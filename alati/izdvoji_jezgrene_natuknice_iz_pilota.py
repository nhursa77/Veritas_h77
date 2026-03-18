from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json")
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json"
)

JEZGRENI_NAZIVI = {
    "zalba",
    "prigovor",
    "rjesenje",
    "presuda",
    "dokaz",
    "dostava",
    "izvrsenje",
    "postupak",
    "nadleznost",
    "stranka",
    "punomoc",
    "zapisnik",
    "rok",
    "pristojba",
    "trosak postupka",
    "pravomocnost",
    "izvrsnost",
    "okrivljenik",
    "tuzba",
    "zahtjev",
}

OSNOVA_MAP = {
    "PROCESNO_CENTRALAN_POJAM": "OSNOVNI_PROCESNI_POJAM",
    "TEMELJNI_AKT": "OSNOVNI_PRAVNI_AKT",
    "TEMELJNA_PRAVNA_RADNJA": "OSNOVNA_PRAVNA_RADNJA",
    "TEMELJNI_STATUS_ILI_SVOJSTVO": "OSNOVNI_STATUS_ILI_SVOJSTVO",
    "POSTUPOVNI_OKVIR": "OSNOVNI_POSTUPOVNI_OKVIR",
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


def _derive_osnova_jezgrenosti(entry: dict[str, Any]) -> str:
    pilot_basis = str(entry.get("osnova_ulaska_u_pilot", "")).strip()
    mapped = OSNOVA_MAP.get(pilot_basis)
    if mapped is not None:
        return mapped

    naziv = _norm(entry.get("kanonski_naziv", ""))
    if any(k in naziv for k in ["presuda", "rjesenje", "odluka"]):
        return "OSNOVNI_PRAVNI_AKT"
    if any(k in naziv for k in ["tuzba", "zahtjev", "izvrsenje"]):
        return "OSNOVNA_PRAVNA_RADNJA"
    if any(k in naziv for k in ["nadleznost", "pravomocnost", "izvrsnost"]):
        return "OSNOVNI_STATUS_ILI_SVOJSTVO"
    if "postupak" in naziv:
        return "OSNOVNI_POSTUPOVNI_OKVIR"
    return "OSNOVNI_PROCESNI_POJAM"


def extract_core_entries(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, collections.Counter[str], list[str], list[str], int, int]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    entries = payload.get("pilot_natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'pilot_natuknice' mora biti lista.")

    core_entries: list[dict[str, Any]] = []
    dropped_complex_names: list[str] = []
    by_osnova: collections.Counter[str] = collections.Counter()

    for entry in entries:
        if not isinstance(entry, dict):
            continue

        name = str(entry.get("kanonski_naziv", "")).strip()
        if not name:
            continue

        normalized_name = _norm(name)
        if normalized_name not in JEZGRENI_NAZIVI:
            dropped_complex_names.append(name)
            continue

        osnova_jezgrenosti = _derive_osnova_jezgrenosti(entry)
        enriched = dict(entry)
        enriched["jezgrena_natuknica"] = True
        enriched["osnova_jezgrenosti"] = osnova_jezgrenosti
        core_entries.append(enriched)
        by_osnova[osnova_jezgrenosti] += 1

    for index, entry in enumerate(core_entries, start=1):
        entry["redoslijed_jezgrenog_skupa"] = index

    core_names = [str(entry.get("kanonski_naziv", "")).strip() for entry in core_entries]

    empty_nn_sidra = 0
    status_ceka = 0
    for entry in core_entries:
        nn_sidra = entry.get("nn_sidra", {})
        if isinstance(nn_sidra, dict) and len(nn_sidra) == 0:
            empty_nn_sidra += 1
        elif nn_sidra in (None, [], ""):
            empty_nn_sidra += 1

        if str(entry.get("status_validacije", "")).strip() == "CEKA_NN_SIDRO":
            status_ceka += 1

    output_payload = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_pilot_natuknica": len(entries),
        "ukupan_broj_izdvojenih_jezgrenih_natuknica": len(core_entries),
        "jezgrene_natuknice": core_entries,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_pilot_natuknica": len(entries),
        "ukupan_broj_izdvojenih_jezgrenih_natuknica": len(core_entries),
        "broj_po_osnova_jezgrenosti": dict(sorted(by_osnova.items())),
        "popis_jezgrenih_kanonski_naziv": core_names,
        "popis_odbacenih_slozenih_natuknica": sorted(
            dropped_complex_names, key=lambda x: _norm(x)
        ),
        "broj_natuknica_s_praznim_nn_sidra": empty_nn_sidra,
        "broj_natuknica_status_validacije_CEKA_NN_SIDRO": status_ceka,
        "ulazni_broj_po_osnova_ulaska_u_pilot": input_manifest.get(
            "broj_po_osnova_ulaska_u_pilot", {}
        ),
    }
    _write_json(output_manifest_path, output_manifest)

    return (
        len(entries),
        len(core_entries),
        by_osnova,
        core_names,
        sorted(dropped_complex_names, key=lambda x: _norm(x)),
        empty_nn_sidra,
        status_ceka,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Izdvaja jezgrene rječničke natuknice iz pilot-skupa."
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

    (
        total_in,
        total_core,
        by_osnova,
        core_names,
        dropped_complex,
        empty_nn_sidra,
        status_ceka,
    ) = extract_core_entries(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"INPUT_PILOT_ENTRIES={total_in}")
    print(f"CORE_ENTRIES={total_core}")
    for osnova, count in sorted(by_osnova.items()):
        print(f"CORE_BY_OSNOVA={osnova}:{count}")
    for name in core_names:
        print(f"CORE_KANONSKI_NAZIV={name}")
    for name in dropped_complex:
        print(f"DROPPED_COMPLEX={name}")
    print(f"CORE_EMPTY_NN_SIDRA={empty_nn_sidra}")
    print(f"CORE_STATUS_CEKA_NN_SIDRO={status_ceka}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
