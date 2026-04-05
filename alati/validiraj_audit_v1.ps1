#requires -Version 5.1
<#
.SYNOPSIS
Kompatibilni wrapper za `audit_v*.json` validaciju.

.DESCRIPTION
Zadrzava postojece ime validatora i delegira schema-driven provjeru na
`validiraj_json_po_shemi_v1.ps1` uz `SCHEMA_AUDIT_V1.json`.

.NOTES
- Ova skripta je kompatibilni wrapper.
- Delegira na `validiraj_json_po_shemi_v1.ps1`.
- Koristi `SCHEMA_AUDIT_V1.json`.
#>

[CmdletBinding()]
param(
    [switch]$Pomoc
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$marker = "VALIDATOR_AUDIT_V1"
$opis = "audit v1 wrapper prema generickom schema-driven validatoru"
$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$delegatePath = Join-Path $PSScriptRoot "validiraj_json_po_shemi_v1.ps1"
$schemaPath = Join-Path $repoRoot "dokumentacija\sheme\SCHEMA_AUDIT_V1.json"
$targetRoot = Join-Path $repoRoot "predmeti\sud\prekrsajni"

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

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "audit_v*.json" |
    Where-Object { $_.FullName -match "\\audit\\" }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "$marker`_EXIT=0"
    exit 0
}

$finalExit = 0
foreach ($file in @($files)) {
    $delegateJsonPath = $file.FullName
    $tempJsonPath = $null

    try {
        $doc = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        $requiresNormalization = $false

        foreach ($modul in @($doc.moduli)) {
            if ($null -eq $modul) {
                continue
            }

            if ($null -ne $modul.ulazi -and $modul.ulazi -isnot [System.Array]) {
                $modul.ulazi = @($modul.ulazi)
                $requiresNormalization = $true
            }

            if ($null -ne $modul.izlazi -and $modul.izlazi -isnot [System.Array]) {
                $modul.izlazi = @($modul.izlazi)
                $requiresNormalization = $true
            }
        }

        if ($requiresNormalization) {
            $tempJsonPath = Join-Path $env:TEMP (
                "veritas_audit_v1_wrapper_{0}.json" -f [Guid]::NewGuid().ToString("N")
            )
            $doc | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $tempJsonPath -Encoding UTF8
            $delegateJsonPath = $tempJsonPath
        }
    }
    catch {
        $delegateJsonPath = $file.FullName
    }

    try {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $delegatePath `
            -JsonPutanja $delegateJsonPath `
            -ShemaPutanja $schemaPath `
            -OpisValidatora $opis `
            -OznakaIzlaza "${marker}_DELEGAT"
        $delegateExit = $LASTEXITCODE
    }
    finally {
        if ($null -ne $tempJsonPath -and (Test-Path -LiteralPath $tempJsonPath)) {
            Remove-Item -LiteralPath $tempJsonPath -Force -ErrorAction SilentlyContinue
        }
    }

    if ($delegateExit -ne 0 -and $finalExit -eq 0) {
        $finalExit = $delegateExit
    }
}

Write-Host "$marker`_EXIT=$finalExit"
exit $finalExit