from __future__ import annotations

import argparse
import collections
import hashlib
import json
import re
import unicodedata
from pathlib import Path
from typing import Any

DEFAULT_INPUT = Path(
    "baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi.json"
)
DEFAULT_INPUT_MANIFEST = Path(
    "baza_terminologije/mape/eu_prema_nn/"
    "nn_sidrenju_podobni_pojmovi_manifest.json"
)
DEFAULT_OUTPUT = Path(
    "baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice.json"
)
DEFAULT_OUTPUT_MANIFEST = Path(
    "baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice_manifest.json"
)

ALLOWED_VRSTA_POJMA = {
    "PROCESNI_POJAM",
    "PRAVNI_INSTITUT",
    "PRAVNA_RADNJA",
    "PRAVNI_AKT",
    "TIJELO_ILI_NADLEZNOST",
    "ROK",
    "DOKAZNO_SREDSTVO",
    "STATUS_ILI_SVOJSTVO",
    "SANKCIJA",
    "TROSAK_ILI_PRISTOJBA",
    "NEKLASIFICIRANO",
}

POUZDANOST_RANK = {"NISKA": 1, "SREDNJA": 2, "VISOKA": 3}

GENERIC_EQUIVALENT = {
    "",
    "term",
    "validated",
    "not validated",
    "yes",
    "no",
    "ad hoc",
    "preferred",
    "obsolete",
    "eu",
    "n/a",
}

RE_UPPER_SHORT = re.compile(r"^[A-Z0-9]{2,10}$")
RE_TWO_LETTER = re.compile(r"^[a-z]{2}$")
RE_ONLY_DIGITS = re.compile(r"^\d+$")

KEYWORDS = {
    "TIJELO_ILI_NADLEZNOST": [
        "sud",
        "court",
        "tribunal",
        "nadleznost",
        "jurisdiction",
        "tijelo",
        "authority",
        "ministarstvo",
        "agencija",
    ],
    "ROK": ["rok", "deadline", "time limit", "period", "zastara"],
    "DOKAZNO_SREDSTVO": ["dokaz", "evidence", "iskaz", "vjestacenje"],
    "SANKCIJA": ["kazna", "sankcija", "penalty", "globa"],
    "TROSAK_ILI_PRISTOJBA": [
        "trosak",
        "pristojba",
        "naknada",
        "cost",
        "fee",
        "placanj",
    ],
    "STATUS_ILI_SVOJSTVO": [
        "apsolutna",
        "relativna",
        "nadlezan",
        "nenadleznost",
        "pravomoc",
        "status",
    ],
    "PRAVNA_RADNJA": [
        "tuzba",
        "zalba",
        "prigovor",
        "zahtjev",
        "podnesak",
        "ovrha",
        "izvrsenje",
        "dostava",
    ],
    "PRAVNI_AKT": [
        "rjesenje",
        "presuda",
        "odluka",
        "zakljucak",
        "naredba",
        "akt",
    ],
    "PRAVNI_INSTITUT": [
        "law",
        "zakon",
        "procedural law",
        "criminal law",
        "constitutional law",
        "administrative law",
        "civil law",
        "family law",
        "postupak",
        "procedure",
        "pravo",
    ],
}


def _load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def _norm(value: Any) -> str:
    text = "" if value is None else str(value)
    normalized = unicodedata.normalize("NFKD", text.casefold())
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    ascii_text = re.sub(r"\s+", " ", ascii_text).strip()
    return ascii_text


def _clean_text(value: Any) -> str:
    if value is None:
        return ""
    text = str(value)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def _is_noise_equivalent(text: str) -> bool:
    norm = _norm(text)
    if norm in GENERIC_EQUIVALENT:
        return True
    if RE_ONLY_DIGITS.fullmatch(norm):
        return True
    if RE_TWO_LETTER.fullmatch(norm):
        return True
    return False


def _choose_confidence(values: list[str]) -> str:
    if not values:
        return "NISKA"
    valid = [v for v in values if v in POUZDANOST_RANK]
    if not valid:
        return "NISKA"
    return max(valid, key=lambda v: POUZDANOST_RANK[v])


