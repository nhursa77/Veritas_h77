from __future__ import annotations

import argparse
import collections
import json
import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren_manifest.json"
)

SOURCE_ROOT = Path("izvori/dokazno/narodne_novine")
NORMS_ROOT = Path("baza_zakona/norme")

ACT_SOURCE_MAP = {
    "prekrsajni_zakon_procisceni": "prekrsajni_zakon",
    "ustav_rh_procisceni": "ustav_rh_nn_85_2010",
}

TARGET_TERMS = {
    "dokaz": {
        "search_pattern": r"dokaz",
        "max_sidra": 5,
    },
    "dostava": {
        "search_pattern": r"dostav",
        "max_sidra": 5,
    },
    "izvršenje": {
        "search_pattern": r"izvrs|izvr\u0161",
        "max_sidra": 5,
    },
    "presuda": {
        "search_pattern": r"presud",
        "max_sidra": 5,
    },
    "prigovor": {
        "search_pattern": r"prigovor",
        "max_sidra": 5,
    },
    "rješenje": {
        "search_pattern": r"rjesen|rje\u0161en",
        "max_sidra": 5,
    },
    "žalba": {
        "search_pattern": r"zalb|\u017ealb",
        "max_sidra": 5,
    },
    "apsolutna nenadležnost": {
        "search_pattern": r"apsolutna\s+nenadleznost",
        "fallback_pattern": r"nenadlez",
        "max_sidra": 5,
        "allow_nejasno": True,
    },
    "glavni postupak": {
        "search_pattern": r"glavni\s+postupak",
        "max_sidra": 5,
    },
}


@dataclass(frozen=True)
class ArticleRecord:
    naziv_akta: str
    akt_slug: str
    broj_nn: str
    clanak: str
    izvor_putanja: str
    tekst_norm: str


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


def _clanak_sort_key(clanak: str) -> tuple[int, str]:
    text = str(clanak).strip()
    if text.isdigit():
        return (int(text), text)
    match = re.search(r"(\d+)", text)
    if match:
        return (int(match.group(1)), text)
    return (10**9, text)


def _load_source_meta(source_slug: str) -> tuple[str, str, Path] | None:
    source_dir = SOURCE_ROOT / source_slug
    meta_path = source_dir / "meta.json"
    izvor_path = source_dir / "izvor_nn.html"
    if not meta_path.exists() or not izvor_path.exists():
        return None

    meta = _load_json(meta_path)
    naziv_akta = str(meta.get("naziv_akta") or source_slug)
    broj_nn = str(meta.get("oznaka_akta") or "")
    return naziv_akta, broj_nn, izvor_path


def collect_article_records() -> list[ArticleRecord]:
    records: list[ArticleRecord] = []

    for norm_dir in sorted(NORMS_ROOT.glob("*_procisceni")):
        source_slug = ACT_SOURCE_MAP.get(norm_dir.name)
        if source_slug is None:
            continue

        source_meta = _load_source_meta(source_slug)
        if source_meta is None:
            continue

        naziv_akta_meta, broj_nn_meta, izvor_path = source_meta
        izvor_putanja = izvor_path.as_posix()

        for article_path in sorted(norm_dir.glob("clanak_*.json")):
            payload = _load_json(article_path)
            clanak = str(payload.get("clanak", {}).get("oznaka", "")).strip()
            tekst = str(payload.get("clanak", {}).get("tekst", "")).strip()
            if not clanak or not tekst:
                continue

            sidra = payload.get("izvori", {}).get("dokazni_izvor", {}).get("sidra", [])
            broj_nn = broj_nn_meta
            if isinstance(sidra, list) and len(sidra) > 0:
                broj_nn_payload = str(sidra[0].get("nn_broj") or "").strip()
                if broj_nn_payload:
                    broj_nn = broj_nn_payload

            naziv_akta = naziv_akta_meta
            if not naziv_akta:
                naziv_akta = str(payload.get("akt", {}).get("naziv") or source_slug)

            records.append(
                ArticleRecord(
                    naziv_akta=naziv_akta,
                    akt_slug=source_slug,
                    broj_nn=broj_nn,
                    clanak=clanak,
                    izvor_putanja=izvor_putanja,
                    tekst_norm=_norm(tekst),
                )
            )

    return records


