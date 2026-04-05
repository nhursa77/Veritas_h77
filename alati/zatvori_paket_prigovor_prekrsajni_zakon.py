"""
Kompatibilni wrapper za zatvaranje paketa Prekršajnog zakona.

Ova skripta delegira na zatvori_paket_prekrsajni_zakon.py
i koristi --vrsta-paketa prigovor.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

VRSTA_PAKETA = "prigovor"


def main() -> int:
    target = Path(__file__).resolve().with_name("zatvori_paket_prekrsajni_zakon.py")
    command = [
        sys.executable,
        str(target),
        "--vrsta-paketa",
        VRSTA_PAKETA,
        *sys.argv[1:],
    ]
    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
