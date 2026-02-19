param()

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$schemaPath = Join-Path $root "dokumentacija\sheme\SCHEMA_DELTA_OPS.json"
$deltaRoot = Join-Path $root "izvori\kontrolno\zakon_hr"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"
$pythonExe = if (Test-Path -LiteralPath $venvPython) { $venvPython } else { "python" }

if (!(Test-Path -LiteralPath $schemaPath)) {
    Write-Host "DELTA_OPS_SCHEMA_PATH: $schemaPath"
    Write-Host "ERROR: nedostaje kanonska shema SCHEMA_DELTA_OPS.json"
    exit 2
}

$deltaFiles = @()
if (Test-Path -LiteralPath $deltaRoot) {
    $deltaFiles = @(
        Get-ChildItem -LiteralPath $deltaRoot -Recurse -Filter "*_delta_ops.json" -File -ErrorAction SilentlyContinue |
            Sort-Object -Property FullName
    )
}

Write-Host "DELTA_OPS_SCHEMA_PATH: $schemaPath"
Write-Host "DELTA_OPS_FILES_COUNT: $($deltaFiles.Count)"

$validatorScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("veritas_validate_delta_ops_{0}.py" -f ([guid]::NewGuid().ToString("N")))
$validatorScript = @'
import json
import sys
from pathlib import Path

try:
    from jsonschema import Draft202012Validator
    HAS_JSONSCHEMA = True
except Exception:
    HAS_JSONSCHEMA = False

def _type_ok(value, expected):
    if expected == "object":
        return isinstance(value, dict)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if expected == "null":
        return value is None
    return False

def _check_type(value, schema_type):
    if isinstance(schema_type, list):
        return any(_type_ok(value, t) for t in schema_type)
    return _type_ok(value, schema_type)

def _path_text(path_parts):
    if not path_parts:
        return "<root>"
    return "/".join(str(p) for p in path_parts)

def _fallback_validate(schema, value, path_parts):
    errors = []

    schema_type = schema.get("type")
    if schema_type is not None and not _check_type(value, schema_type):
        errors.append(f"path={_path_text(path_parts)}: očekivan type={schema_type}")
        return errors

    if isinstance(value, dict):
        required = schema.get("required", [])
        for key in required:
            if key not in value:
                errors.append(f"path={_path_text(path_parts)}: nedostaje obavezno polje '{key}'")

        properties = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            for key in value.keys():
                if key not in properties:
                    errors.append(f"path={_path_text(path_parts + [key])}: dodatno polje nije dozvoljeno")

        for key, child_schema in properties.items():
            if key in value:
                errors.extend(_fallback_validate(child_schema, value[key], path_parts + [key]))

        return errors

    if isinstance(value, list) and "items" in schema:
        item_schema = schema["items"]
        for idx, item in enumerate(value):
            errors.extend(_fallback_validate(item_schema, item, path_parts + [idx]))

    return errors

if len(sys.argv) < 2:
    print("ERROR: nedostaje putanja sheme.")
    sys.exit(4)

schema_path = Path(sys.argv[1])
file_paths = [Path(p) for p in sys.argv[2:]]

try:
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
except Exception as exc:
    print(f"ERROR: ne mogu učitati shemu: {schema_path} ({exc})")
    sys.exit(5)

validator = Draft202012Validator(schema) if HAS_JSONSCHEMA else None
has_errors = False

for path in sorted(file_paths, key=lambda p: str(p).lower()):
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"DELTA_OPS_INVALID: {path}: nevaljan JSON ({exc})")
        has_errors = True
        continue

    if HAS_JSONSCHEMA:
        errors = sorted(
            validator.iter_errors(payload),
            key=lambda e: (list(e.absolute_path), e.message),
        )
        if errors:
            first_error = errors[0]
            json_path = "/".join(str(p) for p in first_error.absolute_path)
            if json_path == "":
                json_path = "<root>"
            print(f"DELTA_OPS_INVALID: {path}: path={json_path}: {first_error.message}")
            has_errors = True
        else:
            print(f"DELTA_OPS_VALID: {path}")
    else:
        fallback_errors = _fallback_validate(schema, payload, [])
        if fallback_errors:
            print(f"DELTA_OPS_INVALID: {path}: {fallback_errors[0]}")
            has_errors = True
        else:
            print(f"DELTA_OPS_VALID: {path}")

if has_errors:
    sys.exit(1)

print("DELTA_OPS_SCHEMA_VALIDATION=OK")
sys.exit(0)
'@

Set-Content -LiteralPath $validatorScriptPath -Value $validatorScript -Encoding UTF8

try {
    $pythonArgs = @($validatorScriptPath, $schemaPath)
    foreach ($file in $deltaFiles) {
        $pythonArgs += $file.FullName
    }

    & $pythonExe @pythonArgs
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        Write-Host "ERROR: validacija *_delta_ops.json po shemi nije prošla."
        exit $exitCode
    }

    exit 0
}
finally {
    if (Test-Path -LiteralPath $validatorScriptPath) {
        Remove-Item -LiteralPath $validatorScriptPath -Force -ErrorAction SilentlyContinue
    }
}
