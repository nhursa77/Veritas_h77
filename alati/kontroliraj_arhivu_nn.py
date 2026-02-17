from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NORME_DIR = ROOT / "baza_zakona" / "norme"
NN_ROOT = ROOT / "izvori" / "dokazno" / "narodne_novine"
REPORT_PATH = NN_ROOT / "IZVJESTAJ_KONTROLE_ARHIVE.md"


def datum_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def detektiraj_slug_iz_datoteke(path: Path) -> str | None:
    rel = path.relative_to(NORME_DIR)

    if len(rel.parts) >= 2 and rel.parts[0] != ".":
        kandidat = rel.parts[0]
        if kandidat not in {".", ".."}:
            return kandidat.lower()

    match = re.match(r"^(?P<slug>[A-Za-z0-9_]+)_clanak_\d+\.json$", path.name)
    if match:
        return match.group("slug").lower()

    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        akt = payload.get("akt")
        if isinstance(akt, dict):
            slug = akt.get("slug")
            if isinstance(slug, str) and slug.strip():
                return slug.strip().lower()
    except Exception:
        pass

    return None


def pronadi_slugove_normi() -> list[str]:
    slugs = set()
    for path in NORME_DIR.rglob("*.json"):
        if path.name.upper().startswith("IZVJESTAJ_"):
            continue
        slug = detektiraj_slug_iz_datoteke(path)
        if slug:
            slugs.add(slug)
    return sorted(slugs)


def status_akta(slug: str) -> tuple[str, str]:
    akt_dir = NN_ROOT / slug
    if not akt_dir.exists():
        return ("NEDOSTAJE", "nedostaje mapa akta u NN arhivi")

    source_files = list(akt_dir.glob("izvor_nn.*"))
    meta_path = akt_dir / "meta.json"

    if not source_files or not meta_path.exists():
        return ("NEDOSTAJE", "nedostaje izvor_nn.* ili meta.json")

    try:
        meta_raw = meta_path.read_text(encoding="utf-8-sig")
        meta = json.loads(meta_raw)
    except Exception:
        return ("HASH_NEDOSTAJE", "meta.json nije čitljiv JSON")

    sha = meta.get("sha256_datoteke") if isinstance(meta, dict) else None
    if not isinstance(sha, str) or not sha.strip():
        return ("HASH_NEDOSTAJE", "meta.json postoji, ali sha256_datoteke nedostaje")

    return ("OK", "izvor + meta + hash postoje")


def generiraj_izvjestaj(ok: list[str], nedostaje: list[tuple[str, str]], hash_nedostaje: list[tuple[str, str]]) -> None:
    ukupno = len(ok) + len(nedostaje) + len(hash_nedostaje)
    lines = [
        "# Izvještaj kontrole arhive NN",
        "",
        f"- Datum: {datum_hr()}",
        f"- Ukupno aktova u NORMA bazi: {ukupno}",
        f"- OK: {len(ok)}",
        f"- NEDOSTAJE: {len(nedostaje)}",
        f"- HASH_NEDOSTAJE: {len(hash_nedostaje)}",
        "",
        "## Statusi",
        "",
        "### OK",
        "",
    ]

    if ok:
        for slug in ok:
            lines.append(f"- {slug}")
    else:
        lines.append("- Nema aktova sa statusom OK.")

    lines.extend(["", "### NEDOSTAJE", ""])
    if nedostaje:
        for slug, razlog in nedostaje:
            lines.append(f"- {slug} | {razlog}")
    else:
        lines.append("- Nema aktova sa statusom NEDOSTAJE.")

    lines.extend(["", "### HASH_NEDOSTAJE", ""])
    if hash_nedostaje:
        for slug, razlog in hash_nedostaje:
            lines.append(f"- {slug} | {razlog}")
    else:
        lines.append("- Nema aktova sa statusom HASH_NEDOSTAJE.")

    lines.extend(
        [
            "",
            "## Gate pravilo",
            "",
            "- Ako postoji NEDOSTAJE ili HASH_NEDOSTAJE za akt koji se koristi u predmetu, vanjski izlaz je zabranjen.",
            "",
        ]
    )

    NN_ROOT.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    slugs = pronadi_slugove_normi()
    ok: list[str] = []
    nedostaje: list[tuple[str, str]] = []
    hash_nedostaje: list[tuple[str, str]] = []

    for slug in slugs:
        status, razlog = status_akta(slug)
        if status == "OK":
            ok.append(slug)
        elif status == "NEDOSTAJE":
            nedostaje.append((slug, razlog))
        else:
            hash_nedostaje.append((slug, razlog))

    generiraj_izvjestaj(ok=ok, nedostaje=nedostaje, hash_nedostaje=hash_nedostaje)
    print(f"OK: {len(ok)} | NEDOSTAJE: {len(nedostaje)} | HASH_NEDOSTAJE: {len(hash_nedostaje)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
