$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_AUDIT_V1.json"

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
    Write-Host "VALIDATOR_AUDIT_V1_EXIT=1"
    exit 1
}

$schema = Get-Content -LiteralPath $schemaPath -Raw | ConvertFrom-Json

$targetRoot = Join-Path $repoRoot "predmeti\sud\prekrsajni"
if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "audit_v*.json" |
    Where-Object { $_.FullName -match "\\audit\\" }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_V1_EXIT=0"
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
$requiredModul = @($schema.properties.moduli.items.required)
$requiredNalaz = @($schema.properties.nalazi.items.required)
$requiredRok = @($schema.properties.rokovi.items.required)
$requiredLijek = @($schema.properties.preporuceni_pravni_lijek.required)
$requiredGate = @($schema.properties.gate_stanje.required)
$enumStatus = @($schema.properties.moduli.items.properties.status.enum)
$enumTezina = @($schema.properties.nalazi.items.properties.tezina.enum)

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

    if (-not (Test-RequiredProps -Object $doc.preporuceni_pravni_lijek -Required $requiredLijek -Path "preporuceni_pravni_lijek")) {
        Write-Host "ERROR: LIJEK_KEYS_FAIL $($file.FullName)"
        $ok = $false
    }

    if (-not (Test-RequiredProps -Object $doc.gate_stanje -Required $requiredGate -Path "gate_stanje")) {
        Write-Host "ERROR: GATE_KEYS_FAIL $($file.FullName)"
        $ok = $false
    }

    foreach ($modul in @($doc.moduli)) {
        if (-not (Test-RequiredProps -Object $modul -Required $requiredModul -Path "moduli[]")) {
            Write-Host "ERROR: MODUL_KEYS_FAIL $($file.FullName)"
            $ok = $false
            continue
        }

        if ($enumStatus -notcontains [string]$modul.status) {
            Write-Host "ERROR: MODUL_STATUS_ENUM_FAIL $($file.FullName)"
            $ok = $false
        }
    }

    foreach ($nalaz in @($doc.nalazi)) {
        if (-not (Test-RequiredProps -Object $nalaz -Required $requiredNalaz -Path "nalazi[]")) {
            Write-Host "ERROR: NALAZ_KEYS_FAIL $($file.FullName)"
            $ok = $false
            continue
        }

        if ($enumTezina -notcontains [string]$nalaz.tezina) {
            Write-Host "ERROR: NALAZ_TEZINA_ENUM_FAIL $($file.FullName)"
            $ok = $false
        }
    }

    foreach ($rok in @($doc.rokovi)) {
        if (-not (Test-RequiredProps -Object $rok -Required $requiredRok -Path "rokovi[]")) {
            Write-Host "ERROR: ROK_KEYS_FAIL $($file.FullName)"
            $ok = $false
        }
    }
}

if ($ok) {
    Write-Host "VALIDATOR_AUDIT_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_AUDIT_V1_EXIT=1"
exit 1