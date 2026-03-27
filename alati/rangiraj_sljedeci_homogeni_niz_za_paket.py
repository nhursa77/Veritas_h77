from __future__ import annotations

import argparse
import datetime as dt
import json
from collections import defaultdict
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json")
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json"
)
DEFAULT_VALIDATED = Path("baza_terminologije/rjecnik/potpuno_validirane_natuknice.json")
DEFAULT_VALIDATED_MANIFEST = Path(
    "baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket_manifest.json"
)


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise ValueError(f"Ocekivan je JSON objekt: {path}")
    return payload


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def _article_sort_key(article: str | None) -> tuple[int, int | str]:
    token = (article or "").strip()
    if token.isdigit():
        return (0, int(token))
    return (1, token)


def _first_article(row: dict[str, Any]) -> str:
    sidra = row.get("nn_sidra")
    if not isinstance(sidra, list) or not sidra:
        return ""
    first = sidra[0]
    if not isinstance(first, dict):
        return ""
    return _norm(first.get("clanak")) or ""


def _identity(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(row.get("podnatuknica_id", "")).strip(),
        str(row.get("kanonski_naziv_podnatuknice", "")).strip(),
    )


def _group_key(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(_norm(row.get("nadredeni_kanonski_naziv")) or ""),
        str(_norm(row.get("akt_slug")) or ""),
    )


def _sidro_signature(
    sidro: dict[str, Any],
) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _norm(sidro.get("akt_slug")),
        _norm(sidro.get("broj_nn")),
        _norm(sidro.get("clanak")),
        _norm(sidro.get("stavak")),
        _norm(sidro.get("tocka")),
    )


def _is_ready_for_package(row: dict[str, Any]) -> bool:
    act_slug = _norm(row.get("akt_slug"))
    if not act_slug:
        return False

    if not _norm(row.get("nadredeni_kanonski_naziv")):
        return False
    if not _norm(row.get("kanonski_naziv_podnatuknice")):
        return False
    if not _norm(row.get("pravna_grana_ili_kontekst")):
        return False

    sidra_raw = row.get("nn_sidra")
    if not isinstance(sidra_raw, list) or not sidra_raw:
        return False

    sidra = [s for s in sidra_raw if isinstance(s, dict)]
    if not sidra:
        return False

    sidro_slugs = {_norm(s.get("akt_slug")) for s in sidra}
    if sidro_slugs != {act_slug}:
        return False

    signatures = {_sidro_signature(s) for s in sidra}
    if len(signatures) != 1:
        return False

    first = sidra[0]
    if _norm(first.get("broj_nn")) != _norm(row.get("broj_nn")):
        return False
    if _norm(first.get("naziv_akta")) != _norm(row.get("naziv_akta")):
        return False

    return True


def _row_sort_key(row: dict[str, Any]) -> tuple[str, tuple[int, int | str], str]:
    return (
        str(row.get("kanonski_naziv_podnatuknice", "")),
        _article_sort_key(_first_article(row)),
        str(row.get("podnatuknica_id", "")),
    )


def _group_sort_key(item: dict[str, Any]) -> tuple[int, int, int, str, str]:
    return (
        -int(item["score"]),
        -int(item["ukupno_preostalih_u_nizu"]),
        -int(item["broj_jednoznacno_spremnih_za_paketno_zatvaranje"]),
        str(item["nadredeni_kanonski_naziv"]),
        str(item["akt_slug"]),
    )


