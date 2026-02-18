from __future__ import annotations

import json
import re
import subprocess
from datetime import datetime
from html import unescape
from pathlib import Path
import sys
import unicodedata
from urllib.request import urlopen


ROOT = Path(__file__).resolve().parents[1]
NN_ROOT = ROOT / "izvori" / "dokazno" / "narodne_novine"
KONTROLA_IZVJESTAJ = NN_ROOT / "IZVJESTAJ_KONTROLE_ARHIVE.md"

ARTICLE_HEADER_RX = re.compile(r"\b[ČC]lanak\s+(\d{1,4})\b", flags=re.IGNORECASE)
STOP_HEADING_KEYWORDS = ("ZAKON", "ODLUKA", "PRAVILNIK", "UREDBA", "RJEŠENJE", "RJESENJE")
SLICER_SCRIPT = ROOT / "alati" / "eli_issue_pdf_slicer.py"


class PdfFallbackGuardrailError(RuntimeError):
    pass


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


def _normaliziraj_za_match(text: str) -> str:
    normalized = unicodedata.normalize("NFKD", text)
    without_diacritics = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    return without_diacritics.upper()


def _html_je_nedostupan_ili_bez_clanaka(html: str) -> bool:
    normalized = _normaliziraj_za_match(html)
    if "SADRZAJ JE NEDOSTUPAN" in normalized:
        return True
    if ARTICLE_HEADER_RX.search(html) is None:
        return True
    return False


def _derive_eli_pdf_url(meta: dict) -> str | None:
    explicit = str(meta.get("eli_pdf_url") or "").strip()
    if explicit:
        return explicit

    oznaka = str(meta.get("oznaka_akta") or "")
    m = re.search(r"NN\s*([0-9]{1,3})/([0-9]{2,4})", oznaka, flags=re.IGNORECASE)
    if m is None:
        return None

    broj = int(m.group(1))
    godina_raw = m.group(2)
    godina = int(godina_raw) if len(godina_raw) == 4 else int(f"20{godina_raw}")
    return f"https://narodne-novine.nn.hr/eli/sluzbeni/{godina}/{broj}/pdf"


def _download_pdf(url: str, out_path: Path) -> None:
    with urlopen(url, timeout=90) as response:
        payload = response.read()
    if not payload.startswith(b"%PDF"):
        raise RuntimeError(f"ELI URL nije vratio PDF: {url}")
    out_path.write_bytes(payload)