def _dedupe_and_limit(records: list[ArticleRecord], limit: int) -> list[ArticleRecord]:
    seen: set[tuple[str, str]] = set()
    unique: list[ArticleRecord] = []

    ordered = sorted(
        records,
        key=lambda x: (x.akt_slug, _clanak_sort_key(x.clanak)),
    )
    for record in ordered:
        key = (record.akt_slug, record.clanak)
        if key in seen:
            continue
        seen.add(key)
        unique.append(record)
        if len(unique) >= limit:
            break

    return unique


def _build_sidro(record: ArticleRecord, note: str) -> dict[str, Any]:
    return {
        "naziv_akta": record.naziv_akta,
        "akt_slug": record.akt_slug,
        "broj_nn": record.broj_nn,
        "clanak": record.clanak,
        "stavak": None,
        "tocka": None,
        "izvor_putanja": record.izvor_putanja,
        "napomena": note,
    }


def _status_validacije_for(status_sidra: str) -> str:
    if status_sidra == "OK":
        return "NN_SIDRENO"
    if status_sidra == "NEDOSTAJE":
        return "CEKA_NN_SIDRO"
    return "CEKA_RUCNU_PROVJERU_NN"


def anchor_entry(entry: dict[str, Any], records: list[ArticleRecord]) -> tuple[dict[str, Any], str, int]:
    anchored = dict(entry)
    term = str(anchored.get("kanonski_naziv", "")).strip()
    config = TARGET_TERMS.get(term)

    if config is None:
        anchored["nn_sidra"] = {
            "status_sidra": "NEJASNO",
            "sidra": [],
        }
        anchored["status_validacije"] = "CEKA_RUCNU_PROVJERU_NN"
        return anchored, "NEJASNO", 0

    pattern = re.compile(str(config["search_pattern"]))
    matching = [r for r in records if pattern.search(r.tekst_norm)]

    status_sidra = "NEDOSTAJE"
    chosen: list[ArticleRecord] = []

    if term == "apsolutna nenadležnost":
        exact_pattern = re.compile(str(config["search_pattern"]))
        exact = [r for r in records if exact_pattern.search(r.tekst_norm)]
        if len(exact) == 1:
            status_sidra = "OK"
            chosen = _dedupe_and_limit(exact, int(config["max_sidra"]))
        elif len(exact) > 1:
            status_sidra = "VISE_MOGUCIH_SIDARA"
            chosen = _dedupe_and_limit(exact, int(config["max_sidra"]))
        else:
            fallback = [
                r
                for r in records
                if re.search(str(config.get("fallback_pattern", "")), r.tekst_norm)
            ]
            if len(fallback) > 0:
                status_sidra = "NEJASNO"
                chosen = _dedupe_and_limit(fallback, int(config["max_sidra"]))
            else:
                status_sidra = "NEDOSTAJE"
                chosen = []
    else:
        if len(matching) == 0:
            status_sidra = "NEDOSTAJE"
            chosen = []
        elif len(matching) == 1:
            status_sidra = "OK"
            chosen = _dedupe_and_limit(matching, int(config["max_sidra"]))
        else:
            status_sidra = "VISE_MOGUCIH_SIDARA"
            chosen = _dedupe_and_limit(matching, int(config["max_sidra"]))

    sidra: list[dict[str, Any]] = []
    for rec in chosen:
        if status_sidra == "OK":
            note = "Jedno jasno NN sidro u prvom sidrenom sloju."
        elif status_sidra == "VISE_MOGUCIH_SIDARA":
            note = (
                "Više mogućih članaka; bez prisilnog sužavanja na jedno sidro "
                "u prvom sloju."
            )
        elif status_sidra == "NEJASNO":
            note = (
                "Pojam nije jednoznačno potvrđen kao normativna fraza; "
                "upisani su kandidati za ručnu provjeru."
            )
        else:
            note = "Nije pronađeno dokazivo sidro u dostupnim NN izvorima."

        sidra.append(_build_sidro(rec, note))

    anchored["nn_sidra"] = {
        "status_sidra": status_sidra,
        "sidra": sidra,
    }
    anchored["status_validacije"] = _status_validacije_for(status_sidra)

    # Normativna definicija se ne popunjava bez izričite definicije u NN tekstu.
    if anchored.get("definicija_normativna") not in (None, ""):
        anchored["definicija_normativna"] = anchored.get("definicija_normativna")

    return anchored, status_sidra, len(sidra)


