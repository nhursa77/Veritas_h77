from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/eu/curia/terminoloski_zapisi.json")
DEFAULT_SEGMENTS_DIR = Path("baza_terminologije/eu/curia/segmenti")
DEFAULT_MANIFEST = Path("baza_terminologije/eu/curia/segmenti_manifest.json")


def _slugify(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    lowered = ascii_text.lower()
    slug = re.sub(r"[^a-z0-9]+", "_", lowered).strip("_")
    if not slug:
        slug = "worksheet"
    return slug


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _group_by_worksheet(records: list[dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
    groups: dict[str, list[dict[str, Any]]] = {}
    for record in records:
        worksheet = record.get("worksheet")
        if not isinstance(worksheet, str) or worksheet.strip() == "":
            worksheet = "(bez_worksheet)"
        groups.setdefault(worksheet, []).append(record)
    return groups


def segment(
    input_path: Path,
    segments_dir: Path,
    manifest_path: Path,
) -> tuple[int, int, list[tuple[str, str, int]], bool]:
    payload = _load_json(input_path)
    records = payload.get("zapisi", [])
    if not isinstance(records, list):
        raise ValueError("Polje 'zapisi' mora biti lista.")

    groups = _group_by_worksheet(records)
    ordered_worksheets = sorted(groups.keys())

    used_filenames: set[str] = set()
    segments: list[tuple[str, str, int]] = []
    total_segmented_records = 0

    for worksheet in ordered_worksheets:
        base_slug = _slugify(worksheet)
        file_name = f"{base_slug}.json"
        suffix = 2
        while file_name in used_filenames:
            file_name = f"{base_slug}_{suffix}.json"
            suffix += 1
        used_filenames.add(file_name)

        segment_records = groups[worksheet]
        total_segmented_records += len(segment_records)

        segment_payload = {
            "izvor": str(input_path.as_posix()),
            "worksheet": worksheet,
            "record_count": len(segment_records),
            "zapisi": segment_records,
        }
        _write_json(segments_dir / file_name, segment_payload)
        segments.append((worksheet, file_name, len(segment_records)))

    expected_total = int(payload.get("ukupno_zapisa", len(records)))
    manifest_payload = {
        "izvor": str(input_path.as_posix()),
        "ukupan_broj_segmenata": len(segments),
        "ukupan_broj_zapisa": total_segmented_records,
        "ocekivan_broj_zapisa": expected_total,
        "zbroj_odgovara_izvoru": total_segmented_records == expected_total,
        "segmenti": [
            {
                "worksheet": worksheet,
                "izlazna_datoteka": file_name,
                "broj_zapisa": count,
            }
            for worksheet, file_name, count in segments
        ],
    }
    _write_json(manifest_path, manifest_payload)

    return len(segments), total_segmented_records, segments, total_segmented_records == expected_total


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Segmentira CURIA terminoloske zapise po worksheetu."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--segments-dir", type=Path, default=DEFAULT_SEGMENTS_DIR)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.input.exists():
        print(f"ERROR: Ulazna datoteka ne postoji: {args.input}")
        return 2

    segments_count, total_records, segments, sums_match = segment(
        input_path=args.input,
        segments_dir=args.segments_dir,
        manifest_path=args.manifest,
    )

    print(f"SEGMENTS_COUNT={segments_count}")
    for worksheet, file_name, count in segments:
        print(f"SEGMENT_RECORDS={worksheet} => {file_name} => {count}")
    print(f"TOTAL_RECORDS={total_records}")
    print(f"MANIFEST_PATH={args.manifest.as_posix()}")
    print(f"SUM_MATCH_SOURCE={'YES' if sums_match else 'NO'}")

    return 0 if sums_match else 4


if __name__ == "__main__":
    sys.exit(main())
