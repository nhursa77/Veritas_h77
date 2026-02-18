param(
    [Parameter(Mandatory = $true)]
    [string] $AktSlug,

    [Parameter(Mandatory = $false)]
    [int] $ExpectedCountOverride
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$validator = Join-Path $PSScriptRoot "validiraj_nn_vs_kontrolno.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"
$reportPathRel = "baza_zakona/norme/$AktSlug/IZVJESTAJ_VALIDACIJE_KONTROLNO.md"
$controlJsonRel = "izvori/kontrolno/zakon_hr/$AktSlug/struktura_kontrolno_dokumenti.json"

function Get-SlugEnvKey {
    param([string] $Value)
    $token = ($Value.ToUpperInvariant() -replace '[^A-Z0-9]+', '_').Trim('_')
    return "VERITAS_${token}_EXPECTED_COUNT_OVERRIDE"
}

$overrideEnvName = Get-SlugEnvKey -Value $AktSlug
$overrideWasSet = $false

Push-Location $root
try {
    if ($PSBoundParameters.ContainsKey('ExpectedCountOverride')) {
        Set-Item -Path "Env:$overrideEnvName" -Value ([string]$ExpectedCountOverride)
        $overrideWasSet = $true
    }

    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $validator -AktSlug $AktSlug
    }
    else {
        python $validator -AktSlug $AktSlug
    }

    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Host "OK"
    }
    else {
        Write-Host "FAIL (exit code $exitCode)"
    }

    # Repo hygiene: rollback generated artifacts for this akt.
    try {
        git restore -- $reportPathRel $controlJsonRel 2>$null | Out-Null
    }
    catch {
        # Ignore when paths are not yet tracked in git for new akt ingests.
    }
    git status --short

    exit $exitCode
}
finally {
    if ($overrideWasSet) {
        Remove-Item -Path "Env:$overrideEnvName" -ErrorAction SilentlyContinue
    }
    Pop-Location
}
