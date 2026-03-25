from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path("baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json")
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json"
)
DEFAULT_OUTPUT = Path("baza_terminologije/rjecnik/potpuno_validirane_natuknice.json")
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json"
)

STATUS_POTPUNO_VALIDIRANO = "POTPUNO_VALIDIRANO"
IZVOR_VALIDACIJE = "rucna_validacija"


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError(f"Ocekivan je JSON objekt: {path}")
    return data


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


def _sidro_signature(sidro: dict[str, Any]) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _norm(sidro.get("akt_slug")),
        _norm(sidro.get("broj_nn")),
        _norm(sidro.get("clanak")),
        _norm(sidro.get("stavak")),
        _norm(sidro.get("tocka")),
    )


def _has_clear_act_slug(row: dict[str, Any], sidra: list[dict[str, Any]]) -> bool:
    act_slug = _norm(row.get("akt_slug"))
    if not act_slug:
        return False
    sidro_slugs = {_norm(s.get("akt_slug")) for s in sidra}
    return sidro_slugs == {act_slug}


def _has_unambiguous_context(sidra: list[dict[str, Any]]) -> bool:
    signatures = {_sidro_signature(s) for s in sidra}
    return len(signatures) == 1


def _has_no_contradictory_sidra(row: dict[str, Any], sidra: list[dict[str, Any]]) -> bool:
    if not _has_unambiguous_context(sidra):
        return False
    first = sidra[0]
    return (
        _norm(first.get("akt_slug")) == _norm(row.get("akt_slug"))
        and _norm(first.get("broj_nn")) == _norm(row.get("broj_nn"))
        and _norm(first.get("naziv_akta")) == _norm(row.get("naziv_akta"))
    )


def _can_describe_without_invented_definition(row: dict[str, Any], sidra: list[dict[str, Any]]) -> bool:
    return bool(
        _norm(row.get("nadredeni_kanonski_naziv"))
        and _norm(row.get("kanonski_naziv_podnatuknice"))
        and _norm(row.get("pravna_grana_ili_kontekst"))
        and sidra
    )


def _does_not_require_additional_split(sidra: list[dict[str, Any]]) -> bool:
    signatures = {_sidro_signature(s) for s in sidra}
    return len(signatures) == 1


def _is_eligible(row: dict[str, Any]) -> bool:
    sidra_raw = row.get("nn_sidra")
    if not isinstance(sidra_raw, list) or not sidra_raw:
        return False
    sidra = [s for s in sidra_raw if isinstance(s, dict)]
    if not sidra:
        return False

    return all(
        [
            _has_clear_act_slug(row, sidra),
            _has_unambiguous_context(sidra),
            _has_no_contradictory_sidra(row, sidra),
            _can_describe_without_invented_definition(row, sidra),
            _does_not_require_additional_split(sidra),
        ]
    )


def _selection_sort_key(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(row.get("kanonski_naziv_podnatuknice", "")),
        str(row.get("podnatuknica_id", "")),
    )


def _sidra_for_manifest(sidra: list[dict[str, Any]]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for sidro in sidra:
        out.append(
            {
                "akt_slug": _norm(sidro.get("akt_slug")),
                "broj_nn": _norm(sidro.get("broj_nn")),
                "clanak": _norm(sidro.get("clanak")),
                "stavak": _norm(sidro.get("stavak")),
                "tocka": _norm(sidro.get("tocka")),
                "izvor_putanja": _norm(sidro.get("izvor_putanja")),
            }
        )
    return out


def run(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, str, int, str]:
    payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)

    rows = payload.get("granske_podnatuknice", [])
    if not isinstance(rows, list):
        raise ValueError("Polje 'granske_podnatuknice' mora biti lista.")

    eligible = [row for row in rows if isinstance(row, dict) and _is_eligible(row)]
    if not eligible:
        raise ValueError("Nije pronadena nijedna podnatuknica koja zadovoljava pravilo odabira.")

    selected = sorted(eligible, key=_selection_sort_key)[0]
    sidra = [s for s in selected.get("nn_sidra", []) if isinstance(s, dict)]
    today = dt.date.today().isoformat()

    validated_row = {
        "nadredeni_pojam_id": selected.get("nadredeni_pojam_id"),
        "nadredeni_kanonski_naziv": selected.get("nadredeni_kanonski_naziv"),
        "podnatuknica_id": selected.get("podnatuknica_id"),
        "kanonski_naziv_podnatuknice": selected.get("kanonski_naziv_podnatuknice"),
        "pravna_grana_ili_kontekst": selected.get("pravna_grana_ili_kontekst"),
        "naziv_akta": selected.get("naziv_akta"),
        "akt_slug": selected.get("akt_slug"),
        "broj_nn": selected.get("broj_nn"),
        "nn_sidra": sidra,
        "status_podnatuknice": STATUS_POTPUNO_VALIDIRANO,
        "datum_validacije": today,
        "izvor_validacije": IZVOR_VALIDACIJE,
        "napomena_veritas": (
            "Zatvorena je kao prva po kanonskom sortiranju medu podnatuknicama "
            "koje imaju jedan akt_slug, jednoznacan normativni kontekst i "
            "nekontradiktorna dokaziva NN sidra; dodatno razbijanje nije potrebno."
        ),
    }

    output_payload = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(rows),
        "ukupan_broj_zatvorenih_natuknica": 1,
        "potpuno_validirane_natuknice": [validated_row],
    }

    manifest_payload = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "izlaz": str(output_path).replace("\\", "/"),
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(rows),
        "naziv_odabrane_podnatuknice": selected.get("kanonski_naziv_podnatuknice"),
        "razlog_odabira": (
            "Prva po uzlaznom sortiranju kanonski_naziv_podnatuknice medu "
            "podnatuknicama koje zadovoljavaju sva pravila odabira."
        ),
        "broj_potvrdenih_sidara_u_odabranoj_natuknici": len(sidra),
        "popis_sidara_u_odabranoj_natuknici": _sidra_for_manifest(sidra),
        "zatvorena_samo_jedna_natuknica": True,
        "ukupan_broj_zatvorenih_u_ovom_zadatku": 1,
        "status_zadataka": "PILOT_POTPUNO_VALIDIRANO_ZATVOREN",
    }

    _write_json(output_path, output_payload)
    _write_json(output_manifest_path, manifest_payload)

    return (
        len(rows),
        str(selected.get("kanonski_naziv_podnatuknice", "")),
        len(sidra),
        STATUS_POTPUNO_VALIDIRANO,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Zatvara prvu potpuno validiranu gransku natuknicu po deterministicnom pravilu."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    ukupno, naziv, broj_sidara, status = run(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"ULAZNE_GRANSKE_PODNATUKNICE={ukupno}")
    print(f"ODABRANA_PODNATUKNICA={naziv}")
    print(f"BROJ_POTVRDENIH_SIDARA={broj_sidara}")
    print(f"ZAVRSNI_STATUS={status}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
