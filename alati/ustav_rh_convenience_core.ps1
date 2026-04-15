param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("run_normiratelj", "acceptance_preflight")]
    [string] $Mode,

    [Parameter(Mandatory = $false)]
    [Nullable[int]] $ExpectedCountOverride
)

$ErrorActionPreference = "Stop"

$runNormirateljScript = Join-Path $PSScriptRoot "run_normiratelj.ps1"
$acceptancePreflightScript = Join-Path $PSScriptRoot "acceptance_preflight.ps1"

switch ($Mode) {
    "run_normiratelj" {
        & $runNormirateljScript -AktSlug "ustav_rh"
        exit $LASTEXITCODE
    }

    "acceptance_preflight" {
        if ($null -ne $ExpectedCountOverride) {
            & $acceptancePreflightScript -AktSlug "ustav_rh" -ExpectedCountOverride $ExpectedCountOverride.Value
        }
        else {
            & $acceptancePreflightScript -AktSlug "ustav_rh"
        }

        exit $LASTEXITCODE
    }
}
