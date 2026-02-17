from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path


def ocisti_razmake(tekst: str) -> str:
    return re.sub(r"\s+", " ", tekst).strip()


def ucitaj_meta(putanja: Path) -> dict:
    if not putanja.exists():
        return {}
    with putanja.open("r", encoding="utf-8") as datoteka:
        return json.load(datoteka)


def izdvoji_redove_iz_html(html: str, napomene: list[str]) -> list[str]:
    try:
        from bs4 import BeautifulSoup  # type: ignore

        juha = BeautifulSoup(html, "html.parser")
        tekst = juha.get_text("\n")
    except Exception:
        napomene.append(
            "Parser radi bez BeautifulSoup; rezultat može imati više šuma."
        )
        bez_skripti = re.sub(
            r"<script[\\s\\S]*?</script>",
            " ",
            html,
            flags=re.IGNORECASE,
        )
        bez_stila = re.sub(
            r"<style[\\s\\S]*?</style>",
            " ",
            bez_skripti,
            flags=re.IGNORECASE,
        )
        tekst = re.sub(r"<[^>]+>", " ", bez_stila)

    retci = []
    for redak in tekst.splitlines():
        cist = ocisti_razmake(redak)
        if cist:
            retci.append(cist)
    return retci


def je_naslov_clanka(redak: str) -> re.Match[str] | None:
    uzorak = re.compile(r"^članak\s+([0-9]+[a-zA-Z]?)\.?$", re.IGNORECASE)
    return uzorak.match(redak)


def razdijeli_po_clancima(retci: list[str]) -> list[tuple[str, list[str]]]:
    clanci: list[tuple[str, list[str]]] = []
    oznaka = None
    sadrzaj: list[str] = []

    for redak in retci:
        pogodak = je_naslov_clanka(redak)
        if pogodak:
            if oznaka is not None:
                clanci.append((oznaka, sadrzaj))
            oznaka = pogodak.group(1)
            sadrzaj = []
            continue

        if oznaka is not None:
            sadrzaj.append(redak)

    if oznaka is not None:
        clanci.append((oznaka, sadrzaj))

    return clanci


def izdvoji_stavke(oznaka: str, retci: list[str], napomene: list[str]) -> dict:
    naslov = None
    preostalo = list(retci)

    if preostalo:
        prvi = preostalo[0]
        if not re.match(r"^\([0-9]+\)", prvi):
            naslov = prvi
            preostalo = preostalo[1:]

    stavci = []
    broj_stavka = None
    dijelovi: list[str] = []

    for redak in preostalo:
        pogodak_st = re.match(r"^\(([0-9]+)\)\s*(.*)$", redak)
        if pogodak_st:
            if broj_stavka is not None:
                stavci.append(
                    {
                        "broj": broj_stavka,
                        "tekst": ocisti_razmake(" ".join(dijelovi)),
                    }
                )
            broj_stavka = int(pogodak_st.group(1))
            prvi_dio = pogodak_st.group(2)
            dijelovi = [prvi_dio] if prvi_dio else []
        else:
            if broj_stavka is None:
                broj_stavka = 1
            dijelovi.append(redak)

    if broj_stavka is not None:
        stavci.append(
            {
                "broj": broj_stavka,
                "tekst": ocisti_razmake(" ".join(dijelovi)),
            }
        )

    if not stavci:
        napomene.append(f"Članak {oznaka} nema jasno izdvojene stavke.")
        stavci = [{"broj": 1, "tekst": ""}]

    clanak = {
        "oznaka": oznaka,
        "naslov": naslov,
        "stavci": stavci,
    }
    return clanak


def glavna() -> int:
    korijen = Path(__file__).resolve().parents[1]
    ulaz_html = korijen / "izvori/operativno/zakon_hr/ustav_rh/ustav_rh.html"
    ulaz_meta = korijen / "izvori/operativno/zakon_hr/ustav_rh/meta.json"
    izlaz_json = (
        korijen / "izvori/operativno/zakon_hr/ustav_rh/ustav_rh_struktura.json"
    )

    if not ulaz_html.exists():
        print("Ulazni HTML nije pronađen.")
        return 1

    with ulaz_html.open("r", encoding="utf-8", errors="ignore") as datoteka:
        html = datoteka.read()

    meta = ucitaj_meta(ulaz_meta)
    napomene: list[str] = []

    retci = izdvoji_redove_iz_html(html, napomene)
    blokovi = razdijeli_po_clancima(retci)

    clanci = []
    for oznaka, sadrzaj in blokovi:
        clanci.append(izdvoji_stavke(oznaka, sadrzaj, napomene))

    if not clanci:
        napomene.append("Nije pronađen nijedan članak u ulaznom HTML-u.")

    datum_pristupa = meta.get("datum_pristupa")
    if not datum_pristupa:
        datum_pristupa = datetime.now().strftime("%d.%m.%Y.")

    zapis = {
        "akt": {
            "naziv": "Ustav Republike Hrvatske",
            "izvor": "zakon.hr",
            "datum_pristupa": datum_pristupa,
            "sha256_html": meta.get("sha256_datoteke"),
        },
        "clanci": clanci,
        "napomene": napomene
        if napomene
        else ["Parser nije prijavio nejasnoće u ovom prolazu."],
    }

    with izlaz_json.open("w", encoding="utf-8", newline="\n") as datoteka:
        json.dump(zapis, datoteka, ensure_ascii=False, indent=2)
        datoteka.write("\n")

    print(f"Zapisan izlaz: {izlaz_json}")
    print(f"Broj pronađenih članaka: {len(clanci)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(glavna())
