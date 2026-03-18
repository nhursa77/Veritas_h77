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
DEFAULT_OLD_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_manifest.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2_manifest.json"
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


def _normalize_scalar(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def _sidro_key(sidro: dict[str, Any]) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _normalize_scalar(sidro.get("naziv_akta")),
        _normalize_scalar(sidro.get("broj_nn")),
        _normalize_scalar(sidro.get("clanak")),
        _normalize_scalar(sidro.get("stavak")),
        _normalize_scalar(sidro.get("tocka")),
    )


def _stable_candidate_id(
    parent_id: str,
    act_slug: str,
    broj_nn: str,
    clanak: str,
    stavak: str | None,
    tocka: str | None,
) -> str:
    seed = (
        f"{parent_id}|{act_slug}|{broj_nn}|{clanak}|"
        f"{stavak or 'NULL'}|{tocka or 'NULL'}"
    ).encode("utf-8")
    digest = hashlib.sha256(seed).hexdigest()[:12]
    return f"VH77-KPNN2-{digest}"


def _safe_part(value: str | None, fallback: str) -> str:
    if value is None:
        return fallback
    stripped = value.strip()
    return stripped if stripped else fallback


def _candidate_name(
    parent_name: str,
    act_slug: str,
    clanak: str,
    stavak: str | None,
    tocka: str | None,
) -> str:
    s_part = _safe_part(stavak, "null")
    t_part = _safe_part(tocka, "null")
    return f"{parent_name} — {act_slug} — {clanak} — s{s_part} — t{t_part}"


def _entry_status(entry: dict[str, Any]) -> str:
    return str(entry.get("nn_sidra", {}).get("status_sidra", "")).strip()


