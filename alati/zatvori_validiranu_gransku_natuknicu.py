from __future__ import annotations

# NAPOMENA:
# Ovo je novi genericki alat za zatvaranje validirane granske natuknice.
# Postojece 4 skripte iz skupine u ovom koraku nisu dirane.
# Migracija wrappera na ovaj alat nije dio ovog zadatka.

import argparse
import datetime as dt
import json
from dataclasses import dataclass
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
STATUS_NIJE_PRONADEN_KANDIDAT = "NIJE_PRONADEN_KANDIDAT"


@dataclass(frozen=True)
class ModeConfig:
    nacin: str
    requires_existing: bool
    sort_with_article: bool
    allow_empty_result: bool
    manifest_status_when_closed: str
    parser_description: str
    row_note: str
    previous_field_style: str
    selected_reason: str | None = None


MODE_CONFIGS: dict[str, ModeConfig] = {
    "prva": ModeConfig(
        nacin="prva",
        requires_existing=False,
        sort_with_article=False,
        allow_empty_result=False,
        manifest_status_when_closed="PILOT_POTPUNO_VALIDIRANO_ZATVOREN",
        parser_description=(
            "Deterministicki zatvara prvu potpuno validiranu gransku "
            "natuknicu po jednom generickom alatu."
        ),
        row_note=(
            "Zatvorena je kao prva po kanonskom sortiranju medu "
            "podnatuknicama koje imaju jedan akt_slug, jednoznacan "
            "normativni kontekst i nekontradiktorna dokaziva NN sidra; "
            "dodatno razbijanje nije potrebno."
        ),
        previous_field_style="none",
        selected_reason=(
            "Prva po uzlaznom sortiranju kanonski_naziv_podnatuknice medu "
            "podnatuknicama koje zadovoljavaju sva pravila odabira."
        ),
    ),
    "druga": ModeConfig(
        nacin="druga",
        requires_existing=True,
        sort_with_article=False,
        allow_empty_result=True,
        manifest_status_when_closed="DRUGA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA",
        parser_description=(
            "Deterministicki zatvara drugu potpuno validiranu gransku "
            "natuknicu ili evidentira da kandidata nema."
        ),
        row_note=(
            "Zatvorena je kao sljedeca po kanonskom sortiranju nakon vec "
            "zatvorene natuknice, uz jednoznacan kontekst, jedan akt_slug i "
            "nekontradiktorna dokaziva NN sidra."
        ),
        previous_field_style="single",
    ),
    "sljedeca": ModeConfig(
        nacin="sljedeca",
        requires_existing=True,
        sort_with_article=True,
        allow_empty_result=True,
        manifest_status_when_closed="SLJEDECA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA",
        parser_description=(
            "Deterministicki zatvara sljedecu potpuno validiranu gransku "
            "natuknicu ili evidentira da kandidata nema."
        ),
        row_note=(
            "Zatvorena je kao sljedeca po kanonskom sortiranju uz pravilo "
            "kanonski_naziv_podnatuknice pa clanak, uz jednoznacan kontekst, "
            "jedan akt_slug i nekontradiktorna dokaziva NN sidra."
        ),
        previous_field_style="list",
        selected_reason=(
            "Kandidat je odabran deterministicki nakon iskljucenja vec "
            "zatvorenih natuknica, po sortiranju "
            "kanonski_naziv_podnatuknice pa clanak."
        ),
    ),
    "jos_jedna": ModeConfig(
        nacin="jos_jedna",
        requires_existing=True,
        sort_with_article=True,
        allow_empty_result=True,
        manifest_status_when_closed=(
            "JOS_JEDNA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA"
        ),
        parser_description=(
            "Deterministicki zatvara jos jednu potpuno validiranu gransku "
            "natuknicu ili evidentira da kandidata nema."
        ),
        row_note=(
            "Zatvorena je kao sljedeca po kanonskom sortiranju uz pravilo "
            "kanonski_naziv_podnatuknice pa clanak, uz jednoznacan kontekst, "
            "jedan akt_slug i nekontradiktorna dokaziva NN sidra."
        ),
        previous_field_style="list",
        selected_reason=(
            "Kandidat je odabran deterministicki nakon iskljucenja vec "
            "zatvorenih natuknica, po sortiranju "
            "kanonski_naziv_podnatuknice pa clanak."
        ),
    ),
}


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


