from __future__ import annotations

import argparse
import collections
import hashlib
import json
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran_manifest.json"
)
DEFAULT_PREVIOUS_OUTPUT = Path("baza_terminologije/rjecnik/granske_podnatuknice_nn.json")
DEFAULT_PREVIOUS_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/granske_podnatuknice_nn_manifest.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json"
)

TARGET_POJMOVI = [
    "dokaz",
    "dostava",
    "izvršenje",
    "presuda",
    "prigovor",
    "rješenje",
    "žalba",
    "apsolutna nenadležnost",
]

STATUS_PODNATUKNICE = "GRANSKI_KONSOLIDIRANO"


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def _classify_context(act_slug: str | None, naziv_akta: str | None) -> str:
    slug = (act_slug or "").lower()
    naziv = (naziv_akta or "").lower()
    joined = f"{slug} {naziv}"

    if "prekrsaj" in joined:
        return "prekršajni"
    if "ustav" in joined:
        return "ustavni / opći"
    return "drugi dokazivi kontekst"


def _context_display_name(context_label: str, act_slug: str | None, naziv_akta: str | None) -> str:
    if context_label == "prekršajni":
        return "prekršajni zakon"
    if context_label == "ustavni / opći":
        return "ustav rh"
    if naziv_akta:
        return naziv_akta.replace("_", " ")
    if act_slug:
        return act_slug.replace("_", " ")
    return "drugi kontekst"


def _sidro_sort_key(sidro: dict[str, Any]) -> tuple[str, str, str, str, str]:
    return (
        _norm(sidro.get("naziv_akta")) or "",
        _norm(sidro.get("broj_nn")) or "",
        _norm(sidro.get("clanak")) or "",
        _norm(sidro.get("stavak")) or "",
        _norm(sidro.get("tocka")) or "",
    )


def _grouping_key(
    sidro: dict[str, Any],
) -> tuple[str, str | None, str | None, str | None, str | None, str | None, str | None]:
    naziv_akta = _norm(sidro.get("naziv_akta"))
    act_slug = _norm(sidro.get("akt_slug"))
    broj_nn = _norm(sidro.get("broj_nn"))
    clanak = _norm(sidro.get("clanak"))
    stavak = _norm(sidro.get("stavak"))
    tocka = _norm(sidro.get("tocka"))
    context = _classify_context(act_slug, naziv_akta)
    return (context, naziv_akta, act_slug, broj_nn, clanak, stavak, tocka)


def _build_id(
    parent_id: str,
    context_label: str,
    act_slug: str | None,
    broj_nn: str | None,
    clanak: str | None,
    stavak: str | None,
    tocka: str | None,
) -> str:
    seed = (
        f"{parent_id}|{context_label}|{act_slug or 'NULL'}|{broj_nn or 'NULL'}|"
        f"{clanak or 'NULL'}|{stavak or 'NULL'}|{tocka or 'NULL'}"
    )
    digest = hashlib.sha256(seed.encode("utf-8")).hexdigest()[:12]
    return f"VH77-GPNN-{digest}"


