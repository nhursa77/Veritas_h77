param(
    [string]$NormaPutanja = "baza_zakona/norme/ustav_rh_procisceni/clanak_0001.json",
    [string]$ShemaPutanja = "baza_zakona/sheme/NORMA_V1.schema.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "Python nije pronađen u sustavu."
    Write-Host "Pokreni validaciju nakon instalacije Pythona."
    exit 0
}

$provjeraModula = @"
import importlib.util
import sys
sys.exit(0 if importlib.util.find_spec("jsonschema") else 1)
"@

python -c $provjeraModula
if ($LASTEXITCODE -ne 0) {
    Write-Host "Modul 'jsonschema' nije dostupan u aktivnom Python okruženju."
    Write-Host "Instaliraj ga naredbom: pip install jsonschema"
    Write-Host "Preporuka: koristi lokalni .venv za ovaj repozitorij."
    exit 0
}

$skriptaValidacije = @"
import json
import sys
from jsonschema import validate
from jsonschema import ValidationError

norma_putanja = r"$NormaPutanja"
shema_putanja = r"$ShemaPutanja"

with open(shema_putanja, "r", encoding="utf-8") as f:
    shema = json.load(f)

with open(norma_putanja, "r", encoding="utf-8") as f:
    norma = json.load(f)

try:
    validate(instance=norma, schema=shema)
    print("Validacija uspješna: NORMA JSON je usklađen sa shemom.")
except ValidationError as e:
    print("Validacija nije prošla.")
    print(e.message)
    sys.exit(1)
"@

python -c $skriptaValidacije
if ($LASTEXITCODE -ne 0) {
    Write-Host "NORMA JSON nije prošao validaciju."
    exit 1
}