def _first_article_value(row: dict[str, Any]) -> str:
    sidra = row.get("nn_sidra")
    if not isinstance(sidra, list) or not sidra:
        return ""
    first = sidra[0]
    if not isinstance(first, dict):
        return ""
    return _norm(first.get("clanak")) or ""


def _article_sort_key(article: str) -> tuple[int, int | str]:
    text = article.strip()
    if text.isdigit():
        return (0, int(text))
    return (1, text)


def _selection_sort_key(
    row: dict[str, Any],
    *,
    sort_with_article: bool,
) -> tuple[str, str | tuple[int, int | str], str]:
    name = str(row.get("kanonski_naziv_podnatuknice", ""))
    row_id = str(row.get("podnatuknica_id", ""))
    if sort_with_article:
        return (name, _article_sort_key(_first_article_value(row)), row_id)
    return (name, row_id, row_id)


def _has_clear_act_slug(row: dict[str, Any], sidra: list[dict[str, Any]]) -> bool:
    act_slug = _norm(row.get("akt_slug"))
    if not act_slug:
        return False
    sidro_slugs = {_norm(s.get("akt_slug")) for s in sidra}
    return sidro_slugs == {act_slug}


def _has_unambiguous_context(sidra: list[dict[str, Any]]) -> bool:
    signatures = {_sidro_signature(s) for s in sidra}
    return len(signatures) == 1


def _has_no_contradictory_sidra(
    row: dict[str, Any],
    sidra: list[dict[str, Any]],
) -> bool:
    if not _has_unambiguous_context(sidra):
        return False
    first = sidra[0]
    return (
        _norm(first.get("akt_slug")) == _norm(row.get("akt_slug"))
        and _norm(first.get("broj_nn")) == _norm(row.get("broj_nn"))
        and _norm(first.get("naziv_akta")) == _norm(row.get("naziv_akta"))
    )


