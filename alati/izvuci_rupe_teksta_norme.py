from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NORME_DIR = ROOT / "baza_zakona" / "norme" / "ustav_rh"
REPORT_PATH = NORME_DIR / "IZVJESTAJ_RUPE_TEKSTA.md"


def datum_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def razlog_teksta(vrijednost: object) -> str | None:
    if vrijednost is None:
        return "null"
    if isinstance(vrijednost, str) and vrijednost.strip() == "":
        return "prazno"
    return None


def main() -> int:
    files = sorted(NORME_DIR.glob("clanak_*.json"))
    rupe: list[tuple[str, str, str]] = []

    for path in files:
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            rupe.append((path.name, "(nepoznato)", "neispravan JSON"))
            continue

        clanak = payload.get("clanak")
        oznaka = "(nepoznato)"
        tekst = None

        if isinstance(clanak, dict):
            oznaka = str(clanak.get("oznaka", "(nepoznato)"))
            tekst = clanak.get("tekst")

        razlog = razlog_teksta(tekst)
        if razlog is not None:
            rupe.append((path.name, oznaka, razlog))

    lines = [
        "# Izvještaj rupa teksta NORMA (Ustav RH)",
        "",
        f"- Datum: {datum_hr()}",
        f"- Broj pregledanih datoteka: {len(files)}",
        f"- Broj rupa (bez teksta): {len(rupe)}",
        "",
        "## Lista rupa",
        "",
    ]

    if not rupe:
        lines.append("- Nema rupa bez teksta.")
    else:
        for naziv, oznaka, razlog in rupe:
            lines.append(f"- {naziv} | {oznaka} | {razlog}")

    lines.append("")
    lines.append("## Zaključak")
    lines.append("")
    lines.append(f"- ZA DOPUNU IZ NN: {len(rupe)} članaka")
    lines.append("")

    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")

    print(f"Rupe: {len(rupe)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
