from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT_PILOT = Path("baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json")
DEFAULT_INPUT_PILOT_MANIFEST = Path(
    "baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json"
)
DEFAULT_INPUT_CORE = Path("baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json")
DEFAULT_INPUT_CORE_MANIFEST = Path(
    "baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje_manifest.json"
)

# Kontekstni markeri upućuju na uske/složene fraze koje ne ulaze u osnovni skup.
CONTEXT_MARKERS = {
    " kojim ",
    " koja ",
    " koje ",
    " kojeg ",
    " kojom ",
    " radi ",
    " zbog ",
    " medu ",
    " protiv ",
    " po ",
    " na ",
    " u ",
    " za ",
    " o ",
}

GENERAL_EXTENSION_KEYWORDS = {
    "postupak": "OPCI_POSTUPOVNI_POJAM",
    "nadleznost": "TEMELJNI_STATUS_POSTUPKA",
    "pravomocnost": "TEMELJNI_STATUS_POSTUPKA",
    "izvrsnost": "TEMELJNI_STATUS_POSTUPKA",
    "rok": "OPCI_POSTUPOVNI_POJAM",
    "tuzba": "TEMELJNI_AKT_ILI_RADNJA",
    "zahtjev": "TEMELJNI_AKT_ILI_RADNJA",
    "stranka": "OPCI_POSTUPOVNI_POJAM",
    "punomoc": "OPCI_POSTUPOVNI_POJAM",
    "pristojba": "TEMELJNI_AKT_ILI_RADNJA",
    "trosak": "TEMELJNI_AKT_ILI_RADNJA",
    "okrivljenik": "TEMELJNI_STATUS_POSTUPKA",
}

