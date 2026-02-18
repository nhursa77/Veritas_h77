param(
    [Parameter(Mandatory = $false)]
    [int] $ExpectedCountOverride
)

$ErrorActionPreference = "Stop"

$genericPreflight = Join-Path $PSScriptRoot "acceptance_preflight.ps1"
if ($PSBoundParameters.ContainsKey('ExpectedCountOverride')) {
    & $genericPreflight -AktSlug "ustav_rh" -ExpectedCountOverride $ExpectedCountOverride
}
else {
    & $genericPreflight -AktSlug "ustav_rh"
}

exit $LASTEXITCODE
