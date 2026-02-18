#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
NN_JSON = REPO_ROOT / "izvori" / "dokazno" / "narodne_novine" / "ustav_rh" / "struktura_nn.json"
KONTROLNO_TXT = REPO_ROOT / "izvori" / "kontrolno" / "zakon_hr" / "ustav_rh" / "ustav_rh_kontrolni.txt"
NN_HTML = REPO_ROOT / "izvori" / "dokazno" / "narodne_novine" / "ustav_rh" / "izvor_nn.html"
OUT_REPORT = REPO_ROOT / "baza_zakona" / "norme" / "ustav_rh" / "IZVJESTAJ_VALIDACIJE_KONTROLNO.md"

ARTICLE_RX = re.compile(r"Članak\s+(\d+)\.", flags=re.IGNORECASE)
CONTROL_HEADER_RX = re.compile(r"(?m)^\s*Članak\s+(\d{1,3})\b")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_kontrolno_nums(text: str) -> set[int]:
    return {int(match.group(1)) for match in CONTROL_HEADER_RX.finditer(text)}


def parse_kontrolno_headers(text: str) -> list[int]:
    return [int(match.group(1)) for match in CONTROL_HEADER_RX.finditer(text)]


def parse_nn_numbers_and_texts(payload: dict) -> tuple[set[int], dict[int, str]]:
    clanci = payload.get("clanci", [])
    nn_nums: set[int] = set()
    text_by_num: dict[int, str] = {}

    for clanak in clanci:
        raw_num = clanak.get("broj")
        broj: int | None = None

        if isinstance(raw_num, int):
            broj = raw_num
        elif isinstance(raw_num, str):
            m = re.match(r"\s*(\d+)", raw_num)
            if m:
                broj = int(m.group(1))

        if broj is None:
            continue

        tekst = str(clanak.get("tekst") or "").strip()
        nn_nums.add(broj)

        if broj in text_by_num:
            if len(tekst) > len(text_by_num[broj]):
                text_by_num[broj] = tekst
        else:
            text_by_num[broj] = tekst

    return nn_nums, text_by_num


def anomaly_check_in_html(html: str) -> tuple[bool, str, dict[str, object]]:
    start_marker = "Članak 10."
    end_marker = "Članak 12."

    start_idx = html.find(start_marker)
    if start_idx < 0:
        return False, "Nije pronađen marker 'Članak 10.' u NN HTML-u.", {
            "FOUND_BETWEEN_10_12": None,
            "KEYWORDS": [],
        }

    end_idx = html.find(end_marker, start_idx + len(start_marker))
    if end_idx < 0:
        return False, "Nije pronađen marker 'Članak 12.' nakon 'Članak 10.' u NN HTML-u.", {
            "FOUND_BETWEEN_10_12": None,
            "KEYWORDS": [],
        }

    segment = html[start_idx:end_idx]
    has_heading = "Članak 1 I." in segment
    keys = [
        "Grb Republike Hrvatske",
        "Zastava Republike Hrvatske",
        "Himna je Republike Hrvatske",
    ]
    found_keys = [key for key in keys if key in segment]

    payload = {
        "FOUND_BETWEEN_10_12": "Članak 1 I." if has_heading else None,
        "KEYWORDS": found_keys,
    }

    if has_heading and len(found_keys) >= 2:
        details = ", ".join(found_keys)
        return (
            True,
            "ANOMALIJA: sadržaj čl. 11 je prisutan u HTML segmentu, "
            "ali heading je 'Članak 1 I.' -> NN parsiranje treba ručno/automatski rule. "
            f"Ključne fraze: {details}",
            payload,
        )

    if not has_heading:
        return False, "U segmentu između 'Članak 10.' i 'Članak 12.' nije pronađen heading 'Članak 1 I.'.", payload

    return False, "Heading 'Članak 1 I.' postoji, ali nije potvrđen sadržajni signal čl. 11 (>=2 ključne fraze).", payload


def norma_filename_for_number(number: int) -> str:
    return f"clanak_{number:04d}.json"


