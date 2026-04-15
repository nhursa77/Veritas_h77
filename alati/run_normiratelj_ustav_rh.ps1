[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$convenienceCore = Join-Path $PSScriptRoot "ustav_rh_convenience_core.ps1"
& $convenienceCore -Mode "run_normiratelj"
exit $LASTEXITCODE
