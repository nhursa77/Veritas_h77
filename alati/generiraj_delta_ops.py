#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
import unicodedata
from datetime import datetime, timezone
from pathlib import Path


def _normalize_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    without_diacritics = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    return without_diacritics.lower()


def _excerpt_hash_12(normalized_text: str, start: int, end: int) -> str:
    left = max(0, start - 160)
    right = min(len(normalized_text), end + 160)
    excerpt = normalized_text[left:right].strip()
    digest = hashlib.sha256(excerpt.encode("utf-8")).hexdigest()
    return digest[:12]


def _infer_target_article(normalized_text: str, match_start: int, fallback_article: int | None) -> int | None:
    probe_start = max(0, match_start - 220)
    context = normalized_text[probe_start:match_start]

    back_refs = list(re.finditer(r"(?:u\s+clanku|clanak)\s+(\d{1,4})", context, flags=re.IGNORECASE))
    if back_refs:
        return int(back_refs[-1].group(1))
    return fallback_article


def _safe_int(value: object) -> int | None:
    if isinstance(value, int):
        return value
    if isinstance(value, str) and value.isdigit():
        return int(value)
    return None


def _select_source_doc(payload: dict, akt_slug: str) -> dict:
    docs = payload.get("dokumenti")
    if not isinstance(docs, list) or not docs:
        raise ValueError("source-json nema polje 'dokumenti' ili je prazno")

    preferred_id = f"{akt_slug}_procisceni"
    for doc in docs:
        if isinstance(doc, dict) and str(doc.get("doc_id", "")) == preferred_id:
            return doc

    for doc in docs:
        if isinstance(doc, dict) and str(doc.get("doc_id", "")).startswith(akt_slug):
            return doc

    first = docs[0]
    if not isinstance(first, dict):
        raise ValueError("prvi dokument u source-json nije objekt")
    return first


def _parse_ops_from_article(clanak: dict) -> list[dict]:
    text = str(clanak.get("tekst") or "")
    normalized = _normalize_text(text)
    fallback_article = _safe_int(clanak.get("broj"))

    ops: list[dict] = []

    insert_after_matches: list[tuple[int, int, re.Match[str]]] = []
    rx_insert_after = re.compile(
        r"iza\s+clanka\s+(\d{1,4})\s+dodaje\s+se\s+clanak\s+(\d{1,4})",
        flags=re.IGNORECASE,
    )
    for match in rx_insert_after.finditer(normalized):
        start, end = match.span()
        insert_after_matches.append((start, end, match))
        ops.append(
            {
                "_start": start,
                "op": "insert_article_after",
                "target_article": int(match.group(2)),
                "ref_article": int(match.group(1)),
                "note": None,
                "excerpt_hash": _excerpt_hash_12(normalized, start, end),
            }
        )

    rx_u_clanku = re.compile(r"u\s+clanku\s+(\d{1,4})", flags=re.IGNORECASE)
    for match in rx_u_clanku.finditer(normalized):
        start, end = match.span()
        ops.append(
            {
                "_start": start,
                "op": "modify_article",
                "target_article": int(match.group(1)),
                "note": None,
                "excerpt_hash": _excerpt_hash_12(normalized, start, end),
            }
        )

    rx_insert = re.compile(r"dodaje\s+se\s+clanak\s+(\d{1,4})", flags=re.IGNORECASE)
    for match in rx_insert.finditer(normalized):
        start, end = match.span()
        overlaps_insert_after = any(start < ia_end and end > ia_start for ia_start, ia_end, _ in insert_after_matches)
        if overlaps_insert_after:
            continue
        ops.append(
            {
                "_start": start,
                "op": "insert_article",
                "target_article": int(match.group(1)),
                "note": None,
                "excerpt_hash": _excerpt_hash_12(normalized, start, end),
            }
        )

    rx_repeal_1 = re.compile(r"clanak\s+(\d{1,4})\s+brise\s+se", flags=re.IGNORECASE)
    rx_repeal_2 = re.compile(r"brise\s+se\s+clanak\s+(\d{1,4})", flags=re.IGNORECASE)
    for regex in (rx_repeal_1, rx_repeal_2):
        for match in regex.finditer(normalized):
            start, end = match.span()
            ops.append(
                {
                    "_start": start,
                    "op": "repeal_article",
                    "target_article": int(match.group(1)),
                    "note": None,
                    "excerpt_hash": _excerpt_hash_12(normalized, start, end),
                }
            )

    rx_word_replace = re.compile(r"rijec[^.\n]{0,240}?zamjenjuje\s+se", flags=re.IGNORECASE)
    rx_stavak_change = re.compile(r"stavak[^.\n]{0,240}?mijenja\s+se", flags=re.IGNORECASE)
    for regex, note in (
        (rx_word_replace, "word_replacement"),
        (rx_stavak_change, "paragraph_change"),
    ):
        for match in regex.finditer(normalized):
            start, end = match.span()
            inferred = _infer_target_article(normalized, start, fallback_article)
            ops.append(
                {
                    "_start": start,
                    "op": "modify_article",
                    "target_article": inferred,
                    "note": note,
                    "excerpt_hash": _excerpt_hash_12(normalized, start, end),
                }
            )

    ops.sort(key=lambda item: int(item.get("_start", 0)))
    cleaned: list[dict] = []
    for item in ops:
        cleaned.append(
            {
                "op": item["op"],
                "target_article": item.get("target_article"),
                "ref_article": item.get("ref_article"),
                "note": item.get("note"),
                "excerpt_hash": item["excerpt_hash"],
            }
        )
    return cleaned


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generira delta_ops.json za amandmanski akt.")
    parser.add_argument("--akt-slug", required=True)
    parser.add_argument("--source-json", required=True)
    parser.add_argument("--out", required=True)
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    akt_slug = str(args.akt_slug).strip()
    source_json_path = Path(args.source_json)
    out_path = Path(args.out)

    if not akt_slug:
        raise ValueError("--akt-slug je obavezan")
    if not source_json_path.exists():
        raise FileNotFoundError(f"Nedostaje source-json: {source_json_path}")

    payload = json.loads(source_json_path.read_text(encoding="utf-8"))
    source_doc = _select_source_doc(payload, akt_slug=akt_slug)
    source_doc_id = str(source_doc.get("doc_id") or "")
    clanci = source_doc.get("clanci")
    if not isinstance(clanci, list):
        clanci = []

    ops: list[dict] = []
    for clanak in clanci:
        if isinstance(clanak, dict):
            ops.extend(_parse_ops_from_article(clanak))

    output_payload = {
        "akt_slug": akt_slug,
        "generated_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source_doc_id": source_doc_id,
        "ops": ops,
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(output_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK: generated delta ops ({len(ops)}) -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
