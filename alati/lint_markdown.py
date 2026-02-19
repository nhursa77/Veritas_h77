import json
import sys
from pathlib import Path


def load_markdownlint_config(config_path: Path) -> dict:
    if not config_path.exists():
        return {}
    try:
        return json.loads(config_path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def get_line_length_limit(config: dict) -> int:
    md013 = config.get("MD013")

    if isinstance(md013, dict):
        raw = md013.get("line_length")
        if isinstance(raw, int) and raw > 0:
            return raw

    return 80


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


def check_md013(path: Path, max_len: int) -> list[tuple[int, int]]:
    violations: list[tuple[int, int]] = []
    lines = path.read_text(encoding="utf-8").splitlines()

    for idx, line in enumerate(lines, start=1):
        length = len(line)
        if length > max_len:
            violations.append((idx, length))

    return violations


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    config_path = root / ".markdownlint.json"
    config = load_markdownlint_config(config_path)
    max_len = get_line_length_limit(config)
    target_files = collect_target_files(root, sys.argv[1:])

    print("MDLINT_BEGIN=True")
    print(f"MDLINT_CONFIG={config_path}")
    print(f"MDLINT_MD013_MAX={max_len}")
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
        violations = check_md013(file_path, max_len)
        total_violations += len(violations)

        for line_no, actual_len in violations:
            print(
                f"MDLINT_VIOLATION: {rel}:{line_no}: "
                f"MD013 line-length expected<={max_len} actual={actual_len}"
            )

    exit_code = 0 if total_violations == 0 else 1
    print(f"MDLINT_VIOLATIONS={total_violations}")
    print("MDLINT_END=True")
    print(f"MDLINT_EXIT={exit_code}")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
