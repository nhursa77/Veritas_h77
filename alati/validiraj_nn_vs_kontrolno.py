#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
NN_JSON = REPO_ROOT / "izvori" / "dokazno" / "narodne_novine" / "ustav_rh" / "struktura_nn.json"
NN_DOCS_JSON = REPO_ROOT / "izvori" / "dokazno" / "narodne_novine" / "ustav_rh" / "struktura_nn_dokumenti.json"
KONTROLNO_TXT = REPO_ROOT / "izvori" / "kontrolno" / "zakon_hr" / "ustav_rh" / "ustav_rh_kontrolni.txt"
KONTROLNO_DOCS_JSON = REPO_ROOT / "izvori" / "kontrolno" / "zakon_hr" / "ustav_rh" / "struktura_kontrolno_dokumenti.json"
NN_HTML = REPO_ROOT / "izvori" / "dokazno" / "narodne_novine" / "ustav_rh" / "izvor_nn.html"
OUT_REPORT = REPO_ROOT / "baza_zakona" / "norme" / "ustav_rh" / "IZVJESTAJ_VALIDACIJE_KONTROLNO.md"

CONTROL_HEADER_STRICT_RX = re.compile(r"^\s*Članak\s+([0-9]{1,3})\.\s*$")
CONTROL_HEADER_TYPO_I_RX = re.compile(r"^\s*Članak\s+I([0-9]{2,3})\.\s*$")
CONTROL_HEADER_TYPO_L_RX = re.compile(r"^\s*Članak\s+l([0-9]{2,3})\.\s*$")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


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


def parse_kontrolno_dokumenti(text: str) -> tuple[list[dict], list[str]]:
    dokumenti: list[dict] = [
        {
            "doc_id": "ustav_rh_procisceni",
            "tip": "ustav_procisceni",
            "nn": None,
            "naslov": "Ustav Republike Hrvatske",
            "clanci": [],
        }
    ]
    current_doc = dokumenti[0]

    typo_mappings: list[str] = []
    current_num: int | None = None
    current_parts: list[str] = []

    def zavrsi_trenutni() -> None:
        nonlocal current_num, current_parts
        if current_num is None:
            return
        tekst = re.sub(r"\s+", " ", " ".join(current_parts)).strip()
        current_doc["clanci"].append(
            {
                "broj": current_num,
                "naslov": None,
                "tekst": tekst,
                "struktura": {"stavci": None, "glava_rimski": None},
            }
        )
        current_num = None
        current_parts = []

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue

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

        match_clean = CONTROL_HEADER_STRICT_RX.match(line)
        if match_clean:
            zavrsi_trenutni()
            current_num = int(match_clean.group(1))
            continue

        match_i = CONTROL_HEADER_TYPO_I_RX.match(line)
        if match_i:
            zavrsi_trenutni()
            suffix = match_i.group(1)
            mapped = int(f"1{suffix}")
            current_num = mapped
            typo = f"Članak I{suffix} -> {mapped}"
            if typo not in typo_mappings:
                typo_mappings.append(typo)
            continue

        match_l = CONTROL_HEADER_TYPO_L_RX.match(line)
        if match_l:
            zavrsi_trenutni()
            suffix = match_l.group(1)
            mapped = int(f"1{suffix}")
            current_num = mapped
            typo = f"Članak l{suffix} -> {mapped}"
            if typo not in typo_mappings:
                typo_mappings.append(typo)
            continue

        if current_num is not None:
            current_parts.append(line)

    zavrsi_trenutni()
    return dokumenti, typo_mappings


def parse_nn_dokumenti() -> list[dict]:
    if NN_DOCS_JSON.exists():
        payload = json.loads(NN_DOCS_JSON.read_text(encoding="utf-8"))
        return payload.get("dokumenti", [])

    payload = json.loads(NN_JSON.read_text(encoding="utf-8"))
    return [
        {
            "doc_id": "ustav_rh_procisceni",
            "tip": "ustav_procisceni",
            "nn": None,
            "naslov": "Ustav Republike Hrvatske",
            "clanci": payload.get("clanci", []),
        }
    ]


