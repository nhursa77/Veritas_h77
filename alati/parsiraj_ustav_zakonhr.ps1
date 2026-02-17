$ErrorActionPreference = "Stop"

$repoKorijen = Split-Path -Parent $PSScriptRoot
$python = Get-Command python -ErrorAction SilentlyContinue

if (-not $python) {
    Write-Host "Python nije pronađen u sustavu."
    exit 1
}

$pythonSkripta = Join-Path $PSScriptRoot "parsiraj_ustav_zakonhr.py"
& python $pythonSkripta

if ($LASTEXITCODE -ne 0) {
    Write-Host "Parsiranje nije uspjelo."
    exit $LASTEXITCODE
}

$izlaz = Join-Path $repoKorijen "izvori/operativno/zakon_hr/ustav_rh/ustav_rh_struktura.json"
if (-not (Test-Path -LiteralPath $izlaz)) {
    Write-Host "Izlazna datoteka nije pronađena."
    exit 1
}

$objekt = Get-Content -LiteralPath $izlaz -Raw | ConvertFrom-Json
$brojClanka = @($objekt.clanci).Count
Write-Host "Pronađeno članaka: $brojClanka"
