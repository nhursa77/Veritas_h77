from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime
from pathlib import Path
from typing import Any


def sha256_upper_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest().upper()


def sha256_upper_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest().upper()


def kanoniziraj_lf(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def danas_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def normaliziraj_datum(datum: str) -> str:
    raw = (datum or "").strip()
    if not raw:
        return danas_hr()

    try:
        parsed = datetime.strptime(raw, "%d.%m.%Y.")
        return parsed.strftime("%d.%m.%Y.")
    except ValueError:
        pass

    try:
        parsed = datetime.strptime(raw, "%d.%m.%Y")
        return parsed.strftime("%d.%m.%Y.")
    except ValueError:
        return danas_hr()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Normiratelj iz strukture NN u NORMA JSON")
    parser.add_argument("--akt-slug", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--meta", required=True)
    parser.add_argument("--out-dir", required=True)
    return parser


def create_norma_payload(
    akt: dict[str, Any],
    clanak: dict[str, Any],
    meta: dict[str, Any],
    stanje_na_dan: str,
    datum_provjere: str,
) -> dict[str, Any]:
    broj = int(clanak["broj"])
    tekst = kanoniziraj_lf(str(clanak["tekst"]).strip())

    oznaka_akta = meta.get("oznaka_akta")
    sidro_obj = {
        "nn_broj": oznaka_akta if isinstance(oznaka_akta, str) and oznaka_akta.strip() else None,
        "datum_objave": None,
        "opis": "službena objava",
        "url": meta.get("url"),
    }

    payload: dict[str, Any] = {
        "akt": {
            "naziv": akt.get("naziv"),
            "vrsta": akt.get("vrsta"),
            "slug": akt.get("slug"),
            "jurisdikcija": akt.get("jurisdikcija", "RH"),
            "jezik": akt.get("jezik", "hr"),
        },
        "clanak": {
            "oznaka": str(broj),
            "naslov": clanak.get("naslov"),
            "tekst": tekst,
            "struktura": {
                "stavci": None,
            },
        },
        "verzija": {
            "stanje_na_dan": stanje_na_dan,
            "datum_provjere": datum_provjere,
            "napomena": "Normirano iz NN strukture.",
        },
        "izvori": {
            "operativni_izvor": {
                "naziv": "Narodne novine",
                "url": meta.get("url"),
                "datum_pristupa": stanje_na_dan,
            },
            "dokazni_izvor": {
                "naziv": "Narodne novine",
                "sidra": [sidro_obj],
            },
            "status_sidra": "puno",
        },
        "integritet": {
            "sha256_teksta": sha256_upper_text(tekst),
            "sha256_datoteke": None,
            "napomena": None,
        },
    }

    return payload


def main() -> int:
    args = build_parser().parse_args()

    akt_slug = args.akt_slug.strip().lower()
    input_path = Path(args.input)
    meta_path = Path(args.meta)
    out_dir = Path(args.out_dir)
    report_path = out_dir / "IZVJESTAJ_NORMIRANJA.md"

    struktura = load_json(input_path)
    meta = load_json(meta_path)

    akt = struktura.get("akt") if isinstance(struktura.get("akt"), dict) else {}
    clanci = struktura.get("clanci") if isinstance(struktura.get("clanci"), list) else []

    stanje_na_dan = normaliziraj_datum(str(meta.get("datum_pristupa", "")))
    datum_provjere = danas_hr()

    out_dir.mkdir(parents=True, exist_ok=True)

    generated = 0
    warnings: list[str] = []
    broj_pojava: dict[int, int] = {}

    for idx, clanak in enumerate(clanci, start=1):
        if not isinstance(clanak, dict):
            warnings.append(f"Index {idx}: zapis članka nije objekt.")
            continue

        broj = clanak.get("broj")
        if not isinstance(broj, int):
            warnings.append(f"Index {idx}: nevaljan broj članka ({broj}).")
            continue

        tekst_raw = clanak.get("tekst")
        if not isinstance(tekst_raw, str) or not tekst_raw.strip():
            warnings.append(f"Članak {broj}: preskočen (nedostaje tekst).")
            continue

        broj_pojava[broj] = broj_pojava.get(broj, 0) + 1
        if broj_pojava[broj] > 1:
            warnings.append(
                f"Članak {broj}: duplikat broja; datoteka clanak_{broj:04d}.json je prepisana."
            )

        payload = create_norma_payload(
            akt=akt,
            clanak=clanak,
            meta=meta,
            stanje_na_dan=stanje_na_dan,
            datum_provjere=datum_provjere,
        )

        json_without_file_hash = json.dumps(payload, ensure_ascii=False, indent=2)
        payload["integritet"]["sha256_datoteke"] = sha256_upper_text(json_without_file_hash)
        final_text = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"

        file_name = f"clanak_{broj:04d}.json"
        out_path = out_dir / file_name
        out_path.write_text(final_text, encoding="utf-8")
        generated += 1

    lines = [
        "# Izvještaj normiranja (NN struktura)",
        "",
        f"- Datum: {danas_hr()}",
        f"- Akt slug: {akt_slug}",
        f"- Broj ulaznih članaka: {len(clanci)}",
        f"- Broj generiranih JSON datoteka: {generated}",
        f"- Broj upozorenja: {len(warnings)}",
        "",
        "## Upozorenja",
        "",
    ]

    if warnings:
        for warning in warnings:
            lines.append(f"- {warning}")
    else:
        lines.append("- Nema upozorenja.")

    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"OK: generirano {generated} NORMA članaka")
    print(f"Izlaz: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
