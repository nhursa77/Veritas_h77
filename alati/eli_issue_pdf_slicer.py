from __future__ import annotations

import argparse
import re
import sys
import unicodedata
from pathlib import Path


DEFAULT_STOP_ANCHORS = [
    "ZAKON O",
    "PRAVILNIK O",
    "ODLUKA O",
    "UREDBA O",
]

ARTICLE_RX = re.compile(r"\b[ČC]lanak\s+(\d{1,4})\b", flags=re.IGNORECASE)


def _norm(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    without_diacritics = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    return without_diacritics.upper().strip()


def _extract_text(pdf_path: Path) -> str:
    try:
        from pypdf import PdfReader
    except Exception as exc:
        raise RuntimeError("Nedostaje Python paket 'pypdf'.") from exc

    reader = PdfReader(str(pdf_path))
    pages: list[str] = []
    for page in reader.pages:
        pages.append(page.extract_text() or "")

    text = "\n\n".join(pages)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    return text


def _find_anchor_line(lines: list[str], title_anchor: str) -> int:
    title_norm = _norm(title_anchor)
    hits = [idx for idx, line in enumerate(lines) if title_norm in _norm(line)]
    if len(hits) != 1:
        raise ValueError(f"TITLE_ANCHOR_MATCH_COUNT={len(hits)}")
    return hits[0]


def _line_is_heading_candidate(line: str) -> bool:
    stripped = re.sub(r"\s+", " ", line.strip())
    if len(stripped) < 8:
        return False

    letters = [ch for ch in stripped if ch.isalpha()]
    if not letters:
        return False

    uppercase_ratio = sum(1 for ch in letters if ch.isupper()) / len(letters)
    return uppercase_ratio >= 0.9


def _slice_segment(lines: list[str], start_index: int, stop_anchors: list[str], title_anchor: str) -> str:
    title_norm = _norm(title_anchor)
    stop_norms = [_norm(x) for x in stop_anchors if x.strip()]

    selected: list[str] = []
    found_article = False

    for idx in range(start_index, len(lines)):
        line = lines[idx]
        normalized = _norm(line)
        if ARTICLE_RX.search(line):
            found_article = True

        if found_article and idx > start_index + 3 and _line_is_heading_candidate(line):
            if normalized != title_norm and any(anchor in normalized for anchor in stop_norms):
                break

        selected.append(line)

    segment = "\n".join(selected)
    segment = re.sub(r"\n{3,}", "\n\n", segment)
    segment = "\n".join(re.sub(r"[ \t]+", " ", ln).strip() for ln in segment.split("\n"))
    return re.sub(r"\n{3,}", "\n\n", segment).strip()


def _extract_article_blocks(segment: str) -> list[tuple[int, str]]:
    matches = list(ARTICLE_RX.finditer(segment))
    if not matches:
        return []

    blocks: list[tuple[int, str]] = []
    for i, match in enumerate(matches):
        broj = int(match.group(1))
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(segment)
        raw_block = segment[start:end].strip()
        raw_block = re.sub(r"\s+", " ", raw_block)

        # Normaliziraj heading u oblik: Članak N.
        raw_block = re.sub(r"^([ČC]lanak\s+\d{1,4})\b\.?", fr"Članak {broj}.", raw_block, flags=re.IGNORECASE)
        blocks.append((broj, raw_block.strip()))

    return blocks


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Slicer ELI issue PDF -> TXT segment akta")
    parser.add_argument("--issue_pdf_path", required=True)
    parser.add_argument("--title_anchor", required=True)
    parser.add_argument("--out_txt_path", required=True)
    parser.add_argument("--stop_anchors", nargs="*", default=DEFAULT_STOP_ANCHORS)
    return parser


def main() -> int:
    args = build_parser().parse_args()

    issue_pdf_path = Path(args.issue_pdf_path)
    out_txt_path = Path(args.out_txt_path)
    title_anchor = str(args.title_anchor).strip()
    stop_anchors = [str(x) for x in (args.stop_anchors or DEFAULT_STOP_ANCHORS)]

    if not issue_pdf_path.exists():
        print(f"ERROR: Nedostaje PDF: {issue_pdf_path}")
        return 2

    if not title_anchor:
        print("ERROR: title_anchor je prazan")
        return 2

    try:
        text = _extract_text(issue_pdf_path)
        lines = text.split("\n")
        anchor_index = _find_anchor_line(lines, title_anchor=title_anchor)
        segment = _slice_segment(lines, start_index=anchor_index, stop_anchors=stop_anchors, title_anchor=title_anchor)
        blocks = _extract_article_blocks(segment)
    except ValueError as exc:
        print(f"ERROR: {exc}")
        return 12
    except Exception as exc:
        print(f"ERROR: {exc}")
        return 1

    if not blocks:
        print("ERROR: ARTICLE_BLOCKS_COUNT=0")
        return 12

    out_txt_path.parent.mkdir(parents=True, exist_ok=True)
    lines_out: list[str] = []
    for _, block in blocks:
        lines_out.append(block)
        lines_out.append("")

    out_txt_path.write_text("\n".join(lines_out).strip() + "\n", encoding="utf-8")
    print(f"OK: title_anchor={title_anchor}")
    print(f"OK: article_blocks={len(blocks)}")
    print(f"OUT: {out_txt_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