def run(
    input_path: Path,
    input_manifest_path: Path,
    validated_path: Path,
    validated_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[dict[str, Any], dict[str, Any]]:
    input_payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    validated_payload = _load_json(validated_path)
    _ = _load_json(validated_manifest_path)

    rows_raw = input_payload.get("granske_podnatuknice", [])
    if not isinstance(rows_raw, list):
        raise ValueError("Polje 'granske_podnatuknice' mora biti lista.")
    rows = [row for row in rows_raw if isinstance(row, dict)]

    validated_raw = validated_payload.get("potpuno_validirane_natuknice", [])
    if not isinstance(validated_raw, list):
        raise ValueError("Polje 'potpuno_validirane_natuknice' mora biti lista.")
    validated_rows = [row for row in validated_raw if isinstance(row, dict)]
    validated_identities = {_identity(row) for row in validated_rows}

    groups: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        key = _group_key(row)
        if not key[0] or not key[1]:
            continue
        groups[key].append(row)

    ranked: list[dict[str, Any]] = []
    for key in sorted(groups.keys(), key=lambda t: (t[0], t[1])):
        grouped_rows = sorted(groups[key], key=_row_sort_key)
        remaining = [r for r in grouped_rows if _identity(r) not in validated_identities]

        spremni = [r for r in remaining if _is_ready_for_package(r)]
        problemati = [r for r in remaining if not _is_ready_for_package(r)]

        total_remaining = len(remaining)
        ready_count = len(spremni)
        problematic_count = len(problemati)
        score = (100 * total_remaining) + (10 * ready_count) - problematic_count

        ranked.append(
            {
                "nadredeni_kanonski_naziv": key[0],
                "akt_slug": key[1],
                "ukupno_u_nizu": len(grouped_rows),
                "ukupno_vec_zatvorenih_u_nizu": len(grouped_rows) - total_remaining,
                "ukupno_preostalih_u_nizu": total_remaining,
                "broj_jednoznacno_spremnih_za_paketno_zatvaranje": ready_count,
                "broj_problematnih_u_nizu": problematic_count,
                "score": score,
                "primjeri_preostalih_clanaka": [
                    _first_article(r) for r in remaining[:5] if _first_article(r)
                ],
            }
        )

    ranked_sorted = sorted(ranked, key=_group_sort_key)
    top10 = ranked_sorted[:10]

    recommended = None
    for item in ranked_sorted:
        if item["broj_jednoznacno_spremnih_za_paketno_zatvaranje"] > 0:
            recommended = item
            break

    generated_at = dt.datetime.now(dt.UTC).replace(microsecond=0).isoformat()
    result_payload: dict[str, Any] = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "ulaz_potpuno_validirane": str(validated_path).replace("\\", "/"),
        "ulaz_potpuno_validirane_manifest": str(validated_manifest_path).replace(
            "\\", "/"
        ),
        "datum_generiranja": generated_at,
        "metodologija_bodovanja": {
            "formula": (
                "score = 100 * ukupno_preostalih_u_nizu + 10 * "
                "broj_jednoznacno_spremnih_za_paketno_zatvaranje - "
                "broj_problematnih_u_nizu"
            ),
            "deterministicki_sort": (
                "score desc, ukupno_preostalih desc, "
                "broj_jednoznacno_spremnih desc, nadredeni_kanonski_naziv asc, "
                "akt_slug asc"
            ),
        },
        "ukupan_broj_homogenih_nizova": len(ranked_sorted),
        "top_10_nizova": top10,
        "preporuceni_sljedeci_niz_za_paket": recommended,
        "napomena": (
            "Analiza je read-only i ne zatvara nove natuknice. "
            "Sluzi iskljucivo za odabir sljedeceg homogenog paketa."
        ),
    }

    if recommended is None:
        result_payload["razlog_preporuke"] = (
            "Nema preostalih nizova s jednoznacno spremnim stavkama."
        )
    else:
        result_payload["razlog_preporuke"] = (
            "Odabran je niz s najvisim deterministickim scoreom i barem jednom "
            "jednoznacno spremnom stavkom za paketno zatvaranje."
        )

    manifest_payload: dict[str, Any] = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "ulaz_potpuno_validirane": str(validated_path).replace("\\", "/"),
        "ulaz_potpuno_validirane_manifest": str(validated_manifest_path).replace(
            "\\", "/"
        ),
        "izlaz": str(output_path).replace("\\", "/"),
        "datum_generiranja": generated_at,
        "status_zadatka": "RANGIRANJE_HOMOGENIH_NIZOVA_ZAVRSENO",
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(rows),
        "ukupan_broj_potpuno_validiranih_u_ulazu": len(validated_rows),
        "ukupan_broj_homogenih_nizova": len(ranked_sorted),
        "broj_nizova_u_top_10": len(top10),
        "preporuceni_nadredeni_kanonski_naziv": (
            None if recommended is None else recommended["nadredeni_kanonski_naziv"]
        ),
        "preporuceni_akt_slug": None if recommended is None else recommended["akt_slug"],
        "preporuceni_score": None if recommended is None else recommended["score"],
        "zatvaranje_novih_natuknica_u_ovom_koraku": 0,
        "napomena": "Analiza-only korak; bez izmjene potpuno_validirane_natuknice.json.",
    }

    _write_json(output_path, result_payload)
    _write_json(output_manifest_path, manifest_payload)
    return result_payload, manifest_payload


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Rangira sljedeci homogeni niz za paketno zatvaranje (analiza-only)."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--validated", type=Path, default=DEFAULT_VALIDATED)
    parser.add_argument(
        "--validated-manifest", type=Path, default=DEFAULT_VALIDATED_MANIFEST
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    payload, manifest = run(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        validated_path=args.validated,
        validated_manifest_path=args.validated_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    top = payload.get("preporuceni_sljedeci_niz_za_paket")
    if isinstance(top, dict):
        print("TOP_PREPORUKA_BEGIN")
        print(f"NADREDENI={top.get('nadredeni_kanonski_naziv')}")
        print(f"AKT_SLUG={top.get('akt_slug')}")
        print(f"SCORE={top.get('score')}")
        print("TOP_PREPORUKA_END")
    print("RANGIRANJE_EXIT=0")
    print(f"STATUS_ZADATKA={manifest.get('status_zadatka')}")


if __name__ == "__main__":
    main()