def anchor_dataset(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[list[dict[str, Any]], dict[str, int], dict[str, int]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    entries = payload.get("natuknice", [])
    if not isinstance(entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    records = collect_article_records()

    anchored_entries: list[dict[str, Any]] = []
    by_status_sidra: collections.Counter[str] = collections.Counter()
    by_status_validacije: collections.Counter[str] = collections.Counter()

    for entry in entries:
        if not isinstance(entry, dict):
            continue
        anchored, status_sidra, sidra_count = anchor_entry(entry, records)
        anchored_entries.append(anchored)
        by_status_sidra[status_sidra] += 1
        by_status_validacije[str(anchored.get("status_validacije", ""))] += 1
        print(
            "NN_SIDRENJE_ITEM="
            f"{anchored.get('kanonski_naziv')}|{status_sidra}|{sidra_count}"
        )

    output_payload = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "ukupan_broj_ulaznih_natuknica": len(entries),
        "ukupan_broj_nn_sidrenih_natuknica": len(anchored_entries),
        "natuknice": anchored_entries,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "naziv_izlazne_datoteke": output_path.as_posix(),
        "ukupan_broj_ulaznih_natuknica": len(entries),
        "ukupan_broj_nn_sidrenih_natuknica": len(anchored_entries),
        "broj_po_status_sidra": dict(sorted(by_status_sidra.items())),
        "broj_po_status_validacije": dict(sorted(by_status_validacije.items())),
        "obradene_natuknice": [
            {
                "kanonski_naziv": str(item.get("kanonski_naziv", "")),
                "status_sidra": str(item.get("nn_sidra", {}).get("status_sidra", "")),
                "broj_sidara": len(item.get("nn_sidra", {}).get("sidra", [])),
            }
            for item in anchored_entries
        ],
        "koristeni_nn_izvori": sorted(
            {
                sidro.get("akt_slug")
                for item in anchored_entries
                for sidro in item.get("nn_sidra", {}).get("sidra", [])
                if sidro.get("akt_slug")
            }
        ),
        "ulazni_manifest_osnovnog_skupa": {
            "ukupan_broj_natuknica_u_osnovnom_postupovnom_skupu": input_manifest.get(
                "ukupan_broj_natuknica_u_osnovnom_postupovnom_skupu"
            ),
            "popis_kanonski_naziv": input_manifest.get("popis_kanonski_naziv", []),
        },
    }
    _write_json(output_manifest_path, output_manifest)

    return anchored_entries, dict(by_status_sidra), dict(by_status_validacije)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Radi prvo NN sidrenje osnovnog postupovnog skupa rječničkih "
            "natuknica."
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

    anchored_entries, by_status_sidra, by_status_validacije = anchor_dataset(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"NN_SIDRENJE_TOTAL_ENTRIES={len(anchored_entries)}")
    for status, count in sorted(by_status_sidra.items()):
        print(f"NN_SIDRENJE_STATUS_SIDRA={status}:{count}")

    print(
        "NN_SIDRENJE_STATUS_VALIDACIJE="
        f"NN_SIDRENO:{by_status_validacije.get('NN_SIDRENO', 0)}"
    )
    print(
        "NN_SIDRENJE_STATUS_VALIDACIJE="
        "CEKA_RUCNU_PROVJERU_NN:"
        f"{by_status_validacije.get('CEKA_RUCNU_PROVJERU_NN', 0)}"
    )
    print(
        "NN_SIDRENJE_STATUS_VALIDACIJE="
        f"CEKA_NN_SIDRO:{by_status_validacije.get('CEKA_NN_SIDRO', 0)}"
    )
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
