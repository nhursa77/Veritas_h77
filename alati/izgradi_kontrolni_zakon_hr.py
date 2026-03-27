#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
from datetime import datetime
from pathlib import Path
from urllib.request import Request, urlopen


def fetch_html(url: str) -> str:
    req = Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        },
    )
    with urlopen(req, timeout=60) as response:  # nosec B310
        raw = response.read()
    return raw.decode("utf-8", errors="ignore")


def clean_html_to_lines(raw_html: str) -> list[str]:
    text = re.sub(r"(?is)<script[^>]*>.*?</script>", " ", raw_html)
    text = re.sub(r"(?is)<style[^>]*>.*?</style>", " ", text)
    text = re.sub(r"(?is)<noscript[^>]*>.*?</noscript>", " ", text)
    text = re.sub(r"(?i)<br\s*/?>", "\n", text)
    text = re.sub(r"(?i)</(p|li|h1|h2|h3|h4|h5|h6|div|section|article|tr)>", "\n", text)
    text = re.sub(r"(?is)<[^>]+>", " ", text)
    text = html.unescape(text)

    lines: list[str] = []
    for line in text.splitlines():
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            lines.append(line)
    return lines


def is_noise_line(line: str) -> bool:
    lowered = line.lower()
    noise_markers = [
        "nastavkom korištenja",
        "upravljanje opcijama",
        "prijava / registracija",
        "personalizirano oglašavanje",
        "dodatne poveznice",
        "additional links",
        "copyright",
        "uživajte",
        "home icon",
        "upute",
        "uvjeti",
        "cjenik",
        "kontakt",
        "pristajem",
    ]
    return any(marker in lowered for marker in noise_markers)


def extract_articles(lines: list[str]) -> list[tuple[str, str]]:
    heading_rx = re.compile(r"^Članak\s+([0-9]+[A-Za-z]?)\.?\s*(?:\(.*\))?\s*$", re.IGNORECASE)

    articles: list[tuple[str, str]] = []
    current_no: str | None = None
    current_parts: list[str] = []

    for line in lines:
        if is_noise_line(line):
            continue

        m = heading_rx.match(line)
        if m:
            if current_no is not None:
                text = re.sub(r"\s+", " ", " ".join(current_parts)).strip()
                articles.append((current_no, text))
            current_no = m.group(1)
            current_parts = []
            continue

        if current_no is None:
            continue

        if line.startswith("#"):
            continue

        current_parts.append(line)

    if current_no is not None:
        text = re.sub(r"\s+", " ", " ".join(current_parts)).strip()
        articles.append((current_no, text))

    # Keep the first occurrence of each article number and preserve order.
    seen: set[str] = set()
    deduped: list[tuple[str, str]] = []
    for no, body in articles:
        if no in seen:
            continue
        seen.add(no)
        deduped.append((no, body))

    return deduped


def write_outputs(root: Path, akt_slug: str, naziv_akta: str, url: str, raw_html: str, articles: list[tuple[str, str]]) -> None:
    out_dir = root / "izvori" / "kontrolno" / "zakon_hr" / akt_slug
    out_dir.mkdir(parents=True, exist_ok=True)

    html_path = out_dir / f"{akt_slug}_zakon_hr.html"
    txt_path = out_dir / f"{akt_slug}_kontrolni.txt"
    meta_path = out_dir / "meta.json"

    html_path.write_text(raw_html, encoding="utf-8", newline="\n")
    html_sha = hashlib.sha256(raw_html.encode("utf-8", errors="ignore")).hexdigest()

    txt_lines: list[str] = []
    for no, body in articles:
        txt_lines.append(f"Članak {no}.")
        txt_lines.append(body)
        txt_lines.append("")
    txt_content = "\n".join(txt_lines).rstrip() + "\n"
    txt_path.write_text(txt_content, encoding="utf-8", newline="\n")

    txt_sha = hashlib.sha256(txt_content.encode("utf-8")).hexdigest()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S %z")
    meta = {
        "izvor": "zakon.hr",
        "akt_slug": akt_slug,
        "naziv_akta": naziv_akta,
        "url": url,
        "preuzeto_lokalno": now,
        "html_sha256": html_sha,
        "txt_sha256": txt_sha,
        "broj_clanaka_u_kontrolnom_txt": len(articles),
        "napomena": "Kontrolni tekst preuzet sa zakon.hr za usporedbu s NORMA JSON setom.",
    }
    meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Izgradi lokalni kontrolni zakon.hr artefakt za akt.")
    parser.add_argument("--akt-slug", required=True)
    parser.add_argument("--naziv-akta", required=True)
    parser.add_argument("--url", required=True)
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    raw_html = fetch_html(args.url)
    lines = clean_html_to_lines(raw_html)
    articles = extract_articles(lines)
    if not articles:
        print("ERROR: nije izdvojen nijedan članak iz zakon.hr sadržaja")
        return 2

    write_outputs(root, args.akt_slug, args.naziv_akta, args.url, raw_html, articles)
    print(f"KONTROLNI_SOURCE=zakon.hr")
    print(f"KONTROLNI_AKT={args.akt_slug}")
    print(f"KONTROLNI_URL={args.url}")
    print(f"KONTROLNI_CLANCI={len(articles)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
