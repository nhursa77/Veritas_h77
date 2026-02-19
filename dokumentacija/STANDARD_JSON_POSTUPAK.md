# Standard JSON “POSTUPAK” (procedura) — kanonski

## 0) Svrha

Ovaj standard definira jedinstveni JSON format za opis proceduralnih koraka
(postupaka) koje Veritas H.77 provodi u obrani prava pojedinca.

Cilj:

- deterministički tijek (bez improvizacije),
- pravovremeno djelovanje (rokovi, hitnost),
- dokazno uredno (chain of custody),
- proporcionalno (razmjerno riziku i šteti),
- vanjski izlaz = uredan nacrt dokumenta, koji vrijedi tek nakon potpisa
  nositelja.

---

## 1) Načela

1) Jedan postupak = skup koraka.
2) Jedan korak = jedan JSON objekt.
3) Korak se izvršava samo ako zadovoljava uvjete (gate).
4) Svaki korak mora imati: ulaze, norme, radnju, izlaz.
5) Format datuma je hrvatski: `DD.MM.YYYY.` (npr. `16.02.2026.`).
6) Veritas djeluje obrambeno i proporcionalno; bez laži, ucjena i ofenzive
   bez obrane.
7) Vanjski dokument se uvijek potvrđuje potpisom nositelja.

---

## 2) Lokacija u repozitoriju

Preporučeno:

- `baza_postupaka/<podrucje>/<slug_postupka>/v1/`

Primjer:

- `baza_postupaka/telekom/prigovor_povecanje_cijene/v1/`

Datoteke:

- `postupak.json` (meta)
- `korak_<nnn>_<slug>.json` (svaki korak zasebno)

---

## 3) Obavezna polja za KORAK (minimalni zapis)

### 3.1 Identitet i verzija

- `id` (string; stabilan, npr. `P-TELEKOM-001`)
- `naziv` (string)
- `verzija` (string; npr. `1.0`)
- `podrucje` (enum: `upravni`, `telekom`, `ovrha`, `sud`, `kazneno`,
  `radno`, `zastita_podataka`, `ostalo`)
- `status` (enum: `nacrt`, `kanonski`, `zastarjelo`)
- `datum_izrade` (datum `DD.MM.YYYY.`)
- `autor` (enum: `veritas_h77`, `nositelj`, `svjedok`)

### 3.2 Okidač i hitnost

- `okidac` (objekt)
  - `tip` (enum: `rok`, `dogadaj`, `zahtjev_nositelja`, `eskalacija`,
    `provjera`)
  - `opis` (string)
- `hitnost` (objekt)
  - `razina` (enum: `nisko`, `srednje`, `visoko`, `kriticno`)
  - `razlog` (string)
  - `rok` (datum `DD.MM.YYYY.` ili null)

### 3.3 Uvjeti pokretanja (gate)

- `gate` (objekt)
  - `minimalni_dokazi` (niz objekata; vidi poglavlje 4)
  - `status_sidra_norme` (enum: `puno`, `djelomicno`, `nema`)
  - `zabrane` (niz; vidi poglavlje 5)
  - `ako_ne_prode` (enum: `zaustavi`, `prebaci_u_prikupljanje`,
    `trazi_potvrdu_nositelja`)

### 3.4 Ulazi (činjenice i dokazi)

- `ulazi` (objekt)
  - `cinjenice` (niz stringova; kratke, numerirane činjenice)
  - `dokazi` (niz objekata; vidi poglavlje 6)
  - `lanac_skrbnistva` (niz objekata; vidi poglavlje 7)

### 3.5 Norme (pravni temelj)

- `norme` (objekt)
  - `hijerarhija` (niz enum vrijednosti: `prirodno_pravo`,
    `un_ljudska_prava`, `ustav`, `zakon`, `podzakonski`, `lokalni`)
  - `citati` (niz objekata; referenca na STANDARD_JSON_NORMA)
  - `status` (enum: `potvrdeno`, `djelomicno`, `nepotvrdeno`)

### 3.6 Radnja (što radimo)

- `radnja` (objekt)
  - `tip` (enum: `priprema_dokumenta`, `zahtjev_za_informacijom`,
    `prigovor`, `zalba`, `tuzba`, `opomena`, `interna_biljeska`)
  - `mikro_koraci` (niz stringova; konkretni koraci)
  - `komunikacija` (objekt)
    - `ton` (enum: `formalan`, `neutralan`, `ostro_proporcionalan`)
    - `zabrane` (niz; vidi poglavlje 5)

### 3.7 Izlaz (što proizvedemo)

- `izlaz` (objekt)
  - `tip` (enum: `nacrt_dokumenta`, `popis_za_dopunu`,
    `odluka_zaustavljanja`, `interni_zapis`)
  - `predlozak` (string ili null; putanja u `predlosci/`)
  - `generirani_artefakti` (niz objekata; vidi 8)
  - `potpis` (objekt)
    - `potrebno` (bool)
    - `potpisnik` (enum: `nositelj`)
    - `napomena` (string; “dokument vrijedi tek nakon potpisa nositelja”)

---

## 4) Minimalni dokazi (gate.minimalni_dokazi)

Svaki element:

- `vrsta` (enum: `izjava_nositelja`, `dokument`, `snimka_ekrana`, `e_mail`,
  `racun`, `rjesenje`, `poziv`, `ostalo`)
- `opis` (string)
- `obavezno` (bool)

---

## 5) Zabrane (crvene linije)

Vrijednosti za `gate.zabrane` i `radnja.komunikacija.zabrane`:

- `laz`
- `krivotvorenje`
- `ucjena`
- `prijetnja`
- `ofenziva_bez_obrane`
- `kleveta`
- `otkrivanje_tudih_podataka_bez_osnove`

