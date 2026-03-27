from __future__ import annotations

import argparse
import datetime as dt
import json
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

EXCLUDED_ALREADY_PROCESSED = {
    ("apsolutna nenadležnost", "prekrsajni_zakon"),
    ("dokaz", "prekrsajni_zakon"),
}

STATUS_POTPUNO_VALIDIRANO = "POTPUNO_VALIDIRANO"
IZVOR_VALIDACIJE = "rucna_validacija"
STATUS_PAKET_ZATVOREN = "PAKET_JEDNOZNACNIH_NATUKNICA_ZATVOREN"
STATUS_PAKET_BEZ_NOVIH = "PAKET_NEMA_NOVIH_ZATVARANJA"


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


def _pick_target_from_ranking(
    ranking_payload: dict[str, Any],
) -> tuple[str, str, int, str]:
    rows_raw = ranking_payload.get("top_10_nizova", [])
    if not isinstance(rows_raw, list):
        raise ValueError("Polje 'top_10_nizova' mora biti lista.")

    for row in rows_raw:
        if not isinstance(row, dict):
            continue
        pojam = _norm(row.get("nadredeni_kanonski_naziv"))
        akt = _norm(row.get("akt_slug"))
        if not pojam or not akt:
            continue
        if (pojam, akt) in EXCLUDED_ALREADY_PROCESSED:
            continue

        score_value = row.get("score", 0)
        score = int(score_value) if isinstance(score_value, (int, float)) else 0
        razlog = (
            "Odabran je kao prvi sljedeci niz po postojecem deterministickom "
            "poretku rang-liste nakon iskljucenja vec obradenih nizova "
            "apsolutna nenadležnost + prekrsajni_zakon i dokaz + prekrsajni_zakon."
        )
        return (pojam, akt, score, razlog)

    raise ValueError("Nema dostupnog sljedeceg preporucenog homogenog niza.")


def _check_eligibility(row: dict[str, Any], target_pojam: str, target_akt: str) -> tuple[bool, str]:
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


def run(
    ranking_path: Path,
    ranking_manifest_path: Path,
    input_path: Path,
    input_manifest_path: Path,
    existing_validated_path: Path,
    existing_validated_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[str, str, int, str, int, int, int, list[str], list[dict[str, str]], str]:
    ranking_payload = _load_json(ranking_path)
    _ = _load_json(ranking_manifest_path)
    input_payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)
    existing_payload = _load_json(existing_validated_path)
    _ = _load_json(existing_validated_manifest_path)

    target_pojam, target_akt, target_score, razlog_odabira = _pick_target_from_ranking(
        ranking_payload
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

        if identity in existing_identities:
            skipped.append(
                {
                    "clanak": article or "(nepoznat)",
                    "podnatuknica": name,
                    "razlog": "Vec zatvorena natuknica prema podnatuknica_id + naziv.",
                }
            )
            continue

        is_ok, reason = _check_eligibility(row, target_pojam, target_akt)
        if is_ok:
            candidates.append(row)
        else:
            skipped.append(
                {
                    "clanak": article or "(nepoznat)",
                    "podnatuknica": name,
                    "razlog": reason,
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
                "Paketno zatvorena kao dio sljedeceg preporucenog homogenog niza "
                f"{target_pojam} — {target_akt}, uz jednoznacan normativni "
                "kontekst i dokaziva NN sidra."
            ),
        }
        updated_rows.append(new_row)

        newly_closed_articles.append(article)
        newly_closed_names.append(str(new_row.get("kanonski_naziv_podnatuknice", "")))
        sidra_manifest[article] = _sidra_for_manifest(sidra)

    zavrsni_broj = len(updated_rows)
    status = STATUS_PAKET_ZATVOREN if newly_closed_articles else STATUS_PAKET_BEZ_NOVIH

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
        "ulaz_rang_lista": str(ranking_path).replace("\\", "/"),
        "ulaz_rang_manifest": str(ranking_manifest_path).replace("\\", "/"),
        "izlaz": str(output_path).replace("\\", "/"),
        "prethodni_manifest": str(existing_validated_manifest_path).replace("\\", "/"),
        "odabrani_nadredeni_kanonski_naziv": target_pojam,
        "odabrani_akt_slug": target_akt,
        "odabrani_score": target_score,
        "razlog_odabira_niza": razlog_odabira,
        "pocetni_broj_potpuno_validiranih_natuknica": pocetni_broj,
        "zavrsni_broj_potpuno_validiranih_natuknica": zavrsni_broj,
        "broj_analiziranih_kandidata_u_paketu": len(package_rows),
        "broj_novozatvorenih_natuknica_u_paketu": len(newly_closed_articles),
        "popis_novozatvorenih_clanaka_u_paketu": newly_closed_articles,
        "popis_novozatvorenih_natuknica_u_paketu": newly_closed_names,
        "popis_preskocenih_stavki_u_paketu": skipped,
        "status_zadatka": status,
        "obraden_samo_homogeni_paket": True,
        "homogeni_paket": {
            "nadredeni_kanonski_naziv": target_pojam,
            "akt_slug": target_akt,
        },
        "iskljuceni_vec_obradeni_nizovi": [
            {
                "nadredeni_kanonski_naziv": pojam,
                "akt_slug": akt,
            }
            for pojam, akt in sorted(EXCLUDED_ALREADY_PROCESSED)
        ],
        "sidra_po_novozatvorenom_clanku": sidra_manifest,
    }

    _write_json(output_path, output_payload)
    _write_json(output_manifest_path, manifest_payload)

    return (
        target_pojam,
        target_akt,
        target_score,
        razlog_odabira,
        pocetni_broj,
        zavrsni_broj,
        len(package_rows),
        newly_closed_articles,
        skipped,
        status,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Paketno zatvara jednoznacne natuknice iz sljedeceg preporucenog "
            "homogenog niza prema postojecoj rang-listi."
        )
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
    args = parse_args()
    (
        target_pojam,
        target_akt,
        target_score,
        reason,
        pocetni,
        zavrsni,
        analizirani,
        closed_articles,
        skipped,
        status,
    ) = run(
        ranking_path=args.ranking,
        ranking_manifest_path=args.ranking_manifest,
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        existing_validated_path=args.existing_validated,
        existing_validated_manifest_path=args.existing_validated_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"ODABRANI_NADREDENI={target_pojam}")
    print(f"ODABRANI_AKT_SLUG={target_akt}")
    print(f"ODABRANI_SCORE={target_score}")
    print(f"RAZLOG_ODABIRA={reason}")
    print(f"POCETNI_BROJ_POTPUNO_VALIDIRANIH={pocetni}")
    print(f"ZAVRSNI_BROJ_POTPUNO_VALIDIRANIH={zavrsni}")
    print(f"BROJ_ANALIZIRANIH_KANDIDATA_U_PAKETU={analizirani}")
    print(f"BROJ_NOVOZATVORENIH_U_PAKETU={len(closed_articles)}")
    print(f"NOVOZATVORENI_CLANCI={','.join(closed_articles)}")
    print(f"BROJ_PRESKOCENIH_U_PAKETU={len(skipped)}")
    print(f"STATUS_PAKETA={status}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())