from __future__ import annotations

import json
import re
from datetime import datetime
from html import unescape
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
NN_ROOT = ROOT / "izvori" / "dokazno" / "narodne_novine"
KONTROLA_IZVJESTAJ = NN_ROOT / "IZVJESTAJ_KONTROLE_ARHIVE.md"


def datum_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def status_akta_iz_izvjestaja(slug: str) -> str | None:
    if not KONTROLA_IZVJESTAJ.exists():
        return None

    lines = KONTROLA_IZVJESTAJ.read_text(encoding="utf-8").splitlines()
    sekcija = None
    slug_lc = slug.lower()

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("### "):
            sekcija = stripped.replace("### ", "").strip().upper()
            continue

        if not stripped.startswith("-"):
            continue

        item = stripped.lstrip("-").strip()
        if not item or "Nema aktova" in item:
            continue

        kandidat_slug = item.split("|", 1)[0].strip().lower()
        if kandidat_slug == slug_lc:
            return sekcija

    return None


def ucitaj_meta(akt_slug: str) -> dict:
    meta_path = NN_ROOT / akt_slug / "meta.json"
    if not meta_path.exists():
        raise RuntimeError(f"Nedostaje meta.json: {meta_path}")
    return json.loads(meta_path.read_text(encoding="utf-8-sig"))


def ucitaj_html_izvor(akt_slug: str) -> tuple[Path, str]:
    akt_dir = NN_ROOT / akt_slug
    html_path = akt_dir / "izvor_nn.html"
    if not html_path.exists():
        raise RuntimeError(f"Nedostaje HTML izvor: {html_path}")
    html = html_path.read_text(encoding="utf-8", errors="ignore")
    return html_path, html


def html_u_linije(html: str) -> list[str]:
    text = re.sub(r"<script\b[^>]*>.*?</script>", " ", html, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r"<style\b[^>]*>.*?</style>", " ", text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r"<(br|/p|/div|/li|/h1|/h2|/h3|/h4|/h5|/h6)\b[^>]*>", "\n", text, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>", " ", text)
    text = unescape(text)
    text = text.replace("\u00a0", " ")
    text = text.replace("\r", "\n")
    text = re.sub(r"\n{2,}", "\n", text)

    lines = []
    for raw_line in text.split("\n"):
        line = re.sub(r"\s+", " ", raw_line).strip()
        if line:
            lines.append(line)
    return lines


def parsiraj_clanke(lines: list[str]) -> tuple[list[dict], list[str]]:
    pattern = re.compile(r"^\s*[ČC]lanak\s+(\d+)(?:\.)?(?=\s|$)\s*(.*)$", flags=re.IGNORECASE)
    clanci: list[dict] = []
    upozorenja: list[str] = []
    vidjeni_brojevi: set[int] = set()

    current_num: int | None = None
    current_parts: list[str] = []

    def zavrsi_trenutni() -> None:
        nonlocal current_num, current_parts
        if current_num is None:
            return
        tekst = re.sub(r"\s+", " ", " ".join(current_parts)).strip()
        if not tekst:
            tekst = f"Članak {current_num}."
            upozorenja.append(f"Članak {current_num} nema izdvojen tekst; upisan je samo marker članka.")

        clanci.append(
            {
                "broj": current_num,
                "naslov": None,
                "tekst": tekst,
                "struktura": {
                    "stavci": None,
                },
            }
        )
        if current_num in vidjeni_brojevi:
            upozorenja.append(f"Broj članka {current_num} pojavljuje se više puta u izvoru.")
        vidjeni_brojevi.add(current_num)
        current_num = None
        current_parts = []

    for line in lines:
        m = pattern.match(line)
        if m:
            zavrsi_trenutni()
            current_num = int(m.group(1))
            ostatak = m.group(2).strip()
            if ostatak:
                current_parts.append(ostatak)
            continue

        if current_num is not None:
            current_parts.append(line)

    zavrsi_trenutni()

    if not clanci:
        upozorenja.append("Nije pronađen nijedan članak po markeru 'Članak <broj>'.")

    return clanci, upozorenja


def izradi_strukturu(meta: dict, akt_slug: str, clanci: list[dict]) -> dict:
    return {
        "akt": {
            "slug": akt_slug,
            "naziv": meta.get("naziv_akta"),
            "vrsta": meta.get("vrsta_akta"),
            "jurisdikcija": "RH",
            "jezik": "hr",
        },
        "izvor": {
            "url": meta.get("url"),
            "datum_pristupa": meta.get("datum_pristupa"),
            "tip_sadrzaja": meta.get("tip_sadrzaja"),
            "sha256_datoteke": meta.get("sha256_datoteke"),
            "oznaka_akta": meta.get("oznaka_akta"),
        },
        "parsiranje": {
            "datum_parsiranja": datum_hr(),
            "broj_clanaka": len(clanci),
        },
        "clanci": clanci,
    }


def zapisi_izvjestaj(akt_slug: str, clanci: list[dict], upozorenja: list[str], report_path: Path) -> None:
    prvih_10 = [str(c["broj"]) for c in clanci[:10]]
    lines = [
        "# Izvještaj parsiranja NN",
        "",
        f"- Datum: {datum_hr()}",
        f"- akt_slug: {akt_slug}",
        f"- Broj pronađenih članaka: {len(clanci)}",
        f"- Prvih 10 brojeva članaka: {', '.join(prvih_10) if prvih_10 else 'nema'}",
        "",
        "## Upozorenja",
        "",
    ]

    if upozorenja:
        for w in upozorenja:
            lines.append(f"- {w}")
    else:
        lines.append("- Nema upozorenja.")

    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    akt_slug = "ustav_rh"
    if len(sys.argv) >= 2 and sys.argv[1].strip():
        akt_slug = sys.argv[1].strip().lower()

    status = status_akta_iz_izvjestaja(akt_slug)
    if status != "OK":
        raise RuntimeError(
            f"Gate blokada: akt_slug '{akt_slug}' nema status OK u kontroli arhive (status: {status})."
        )

    meta = ucitaj_meta(akt_slug)
    _, html = ucitaj_html_izvor(akt_slug)

    lines = html_u_linije(html)
    clanci, upozorenja = parsiraj_clanke(lines)

    akt_dir = NN_ROOT / akt_slug
    struktura_path = akt_dir / "struktura_nn.json"
    report_path = akt_dir / "IZVJESTAJ_PARSIRANJA_NN.md"

    struktura = izradi_strukturu(meta=meta, akt_slug=akt_slug, clanci=clanci)
    struktura_path.write_text(json.dumps(struktura, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    zapisi_izvjestaj(akt_slug=akt_slug, clanci=clanci, upozorenja=upozorenja, report_path=report_path)

    print(f"OK: parsirano {len(clanci)} članaka")
    print(f"Izlaz: {struktura_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
