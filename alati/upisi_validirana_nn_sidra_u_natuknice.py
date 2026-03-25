from __future__ import annotations

import argparse
import collections
import json
from datetime import date
from pathlib import Path
from typing import Any

DEFAULT_INPUT_CANDIDATES = Path(
    "baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju.json"
)
DEFAULT_INPUT_CANDIDATES_MANIFEST = Path(
    "baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju_manifest.json"
)
DEFAULT_INPUT_BASE = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran_manifest.json"
)

TARGET_POJMOVI = [
    "dokaz",
    "dostava",
    "izvršenje",
    "presuda",
    "prigovor",
    "rješenje",
    "žalba",
    "apsolutna nenadležnost",
]

STATUS_VALIDIRANO = "NN_VALIDIRANO"
STATUS_DJELOMICNO = "NN_DJELOMICNO_VALIDIRANO"
STATUS_CEKA = "CEKA_DALJNJU_RUCNU_VALIDACIJU"


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


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


def _candidate_key(candidate: dict[str, Any]) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _norm(candidate.get("naziv_akta")),
        _norm(candidate.get("broj_nn")),
        _norm(candidate.get("clanak")),
        _norm(candidate.get("stavak")),
        _norm(candidate.get("tocka")),
    )


def _sidro_key(sidro: dict[str, Any]) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _norm(sidro.get("naziv_akta")),
        _norm(sidro.get("broj_nn")),
        _norm(sidro.get("clanak")),
        _norm(sidro.get("stavak")),
        _norm(sidro.get("tocka")),
    )


def _sort_key(key: tuple[str | None, str | None, str | None, str | None, str | None]) -> tuple[str, str, str, str, str]:
    return tuple(part or "" for part in key)


