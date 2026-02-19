from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
OLD_DIR = ROOT / "baza_zakona" / "arhiva" / "ustav_rh" / "nn_56_1990_1092_142"
NEW_DIR = ROOT / "baza_zakona" / "norme" / "ustav_rh_procisceni"
REPORT_PATH = NEW_DIR / "IZVJESTAJ_DIFF_142_VS_152.md"
LEN_DIFF_THRESHOLD = 50


def _extract_number_from_filename(path: Path) -> int | None:
    match = re.match(r"^clanak_(\d{1,4})[a-zA-Z]*\.json$", path.name)
    if not match:
        return None
    return int(match.group(1))


def _extract_number_from_payload(payload: dict[str, Any]) -> int | None:
    clanak = payload.get("clanak") if isinstance(payload, dict) else None
    if not isinstance(clanak, dict):
        return None

    raw = clanak.get("oznaka")
    if raw is None:
        raw = clanak.get("broj")

    if isinstance(raw, int):
        return raw

    if isinstance(raw, str):
        match = re.match(r"\s*(\d+)", raw)
        if match:
            return int(match.group(1))

    return None


def _extract_text(payload: dict[str, Any]) -> str:
    clanak = payload.get("clanak") if isinstance(payload, dict) else None
    if not isinstance(clanak, dict):
        return ""
    return str(clanak.get("tekst") or "").strip()


def _extract_text_hash(payload: dict[str, Any], text: str) -> str:
    integritet = payload.get("integritet") if isinstance(payload, dict) else None
    if isinstance(integritet, dict):
        raw = integritet.get("sha256_teksta")
        if isinstance(raw, str) and raw.strip():
            return raw.strip().upper()

    return hashlib.sha256(text.encode("utf-8")).hexdigest().upper()


def load_set(directory: Path) -> dict[int, dict[str, Any]]:
    data: dict[int, dict[str, Any]] = {}
    if not directory.exists():
        return data

    for path in sorted(directory.glob("clanak_*.json")):
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            continue

        number = _extract_number_from_payload(payload)
        if number is None:
            number = _extract_number_from_filename(path)
        if number is None:
            continue

        text = _extract_text(payload)
        text_hash = _extract_text_hash(payload, text)

        data[number] = {
            "path": path,
            "text": text,
            "length": len(text),
            "hash": text_hash,
        }

    return data


def build_report(
    old_set: dict[int, dict[str, Any]],
    new_set: dict[int, dict[str, Any]],
    added: list[int],
    removed: list[int],
    changed: list[dict[str, Any]],
) -> str:
    lines: list[str] = []
    lines.append("# IZVJESTAJ_DIFF_142_VS_152")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- OLD_COUNT: {len(old_set)}")
    lines.append(f"- NEW_COUNT: {len(new_set)}")
    lines.append(f"- ADDED_COUNT: {len(added)}")
    lines.append(f"- REMOVED_COUNT: {len(removed)}")
    lines.append(f"- CHANGED_COUNT: {len(changed)}")
    lines.append("")

    lines.append("## Added in 152 (not in 142)")
    lines.append("")
    if added:
        for n in added:
            lines.append(f"- Članak {n}")
    else:
        lines.append("- (none)")
    lines.append("")

    lines.append("## Removed in 152 (present in 142, missing in 152)")
    lines.append("")
    if removed:
        for n in removed:
            lines.append(f"- Članak {n}")
    else:
        lines.append("- (none)")
    lines.append("")

    lines.append("## Changed (present in both, hash/len differs)")
    lines.append("")
    if changed:
        for item in changed:
            lines.append(
                f"- Članak {item['number']}: "
                f"old_len={item['old_len']}, new_len={item['new_len']}, "
                f"old_hash={item['old_hash'][:8]}, new_hash={item['new_hash'][:8]}"
            )
    else:
        lines.append("- (none)")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    old_set = load_set(OLD_DIR)
    new_set = load_set(NEW_DIR)

    old_nums = set(old_set.keys())
    new_nums = set(new_set.keys())

    added = sorted(new_nums - old_nums)
    removed = sorted(old_nums - new_nums)

    changed: list[dict[str, Any]] = []
    for number in sorted(old_nums & new_nums):
        old_item = old_set[number]
        new_item = new_set[number]

        hash_diff = old_item["hash"] != new_item["hash"]
        len_diff = abs(int(new_item["length"]) - int(old_item["length"])) >= LEN_DIFF_THRESHOLD
        if hash_diff or len_diff:
            changed.append(
                {
                    "number": number,
                    "old_len": old_item["length"],
                    "new_len": new_item["length"],
                    "old_hash": old_item["hash"],
                    "new_hash": new_item["hash"],
                }
            )

    report = build_report(old_set=old_set, new_set=new_set, added=added, removed=removed, changed=changed)
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(report, encoding="utf-8")

    print(f"OLD_COUNT: {len(old_set)}")
    print(f"NEW_COUNT: {len(new_set)}")
    print(f"ADDED_LIST: {added}")
    print(f"REMOVED_LIST: {removed}")
    print(f"CHANGED_COUNT: {len(changed)}")
    print(f"REPORT: {REPORT_PATH.as_posix()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