def dokument_brojevi_i_tekst(dokument: dict) -> tuple[list[int], set[int], dict[int, str]]:
    clanci = dokument.get("clanci", []) if isinstance(dokument, dict) else []
    ordered: list[int] = []
    nums: set[int] = set()
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
        ordered.append(broj)
        nums.add(broj)
        if broj in text_by_num:
            if len(tekst) > len(text_by_num[broj]):
                text_by_num[broj] = tekst
        else:
            text_by_num[broj] = tekst

    return ordered, nums, text_by_num


def detect_control_truncation(headers: list[int]) -> tuple[bool, int | None, int | None, list[str]]:
    if not headers:
        return False, None, None, []

    control_min = min(headers)
    control_max = max(headers)
    suspicious_examples: list[str] = []
    seen_high_range = False

    for index, number in enumerate(headers):
        if number >= 120:
            seen_high_range = True

        if number < 50 and seen_high_range:
            prev_value = headers[index - 1] if index > 0 else None
            next_value = headers[index + 1] if index + 1 < len(headers) else None
            neighbor_high = (
                (prev_value is not None and prev_value >= 120)
                or (next_value is not None and next_value >= 120)
            )
            if neighbor_high:
                suspicious_examples.append(
                    f"found {number} near high-range context (prev={prev_value}, next={next_value})"
                )

    small_weird = {12, 13, 14} & set(headers)
    truncated = control_max >= 120 and (bool(suspicious_examples) or bool(small_weird))
    if truncated and not suspicious_examples and small_weird:
        suspicious_examples.append("found small numbers (12/13/14) in same control set with high range >=120")

    return truncated, control_min, control_max, suspicious_examples


