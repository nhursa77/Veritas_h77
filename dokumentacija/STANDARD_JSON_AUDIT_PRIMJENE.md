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

## 9. Audit naplate (kanonsko mapiranje v1)

Audit naplate se u AUDIT v1 zapisuje isključivo kroz `nalazi[]`.
Ne uvode se nova polja.

### 9.1. Semafor Preflight (Z/Ž/C)

Preflight rezultat se zapisuje kao jedan nalaz:

- `kod`: `NAP-SEM`
- `opis`: mora sadržavati `preflight=ZELENO|ZUTO|CRVENO`
- `tezina`:
  - ZELENO → `NISKA`
  - ZUTO → `SREDNJA`
  - CRVENO → `VISOKA`
- `posljedica`:
  - ZELENO → "Naplata dopuštena."
  - ZUTO → "Naplata uvjetno dopuštena uz Risk Disclosure."
  - CRVENO → "Naplata zabranjena; nema naplatnog dokumenta."

### 9.2. Gateovi G1–G3 (PASS/FAIL)

Rezultati gateova se bilježe kao 3 nalaza (svaki zasebno):

- `NAP-G1` za Proceduralnu dopuštenost
- `NAP-G2` za Minimalni činjenični prag
- `NAP-G3` za Minimalni dokazni prag ili dokaznu strategiju

`opis` mora sadržavati:
- `gate=G1|G2|G3`
- `rezultat=PASS|FAIL`
- kratki razlog (činjenično)

Ako je rezultat FAIL, `tezina` mora biti `VISOKA` i `posljedica` mora
ukazivati da je naplata zabranjena.

### 9.3. Odluka o naplati

Odluka o naplati se bilježi kao jedan nalaz:

- `kod`: `NAP-ODL`
- `opis`: `naplata=DOPUSTENO|ZABRANJENO`
- `tezina`:
  - DOPUSTENO → `NISKA` ili `SREDNJA`
  - ZABRANJENO → `VISOKA`
- `posljedica`:
  - DOPUSTENO → "Može se generirati naplatni dokument."
  - ZABRANJENO → "Dozvoljeni su samo besplatni informativni izlazi i/ili
    alternativni dokument za pribavu dokaza (ako je legitimno)."

### 9.4. Veza s gate_stanje

Ako je `NAP-SEM` CRVENO ili je bilo koji od `NAP-G1/G2/G3` FAIL,
onda `gate_stanje.blocked` mora biti `true`, a `blocked_razlog` mora biti
konkretan (bez retorike).
