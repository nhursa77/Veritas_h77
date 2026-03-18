from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/"
    "curia_prema_nn_potencijalni_pojmovi_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/"
    "prioritetni_uzorak_za_nn_sidrenje.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/"
    "prioritetni_uzorak_za_nn_sidrenje_manifest.json"
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


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm_text(value: Any) -> str:
    text = "" if value is None else str(value)
    normalized = unicodedata.normalize("NFKD", text.casefold())
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    ascii_text = re.sub(r"\s+", " ", ascii_text).strip()
    return re.sub(r"[^a-z0-9 ]+", "", ascii_text)


def _contains_process_keyword(mapping: dict[str, Any]) -> bool:
    fields: list[str] = []
    fields.append(_norm_text(mapping.get("predlozeni_nn_pojam")))
    fields.append(_norm_text(mapping.get("curia_pojam_izvornik")))

    equivalents = mapping.get("curia_ekvivalenti")
    if isinstance(equivalents, list):
        for item in equivalents:
            fields.append(_norm_text(item))

    haystack = " ".join(field for field in fields if field)
    if not haystack:
        return False

    for keyword in PROCESS_KEYWORDS:
        if keyword in haystack:
            return True
    return False


def _determine_priority_reason(
    mapping: dict[str, Any],
    freq_by_candidate: collections.Counter[str],
) -> str | None:
    candidate = str(mapping.get("predlozeni_nn_pojam", ""))

    if mapping.get("razina_pouzdanosti") == "SREDNJA":
        return "POUZDANOST_SREDNJA"
    if freq_by_candidate.get(candidate, 0) > 1:
        return "UCESTALI_KANDIDAT"
    if _contains_process_keyword(mapping):
        return "PROCESNI_NAZIV"
    return None


def _sorting_key(mapping: dict[str, Any]) -> tuple[str, str, str, str]:
    return (
        str(mapping.get("osnova_prioriteta", "")),
        str(mapping.get("predlozeni_nn_pojam", "")),
        str(mapping.get("curia_oznaka_zapisa", "")),
        str(mapping.get("osnova_mapiranja", "")),
    )


def build_priority_sample(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], list[dict[str, Any]]]:
    payload = _load_json(input_path)
    manifest_in = _load_json(input_manifest_path)

    mappings = payload.get("mapiranja", [])
    if not isinstance(mappings, list):
        raise ValueError("Polje 'mapiranja' mora biti lista.")

    freq_by_candidate: collections.Counter[str] = collections.Counter()
    for item in mappings:
        if not isinstance(item, dict):
            continue
        candidate = str(item.get("predlozeni_nn_pojam", ""))
        freq_by_candidate[candidate] += 1

    selected: list[dict[str, Any]] = []
    reason_counts = {
        "POUZDANOST_SREDNJA": 0,
        "UCESTALI_KANDIDAT": 0,
        "PROCESNI_NAZIV": 0,
    }

    for item in mappings:
        if not isinstance(item, dict):
            continue
        reason = _determine_priority_reason(item, freq_by_candidate)
        if reason is None:
            continue

        enriched = dict(item)
        enriched["osnova_prioriteta"] = reason
        selected.append(enriched)
        reason_counts[reason] += 1

    selected.sort(key=_sorting_key)
    for index, item in enumerate(selected, start=1):
        item["redoslijed_prioriteta"] = index

    top20 = [
        {"kandidat": candidate, "broj": count}
        for candidate, count in sorted(
            freq_by_candidate.items(), key=lambda kv: (-kv[1], kv[0])
        )[:20]
    ]

    output_payload = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(mappings),
        "ukupan_broj_izdvojenih_prioritetnih_zapisa": len(selected),
        "prioritetni_zapisi": selected,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(mappings),
        "ukupan_broj_izdvojenih_prioritetnih_zapisa": len(selected),
        "broj_izdvojenih_po_osnovi_prioriteta": reason_counts,
        "broj_jedinstvenih_predlozeni_nn_pojam": len(freq_by_candidate),
        "top_20_najcescih_kandidata": top20,
        "ulazni_segmenti": manifest_in.get("ulazni_segmenti", []),
    }
    _write_json(output_manifest_path, output_manifest)

    return len(mappings), len(selected), reason_counts, top20


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Izdvaja prioritetni uzorak kandidata za NN sidrenje."
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

    total_in, total_out, reason_counts, top20 = build_priority_sample(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"TOTAL_INPUT_RECORDS={total_in}")
    print(f"TOTAL_PRIORITY_RECORDS={total_out}")
    print(
        "PRIORITY_BY_REASON="
        f"POUZDANOST_SREDNJA:{reason_counts['POUZDANOST_SREDNJA']},"
        f"UCESTALI_KANDIDAT:{reason_counts['UCESTALI_KANDIDAT']},"
        f"PROCESNI_NAZIV:{reason_counts['PROCESNI_NAZIV']}"
    )
    for item in top20:
        print(f"TOP20={item['kandidat']} => {item['broj']}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
