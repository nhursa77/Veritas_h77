from __future__ import annotations

import argparse
import collections
import hashlib
import json
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren_manifest.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/rjecnik/kandidatske_podnatuknice_nn.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_manifest.json"
)

MULTI_STATUSES = {"VISE_MOGUCIH_SIDARA", "NEJASNO"}


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _stable_candidate_id(parent_id: str, act_slug: str, broj_nn: str, ordinal: int) -> str:
    seed = f"{parent_id}|{act_slug}|{broj_nn}|{ordinal}".encode("utf-8")
    digest = hashlib.sha256(seed).hexdigest()[:12]
    return f"VH77-KPNN-{digest}"


def _group_sidra_by_act(sidra: list[dict[str, Any]]) -> dict[tuple[str, str, str], list[dict[str, Any]]]:
    grouped: dict[tuple[str, str, str], list[dict[str, Any]]] = collections.OrderedDict()

    for sidro in sidra:
        akt_slug = str(sidro.get("akt_slug", "")).strip()
        naziv_akta = str(sidro.get("naziv_akta", "")).strip()
        broj_nn = str(sidro.get("broj_nn", "")).strip()
        key = (akt_slug, naziv_akta, broj_nn)
        grouped.setdefault(key, []).append(sidro)

    return grouped


def _build_candidates(entries: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], dict[str, int], dict[str, int], list[str]]:
    candidates: list[dict[str, Any]] = []
    by_parent: collections.Counter[str] = collections.Counter()
    by_act: collections.Counter[str] = collections.Counter()
    parent_names: list[str] = []

    for entry in entries:
        nn_sidra = entry.get("nn_sidra", {})
        status_sidra = str(nn_sidra.get("status_sidra", "")).strip()
        if status_sidra not in MULTI_STATUSES:
            continue

        sidra = nn_sidra.get("sidra", [])
        if not isinstance(sidra, list) or len(sidra) == 0:
            continue

        parent_id = str(entry.get("pojam_id", "")).strip()
        parent_name = str(entry.get("kanonski_naziv", "")).strip()
        if parent_name and parent_name not in parent_names:
            parent_names.append(parent_name)

        grouped = _group_sidra_by_act(sidra)
        osnova = "RAZLICIT_AKT" if len(grouped) > 1 else "RAZLICIT_NORMATIVNI_KONTEKST"

        ordinal = 0
        for (act_slug, naziv_akta, broj_nn), grouped_sidra in grouped.items():
            ordinal += 1
            kandidat_id = _stable_candidate_id(parent_id, act_slug, broj_nn, ordinal)
            kandidat_naziv = f"{parent_name} — {naziv_akta}"

            candidate = {
                "nadredeni_pojam_id": parent_id,
                "nadredeni_kanonski_naziv": parent_name,
                "kandidat_id": kandidat_id,
                "kanonski_naziv_kandidata": kandidat_naziv,
                "naziv_akta": naziv_akta,
                "akt_slug": act_slug,
                "broj_nn": broj_nn,
                "nn_sidra": {
                    "status_sidra": status_sidra,
                    "sidra": grouped_sidra,
                },
                "status_kandidata": "KANDIDAT_NN_SIDRA",
                "osnova_razdvajanja": osnova,
                "zahtijeva_rucnu_validaciju": True,
            }
            candidates.append(candidate)
            by_parent[parent_name] += 1
            by_act[naziv_akta or act_slug] += 1

            print(
                "KANDIDAT_ITEM="
                f"{parent_name}|{kandidat_naziv}|{len(grouped_sidra)}|{status_sidra}"
            )

    return candidates, dict(by_parent), dict(by_act), parent_names


def split_multi_anchor_entries(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], dict[str, int]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    entries = payload.get("natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    multi_entries = []
    for entry in entries:
        status = str(entry.get("nn_sidra", {}).get("status_sidra", "")).strip()
        if status in MULTI_STATUSES:
            multi_entries.append(entry)

    candidates, by_parent, by_act, parent_names = _build_candidates(multi_entries)

    out_payload = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "ukupan_broj_ulaznih_viseznacnih_natuknica": len(multi_entries),
        "ukupan_broj_kandidatskih_podnatuknica": len(candidates),
        "kandidatske_podnatuknice": candidates,
    }
    _write_json(output_path, out_payload)

    out_manifest = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "naziv_izlazne_datoteke": output_path.as_posix(),
        "ukupan_broj_ulaznih_viseznacnih_natuknica": len(multi_entries),
        "ukupan_broj_kandidatskih_podnatuknica": len(candidates),
        "broj_kandidata_po_nadredenom_pojmu": dict(sorted(by_parent.items())),
        "broj_kandidata_po_aktu": dict(sorted(by_act.items())),
        "popis_nadredenih_pojmova": parent_names,
        "popis_kanonski_naziv_kandidata": [
            item.get("kanonski_naziv_kandidata", "") for item in candidates
        ],
        "ulazni_manifest_nn_sidrenja": {
            "broj_po_status_sidra": input_manifest.get("broj_po_status_sidra", {}),
            "broj_po_status_validacije": input_manifest.get(
                "broj_po_status_validacije", {}
            ),
        },
    }
    _write_json(output_manifest_path, out_manifest)

    return len(multi_entries), len(candidates), by_parent, by_act


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Razlaže višeznačna/neasna NN sidra u kandidatske podnatuknice "
            "po aktu i kontekstu."
        )
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

    total_multi, total_candidates, by_parent, by_act = split_multi_anchor_entries(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"ULAZ_VISEZNACNE_NATUKNICE={total_multi}")
    print(f"UKUPNO_KANDIDATA={total_candidates}")
    for parent, count in sorted(by_parent.items()):
        print(f"KANDIDATI_PO_NADREDENOM={parent}:{count}")
    for act, count in sorted(by_act.items()):
        print(f"KANDIDATI_PO_AKTU={act}:{count}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
