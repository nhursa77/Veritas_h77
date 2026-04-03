import json
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

MARKDOWNLINT_NPX_PACKAGE = "markdownlint-cli@0.48.0"


def load_markdownlint_config(config_path: Path) -> dict:
    if not config_path.exists():
        return {}
    try:
        return json.loads(config_path.read_text(encoding="utf-8-sig"))
    except Exception:
        return {}


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


def configured_rules(config: dict) -> list[str]:
    rules = []
    for key, value in config.items():
        if not str(key).startswith("MD"):
            continue
        if value is False:
            continue
        rules.append(str(key))
    return sorted(rules)


def resolve_engine_command(root: Path) -> tuple[list[str], str]:
    local_candidates = [
        root / "node_modules" / ".bin" / "markdownlint.cmd",
        root / "node_modules" / ".bin" / "markdownlint",
    ]

    for candidate in local_candidates:
        if candidate.exists():
            return [str(candidate)], "markdownlint-cli(local)"

    for command_name in ("markdownlint.cmd", "markdownlint"):
        resolved = shutil.which(command_name)
        if resolved:
            return [resolved], "markdownlint-cli(global)"

    npx = shutil.which("npx.cmd") or shutil.which("npx")
    if npx:
        return [npx, "--yes", MARKDOWNLINT_NPX_PACKAGE], MARKDOWNLINT_NPX_PACKAGE

    raise FileNotFoundError(
        "stvarni markdownlint CLI nije dostupan (ni local ni global ni preko npx)"
    )


def emit_stream(text: str) -> int:
    if not text:
        return 0

    count = 0
    for line in text.splitlines():
        if line.strip() == "":
            continue
        print(line)
        if ": MD" in line:
            count += 1

    return count


def materialize_runtime_config(config: dict) -> str:
    handle = tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        suffix=".json",
        prefix="veritas_markdownlint_",
        delete=False,
    )
    with handle:
        json.dump(config, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    return handle.name


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    config_path = root / ".markdownlint.json"
    config = load_markdownlint_config(config_path)
    rules = configured_rules(config)
    target_files = collect_target_files(root, sys.argv[1:])

    print("MDLINT_BEGIN=True")
    print(f"MDLINT_CONFIG={config_path}")
    print(f"MDLINT_RULESET={','.join(rules)}")

    existing_targets: list[str] = []
    for file_path in target_files:
        rel = file_path.relative_to(root).as_posix()
        if not file_path.exists():
            print(f"MDLINT_SKIPPED_MISSING={rel}")
            continue
        existing_targets.append(rel)

    print(f"MDLINT_FILES={len(existing_targets)}")

    if len(existing_targets) == 0:
        print("MDLINT_VIOLATIONS=0")
        print("MDLINT_END=True")
        print("MDLINT_EXIT=0")
        return 0

    try:
        command, engine_label = resolve_engine_command(root)
    except FileNotFoundError as exc:
        print(f"ERROR: {exc}")
        print("MDLINT_END=True")
        print("MDLINT_EXIT=2")
        return 2

    runtime_config_path = materialize_runtime_config(config)
    print(f"MDLINT_ENGINE={engine_label}")
    print("MDLINT_RULESET_SOURCE=.markdownlint.json")
    print(f"MDLINT_RUNTIME_CONFIG={runtime_config_path}")
    full_command = command + ["--config", runtime_config_path] + existing_targets
    print(f"MDLINT_COMMAND={' '.join(shlex.quote(part) for part in full_command)}")

    try:
        result = subprocess.run(
            full_command,
            cwd=root,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    finally:
        try:
            Path(runtime_config_path).unlink(missing_ok=True)
        except Exception:
            pass

    violation_count = 0
    violation_count += emit_stream(result.stdout)
    violation_count += emit_stream(result.stderr)

    print(f"MDLINT_VIOLATIONS={violation_count}")
    print("MDLINT_END=True")
    print(f"MDLINT_EXIT={result.returncode}")
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