def _can_describe_without_invented_definition(
    row: dict[str, Any],
    sidra: list[dict[str, Any]],
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
    sidra = [sidro for sidro in sidra_raw if isinstance(sidro, dict)]
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


def _build_validated_row(
    selected: dict[str, Any],
    sidra: list[dict[str, Any]],
    *,
    row_note: str,
) -> dict[str, Any]:
    today = dt.date.today().isoformat()
    return {
        "nadredeni_pojam_id": selected.get("nadredeni_pojam_id"),
        "nadredeni_kanonski_naziv": selected.get("nadredeni_kanonski_naziv"),
        "podnatuknica_id": selected.get("podnatuknica_id"),
        "kanonski_naziv_podnatuknice": selected.get(
            "kanonski_naziv_podnatuknice"
        ),
        "pravna_grana_ili_kontekst": selected.get("pravna_grana_ili_kontekst"),
        "naziv_akta": selected.get("naziv_akta"),
        "akt_slug": selected.get("akt_slug"),
        "broj_nn": selected.get("broj_nn"),
        "nn_sidra": sidra,
        "status_podnatuknice": STATUS_POTPUNO_VALIDIRANO,
        "datum_validacije": today,
        "izvor_validacije": IZVOR_VALIDACIJE,
        "napomena_veritas": row_note,
    }


def _parse_branch_rows(payload: dict[str, Any]) -> list[dict[str, Any]]:
    rows_raw = payload.get("granske_podnatuknice", [])
    if not isinstance(rows_raw, list):
        raise ValueError("Polje 'granske_podnatuknice' mora biti lista.")
    return [row for row in rows_raw if isinstance(row, dict)]


def _parse_existing_rows(payload: dict[str, Any]) -> list[dict[str, Any]]:
    rows_raw = payload.get("potpuno_validirane_natuknice", [])
    if not isinstance(rows_raw, list):
        raise ValueError("Polje 'potpuno_validirane_natuknice' mora biti lista.")
    return [row for row in rows_raw if isinstance(row, dict)]


def run(
    *,
    nacin: str,
    input_path: Path,
    input_manifest_path: Path,
    existing_validated_path: Path,
    existing_validated_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> dict[str, Any]:
    if nacin not in MODE_CONFIGS:
        allowed = ", ".join(sorted(MODE_CONFIGS.keys()))
        raise ValueError(f"Nepodrzan nacin rada: {nacin}. Dozvoljeno: {allowed}")

    config = MODE_CONFIGS[nacin]
    input_payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    branch_rows = _parse_branch_rows(input_payload)

    existing_rows: list[dict[str, Any]] = []
    existing_manifest: dict[str, Any] = {}

    if config.requires_existing:
        existing_payload = _load_json(existing_validated_path)
        existing_manifest = _load_json(existing_validated_manifest_path)
        existing_rows = _parse_existing_rows(existing_payload)

    existing_identities = {_validated_identity(row) for row in existing_rows}
    existing_names = [
        str(row.get("kanonski_naziv_podnatuknice", "")).strip()
        for row in existing_rows
        if str(row.get("kanonski_naziv_podnatuknice", "")).strip()
    ]

    eligible: list[dict[str, Any]] = []
    for row in branch_rows:
        if config.requires_existing and _validated_identity(row) in existing_identities:
            continue
        if _is_eligible(row):
            eligible.append(row)

    if not eligible and not config.allow_empty_result:
        raise ValueError(
            "Nije pronadena nijedna podnatuknica koja zadovoljava pravilo "
            "odabira."
        )

    selected_name = "NIJE_ZATVORENA_NOVA_NATUKNICA"
    selected_sidra_count = 0
    status = config.manifest_status_when_closed
    reason_if_not_closed = (
        "Nema preostalih podnatuknica koje zadovoljavaju strogi model "
        "(jednoznacan kontekst, jedan akt_slug, nekontradiktorna dokaziva "
        "sidra, bez duplikata vec zatvorenih)."
    )

    updated_rows = list(existing_rows)
    selected_sidra_for_manifest: list[dict[str, Any]] = []

    if eligible:
        selected = sorted(
            eligible,
            key=lambda row: _selection_sort_key(
                row,
                sort_with_article=config.sort_with_article,
            ),
        )[0]
        sidra = [sidro for sidro in selected.get("nn_sidra", []) if isinstance(sidro, dict)]
        validated_row = _build_validated_row(selected, sidra, row_note=config.row_note)

        if config.requires_existing:
            updated_rows.append(validated_row)
        else:
            updated_rows = [validated_row]

        selected_name = str(validated_row.get("kanonski_naziv_podnatuknice", ""))
        selected_sidra_count = len(sidra)
        selected_sidra_for_manifest = _sidra_for_manifest(sidra)
    else:
        status = STATUS_NIJE_PRONADEN_KANDIDAT

    output_payload = {
        "ulaz": str(input_path).replace("\\", "/"),
        "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
        "ukupan_broj_granskih_podnatuknica_u_ulazu": len(branch_rows),
        "ukupan_broj_zatvorenih_natuknica": len(updated_rows),
        "potpuno_validirane_natuknice": updated_rows,
    }

    if config.nacin == "prva":
        manifest_payload: dict[str, Any] = {
            "ulaz": str(input_path).replace("\\", "/"),
            "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
            "izlaz": str(output_path).replace("\\", "/"),
            "ukupan_broj_granskih_podnatuknica_u_ulazu": len(branch_rows),
            "naziv_odabrane_podnatuknice": selected_name,
            "razlog_odabira": config.selected_reason,
            "broj_potvrdenih_sidara_u_odabranoj_natuknici": selected_sidra_count,
            "popis_sidara_u_odabranoj_natuknici": selected_sidra_for_manifest,
            "zatvorena_samo_jedna_natuknica": bool(selected_sidra_count > 0),
            "ukupan_broj_zatvorenih_u_ovom_zadatku": len(updated_rows),
            "status_zadataka": status,
        }
    else:
        manifest_payload = {
            "ulaz": str(input_path).replace("\\", "/"),
            "ulaz_manifest": str(input_manifest_path).replace("\\", "/"),
            "izlaz": str(output_path).replace("\\", "/"),
            "prethodni_manifest": str(existing_validated_manifest_path).replace(
                "\\",
                "/",
            ),
            "ukupan_broj_granskih_podnatuknica_u_ulazu": len(branch_rows),
            "pocetni_broj_potpuno_validiranih_natuknica": len(existing_rows),
            "zavrsni_broj_potpuno_validiranih_natuknica": len(updated_rows),
            "naziv_novo_zatvorene_natuknice": selected_name,
            "broj_potvrdenih_sidara_u_novo_zatvorenoj_natuknici": (
                selected_sidra_count
            ),
            "status_zadataka": status,
            "zatvorena_samo_jedna_nova_natuknica_u_ovom_zadatku": (
                len(updated_rows) == len(existing_rows) + (1 if selected_sidra_count else 0)
            ),
        }

        if config.previous_field_style == "single":
            manifest_payload["prethodno_zatvorena_natuknica"] = existing_manifest.get(
                "naziv_odabrane_podnatuknice"
            )
        elif config.previous_field_style == "list":
            manifest_payload["prethodno_zatvorene_natuknice"] = existing_names

        if selected_sidra_count > 0:
            if config.selected_reason is not None:
                manifest_payload["razlog_odabira"] = config.selected_reason
            manifest_payload["popis_sidara_u_novo_zatvorenoj_natuknici"] = (
                selected_sidra_for_manifest
            )
        else:
            manifest_payload["razlog_nezatvaranja"] = reason_if_not_closed
            manifest_payload["popis_sidara_u_novo_zatvorenoj_natuknici"] = []

    _write_json(output_path, output_payload)
    _write_json(output_manifest_path, manifest_payload)

    return {
        "nacin": nacin,
        "ukupno_ulaznih": len(branch_rows),
        "pocetni_broj": len(existing_rows),
        "zavrsni_broj": len(updated_rows),
        "naziv": selected_name,
        "broj_sidara": selected_sidra_count,
        "status": status,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Genericki alat za deterministicko zatvaranje validirane granske "
            "natuknice bez diranja postojecih wrapper skripti."
        )
    )
    parser.add_argument(
        "--nacin",
        required=True,
        choices=sorted(MODE_CONFIGS.keys()),
        help="Odabir ponasanja: prva, druga, sljedeca ili jos_jedna.",
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument(
        "--existing-validated",
        type=Path,
        default=DEFAULT_EXISTING_VALIDATED,
        help="Postojeci skup zatvorenih natuknica za append modove.",
    )
    parser.add_argument(
        "--existing-validated-manifest",
        type=Path,
        default=DEFAULT_EXISTING_VALIDATED_MANIFEST,
        help="Manifest postojeceg skupa zatvorenih natuknica.",
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    try:
        args = parse_args()
        result = run(
            nacin=args.nacin,
            input_path=args.input,
            input_manifest_path=args.input_manifest,
            existing_validated_path=args.existing_validated,
            existing_validated_manifest_path=args.existing_validated_manifest,
            output_path=args.output,
            output_manifest_path=args.output_manifest,
        )
    except Exception as exc:
        print(f"ERROR={exc}")
        return 1

    if args.nacin == "prva":
        print(f"ULAZNE_GRANSKE_PODNATUKNICE={result['ukupno_ulaznih']}")
        print(f"ODABRANA_PODNATUKNICA={result['naziv']}")
        print(f"BROJ_POTVRDENIH_SIDARA={result['broj_sidara']}")
        print(f"ZAVRSNI_STATUS={STATUS_POTPUNO_VALIDIRANO}")
        return 0

    print(f"POCETNI_BROJ_POTPUNO_VALIDIRANIH={result['pocetni_broj']}")
    print(f"ZAVRSNI_BROJ_POTPUNO_VALIDIRANIH={result['zavrsni_broj']}")
    print(f"NOVO_ZATVORENA_NATUKNICA={result['naziv']}")
    print(f"BROJ_POTVRDENIH_SIDARA={result['broj_sidara']}")
    print(f"ZAVRSNI_STATUS={result['status']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
