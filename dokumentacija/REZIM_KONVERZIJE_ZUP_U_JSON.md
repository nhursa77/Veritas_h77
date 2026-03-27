# REZIM KONVERZIJE ZUP U JSON

Datum: 27.03.2026.
Status: kanonski
Opseg: utvrdjivanje izvora i rezima ingest-a za
`zakon_o_opcem_upravnom_postupku`.

---

## A) Ciljani zakon

- `zakon_o_opcem_upravnom_postupku`

---

## B) Provjera izvora na Narodnim novinama

Provedena je deterministicka provjera NN pretrage kroz dva ciljna upita:

- upit 1: `zakon o opcem upravnom postupku`
- upit 2: `procisceni tekst zakona o opcem upravnom postupku`

Rezultat provjere:

- u NN pretraznom odgovoru nije pronadjen eksplicitan signal za
  procisceni tekst ciljanog zakona
- nije pronadjen ni jasan izravni indikator prociscenog ulaza za ZUP

Zakljucak za ovaj korak:

- za `zakon_o_opcem_upravnom_postupku` nije dokazano da je na NN dostupan
  valjani procisceni tekst za izravnu konverziju
- rezim konverzije mora se voditi po modelu kao `prekrsajni_zakon`

---

## C) Pravilo odluke

Obavezno pravilo odluke bez alternative:

- ako je zakon na Narodnim novinama dostupan u prociscenom obliku,
  ide se po obrascu prociscenog akta
- ako nije dostupan u prociscenom obliku,
  mora se odraditi na nacin kako je u projektu odradjen
  `prekrsajni_zakon`

---

## D) Operativni zakljucak za ZUP

REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL

---

## E) Veza s postojecim projektom

- `ustav_rh_procisceni` predstavlja postojeci uzorak rada za procisceni akt
- `prekrsajni_zakon` predstavlja postojeci uzorak rada za akt koji se mora
  voditi kroz slozeniji model kada nema jednostavnog prociscenog ulaza

Operativni okvir slozenijeg modela u projektu ukljucuje:

- core + amandmani
- sidra (NN) i kontrolni sloj
- fallback i validaciju prije operativne projekcije u NORMA JSON
