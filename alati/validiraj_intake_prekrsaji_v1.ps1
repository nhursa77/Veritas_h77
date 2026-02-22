$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_INTAKE_PREKRSAJI_V1.json"

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
    Write-Host "VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=1"
    exit 1
}

$schema = Get-Content -LiteralPath $schemaPath -Raw | ConvertFrom-Json

$targetRoot = Join-Path $repoRoot "predmeti\sud\prekrsajni"
if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "intake_v*.json" |
    Where-Object { $_.FullName -match "\\intake\\" }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=0"
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
$requiredKontradikcije = @($schema.properties.kontradikcije.required)
$enumCilj = @($schema.properties.cilj.enum)
$enumOsporavanja = @($schema.properties.osporavanja.items.enum)

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

    if (-not (Test-RequiredProps -Object $doc.kontradikcije -Required $requiredKontradikcije -Path "kontradikcije")) {
        Write-Host "ERROR: KONTRADIKCIJE_KEYS_FAIL $($file.FullName)"
        $ok = $false
    }

    if ($enumCilj -notcontains [string]$doc.cilj) {
        Write-Host "ERROR: CILJ_ENUM_FAIL $($file.FullName)"
        $ok = $false
    }

    foreach ($osporavanje in @($doc.osporavanja)) {
        if ($enumOsporavanja -notcontains [string]$osporavanje) {
            Write-Host "ERROR: OSPORAVANJA_ENUM_FAIL $($file.FullName)"
            $ok = $false
        }
    }

    if ($doc.kontradikcije.ima_kontradikcija -isnot [bool]) {
        Write-Host "ERROR: KONTRADIKCIJE_BOOL_FAIL $($file.FullName)"
        $ok = $false
    }

    if ($doc.kontradikcije.opis -isnot [string]) {
        Write-Host "ERROR: KONTRADIKCIJE_OPIS_TYPE_FAIL $($file.FullName)"
        $ok = $false
    }
}

if ($ok) {
    Write-Host "VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=1"
exit 1
