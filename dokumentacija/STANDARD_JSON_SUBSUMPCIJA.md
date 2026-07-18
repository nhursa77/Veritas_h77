# STANDARD JSON — SUBSUMPCIJA (v1)

Datum: 17.07.2026.

Ovaj standard definira jedini dopušteni format subsumcijskog zapisa u predmetu.
Subsumcija je provjera elemenata bića prekršaja kroz vezu:
element → činjenica → dokaz → obrazloženje → status.

Subsumcija ne smije sadržavati retoriku niti slobodne zaključke bez reference.
Ako nedostaje činjenica ili dokaz, status elementa mora biti `NEPROLAZ`.

## 1. Obavezni korijenski ključevi

Subsumcija JSON mora sadržavati sve ove ključeve:

- `meta`
- `elementi_bica`

## 2. Meta

`meta` je objekt s obaveznim poljima:

- `id_predmeta` (string)
- `tok` (string; npr. TOK_PN_PRIGOVOR)
- `verzija_toka` (string; npr. v1)
- `datum_izrade` (string; format DD.MM.YYYY.)
- `izvor_subsumcije` (string; naziv alata/komponente)

## 3. Elementi bića

`elementi_bica` je niz objekata. Svaki element mora imati:

- `naziv_elementa` (string)
- `cinjenica_ref` (string; referenca na činjenični zapis ili prazno)
- `dokaz_ref` (string; referenca na dokaz ili prazno)
- `obrazlozenje` (string; kratko)
- `status` (string; PROLAZ | NEPROLAZ | N/A)

Pravila statusa:
- `NEPROLAZ` ako je `cinjenica_ref` prazno ili `dokaz_ref` prazno.
- `N/A` se koristi samo ako se element ne primjenjuje u tom toku, uz kratko
  obrazloženje u `obrazlozenje`.
- Nijedan element ne smije ostati bez statusa.
- U predmetu je `dokaz_ref` kanonska relativna putanja pod mapom
  `predmeti/sud/prekrsajni/<PREDMET_ID>/dokazi/` istog predmeta.
- Vrijednosti pod `fixture/` dopuštene su samo u izoliranim testnim
  scenarijima. P8 ih ne prihvaća kao dokazni artefakt.

## 4. Minimalni primjer (struktura)

```json
{
  "meta": {
    "id_predmeta": "OGLEDNI_PREDMET_0001",
    "tok": "TOK_PN_PRIGOVOR",
    "verzija_toka": "v1",
    "datum_izrade": "20.02.2026.",
    "izvor_subsumcije": "generator_subsumcije"
  },
  "elementi_bica": [
    {
      "naziv_elementa": "Radnja",
      "cinjenica_ref": "",
      "dokaz_ref": "",
      "obrazlozenje": "Nedostaju činjenica i dokaz u predmetu.",
      "status": "NEPROLAZ"
    }
  ]
}
```
