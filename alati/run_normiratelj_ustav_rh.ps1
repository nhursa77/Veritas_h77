param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$scriptPath = Join-Path $PSScriptRoot "normiratelj_iz_strukture_nn.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

$inputPath = Join-Path $root "izvori\dokazno\narodne_novine\ustav_rh\struktura_nn_dokumenti.json"
$metaPath = Join-Path $root "izvori\dokazno\narodne_novine\ustav_rh\meta.json"
$outDir = Join-Path $root "baza_zakona\norme\ustav_rh"

Push-Location $root
try {
    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $scriptPath --akt-slug "ustav_rh" --input $inputPath --meta $metaPath --out-dir $outDir
    }
    else {
        python $scriptPath --akt-slug "ustav_rh" --input $inputPath --meta $metaPath --out-dir $outDir
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
