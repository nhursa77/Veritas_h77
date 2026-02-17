from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NORME_DIR = ROOT / "baza_zakona" / "norme" / "ustav_rh"
STRUKTURA_PATH = ROOT / "izvori" / "operativno" / "zakon_hr" / "ustav_rh" / "ustav_rh_struktura.json"
NORMIRANJE_REPORT_PATH = NORME_DIR / "IZVJESTAJ_NORMIRANJA.md"
REPORT_PATH = NORME_DIR / "IZVJESTAJ_RUPE_TEKSTA.md"
TODO_PATTERN = re.compile(r"TODO:|TODO\s*-", re.IGNORECASE)


def datum_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def razlog_teksta(vrijednost: object) -> str | None:
    if vrijednost is None:
        return "null"
    if isinstance(vrijednost, str) and vrijednost == "":
        return "prazno"
    if isinstance(vrijednost, str) and vrijednost.strip() == "":
        return "whitespace"
    return None


def ucitaj_ocekivane_oznake() -> list[int]:
    payload = json.loads(STRUKTURA_PATH.read_text(encoding="utf-8"))
    oznake = set()
    for clanak in payload.get("clanci", []):
        oznaka = str(clanak.get("oznaka", "")).strip()
        if oznaka.isdigit():
            oznake.add(int(oznaka))
    return sorted(oznake)


def procitaj_normiranje_brojke() -> tuple[int | None, int | None]:
    if not NORMIRANJE_REPORT_PATH.exists():
        return (None, None)

    text = NORMIRANJE_REPORT_PATH.read_text(encoding="utf-8")
    ulaz_match = re.search(r"Broj članaka u ulazu:\s*(\d+)", text)
    gen_match = re.search(r"Broj generiranih NORMA JSON datoteka:\s*(\d+)", text)

    ulaz = int(ulaz_match.group(1)) if ulaz_match else None
    gen = int(gen_match.group(1)) if gen_match else None
    return (ulaz, gen)


def main() -> int:
    expected_oznake = ucitaj_ocekivane_oznake()
    files = sorted(NORME_DIR.glob("clanak_*.json"))

    found_by_oznaka: dict[int, str] = {}
    rupe_b: list[tuple[str, str, str]] = []
    rupe_c: list[tuple[str, str, str]] = []

    for path in files:
        match = re.fullmatch(r"clanak_(\d{4})\.json", path.name)
        if match:
            found_by_oznaka[int(match.group(1))] = path.name

        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            rupe_b.append((path.name, "(nepoznato)", "neispravan JSON"))
            continue

        clanak = payload.get("clanak")
        oznaka = "(nepoznato)"
        tekst = None

        if isinstance(clanak, dict):
            oznaka = str(clanak.get("oznaka", "(nepoznato)"))
            tekst = clanak.get("tekst")

        razlog = razlog_teksta(tekst)
        if razlog is not None:
            rupe_b.append((path.name, oznaka, razlog))
            continue

        if isinstance(tekst, str) and TODO_PATTERN.search(tekst):
            rupe_c.append((path.name, oznaka, "TODO"))

    rupe_a: list[tuple[str, str]] = []
    for oznaka_int in expected_oznake:
        if oznaka_int not in found_by_oznaka:
            rupe_a.append((str(oznaka_int), f"clanak_{oznaka_int:04d}.json"))

    broj_a = len(rupe_a)
    broj_b = len(rupe_b)
    broj_c = len(rupe_c)
    ukupno_rupe = broj_a + broj_b + broj_c

    norm_ulaz, norm_gen = procitaj_normiranje_brojke()

    lines = [
        "# Izvještaj rupa teksta NORMA (Ustav RH)",
        "",
        f"- Datum: {datum_hr()}",
        f"- Očekivano članaka iz strukture: {len(expected_oznake)}",
        f"- Nađeno datoteka u norma: {len(files)}",
        f"- Rupe A (nedostaje datoteka): {broj_a}",
        f"- Rupe B (prazno/null/whitespace): {broj_b}",
        f"- Rupe C (placeholder TODO): {broj_c}",
        f"- Ukupno rupa: {ukupno_rupe}",
        "",
        "## Usporedba s izvještajem normiranja",
        "",
    ]

    if norm_ulaz is None and norm_gen is None:
        lines.append("- Izvještaj normiranja nije pronađen ili nema čitljive brojke.")
    else:
        lines.append(f"- Normiranje (ulaz): {norm_ulaz if norm_ulaz is not None else 'n/a'}")
        lines.append(f"- Normiranje (generirano): {norm_gen if norm_gen is not None else 'n/a'}")

    lines.extend(
        [
            "",
            "## Lista rupa",
            "",
            "### A) Nedostajući članci",
            "",
        ]
    )

    if not rupe_a:
        lines.append("- Nema nedostajućih datoteka.")
    else:
        for oznaka, expected_file in rupe_a:
            lines.append(f"- čl. {oznaka} | očekivano: {expected_file}")

    lines.extend(
        [
            "",
            "### B) Prazno / null / whitespace",
            "",
        ]
    )

    if not rupe_b:
        lines.append("- Nema rupa klase B.")
    else:
        for naziv, oznaka, razlog in rupe_b:
            lines.append(f"- {naziv} | {oznaka} | {razlog}")

    lines.extend(
        [
            "",
            "### C) Placeholder tekst (TODO)",
            "",
        ]
    )

    if not rupe_c:
        lines.append("- Nema rupa klase C.")
    else:
        for naziv, oznaka, uzorak in rupe_c:
            lines.append(f"- {naziv} | {oznaka} | {uzorak}")

    lines.append("")
    lines.append("## Zaključak")
    lines.append("")
    lines.append(f"- ZA DOPUNU IZ NN: {ukupno_rupe} članaka")
    lines.append("")

    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")

    print(f"Rupe_A: {broj_a}, Rupe_B: {broj_b}, Rupe_C: {broj_c}, Ukupno: {ukupno_rupe}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
