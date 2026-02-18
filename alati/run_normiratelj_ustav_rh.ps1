param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$scriptPath = Join-Path $PSScriptRoot "normiratelj_iz_strukture_nn.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

$sourceSlug = "ustav_rh_nn_85_2010"
$operativniSlug = "ustav_rh"

$inputPath = Join-Path $root "izvori\dokazno\narodne_novine\$sourceSlug\struktura_nn_dokumenti.json"
$metaPath = Join-Path $root "izvori\dokazno\narodne_novine\$sourceSlug\meta.json"
$sourceOutDir = Join-Path $root "baza_zakona\norme\$sourceSlug"
$operativniOutDir = Join-Path $root "baza_zakona\norme\$operativniSlug"
$arhivaDir = Join-Path $root "baza_zakona\arhiva\ustav_rh_nn_56_1990_1092_142"

Push-Location $root
try {
    if (!(Test-Path -LiteralPath $inputPath)) {
        throw "Nedostaje ulazna dokument-split struktura: $inputPath"
    }

    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $scriptPath --akt-slug $sourceSlug --input $inputPath --meta $metaPath --out-dir $sourceOutDir
    }
    else {
        python $scriptPath --akt-slug $sourceSlug --input $inputPath --meta $metaPath --out-dir $sourceOutDir
    }

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    if ((Test-Path -LiteralPath $operativniOutDir) -and !(Test-Path -LiteralPath $arhivaDir)) {
        New-Item -ItemType Directory -Force -Path $arhivaDir | Out-Null
        Copy-Item -Path (Join-Path $operativniOutDir "*") -Destination $arhivaDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $operativniOutDir | Out-Null
    Get-ChildItem -LiteralPath $operativniOutDir -Filter "clanak_*.json" -File | Remove-Item -Force
    Remove-Item -LiteralPath (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -ErrorAction SilentlyContinue

    Copy-Item -Path (Join-Path $sourceOutDir "clanak_*.json") -Destination $operativniOutDir -Force
    Copy-Item -LiteralPath (Join-Path $sourceOutDir "IZVJESTAJ_NORMIRANJA.md") -Destination (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -Force

    Write-Host "Operativni set ažuriran: $operativniOutDir (izvor: $sourceOutDir)"
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
