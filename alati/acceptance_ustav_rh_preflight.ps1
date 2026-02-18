param()

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$validator = Join-Path $PSScriptRoot "validiraj_nn_vs_kontrolno.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

Push-Location $root
try {
    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $validator
    }
    else {
        python $validator
    }

    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Host "OK"
    }
    else {
        Write-Host "FAIL (exit code $exitCode)"
    }

    exit $exitCode
}
finally {
    Pop-Location
}
