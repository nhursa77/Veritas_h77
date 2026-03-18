from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/prioritetni_uzorak_za_nn_sidrenje.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/"
    "prioritetni_uzorak_za_nn_sidrenje_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi_manifest.json"
)

PROCESS_KEYWORDS = [
    "zalba",
    "prigovor",
    "rok",
    "rjesenje",
    "presuda",
    "postupak",
    "tuzba",
    "dokaz",
    "dostava",
    "nadleznost",
    "izvrsenje",
]

ACT_ACTION_KEYWORDS = [
    "odluka",
    "nalog",
    "zahtjev",
    "ovrha",
    "izvrsenje",
    "dostava",
    "presuda",
    "rjesenje",
    "postupak",
    "tuzba",
    "zalba",
    "prigovor",
    "dokaz",
]

LEGAL_NAME_KEYWORDS = [
    "law",
    "criminal",
    "constitutional",
    "administrative",
    "procedural",
    "civil",
    "family",
    "kaznen",
    "ustavn",
    "upravn",
    "parnic",
    "prekrsaj",
    "pravni",
]

GENERIC_EXACT = {
    "eu",
    "law",
    "no",
    "not validated",
    "term",
    "validated",
    "yes",
    "ad hoc",
}


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm(value: Any) -> str:
    text = "" if value is None else str(value)
    normalized = unicodedata.normalize("NFKD", text.casefold())
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    ascii_text = re.sub(r"\s+", " ", ascii_text).strip()
    return ascii_text


def _is_code_like(candidate: str) -> bool:
    if re.fullmatch(r"[a-z]{2}", candidate):
        return True
    parts = re.split(r"\s*[|/,;:]\s*", candidate)
    if len(parts) > 1 and all(re.fullmatch(r"[a-z]{2}", p) for p in parts if p):
        return True
    return False


def _classify_retain_basis(candidate_norm: str) -> str | None:
    if any(keyword in candidate_norm for keyword in PROCESS_KEYWORDS):
        return "PROCESNI_POJAM"
    if any(keyword in candidate_norm for keyword in ACT_ACTION_KEYWORDS):
        return "AKT_ILI_RADNJA"
    if any(keyword in candidate_norm for keyword in LEGAL_NAME_KEYWORDS):
        return "PRAVNI_NAZIV"
    return None


def clean_sample(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, int, list[tuple[str, int]], list[tuple[str, int]], dict[str, int]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    records = payload.get("prioritetni_zapisi", [])
    if not isinstance(records, list):
        raise ValueError("Polje 'prioritetni_zapisi' mora biti lista.")

    kept: list[dict[str, Any]] = []
    kept_basis_counts = {
        "PRAVNI_NAZIV": 0,
        "PROCESNI_POJAM": 0,
        "AKT_ILI_RADNJA": 0,
    }
    kept_counter: collections.Counter[str] = collections.Counter()
    dropped_counter: collections.Counter[str] = collections.Counter()

    for record in records:
        if not isinstance(record, dict):
            continue

        candidate_raw = str(record.get("predlozeni_nn_pojam", "")).strip()
        candidate_norm = _norm(candidate_raw)

        keep = True
        if len(candidate_norm) < 3:
            keep = False
        elif candidate_norm in GENERIC_EXACT:
            keep = False
        elif _is_code_like(candidate_norm):
            keep = False
        elif not re.search(r"[a-z]", candidate_norm):
            keep = False

        basis = _classify_retain_basis(candidate_norm) if keep else None
        if keep and basis is None:
            keep = False

        if keep:
            enriched = dict(record)
            enriched["status_podobnosti_nn_sidrenja"] = "PODOBAN_ZA_NN_PREGLED"
            enriched["osnova_podobnosti"] = basis
            kept.append(enriched)
            kept_basis_counts[basis] += 1
            kept_counter[candidate_raw] += 1
        else:
            dropped_counter[candidate_raw] += 1

    output_payload = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(records),
        "ukupan_broj_zadrzanih_zapisa": len(kept),
        "ukupan_broj_odbacenih_zapisa": len(records) - len(kept),
        "zapisi": kept,
    }
    _write_json(output_path, output_payload)

    top30_kept = sorted(kept_counter.items(), key=lambda kv: (-kv[1], kv[0]))[:30]
    top30_dropped = sorted(dropped_counter.items(), key=lambda kv: (-kv[1], kv[0]))[:30]

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(records),
        "ukupan_broj_zadrzanih_zapisa": len(kept),
        "ukupan_broj_odbacenih_zapisa": len(records) - len(kept),
        "broj_zadrzanih_po_osnovi_podobnosti": kept_basis_counts,
        "top_30_najcescih_zadrzanih_kandidata": [
            {"kandidat": k, "broj": v} for k, v in top30_kept
        ],
        "top_30_najcescih_odbacenih_kandidata": [
            {"kandidat": k, "broj": v} for k, v in top30_dropped
        ],
        "status_podobnosti_nn_sidrenja": "PODOBAN_ZA_NN_PREGLED",
        "ulazni_segmenti": input_manifest.get("ulazni_segmenti", []),
    }
    _write_json(output_manifest_path, output_manifest)

    return (
        len(records),
        len(kept),
        len(records) - len(kept),
        top30_kept,
        top30_dropped,
        kept_basis_counts,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Cisti prioritetni uzorak na NN-sidrenju podobne pojmove."
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

    total_in, kept, dropped, top_kept, top_dropped, basis_counts = clean_sample(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"TOTAL_INPUT_RECORDS={total_in}")
    print(f"KEPT_RECORDS={kept}")
    print(f"DROPPED_RECORDS={dropped}")
    print(
        "KEPT_BY_BASIS="
        f"PRAVNI_NAZIV:{basis_counts['PRAVNI_NAZIV']},"
        f"PROCESNI_POJAM:{basis_counts['PROCESNI_POJAM']},"
        f"AKT_ILI_RADNJA:{basis_counts['AKT_ILI_RADNJA']}"
    )
    for candidate, count in top_kept:
        print(f"TOP30_KEPT={candidate} => {count}")
    for candidate, count in top_dropped:
        print(f"TOP30_DROPPED={candidate} => {count}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
