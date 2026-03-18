from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/eu/curia/hrvatski_relevantni_termini.json")
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/eu/curia/hrvatski_relevantni_termini_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi_manifest.json"
)

IGNORE_TOKENS = {
    "hr",
    "term",
    "validated",
    "yes",
    "systematic",
    "jurisprudence",
    "concept",
    "recommended",
    "to be validated",
    "",
}


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm_text(value: str) -> str:
    lowered = value.casefold().strip()
    normalized = unicodedata.normalize("NFKD", lowered)
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    ascii_text = re.sub(r"\s+", " ", ascii_text).strip()
    return re.sub(r"[^a-z0-9 ]+", "", ascii_text)


def _is_potential_term(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    text = value.strip()
    if not text:
        return False
    if text.casefold() in IGNORE_TOKENS:
        return False
    if text.isdigit():
        return False
    if len(text) < 2:
        return False
    if not re.search(r"[a-zA-ZČĆŽŠĐčćžšđ]", text):
        return False
    return True


def _extract_candidates(record: dict[str, Any]) -> list[str]:
    candidates: list[str] = []

    source_term = record.get("pojam_izvornik")
    if _is_potential_term(source_term):
        candidates.append(str(source_term).strip())

    equivalents = record.get("ekvivalenti")
    if isinstance(equivalents, list):
        for value in equivalents:
            if _is_potential_term(value):
                candidate = str(value).strip()
                if candidate not in candidates:
                    candidates.append(candidate)

    return candidates


def _map_basis_and_confidence(curia_term: str | None, candidate: str) -> tuple[str, str]:
    source = curia_term or ""
    if source and source.strip() == candidate:
        return "TEKSTUALNO_PODUDARANJE", "SREDNJA"

    if source and _norm_text(source) == _norm_text(candidate):
        return "NORMALIZIRANO_PODUDARANJE_NAZIVA", "SREDNJA"

    return "OCITA_JEZICNA_BLISKOST", "NISKA"


def build_mapping(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], int]:
    source_payload = _load_json(input_path)
    source_manifest = _load_json(input_manifest_path)

    records = source_payload.get("zapisi", [])
    if not isinstance(records, list):
        raise ValueError("Polje 'zapisi' u ulazu mora biti lista.")

    mapped: list[dict[str, Any]] = []
    by_confidence = {"NISKA": 0, "SREDNJA": 0}
    manual_review_count = 0

    for record in records:
        if not isinstance(record, dict):
            continue

        candidates = _extract_candidates(record)
        if not candidates:
            continue

        curia_term = record.get("pojam_izvornik")
        for candidate in candidates:
            basis, confidence = _map_basis_and_confidence(
                str(curia_term) if curia_term is not None else None,
                candidate,
            )
            mapped_record = {
                "curia_oznaka_zapisa": record.get("oznaka_zapisa"),
                "curia_pojam_izvornik": record.get("pojam_izvornik"),
                "curia_ekvivalenti": record.get("ekvivalenti"),
                "predlozeni_nn_pojam": candidate,
                "osnova_mapiranja": basis,
                "razina_pouzdanosti": confidence,
                "zahtijeva_rucnu_provjeru": True,
                "status_mapiranja": "PREDLOZENO_BEZ_NN_SIDRA",
            }
            mapped.append(mapped_record)
            by_confidence[confidence] += 1
            manual_review_count += 1

    output_payload = {
        "izvor_hrvatski_relevantni_termini": str(input_path.as_posix()),
        "ukupan_broj_obradenih_termina": len(records),
        "ukupan_broj_predlozenih_mapiranja": len(mapped),
        "mapiranja": mapped,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_obradenih_termina": len(records),
        "ukupan_broj_predlozenih_mapiranja": len(mapped),
        "broj_mapiranja_po_razini_pouzdanosti": by_confidence,
        "broj_zapisa_oznacenih_za_rucnu_provjeru": manual_review_count,
        "status_mapiranja": "PREDLOZENO_BEZ_NN_SIDRA",
        "zahtijeva_rucnu_provjeru": True,
        "osnove_mapiranja": sorted(
            set(item["osnova_mapiranja"] for item in mapped)
        ),
        "ulazni_segmenti": source_manifest.get("nazivi_ulaznih_segmenata", []),
    }
    _write_json(output_manifest_path, output_manifest)

    return len(records), len(mapped), by_confidence, manual_review_count


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Mapira CURIA hrvatski relevantne termine na potencijalne NN pojmove."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.input.exists():
        print(f"ERROR: Nedostaje ulazna datoteka: {args.input}")
        return 2
    if not args.input_manifest.exists():
        print(f"ERROR: Nedostaje ulazni manifest: {args.input_manifest}")
        return 3

    processed, proposed, by_confidence, manual_review = build_mapping(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"PROCESSED_TERMS={processed}")
    print(f"PROPOSED_MAPPINGS={proposed}")
    print(f"CONFIDENCE_NISKA={by_confidence.get('NISKA', 0)}")
    print(f"CONFIDENCE_SREDNJA={by_confidence.get('SREDNJA', 0)}")
    print(f"MANUAL_REVIEW_COUNT={manual_review}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