def consolidate(
    input_path: Path,
    input_manifest_path: Path,
    previous_output_path: Path,
    previous_output_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> int:
    payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    old_payload = _load_json(previous_output_path) if previous_output_path.exists() else {}
    old_manifest = (
        _load_json(previous_output_manifest_path)
        if previous_output_manifest_path.exists()
        else {}
    )

    entries = payload.get("natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    output_rows: list[dict[str, Any]] = []
    by_parent: collections.Counter[str] = collections.Counter()
    by_act: collections.Counter[str] = collections.Counter()
    by_context: collections.Counter[str] = collections.Counter()

    single_context_pojmovi: list[str] = []
    multi_context_pojmovi: list[str] = []
    per_pojam_detalji: list[dict[str, Any]] = []

    for entry in entries:
        if not isinstance(entry, dict):
            continue

        parent_name = str(entry.get("kanonski_naziv", "")).strip()
        if parent_name not in TARGET_POJMOVI:
            continue

        parent_id = str(entry.get("pojam_id", "")).strip()
        sidra = entry.get("nn_sidra", {}).get("sidra", [])
        if not isinstance(sidra, list):
            sidra = []

        grouped: dict[
            tuple[
                str,
                str | None,
                str | None,
                str | None,
                str | None,
                str | None,
                str | None,
            ],
            list[dict[str, Any]],
        ] = collections.defaultdict(list)
        for sidro in sidra:
            if not isinstance(sidro, dict):
                continue
            key = _grouping_key(sidro)
            grouped[key].append(sidro)

        if len(grouped) <= 1:
            single_context_pojmovi.append(parent_name)
        else:
            multi_context_pojmovi.append(parent_name)

        acts = {k[1] or "(nepoznat_akt)" for k in grouped.keys()}
        contexts = {k[0] for k in grouped.keys()}

        grouping_reasons: list[dict[str, Any]] = []

        for key in sorted(
            grouped.keys(),
            key=lambda t: (
                t[0],
                t[1] or "",
                t[2] or "",
                t[3] or "",
                t[4] or "",
                t[5] or "",
                t[6] or "",
            ),
        ):
            context_label, naziv_akta, act_slug, broj_nn, clanak, stavak, tocka = key
            context_sidra = sorted(grouped[key], key=_sidro_sort_key)

            if len(acts) > 1:
                osnova = "RAZLICIT_AKT"
            elif len(contexts) > 1:
                osnova = "RAZLICITA_PRAVNA_GRANA"
            else:
                osnova = "RAZLICIT_NORMATIVNI_KONTEKST"

            if len(grouped) == 1 and len(sidra) > 1:
                razlog = "SVA_SIDRA_DIJELE_ISTI_AKT_I_ISTI_NORMATIVNI_KONTEKST"
            elif len(grouped) == 1 and len(sidra) == 1:
                razlog = "ULAZ_VEC_SADRZI_JEDNO_SIDRO"
            else:
                razlog = osnova

            display = _context_display_name(context_label, act_slug, naziv_akta)
            clanak_part = clanak if clanak else "(bez_clanka)"
            stavak_part = f" st. {stavak}" if stavak else ""
            tocka_part = f" t. {tocka}" if tocka else ""
            podnatuknica = {
                "nadredeni_pojam_id": parent_id,
                "nadredeni_kanonski_naziv": parent_name,
                "podnatuknica_id": _build_id(
                    parent_id,
                    context_label,
                    act_slug,
                    broj_nn,
                    clanak,
                    stavak,
                    tocka,
                ),
                "kanonski_naziv_podnatuknice": (
                    f"{parent_name} — {display} — čl. {clanak_part}{stavak_part}{tocka_part}"
                ),
                "pravna_grana_ili_kontekst": context_label,
                "naziv_akta": naziv_akta,
                "akt_slug": act_slug,
                "broj_nn": broj_nn,
                "nn_sidra": context_sidra,
                "status_podnatuknice": STATUS_PODNATUKNICE,
                "osnova_konsolidacije": osnova,
                "zahtijeva_rucnu_potvrdu": True,
            }
            output_rows.append(podnatuknica)
            by_parent[parent_name] += 1
            by_act[naziv_akta or "(nepoznat_akt)"] += 1
            by_context[context_label] += 1

            grouping_reasons.append(
                {
                    "podnatuknica_id": podnatuknica["podnatuknica_id"],
                    "broj_sidara_u_grupi": len(context_sidra),
                    "osnova_konsolidacije": osnova,
                    "razlog_grupiranja": razlog,
                    "kontekst": {
                        "pravna_grana_ili_kontekst": context_label,
                        "naziv_akta": naziv_akta,
                        "broj_nn": broj_nn,
                        "clanak": clanak,
                        "stavak": stavak,
                        "tocka": tocka,
                    },
                }
            )

        per_pojam_detalji.append(
            {
                "nadredeni_kanonski_naziv": parent_name,
                "broj_ulaznih_sidara": len(sidra),
                "broj_izlaznih_podnatuknica": by_parent[parent_name],
                "razlozi_grupiranja": grouping_reasons,
                "status_mapiranja": (
                    "OSTAO_1_NA_1" if by_parent[parent_name] == 1 else "RAZLOMLJEN_NA_VISE"
                ),
            }
        )

        print(
            "POJAM_KONSOLIDACIJA="
            f"{parent_name}|ULAZNA_POTVRDENA_SIDRA={len(sidra)}|"
            f"IZLAZNE_GRANSKE_PODNATUKNICE={by_parent[parent_name]}"
        )

    output_payload = {
        "ulaz": input_path.as_posix(),
        "ulaz_manifest": input_manifest_path.as_posix(),
        "ukupan_broj_ulaznih_opcih_pojmova": len(TARGET_POJMOVI),
        "ukupan_broj_izlaznih_granskih_podnatuknica_v2": len(output_rows),
        "granske_podnatuknice": output_rows,
    }
    _write_json(output_path, output_payload)

    manifest = {
        "ulaz": input_path.as_posix(),
        "ulaz_manifest": input_manifest_path.as_posix(),
        "izlaz": output_path.as_posix(),
        "ukupan_broj_ulaznih_opcih_pojmova": len(TARGET_POJMOVI),
        "ukupan_broj_izlaznih_granskih_podnatuknica_v2": len(output_rows),
        "broj_podnatuknica_po_nadredenom_pojmu": dict(sorted(by_parent.items())),
        "broj_podnatuknica_po_aktu": dict(sorted(by_act.items())),
        "broj_podnatuknica_po_pravnoj_grani_ili_kontekstu": dict(
            sorted(by_context.items())
        ),
        "detalji_po_nadredenom_pojmu": sorted(
            per_pojam_detalji,
            key=lambda item: str(item["nadredeni_kanonski_naziv"]),
        ),
        "popis_svih_podnatuknica": [
            {
                "podnatuknica_id": row["podnatuknica_id"],
                "kanonski_naziv_podnatuknice": row["kanonski_naziv_podnatuknice"],
                "nadredeni_kanonski_naziv": row["nadredeni_kanonski_naziv"],
                "pravna_grana_ili_kontekst": row["pravna_grana_ili_kontekst"],
                "naziv_akta": row["naziv_akta"],
                "broj_nn": row["broj_nn"],
            }
            for row in output_rows
        ],
        "popis_pojmova_koji_su_ostali_u_jednom_kontekstu": sorted(
            set(single_context_pojmovi)
        ),
        "popis_pojmova_koji_su_razlomljeni_na_vise_konteksta": sorted(
            set(multi_context_pojmovi)
        ),
        "popis_pojmova_koji_su_ostali_1_na_1_i_zasto": [
            {
                "nadredeni_kanonski_naziv": item["nadredeni_kanonski_naziv"],
                "broj_ulaznih_sidara": item["broj_ulaznih_sidara"],
                "broj_izlaznih_podnatuknica": item["broj_izlaznih_podnatuknica"],
                "objasnjenje": (
                    "SVA_SIDRA_DIJELE_ISTI_AKT_I_ISTI_NORMATIVNI_KONTEKST"
                    if item["broj_ulaznih_sidara"] > 1
                    else "ULAZ_VEC_SADRZI_JEDNO_SIDRO"
                ),
            }
            for item in sorted(
                per_pojam_detalji,
                key=lambda x: str(x["nadredeni_kanonski_naziv"]),
            )
            if int(item["broj_izlaznih_podnatuknica"]) == 1
        ],
        "usporedba_prethodni_v1_prema_v2": {
            "prethodni_ukupan_broj_podnatuknica": int(
                old_manifest.get("ukupan_broj_izlaznih_granskih_podnatuknica", 0)
                or old_payload.get("ukupan_broj_izlaznih_granskih_podnatuknica", 0)
                or 0
            ),
            "novi_ukupan_broj_podnatuknica_v2": len(output_rows),
        },
    }
    _write_json(output_manifest_path, manifest)

    print(f"UKUPNO_PODNATUKNICA={len(output_rows)}")
    print(f"OUTPUT_PATH={output_path.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={output_manifest_path.as_posix()}")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Konsolidira validirane NN pojmove u granske podnatuknice."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--previous-output", type=Path, default=DEFAULT_PREVIOUS_OUTPUT)
    parser.add_argument(
        "--previous-output-manifest",
        type=Path,
        default=DEFAULT_PREVIOUS_OUTPUT_MANIFEST,
    )
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

    return consolidate(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        previous_output_path=args.previous_output,
        previous_output_manifest_path=args.previous_output_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )


if __name__ == "__main__":
    raise SystemExit(main())
