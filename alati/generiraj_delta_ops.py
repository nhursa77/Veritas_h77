#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime
from pathlib import Path


ARTICLE_PATTERNS = [
    re.compile(r"\bčlanak\s+(\d{1,4})\b", flags=re.IGNORECASE),
    re.compile(r"\bclanak\s+(\d{1,4})\b", flags=re.IGNORECASE),
    re.compile(r"\bčl\.?\s*(\d{1,4})\b", flags=re.IGNORECASE),
    re.compile(r"\bcl\.?\s*(\d{1,4})\b", flags=re.IGNORECASE),
]


def _safe_int(value: object) -> int | None:
    if isinstance(value, int):
        return value
    if isinstance(value, str) and value.isdigit():
        return int(value)
    return None


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _extract_articles_from_text(text: str) -> set[int]:
    found: set[int] = set()
    for pattern in ARTICLE_PATTERNS:
        for match in pattern.finditer(text):
            value = _safe_int(match.group(1))
            if value is not None:
                found.add(value)
    return found


def _collect_from_sidra_dir(sidra_dir: Path) -> tuple[list[int], str]:
    clanak_files = sorted(sidra_dir.glob("clanak_*.json"))
    if not clanak_files:
        raise FileNotFoundError(f"Nedostaju clanak_*.json u sidra setu: {sidra_dir}")

    all_articles: set[int] = set()
    stanje_na_dan = ""

    for file_path in clanak_files:
        payload = _read_json(file_path)
        clanak = payload.get("clanak") or {}
        verzija = payload.get("verzija") or {}

        if not stanje_na_dan:
            raw_date = str(verzija.get("stanje_na_dan") or "").strip()
            if raw_date:
                stanje_na_dan = raw_date

        own_article = _safe_int(clanak.get("oznaka"))
        if own_article is not None:
            all_articles.add(own_article)

        text = str(clanak.get("tekst") or "")
        all_articles.update(_extract_articles_from_text(text))

    if not stanje_na_dan:
        stanje_na_dan = datetime.now().strftime("%d.%m.%Y.")

    return sorted(all_articles), stanje_na_dan

def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generira delta_ops.json za amandmanski akt.")
    parser.add_argument("--akt-slug", required=True)
    parser.add_argument("--sidra-dir", required=True)
    parser.add_argument("--out", required=True)
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    akt_slug = str(args.akt_slug).strip()
    sidra_dir = Path(args.sidra_dir)
    out_path = Path(args.out)

    if not akt_slug:
        raise ValueError("--akt-slug je obavezan")
    if not sidra_dir.exists():
        raise FileNotFoundError(f"Nedostaje sidra-dir: {sidra_dir}")

    affected_articles, stanje_na_dan = _collect_from_sidra_dir(sidra_dir)

    output_payload = {
        "akt_slug": akt_slug,
        "control_mode": "delta",
        "source": {
            "tip": "NN",
            "slug": akt_slug,
            "stanje_na_dan": stanje_na_dan,
        },
        "affected_articles": affected_articles,
        "ops": [],
        "notes": "AUTO-GENERATED MINIMAL CONTROL; ops empty until delta parser implemented.",
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(output_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK: generated minimal delta control ({len(affected_articles)} affected articles) -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
