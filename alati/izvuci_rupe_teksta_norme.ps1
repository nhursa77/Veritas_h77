param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$pythonScript = Join-Path $PSScriptRoot "izvuci_rupe_teksta_norme.py"
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
