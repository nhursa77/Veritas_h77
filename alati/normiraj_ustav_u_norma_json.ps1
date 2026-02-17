param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$pythonScript = Join-Path $PSScriptRoot "normiraj_ustav_u_norma_json.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

Push-Location $root
try {
    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $pythonScript
    }
    else {
        python $pythonScript
    }
}
finally {
    Pop-Location
}
