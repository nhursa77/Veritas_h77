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
    pattern = re.compile(r"^\s*[ČC]lanak\s+([\dIl]+)\s*(.*)$", flags=re.IGNORECASE)
    rimski_pattern = re.compile(r"^([IVXLCDM]{1,10})\.?\s*(.*)$", flags=re.IGNORECASE)
    clanci: list[dict] = []
    upozorenja: list[str] = []
    rimske_oznake: list[tuple[int, str]] = []
    typo_headers: list[str] = []

    current_num: int | None = None
    current_parts: list[str] = []
    current_glava_rimski: str | None = None

    def normaliziraj_broj_token(token: str) -> tuple[int | None, str | None]:
        izvorno = token.strip()
        if not izvorno:
            return None, None
        norm = izvorno.replace("I", "1").replace("l", "1")
        if not norm.isdigit():
            return None, None
        korekcija = None
        if norm != izvorno:
            korekcija = f"Članak {izvorno} -> {norm}"
        return int(norm), korekcija

    def zavrsi_trenutni() -> None:
        nonlocal current_num, current_parts, current_glava_rimski
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
                    "glava_rimski": current_glava_rimski,
                },
            }
        )
        if current_glava_rimski:
            rimske_oznake.append((current_num, current_glava_rimski))
        current_num = None
        current_parts = []
        current_glava_rimski = None

    for line in lines:
        m = pattern.match(line)
        if m:
            zavrsi_trenutni()
            broj_token = m.group(1)
            broj, korekcija = normaliziraj_broj_token(broj_token)
            if broj is None:
                continue
            current_num = broj
            if korekcija and korekcija not in typo_headers:
                typo_headers.append(korekcija)
            ostatak = m.group(2).strip()
            rimski_match = rimski_pattern.match(ostatak) if ostatak else None
            if rimski_match:
                kandidat = rimski_match.group(1).upper()
                ostatak_poslije = rimski_match.group(2).strip()
                current_glava_rimski = kandidat
                ostatak = ostatak_poslije
            if ostatak:
                current_parts.append(ostatak)
            continue

        if current_num is not None:
            current_parts.append(line)

    zavrsi_trenutni()

    if not clanci:
        upozorenja.append("Nije pronađen nijedan članak po markeru 'Članak <broj>'.")

    if rimske_oznake:
        upozorenja.append(
            f"Detektirano rimskih oznaka glava/dijelova: {len(rimske_oznake)}"
        )

    if typo_headers:
        upozorenja.append(f"Detektirano tipfelera u headerima članaka: {len(typo_headers)}")

    return clanci, upozorenja, typo_headers


def primijeni_ustav_anomaliju_c1i_u_11(akt_slug: str, clanci: list[dict], upozorenja: list[str]) -> None:
    if akt_slug != "ustav_rh":
        return

    kljucne_rijeci = [
        "Grb Republike Hrvatske",
        "Zastava Republike Hrvatske",
        "Himna je Republike Hrvatske",
    ]

    for idx, clanak in enumerate(clanci):
        broj = clanak.get("broj")
        struktura = clanak.get("struktura") if isinstance(clanak.get("struktura"), dict) else {}
        rimski = (struktura.get("glava_rimski") if isinstance(struktura, dict) else None) or ""
        tekst = str(clanak.get("tekst") or "")

        if broj != 1 or rimski.upper() != "I":
            continue

        if idx == 0 or idx + 1 >= len(clanci):
            continue

        broj_prethodni = clanci[idx - 1].get("broj")
        broj_sljedeci = clanci[idx + 1].get("broj")
        if broj_prethodni != 10 or broj_sljedeci != 12:
            continue

        pogodaka = sum(1 for k in kljucne_rijeci if k in tekst)
        if pogodaka < 2:
            continue

        clanak["broj"] = 11
        if isinstance(clanak.get("struktura"), dict):
            clanak["struktura"]["nn_korekcija"] = "ANOMALIJA_C1I_TO_C11"
            clanak["struktura"]["izvorna_glava_rimski"] = "I"
            clanak["struktura"]["glava_rimski"] = None

        upozorenja.append(
            "Korekcija: 'Članak 1 I.' između 10 i 12 mapiran je na članak 11 "
            "(ANOMALIJA_C1I_TO_C11)."
        )
        return


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


def zapisi_izvjestaj(
    akt_slug: str,
    clanci: list[dict],
    upozorenja: list[str],
    typo_headers: list[str],
    report_path: Path,
) -> None:
    prvih_10 = [str(c["broj"]) for c in clanci[:10]]
    brojevi = [str(c["broj"]) for c in clanci]
    rimski_markeri = []
    korekcije = []
    for c in clanci:
        struktura = c.get("struktura") if isinstance(c.get("struktura"), dict) else {}
        marker = struktura.get("glava_rimski") if isinstance(struktura, dict) else None
        if isinstance(marker, str) and marker.strip():
            rimski_markeri.append(f"{c['broj']}->{marker.strip().upper()}")
        if isinstance(struktura, dict) and struktura.get("nn_korekcija"):
            korekcije.append(f"{c['broj']}->{struktura.get('nn_korekcija')}")

    def chunked(values: list[str], size: int = 12) -> list[str]:
        return [", ".join(values[i : i + size]) for i in range(0, len(values), size)]

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

    lines.extend(["", "## Kontrola markera", "", "### Popis pronađenih Članak <broj>", ""])
    if brojevi:
        for row in chunked(brojevi):
            lines.append(f"- {row}")
    else:
        lines.append("- Nema pronađenih brojeva članaka.")

    lines.extend(["", "### Popis rimskih oznaka glava/dijelova", ""])
    if rimski_markeri:
        for row in chunked(rimski_markeri):
            lines.append(f"- {row}")
    else:
        lines.append("- Nema detektiranih rimskih oznaka.")

    lines.extend(["", "### Primijenjene korekcije parsera", ""])
    if korekcije:
        for row in chunked(korekcije):
            lines.append(f"- {row}")
    else:
        lines.append("- Nema primijenjenih korekcija parsera.")

    lines.extend(["", "### FOUND_TYPO_HEADERS (NN)", ""])
    if typo_headers:
        for row in chunked(typo_headers):
            lines.append(f"- {row}")
    else:
        lines.append("- Nema detektiranih tipfelera headera članka.")

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
    clanci, upozorenja, typo_headers = parsiraj_clanke(lines)
    primijeni_ustav_anomaliju_c1i_u_11(akt_slug=akt_slug, clanci=clanci, upozorenja=upozorenja)

    brojevi = [c.get("broj") for c in clanci if isinstance(c.get("broj"), int)]
    duplikati = sorted({b for b in brojevi if brojevi.count(b) > 1})
    if duplikati:
        upozorenja.append(
            "Duplikati brojeva članaka nakon korekcija: "
            + ", ".join(str(x) for x in duplikati)
        )

    akt_dir = NN_ROOT / akt_slug
    struktura_path = akt_dir / "struktura_nn.json"
    report_path = akt_dir / "IZVJESTAJ_PARSIRANJA_NN.md"

    struktura = izradi_strukturu(meta=meta, akt_slug=akt_slug, clanci=clanci)
    struktura_path.write_text(json.dumps(struktura, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    zapisi_izvjestaj(
        akt_slug=akt_slug,
        clanci=clanci,
        upozorenja=upozorenja,
        typo_headers=typo_headers,
        report_path=report_path,
    )

    print(f"OK: parsirano {len(clanci)} članaka")
    print(f"Izlaz: {struktura_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