def build_report(
    ts: str,
    nn_hash: str,
    kontrolno_hash: str,
    nn_count: int,
    kontrolno_count: int,
    kontrolno_headers_count: int,
    kontrolno_first20_headers: list[int],
    kontrolno_has_10: bool,
    kontrolno_has_11: bool,
    kontrolno_has_12: bool,
    kontrolno_count_mismatch_warning: str | None,
    missing_in_nn: list[int],
    extra_in_nn: list[int],
    short_text_nn: list[int],
    short_text_meta: list[tuple[int, int, str]],
    anomaly_flag: bool,
    anomaly_note: str,
    anomaly_meta: dict[str, object],
) -> str:
    lines: list[str] = []
    lines.append("# IZVJESTAJ_VALIDACIJE_KONTROLNO")
    lines.append("")
    lines.append(f"- Timestamp: {ts}")
    lines.append(f"- NN_JSON: {NN_JSON.as_posix()}")
    lines.append(f"- KONTROLNO_TXT: {KONTROLNO_TXT.as_posix()}")
    lines.append(f"- NN_JSON_SHA256: {nn_hash}")
    lines.append(f"- KONTROLNO_TXT_SHA256: {kontrolno_hash}")
    lines.append("")

    lines.append("## SUMMARY")
    lines.append("")
    lines.append(f"- CONTROL_COUNT: {kontrolno_count}")
    lines.append(f"- CONTROL_HEADERS_COUNT: {kontrolno_headers_count}")
    lines.append(f"- NN_COUNT: {nn_count}")
    lines.append(f"- MISSING_COUNT: {len(missing_in_nn)}")
    lines.append(f"- SHORT_COUNT: {len(short_text_nn)}")
    lines.append(f"- ANOMALY_FLAG: {anomaly_flag}")
    lines.append("")

    lines.append("## CONTROL_EXTRACTOR_DEBUG")
    lines.append("")
    lines.append("- CONTROL_FIRST20_HEADERS: [" + ", ".join(str(x) for x in kontrolno_first20_headers) + "]")
    lines.append(f"- CONTROL_HAS_10: {kontrolno_has_10}")
    lines.append(f"- CONTROL_HAS_11: {kontrolno_has_11}")
    lines.append(f"- CONTROL_HAS_12: {kontrolno_has_12}")
    if kontrolno_count_mismatch_warning:
        lines.append(f"- WARNING: {kontrolno_count_mismatch_warning}")
    lines.append("")

    lines.append("## Missing in NN (present in zakon.hr, absent in NN)")
    lines.append("")
    if missing_in_nn:
        for number in missing_in_nn:
            lines.append(f"- {number}")
    else:
        lines.append("- (none)")
    lines.append("")

    lines.append("## Extra in NN (present in NN, absent in zakon.hr)")
    lines.append("")
    if extra_in_nn:
        for number in extra_in_nn:
            lines.append(f"- {number}")
    else:
        lines.append("- (none)")
    lines.append("")

    lines.append("## Short texts in NN (len < 200)")
    lines.append("")
    if short_text_meta:
        for number, text_len, filename in short_text_meta:
            lines.append(f"- Članak {number} (len={text_len}) -> {filename}")
    else:
        lines.append("- (none)")
    lines.append("")

    lines.append("## Anomaly hints")
    lines.append("")
    lines.append(f"- ANOMALY_FLAG: {anomaly_flag}")
    lines.append(f"- FOUND_BETWEEN_10_12: {anomaly_meta.get('FOUND_BETWEEN_10_12')}")
    keys = anomaly_meta.get("KEYWORDS") if isinstance(anomaly_meta.get("KEYWORDS"), list) else []
    lines.append("- KEYWORDS_FOUND: " + (", ".join(str(k) for k in keys) if keys else "(none)"))
    lines.append(f"- NAPOMENA: {anomaly_note}")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    for required in (NN_JSON, KONTROLNO_TXT, NN_HTML):
        if not required.exists():
            raise FileNotFoundError(f"Nedostaje ulazna datoteka: {required}")

    nn_payload = json.loads(NN_JSON.read_text(encoding="utf-8"))
    kontrolno_text = KONTROLNO_TXT.read_text(encoding="utf-8")
    nn_html = NN_HTML.read_text(encoding="utf-8", errors="ignore")

    kontrolno_headers = parse_kontrolno_headers(kontrolno_text)
    kontrolno_nums = set(kontrolno_headers)
    kontrolno_count = len(kontrolno_nums)
    kontrolno_headers_count = len(kontrolno_headers)
    kontrolno_first20_headers = kontrolno_headers[:20]
    kontrolno_has_10 = 10 in kontrolno_nums
    kontrolno_has_11 = 11 in kontrolno_nums
    kontrolno_has_12 = 12 in kontrolno_nums
    kontrolno_count_mismatch_warning: str | None = None
    if kontrolno_headers_count != len(kontrolno_nums):
        kontrolno_count_mismatch_warning = (
            "CONTROL_HEADERS_COUNT != len(control_nums): "
            f"{kontrolno_headers_count} vs {len(kontrolno_nums)}"
        )

    nn_nums, nn_texts = parse_nn_numbers_and_texts(nn_payload)

    missing_in_nn = sorted(kontrolno_nums - nn_nums)
    extra_in_nn = sorted(nn_nums - kontrolno_nums)
    short_text_meta = sorted(
        [
            (number, len(text.strip()), norma_filename_for_number(number))
            for number, text in nn_texts.items()
            if len(text.strip()) < 200
        ],
        key=lambda item: item[0],
    )
    short_text_nn = [number for number, _, _ in short_text_meta]

    anomaly_flag, anomaly_note, anomaly_meta = anomaly_check_in_html(nn_html)

    ts = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    report = build_report(
        ts=ts,
        nn_hash=sha256_file(NN_JSON),
        kontrolno_hash=sha256_file(KONTROLNO_TXT),
        nn_count=len(nn_nums),
        kontrolno_count=kontrolno_count,
        kontrolno_headers_count=kontrolno_headers_count,
        kontrolno_first20_headers=kontrolno_first20_headers,
        kontrolno_has_10=kontrolno_has_10,
        kontrolno_has_11=kontrolno_has_11,
        kontrolno_has_12=kontrolno_has_12,
        kontrolno_count_mismatch_warning=kontrolno_count_mismatch_warning,
        missing_in_nn=missing_in_nn,
        extra_in_nn=extra_in_nn,
        short_text_nn=short_text_nn,
        short_text_meta=short_text_meta,
        anomaly_flag=anomaly_flag,
        anomaly_note=anomaly_note,
        anomaly_meta=anomaly_meta,
    )

    OUT_REPORT.parent.mkdir(parents=True, exist_ok=True)
    OUT_REPORT.write_text(report + "\n", encoding="utf-8")

    missing_csv = ", ".join(str(x) for x in missing_in_nn)
    extra_csv = ", ".join(str(x) for x in extra_in_nn)
    short_first20 = short_text_nn[:20]
    short_first20_csv = ", ".join(str(x) for x in short_first20)

    print(f"CONTROL_COUNT: {kontrolno_count}")
    print(f"CONTROL_HEADERS_COUNT: {kontrolno_headers_count}")
    print("CONTROL_FIRST20_HEADERS: [" + ", ".join(str(x) for x in kontrolno_first20_headers) + "]")
    print(f"CONTROL_HAS_10: {kontrolno_has_10}")
    print(f"CONTROL_HAS_11: {kontrolno_has_11}")
    print(f"CONTROL_HAS_12: {kontrolno_has_12}")
    print(f"NN_COUNT: {len(nn_nums)}")
    print(f"MISSING_COUNT: {len(missing_in_nn)}")
    print(f"MISSING_LIST: [{missing_csv}]" if missing_csv else "MISSING_LIST: []")
    print(f"EXTRA_LIST: [{extra_csv}]" if extra_csv else "EXTRA_LIST: []")
    print(f"SHORT_COUNT: {len(short_text_nn)}")
    print(f"SHORT_LIST_COUNT: {len(short_text_nn)}")
    print(f"SHORT_LIST_FIRST20: [{short_first20_csv}]" if short_first20_csv else "SHORT_LIST_FIRST20: []")
    print(f"ANOMALY_FLAG: {anomaly_flag}")
    print(f"REPORT: {OUT_REPORT.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
