param(
    [string]$AktSlug = "ustav_rh"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$kontrolaScript = Join-Path $PSScriptRoot "kontroliraj_arhivu_nn.ps1"
$pythonScript = Join-Path $PSScriptRoot "parsiraj_nn_html.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

Push-Location $root
try {
    & $kontrolaScript
    if ($LASTEXITCODE -ne 0) {
        throw "Kontrola arhive nije uspješno završena."
    }

    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $pythonScript $AktSlug
    }
    else {
        python $pythonScript $AktSlug
    }

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
