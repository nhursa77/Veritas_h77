param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$pythonScript = Join-Path $PSScriptRoot "kontroliraj_arhivu_nn.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

Push-Location $root
try {
    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $pythonScript
    }
    else {
        python $pythonScript
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
