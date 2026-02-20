$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_POSTUPAK_V1.json"

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
    Write-Host "VALIDATOR_POSTUPAK_V1_EXIT=1"
    exit 1
}

$schema = Get-Content -LiteralPath $schemaPath -Raw | ConvertFrom-Json

$targetRoot = Join-Path $repoRoot "postupci\sud\prekrsajni"
if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_POSTUPAK_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "postupak.json"

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_POSTUPAK_V1_EXIT=0"
    exit 0
}

function Test-RequiredProps {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)] [string[]] $Required,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    foreach ($name in $Required) {
        if ($null -eq $Object.PSObject.Properties[$name]) {
            Write-Host "ERROR: MISSING_REQUIRED $Path.$name"
            return $false
        }
    }

    return $true
}

$ok = $true
$requiredRoot = @($schema.required)
$requiredMeta = @($schema.properties.meta.required)
$requiredKorak = @($schema.properties.koraci.items.required)
$requiredGate = @($schema.properties.koraci.items.properties.gate.items.required)
$allowedOperator = @($schema.properties.koraci.items.properties.gate.items.properties.operator.enum)
$allowedAkcija = @($schema.properties.koraci.items.properties.gate.items.properties.akcija_na_fail.enum)

foreach ($file in $files) {
    try {
        $doc = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: JSON_PARSE_FAIL $($file.FullName)"
        $ok = $false
        continue
    }

    if (-not (Test-RequiredProps -Object $doc -Required $requiredRoot -Path "root")) {
        Write-Host "ERROR: ROOT_KEYS_FAIL $($file.FullName)"
        $ok = $false
        continue
    }

    if (-not (Test-RequiredProps -Object $doc.meta -Required $requiredMeta -Path "meta")) {
        Write-Host "ERROR: META_KEYS_FAIL $($file.FullName)"
        $ok = $false
    }

    foreach ($korak in @($doc.koraci)) {
        if (-not (Test-RequiredProps -Object $korak -Required $requiredKorak -Path "koraci[]")) {
            Write-Host "ERROR: KORAK_KEYS_FAIL $($file.FullName)"
            $ok = $false
            continue
        }

        if ($korak.id -isnot [string]) {
            Write-Host "ERROR: KORAK_ID_TYPE_FAIL $($file.FullName)"
            $ok = $false
        }

        if ($korak.ulazi -isnot [System.Array] -or $korak.izlazi -isnot [System.Array]) {
            Write-Host "ERROR: KORAK_IO_ARRAY_FAIL $($file.FullName)"
            $ok = $false
        }

        foreach ($gate in @($korak.gate)) {
            if (-not (Test-RequiredProps -Object $gate -Required $requiredGate -Path "koraci[].gate[]")) {
                Write-Host "ERROR: GATE_KEYS_FAIL $($file.FullName)"
                $ok = $false
                continue
            }

            if ($allowedOperator -notcontains [string]$gate.operator) {
                Write-Host "ERROR: GATE_OPERATOR_FAIL $($file.FullName)"
                $ok = $false
            }

            if ($allowedAkcija -notcontains [string]$gate.akcija_na_fail) {
                Write-Host "ERROR: GATE_AKCIJA_FAIL $($file.FullName)"
                $ok = $false
            }
        }
    }
}

if ($ok) {
    Write-Host "VALIDATOR_POSTUPAK_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_POSTUPAK_V1_EXIT=1"
exit 1