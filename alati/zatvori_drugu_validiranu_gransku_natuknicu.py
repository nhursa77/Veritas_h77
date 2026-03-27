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
DEFAULT_EXISTING_VALIDATED = Path(
    "baza_terminologije/rjecnik/potpuno_validirane_natuknice.json"
)
DEFAULT_EXISTING_VALIDATED_MANIFEST = Path(
    "baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json"
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


def _selection_sort_key(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(row.get("kanonski_naziv_podnatuknice", "")),
        str(row.get("podnatuknica_id", "")),
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


def _can_describe_without_invented_definition(
    row: dict[str, Any], sidra: list[dict[str, Any]]
) -> bool:
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


def _sidra_for_manifest(sidra: list[dict[str, Any]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for sidro in sidra:
        rows.append(
            {
                "akt_slug": _norm(sidro.get("akt_slug")),
                "broj_nn": _norm(sidro.get("broj_nn")),
                "clanak": _norm(sidro.get("clanak")),
                "stavak": _norm(sidro.get("stavak")),
                "tocka": _norm(sidro.get("tocka")),
                "izvor_putanja": _norm(sidro.get("izvor_putanja")),
            }
        )
    return rows


def _validated_identity(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(row.get("podnatuknica_id", "")).strip(),
        str(row.get("kanonski_naziv_podnatuknice", "")).strip(),
    )


def run(
    input_path: Path,
    input_manifest_path: Path,
    existing_validated_path: Path,
    existing_validated_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, str, int, str]:
    input_payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    existing_payload = _load_json(existing_validated_path)
    previous_manifest = _load_json(existing_validated_manifest_path)

    branch_rows_raw = input_payload.get("granske_podnatuknice", [])
    if not isinstance(branch_rows_raw, list):
        raise ValueError("Polje 'granske_podnatuknice' mora biti lista.")

    existing_rows_raw = existing_payload.get("potpuno_validirane_natuknice", [])
    if not isinstance(existing_rows_raw, list):
        raise ValueError("Polje 'potpuno_validirane_natuknice' mora biti lista.")

    branch_rows = [row for row in branch_rows_raw if isinstance(row, dict)]
    existing_rows = [row for row in existing_rows_raw if isinstance(row, dict)]

    existing_identities = {_validated_identity(row) for row in existing_rows}

    eligible: list[dict[str, Any]] = []
    for row in branch_rows:
        identity = _validated_identity(row)
        if identity in existing_identities:
            continue
        if _is_eligible(row):
            eligible.append(row)

    pocetni_broj = len(existing_rows)
    selected_name = "NIJE_ZATVORENA_NOVA_NATUKNICA"
    selected_sidra_count = 0
    status = "NIJE_PRONADEN_KANDIDAT"
    reason_if_not_closed = ""

    updated_rows = list(existing_rows)

    if eligible:
        selected = sorted(eligible, key=_selection_sort_key)[0]
        sidra = [s for s in selected.get("nn_sidra", []) if isinstance(s, dict)]
        today = dt.date.today().isoformat()

        new_row = {
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
                "Zatvorena je kao sljedeca po kanonskom sortiranju nakon vec "
                "zatvorene natuknice, uz jednoznacan kontekst, jedan akt_slug i "
                "nekontradiktorna dokaziva NN sidra."
            ),
        }
        updated_rows.append(new_row)

        selected_name = str(new_row.get("kanonski_naziv_podnatuknice", ""))
        selected_sidra_count = len(sidra)
        status = "DRUGA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA"
    else:
        reason_if_not_closed = (
            "Nema preostalih podnatuknica koje zadovoljavaju strogi model "
            "(jednoznacan kontekst, jedan akt_slug, nekontradiktorna dokaziva "
            "sidra, bez duplikata vec zatvorenih)."
        )

    zavrsni_broj = len(updated_rows)

    output_payload = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(branch_rows),
        "ukupan_broj_zatvorenih_natuknica": zavrsni_broj,
        "potpuno_validirane_natuknice": updated_rows,
    }

    manifest_payload: dict[str, Any] = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "izlaz": str(output_path).replace("\\", "/"),
        "prethodni_manifest": str(existing_validated_manifest_path).replace("\\", "/"),
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(branch_rows),
        "pocetni_broj_potpuno_validiranih_natuknica": pocetni_broj,
        "zavrsni_broj_potpuno_validiranih_natuknica": zavrsni_broj,
        "naziv_novo_zatvorene_natuknice": selected_name,
        "broj_potvrdenih_sidara_u_novo_zatvorenoj_natuknici": selected_sidra_count,
        "status_zadataka": status,
        "zatvorena_samo_jedna_nova_natuknica_u_ovom_zadatku": (
            zavrsni_broj == pocetni_broj + 1
        ),
        "prethodno_zatvorena_natuknica": previous_manifest.get(
            "naziv_odabrane_podnatuknice"
        ),
    }

    if selected_sidra_count > 0:
        last_row = updated_rows[-1]
        sidra_last = [s for s in last_row.get("nn_sidra", []) if isinstance(s, dict)]
        manifest_payload["popis_sidara_u_novo_zatvorenoj_natuknici"] = _sidra_for_manifest(
            sidra_last
        )
    else:
        manifest_payload["razlog_nezatvaranja"] = reason_if_not_closed
        manifest_payload["popis_sidara_u_novo_zatvorenoj_natuknici"] = []

    _write_json(output_path, output_payload)
    _write_json(output_manifest_path, manifest_payload)

    return (pocetni_broj, zavrsni_broj, selected_name, selected_sidra_count, status)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Deterministicki zatvara drugu potpuno validiranu gransku natuknicu "
            "ili evidentira da kandidata nema."
        )
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--existing-validated", type=Path, default=DEFAULT_EXISTING_VALIDATED)
    parser.add_argument(
        "--existing-validated-manifest",
        type=Path,
        default=DEFAULT_EXISTING_VALIDATED_MANIFEST,
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    pocetni, zavrsni, naziv, broj_sidara, status = run(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        existing_validated_path=args.existing_validated,
        existing_validated_manifest_path=args.existing_validated_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"POCETNI_BROJ_POTPUNO_VALIDIRANIH={pocetni}")
    print(f"ZAVRSNI_BROJ_POTPUNO_VALIDIRANIH={zavrsni}")
    print(f"NOVO_ZATVORENA_NATUKNICA={naziv}")
    print(f"BROJ_POTVRDENIH_SIDARA={broj_sidara}")
    print(f"ZAVRSNI_STATUS={status}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