def run_validation(
    candidates_path: Path,
    candidates_manifest_path: Path,
    base_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> int:
    candidates_payload = _load_json(candidates_path)
    _ = _load_json(candidates_manifest_path)
    base_payload = _load_json(base_path)

    candidates = candidates_payload.get("konacni_nn_kandidati_za_validaciju", [])
    base_entries = base_payload.get("natuknice", [])

    if not isinstance(candidates, list):
        raise ValueError("Polje 'konacni_nn_kandidati_za_validaciju' mora biti lista.")
    if not isinstance(base_entries, list):
        raise ValueError("Polje 'natuknice' mora biti lista.")

    grouped_candidates: dict[str, list[dict[str, Any]]] = collections.defaultdict(list)
    for candidate in candidates:
        if not isinstance(candidate, dict):
            continue
        parent = str(candidate.get("nadredeni_kanonski_naziv", "")).strip()
        grouped_candidates[parent].append(candidate)

    today = date.today().strftime("%d.%m.%Y.")

    status_counts: collections.Counter[str] = collections.Counter()
    potvrdena_po_pojmu: dict[str, list[dict[str, Any]]] = {}
    pojmovi_bez_konacne: list[str] = []
    report_rows: list[tuple[str, int, int, str]] = []

    for entry in base_entries:
        if not isinstance(entry, dict):
            continue

        pojam = str(entry.get("kanonski_naziv", "")).strip()
        if pojam not in TARGET_POJMOVI:
            continue

        pojam_candidates = grouped_candidates.get(pojam, [])
        candidate_by_key = {
            _candidate_key(c): c
            for c in pojam_candidates
            if isinstance(c, dict)
        }

        sidra_in_entry = entry.get("nn_sidra", {}).get("sidra", [])
        if not isinstance(sidra_in_entry, list):
            sidra_in_entry = []

        potvrdena_sidra: list[dict[str, Any]] = []
        for sidro in sidra_in_entry:
            if not isinstance(sidro, dict):
                continue
            key = _sidro_key(sidro)
            if key in candidate_by_key:
                sidro_copy = dict(sidro)
                sidro_copy["napomena"] = (
                    "Potvrđeno ručnom validacijom kao relevantan normativni "
                    "kontekst; višeznačnost nije potpuno zatvorena."
                )
                potvrdena_sidra.append(sidro_copy)

        # U ovom koraku ručne validacije ne biramo jedno 'pobjedničko' sidro,
        # nego potvrđujemo skup konteksta koji su ručno prihvaćeni iz ulaza.
        if len(potvrdena_sidra) == 0:
            new_status = STATUS_CEKA
            sidra_status = "NEJASNO"
            napomena = (
                "Ručna validacija nije potvrdila konačno sidro; pojam ostaje "
                "otvoren za daljnji pregled."
            )
        elif len(potvrdena_sidra) == 1:
            new_status = STATUS_VALIDIRANO
            sidra_status = "OK"
            napomena = (
                "Ručnom validacijom potvrđeno jedno konačno NN sidro."
            )
        else:
            new_status = STATUS_DJELOMICNO
            sidra_status = "VISE_MOGUCIH_SIDARA"
            napomena = (
                "Ručnom validacijom potvrđen skup relevantnih sidara; "
                "višeznačnost nije potpuno zatvorena."
            )

        entry["nn_sidra"] = {
            "status_sidra": sidra_status,
            "sidra": sorted(
                potvrdena_sidra,
                key=lambda s: _sort_key(_sidro_key(s)),
            ),
        }
        entry["status_validacije"] = new_status
        entry["napomena_veritas"] = napomena
        entry["datum_validacije"] = today
        entry["izvor_validacije"] = "rucna_validacija"

        status_counts[new_status] += 1
        if new_status != STATUS_VALIDIRANO:
            pojmovi_bez_konacne.append(pojam)

        potvrdena_po_pojmu[pojam] = [
            {
                "naziv_akta": s.get("naziv_akta"),
                "broj_nn": s.get("broj_nn"),
                "clanak": s.get("clanak"),
                "stavak": s.get("stavak"),
                "tocka": s.get("tocka"),
            }
            for s in entry["nn_sidra"]["sidra"]
        ]

        report_rows.append((pojam, len(pojam_candidates), len(potvrdena_sidra), new_status))

    output_payload = {
        "ulaz_kandidati": candidates_path.as_posix(),
        "ulaz_kandidati_manifest": candidates_manifest_path.as_posix(),
        "ulaz_osnovni_skup": base_path.as_posix(),
        "datum_validacije": today,
        "izvor_validacije": "rucna_validacija",
        "ukupan_broj_natuknica": len(base_entries),
        "natuknice": base_entries,
    }
    _write_json(output_path, output_payload)

    output_manifest = {
        "ulaz_kandidati": candidates_path.as_posix(),
        "ulaz_kandidati_manifest": candidates_manifest_path.as_posix(),
        "ulaz_osnovni_skup": base_path.as_posix(),
        "izlaz": output_path.as_posix(),
        "datum_validacije": today,
        "izvor_validacije": "rucna_validacija",
        "ukupan_broj_pojmova_u_ulazu": len(TARGET_POJMOVI),
        "broj_potpuno_validiranih": status_counts.get(STATUS_VALIDIRANO, 0),
        "broj_djelomicno_validiranih": status_counts.get(STATUS_DJELOMICNO, 0),
        "broj_ceka_daljnju_validaciju": status_counts.get(STATUS_CEKA, 0),
        "potvrdena_sidra_po_nadredenom_pojmu": {
            k: potvrdena_po_pojmu.get(k, [])
            for k in TARGET_POJMOVI
        },
        "pojmovi_bez_konacne_odluke": sorted(pojmovi_bez_konacne),
    }
    _write_json(output_manifest_path, output_manifest)

    for pojam, ulaz, potvrdeno, status in sorted(report_rows, key=lambda row: row[0]):
        print(
            "VALIDACIJA_POJAM="
            f"{pojam}|ULAZNI_KANDIDATI={ulaz}|POTVRDENA_SIDRA={potvrdeno}|"
            f"STATUS={status}"
        )

    print(f"STATUS_COUNT_{STATUS_VALIDIRANO}={status_counts.get(STATUS_VALIDIRANO, 0)}")
    print(
        "STATUS_COUNT_"
        f"{STATUS_DJELOMICNO}={status_counts.get(STATUS_DJELOMICNO, 0)}"
    )
    print(f"STATUS_COUNT_{STATUS_CEKA}={status_counts.get(STATUS_CEKA, 0)}")
    print(f"OUTPUT_PATH={output_path.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={output_manifest_path.as_posix()}")

    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Upisuje ručno validirana NN sidra u osnovni postupovni skup."
    )
    parser.add_argument("--input-candidates", type=Path, default=DEFAULT_INPUT_CANDIDATES)
    parser.add_argument(
        "--input-candidates-manifest",
        type=Path,
        default=DEFAULT_INPUT_CANDIDATES_MANIFEST,
    )
    parser.add_argument("--input-base", type=Path, default=DEFAULT_INPUT_BASE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.input_candidates.exists():
        print(f"ERROR: Nedostaje ulazna datoteka kandidata: {args.input_candidates}")
        return 2
    if not args.input_candidates_manifest.exists():
        print(
            "ERROR: Nedostaje ulazni manifest kandidata: "
            f"{args.input_candidates_manifest}"
        )
        return 3
    if not args.input_base.exists():
        print(f"ERROR: Nedostaje ulazna datoteka osnovnog skupa: {args.input_base}")
        return 4

    return run_validation(
        candidates_path=args.input_candidates,
        candidates_manifest_path=args.input_candidates_manifest,
        base_path=args.input_base,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )


if __name__ == "__main__":
    raise SystemExit(main())
