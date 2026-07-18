# STANDARD JSON — PREDLOŽAK (v1)

Datum: 20.02.2026.

Ovaj standard definira jedini dopušteni format predloška koji se koristi za
generiranje nacrta podneska u prekršajnom modulu.

Predložak se puni isključivo iz audita (`audit_v*.json`) i metapodataka
predmeta. Predložak ne smije sadržavati slobodne pravne zaključke.

## 1. Obavezni korijenski ključevi

Predložak JSON mora sadržavati sve ove ključeve:

- `meta`
- `sekcije`
- `mapiranje`

## 2. Meta

`meta` je objekt s obaveznim poljima:

- `id_predloska` (string)
- `naziv` (string)
- `verzija` (string; npr. v1)
- `domena` (string; mora biti `prekrsajni`)
- `vrsta_akta` (string; npr. prigovor_pn ili zalba_presuda_ili_rjesenje)
- `datum_izrade` (string; format DD.MM.YYYY.)

## 3. Sekcije

`sekcije` je niz objekata. Svaka sekcija mora imati:

- `id` (string)
- `naslov` (string)
- `polja` (niz objekata)

Svako polje mora imati:

- `id` (string)
- `label` (string)
- `izvor` (string; referenca u formatu `audit.*`, `predmet.*` ili `intake.*`)
- `obavezno` (boolean)

Pravila:
- `izvor` je samo referenca. Predložak ne sadrži vrijednosti.
- Ako je `obavezno=true` i izvor se ne može razriješiti, generiranje nacrta
  mora biti blokirano (gate) uz razlog.
- Predložak prvog P7 toka obavezno mapira vrstu, broj, datum i datum dostave
  osporavanog akta iz `predmet.akt`.

## 4. Mapiranje

`mapiranje` je objekt koji definira pravila punjenja.
Mora sadržavati:

- `izvori` (niz stringova; dopušteno: `audit`, `predmet`, `intake`)
- `pravila` (niz objekata)

Svako pravilo mora imati:

- `polje_id` (string; referenca na `sekcije[].polja[].id`)
- `izvor` (string; isti format kao gore)
- `transformacija` (string; dopušteno: `none`)

Pravila:
- Transformacije su u v1 zabranjene osim `none`. Svaka kompleksnost ide u
  novu verziju standarda.
- Svako polje iz `sekcije[].polja[]` mora imati točno jedno pravilo.
- `polje_id` mora biti jedinstven u cijelom predlošku.
- `izvor` u pravilu mora biti jednak izvoru deklariranom u polju.
- Korijen svakog izvora mora biti naveden u `mapiranje.izvori`.
- Ako se obavezni izvor ne može razriješiti ili je prazan, nema nacrta.

## 5. P7 ulazni ugovor

P7 runner razrješava samo putanje oblika:

- `audit.<polje>` iz `audit_generated_v1.json`
- `predmet.<polje>` iz `predmet.json`
- `intake.<polje>` iz `intake_v1.json`

Postupak smije koristiti oznaku `{PREDMET_ID}` samo u referencama na
predmet. Runner oznaku zamjenjuje odobrenim identifikatorom predmeta i mora
odbiti putanju koja izlazi iz repozitorija ili ostane nerazriješena.

Minimalni `predmet.json` za sintetički P7 prolaz mora sadržavati:

- `meta.id_predmeta`
- sva polja koja konkretni predložak označava kao obavezna

Identitet predmeta i toka mora se podudarati u predmetu, intakeu,
subsumpciji i generiranom auditu. Nepodudarnost blokira nacrt.

## 6. P7 izlazni ugovor

Nacrt mora sadržavati identitet predloška, reference na predmet i generirani
audit te dokaz za svako mapirano polje:

- `POLJE_BEGIN=<id>`
- `LABEL=<label>`
- `IZVOR=<audit.*|predmet.*|intake.*>`
- razriješenu vrijednost ili strukturirani audit blok
- `POLJE_END=<id>`

Bez barem jednog u auditu prenesenog NORMA zapisa sa statusom sidra `puno`
runner ne smije proizvesti nacrt. Ostali uvjeti izlaza uređeni su standardom
`STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`.

## 7. Minimalni primjer (struktura)

```json
{
  "meta": {
    "id_predloska": "prigovor_pn_v1",
    "naziv": "Prigovor na prekršajni nalog",
    "verzija": "v1",
    "domena": "prekrsajni",
    "vrsta_akta": "prigovor_pn",
    "datum_izrade": "20.02.2026."
  },
  "sekcije": [
    {
      "id": "zaglavlje",
      "naslov": "Zaglavlje",
      "polja": [
        {
          "id": "sud_naziv",
          "label": "Naziv suda",
          "izvor": "predmet.sud_naziv",
          "obavezno": true
        }
      ]
    },
    {
      "id": "razlozi",
      "naslov": "Razlozi",
      "polja": [
        {
          "id": "nalazi",
          "label": "Nalazi iz audita",
          "izvor": "audit.nalazi",
          "obavezno": false
        }
      ]
    }
  ],
  "mapiranje": {
    "izvori": ["audit", "predmet", "intake"],
    "pravila": [
      {
        "polje_id": "sud_naziv",
        "izvor": "predmet.sud_naziv",
        "transformacija": "none"
      },
      {
        "polje_id": "nalazi",
        "izvor": "audit.nalazi",
        "transformacija": "none"
      }
    ]
  }
}
```
