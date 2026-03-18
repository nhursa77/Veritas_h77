from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

DEFAULT_SEGMENTS_DIR = Path("baza_terminologije/eu/curia/segmenti")
DEFAULT_SEGMENTS_MANIFEST = Path("baza_terminologije/eu/curia/segmenti_manifest.json")
DEFAULT_OUTPUT = Path("baza_terminologije/eu/curia/hrvatski_relevantni_termini.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/eu/curia/hrvatski_relevantni_termini_manifest.json"
)

HR_CODE_PATTERN = re.compile(r"(^|[^a-z0-9])hr([^a-z0-9]|$)", re.IGNORECASE)
HR_WORD_PATTERNS = [
    re.compile(r"croatian", re.IGNORECASE),
    re.compile(r"hrvatsk", re.IGNORECASE),
    re.compile(r"croate", re.IGNORECASE),
    re.compile(r"croato", re.IGNORECASE),
    re.compile(r"kroatisch", re.IGNORECASE),
    re.compile(r"kroatisk", re.IGNORECASE),
]


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _to_text(value: Any) -> str:
    if value is None:
        return ""
    return str(value)


def _has_hr_code(text: str) -> bool:
    return bool(HR_CODE_PATTERN.search(text))


def _has_hr_word(text: str) -> bool:
    return any(pattern.search(text) for pattern in HR_WORD_PATTERNS)


def _find_hr_relevance(record: dict[str, Any]) -> str | None:
    language_text = _to_text(record.get("jezik_izvornika")).strip()
    if language_text:
        if _has_hr_code(language_text):
            return "JEZIK_HR"
        if _has_hr_word(language_text):
            return "JEZIK_HR"

    original_term = _to_text(record.get("pojam_izvornik"))
    if original_term and _has_hr_word(original_term):
        return "POLJE_SADRZI_CROATIAN"
    if original_term and _has_hr_code(original_term):
        return "POLJE_SADRZI_CROATIAN"

    equivalents = record.get("ekvivalenti", [])
    if isinstance(equivalents, list):
        for value in equivalents:
            text = _to_text(value).strip()
            if not text:
                continue
            if _has_hr_word(text):
                return "EKVIVALENT_HR"
            if text.lower() == "hr":
                return "EKVIVALENT_HR"
            if _has_hr_code(text):
                return "EKVIVALENT_HR"

    return None


def extract_hr_relevant(
    segments_dir: Path,
    segments_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], list[str]]:
    segments_manifest = _load_json(segments_manifest_path)
    segment_entries = segments_manifest.get("segmenti", [])
    if not isinstance(segment_entries, list):
        raise ValueError("Polje 'segmenti' mora biti lista u segmenti_manifest.json")

    extracted_records: list[dict[str, Any]] = []
    per_segment_counts: dict[str, int] = {}
    used_reasons: dict[str, int] = {}
    total_reviewed = 0
    input_segments: list[str] = []

    for segment in segment_entries:
        segment_file = segment.get("izlazna_datoteka")
        worksheet = segment.get("worksheet")
        if not isinstance(segment_file, str):
            continue

        input_segments.append(segment_file)
        segment_path = segments_dir / segment_file
        segment_payload = _load_json(segment_path)
        records = segment_payload.get("zapisi", [])
        if not isinstance(records, list):
            continue

        segment_count = 0
        for record in records:
            if not isinstance(record, dict):
                continue
            total_reviewed += 1
            reason = _find_hr_relevance(record)
            if reason is None:
                continue

            extracted = dict(record)
            extracted["osnova_hrvatske_relevantnosti"] = reason
            extracted_records.append(extracted)
            segment_count += 1
            used_reasons[reason] = used_reasons.get(reason, 0) + 1

        segment_key = str(worksheet) if isinstance(worksheet, str) else segment_file
        per_segment_counts[segment_key] = segment_count

    output_payload = {
        "izvor_segmenti_manifest": str(segments_manifest_path.as_posix()),
        "ukupan_broj_pregledanih_zapisa": total_reviewed,
        "ukupan_broj_izdvojenih_zapisa": len(extracted_records),
        "zapisi": extracted_records,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazni_segmenti_manifest": str(segments_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_pregledanih_zapisa": total_reviewed,
        "ukupan_broj_izdvojenih_zapisa": len(extracted_records),
        "broj_izdvojenih_po_segmentu": per_segment_counts,
        "osnove_hrvatske_relevantnosti": sorted(used_reasons.keys()),
        "broj_po_osnovi": used_reasons,
        "nazivi_ulaznih_segmenata": input_segments,
    }
    _write_json(output_manifest_path, output_manifest)

    return total_reviewed, len(extracted_records), per_segment_counts, sorted(used_reasons.keys())


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Izdvaja hrvatski relevantne CURIA terminoloske zapise."
    )
    parser.add_argument("--segments-dir", type=Path, default=DEFAULT_SEGMENTS_DIR)
    parser.add_argument("--segments-manifest", type=Path, default=DEFAULT_SEGMENTS_MANIFEST)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.segments_manifest.exists():
        print(f"ERROR: Nedostaje segmenti manifest: {args.segments_manifest}")
        return 2
    if not args.segments_dir.exists():
        print(f"ERROR: Nedostaje mapa segmenata: {args.segments_dir}")
        return 3

    total_reviewed, total_extracted, per_segment, reasons = extract_hr_relevant(
        segments_dir=args.segments_dir,
        segments_manifest_path=args.segments_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"TOTAL_REVIEWED_RECORDS={total_reviewed}")
    print(f"TOTAL_EXTRACTED_RECORDS={total_extracted}")
    for segment_name in sorted(per_segment.keys()):
        print(f"EXTRACTED_BY_SEGMENT={segment_name} => {per_segment[segment_name]}")
    print(f"HR_RELEVANCE_BASES={','.join(reasons)}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
