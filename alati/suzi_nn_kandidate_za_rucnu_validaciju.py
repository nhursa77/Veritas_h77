from __future__ import annotations

import argparse
import collections
import hashlib
import json
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju_manifest.json"
)

STATUS_FINAL = "SPREMAN_ZA_RUČNU_VALIDACIJU"
OZN_GRUPIRAN = "GRUPIRAN_ISTI_KONTEKST"
OZN_ZADRZAN_AKT = "ZADRŽAN_RAZLIČIT_AKT"
OZN_ZADRZAN_KONTEKST = "ZADRŽAN_RAZLIČIT_KONTEKST"


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


def _context_key(candidate: dict[str, Any]) -> tuple[str | None, str | None, str | None, str | None, str | None]:
    return (
        _norm(candidate.get("naziv_akta")),
        _norm(candidate.get("broj_nn")),
        _norm(candidate.get("clanak")),
        _norm(candidate.get("stavak")),
        _norm(candidate.get("tocka")),
    )


def _stable_final_id(parent_id: str, context_key: tuple[str | None, str | None, str | None, str | None, str | None]) -> str:
    joined = "|".join([parent_id, *[part or "NULL" for part in context_key]])
    digest = hashlib.sha256(joined.encode("utf-8")).hexdigest()[:12]
    return f"VH77-KPNNF-{digest}"


def _safe(value: str | None, fallback: str) -> str:
    if value is None:
        return fallback
    stripped = value.strip()
    return stripped if stripped else fallback


def _name_from_context(parent_name: str, candidate: dict[str, Any]) -> str:
    act_slug = _safe(_norm(candidate.get("akt_slug")), "(nepoznat_slug)")
    clanak = _safe(_norm(candidate.get("clanak")), "(nepoznat_clanak)")
    stavak = _safe(_norm(candidate.get("stavak")), "null")
    tocka = _safe(_norm(candidate.get("tocka")), "null")
    return f"{parent_name} — {act_slug} — {clanak} — s{stavak} — t{tocka}"