def _run_pdf_slicer(pdf_path: Path, txt_path: Path, meta: dict, akt_slug: str) -> tuple[str, list[int]]:
    if not SLICER_SCRIPT.exists():
        raise RuntimeError(f"Nedostaje slicer skripta: {SLICER_SCRIPT}")

    title_anchor = str(meta.get("pdf_title_anchor") or "").strip()
    if not title_anchor:
        naziv = str(meta.get("naziv_akta") or akt_slug).strip()
        title_anchor = _normaliziraj_za_match(naziv)

    stop_anchors_raw = meta.get("pdf_stop_anchors")
    stop_anchors: list[str] = []
    if isinstance(stop_anchors_raw, list):
        stop_anchors = [str(x).strip() for x in stop_anchors_raw if str(x).strip()]
    if not stop_anchors:
        stop_anchors = list(STOP_HEADING_KEYWORDS)

    cmd = [
        sys.executable,
        str(SLICER_SCRIPT),
        "--issue_pdf_path",
        str(pdf_path),
        "--title_anchor",
        title_anchor,
        "--out_txt_path",
        str(txt_path),
        "--stop_anchors",
        *stop_anchors,
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode == 12:
        detail = (result.stdout or result.stderr or "").strip()
        raise PdfFallbackGuardrailError(f"FOUND_MULTIPLE_ACTS_IN_PDF: True | {detail}")
    if result.returncode != 0:
        detail = (result.stdout or result.stderr or "").strip()
        raise RuntimeError(f"Slicer nije uspio (exit {result.returncode}): {detail}")

    segment = txt_path.read_text(encoding="utf-8")
    brojevi = [int(m.group(1)) for m in ARTICLE_HEADER_RX.finditer(segment)]
    if not brojevi:
        raise RuntimeError("Slicer nije pronašao nijedan članak u segmentu.")

    return segment, brojevi


def _ensure_parsable_html_from_pdf_if_needed(akt_slug: str, meta: dict, html_path: Path, html: str) -> tuple[str, list[str]]:
    warnings: list[str] = []
    if not _html_je_nedostupan_ili_bez_clanaka(html):
        return html, warnings

    pdf_url = _derive_eli_pdf_url(meta)
    if not pdf_url:
        raise RuntimeError("NN HTML je nedostupan, a eli_pdf_url nije definiran niti je moguće derivirati URL iz oznake_akta.")

    akt_dir = NN_ROOT / akt_slug
    pdf_path = akt_dir / "izvor_nn_issue.pdf"
    txt_path = akt_dir / "izvor_nn_issue.txt"

    _download_pdf(pdf_url, pdf_path)
    segment, brojevi = _run_pdf_slicer(pdf_path=pdf_path, txt_path=txt_path, meta=meta, akt_slug=akt_slug)

    pseudo_html = (
        "<html><body>\n"
        "<h1>Narodne novine — ELI PDF fallback</h1>\n"
        f"<p>Akt: {meta.get('naziv_akta') or akt_slug}</p>\n"
        f"<p>ELI PDF: {pdf_url}</p>\n"
        "<pre>\n"
        f"{segment}\n"
        "</pre>\n"
        "</body></html>\n"
    )
    html_path.write_text(pseudo_html, encoding="utf-8")

    warnings.append("NN HTML nedostupan/bez članaka: aktiviran ELI PDF fallback.")
    warnings.append(f"ELI PDF URL: {pdf_url}")
    warnings.append(f"PDF slicer broj detektiranih članaka: {len(brojevi)}")
    return pseudo_html, warnings


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


def _normaliziraj_broj_token(token: str) -> tuple[int | None, str | None]:
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


def _detektiraj_switch_dokumenta(line: str) -> dict | None:
    clean = line.strip()
    if not clean:
        return None

    nn_match = re.search(r"NN\s*([0-9]{1,3}/[0-9]{2,4})", clean, flags=re.IGNORECASE)
    if not nn_match:
        return None

    nn_raw = nn_match.group(1)
    nn_key = nn_raw.replace("/", "_")

    if re.search(r"^Ustavni zakon", clean, flags=re.IGNORECASE):
        return {
            "doc_id": f"amandman_nn_{nn_key}",
            "tip": "amandman",
            "nn": nn_raw,
            "naslov": clean,
            "clanci": [],
        }

    if re.search(r"^Promjena Ustava", clean, flags=re.IGNORECASE):
        return {
            "doc_id": f"promjena_nn_{nn_key}",
            "tip": "promjena",
            "nn": nn_raw,
            "naslov": clean,
            "clanci": [],
        }

    return None


def parsiraj_dokumente_nn(lines: list[str], meta: dict) -> tuple[list[dict], list[str], list[str]]:
    pattern = re.compile(r"^\s*[ČC]lanak\s+([\dIl]+)\s*(.*)$", flags=re.IGNORECASE)
    rimski_pattern = re.compile(r"^([IVXLCDM]{1,10})\.?\s*(.*)$", flags=re.IGNORECASE)

    upozorenja: list[str] = []
    typo_headers: list[str] = []
    rimske_oznake: list[tuple[int, str]] = []

    akt_slug = str(meta.get("slug") or "akt").strip().lower() or "akt"
    akt_vrsta = str(meta.get("vrsta_akta") or "akt").strip().lower() or "akt"

    dokumenti: list[dict] = [
        {
            "doc_id": f"{akt_slug}_procisceni",
            "tip": f"{akt_vrsta}_procisceni",
            "nn": str(meta.get("oznaka_akta") or ""),
            "naslov": str(meta.get("naziv_akta") or akt_slug),
            "clanci": [],
        }
    ]
    current_doc = dokumenti[0]

    current_num: int | None = None
    current_parts: list[str] = []
    current_glava_rimski: str | None = None

    def zavrsi_trenutni() -> None:
        nonlocal current_num, current_parts, current_glava_rimski
        if current_num is None:
            return

        tekst = re.sub(r"\s+", " ", " ".join(current_parts)).strip()
        if not tekst:
            tekst = f"Članak {current_num}."
            upozorenja.append(f"Članak {current_num} nema izdvojen tekst; upisan je samo marker članka.")

        current_doc["clanci"].append(
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
        switch_doc = _detektiraj_switch_dokumenta(line)
        if switch_doc is not None:
            zavrsi_trenutni()
            postojeci = next((d for d in dokumenti if d.get("doc_id") == switch_doc["doc_id"]), None)
            if postojeci is None:
                dokumenti.append(switch_doc)
                current_doc = switch_doc
            else:
                current_doc = postojeci
            continue

        m = pattern.match(line)
        if m:
            zavrsi_trenutni()
            broj_token = m.group(1)
            broj, korekcija = _normaliziraj_broj_token(broj_token)
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

    ukupno = sum(len(d.get("clanci", [])) for d in dokumenti)
    if ukupno == 0:
        upozorenja.append("Nije pronađen nijedan članak po markeru 'Članak <broj>'.")

    if rimske_oznake:
        upozorenja.append(f"Detektirano rimskih oznaka glava/dijelova: {len(rimske_oznake)}")

    if typo_headers:
        upozorenja.append(f"Detektirano tipfelera u headerima članaka: {len(typo_headers)}")

    return dokumenti, upozorenja, typo_headers


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


def izradi_strukturu_dokumenti(meta: dict, akt_slug: str, dokumenti: list[dict]) -> dict:
    return {
        "glavni_akt": {
            "slug": akt_slug,
            "naziv": meta.get("naziv_akta"),
        },
        "dokumenti": dokumenti,
        "izvor": {
            "url": meta.get("url"),
            "datum_pristupa": meta.get("datum_pristupa"),
            "tip_sadrzaja": meta.get("tip_sadrzaja"),
            "sha256_datoteke": meta.get("sha256_datoteke"),
            "oznaka_akta": meta.get("oznaka_akta"),
        },
        "parsiranje": {
            "datum_parsiranja": datum_hr(),
            "broj_dokumenata": len(dokumenti),
            "broj_clanaka_ukupno": sum(len(d.get("clanci", [])) for d in dokumenti),
        },
    }


def zapisi_izvjestaj(
    akt_slug: str,
    clanci: list[dict],
    dokumenti: list[dict],
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

    lines.extend(["", "### Document split summary", ""])
    doc_ids = [str(d.get("doc_id")) for d in dokumenti if d.get("doc_id")]
    if doc_ids:
        lines.append(f"- DOC_IDS: {', '.join(doc_ids)}")
    else:
        lines.append("- DOC_IDS: ustav_rh_procisceni")

    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    akt_slug = "ustav_rh"
    if len(sys.argv) >= 2 and sys.argv[1].strip():
        akt_slug = sys.argv[1].strip().lower()

    status = status_akta_iz_izvjestaja(akt_slug)
    if status not in {"OK", None}:
        raise RuntimeError(
            f"Gate blokada: akt_slug '{akt_slug}' nema status OK u kontroli arhive (status: {status})."
        )

    meta = ucitaj_meta(akt_slug)
    html_path, html = ucitaj_html_izvor(akt_slug)
    try:
        html, fallback_warnings = _ensure_parsable_html_from_pdf_if_needed(
            akt_slug=akt_slug,
            meta=meta,
            html_path=html_path,
            html=html,
        )
    except PdfFallbackGuardrailError as exc:
        print(f"ERROR: {exc}")
        return 12

    lines = html_u_linije(html)
    dokumenti, upozorenja, typo_headers = parsiraj_dokumente_nn(lines, meta=meta)
    upozorenja.extend(fallback_warnings)

    doc_procisceni = next(
        (d for d in dokumenti if d.get("doc_id") == f"{akt_slug}_procisceni"),
        {"clanci": []},
    )
    clanci = doc_procisceni.get("clanci", [])
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
    struktura_docs_path = akt_dir / "struktura_nn_dokumenti.json"
    report_path = akt_dir / "IZVJESTAJ_PARSIRANJA_NN.md"

    struktura = izradi_strukturu(meta=meta, akt_slug=akt_slug, clanci=clanci)
    struktura_docs = izradi_strukturu_dokumenti(meta=meta, akt_slug=akt_slug, dokumenti=dokumenti)
    struktura_path.write_text(json.dumps(struktura, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    struktura_docs_path.write_text(json.dumps(struktura_docs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    zapisi_izvjestaj(
        akt_slug=akt_slug,
        clanci=clanci,
        dokumenti=dokumenti,
        upozorenja=upozorenja,
        typo_headers=typo_headers,
        report_path=report_path,
    )

    print(f"OK: parsirano {len(clanci)} članaka (procisceni), dokumenata: {len(dokumenti)}")
    print(f"Izlaz: {struktura_path}")
    print(f"Izlaz (dokumenti): {struktura_docs_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
