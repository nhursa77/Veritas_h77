# DOKUMENT 02 — Standard JSON “NORMA” (chunk = članak) — kanonski

## 0) Svrha

Ovaj standard definira jedinstveni JSON format za pohranu normativnih tekstova
(ustav, zakoni, pravilnici i međunarodni akti), gdje je osnovna jedinica obrade
**članak**.

Cilj:

- deterministička obrada (bez improvizacije),
- jednoznačno citiranje (čl., st., t.),
- dokazno sidrenje (Narodne novine i/ili službeni izvor),
- verzioniranje (“stanje na dan”),
- mogućnost provjere integriteta (hash).

---

## 1) Načela

1) **Jedan članak = jedan JSON objekt.**  
2) **Struktura teksta se čuva** (stavci, točke, alineje) tako da je moguće
precizno citirati.  
3) **Svaki članak mora imati dokazno sidro** (službena objava/izvor) ili se
označava kao nepotpun za vanjsku uporabu.  
4) **Verzija je obavezna**: “stanje na dan” + datum provjere.  
5) **Jezik je hrvatski**, nazivi polja su hrvatski (bez engleskog).  
6) **Razdvajanje izvora**: operativni tekst (pročišćeni) ≠ dokazni izvor
(službena objava).  
7) **Format datuma je hrvatski**: `DD/MM/YYYY` (npr. `16/02/2026`).

---

## 2) Lokacija u repozitoriju

Preporučena struktura:

- `baza_zakona/<vrsta>/<slug_akta>/<stanje_na_dan>/`
npr.
- `baza_zakona/zakon/zakon_o_opcem_upravnom_postupku/16-02-2026/`

Svaki članak je zasebna datoteka:

- `clanak_<broj>.json` (npr. `clanak_12.json`)
Za složenije oznake:
- `clanak_12a.json`, `clanak_1045.json`

---

## 3) Obavezna polja (minimalni zapis)

Svaki članak mora sadržavati sljedeća polja:

### 3.1 Identitet akta

- `akt` (objekt)
  - `naziv` (string)
  - `vrsta` (enum: `ustav`, `zakon`, `pravilnik`, `uredba`, `odluka`,
    `medunarodni_akt`)
  - `slug` (string, stabilan identifikator u repou)
  - `jurisdikcija` (string, npr. `RH`, `EU`, `UN`)
  - `jezik` (string, npr. `hr`)

### 3.2 Identitet članka

- `clanak` (objekt)
  - `oznaka` (string, npr. `12`, `12.a`, `1045`)
  - `naslov` (string ili null)
  - `tekst` (string, puni tekst članka u izvornom obliku)
  - `struktura` (objekt; vidi poglavlje 4)

### 3.3 Verzija i provjera (datumi: DD/MM/YYYY)

- `verzija` (objekt)
  - `stanje_na_dan` (datum `DD/MM/YYYY`)
  - `datum_provjere` (datum `DD/MM/YYYY`)
  - `napomena` (string ili null)

### 3.4 Izvori i sidra (datumi: DD/MM/YYYY)

- `izvori` (objekt)
  - `operativni_izvor` (objekt ili null)
    - `naziv` (string; npr. `zakon.hr`)
    - `url` (string)
    - `datum_pristupa` (datum `DD/MM/YYYY`)
  - `dokazni_izvor` (objekt ili null)
    - `naziv` (string; npr. `Narodne novine`)
    - `sidra` (array objekata; vidi 5)
  - `status_sidra` (enum: `puno`, `djelomicno`, `nema`)

### 3.5 Integritet

- `integritet` (objekt)
  - `sha256_teksta` (string; hash nad kanoniziranim tekstom članka)
  - `sha256_datoteke` (string ili null; ako se koristi)
  - `napomena` (string ili null)

---

## 4) Struktura članka (stavci/točke)

Polje `struktura` mora omogućiti precizno citiranje.

Minimalno:

- `stavci` (array)
  - svaki stavak:
    - `broj` (integer, 1..n)
    - `tekst` (string)
    - `tocke` (array ili null)
      - svaka točka:
        - `oznaka` (string, npr. `1`, `2`, `a`, `b`)
        - `tekst` (string)
        - `alineje` (array stringova ili null)

Ako članak nema formalne stavke, cijeli tekst ide u stavak 1.

---

## 5) Sidra (Narodne novine / službeni izvor)

`sidra` je niz objekata, minimalno:

- `sidra[]`:
  - `nn_broj` (string, npr. `47/09`)
  - `datum_objave` (datum `DD/MM/YYYY` ili null ako nije poznat)
  - `opis` (string; npr. `pročišćeni tekst`, `izmjene i dopune`,
    `osnovni tekst`)
  - `url` (string ili null)

Ako akt nije iz NN (npr. UN), koristi se odgovarajući službeni izvor u istom
formatu.

---

## 6) Pravila valjanosti zapisa (gating)

Zapis članka je:

- **interno upotrebljiv** ako postoji operativni izvor i struktura
  teksta.
- **vanjski upotrebljiv (za podneske)** samo ako je `status_sidra = puno`
  i postoji barem jedno dokazno sidro.

Ako nije “vanjski upotrebljiv”, Veritas mora jasno označiti status
i predložiti dopunu sidara.

---

## 7) Primjer (minimalni)
>
> Primjer je ilustrativan; stvarne vrijednosti se popunjavaju po stvarnom aktu.

```json
{
  "akt": {
    "naziv": "Zakon o općem upravnom postupku",
    "vrsta": "zakon",
    "slug": "zakon_o_opcem_upravnom_postupku",
    "jurisdikcija": "RH",
    "jezik": "hr"
  },
  "clanak": {
    "oznaka": "12",
    "naslov": null,
    "tekst": "…",
    "struktura": {
      "stavci": [
        {
          "broj": 1,
          "tekst": "…",
          "tocke": null
        }
      ]
    }
  },
  "verzija": {
    "stanje_na_dan": "16/02/2026",
    "datum_provjere": "16/02/2026",
    "napomena": null
  },
  "izvori": {
    "operativni_izvor": {
      "naziv": "zakon.hr",
      "url": "…",
      "datum_pristupa": "16/02/2026"
    },
    "dokazni_izvor": {
      "naziv": "Narodne novine",
      "sidra": [
        {
          "nn_broj": "47/09",
          "datum_objave": null,
          "opis": "osnovni tekst",
          "url": null
        }
      ]
    },
    "status_sidra": "djelomicno"
  },
  "integritet": {
    "sha256_teksta": "…",
    "sha256_datoteke": null,
    "napomena": null
  }
}
```
