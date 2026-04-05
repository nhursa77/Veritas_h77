#requires -Version 5.1
<#
.SYNOPSIS
Kompatibilni wrapper za `predlozak.json` validaciju.

.DESCRIPTION
Zadrzava postojece ime validatora i delegira schema-driven provjeru na
`validiraj_json_po_shemi_v1.ps1` uz `SCHEMA_PREDLOZAK_V1.json`.

.NOTES
- Ova skripta je kompatibilni wrapper.
- Delegira na `validiraj_json_po_shemi_v1.ps1`.
- Koristi `SCHEMA_PREDLOZAK_V1.json`.
#>

[CmdletBinding()]
param(
    [switch]$Pomoc
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$marker = "VALIDATOR_PREDLOZAK_V1"
$opis = "predlozak v1 wrapper prema generickom schema-driven validatoru"
$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$delegatePath = Join-Path $PSScriptRoot "validiraj_json_po_shemi_v1.ps1"
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_PREDLOZAK_V1.json"
$targetRoot = Join-Path $repoRoot "predlosci\sud\prekrsajni"

if ($Pomoc) {
    Get-Help -Detailed $PSCommandPath
    exit 0
}

if (-not (Test-Path -LiteralPath $delegatePath)) {
    Write-Host "ERROR: NEDOSTAJE_DELEGAT=$delegatePath"
    Write-Host "$marker`_EXIT=4"
    exit 4
}

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
    Write-Host "$marker`_EXIT=3"
    exit 3
}

if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "$marker`_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "predlozak.json"

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "$marker`_EXIT=0"
    exit 0
}

$finalExit = 0
foreach ($file in @($files)) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $delegatePath `
        -JsonPutanja $file.FullName `
        -ShemaPutanja $schemaPath `
        -OpisValidatora $opis `
        -OznakaIzlaza "${marker}_DELEGAT"
    $delegateExit = $LASTEXITCODE

    if ($delegateExit -ne 0 -and $finalExit -eq 0) {
        $finalExit = $delegateExit
    }
}

Write-Host "$marker`_EXIT=$finalExit"
exit $finalExit