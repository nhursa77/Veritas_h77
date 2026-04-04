from __future__ import annotations

# KOMPATIBILNI WRAPPER:
# Ova skripta zadržava postojeće ime radi kompatibilnosti.
# Delegira na `zatvori_validiranu_gransku_natuknicu.py`.
# Koristi fiksni `--nacin druga`.

import subprocess
import sys
from pathlib import Path

FIXED_MODE = "druga"


def main() -> int:
    forwarded_args = sys.argv[1:]
    if any(arg == "--nacin" or arg.startswith("--nacin=") for arg in forwarded_args):
        print(
            f"ERROR=Wrapper vec fiksira --nacin={FIXED_MODE}; nemojte ga dodatno zadavati."
        )
        return 1

    target_script = Path(__file__).with_name("zatvori_validiranu_gransku_natuknicu.py")
    command = [sys.executable, str(target_script), "--nacin", FIXED_MODE, *forwarded_args]
    completed = subprocess.run(command, check=False)
    return int(completed.returncode)


if __name__ == "__main__":
    raise SystemExit(main())