---

## 6) Dokazi (ulazi.dokazi)

Svaki dokaz:

- `id` (string; npr. `D-001`)
- `naziv` (string)
- `vrsta` (enum kao u 4)
- `datum` (datum `DD.MM.YYYY.` ili null)
- `putanja` (string; relativno u repou ili lokalno)
- `sha256` (string ili null)
- `napomena` (string ili null)

---

## 7) Lanac skrbništva (ulazi.lanac_skrbnistva)

Svaki zapis:

- `datum_vrijeme` (string; lokalno, npr. `16.02.2026. 18:22`)
- `osoba` (enum: `nositelj`, `svjedok`, `veritas_h77`)
- `radnja` (enum: `zaprimljeno`, `kopirano`, `hashirano`, `pohranjeno`,
  `poslano`, `arhivirano`)
- `detalj` (string)

---

## 8) Generirani artefakti (izlaz.generirani_artefakti)

Svaki artefakt:

- `naziv` (string)
- `vrsta` (enum: `podnesak`, `prigovor`, `zalba`, `tuzba`, `dopuna`,
  `interno`)
- `putanja` (string; relativno u repou)
- `sha256` (string ili null)

---

## 9) Referenciranje normi (norme.citati)

Svaki citat je stroga referenca na STANDARD_JSON_NORMA:

- `akt_slug` (string)
- `stanje_na_dan` (datum `DD.MM.YYYY.`)
- `clanak_oznaka` (string)
- `stavak` (integer ili null)
- `tocka` (string ili null)
- `napomena` (string ili null)

---

## 10) Pravila valjanosti (gating)

Korak je:

- interno upotrebljiv ako ima činjenice + barem jedan dokaz + status normi
  nije `nepotvrdeno`.
- vanjski upotrebljiv (za izradu podneska) samo ako je
  `status_sidra_norme = puno` i `izlaz.potpis.potrebno = true`.

Ako uvjeti nisu zadovoljeni, izlaz mora biti `popis_za_dopunu` ili
`odluka_zaustavljanja`.

---

## 11) Minimalni primjer koraka (JSON)

```json
{
  "id": "P-TELEKOM-001",
  "naziv": "Priprema prigovora na povećanje cijene",
  "verzija": "1.0",
  "podrucje": "telekom",
  "status": "nacrt",
  "datum_izrade": "16.02.2026.",
  "autor": "veritas_h77",
  "okidac": {
    "tip": "rok",
    "opis": "Zaprimljena obavijest o povećanju cijene; reagirati u roku."
  },
  "hitnost": {
    "razina": "visoko",
    "razlog": "Postoji rok za prigovor.",
    "rok": "20.02.2026."
  },
  "gate": {
    "minimalni_dokazi": [
      {
        "vrsta": "izjava_nositelja",
        "opis": "Kratka izjava: tko, što, kada.",
        "obavezno": true
      },
      {
        "vrsta": "e_mail",
        "opis": "Obavijest operatera o promjeni cijene.",
        "obavezno": true
      }
    ],
    "status_sidra_norme": "djelomicno",
    "zabrane": ["laz", "ucjena", "ofenziva_bez_obrane"],
    "ako_ne_prode": "prebaci_u_prikupljanje"
  },
  "ulazi": {
    "cinjenice": [
      "1) Operater je poslao obavijest o povećanju cijene.",
      "2) Nositelj smatra promjenu jednostranom i traži pravnu osnovu."
    ],
    "dokazi": [
      {
        "id": "D-001",
        "naziv": "Obavijest operatera",
        "vrsta": "e_mail",
        "datum": "16.02.2026.",
        "putanja": "predmeti/telekom/a1_obavijest.pdf",
        "sha256": null,
        "napomena": null
      }
    ],
    "lanac_skrbnistva": [
      {
        "datum_vrijeme": "16.02.2026. 18:22",
        "osoba": "nositelj",
        "radnja": "zaprimljeno",
        "detalj": "Zaprimljen e-mail u sandučić."
      }
    ]
  },
  "norme": {
    "hijerarhija": ["un_ljudska_prava", "ustav", "zakon", "podzakonski"],
    "citati": [
      {
        "akt_slug": "ustav_rh",
        "stanje_na_dan": "16.02.2026.",
        "clanak_oznaka": "3",
        "stavak": null,
        "tocka": null,
        "napomena": "Razmjernost i vladavina prava."
      }
    ],
    "status": "djelomicno"
  },
  "radnja": {
    "tip": "prigovor",
    "mikro_koraci": [
      "Sastaviti nacrt prigovora.",
      "Ugraditi činjenice i citate normi.",
      "Pripremiti popis priloga.",
      "Dati nositelju na potpis."
    ],
    "komunikacija": {
      "ton": "formalan",
      "zabrane": ["kleveta", "prijetnja"]
    }
  },
  "izlaz": {
    "tip": "nacrt_dokumenta",
    "predlozak": "predlosci/telekom/prigovor.md",
    "generirani_artefakti": [
      {
        "naziv": "Prigovor - nacrt",
        "vrsta": "prigovor",
        "putanja": "predmeti/telekom/prigovor_nacrt.md",
        "sha256": null
      }
    ],
    "potpis": {
      "potrebno": true,
      "potpisnik": "nositelj",
      "napomena": "Dokument vrijedi tek nakon potpisa nositelja."
    }
  }
}
```

## 12) Zaključna norma

Svi postupci i koraci Veritasa H.77 moraju biti opisani ovim standardom.
Svako odstupanje je nekanonsko i mora biti ispravljeno prije vanjske uporabe.