def split_candidates_v2(
    input_path: Path,
    input_manifest_path: Path,
    old_output_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], dict[str, int], dict[str, int], dict[str, int]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)
    old_manifest = _load_json(old_output_manifest_path) if old_output_manifest_path.exists() else {}

    entries = payload.get("natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    multi_entries: list[dict[str, Any]] = [
        e for e in entries if isinstance(e, dict) and _entry_status(e) in MULTI_STATUSES
    ]

    candidates: list[dict[str, Any]] = []
    by_parent: collections.Counter[str] = collections.Counter()
    by_act: collections.Counter[str] = collections.Counter()
    input_sidra_count_by_parent: dict[str, int] = {}

    for entry in multi_entries:
        parent_id = str(entry.get("pojam_id", "")).strip()
        parent_name = str(entry.get("kanonski_naziv", "")).strip()
        status_sidra = _entry_status(entry)

        sidra = entry.get("nn_sidra", {}).get("sidra", [])
        if not isinstance(sidra, list):
            sidra = []

        input_sidra_count_by_parent[parent_name] = len(sidra)

        # Deduplikacija po traženoj kombinaciji polja.
        unique_by_key: dict[tuple[str | None, str | None, str | None, str | None, str | None], dict[str, Any]] = {}
        for sidro in sidra:
            if not isinstance(sidro, dict):
                continue
            key = _sidro_key(sidro)
            unique_by_key.setdefault(key, sidro)

        act_set = {
            _safe_part(_normalize_scalar(s.get("akt_slug")), "")
            for s in unique_by_key.values()
        }
        osnova = "RAZLICIT_AKT" if len(act_set) > 1 else "RAZLICIT_NORMATIVNI_KONTEKST"

        for sidro in unique_by_key.values():
            naziv_akta = _safe_part(_normalize_scalar(sidro.get("naziv_akta")), "(nepoznat_akt)")
            act_slug = _safe_part(_normalize_scalar(sidro.get("akt_slug")), "(nepoznat_slug)")
            broj_nn = _safe_part(_normalize_scalar(sidro.get("broj_nn")), "(nepoznat_nn)")
            clanak = _safe_part(_normalize_scalar(sidro.get("clanak")), "(nepoznat_clanak)")
            stavak = _normalize_scalar(sidro.get("stavak"))
            tocka = _normalize_scalar(sidro.get("tocka"))
            izvor_putanja = _safe_part(
                _normalize_scalar(sidro.get("izvor_putanja")),
                "(nepoznata_putanja)",
            )

            candidate = {
                "nadredeni_pojam_id": parent_id,
                "nadredeni_kanonski_naziv": parent_name,
                "kandidat_id": _stable_candidate_id(
                    parent_id=parent_id,
                    act_slug=act_slug,
                    broj_nn=broj_nn,
                    clanak=clanak,
                    stavak=stavak,
                    tocka=tocka,
                ),
                "kanonski_naziv_kandidata": _candidate_name(
                    parent_name=parent_name,
                    act_slug=act_slug,
                    clanak=clanak,
                    stavak=stavak,
                    tocka=tocka,
                ),
                "naziv_akta": naziv_akta,
                "akt_slug": act_slug,
                "broj_nn": broj_nn,
                "clanak": clanak,
                "stavak": stavak,
                "tocka": tocka,
                "izvor_putanja": izvor_putanja,
                "status_kandidata": "KANDIDAT_NN_SIDRA",
                "osnova_razdvajanja": osnova,
                "zahtijeva_rucnu_validaciju": True,
            }
            candidates.append(candidate)
            by_parent[parent_name] += 1
            by_act[naziv_akta] += 1

        print(
            "ULAZ_IZLAZ_PO_NATUKNICI="
            f"{parent_name}|SIDRA={len(sidra)}|KANDIDATI_V2={by_parent[parent_name]}"
        )

    out_payload = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "ukupan_broj_ulaznih_viseznacnih_natuknica": len(multi_entries),
        "ukupan_broj_kandidata_v2": len(candidates),
        "kandidatske_podnatuknice_v2": candidates,
    }
    _write_json(output_path, out_payload)

    old_total = int(old_manifest.get("ukupan_broj_kandidatskih_podnatuknica", 0))
    old_by_parent = old_manifest.get("broj_kandidata_po_nadredenom_pojmu", {})
    if not isinstance(old_by_parent, dict):
        old_by_parent = {}

    stayed_one: list[dict[str, str]] = []
    for parent_name, new_count in sorted(by_parent.items()):
        if new_count == 1:
            sidra_count = input_sidra_count_by_parent.get(parent_name, 0)
            if sidra_count <= 1:
                razlog = "ULAZ_VEC_IMA_JEDNO_SIDRO"
            else:
                razlog = "SVA_SIDRA_DIJELE_ISTU_KOMBINACIJU_AKT_NN_CLANAK_STAVAK_TOCKA"
            stayed_one.append(
                {
                    "nadredeni_kanonski_naziv": parent_name,
                    "broj_sidara_u_ulazu": str(sidra_count),
                    "broj_kandidata_v2": "1",
                    "objasnjenje": razlog,
                }
            )

    out_manifest = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "naziv_izlazne_datoteke": output_path.as_posix(),
        "ukupan_broj_ulaznih_viseznacnih_natuknica": len(multi_entries),
        "ukupan_broj_kandidata_v2": len(candidates),
        "broj_kandidata_po_nadredenom_pojmu": dict(sorted(by_parent.items())),
        "broj_kandidata_po_aktu": dict(sorted(by_act.items())),
        "usporedba_staro_novo": {
            "stari_broj_kandidata": old_total,
            "novi_broj_kandidata": len(candidates),
            "delta": len(candidates) - old_total,
            "stari_broj_kandidata_po_nadredenom": old_by_parent,
            "novi_broj_kandidata_po_nadredenom": dict(sorted(by_parent.items())),
        },
        "popis_natuknica_gdje_je_broj_kandidata_ostao_1": stayed_one,
    }
    _write_json(output_manifest_path, out_manifest)

    return (
        len(multi_entries),
        len(candidates),
        dict(by_parent),
        dict(by_act),
        input_sidra_count_by_parent,
        old_by_parent,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Ispravlja razlaganje NN kandidata na razinu stvarnih sidara (v2)."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--old-output-manifest", type=Path, default=DEFAULT_OLD_OUTPUT_MANIFEST)
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

    total_multi, total_v2, by_parent, by_act, sidra_in, _ = split_candidates_v2(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        old_output_manifest_path=args.old_output_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"ULAZ_VISEZNACNE_NATUKNICE={total_multi}")
    print(f"UKUPNO_KANDIDATA_V2={total_v2}")
    for parent_name in sorted(by_parent.keys()):
        print(
            "POJAM_SIDRA_KANDIDATI="
            f"{parent_name}|SIDRA={sidra_in.get(parent_name, 0)}|KANDIDATI_V2={by_parent[parent_name]}"
        )
    for act, count in sorted(by_act.items()):
        print(f"KANDIDATI_V2_PO_AKTU={act}:{count}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
