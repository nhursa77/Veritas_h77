Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$outputPath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\izlazi\nacrt_prigovor_pn_v1.txt"

if (-not (Test-Path -LiteralPath $outputPath)) {
    Write-Host "ERROR: OUTPUT_NOT_FOUND=$outputPath"
    Write-Host "VALIDATOR_IZLAZ_TOK_PN_PRIGOVOR_V1_EXIT=1"
    exit 1
}

$fileInfo = Get-Item -LiteralPath $outputPath
if ($fileInfo.Length -le 0) {
    Write-Host "ERROR: OUTPUT_EMPTY=$outputPath"
    Write-Host "VALIDATOR_IZLAZ_TOK_PN_PRIGOVOR_V1_EXIT=1"
    exit 1
}

$content = Get-Content -LiteralPath $outputPath -Raw
$requiredText = "NACRT — bez potpisa"
if ($content -notmatch [regex]::Escape($requiredText)) {
    Write-Host "ERROR: OUTPUT_MISSING_REQUIRED_TEXT"
    Write-Host "VALIDATOR_IZLAZ_TOK_PN_PRIGOVOR_V1_EXIT=1"
    exit 1
}

Write-Host "VALIDATOR_IZLAZ_TOK_PN_PRIGOVOR_V1_EXIT=0"
exit 0
