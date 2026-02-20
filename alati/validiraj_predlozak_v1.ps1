$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_PREDLOZAK_V1.json"

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
    Write-Host "VALIDATOR_PREDLOZAK_V1_EXIT=1"
    exit 1
}

$schema = Get-Content -LiteralPath $schemaPath -Raw | ConvertFrom-Json

$targetRoot = Join-Path $repoRoot "predlosci\sud\prekrsajni"
if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_PREDLOZAK_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "predlozak.json"

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_PREDLOZAK_V1_EXIT=0"
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
$requiredSekcija = @($schema.properties.sekcije.items.required)
$requiredPolje = @($schema.properties.sekcije.items.properties.polja.items.required)
$requiredMapiranje = @($schema.properties.mapiranje.required)
$requiredPravilo = @($schema.properties.mapiranje.properties.pravila.items.required)
$enumTransformacija = @($schema.properties.mapiranje.properties.pravila.items.properties.transformacija.enum)

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

    foreach ($sekcija in @($doc.sekcije)) {
        if (-not (Test-RequiredProps -Object $sekcija -Required $requiredSekcija -Path "sekcije[]")) {
            Write-Host "ERROR: SEKCIJA_KEYS_FAIL $($file.FullName)"
            $ok = $false
            continue
        }

        foreach ($polje in @($sekcija.polja)) {
            if (-not (Test-RequiredProps -Object $polje -Required $requiredPolje -Path "sekcije[].polja[]")) {
                Write-Host "ERROR: POLJE_KEYS_FAIL $($file.FullName)"
                $ok = $false
            }
        }
    }

    if (-not (Test-RequiredProps -Object $doc.mapiranje -Required $requiredMapiranje -Path "mapiranje")) {
        Write-Host "ERROR: MAPIRANJE_KEYS_FAIL $($file.FullName)"
        $ok = $false
        continue
    }

    foreach ($pravilo in @($doc.mapiranje.pravila)) {
        if (-not (Test-RequiredProps -Object $pravilo -Required $requiredPravilo -Path "mapiranje.pravila[]")) {
            Write-Host "ERROR: PRAVILO_KEYS_FAIL $($file.FullName)"
            $ok = $false
            continue
        }

        if ($enumTransformacija -notcontains [string]$pravilo.transformacija) {
            Write-Host "ERROR: TRANSFORMACIJA_ENUM_FAIL $($file.FullName)"
            $ok = $false
        }
    }
}

if ($ok) {
    Write-Host "VALIDATOR_PREDLOZAK_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_PREDLOZAK_V1_EXIT=1"
exit 1