def anomaly_check_in_html(html: str) -> tuple[bool, str, dict[str, object]]:
    start_marker = "Članak 10."
    end_marker = "Članak 12."

    typo_matches = sorted({
        f"Članak I{m.group(1)} -> 1{m.group(1)}"
        for m in re.finditer(r"Članak\s+I([0-9]{2,3})", html)
    } | {
        f"Članak l{m.group(1)} -> 1{m.group(1)}"
        for m in re.finditer(r"Članak\s+l([0-9]{2,3})", html)
    })

    start_idx = html.find(start_marker)
    if start_idx < 0:
        return False, "Nije pronađen marker 'Članak 10.' u NN HTML-u.", {
            "FOUND_BETWEEN_10_12": None,
            "KEYWORDS": [],
            "FOUND_TYPO_HEADERS": typo_matches,
        }

    end_idx = html.find(end_marker, start_idx + len(start_marker))
    if end_idx < 0:
        return False, "Nije pronađen marker 'Članak 12.' nakon 'Članak 10.' u NN HTML-u.", {
            "FOUND_BETWEEN_10_12": None,
            "KEYWORDS": [],
            "FOUND_TYPO_HEADERS": typo_matches,
        }

    segment = html[start_idx:end_idx]
    has_heading = "Članak 1 I." in segment
    keys = ["Grb Republike Hrvatske", "Zastava Republike Hrvatske", "Himna je Republike Hrvatske"]
    found_keys = [key for key in keys if key in segment]

    payload = {
        "FOUND_BETWEEN_10_12": "Članak 1 I." if has_heading else None,
        "KEYWORDS": found_keys,
        "FOUND_TYPO_HEADERS": typo_matches,
    }

    if has_heading and len(found_keys) >= 2:
        details = ", ".join(found_keys)
        return (
            True,
            "ANOMALIJA: sadržaj čl. 11 je prisutan u HTML segmentu, ali heading je 'Članak 1 I.' -> NN parsiranje treba ručno/automatski rule. "
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
    control_docs_ids: list[str],
    nn_docs_ids: list[str],
    nn_count: int,
    kontrolno_count: int,
    kontrolno_headers_count: int,
    kontrolno_first20_headers: list[int],
    kontrolno_has_10: bool,
    kontrolno_has_11: bool,
    kontrolno_has_12: bool,
    kontrolno_typo_headers: list[str],
    control_truncation_suspected: bool,
    control_min: int | None,
    control_max: int | None,
    control_truncation_examples: list[str],
    kontrolno_count_mismatch_warning: str | None,
    missing_in_nn: list[int],
    extra_in_nn: list[int],
    untrustworthy_control_extra_list: list[int],
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
    lines.append(f"- NN_JSON_SHA256: {nn_hash}")
    lines.append(f"- KONTROLNO_TXT_SHA256: {kontrolno_hash}")
    lines.append("")

    lines.append("## Document split summary")
    lines.append("")
    lines.append(f"- CONTROL_DOCS_FOUND: {len(control_docs_ids)} | {', '.join(control_docs_ids) if control_docs_ids else '(none)'}")
    lines.append(f"- NN_DOCS_FOUND: {len(nn_docs_ids)} | {', '.join(nn_docs_ids) if nn_docs_ids else '(none)'}")
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
    lines.append(f"- CONTROL_TRUNCATION_SUSPECTED: {control_truncation_suspected}")
    lines.append(f"- CONTROL_MIN: {control_min}")
    lines.append(f"- CONTROL_MAX: {control_max}")
    lines.append("- CONTROL_TYPO_HEADERS: " + (", ".join(kontrolno_typo_headers) if kontrolno_typo_headers else "(none)"))
    if kontrolno_count_mismatch_warning:
        lines.append(f"- WARNING: {kontrolno_count_mismatch_warning}")
    lines.append("")

    lines.append("## Control source anomaly (zakon.hr truncation suspected)")
    lines.append("")
    lines.append(f"- CONTROL_TRUNCATION_SUSPECTED: {control_truncation_suspected}")
    if control_truncation_examples:
        for example in control_truncation_examples:
            lines.append(f"- {example}")
    else:
        lines.append("- (none)")
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
    if control_truncation_suspected:
        lines.append("- UNTRUSTWORTHY_CONTROL_EXTRA_LIST: kontrolni izvor je označen kao nepouzdan (truncation suspected).")
        if untrustworthy_control_extra_list:
            lines.append("- Kandidati (nepouzdano): " + ", ".join(str(x) for x in untrustworthy_control_extra_list))
        else:
            lines.append("- Kandidati (nepouzdano): (none)")
    elif extra_in_nn:
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
    typo_headers = anomaly_meta.get("FOUND_TYPO_HEADERS") if isinstance(anomaly_meta.get("FOUND_TYPO_HEADERS"), list) else []
    lines.append("- FOUND_TYPO_HEADERS: " + (", ".join(str(item) for item in typo_headers) if typo_headers else "(none)"))
    lines.append(f"- NAPOMENA: {anomaly_note}")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    for required in (NN_JSON, KONTROLNO_TXT, NN_HTML):
        if not required.exists():
            raise FileNotFoundError(f"Nedostaje ulazna datoteka: {required}")

    nn_dokumenti = parse_nn_dokumenti()
    kontrolno_text = KONTROLNO_TXT.read_text(encoding="utf-8")
    nn_html = NN_HTML.read_text(encoding="utf-8", errors="ignore")

    kontrolno_dokumenti, kontrolno_typo_headers = parse_kontrolno_dokumenti(kontrolno_text)
    KONTROLNO_DOCS_JSON.write_text(
        json.dumps(
            {
                "glavni_akt": {"slug": "ustav_rh", "naziv": "Ustav Republike Hrvatske"},
                "dokumenti": kontrolno_dokumenti,
                "parsiranje": {
                    "datum_parsiranja": datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds"),
                    "broj_dokumenata": len(kontrolno_dokumenti),
                },
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    nn_doc = next((d for d in nn_dokumenti if d.get("doc_id") == "ustav_rh_procisceni"), {"clanci": []})
    control_doc = next((d for d in kontrolno_dokumenti if d.get("doc_id") == "ustav_rh_procisceni"), {"clanci": []})

    kontrolno_headers, kontrolno_nums, _ = dokument_brojevi_i_tekst(control_doc)
    nn_headers, nn_nums, nn_texts = dokument_brojevi_i_tekst(nn_doc)

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

    control_truncation_suspected, control_min, control_max, control_truncation_examples = detect_control_truncation(kontrolno_headers)

    missing_in_nn = sorted(kontrolno_nums - nn_nums)
    raw_extra_in_nn = sorted(nn_nums - kontrolno_nums)
    extra_in_nn = [] if control_truncation_suspected else raw_extra_in_nn
    untrustworthy_control_extra_list = raw_extra_in_nn if control_truncation_suspected else []

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

    nn_hash = sha256_file(NN_DOCS_JSON) if NN_DOCS_JSON.exists() else sha256_file(NN_JSON)
    kontrolno_hash = sha256_file(KONTROLNO_TXT)
    control_docs_ids = [str(d.get("doc_id")) for d in kontrolno_dokumenti if d.get("doc_id")]
    nn_docs_ids = [str(d.get("doc_id")) for d in nn_dokumenti if d.get("doc_id")]

    ts = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
    report = build_report(
        ts=ts,
        nn_hash=nn_hash,
        kontrolno_hash=kontrolno_hash,
        control_docs_ids=control_docs_ids,
        nn_docs_ids=nn_docs_ids,
        nn_count=len(nn_nums),
        kontrolno_count=kontrolno_count,
        kontrolno_headers_count=kontrolno_headers_count,
        kontrolno_first20_headers=kontrolno_first20_headers,
        kontrolno_has_10=kontrolno_has_10,
        kontrolno_has_11=kontrolno_has_11,
        kontrolno_has_12=kontrolno_has_12,
        kontrolno_typo_headers=kontrolno_typo_headers,
        control_truncation_suspected=control_truncation_suspected,
        control_min=control_min,
        control_max=control_max,
        control_truncation_examples=control_truncation_examples,
        kontrolno_count_mismatch_warning=kontrolno_count_mismatch_warning,
        missing_in_nn=missing_in_nn,
        extra_in_nn=extra_in_nn,
        untrustworthy_control_extra_list=untrustworthy_control_extra_list,
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
    untrustworthy_extra_csv = ", ".join(str(x) for x in untrustworthy_control_extra_list)
    short_first20 = short_text_nn[:20]
    short_first20_csv = ", ".join(str(x) for x in short_first20)

    print(f"CONTROL_DOCS_FOUND: {len(control_docs_ids)} | {', '.join(control_docs_ids) if control_docs_ids else '(none)'}")
    print(f"NN_DOCS_FOUND: {len(nn_docs_ids)} | {', '.join(nn_docs_ids) if nn_docs_ids else '(none)'}")
    print(f"CONTROL_COUNT: {kontrolno_count}")
    print(f"CONTROL_HEADERS_COUNT: {kontrolno_headers_count}")
    print("CONTROL_FIRST20_HEADERS: [" + ", ".join(str(x) for x in kontrolno_first20_headers) + "]")
    print(f"CONTROL_HAS_10: {kontrolno_has_10}")
    print(f"CONTROL_HAS_11: {kontrolno_has_11}")
    print(f"CONTROL_HAS_12: {kontrolno_has_12}")
    print(f"CONTROL_TRUNCATION_SUSPECTED: {control_truncation_suspected}")
    print("CONTROL_TYPO_HEADERS: " + (", ".join(kontrolno_typo_headers) if kontrolno_typo_headers else "(none)"))
    print(f"NN_COUNT: {len(nn_nums)}")
    print(f"MISSING_COUNT: {len(missing_in_nn)}")
    print(f"MISSING_LIST: [{missing_csv}]" if missing_csv else "MISSING_LIST: []")
    print(f"EXTRA_LIST: [{extra_csv}]" if extra_csv else "EXTRA_LIST: []")
    if control_truncation_suspected:
        print(
            f"UNTRUSTWORTHY_CONTROL_EXTRA_LIST: [{untrustworthy_extra_csv}]"
            if untrustworthy_extra_csv
            else "UNTRUSTWORTHY_CONTROL_EXTRA_LIST: []"
        )
    print(f"SHORT_COUNT: {len(short_text_nn)}")
    print(f"SHORT_LIST_COUNT: {len(short_text_nn)}")
    print(f"SHORT_LIST_FIRST20: [{short_first20_csv}]" if short_first20_csv else "SHORT_LIST_FIRST20: []")
    print(f"ANOMALY_FLAG: {anomaly_flag}")
    print(f"REPORT: {OUT_REPORT.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
