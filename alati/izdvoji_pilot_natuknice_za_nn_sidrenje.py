from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice.json")
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice_manifest.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json"
)

PILOT_TARGET_MIN = 20
PILOT_TARGET_MAX = 30

OSNOVA_ORDER = [
    "PROCESNO_CENTRALAN_POJAM",
    "TEMELJNI_AKT",
    "TEMELJNA_PRAVNA_RADNJA",
    "TEMELJNI_STATUS_ILI_SVOJSTVO",
    "POSTUPOVNI_OKVIR",
]

KEYWORDS = {
    "PROCESNO_CENTRALAN_POJAM": [
        "zalba",
        "prigovor",
        "rok",
        "dostava",
        "dokaz",
        "zapisnik",
        "punomoc",
        "stranka",
        "okrivljenik",
    ],
    "TEMELJNI_AKT": [
        "rjesenje",
        "presuda",
        "odluka",
    ],
    "TEMELJNA_PRAVNA_RADNJA": [
        "tuzba",
        "zahtjev",
        "izvrsenje",
    ],
    "TEMELJNI_STATUS_ILI_SVOJSTVO": [
        "nadleznost",
        "pravomocnost",
        "izvrsnost",
    ],
    "POSTUPOVNI_OKVIR": [
        "postupak",
        "procedure",
        "proceedings",
    ],
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


def _match_osnova(kanonski_naziv: str, vrsta_pojma: str) -> tuple[str | None, list[str]]:
    naziv_norm = _norm(kanonski_naziv)
    vrsta = (vrsta_pojma or "").strip()

    matched: dict[str, list[str]] = {key: [] for key in OSNOVA_ORDER}
    for osnova in OSNOVA_ORDER:
        for keyword in KEYWORDS[osnova]:
            if keyword in naziv_norm:
                matched[osnova].append(keyword)

    if matched["TEMELJNI_AKT"]:
        return "TEMELJNI_AKT", matched["TEMELJNI_AKT"]
    if vrsta == "PRAVNI_AKT":
        return "TEMELJNI_AKT", ["vrsta_pojma=PRAVNI_AKT"]

    if matched["TEMELJNA_PRAVNA_RADNJA"]:
        return "TEMELJNA_PRAVNA_RADNJA", matched["TEMELJNA_PRAVNA_RADNJA"]
    if vrsta == "PRAVNA_RADNJA":
        return "TEMELJNA_PRAVNA_RADNJA", ["vrsta_pojma=PRAVNA_RADNJA"]

    if matched["TEMELJNI_STATUS_ILI_SVOJSTVO"]:
        return "TEMELJNI_STATUS_ILI_SVOJSTVO", matched[
            "TEMELJNI_STATUS_ILI_SVOJSTVO"
        ]
    if vrsta == "STATUS_ILI_SVOJSTVO":
        return "TEMELJNI_STATUS_ILI_SVOJSTVO", ["vrsta_pojma=STATUS_ILI_SVOJSTVO"]

    if matched["POSTUPOVNI_OKVIR"]:
        return "POSTUPOVNI_OKVIR", matched["POSTUPOVNI_OKVIR"]

    if matched["PROCESNO_CENTRALAN_POJAM"]:
        return "PROCESNO_CENTRALAN_POJAM", matched["PROCESNO_CENTRALAN_POJAM"]

    return None, []


def _pilot_score(kanonski_naziv: str, vrsta_pojma: str, matched_keywords: list[str]) -> int:
    naziv_norm = _norm(kanonski_naziv)
    vrsta = (vrsta_pojma or "").strip()

    score = 0
    for keyword in matched_keywords:
        if keyword.startswith("vrsta_pojma="):
            continue
        score += 10
        if naziv_norm == keyword:
            score += 8

    if vrsta == "PROCESNI_POJAM":
        score += 5
    elif vrsta in {"PRAVNA_RADNJA", "PRAVNI_AKT"}:
        score += 4
    elif vrsta in {"STATUS_ILI_SVOJSTVO", "TIJELO_ILI_NADLEZNOST"}:
        score += 2

    # Stabilna prednost pojmova koji točno pogađaju tražene procesne okidače.
    for exact in [
        "zalba",
        "prigovor",
        "rjesenje",
        "presuda",
        "tuzba",
        "zahtjev",
        "rok",
        "dostava",
        "dokaz",
        "nadleznost",
        "zapisnik",
        "punomoc",
        "stranka",
        "okrivljenik",
        "trosak postupka",
        "pristojba",
        "izvrsenje",
        "pravomocnost",
        "izvrsnost",
        "postupak",
    ]:
        if exact in naziv_norm:
            score += 3

    return score


def extract_pilot_entries(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, collections.Counter[str], collections.Counter[str], int, int, list[str]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    entries = payload.get("natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    candidates: list[tuple[int, str, dict[str, Any], str, str]] = []

    for entry in entries:
        if not isinstance(entry, dict):
            continue

        name = str(entry.get("kanonski_naziv", "")).strip()
        vrsta = str(entry.get("vrsta_pojma", "")).strip()
        if not name:
            continue

        osnova, matched = _match_osnova(name, vrsta)
        if osnova is None:
            continue

        score = _pilot_score(name, vrsta, matched)
        reason = (
            f"osnova={osnova}; kriterij={'/'.join(matched) if matched else 'vrsta_pojma'}"
        )
        candidates.append((score, _norm(name), entry, osnova, reason))

    candidates.sort(key=lambda item: (-item[0], item[1], str(item[2].get("pojam_id", ""))))

    selected = candidates[:PILOT_TARGET_MAX]

    pilot_entries: list[dict[str, Any]] = []
    by_vrsta: collections.Counter[str] = collections.Counter()
    by_osnova: collections.Counter[str] = collections.Counter()
    empty_nn_sidra = 0
    status_ceka = 0

    for idx, (_, _, entry, osnova, reason) in enumerate(selected, start=1):
        enriched = dict(entry)
        enriched["pilot_skup"] = True
        enriched["osnova_ulaska_u_pilot"] = osnova
        enriched["redoslijed_pilota"] = idx
        enriched["osnova_ulaska_u_pilot_opis"] = reason

        pilot_entries.append(enriched)
        by_vrsta[str(enriched.get("vrsta_pojma", "NEKLASIFICIRANO"))] += 1
        by_osnova[osnova] += 1

        nn_sidra = enriched.get("nn_sidra", {})
        if isinstance(nn_sidra, dict) and len(nn_sidra) == 0:
            empty_nn_sidra += 1
        elif nn_sidra in (None, [], ""):
            empty_nn_sidra += 1

        if str(enriched.get("status_validacije", "")).strip() == "CEKA_NN_SIDRO":
            status_ceka += 1

    pilot_names = [str(item.get("kanonski_naziv", "")).strip() for item in pilot_entries]

    output_payload = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_natuknica": len(entries),
        "ukupan_broj_izdvojenih_pilot_natuknica": len(pilot_entries),
        "pilot_natuknice": pilot_entries,
    }
    _write_json(output_path, output_payload)

    in_target = PILOT_TARGET_MIN <= len(pilot_entries) <= PILOT_TARGET_MAX
    note = ""
    if not in_target:
        note = (
            "Broj pilot-natuknica je izvan ciljanog raspona 20-30 zbog "
            "determinističkog odabira iz dostupnih ulaznih kriterija."
        )

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_natuknica": len(entries),
        "ukupan_broj_izdvojenih_pilot_natuknica": len(pilot_entries),
        "broj_po_vrsta_pojma": dict(sorted(by_vrsta.items())),
        "broj_po_osnova_ulaska_u_pilot": dict(sorted(by_osnova.items())),
        "popis_pilot_kanonski_naziv": pilot_names,
        "broj_natuknica_s_praznim_nn_sidra": empty_nn_sidra,
        "broj_natuknica_status_validacije_CEKA_NN_SIDRO": status_ceka,
        "ciljani_raspon_pilot_skupa": f"{PILOT_TARGET_MIN}-{PILOT_TARGET_MAX}",
        "pilot_skup_u_ciljanom_rasponu": in_target,
        "napomena_o_rasponu": note,
        "ulazni_status_validacije_default": input_manifest.get(
            "broj_natuknica_po_status_validacije", {}
        ),
    }
    _write_json(output_manifest_path, output_manifest)

    return (
        len(entries),
        len(pilot_entries),
        by_vrsta,
        by_osnova,
        empty_nn_sidra,
        status_ceka,
        pilot_names,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Izdvaja pilot-skup rječničkih natuknica za prvo NN sidrenje."
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
        total_pilot,
        by_vrsta,
        by_osnova,
        empty_nn_sidra,
        status_ceka,
        pilot_names,
    ) = extract_pilot_entries(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"INPUT_ENTRIES={total_in}")
    print(f"PILOT_ENTRIES={total_pilot}")
    for vrsta, count in sorted(by_vrsta.items()):
        print(f"PILOT_BY_VRSTA={vrsta}:{count}")
    for osnova, count in sorted(by_osnova.items()):
        print(f"PILOT_BY_OSNOVA={osnova}:{count}")
    for name in pilot_names:
        print(f"PILOT_KANONSKI_NAZIV={name}")
    print(f"PILOT_EMPTY_NN_SIDRA={empty_nn_sidra}")
    print(f"PILOT_STATUS_CEKA_NN_SIDRO={status_ceka}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
