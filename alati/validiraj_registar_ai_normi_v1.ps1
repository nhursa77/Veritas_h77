#requires -Version 7.0

[CmdletBinding()]
param(
    [string] $RegistarPutanja,
    [string] $ShemaPutanja
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($RegistarPutanja)) {
    $RegistarPutanja = Join-Path $repoRoot (
        'dokumentacija\REGISTAR_AI_NORMI_V1.json'
    )
}
if ([string]::IsNullOrWhiteSpace($ShemaPutanja)) {
    $ShemaPutanja = Join-Path $repoRoot (
        'dokumentacija\sheme\SCHEMA_REGISTAR_AI_NORMI_V1.json'
    )
}

function Resolve-VeritasPath {
    param([Parameter(Mandatory = $true)][string] $PathValue)

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PathValue))
}

function Add-RegistryError {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]] $Errors,
        [Parameter(Mandatory = $true)][string] $Code,
        [Parameter(Mandatory = $true)][string] $Detail
    )

    [void]$Errors.Add("$Code`: $Detail")
}

$resolvedRegistry = Resolve-VeritasPath -PathValue $RegistarPutanja
$resolvedSchema = Resolve-VeritasPath -PathValue $ShemaPutanja
$errors = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $resolvedRegistry -PathType Leaf)) {
    Write-Host "ERROR: NEDOSTAJE_REGISTAR=$resolvedRegistry"
    Write-Host 'AI_NORME_VALIDATOR_EXIT=2'
    exit 2
}
if (-not (Test-Path -LiteralPath $resolvedSchema -PathType Leaf)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$resolvedSchema"
    Write-Host 'AI_NORME_VALIDATOR_EXIT=3'
    exit 3
}

try {
    $registryRaw = Get-Content -LiteralPath $resolvedRegistry -Raw -Encoding UTF8
    $registry = $registryRaw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: REGISTAR_JSON_PARSE_FAIL=$resolvedRegistry"
    Write-Host 'AI_NORME_VALIDATOR_EXIT=4'
    exit 4
}

try {
    $schemaValid = $registryRaw | Test-Json -SchemaFile $resolvedSchema
}
catch {
    $schemaValid = $false
}
if (-not $schemaValid) {
    Add-RegistryError `
        -Errors $errors `
        -Code 'SCHEMA_FAIL' `
        -Detail 'Registar ne odgovara zatvorenoj shemi.'
}

$ids = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
$ciSmokePath = Join-Path $repoRoot 'alati\ci_smoke.ps1'
$ciSmokeText = Get-Content -LiteralPath $ciSmokePath -Raw -Encoding UTF8

foreach ($norma in @($registry.norme)) {
    $id = [string]$norma.id
    if (-not $ids.Add($id)) {
        Add-RegistryError `
            -Errors $errors `
            -Code 'DUPLIKAT_ID' `
            -Detail $id
    }

    foreach ($source in @($norma.kanonski_izvori)) {
        $sourcePath = Resolve-VeritasPath -PathValue ([string]$source.putanja)
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            Add-RegistryError `
                -Errors $errors `
                -Code 'NEDOSTAJE_KANONSKI_IZVOR' `
                -Detail "$id -> $($source.putanja)"
        }
    }

    foreach ($implementationPath in @($norma.provedba)) {
        $resolvedImplementation = Resolve-VeritasPath `
            -PathValue ([string]$implementationPath)
        if (-not (Test-Path -LiteralPath $resolvedImplementation -PathType Leaf)) {
            Add-RegistryError `
                -Errors $errors `
                -Code 'NEDOSTAJE_PROVEDBA' `
                -Detail "$id -> $implementationPath"
        }
    }

    foreach ($testPath in @($norma.testovi)) {
        $resolvedTest = Resolve-VeritasPath -PathValue ([string]$testPath)
        if (-not (Test-Path -LiteralPath $resolvedTest -PathType Leaf)) {
            Add-RegistryError `
                -Errors $errors `
                -Code 'NEDOSTAJE_TEST' `
                -Detail "$id -> $testPath"
        }
    }

    foreach ($ciStep in @($norma.ci_koraci)) {
        $escapedCiStep = [regex]::Escape([string]$ciStep)
        if ($ciSmokeText -notmatch ('Name\s*=\s*"' + $escapedCiStep + '"')) {
            Add-RegistryError `
                -Errors $errors `
                -Code 'NEDOSTAJE_CI_KORAK' `
                -Detail "$id -> $ciStep"
        }
    }

    if (
        [string]$norma.razina_dokaza -in @('D3', 'D4') -and
        @($norma.testovi).Count -eq 0
    ) {
        Add-RegistryError `
            -Errors $errors `
            -Code 'DOKAZ_BEZ_TESTA' `
            -Detail "$id -> $($norma.razina_dokaza)"
    }
    if (
        [string]$norma.razina_dokaza -eq 'D4' -and
        @($norma.ci_koraci).Count -eq 0
    ) {
        Add-RegistryError `
            -Errors $errors `
            -Code 'D4_BEZ_CI' `
            -Detail $id
    }
    if (
        [string]$norma.razina_dokaza -eq 'D5' -and
        -not [bool]$norma.zahtijeva_ljudsku_odluku
    ) {
        Add-RegistryError `
            -Errors $errors `
            -Code 'D5_BEZ_LJUDSKE_ODLUKE' `
            -Detail $id
    }
}

if ($errors.Count -gt 0) {
    foreach ($validationError in $errors) {
        Write-Host "ERROR: $validationError"
    }
    Write-Host "AI_NORME_BROJ_NORMI=$(@($registry.norme).Count)"
    Write-Host 'AI_NORME_VALIDATOR_STATUS=NEVALIDNO'
    Write-Host 'AI_NORME_VALIDATOR_EXIT=1'
    exit 1
}

Write-Host "AI_NORME_REGISTAR=$resolvedRegistry"
Write-Host "AI_NORME_SHEMA=$resolvedSchema"
Write-Host "AI_NORME_BROJ_NORMI=$(@($registry.norme).Count)"
Write-Host 'AI_NORME_VALIDATOR_STATUS=VALIDNO'
Write-Host 'AI_NORME_VALIDATOR_EXIT=0'
exit 0
