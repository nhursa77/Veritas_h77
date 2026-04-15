[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int] $ExpectedCountOverride
)

$ErrorActionPreference = "Stop"

$convenienceCore = Join-Path $PSScriptRoot "ustav_rh_convenience_core.ps1"
if ($PSBoundParameters.ContainsKey('ExpectedCountOverride')) {
    & $convenienceCore -Mode "acceptance_preflight" -ExpectedCountOverride $ExpectedCountOverride
}
else {
    & $convenienceCore -Mode "acceptance_preflight"
}

exit $LASTEXITCODE