def _detect_vrsta_pojma(
    naziv_norm: str,
    osnove_podobnosti: set[str],
) -> str:
    if not naziv_norm:
        return "NEKLASIFICIRANO"

    # Ako tehnička oznaka eksplicitno navodi procesni pojam, zadržava se ista.
    if "PROCESNI_POJAM" in osnove_podobnosti:
        return "PROCESNI_POJAM"

    if any(keyword in naziv_norm for keyword in KEYWORDS["TIJELO_ILI_NADLEZNOST"]):
        return "TIJELO_ILI_NADLEZNOST"
    if any(keyword in naziv_norm for keyword in KEYWORDS["ROK"]):
        return "ROK"
    if any(keyword in naziv_norm for keyword in KEYWORDS["DOKAZNO_SREDSTVO"]):
        return "DOKAZNO_SREDSTVO"
    if any(keyword in naziv_norm for keyword in KEYWORDS["SANKCIJA"]):
        return "SANKCIJA"
    if any(keyword in naziv_norm for keyword in KEYWORDS["TROSAK_ILI_PRISTOJBA"]):
        return "TROSAK_ILI_PRISTOJBA"

    if "AKT_ILI_RADNJA" in osnove_podobnosti:
        if any(keyword in naziv_norm for keyword in KEYWORDS["PRAVNI_AKT"]):
            return "PRAVNI_AKT"
        if any(keyword in naziv_norm for keyword in KEYWORDS["PRAVNA_RADNJA"]):
            return "PRAVNA_RADNJA"
        return "NEKLASIFICIRANO"

    if any(keyword in naziv_norm for keyword in KEYWORDS["STATUS_ILI_SVOJSTVO"]):
        return "STATUS_ILI_SVOJSTVO"
    if any(keyword in naziv_norm for keyword in KEYWORDS["PRAVNI_INSTITUT"]):
        return "PRAVNI_INSTITUT"

    return "NEKLASIFICIRANO"


def _make_pojam_id(kanonski_naziv: str) -> str:
    digest = hashlib.sha1(_norm(kanonski_naziv).encode("utf-8")).hexdigest()[:12]
    return f"VH77-RJ-{digest}"


def _extract_equivalent_texts(records: list[dict[str, Any]]) -> list[str]:
    texts: list[str] = []
    for record in records:
        raw_values = record.get("curia_ekvivalenti", [])
        if not isinstance(raw_values, list):
            continue
        for value in raw_values:
            text = _clean_text(value)
            if not text:
                continue
            if _is_noise_equivalent(text):
                continue
            texts.append(text)
    unique = sorted(set(texts), key=lambda t: (_norm(t), t))
    return unique


def _split_equivalents(
    kanonski_naziv: str,
    candidate_forms: list[str],
    equivalent_texts: list[str],
) -> tuple[list[str], list[str], list[str], list[str]]:
    canonical_norm = _norm(kanonski_naziv)

    synonyms: set[str] = set()
    writing_variants: set[str] = set()
    foreign_equivalents: set[str] = set()
    abbreviations: set[str] = set()

    for value in candidate_forms:
        text = _clean_text(value)
        if not text:
            continue
        norm = _norm(text)
        if norm == canonical_norm:
            if text != kanonski_naziv:
                writing_variants.add(text)
            continue
        synonyms.add(text)

    for value in equivalent_texts:
        text = _clean_text(value)
        if not text:
            continue
        norm = _norm(text)
        if norm == canonical_norm:
            continue
        if RE_UPPER_SHORT.fullmatch(text):
            abbreviations.add(text)
            continue
        if any(ch in text for ch in ["č", "ć", "š", "ž", "đ"]):
            synonyms.add(text)
            continue
        if " " in text and any(c.isalpha() for c in text):
            foreign_equivalents.add(text)

    return (
        sorted(synonyms, key=lambda t: (_norm(t), t)),
        sorted(writing_variants, key=lambda t: (_norm(t), t)),
        sorted(foreign_equivalents, key=lambda t: (_norm(t), t)),
        sorted(abbreviations, key=lambda t: (_norm(t), t)),
    )


