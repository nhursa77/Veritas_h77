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


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_kontrolno_nums(text: str) -> set[int]:
    return {int(match.group(1)) for match in ARTICLE_RX.finditer(text)}


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


def anomaly_check_in_html(html: str) -> tuple[bool, str]:
    start_marker = "Članak 10."
    end_marker = "Članak 12."

    start_idx = html.find(start_marker)
    if start_idx < 0:
        return False, "Nije pronađen marker 'Članak 10.' u NN HTML-u."

    end_idx = html.find(end_marker, start_idx + len(start_marker))
    if end_idx < 0:
        return False, "Nije pronađen marker 'Članak 12.' nakon 'Članak 10.' u NN HTML-u."

    segment = html[start_idx:end_idx]
    has_heading = "Članak 1 I." in segment
    keys = [
        "Grb Republike Hrvatske",
        "Zastava Republike Hrvatske",
        "Himna je Republike Hrvatske",
    ]
    found_keys = [key for key in keys if key in segment]

    if has_heading and len(found_keys) >= 2:
        details = ", ".join(found_keys)
        return (
            True,
            "ANOMALIJA: sadržaj čl. 11 je prisutan u HTML segmentu, "
            "ali heading je 'Članak 1 I.' -> NN parsiranje treba ručno/automatski rule. "
            f"Ključne fraze: {details}",
        )

    if not has_heading:
        return False, "U segmentu između 'Članak 10.' i 'Članak 12.' nije pronađen heading 'Članak 1 I.'."

    return False, "Heading 'Članak 1 I.' postoji, ali nije potvrđen sadržajni signal čl. 11 (>=2 ključne fraze)."


def build_report(
    ts: str,
    nn_hash: str,
    kontrolno_hash: str,
    nn_count: int,
    kontrolno_count: int,
    missing_in_nn: list[int],
    extra_in_nn: list[int],
    short_text_nn: list[int],
    anomaly_flag: bool,
    anomaly_note: str,
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
    lines.append(f"- NN_COUNT: {nn_count}")
    lines.append(f"- MISSING_COUNT: {len(missing_in_nn)}")
    lines.append(f"- SHORT_COUNT: {len(short_text_nn)}")
    lines.append(f"- ANOMALY_FLAG: {anomaly_flag}")
    lines.append("")

    lines.append("## MISSING_IN_NN")
    lines.append("")
    if missing_in_nn:
        lines.append("- " + ", ".join(str(x) for x in missing_in_nn))
    else:
        lines.append("- Nema nedostajućih članaka prema kontrolnom izvoru.")
    lines.append("")

    lines.append("## SHORT_TEXT_IN_NN")
    lines.append("")
    if short_text_nn:
        lines.append("- " + ", ".join(str(x) for x in short_text_nn))
    else:
        lines.append("- Nema sumnjivo kratkih/empty članaka (threshold < 200).")
    lines.append("")

    lines.append("## EXTRA_IN_NN")
    lines.append("")
    if extra_in_nn:
        lines.append("- " + ", ".join(str(x) for x in extra_in_nn))
    else:
        lines.append("- Nema dodatnih članaka u NN u odnosu na kontrolni izvor.")
    lines.append("")

    lines.append("## ANOMALY_CHECK")
    lines.append("")
    lines.append(f"- ANOMALY_FLAG: {anomaly_flag}")
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

    kontrolno_nums = parse_kontrolno_nums(kontrolno_text)
    nn_nums, nn_texts = parse_nn_numbers_and_texts(nn_payload)

    missing_in_nn = sorted(kontrolno_nums - nn_nums)
    extra_in_nn = sorted(nn_nums - kontrolno_nums)
    short_text_nn = sorted([
        number for number, text in nn_texts.items() if len(text.strip()) < 200
    ])

    anomaly_flag, anomaly_note = anomaly_check_in_html(nn_html)

    ts = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    report = build_report(
        ts=ts,
        nn_hash=sha256_file(NN_JSON),
        kontrolno_hash=sha256_file(KONTROLNO_TXT),
        nn_count=len(nn_nums),
        kontrolno_count=len(kontrolno_nums),
        missing_in_nn=missing_in_nn,
        extra_in_nn=extra_in_nn,
        short_text_nn=short_text_nn,
        anomaly_flag=anomaly_flag,
        anomaly_note=anomaly_note,
    )

    OUT_REPORT.parent.mkdir(parents=True, exist_ok=True)
    OUT_REPORT.write_text(report + "\n", encoding="utf-8")

    print(f"CONTROL_COUNT={len(kontrolno_nums)}")
    print(f"NN_COUNT={len(nn_nums)}")
    print(f"MISSING_COUNT={len(missing_in_nn)}")
    print(f"SHORT_COUNT={len(short_text_nn)}")
    print(f"ANOMALY_FLAG={anomaly_flag}")
    print(f"REPORT={OUT_REPORT.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
