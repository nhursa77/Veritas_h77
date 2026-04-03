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


def emit_stream(text: str) -> None:
    if not text:
        return

    for line in text.splitlines():
        if line.strip() == "":
            continue
        print(line)


def estimate_command_length(parts: list[str]) -> int:
    return len(" ".join(shlex.quote(part) for part in parts))


def chunk_targets(base_command: list[str], targets: list[str], max_length: int = 6000) -> list[list[str]]:
    chunks: list[list[str]] = []
    current: list[str] = []

    for target in targets:
        candidate = current + [target]
        if current and estimate_command_length(base_command + candidate) > max_length:
            chunks.append(current)
            current = [target]
        else:
            current = candidate

    if current:
        chunks.append(current)

    return chunks


def parse_markdownlint_json_output(text: str, root: Path) -> list[tuple[str, int, str]]:
    if not text or text.strip() == "":
        return []

    sanitized = text.strip().lstrip("\ufeff")
    if not sanitized.startswith("["):
        start = sanitized.find("[")
        end = sanitized.rfind("]")
        if start == -1 or end == -1 or end < start:
            return []
        sanitized = sanitized[start : end + 1]

    try:
        payload = json.loads(sanitized)
    except json.JSONDecodeError:
        return []

    if not isinstance(payload, list):
        return []

    parsed: list[tuple[str, int, str]] = []
    for item in payload:
        if not isinstance(item, dict):
            continue

        file_name = str(item.get("fileName", "")).strip()
        line_number = int(item.get("lineNumber", 0) or 0)
        rule_names = item.get("ruleNames", [])
        rule_code = str(rule_names[0]) if isinstance(rule_names, list) and rule_names else "MDLINT"
        rule_description = str(item.get("ruleDescription", "")).strip()
        error_detail = str(item.get("errorDetail", "")).strip()

        try:
            file_path = Path(file_name)
            if file_path.is_absolute():
                relative = file_path.relative_to(root).as_posix()
            else:
                relative = file_name.replace("\\", "/")
        except Exception:
            relative = file_name.replace("\\", "/")

        detail_parts = [rule_code]
        if rule_description:
            detail_parts.append(rule_description)
        if error_detail:
            detail_parts.append(error_detail)

        parsed.append((relative, line_number, " | ".join(detail_parts)))

    return parsed


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
    base_command = command + ["--json", "--config", runtime_config_path]
    chunks = chunk_targets(base_command, existing_targets)

    print(f"MDLINT_ENGINE={engine_label}")
    print("MDLINT_RULESET_SOURCE=.markdownlint.json")
    print(f"MDLINT_RUNTIME_CONFIG={runtime_config_path}")
    print(f"MDLINT_CHUNKS={len(chunks)}")
    print(f"MDLINT_COMMAND_BASE={' '.join(shlex.quote(part) for part in base_command)}")

    violation_count = 0
    final_exit_code = 0

    try:
        for index, chunk in enumerate(chunks, start=1):
            print(f"MDLINT_CHUNK_BEGIN={index}/{len(chunks)} FILES={len(chunk)}")
            result = subprocess.run(
                base_command + chunk,
                cwd=root,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )

            parsed_stdout = parse_markdownlint_json_output(result.stdout, root)
            parsed_stderr = parse_markdownlint_json_output(result.stderr, root)
            parsed_violations = parsed_stdout + parsed_stderr

            if parsed_violations:
                for rel, line_no, detail in parsed_violations:
                    print(f"MDLINT_VIOLATION: {rel}:{line_no}: {detail}")
                violation_count += len(parsed_violations)
            else:
                emit_stream(result.stdout)
                emit_stream(result.stderr)

            print(f"MDLINT_CHUNK_END={index}/{len(chunks)} EXIT={result.returncode}")

            if result.returncode != 0 and final_exit_code == 0:
                final_exit_code = result.returncode
    finally:
        try:
            Path(runtime_config_path).unlink(missing_ok=True)
        except Exception:
            pass

    print(f"MDLINT_VIOLATIONS={violation_count}")
    print("MDLINT_END=True")
    print(f"MDLINT_EXIT={final_exit_code}")
    return final_exit_code


if __name__ == "__main__":
    sys.exit(main())
