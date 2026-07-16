#requires -Version 7.0

param(
    [Parameter(Mandatory = $true)]
    [string] $Tok,

    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $PathRef
    )

    $normalizedPath = $PathRef -replace "/", "\"
    if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
        return $normalizedPath
    }

    return (Join-Path $repoRoot $normalizedPath)
}

$postupakPath = Join-Path $repoRoot ("postupci\sud\prekrsajni\{0}\{1}\postupak.json" -f $Tok, $Verzija)
if (-not (Test-Path -LiteralPath $postupakPath)) {
    Write-Host "ERROR: POSTUPAK_NOT_FOUND=$postupakPath"
    exit 1
}

$postupak = Get-Content -LiteralPath $postupakPath -Raw -Encoding UTF8 | ConvertFrom-Json

$auditPath = Resolve-RepoPath -PathRef ([string]$postupak.ulazi.audit_ref)
$intakePath = Resolve-RepoPath -PathRef ([string]$postupak.ulazi.intake_ref)
$subsumcijaPath = Resolve-RepoPath -PathRef ([string]$postupak.ulazi.subsumcija_ref)
$predlozakPath = Resolve-RepoPath -PathRef ([string]$postupak.ulazi.predlozak_ref)
$outputPath = Resolve-RepoPath -PathRef ([string]$postupak.izlazi.nacrt_ref)

$audit = Get-Content -LiteralPath $auditPath -Raw -Encoding UTF8 | ConvertFrom-Json
$intake = Get-Content -LiteralPath $intakePath -Raw -Encoding UTF8 | ConvertFrom-Json
$null = Get-Content -LiteralPath $subsumcijaPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $predlozakPath)) {
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=missing.predlozak"
    Write-Host "STOP_DETAIL=$predlozakPath"
    exit 0
}

try {
    $null = Get-Content -LiteralPath $predlozakPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=invalid.predlozak"
    Write-Host "STOP_DETAIL=$predlozakPath"
    exit 0
}

if ($audit.gate_stanje.blocked -eq $true) {
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=audit.blocked"
    exit 0
}

$napSem = @($audit.nalazi | Where-Object { [string]$_.kod -eq "NAP-SEM" } | Select-Object -First 1)
if ($napSem.Count -eq 0) {
    Write-Host "ERROR: NAP_SEM_NOT_FOUND"
    exit 1
}

$napSemOpis = [string]$napSem[0].opis
$preflightMatch = [regex]::Match($napSemOpis, "preflight=(ZELENO|ZUTO|CRVENO)")
if (-not $preflightMatch.Success) {
    Write-Host "ERROR: PREFLIGHT_MARKER_NOT_FOUND"
    exit 1
}

$preflightSemafor = $preflightMatch.Groups[1].Value
if ($preflightSemafor -eq "CRVENO") {
    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=preflight.CRVENO"
    exit 0
}

$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$datum = (Get-Date).ToString("dd.MM.yyyy.")
$auditLines = @($audit.nalazi | ForEach-Object {
    "- {0}: {1}" -f ([string]$_.kod), ([string]$_.opis)
})
$osporavanjaText = (@($intake.osporavanja | ForEach-Object { [string]$_ }) -join ", ")

$content = @(
    "NACRT - bez potpisa"
    ""
    "TOK=$Tok"
    "PREDMET_ID=$PredmetId"
    "DATUM=$datum"
    ""
    "AUDIT_NALAZI_BEGIN"
) + $auditLines + @(
    "AUDIT_NALAZI_END"
    ""
    "INTAKE_BEGIN"
    "- cilj: $([string]$intake.cilj)"
    "- osporavanja: $osporavanjaText"
    "- opis: $([string]$intake.opis_dogadaja)"
    "INTAKE_END"
)

Set-Content -LiteralPath $outputPath -Value $content -Encoding utf8NoBOM

Write-Host "RUNNER_RESULT=OK"
Write-Host "OUTPUT_PATH=$outputPath"
exit 0
