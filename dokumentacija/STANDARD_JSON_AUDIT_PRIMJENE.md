# STANDARD JSON — AUDIT PRIMJENE (v1)

Datum: 20.02.2026.

Ovaj standard definira jedini dopušteni format audit zapisa u predmetu:
`predmeti/**/audit/audit_v*.json`.

Audit je deterministički zapis provjera. Ne sadrži slobodno “pravno mišljenje”.
Svi nalazi moraju imati normativnu referencu (`norma_ref`) ili biti prazni.

## 1. Obavezni korijenski ključevi

Audit JSON mora sadržavati sve ove ključeve:

- `meta`
- `moduli`
- `nalazi`
- `rokovi`
- `preporuceni_pravni_lijek`
- `gate_stanje`

## 2. Meta

`meta` je objekt s obaveznim poljima:

- `id_predmeta` (string)
- `tok` (string; npr. TOK_PN_PRIGOVOR)
- `verzija_toka` (string; npr. v1)
- `datum_izrade` (string; format DD.MM.YYYY.)
- `izvor_audita` (string; naziv alata/komponente koja je generirala audit)

## 3. Moduli (M0–M9)

`moduli` je niz objekata. Svaki objekt mora imati:

- `id` (string; M0..M9)
- `status` (string; PROLAZ | NEPROLAZ | N/A)
- `razlog` (string; kratko, bez retorike)
- `ulazi` (niz referenci na datoteke/podatke)
- `izlazi` (niz referenci na datoteke/podatke)

Napomena: nijedan modul se ne preskače; koristi se `N/A` uz razlog.

## 4. Nalazi (matrica pogrešaka)

`nalazi` je niz objekata. Svaki nalaz mora imati:

- `kod` (string)
- `opis` (string; kratko, činjenično)
- `norma_ref` (string; referenca na normu ili sidro, ili prazno ako još nije
  dostupno)
- `tezina` (string; NISKA | SREDNJA | VISOKA)
- `posljedica` (string; opis očekivanog procesnog učinka)

## 5. Rokovi

`rokovi` je niz objekata. Svaki rok mora imati:

- `naziv` (string)
- `pocetak` (string; DD.MM.YYYY. ili prazno)
- `istek` (string; DD.MM.YYYY. ili prazno)
- `izvor_norme_ref` (string; referenca na normu ili sidro, ili prazno)

## 6. Preporučeni pravni lijek

`preporuceni_pravni_lijek` je objekt s obaveznim poljima:

- `naziv` (string)
- `kome` (string)
- `rok` (string; DD.MM.YYYY. ili prazno)
- `ucinak` (string)

## 7. Gate stanje (blokade)

`gate_stanje` je objekt s obaveznim poljima:

- `blocked` (boolean)
- `blocked_razlog` (string; obavezno ako je blocked=true)

Pravila:
- Ako je `blocked=true`, ne smije se generirati nacrt podneska.
- Bez NN sidra (status OK) vanjski izlaz je blocked.

## 8. Minimalni primjer (struktura)

```json
{
  "meta": {
    "id_predmeta": "OGLEDNI_PREDMET_0001",
    "tok": "TOK_PN_PRIGOVOR",
    "verzija_toka": "v1",
    "datum_izrade": "20.02.2026.",
    "izvor_audita": "generator_audita"
  },
  "moduli": [
    {
      "id": "M0",
      "status": "PROLAZ",
      "razlog": "Identifikacija akta izvedena.",
      "ulazi": [],
      "izlazi": []
    }
  ],
  "nalazi": [],
  "rokovi": [],
  "preporuceni_pravni_lijek": {
    "naziv": "",
    "kome": "",
    "rok": "",
    "ucinak": ""
  },
  "gate_stanje": {
    "blocked": true,
    "blocked_razlog": "NN sidro nije potvrđeno (status OK)."
  }
}
```