def narrow_candidates(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, dict[str, int], dict[str, int]]:
    payload = _load_json(input_path)
    _ = _load_json(input_manifest_path)

    candidates = payload.get("kandidatske_podnatuknice_v2", [])
    if not isinstance(candidates, list):
        raise ValueError("Polje 'kandidatske_podnatuknice_v2' mora biti lista.")

    grouped_by_parent: dict[tuple[str, str], list[dict[str, Any]]] = collections.defaultdict(list)
    for candidate in candidates:
        if not isinstance(candidate, dict):
            continue
        parent_id = str(candidate.get("nadredeni_pojam_id", "")).strip()
        parent_name = str(candidate.get("nadredeni_kanonski_naziv", "")).strip()
        grouped_by_parent[(parent_id, parent_name)].append(candidate)

    final_candidates: list[dict[str, Any]] = []
    grouped_records: list[dict[str, Any]] = []
    retained_records: list[dict[str, Any]] = []

    before_by_parent: dict[str, int] = {}
    after_by_parent: dict[str, int] = {}

    for (parent_id, parent_name), parent_candidates in sorted(
        grouped_by_parent.items(), key=lambda item: item[0][1]
    ):
        before_by_parent[parent_name] = len(parent_candidates)

        by_context: dict[
            tuple[str | None, str | None, str | None, str | None, str | None],
            list[dict[str, Any]],
        ] = collections.defaultdict(list)

        for candidate in parent_candidates:
            by_context[_context_key(candidate)].append(candidate)

        acts_in_parent = {
            _safe(_norm(c.get("naziv_akta")), "")
            for c in parent_candidates
        }
        multiple_acts = len(acts_in_parent) > 1

        parent_final_count = 0
        for context_key, same_context_candidates in sorted(
            by_context.items(), key=lambda item: tuple(part or "" for part in item[0])
        ):
            sample = same_context_candidates[0]
            final_candidate = {
                "nadredeni_pojam_id": parent_id,
                "nadredeni_kanonski_naziv": parent_name,
                "kandidat_id": _stable_final_id(parent_id, context_key),
                "kanonski_naziv_kandidata": _name_from_context(parent_name, sample),
                "naziv_akta": _safe(_norm(sample.get("naziv_akta")), "(nepoznat_akt)"),
                "akt_slug": _safe(_norm(sample.get("akt_slug")), "(nepoznat_slug)"),
                "broj_nn": _safe(_norm(sample.get("broj_nn")), "(nepoznat_nn)"),
                "clanak": _safe(_norm(sample.get("clanak")), "(nepoznat_clanak)"),
                "stavak": _norm(sample.get("stavak")),
                "tocka": _norm(sample.get("tocka")),
                "izvor_putanja": _safe(
                    _norm(sample.get("izvor_putanja")),
                    "(nepoznata_putanja)",
                ),
                "status_kandidata": STATUS_FINAL,
                "zahtijeva_rucnu_validaciju": True,
                "oznaka_suzavanja": "",
            }

            if len(same_context_candidates) > 1:
                final_candidate["oznaka_suzavanja"] = OZN_GRUPIRAN
                final_candidate["grupirano_iz_kandidata"] = sorted(
                    str(c.get("kandidat_id", "")).strip()
                    for c in same_context_candidates
                )
                grouped_records.append(
                    {
                        "nadredeni_kanonski_naziv": parent_name,
                        "kontekst": {
                            "naziv_akta": final_candidate["naziv_akta"],
                            "broj_nn": final_candidate["broj_nn"],
                            "clanak": final_candidate["clanak"],
                            "stavak": final_candidate["stavak"],
                            "tocka": final_candidate["tocka"],
                        },
                        "broj_spojenih_kandidata": len(same_context_candidates),
                        "spojeni_kandidat_ids": final_candidate["grupirano_iz_kandidata"],
                        "rezultat_kandidat_id": final_candidate["kandidat_id"],
                    }
                )
            else:
                oznaka = OZN_ZADRZAN_AKT if multiple_acts else OZN_ZADRZAN_KONTEKST
                final_candidate["oznaka_suzavanja"] = oznaka
                retained_records.append(
                    {
                        "nadredeni_kanonski_naziv": parent_name,
                        "kandidat_id": final_candidate["kandidat_id"],
                        "oznaka": oznaka,
                        "kontekst": {
                            "naziv_akta": final_candidate["naziv_akta"],
                            "broj_nn": final_candidate["broj_nn"],
                            "clanak": final_candidate["clanak"],
                            "stavak": final_candidate["stavak"],
                            "tocka": final_candidate["tocka"],
                        },
                    }
                )

            final_candidates.append(final_candidate)
            parent_final_count += 1

        after_by_parent[parent_name] = parent_final_count
        print(
            "SUZAVANJE_PO_POJMU="
            f"{parent_name}|PRIJE={before_by_parent[parent_name]}|"
            f"POSLIJE={after_by_parent[parent_name]}"
        )

    out_payload = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "ukupan_broj_v2_kandidata": len(candidates),
        "ukupan_broj_konacnih_kandidata": len(final_candidates),
        "konacni_nn_kandidati_za_validaciju": final_candidates,
    }
    _write_json(output_path, out_payload)

    comparison: dict[str, dict[str, int]] = {}
    for parent_name in sorted(before_by_parent.keys()):
        before = before_by_parent[parent_name]
        after = after_by_parent.get(parent_name, 0)
        comparison[parent_name] = {
            "prije": before,
            "poslije": after,
            "delta": after - before,
        }

    out_manifest = {
        "ulazna_datoteka": input_path.as_posix(),
        "ulazni_manifest": input_manifest_path.as_posix(),
        "naziv_izlazne_datoteke": output_path.as_posix(),
        "ukupan_broj_v2_kandidata": len(candidates),
        "ukupan_broj_konacnih_kandidata": len(final_candidates),
        "broj_kandidata_po_nadredenom_pojmu": {
            "prije": dict(sorted(before_by_parent.items())),
            "poslije": dict(sorted(after_by_parent.items())),
        },
        "broj_grupiranih_kandidata": len(grouped_records),
        "broj_zadrzanih_kandidata": len(retained_records),
        "popis_grupiranih_kandidata": grouped_records,
        "popis_zadrzanih_kandidata": retained_records,
        "usporedba_prije_poslije": comparison,
    }
    _write_json(output_manifest_path, out_manifest)

    return len(candidates), len(final_candidates), before_by_parent, after_by_parent


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sužava v2 NN kandidate u konačne podnatuknice za ručnu validaciju."
    )
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--input-manifest", type=Path, default=DEFAULT_INPUT_MANIFEST)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--output-manifest", type=Path, default=DEFAULT_OUTPUT_MANIFEST)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.input.exists():
        print(f"ERROR: Nedostaje ulazna datoteka: {args.input}")
        return 2
    if not args.input_manifest.exists():
        print(f"ERROR: Nedostaje ulazni manifest: {args.input_manifest}")
        return 3

    total_before, total_after, before_by_parent, after_by_parent = narrow_candidates(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"UKUPNO_PRIJE={total_before}")
    print(f"UKUPNO_POSLIJE={total_after}")
    print(f"UKUPNO_DELTA={total_after - total_before}")

    for parent_name in sorted(before_by_parent.keys()):
        print(
            "POJAM_PRIJE_POSLIJE="
            f"{parent_name}|PRIJE={before_by_parent[parent_name]}|"
            f"POSLIJE={after_by_parent.get(parent_name, 0)}"
        )

    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
