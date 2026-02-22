# STANDARD JSON — INTAKE PREKRŠAJI (v1)

Datum: 22.02.2026.

Ovaj standard definira minimalni deterministički ulaz za Gate 2 (osporiva
točka + cilj + kontradikcije) u prekršajnom modulu.

INTAKE služi isključivo za Preflight odluku i zapis u audit. INTAKE nije
"pravna argumentacija".

## 1. Obavezni korijenski ključevi

- `meta`
- `cilj`
- `osporavanja`
- `opis_dogadaja`
- `kontradikcije`

## 2. Meta (obavezno)

- `id_predmeta` (string)
- `tok` (string)
- `verzija_toka` (string)
- `datum_izrade` (string; DD.MM.YYYY.)
- `izvor_intake` (string)

## 3. Cilj (obavezno)

`cilj` je string i mora biti jedna od vrijednosti:
- `ponistenje`
- `obustava`
- `preinaka`
- `izdvajanje_dokaza`
- `ublazavanje`
- `vracanje_u_prijasnje_stanje`

## 4. Osporavanja (obavezno)

`osporavanja` je niz stringova. Svaka vrijednost mora biti jedna od:
- `identitet`
- `radnja`
- `okolnosti`
- `dokaz`
- `procedura`
- `nadleznost`

## 5. Opis događaja (obavezno)

`opis_dogadaja` je kratki opis (string), činjenično, bez retorike.

## 6. Kontradikcije (obavezno)

`kontradikcije` je objekt:
- `ima_kontradikcija` (boolean)
- `opis` (string; obavezno ako je true)

Ako je `ima_kontradikcija=true`, Gate 2 je FAIL dok se ne razriješi.

## 7. Minimalni primjer

```json
{
  "meta": {
    "id_predmeta": "OGLEDNI_PREDMET_0001",
    "tok": "TOK_PN_PRIGOVOR",
    "verzija_toka": "v1",
    "datum_izrade": "22.02.2026.",
    "izvor_intake": "rucni_unos"
  },
  "cilj": "izdvajanje_dokaza",
  "osporavanja": ["procedura", "dokaz"],
  "opis_dogadaja": "Korisnik osporava dostavu i traži uvid u dokaz.",
  "kontradikcije": {
    "ima_kontradikcija": false,
    "opis": ""
  }
}
```
