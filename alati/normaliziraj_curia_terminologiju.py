from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

DEFAULT_RAW_INPUT = Path(
    "izvori/operativno/eu/curia/vjm_iate/iate_popis_svih_jezika_raw.json"
)
DEFAULT_STRUCTURE_INPUT = Path(
    "izvori/operativno/eu/curia/vjm_iate/iate_popis_svih_jezika_struktura.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/eu/curia/terminoloski_zapisi.json")


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _first_non_empty(values: list[Any]) -> Any:
    for value in values:
        if value is None:
            continue
        if isinstance(value, str) and value.strip() == "":
            continue
        return value
    return None


def _record_id(source_file: str, worksheet: str, row_index: int) -> str:
    seed = f"{source_file}|{worksheet}|{row_index}".encode("utf-8")
    return hashlib.sha256(seed).hexdigest()[:24]


def _normalize(
    raw_payload: dict[str, Any], structure_payload: dict[str, Any]
) -> tuple[dict[str, Any], int]:
    structure_map: dict[str, int] = {}
    for ws in structure_payload.get("worksheets", []):
        worksheet_name = ws.get("worksheet")
        if isinstance(worksheet_name, str):
            structure_map[worksheet_name] = int(ws.get("column_count", 0))

    source_file = str(raw_payload.get("izvor", ""))
    normalized_records: list[dict[str, Any]] = []
    null_key_count = 0

    for ws in raw_payload.get("worksheets", []):
        worksheet = ws.get("worksheet")
        if not isinstance(worksheet, str):
            continue

        expected_columns = structure_map.get(worksheet, 0)
        for row in ws.get("rows", []):
            row_index = int(row.get("row_index", 0))
            values = row.get("values", [])
            if not isinstance(values, list):
                values = []

            if expected_columns > 0 and len(values) < expected_columns:
                values = values + [None] * (expected_columns - len(values))

            pojam_izvornik = _first_non_empty(values)
            jezik_izvornika = None
            napomena = None
            pravna_referenca = None

            record = {
                "izvor_sustav": "CURIA_VJM_IATE",
                "izvor_datoteka": source_file,
                "worksheet": worksheet,
                "redni_broj_izvora": row_index,
                "pojam_izvornik": pojam_izvornik,
                "jezik_izvornika": jezik_izvornika,
                "ekvivalenti": values,
                "napomena": napomena,
                "pravna_referenca": pravna_referenca,
                "oznaka_zapisa": _record_id(source_file, worksheet, row_index),
                "status_normalizacije": "SIROVO_NORMALIZIRANO",
            }
            normalized_records.append(record)

            if (
                pojam_izvornik is None
                or jezik_izvornika is None
                or pravna_referenca is None
            ):
                null_key_count += 1

    output_payload = {
        "izvor_raw": str(DEFAULT_RAW_INPUT.as_posix()),
        "izvor_struktura": str(DEFAULT_STRUCTURE_INPUT.as_posix()),
        "ukupno_zapisa": len(normalized_records),
        "status_normalizacije": "SIROVO_NORMALIZIRANO",
        "zapisi": normalized_records,
    }
    return output_payload, null_key_count


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Normalizira CURIA sirovi JSON u kanonske terminološke zapise."
    )
    parser.add_argument("--raw-input", type=Path, default=DEFAULT_RAW_INPUT)
    parser.add_argument("--structure-input", type=Path, default=DEFAULT_STRUCTURE_INPUT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.raw_input.exists():
        print(f"ERROR: Nedostaje raw ulaz: {args.raw_input}")
        return 2
    if not args.structure_input.exists():
        print(f"ERROR: Nedostaje struktura ulaz: {args.structure_input}")
        return 3

    raw_payload = _load_json(args.raw_input)
    structure_payload = _load_json(args.structure_input)

    output_payload, null_key_count = _normalize(raw_payload, structure_payload)
    _write_json(args.output, output_payload)

    print(f"NORMALIZED_RECORDS={output_payload['ukupno_zapisa']}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"NULL_KEY_FIELDS_RECORDS={null_key_count}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
