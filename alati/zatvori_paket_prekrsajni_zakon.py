"""
Novi generički alat za zatvaranje paketa Prekršajnog zakona.

U ovom koraku postojećih 8 specijaliziranih `zatvori_paket_*`
skripti nije dirano. Migracija tih skripti u thin wrappere nije dio
ovog zadatka.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

DEFAULT_RANKING = Path(
    "baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json"
)
DEFAULT_RANKING_MANIFEST = Path(
    "baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket_manifest.json"
)
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
STATUS_PAKET_ZATVOREN = "PAKET_JEDNOZNACNIH_NATUKNICA_ZATVOREN"
STATUS_PAKET_BEZ_NOVIH = "PAKET_NEMA_NOVIH_ZATVARANJA"

EXIT_OK = 0
EXIT_RUNTIME_ERROR = 1
EXIT_USAGE_ERROR = 2


@dataclass(frozen=True)
class PackageConfig:
    cli_name: str
    target_pojam: str
    selection_mode: str
    target_akt_slug: str = "prekrsajni_zakon"
    exclude_closed_articles: tuple[str, ...] = ()
    excluded_already_processed: tuple[tuple[str, str], ...] = ()
    enforce_expected_target: bool = False
    include_analyzed_count: bool = False
    include_excluded_processed_list: bool = False
    manifest_reason_key: str | None = None
    note_prefix: str = "homogenog niza"
    sort_final_lists: bool = False
    refresh_ranking_after: bool = False


PACKAGE_CONFIGS: dict[str, PackageConfig] = {
    "apsolutna_nenadleznost": PackageConfig(
        cli_name="apsolutna_nenadleznost",
        target_pojam="apsolutna nenadležnost",
        selection_mode="fixed",
        exclude_closed_articles=("101", "102", "103", "122"),
        note_prefix="homogenog niza",
    ),
    "dokaz": PackageConfig(
        cli_name="dokaz",
        target_pojam="dokaz",
        selection_mode="fixed_ranking_manifest",
        include_analyzed_count=True,
        note_prefix="homogenog niza",
    ),
    "dostava": PackageConfig(
        cli_name="dostava",
        target_pojam="dostava",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
        ),
        include_analyzed_count=True,
        manifest_reason_key="razlog_odabira_niza",
        note_prefix="sljedeceg preporucenog homogenog niza",
    ),
    "izvrsenje": PackageConfig(
        cli_name="izvrsenje",
        target_pojam="izvršenje",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
            ("dostava", "prekrsajni_zakon"),
        ),
        enforce_expected_target=True,
        include_analyzed_count=True,
        include_excluded_processed_list=True,
        manifest_reason_key="razlog_odabira",
        note_prefix="novog homogenog niza",
        sort_final_lists=True,
    ),
    "presuda": PackageConfig(
        cli_name="presuda",
        target_pojam="presuda",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
            ("dostava", "prekrsajni_zakon"),
            ("izvršenje", "prekrsajni_zakon"),
        ),
        enforce_expected_target=True,
        include_analyzed_count=True,
        include_excluded_processed_list=True,
        manifest_reason_key="razlog_odabira",
        note_prefix="novog homogenog niza",
        sort_final_lists=True,
    ),
    "prigovor": PackageConfig(
        cli_name="prigovor",
        target_pojam="prigovor",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
            ("dostava", "prekrsajni_zakon"),
            ("izvršenje", "prekrsajni_zakon"),
            ("presuda", "prekrsajni_zakon"),
        ),
        enforce_expected_target=True,
        include_analyzed_count=True,
        include_excluded_processed_list=True,
        manifest_reason_key="razlog_odabira",
        note_prefix="novog homogenog niza",
        sort_final_lists=True,
    ),
    "rjesenje": PackageConfig(
        cli_name="rjesenje",
        target_pojam="rješenje",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
            ("dostava", "prekrsajni_zakon"),
            ("izvršenje", "prekrsajni_zakon"),
            ("presuda", "prekrsajni_zakon"),
            ("prigovor", "prekrsajni_zakon"),
        ),
        enforce_expected_target=True,
        include_analyzed_count=True,
        include_excluded_processed_list=True,
        manifest_reason_key="razlog_odabira",
        note_prefix="novog homogenog niza",
        sort_final_lists=True,
    ),
    "zalba": PackageConfig(
        cli_name="zalba",
        target_pojam="žalba",
        selection_mode="ranking_next",
        excluded_already_processed=(
            ("apsolutna nenadležnost", "prekrsajni_zakon"),
            ("dokaz", "prekrsajni_zakon"),
            ("dostava", "prekrsajni_zakon"),
            ("izvršenje", "prekrsajni_zakon"),
            ("presuda", "prekrsajni_zakon"),
            ("prigovor", "prekrsajni_zakon"),
            ("rješenje", "prekrsajni_zakon"),
        ),
        enforce_expected_target=True,
        include_analyzed_count=True,
        include_excluded_processed_list=True,
        manifest_reason_key="razlog_odabira",
        note_prefix="novog homogenog niza",
        sort_final_lists=True,
        refresh_ranking_after=True,
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


def _article_sort_key(article: str | None) -> tuple[int, int | str]:
    text = (article or "").strip()
    if text.isdigit():
        return (0, int(text))
    return (1, text)


def _selection_sort_key(row: dict[str, Any]) -> tuple[str, tuple[int, int | str], str]:
    return (
        str(row.get("kanonski_naziv_podnatuknice", "")),
        _article_sort_key(_first_article_value(row)),
        str(row.get("podnatuknica_id", "")),
    )


def _validated_identity(row: dict[str, Any]) -> tuple[str, str]:
    return (
        str(row.get("podnatuknica_id", "")).strip(),
        str(row.get("kanonski_naziv_podnatuknice", "")).strip(),
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


def _check_eligibility(
    row: dict[str, Any],
    target_pojam: str,
    target_akt: str,
) -> tuple[bool, str]:
    if _norm(row.get("nadredeni_kanonski_naziv")) != target_pojam:
        return (False, "Nije ciljni nadredeni pojam odabranog niza.")

    if _norm(row.get("akt_slug")) != target_akt:
        return (False, "Nije ciljni akt_slug odabranog niza.")

    sidra_raw = row.get("nn_sidra")
    if not isinstance(sidra_raw, list) or not sidra_raw:
        return (False, "Nema NN sidra.")

    sidra = [s for s in sidra_raw if isinstance(s, dict)]
    if not sidra:
        return (False, "NN sidra nisu valjana lista objekata.")

    act_slug = _norm(row.get("akt_slug"))
    sidro_slugs = {_norm(s.get("akt_slug")) for s in sidra}
    if sidro_slugs != {act_slug}:
        return (False, "Sidra nisu jednoznacno vezana uz jedan akt_slug.")

    signatures = {_sidro_signature(s) for s in sidra}
    if len(signatures) != 1:
        return (False, "Sidra nisu jednoznacan normativni kontekst.")

    first = sidra[0]
    if _norm(first.get("broj_nn")) != _norm(row.get("broj_nn")):
        return (False, "broj_nn u sidru i retku nije uskladen.")

    if _norm(first.get("naziv_akta")) != _norm(row.get("naziv_akta")):
        return (False, "naziv_akta u sidru i retku nije uskladen.")

    if not (
        _norm(row.get("nadredeni_kanonski_naziv"))
        and _norm(row.get("kanonski_naziv_podnatuknice"))
        and _norm(row.get("pravna_grana_ili_kontekst"))
    ):
        return (False, "Nedostaju obavezna opisna polja za potpuno zatvaranje.")

    return (True, "OK")


def _validate_recommendation(
    ranking_manifest: dict[str, Any],
    target_pojam: str,
    target_akt: str,
) -> None:
    rec_pojam = _norm(ranking_manifest.get("preporuceni_nadredeni_kanonski_naziv"))
    rec_akt = _norm(ranking_manifest.get("preporuceni_akt_slug"))
    if rec_pojam != target_pojam or rec_akt != target_akt:
        raise ValueError(
            "Preporuceni niz u rang manifestu nije uskladen sa zadanom "
            f"vrstom paketa. Dobiveno: {rec_pojam} + {rec_akt}"
        )


def _pick_target_from_ranking(
    ranking_payload: dict[str, Any],
    excluded_already_processed: tuple[tuple[str, str], ...],
) -> tuple[str, str, int, str]:
    rows_raw = ranking_payload.get("top_10_nizova", [])
    if not isinstance(rows_raw, list):
        raise ValueError("Polje 'top_10_nizova' mora biti lista.")

    excluded = set(excluded_already_processed)
    for row in rows_raw:
        if not isinstance(row, dict):
            continue

        pojam = _norm(row.get("nadredeni_kanonski_naziv"))
        akt = _norm(row.get("akt_slug"))
        if not pojam or not akt:
            continue
        if (pojam, akt) in excluded:
            continue

        score_value = row.get("score", 0)
        score = int(score_value) if isinstance(score_value, (int, float)) else 0
        razlog = (
            "Odabran je kao prvi sljedeci niz po postojecem "
            "deterministickom poretku rang-liste nakon iskljucenja vec "
            "obradenih nizova."
        )
        return (pojam, akt, score, razlog)

    raise ValueError("Nema dostupnog sljedeceg preporucenog homogenog niza.")


def _resolve_target(
    config: PackageConfig,
    ranking_payload: dict[str, Any] | None,
    ranking_manifest: dict[str, Any] | None,
) -> tuple[str, str, int | None, str | None]:
    if config.selection_mode == "fixed":
        return (config.target_pojam, config.target_akt_slug, None, None)

    if config.selection_mode == "fixed_ranking_manifest":
        if ranking_manifest is None:
            raise ValueError("Za ovu vrstu paketa obavezan je ranking manifest.")
        _validate_recommendation(
            ranking_manifest,
            config.target_pojam,
            config.target_akt_slug,
        )
        return (config.target_pojam, config.target_akt_slug, None, None)

    if config.selection_mode == "ranking_next":
        if ranking_payload is None:
            raise ValueError("Za ovu vrstu paketa obavezna je rang-lista.")

        pojam, akt, score, reason = _pick_target_from_ranking(
            ranking_payload,
            config.excluded_already_processed,
        )
        if config.enforce_expected_target and (
            pojam != config.target_pojam or akt != config.target_akt_slug
        ):
            raise ValueError(
                "Odabrani niz nije uskladen sa zadanom vrstom paketa. "
                f"Dobiveno: {pojam} + {akt}; "
                f"ocekivano: {config.target_pojam} + {config.target_akt_slug}"
            )
        return (pojam, akt, score, reason)

    raise ValueError(f"Nepoznat selection_mode: {config.selection_mode}")


def _build_note(config: PackageConfig, target_pojam: str, target_akt: str) -> str:
    return (
        f"Paketno zatvorena kao dio {config.note_prefix} "
        f"{target_pojam} — {target_akt}, uz jednoznacan normativni "
        "kontekst i dokaziva NN sidra."
    )


def _finalize_lists(
    config: PackageConfig,
    newly_closed_articles: list[str],
    newly_closed_names: list[str],
    skipped: list[dict[str, str]],
    sidra_manifest: dict[str, list[dict[str, Any]]],
) -> tuple[list[str], list[str], list[dict[str, str]], dict[str, list[dict[str, Any]]]]:
    if not config.sort_final_lists:
        return (newly_closed_articles, newly_closed_names, skipped, sidra_manifest)

    final_articles = sorted(newly_closed_articles, key=_article_sort_key)
    final_names = sorted(newly_closed_names)
    final_skipped = sorted(
        skipped,
        key=lambda item: (
            _article_sort_key(str(item.get("clanak", ""))),
            str(item.get("podnatuknica", "")),
        ),
    )

    final_sidra_manifest: dict[str, list[dict[str, Any]]] = {}
    for article in final_articles:
        final_sidra_manifest[article] = sidra_manifest.get(article, [])

    return (final_articles, final_names, final_skipped, final_sidra_manifest)


def run(
    config: PackageConfig,
    input_path: Path,
    input_manifest_path: Path,
    existing_validated_path: Path,
    existing_validated_manifest_path: Path,
    ranking_path: Path,
    ranking_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> dict[str, Any]:
    input_payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    existing_payload = _load_json(existing_validated_path)
    _ = _load_json(existing_validated_manifest_path)

    ranking_payload = None
    ranking_manifest = None
    if config.selection_mode == "ranking_next":
        ranking_payload = _load_json(ranking_path)
        ranking_manifest = _load_json(ranking_manifest_path)
    elif config.selection_mode == "fixed_ranking_manifest":
        ranking_manifest = _load_json(ranking_manifest_path)

    target_pojam, target_akt, target_score, reason = _resolve_target(
        config,
        ranking_payload,
        ranking_manifest,
    )

    branch_rows_raw = input_payload.get("granske_podnatuknice", [])
    if not isinstance(branch_rows_raw, list):
        raise ValueError("Polje 'granske_podnatuknice' mora biti lista.")

    existing_rows_raw = existing_payload.get("potpuno_validirane_natuknice", [])
    if not isinstance(existing_rows_raw, list):
        raise ValueError("Polje 'potpuno_validirane_natuknice' mora biti lista.")

    branch_rows = [row for row in branch_rows_raw if isinstance(row, dict)]
    existing_rows = [row for row in existing_rows_raw if isinstance(row, dict)]

    pocetni_broj = len(existing_rows)
    existing_identities = {_validated_identity(row) for row in existing_rows}

    package_rows = [
        row
        for row in branch_rows
        if _norm(row.get("nadredeni_kanonski_naziv")) == target_pojam
        and _norm(row.get("akt_slug")) == target_akt
    ]

    candidates: list[dict[str, Any]] = []
    skipped: list[dict[str, str]] = []

    for row in sorted(package_rows, key=_selection_sort_key):
        article = _first_article_value(row)
        name = str(row.get("kanonski_naziv_podnatuknice", "")).strip()
        identity = _validated_identity(row)

        if article in config.exclude_closed_articles:
            skipped.append(
                {
                    "clanak": article or "(nepoznat)",
                    "podnatuknica": name,
                    "razlog": (
                        "Vec zatvoreni clanak iz iskljucenog skupa "
                        f"{'/'.join(config.exclude_closed_articles)}."
                    ),
                }
            )
            continue

        if identity in existing_identities:
            skipped.append(
                {
                    "clanak": article or "(nepoznat)",
                    "podnatuknica": name,
                    "razlog": "Vec zatvorena natuknica prema podnatuknica_id + naziv.",
                }
            )
            continue

        is_ok, reason_text = _check_eligibility(row, target_pojam, target_akt)
        if is_ok:
            candidates.append(row)
        else:
            skipped.append(
                {
                    "clanak": article or "(nepoznat)",
                    "podnatuknica": name,
                    "razlog": reason_text,
                }
            )

    updated_rows = list(existing_rows)
    today = dt.date.today().isoformat()
    newly_closed_articles: list[str] = []
    newly_closed_names: list[str] = []
    sidra_manifest: dict[str, list[dict[str, Any]]] = {}

    for selected in candidates:
        sidra = [s for s in selected.get("nn_sidra", []) if isinstance(s, dict)]
        article = _first_article_value(selected)

        new_row = {
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
            "napomena_veritas": _build_note(config, target_pojam, target_akt),
        }
        updated_rows.append(new_row)

        newly_closed_articles.append(article)
        newly_closed_names.append(str(new_row.get("kanonski_naziv_podnatuknice", "")))
        sidra_manifest[article] = _sidra_for_manifest(sidra)

    (
        final_articles,
        final_names,
        final_skipped,
        final_sidra_manifest,
    ) = _finalize_lists(
        config,
        newly_closed_articles,
        newly_closed_names,
        skipped,
        sidra_manifest,
    )

    zavrsni_broj = len(updated_rows)
    status = STATUS_PAKET_ZATVOREN if final_articles else STATUS_PAKET_BEZ_NOVIH

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
        "prethodni_manifest": str(existing_validated_manifest_path).replace(
            "\\", "/"
        ),
        "pocetni_broj_potpuno_validiranih_natuknica": pocetni_broj,
        "zavrsni_broj_potpuno_validiranih_natuknica": zavrsni_broj,
        "broj_novozatvorenih_natuknica_u_paketu": len(final_articles),
        "popis_novozatvorenih_clanaka_u_paketu": final_articles,
        "popis_novozatvorenih_natuknica_u_paketu": final_names,
        "popis_preskocenih_stavki_u_paketu": final_skipped,
        "status_zadatka": status,
        "obraden_samo_homogeni_paket": True,
        "homogeni_paket": {
            "nadredeni_kanonski_naziv": target_pojam,
            "akt_slug": target_akt,
        },
        "sidra_po_novozatvorenom_clanku": final_sidra_manifest,
    }

    if config.exclude_closed_articles:
        manifest_payload["iskljuceni_vec_zatvoreni_clanci"] = sorted(
            config.exclude_closed_articles,
            key=int,
        )

    if config.include_analyzed_count:
        manifest_payload["broj_analiziranih_kandidata_u_paketu"] = len(package_rows)

    if config.selection_mode == "fixed_ranking_manifest":
        manifest_payload["ulaz_rang_manifest"] = str(ranking_manifest_path).replace(
            "\\", "/"
        )

    if config.selection_mode == "ranking_next":
        manifest_payload["ulaz_rang_lista"] = str(ranking_path).replace("\\", "/")
        manifest_payload["ulaz_rang_manifest"] = str(ranking_manifest_path).replace(
            "\\", "/"
        )
        manifest_payload["odabrani_nadredeni_kanonski_naziv"] = target_pojam
        manifest_payload["odabrani_akt_slug"] = target_akt
        manifest_payload["odabrani_score"] = target_score or 0
        if config.manifest_reason_key and reason is not None:
            manifest_payload[config.manifest_reason_key] = reason
        if config.include_excluded_processed_list:
            manifest_payload["iskljuceni_vec_obradeni_nizovi"] = [
                {
                    "nadredeni_kanonski_naziv": pojam,
                    "akt_slug": akt,
                }
                for pojam, akt in sorted(config.excluded_already_processed)
            ]

    _write_json(output_path, output_payload)
    _write_json(output_manifest_path, manifest_payload)

    refreshed_ranking = False
    if config.refresh_ranking_after:
        ranking_script = Path("alati/rangiraj_sljedeci_homogeni_niz_za_paket.py")
        subprocess.run([sys.executable, str(ranking_script)], check=True)
        refreshed_ranking = True

    return {
        "vrsta_paketa": config.cli_name,
        "target_pojam": target_pojam,
        "target_akt": target_akt,
        "target_score": target_score,
        "reason": reason,
        "pocetni_broj": pocetni_broj,
        "zavrsni_broj": zavrsni_broj,
        "analizirani": len(package_rows),
        "closed_articles": final_articles,
        "skipped": final_skipped,
        "status": status,
        "refreshed_ranking": refreshed_ranking,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generički alat za paketno zatvaranje homogenih nizova "
            "Prekršajnog zakona bez diranja postojećih specijaliziranih skripti."
        ),
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--vrsta-paketa",
        required=True,
        choices=sorted(PACKAGE_CONFIGS.keys()),
        help="Vrsta homogenog paketa koji se zatvara.",
    )
    parser.add_argument("--ranking", type=Path, default=DEFAULT_RANKING)
    parser.add_argument("--ranking-manifest", type=Path, default=DEFAULT_RANKING_MANIFEST)
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
    try:
        args = parse_args()
        config = PACKAGE_CONFIGS[args.vrsta_paketa]
        result = run(
            config=config,
            ranking_path=args.ranking,
            ranking_manifest_path=args.ranking_manifest,
            input_path=args.input,
            input_manifest_path=args.input_manifest,
            existing_validated_path=args.existing_validated,
            existing_validated_manifest_path=args.existing_validated_manifest,
            output_path=args.output,
            output_manifest_path=args.output_manifest,
        )
    except ValueError as exc:
        print(f"ERROR={exc}", file=sys.stderr)
        return EXIT_USAGE_ERROR
    except Exception as exc:  # pragma: no cover - terminal/runtime guard
        print(f"ERROR={exc}", file=sys.stderr)
        return EXIT_RUNTIME_ERROR

    print(f"VRSTA_PAKETA={result['vrsta_paketa']}")
    print(f"ODABRANI_NADREDENI={result['target_pojam']}")
    print(f"ODABRANI_AKT_SLUG={result['target_akt']}")
    if result["target_score"] is not None:
        print(f"ODABRANI_SCORE={result['target_score']}")
    if result["reason"]:
        print(f"RAZLOG_ODABIRA={result['reason']}")
    print(f"POCETNI_BROJ_POTPUNO_VALIDIRANIH={result['pocetni_broj']}")
    print(f"ZAVRSNI_BROJ_POTPUNO_VALIDIRANIH={result['zavrsni_broj']}")
    print(f"BROJ_ANALIZIRANIH_KANDIDATA_U_PAKETU={result['analizirani']}")
    print(f"BROJ_NOVOZATVORENIH_U_PAKETU={len(result['closed_articles'])}")
    print(f"NOVOZATVORENI_CLANCI={','.join(result['closed_articles'])}")
    print(f"BROJ_PRESKOCENIH_U_PAKETU={len(result['skipped'])}")
    print(f"STATUS_PAKETA={result['status']}")
    if result["refreshed_ranking"]:
        print("RANG_LISTA_OSVJEZENA=True")
    return EXIT_OK


if __name__ == "__main__":
    raise SystemExit(main())
