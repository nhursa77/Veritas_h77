from __future__ import annotations

import argparse
import hashlib
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Any


def sha256_upper_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest().upper()


def sha256_upper_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest().upper()


def kanoniziraj_lf(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def danas_hr() -> str:
    return datetime.now().strftime("%d.%m.%Y.")


def normaliziraj_datum(datum: str) -> str:
    raw = (datum or "").strip()
    if not raw:
        return danas_hr()

    try:
        parsed = datetime.strptime(raw, "%d.%m.%Y.")
        return parsed.strftime("%d.%m.%Y.")
    except ValueError:
        pass

    try:
        parsed = datetime.strptime(raw, "%d.%m.%Y")
        return parsed.strftime("%d.%m.%Y.")
    except ValueError:
        return danas_hr()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Normiratelj iz strukture NN u NORMA JSON")
    parser.add_argument("--akt-slug", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--meta", required=True)
    parser.add_argument("--out-dir", required=True)
    return parser


def normalize_clanak_oznaka(raw_value: Any) -> tuple[str, str] | None:
    if isinstance(raw_value, int):
        broj = raw_value
        return str(broj), f"{broj:04d}"

    if isinstance(raw_value, str):
        raw = raw_value.strip()
        if not raw:
            return None
        compact = re.sub(r"\s+", "", raw)
        match = re.match(r"^(\d{1,4})(?:[\._\-/]?([A-Za-z]{1,3}))?$", compact)
        if not match:
            return None

        broj = int(match.group(1))
        suffix_raw = match.group(2)
        suffix = suffix_raw.lower() if suffix_raw else ""
        oznaka = f"{broj}{suffix}"
        file_token = f"{broj:04d}{suffix}"
        return oznaka, file_token

    return None


def extract_doc_split(struktura: dict[str, Any]) -> tuple[dict[str, Any], list[dict[str, Any]], list[dict[str, Any]], bool]:
    akt = struktura.get("akt") if isinstance(struktura.get("akt"), dict) else {}
    dokumenti = struktura.get("dokumenti") if isinstance(struktura.get("dokumenti"), list) else None

    if dokumenti is None:
        clanci_flat = struktura.get("clanci") if isinstance(struktura.get("clanci"), list) else []
        return akt, clanci_flat, [], False

    procisceni = next(
        (
            d for d in dokumenti
            if isinstance(d, dict) and str(d.get("doc_id") or "").strip() == "ustav_rh_procisceni"
        ),
        None,
    )
    amandmani = next(
        (
            d for d in dokumenti
            if isinstance(d, dict) and str(d.get("doc_id") or "").strip() == "ustav_rh_amandmani"
        ),
        None,
    )

    procisceni_clanci = procisceni.get("clanci") if isinstance(procisceni, dict) and isinstance(procisceni.get("clanci"), list) else []
    amandmani_clanci = amandmani.get("clanci") if isinstance(amandmani, dict) and isinstance(amandmani.get("clanci"), list) else []
    return akt, procisceni_clanci, amandmani_clanci, True


def create_norma_payload(
    akt: dict[str, Any],
    clanak: dict[str, Any],
    oznaka: str,
    meta: dict[str, Any],
    stanje_na_dan: str,
    datum_provjere: str,
) -> dict[str, Any]:
    tekst = kanoniziraj_lf(str(clanak["tekst"]).strip())

    oznaka_akta = meta.get("oznaka_akta")
    sidro_obj = {
        "nn_broj": oznaka_akta if isinstance(oznaka_akta, str) and oznaka_akta.strip() else None,
        "datum_objave": None,
        "opis": "službena objava",
        "url": meta.get("url"),
    }

    payload: dict[str, Any] = {
        "akt": {
            "naziv": akt.get("naziv"),
            "vrsta": akt.get("vrsta"),
            "slug": akt.get("slug"),
            "jurisdikcija": akt.get("jurisdikcija", "RH"),
            "jezik": akt.get("jezik", "hr"),
        },
        "clanak": {
            "oznaka": oznaka,
            "naslov": clanak.get("naslov"),
            "tekst": tekst,
            "struktura": {
                "stavci": None,
            },
        },
        "verzija": {
            "stanje_na_dan": stanje_na_dan,
            "datum_provjere": datum_provjere,
            "napomena": "Normirano iz NN strukture.",
        },
        "izvori": {
            "operativni_izvor": {
                "naziv": "Narodne novine",
                "url": meta.get("url"),
                "datum_pristupa": stanje_na_dan,
            },
            "dokazni_izvor": {
                "naziv": "Narodne novine",
                "sidra": [sidro_obj],
            },
            "status_sidra": "puno",
        },
        "integritet": {
            "sha256_teksta": sha256_upper_text(tekst),
            "sha256_datoteke": None,
            "napomena": None,
        },
    }

    return payload


def main() -> int:
    args = build_parser().parse_args()

    akt_slug = args.akt_slug.strip().lower()
    input_path = Path(args.input)
    meta_path = Path(args.meta)
    out_dir = Path(args.out_dir)
    report_path = out_dir / "IZVJESTAJ_NORMIRANJA.md"

    struktura = load_json(input_path)
    meta = load_json(meta_path)

    akt, clanci, amandmani_clanci, input_is_doc_split = extract_doc_split(struktura)

    stanje_na_dan = normaliziraj_datum(str(meta.get("datum_pristupa", "")))
    datum_provjere = danas_hr()

    out_dir.mkdir(parents=True, exist_ok=True)
    for stara_datoteka in out_dir.glob("clanak_*.json"):
        stara_datoteka.unlink()

    generated = 0
    warnings: list[str] = []
    broj_pojava: dict[str, int] = {}

    for idx, clanak in enumerate(clanci, start=1):
        if not isinstance(clanak, dict):
            warnings.append(f"Index {idx}: zapis članka nije objekt.")
            continue

        raw_oznaka = clanak.get("broj")
        if raw_oznaka is None:
            raw_oznaka = clanak.get("oznaka")

        normalized = normalize_clanak_oznaka(raw_oznaka)
        if normalized is None:
            warnings.append(f"Index {idx}: nevaljana oznaka članka ({raw_oznaka}).")
            continue
        oznaka, file_token = normalized

        tekst_raw = clanak.get("tekst")
        if not isinstance(tekst_raw, str) or not tekst_raw.strip():
            warnings.append(f"Članak {broj}: preskočen (nedostaje tekst).")
            continue

        broj_pojava[file_token] = broj_pojava.get(file_token, 0) + 1
        if broj_pojava[file_token] > 1:
            warnings.append(
                f"Članak {oznaka}: duplikat oznake; datoteka clanak_{file_token}.json je prepisana."
            )

        payload = create_norma_payload(
            akt=akt,
            clanak=clanak,
            oznaka=oznaka,
            meta=meta,
            stanje_na_dan=stanje_na_dan,
            datum_provjere=datum_provjere,
        )

        json_without_file_hash = json.dumps(payload, ensure_ascii=False, indent=2)
        payload["integritet"]["sha256_datoteke"] = sha256_upper_text(json_without_file_hash)
        final_text = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"

        file_name = f"clanak_{file_token}.json"
        out_path = out_dir / file_name
        out_path.write_text(final_text, encoding="utf-8")
        generated += 1

    amandmani_oznake: list[str] = []
    for clanak in amandmani_clanci:
        if not isinstance(clanak, dict):
            continue
        raw_oznaka = clanak.get("broj")
        if raw_oznaka is None:
            raw_oznaka = clanak.get("oznaka")
        normalized = normalize_clanak_oznaka(raw_oznaka)
        if normalized is not None:
            amandmani_oznake.append(normalized[0])

    amandmani_range_hint = ", ".join(amandmani_oznake[:10]) if amandmani_oznake else "(none)"

    lines = [
        "# Izvještaj normiranja (NN struktura)",
        "",
        f"- Datum: {danas_hr()}",
        f"- Akt slug: {akt_slug}",
        f"- Broj ulaznih članaka: {len(clanci)}",
        f"- Broj generiranih JSON datoteka: {generated}",
        f"- Broj upozorenja: {len(warnings)}",
        "",
        "## Document split (NN)",
        "",
        f"- PROCISCENI_COUNT: {len(clanci)}",
        f"- AMANDMANI_COUNT: {len(amandmani_clanci)}",
        "- NORMED_FROM_DOC: ustav_rh_procisceni",
        "- AMANDMANI_IGNORED: True",
        f"- AMANDMANI_RANGE_HINT: {amandmani_range_hint}",
        f"- INPUT_DOC_SPLIT_DETECTED: {input_is_doc_split}",
        "",
        "## Upozorenja",
        "",
    ]

    if warnings:
        for warning in warnings:
            lines.append(f"- {warning}")
    else:
        lines.append("- Nema upozorenja.")

    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"OK: generirano {generated} NORMA članaka")
    print(f"Izlaz: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
