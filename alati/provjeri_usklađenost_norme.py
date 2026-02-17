from __future__ import annotations

import hashlib
import json
import re
from collections import defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NORME_DIR = ROOT / "baza_zakona" / "norme" / "ustav_rh"
REPORT_PATH = NORME_DIR / "IZVJESTAJ_VALIDACIJE.md"
PATTERN_DATUM = re.compile(r"^\d{2}\.\d{2}\.\d{4}\.$")
PATTERN_DATOTEKA = re.compile(r"^clanak_(\d{4})\.json$")
DOZVOLJENI_STATUSI = {"puno", "djelomicno", "nema"}


def sha256_hex_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest().upper()


def sha256_hex_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest().upper()


def today_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def provjeri_datoteku(path: Path) -> list[tuple[str, str]]:
    errors: list[tuple[str, str]] = []

    name_match = PATTERN_DATOTEKA.match(path.name)
    expected_oznaka = str(int(name_match.group(1))) if name_match else None

    raw_bytes = path.read_bytes()
    disk_hash = sha256_hex_bytes(raw_bytes)

    try:
        payload = json.loads(raw_bytes.decode("utf-8"))
    except Exception as exc:
        errors.append(("(json)", f"neispravan JSON: {exc}"))
        return errors

    for key in ["akt", "clanak", "verzija", "izvori", "integritet"]:
        if key not in payload:
            errors.append((key, "nedostaje top-level polje"))

    clanak = payload.get("clanak")
    if not isinstance(clanak, dict):
        errors.append(("clanak", "polje mora biti objekt"))
    else:
        struktura = clanak.get("struktura")
        if not isinstance(struktura, dict):
            errors.append(("clanak.struktura", "polje mora biti objekt"))
        else:
            stavci = struktura.get("stavci")
            if not isinstance(stavci, list):
                errors.append(("clanak.struktura.stavci", "polje mora biti lista"))

        oznaka = clanak.get("oznaka")
        if expected_oznaka is not None and str(oznaka) != expected_oznaka:
            errors.append(
                (
                    "clanak.oznaka",
                    f"ne odgovara nazivu datoteke ({path.name} -> očekivano {expected_oznaka}, dobiveno {oznaka})",
                )
            )

        tekst = clanak.get("tekst")
        if not isinstance(tekst, str):
            errors.append(("clanak.tekst", "polje mora biti string"))

    verzija = payload.get("verzija")
    if isinstance(verzija, dict):
        stanje_na_dan = verzija.get("stanje_na_dan")
        if not isinstance(stanje_na_dan, str) or PATTERN_DATUM.fullmatch(stanje_na_dan) is None:
            errors.append(("verzija.stanje_na_dan", "format mora biti DD.MM.YYYY."))

        datum_provjere = verzija.get("datum_provjere")
        if not isinstance(datum_provjere, str) or PATTERN_DATUM.fullmatch(datum_provjere) is None:
            errors.append(("verzija.datum_provjere", "format mora biti DD.MM.YYYY."))
    else:
        errors.append(("verzija", "polje mora biti objekt"))

    izvori = payload.get("izvori")
    if isinstance(izvori, dict):
        operativni = izvori.get("operativni_izvor")
        if not isinstance(operativni, dict):
            errors.append(("izvori.operativni_izvor", "polje mora biti objekt"))
        else:
            if operativni.get("naziv") != "zakon.hr":
                errors.append(("izvori.operativni_izvor.naziv", "vrijednost mora biti 'zakon.hr'"))

        status_sidra = izvori.get("status_sidra")
        if status_sidra not in DOZVOLJENI_STATUSI:
            errors.append(
                (
                    "izvori.status_sidra",
                    "vrijednost mora biti jedno od: puno, djelomicno, nema",
                )
            )
    else:
        errors.append(("izvori", "polje mora biti objekt"))

    integritet = payload.get("integritet")
    if isinstance(integritet, dict):
        expected_sha_teksta = None
        clanak_payload = payload.get("clanak")
        if isinstance(clanak_payload, dict) and isinstance(clanak_payload.get("tekst"), str):
            expected_sha_teksta = sha256_hex_text(clanak_payload["tekst"])

        sha_teksta = integritet.get("sha256_teksta")
        if expected_sha_teksta is not None and sha_teksta != expected_sha_teksta:
            errors.append(
                (
                    "integritet.sha256_teksta",
                    f"ne odgovara tekstu članka (očekivano {expected_sha_teksta}, dobiveno {sha_teksta})",
                )
            )

        sha_datoteke = integritet.get("sha256_datoteke")
        if sha_datoteke != disk_hash:
            errors.append(
                (
                    "integritet.sha256_datoteke",
                    f"ne odgovara hashu datoteke na disku (očekivano {disk_hash}, dobiveno {sha_datoteke})",
                )
            )
    else:
        errors.append(("integritet", "polje mora biti objekt"))

    return errors


def zapisi_izvjestaj(
    ukupno: int,
    proslo: int,
    palo: int,
    greske_po_datoteci: dict[str, list[tuple[str, str]]],
) -> None:
    lines = [
        "# Izvještaj validacije NORMA JSON (Ustav RH)",
        "",
        "Agent: Agent provjere usklađenosti",
        "",
        f"- Datum: {today_hr()}",
        f"- Broj provjerenih datoteka: {ukupno}",
        f"- Broj prošlo: {proslo}",
        f"- Broj palo: {palo}",
        "",
        "## Lista grešaka",
        "",
    ]

    if not greske_po_datoteci:
        lines.append("- Nema grešaka.")
    else:
        for fname in sorted(greske_po_datoteci.keys()):
            lines.append(f"### {fname}")
            lines.append("")
            for polje, razlog in greske_po_datoteci[fname]:
                lines.append(f"- Polje `{polje}`: {razlog}")
            lines.append("")

    lines.append("## Zaključak")
    lines.append("")
    lines.append("- PROLAZI GATE" if palo == 0 else "- NE PROLAZI GATE")
    lines.append("")

    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    files = sorted(NORME_DIR.glob("clanak_*.json"))
    greske_po_datoteci: dict[str, list[tuple[str, str]]] = defaultdict(list)

    for file_path in files:
        errors = provjeri_datoteku(file_path)
        if errors:
            greske_po_datoteci[file_path.name].extend(errors)

    ukupno = len(files)
    palo = len(greske_po_datoteci)
    proslo = ukupno - palo

    zapisi_izvjestaj(ukupno=ukupno, proslo=proslo, palo=palo, greske_po_datoteci=greske_po_datoteci)

    print(f"Provjereno: {ukupno} | Prošlo: {proslo} | Palo: {palo}")
    return 0 if palo == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
