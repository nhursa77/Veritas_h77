$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$targetRoot = Join-Path $repoRoot "predmeti\sud\prekrsajni"

if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "audit_generated_v1.json" |
    Where-Object { $_.FullName -match "\\audit\\" }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

$requiredCodes = @("NAP-G1", "NAP-G2", "NAP-G3", "NAP-SEM", "NAP-ODL")
$ok = $true

foreach ($file in $files) {
    try {
        $doc = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: JSON_PARSE_FAIL $($file.FullName)"
        $ok = $false
        continue
    }

    if ($null -eq $doc.meta) {
        Write-Host "ERROR: MISSING_META $($file.FullName)"
        $ok = $false
    }

    if ($null -eq $doc.gate_stanje) {
        Write-Host "ERROR: MISSING_GATE_STANJE $($file.FullName)"
        $ok = $false
    }

    if ($null -eq $doc.nalazi -or $doc.nalazi -isnot [System.Array]) {
        Write-Host "ERROR: MISSING_NALAZI_ARRAY $($file.FullName)"
        $ok = $false
        continue
    }

    $codes = @($doc.nalazi | ForEach-Object { [string]$_.kod })
    foreach ($requiredCode in $requiredCodes) {
        if ($codes -notcontains $requiredCode) {
            Write-Host "ERROR: MISSING_NALAZ_KOD=$requiredCode FILE=$($file.FullName)"
            $ok = $false
        }
    }
}

if ($ok) {
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=1"
exit 1
