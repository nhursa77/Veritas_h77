Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent

$postupakPath = Join-Path $repoRoot "postupci\sud\prekrsajni\TOK_PN_PRIGOVOR\v1\postupak.json"
$auditPath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\audit\audit_v1.json"
$subsumcijaPath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\audit\subsumcija_v1.json"
$intakePath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\intake\intake_v1.json"
$predlozakPath = Join-Path $repoRoot "predlosci\sud\prekrsajni\prigovor_pn\v1\predlozak.json"
$outputPath = Join-Path $repoRoot "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\izlazi\nacrt_prigovor_pn_v1.txt"

$postupak = Get-Content -LiteralPath $postupakPath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $auditPath -Raw | ConvertFrom-Json
$null = Get-Content -LiteralPath $subsumcijaPath -Raw | ConvertFrom-Json
$intake = Get-Content -LiteralPath $intakePath -Raw | ConvertFrom-Json
$null = Get-Content -LiteralPath $predlozakPath -Raw | ConvertFrom-Json

if ($audit.gate_stanje.blocked -eq $true) {
    $reason = [string]$audit.gate_stanje.blocked_razlog
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=$reason"
    exit 0
}

$napSem = @($audit.nalazi | Where-Object { [string]$_.kod -eq "NAP-SEM" } | Select-Object -First 1)
if ($napSem.Count -eq 0) {
    Write-Host "ERROR: NAP-SEM not found in audit.nalazi"
    exit 1
}

$napSemOpis = [string]$napSem[0].opis
$match = [regex]::Match($napSemOpis, "preflight=(ZELENO|ZUTO|CRVENO)")
if (-not $match.Success) {
    Write-Host "ERROR: preflight marker not found in NAP-SEM opis"
    exit 1
}

$semafor = $match.Groups[1].Value
if ($semafor -eq "CRVENO") {
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=preflight=CRVENO"
    exit 0
}

$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$datum = (Get-Date).ToString("dd.MM.yyyy.")
$tok = [string]$postupak.meta.id
$predmetId = [string]$audit.meta.id_predmeta

$auditLines = @($audit.nalazi | ForEach-Object {
    "- {0}: {1}" -f ([string]$_.kod), ([string]$_.opis)
})

$osporavanjaText = (@($intake.osporavanja | ForEach-Object { [string]$_ }) -join ", ")
$nacrtNapomena = "NACRT $([char]0x2014) bez potpisa"

$content = @(
    "Datum: $datum"
    "Tok: $tok"
    "Predmet: $predmetId"
    ""
    "Audit nalazi:"
) + $auditLines + @(
    ""
    "Intake:"
    "- cilj: $([string]$intake.cilj)"
    "- osporavanja: $osporavanjaText"
    "- opis događaja: $([string]$intake.opis_dogadaja)"
    ""
    $nacrtNapomena
)

Set-Content -LiteralPath $outputPath -Value $content -Encoding UTF8

Write-Host "RUNNER_RESULT=OK"
Write-Host "OUTPUT_PATH=$outputPath"
exit 0
