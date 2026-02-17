param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$pythonScript = Get-ChildItem -Path $PSScriptRoot -Filter "provjeri_uskla*norme.py" | Select-Object -First 1 -ExpandProperty FullName
$pythonScript = [string]$pythonScript
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
