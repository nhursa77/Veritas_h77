from __future__ import annotations

import hashlib
import json
from datetime import datetime
from html import unescape
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = ROOT / "izvori" / "operativno" / "zakon_hr" / "ustav_rh" / "ustav_rh_struktura.json"
META_PATH = ROOT / "izvori" / "operativno" / "zakon_hr" / "ustav_rh" / "meta.json"
OUTPUT_DIR = ROOT / "baza_zakona" / "norme" / "ustav_rh"
REPORT_PATH = OUTPUT_DIR / "IZVJESTAJ_NORMIRANJA.md"


def sha256_hex(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest().upper()


def procisti_tekst(value: str) -> str:
    decoded = unescape(value or "")
    decoded = decoded.replace("\u00a0", " ")
    decoded = re.sub(r"\s+", " ", decoded).strip()
    return decoded


def ucitaj_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def fmt_datum_danas() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def izgradi_stavke(stavci_raw: list[dict]) -> list[dict]:
    stavci = []
    for idx, stavak in enumerate(stavci_raw or [], start=1):
        tekst = procisti_tekst(str(stavak.get("tekst", "")))
        if not tekst:
            continue
        broj = stavak.get("broj")
        if isinstance(broj, int):
            broj_stavka = broj
        else:
            broj_stavka = idx
        stavci.append(
            {
                "broj": broj_stavka,
                "tekst": tekst,
                "tocke": None,
            }
        )
    return stavci


def glavni() -> int:
    struktura = ucitaj_json(INPUT_PATH)
    meta = ucitaj_json(META_PATH)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for stara_datoteka in OUTPUT_DIR.glob("clanak_*.json"):
        stara_datoteka.unlink()

    datum_pristupa = str(meta.get("datum_pristupa", "")).strip() or fmt_datum_danas()
    stanje_na_dan = datum_pristupa
    datum_provjere = fmt_datum_danas()

    clanci = struktura.get("clanci", [])
    broj_ulaznih = len(clanci)
    broj_generiranih = 0
    preskoceni: list[tuple[str, str]] = []

    for clanak in clanci:
        oznaka_raw = str(clanak.get("oznaka", "")).strip()
        if not oznaka_raw.isdigit():
            preskoceni.append((oznaka_raw or "(bez oznake)", "neispravna oznaka članka"))
            continue

        oznaka_int = int(oznaka_raw)
        stavci = izgradi_stavke(clanak.get("stavci", []))
        if not stavci:
            preskoceni.append((str(oznaka_int), "nema teksta članka u ulaznoj strukturi"))
            continue

        puni_tekst = "\n\n".join(stavak["tekst"] for stavak in stavci)
        sha_teksta = sha256_hex(puni_tekst)

        payload = {
            "akt": {
                "naziv": "Ustav Republike Hrvatske",
                "vrsta": "ustav",
                "slug": "ustav_rh",
                "jurisdikcija": "RH",
                "jezik": "hr",
            },
            "clanak": {
                "oznaka": str(oznaka_int),
                "naslov": None,
                "tekst": puni_tekst,
                "struktura": {
                    "stavci": stavci,
                },
            },
            "verzija": {
                "stanje_na_dan": stanje_na_dan,
                "datum_provjere": datum_provjere,
                "napomena": "Operativni tekst: zakon.hr (pročišćeni).",
            },
            "izvori": {
                "operativni_izvor": {
                    "naziv": "zakon.hr",
                    "url": "https://www.zakon.hr/z/94/Ustav-Republike-Hrvatske",
                    "datum_pristupa": datum_pristupa,
                },
                "dokazni_izvor": {
                    "naziv": "Narodne novine",
                    "sidra": [],
                },
                "status_sidra": "nema",
            },
            "integritet": {
                "sha256_teksta": sha_teksta,
                "sha256_datoteke": "",
                "napomena": None,
            },
        }

        canonical_without_file_hash = json.dumps(payload, ensure_ascii=False, indent=2)
        payload["integritet"]["sha256_datoteke"] = sha256_hex(canonical_without_file_hash)
        final_json = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"

        out_file = OUTPUT_DIR / f"clanak_{oznaka_int:04d}.json"
        out_file.write_text(final_json, encoding="utf-8")
        broj_generiranih += 1

    today = fmt_datum_danas()
    report_lines = [
        "# Izvještaj normiranja (Ustav RH)",
        "",
        f"- Datum: {today}",
        f"- Broj članaka u ulazu: {broj_ulaznih}",
        f"- Broj generiranih NORMA JSON datoteka: {broj_generiranih}",
        f"- Broj preskočenih članaka: {len(preskoceni)}",
        "",
    ]

    if preskoceni:
        report_lines.append("## Preskočeni članci")
        report_lines.append("")
        for oznaka, razlog in preskoceni:
            report_lines.append(f"- čl. {oznaka}: {razlog}")
    else:
        report_lines.append("## Preskočeni članci")
        report_lines.append("")
        report_lines.append("- Nema preskočenih članaka.")

    REPORT_PATH.write_text("\n".join(report_lines) + "\n", encoding="utf-8")

    print(f"Generirano: {broj_generiranih}")
    print(f"Preskočeno: {len(preskoceni)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(glavni())
