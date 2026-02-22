param(
    [Parameter(Mandatory = $false)]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $outputPath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\izlazi\nacrt_prigovor_pn_v1.txt"
}
else {
    $normalizedPath = $OutputPath -replace "/", "\"
    if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
        $outputPath = $normalizedPath
    }
    else {
        $outputPath = Join-Path $repoRoot $normalizedPath
    }
}

if (-not (Test-Path -LiteralPath $outputPath)) {
    Write-Host "ERROR: OUTPUT_NOT_FOUND=$outputPath"
    Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=1"
    exit 1
}

$fileInfo = Get-Item -LiteralPath $outputPath
if ($fileInfo.Length -le 0) {
    Write-Host "ERROR: OUTPUT_EMPTY=$outputPath"
    Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=1"
    exit 1
}

$content = Get-Content -LiteralPath $outputPath -Raw
$requiredMarkers = @(
    "NACRT - bez potpisa",
    "TOK=",
    "PREDMET_ID=",
    "DATUM=",
    "AUDIT_NALAZI_BEGIN",
    "AUDIT_NALAZI_END",
    "INTAKE_BEGIN",
    "INTAKE_END"
)

foreach ($marker in $requiredMarkers) {
    if ($content -notmatch [regex]::Escape($marker)) {
        Write-Host "ERROR: OUTPUT_MISSING_MARKER=$marker"
        Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=1"
        exit 1
    }
}

Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=0"
exit 0