ALLOWED_GENERAL_MULTIWORD = {
    "apsolutna nenadleznost",
    "glavni postupak",
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


def _is_complex_context(name_norm: str) -> bool:
    padded = f" {name_norm} "
    if any(marker in padded for marker in CONTEXT_MARKERS):
        return True

    tokens = [t for t in name_norm.split(" ") if t]
    if len(tokens) >= 3 and name_norm not in ALLOWED_GENERAL_MULTIWORD:
        return True

    # Fraze koje počinju od jezgrenog pojma, a imaju dodatni kontekst,
    # tretiraju se kao izvedeni oblici i ne ulaze u osnovni skup.
    if len(tokens) > 1 and tokens[0] in {
        "dostava",
        "dokaz",
        "prigovor",
        "rjesenje",
        "presuda",
        "zalba",
    }:
        return True

    return False


def _pick_extension_basis(name_norm: str) -> str | None:
    for keyword, basis in GENERAL_EXTENSION_KEYWORDS.items():
        if keyword in name_norm:
            return basis
    return None


def build_basic_procedural_set(
    pilot_path: Path,
    pilot_manifest_path: Path,
    core_path: Path,
    core_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, collections.Counter[str], list[str], list[str], int, int]:
    pilot_payload = _load_json(pilot_path)
    pilot_manifest = _load_json(pilot_manifest_path)
    core_payload = _load_json(core_path)
    core_manifest = _load_json(core_manifest_path)

    pilot_entries = pilot_payload.get("pilot_natuknice", [])
    core_entries = core_payload.get("jezgrene_natuknice", [])

    if not isinstance(pilot_entries, list):
        raise ValueError("Polje 'pilot_natuknice' mora biti lista.")
    if not isinstance(core_entries, list):
        raise ValueError("Polje 'jezgrene_natuknice' mora biti lista.")

    core_by_id: dict[str, dict[str, Any]] = {}
    for entry in core_entries:
        if not isinstance(entry, dict):
            continue
        pojam_id = str(entry.get("pojam_id", "")).strip()
        if not pojam_id:
            continue
        core_by_id[pojam_id] = entry

    ordered_selected: list[dict[str, Any]] = []
    added_by_extension: list[str] = []
    taken_from_core: list[str] = []

    for pilot_entry in pilot_entries:
        if not isinstance(pilot_entry, dict):
            continue
        pojam_id = str(pilot_entry.get("pojam_id", "")).strip()
        if pojam_id and pojam_id in core_by_id:
            base = dict(core_by_id[pojam_id])
            base["osnovni_postupovni_skup"] = True
            base["osnova_ulaska_u_osnovni_skup"] = "PREUZETO_IZ_JEZGRE"
            ordered_selected.append(base)
            taken_from_core.append(str(base.get("kanonski_naziv", "")).strip())

    selected_ids = {
        str(entry.get("pojam_id", "")).strip()
        for entry in ordered_selected
        if str(entry.get("pojam_id", "")).strip()
    }

    for pilot_entry in pilot_entries:
        if not isinstance(pilot_entry, dict):
            continue

        pojam_id = str(pilot_entry.get("pojam_id", "")).strip()
        if not pojam_id or pojam_id in selected_ids:
            continue

        name = str(pilot_entry.get("kanonski_naziv", "")).strip()
        if not name:
            continue
        name_norm = _norm(name)

        if _is_complex_context(name_norm):
            continue

        basis = _pick_extension_basis(name_norm)
        if basis is None:
            continue

        extended = dict(pilot_entry)
        extended["osnovni_postupovni_skup"] = True
        extended["osnova_ulaska_u_osnovni_skup"] = basis
        ordered_selected.append(extended)
        selected_ids.add(pojam_id)
        added_by_extension.append(name)

    for idx, entry in enumerate(ordered_selected, start=1):
        entry["redoslijed_osnovnog_skupa"] = idx

    names = [str(entry.get("kanonski_naziv", "")).strip() for entry in ordered_selected]
    by_basis: collections.Counter[str] = collections.Counter(
        str(entry.get("osnova_ulaska_u_osnovni_skup", "")).strip()
        for entry in ordered_selected
    )

    empty_nn_sidra = 0
    status_ceka = 0
    for entry in ordered_selected:
        nn_sidra = entry.get("nn_sidra", {})
        if isinstance(nn_sidra, dict) and len(nn_sidra) == 0:
            empty_nn_sidra += 1
        elif nn_sidra in (None, [], ""):
            empty_nn_sidra += 1

        if str(entry.get("status_validacije", "")).strip() == "CEKA_NN_SIDRO":
            status_ceka += 1

    output_payload = {
        "ulazna_datoteka_pilot": str(pilot_path.as_posix()),
        "ulazni_pilot_manifest": str(pilot_manifest_path.as_posix()),
        "ulazna_datoteka_jezgra": str(core_path.as_posix()),
        "ulazni_jezgra_manifest": str(core_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_pilot_natuknica": len(pilot_entries),
        "ukupan_broj_natuknica_u_osnovnom_postupovnom_skupu": len(ordered_selected),
        "natuknice": ordered_selected,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazna_datoteka_pilot": str(pilot_path.as_posix()),
        "ulazni_pilot_manifest": str(pilot_manifest_path.as_posix()),
        "ulazna_datoteka_jezgra": str(core_path.as_posix()),
        "ulazni_jezgra_manifest": str(core_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_pilot_natuknica": len(pilot_entries),
        "ukupan_broj_natuknica_u_osnovnom_postupovnom_skupu": len(ordered_selected),
        "broj_po_osnova_ulaska_u_osnovni_skup": dict(sorted(by_basis.items())),
        "popis_kanonski_naziv": names,
        "preuzete_iz_jezgre": taken_from_core,
        "dodane_prosirenjem": added_by_extension,
        "broj_s_praznim_nn_sidra": empty_nn_sidra,
        "broj_sa_status_validacije_CEKA_NN_SIDRO": status_ceka,
        "ulazni_broj_po_osnova_ulaska_u_pilot": pilot_manifest.get(
            "broj_po_osnova_ulaska_u_pilot", {}
        ),
        "ulazni_broj_po_osnova_jezgrenosti": core_manifest.get(
            "broj_po_osnova_jezgrenosti", {}
        ),
    }
    _write_json(output_manifest_path, output_manifest)

    return (
        len(pilot_entries),
        len(ordered_selected),
        by_basis,
        names,
        added_by_extension,
        empty_nn_sidra,
        status_ceka,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Proširuje jezgrene natuknice na osnovni postupovni skup."
    )
    parser.add_argument("--pilot-input", type=Path, default=DEFAULT_INPUT_PILOT)
    parser.add_argument(
        "--pilot-input-manifest", type=Path, default=DEFAULT_INPUT_PILOT_MANIFEST
    )
    parser.add_argument("--core-input", type=Path, default=DEFAULT_INPUT_CORE)
    parser.add_argument(
        "--core-input-manifest", type=Path, default=DEFAULT_INPUT_CORE_MANIFEST
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.pilot_input.exists():
        print(f"ERROR: Nedostaje ulazna pilot datoteka: {args.pilot_input}")
        return 2
    if not args.pilot_input_manifest.exists():
        print(f"ERROR: Nedostaje ulazni pilot manifest: {args.pilot_input_manifest}")
        return 3
    if not args.core_input.exists():
        print(f"ERROR: Nedostaje ulazna jezgrena datoteka: {args.core_input}")
        return 4
    if not args.core_input_manifest.exists():
        print(f"ERROR: Nedostaje ulazni jezgreni manifest: {args.core_input_manifest}")
        return 5

    (
        total_pilot,
        total_basic,
        by_basis,
        names,
        added,
        empty_nn_sidra,
        status_ceka,
    ) = build_basic_procedural_set(
        pilot_path=args.pilot_input,
        pilot_manifest_path=args.pilot_input_manifest,
        core_path=args.core_input,
        core_manifest_path=args.core_input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"TOTAL_PILOT_ENTRIES={total_pilot}")
    print(f"TOTAL_BASIC_SET_ENTRIES={total_basic}")
    for basis, count in sorted(by_basis.items()):
        print(f"BASIC_BY_BASIS={basis}:{count}")
    for name in names:
        print(f"BASIC_KANONSKI_NAZIV={name}")
    for name in added:
        print(f"BASIC_ADDED_BY_EXTENSION={name}")
    print(f"BASIC_EMPTY_NN_SIDRA={empty_nn_sidra}")
    print(f"BASIC_STATUS_CEKA_NN_SIDRO={status_ceka}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
