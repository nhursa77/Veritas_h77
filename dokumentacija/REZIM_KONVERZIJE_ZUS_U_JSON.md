# REZIM KONVERZIJE ZUS U JSON

Datum: 27.03.2026.
Status: kanonski
Opseg: utvrdjivanje izvora i rezima ingest-a za
`zakon_o_upravnim_sporovima`.

---

## A) Ciljani zakon

- `zakon_o_upravnim_sporovima`

---

## B) Provjera izvora na Narodnim novinama

Provedena je deterministicka provjera NN pretrage kroz dva ciljna upita:

- upit 1: `zakon o upravnim sporovima`
- upit 2: `procisceni tekst zakona o upravnim sporovima`

Rezultat provjere:

- u NN pretraznom odgovoru nije pronadjen eksplicitan signal za
  procisceni tekst ciljanog zakona
- nije pronadjen ni jasan izravni indikator prociscenog ulaza za ZUS

Kontrolni sloj (zakon.hr) prikazuje:

- naslov `Zakon o upravnim sporovima`
- oznaku `procisceni tekst zakona`
- referencu `NN 36/24` i status `na snazi od 01.07.2024.`
- prijelaznu referencu na raniji zakon (`NN 20/10, 143/12, 152/14,
  94/16, 29/17, 110/21`) kao zakon koji prestaje vaziti

Zakljucak za ovaj korak:

- zakon.hr ostaje kontrolni izvor i ne moze zamijeniti dokazni NN signal
- za `zakon_o_upravnim_sporovima` nije dokazano da je na NN dostupan
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

## D) Operativni zakljucak za ZUS

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
