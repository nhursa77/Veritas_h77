import json
import re
import sys
from pathlib import Path

CANONICAL_RULE_ORDER = ("MD010", "MD013", "MD036", "MD040", "MD047", "MD060")
FENCE_RE = re.compile(r"^\s{0,3}(?P<fence>`{3,}|~{3,})(?P<info>[^\r\n]*)$")
EMPHASIS_ONLY_RE = re.compile(
    r"^(?P<marker>\*{1,3}|_{1,3})(?!\s)(?P<text>.+?)(?<!\s)(?P=marker)$"
)
TABLE_SEPARATOR_RE = re.compile(
    r"^\s*\|?(?:\s*:?-{3,}:?\s*\|)+\s*:?-{3,}:?\s*\|?\s*$"
)


def load_markdownlint_config(config_path: Path) -> dict:
    if not config_path.exists():
        return {}
    try:
        return json.loads(config_path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def is_rule_enabled(config: dict, rule_name: str) -> bool:
    default_enabled = config.get("default", True)
    raw = config.get(rule_name)

    if isinstance(raw, bool):
        return raw
    if isinstance(raw, dict):
        return True
    return bool(default_enabled)


def get_line_length_limit(config: dict) -> int:
    md013 = config.get("MD013")

    if isinstance(md013, dict):
        raw = md013.get("line_length")
        if isinstance(raw, int) and raw > 0:
            return raw

    return 80


def get_md060_style(config: dict) -> str:
    md060 = config.get("MD060")

    if isinstance(md060, dict):
        raw = str(md060.get("style", "leading_and_trailing")).strip()
        if raw in {
            "consistent",
            "leading_and_trailing",
            "leading",
            "trailing",
            "no_leading_or_trailing",
        }:
            return raw

    return "leading_and_trailing"


def collect_target_files(root: Path, arg_paths: list[str]) -> list[Path]:
    targets: list[Path] = []
    seen: set[str] = set()

    for raw in arg_paths:
        text = str(raw).strip()
        if text == "":
            continue

        candidate = Path(text)
        absolute = candidate if candidate.is_absolute() else (root / candidate)
        normalized = str(absolute.resolve())

        if normalized in seen:
            continue

        seen.add(normalized)
        targets.append(absolute)

    return sorted(targets, key=lambda item: str(item).lower())


def describe_violation(rule_name: str, detail: str) -> str:
    return f"{rule_name} {detail}".strip()


def scan_fences(lines: list[str]) -> tuple[set[int], list[tuple[int, str]]]:
    code_lines: set[int] = set()
    md040_violations: list[tuple[int, str]] = []
    in_fence = False
    fence_char = ""
    fence_len = 0

    for idx, line in enumerate(lines, start=1):
        fence_match = FENCE_RE.match(line)

        if not in_fence:
            if not fence_match:
                continue

            info = fence_match.group("info").strip()
            if info == "":
                md040_violations.append((idx, "fenced-code-language-missing"))

            marker = fence_match.group("fence")
            in_fence = True
            fence_char = marker[0]
            fence_len = len(marker)
            code_lines.add(idx)
            continue

        code_lines.add(idx)
        closing_re = re.compile(
            rf"^\s{{0,3}}{re.escape(fence_char)}{{{fence_len},}}\s*$"
        )
        if closing_re.match(line):
            in_fence = False
            fence_char = ""
            fence_len = 0

    return code_lines, md040_violations


def check_md010(lines: list[str]) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []

    for idx, line in enumerate(lines, start=1):
        if "\t" in line:
            violations.append((idx, "hard-tab-detected"))

    return violations


def check_md013(lines: list[str], max_len: int) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []

    for idx, line in enumerate(lines, start=1):
        length = len(line)
        if length > max_len:
            violations.append((idx, f"line-length expected<={max_len} actual={length}"))

    return violations


def check_md036(lines: list[str], code_lines: set[int]) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []

    for idx, line in enumerate(lines, start=1):
        if idx in code_lines:
            continue

        stripped = line.strip()
        if stripped == "":
            continue
        if stripped.startswith(("#", ">", "- ", "+ ", "* ")):
            continue
        if re.match(r"^\d+[.)]\s+", stripped):
            continue

        if EMPHASIS_ONLY_RE.match(stripped):
            violations.append((idx, "emphasis-used-as-heading"))

    return violations


def table_style_flags(line: str) -> tuple[bool, bool]:
    stripped_left = line.lstrip()
    stripped_right = line.rstrip()
    return stripped_left.startswith("|"), stripped_right.endswith("|")


def matches_md060_style(line: str, style: str, expected: tuple[bool, bool]) -> bool:
    leading, trailing = table_style_flags(line)

    if style == "leading_and_trailing":
        return leading and trailing
    if style == "leading":
        return leading and not trailing
    if style == "trailing":
        return (not leading) and trailing
    if style == "no_leading_or_trailing":
        return (not leading) and (not trailing)
    return (leading, trailing) == expected


def check_md060(lines: list[str], code_lines: set[int], style: str) -> list[tuple[int, str]]:
    violations: list[tuple[int, str]] = []
    idx = 0

    while idx < len(lines) - 1:
        line_no = idx + 1
        if line_no in code_lines:
            idx += 1
            continue

        header = lines[idx]
        separator = lines[idx + 1]

        if "|" not in header or not TABLE_SEPARATOR_RE.match(separator):
            idx += 1
            continue

        expected = table_style_flags(header)
        row_idx = idx

        while row_idx < len(lines):
            current_no = row_idx + 1
            if current_no in code_lines:
                break

            current = lines[row_idx]
            if row_idx > idx + 1 and (current.strip() == "" or "|" not in current):
                break

            if not matches_md060_style(current, style, expected):
                violations.append((current_no, f"table-column-style={style}"))

            row_idx += 1

        idx = row_idx

    return violations


def check_md047(raw_text: str, line_count: int) -> list[tuple[int, str]]:
    normalized = raw_text.replace("\r\n", "\n").replace("\r", "\n")
    violation_line = max(1, line_count)

    if normalized == "":
        return []
    if not normalized.endswith("\n"):
        return [(violation_line, "missing-final-newline")]
    if normalized.endswith("\n\n"):
        return [(violation_line, "expected-single-trailing-newline")]

    return []


def lint_file(path: Path, config: dict) -> list[tuple[int, str, str]]:
    raw_text = path.read_text(encoding="utf-8")
    lines = raw_text.splitlines()
    code_lines, md040_violations = scan_fences(lines)
    md013_max = get_line_length_limit(config)
    md060_style = get_md060_style(config)
    violations: list[tuple[int, str, str]] = []

    rule_checks: dict[str, list[tuple[int, str]]] = {}

    if is_rule_enabled(config, "MD010"):
        rule_checks["MD010"] = check_md010(lines)
    if is_rule_enabled(config, "MD013"):
        rule_checks["MD013"] = check_md013(lines, md013_max)
    if is_rule_enabled(config, "MD036"):
        rule_checks["MD036"] = check_md036(lines, code_lines)
    if is_rule_enabled(config, "MD040"):
        rule_checks["MD040"] = md040_violations
    if is_rule_enabled(config, "MD047"):
        rule_checks["MD047"] = check_md047(raw_text, len(lines))
    if is_rule_enabled(config, "MD060"):
        rule_checks["MD060"] = check_md060(lines, code_lines, md060_style)

    for rule_name in CANONICAL_RULE_ORDER:
        for line_no, detail in rule_checks.get(rule_name, []):
            violations.append((line_no, rule_name, detail))

    return violations


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    config_path = root / ".markdownlint.json"
    config = load_markdownlint_config(config_path)
    max_len = get_line_length_limit(config)
    md060_style = get_md060_style(config)
    enabled_rules = [
        rule for rule in CANONICAL_RULE_ORDER if is_rule_enabled(config, rule)
    ]
    target_files = collect_target_files(root, sys.argv[1:])

    print("MDLINT_BEGIN=True")
    print(f"MDLINT_CONFIG={config_path}")
    print(f"MDLINT_RULESET={','.join(enabled_rules)}")
    print(f"MDLINT_MD013_MAX={max_len}")
    print(f"MDLINT_MD060_STYLE={md060_style}")
    print(f"MDLINT_FILES={len(target_files)}")

    if len(target_files) == 0:
        print("MDLINT_VIOLATIONS=0")
        print("MDLINT_END=True")
        print("MDLINT_EXIT=0")
        return 0

    total_violations = 0
    for file_path in target_files:
        if not file_path.exists():
            rel_missing = file_path.relative_to(root).as_posix()
            print(f"MDLINT_SKIPPED_MISSING={rel_missing}")
            continue

        rel = file_path.relative_to(root).as_posix()
        violations = lint_file(file_path, config)
        total_violations += len(violations)

        for line_no, rule_name, detail in violations:
            description = describe_violation(rule_name, detail)
            print(f"MDLINT_VIOLATION: {rel}:{line_no}: {description}")

    exit_code = 0 if total_violations == 0 else 1
    print(f"MDLINT_VIOLATIONS={total_violations}")
    print("MDLINT_END=True")
    print(f"MDLINT_EXIT={exit_code}")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