def build_entries(
    input_path: Path,
    input_manifest_path: Path,
    output_path: Path,
    output_manifest_path: Path,
) -> tuple[int, int, collections.Counter[str], int, int, list[tuple[str, int]]]:
    payload = _load_json(input_path)
    input_manifest = _load_json(input_manifest_path)

    records = payload.get("zapisi", [])
    if not isinstance(records, list):
        raise ValueError("Polje 'zapisi' mora biti lista.")

    grouped: dict[str, list[dict[str, Any]]] = collections.defaultdict(list)
    name_counter: collections.Counter[str] = collections.Counter()

    for record in records:
        if not isinstance(record, dict):
            continue
        naziv = _clean_text(record.get("predlozeni_nn_pojam", ""))
        if not naziv:
            continue
        norm = _norm(naziv)
        if not norm:
            continue
        grouped[norm].append(record)
        name_counter[naziv] += 1

    natuknice: list[dict[str, Any]] = []
    vrsta_counter: collections.Counter[str] = collections.Counter()
    status_counter: collections.Counter[str] = collections.Counter()
    empty_nn_sidra = 0

    for norm_name in sorted(grouped.keys()):
        group = grouped[norm_name]

        canonical_variants = [
            _clean_text(g.get("predlozeni_nn_pojam", "")) for g in group
        ]
        canonical_variants = [v for v in canonical_variants if v]
        canonical_counts = collections.Counter(canonical_variants)
        kanonski_naziv = sorted(
            canonical_counts.items(), key=lambda kv: (-kv[1], _norm(kv[0]), kv[0])
        )[0][0]

        osnove_podobnosti = {
            str(g.get("osnova_podobnosti", "")).strip()
            for g in group
            if g.get("osnova_podobnosti") is not None
        }
        vrsta_pojma = _detect_vrsta_pojma(_norm(kanonski_naziv), osnove_podobnosti)
        if vrsta_pojma not in ALLOWED_VRSTA_POJMA:
            vrsta_pojma = "NEKLASIFICIRANO"

        confidence_values = [str(g.get("razina_pouzdanosti", "")).strip() for g in group]
        razina_pouzdanosti = _choose_confidence(confidence_values)

        equivalent_texts = _extract_equivalent_texts(group)
        synonymi, varijante, strani_ekvivalenti, kratice = _split_equivalents(
            kanonski_naziv,
            canonical_variants,
            equivalent_texts,
        )

        natuknica = {
            "pojam_id": _make_pojam_id(kanonski_naziv),
            "kanonski_naziv": kanonski_naziv,
            "sinonimi": synonymi,
            "varijante_pisanja": varijante,
            "strani_ekvivalenti": strani_ekvivalenti,
            "kratice": kratice,
            "vrsta_pojma": vrsta_pojma,
            "definicija_jezicna": None,
            "definicija_procesna": None,
            "definicija_normativna": None,
            "napomena_veritas": None,
            "nn_sidra": {},
            "povezani_pojmovi": [],
            "tipicne_pogreske": [],
            "status_validacije": "CEKA_NN_SIDRO",
            "razina_pouzdanosti": razina_pouzdanosti,
        }

        natuknice.append(natuknica)
        vrsta_counter[vrsta_pojma] += 1
        status_counter[natuknica["status_validacije"]] += 1
        if not natuknica["nn_sidra"]:
            empty_nn_sidra += 1

    output_payload = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(records),
        "ukupan_broj_generiranih_natuknica": len(natuknice),
        "natuknice": natuknice,
    }
    _write_json(output_path, output_payload)

    top_30_kanonskih_naziva = sorted(
        name_counter.items(), key=lambda kv: (-kv[1], _norm(kv[0]), kv[0])
    )[:30]

    output_manifest = {
        "ulazna_datoteka": str(input_path.as_posix()),
        "ulazni_manifest": str(input_manifest_path.as_posix()),
        "naziv_izlazne_datoteke": str(output_path.as_posix()),
        "ukupan_broj_ulaznih_zapisa": len(records),
        "ukupan_broj_generiranih_natuknica": len(natuknice),
        "broj_natuknica_po_vrsta_pojma": dict(sorted(vrsta_counter.items())),
        "broj_natuknica_po_status_validacije": dict(sorted(status_counter.items())),
        "broj_natuknica_s_praznim_nn_sidra": empty_nn_sidra,
        "top_30_kanonskih_naziva": [
            {"kanonski_naziv": name, "broj": count}
            for name, count in top_30_kanonskih_naziva
        ],
        "status_validacije_default": "CEKA_NN_SIDRO",
        "ulazni_segmenti": input_manifest.get("ulazni_segmenti", []),
    }
    _write_json(output_manifest_path, output_manifest)

    return (
        len(records),
        len(natuknice),
        vrsta_counter,
        empty_nn_sidra,
        status_counter.get("CEKA_NN_SIDRO", 0),
        top_30_kanonskih_naziva,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Gradi početni skup rječničkih natuknica bez NN sidra."
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

    (
        total_in,
        total_entries,
        by_vrsta,
        empty_nn_sidra,
        status_ceka,
        top30,
    ) = build_entries(
        input_path=args.input,
        input_manifest_path=args.input_manifest,
        output_path=args.output,
        output_manifest_path=args.output_manifest,
    )

    print(f"INPUT_RECORDS={total_in}")
    print(f"GENERATED_ENTRIES={total_entries}")
    for vrsta, count in sorted(by_vrsta.items()):
        print(f"BY_VRSTA={vrsta}:{count}")
    print(f"EMPTY_NN_SIDRA={empty_nn_sidra}")
    print(f"STATUS_CEKA_NN_SIDRO={status_ceka}")
    for name, count in top30:
        print(f"TOP30_KANONSKI_NAZIV={name} => {count}")
    print(f"OUTPUT_PATH={args.output.as_posix()}")
    print(f"OUTPUT_MANIFEST_PATH={args.output_manifest.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
