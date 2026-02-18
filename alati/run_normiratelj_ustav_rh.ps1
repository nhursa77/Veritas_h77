param()

$ErrorActionPreference = "Stop"

$genericRunner = Join-Path $PSScriptRoot "run_normiratelj.ps1"
& $genericRunner -AktSlug "ustav_rh"
exit $LASTEXITCODE
