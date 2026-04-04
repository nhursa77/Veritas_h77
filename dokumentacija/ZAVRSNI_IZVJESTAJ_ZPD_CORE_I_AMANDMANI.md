# ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI

Datum: 31.03.2026.
Status: kanonski
Opseg: objedinjeni zavrsni pregled za `zakon_o_porezu_na_dohodak`
na temelju postojecih repo artefakata bez novog ingest-a,
refresh-a ili patcha alata.

---

## 1) Polaziste i obuhvat

Ovaj dokument objedinjeno zatvara dokazni pregled za cijeli ZPD set koji je
u repou vođen modelom `core + amandmani`.

Obuhvaceni su:

- core akt `zakon_o_porezu_na_dohodak`
- svi amandmani iz manifesta `paketi/PAKET_ZPD_V1.json`
- postojeci trajni izvjestaji validacije pod `baza_zakona/norme/` i
  `baza_zakona/sidra/`
- postojeci statusni i dnevnicki tragovi iz zadataka Z119, Z120, Z121,
  Z123, Z124, Z126, Z128 i Z129

Zakljuci u ovom dokumentu ne uvode nove dokaze, nego samo sazimaju vec
evidentirane rezultate.

## 2) Core ZPD

### `zakon_o_porezu_na_dohodak`

- Akt slug: `zakon_o_porezu_na_dohodak`
- zakon.hr kontrolni URL: `https://www.zakon.hr/z/85/zakon-o-porezu-na-dohodak`
- CONTROL_COUNT: `99`
- NN_COUNT: `99`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `2`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

Napomena: core ZPD ima potpunu pokrivenost i bez missing clanaka, ali
`SHORT_COUNT=2` znaci da zavrsni rezultat nije potpuno bez toleriranih
odstupanja, iako je validator prosao stabilno.

## 3) Amandmani iz manifesta

### `NN 106/2018`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_106_2018`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=35597`
- CONTROL_COUNT: `33`
- NN_COUNT: `33`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `9`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 121/2019`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_121_2019`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=42193`
- CONTROL_COUNT: `21`
- NN_COUNT: `22`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[27]`
- SHORT_COUNT: `6`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 32/2020`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_32_2020`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=43421`
- CONTROL_COUNT: `4`
- NN_COUNT: `4`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `1`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 138/2020`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_138_2020`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=46522`
- CONTROL_COUNT: `21`
- NN_COUNT: `21`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `8`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 151/2022`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_151_2022`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=55111`
- CONTROL_COUNT: `23`
- NN_COUNT: `23`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `11`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 114/2023`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_114_2023`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=58270`
- CONTROL_COUNT: `42`
- NN_COUNT: `44`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[76, 78]`
- SHORT_COUNT: `20`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

### `NN 152/2024`

- Akt slug: `zakon_o_porezu_na_dohodak_nn_152_2024`
- zakon.hr kontrolni URL: `https://www.zakon.hr/cms.htm?id=540193`
- CONTROL_COUNT: `19`
- NN_COUNT: `19`
- MISSING_COUNT: `0`
- EXTRA_LIST: `[]`
- SHORT_COUNT: `6`
- CONTROL_TRUNCATION_SUSPECTED: `False`
- Zakljucak: prolaz uz tolerirano odstupanje

## 4) Zavrsni zakljucak za cijeli ZPD

- Zakon kao cjelina obradjen je modelom `core + amandmani`.
- Svi planirani amandmani iz manifesta `paketi/PAKET_ZPD_V1.json` su
  obradjeni i imaju trajni validacijski izvjestaj u repou.
- Nije evidentiran nijedan `MISSING_COUNT>0` niti truncation signal na core
  ili na ijednom amandmanu.
- Otvorena tehnicka napomena nije blockerske prirode, ali ostaje cinjenica
  da svi ZPD zapisi imaju barem jedno tolerirano odstupanje, najcesce
  nenulti `SHORT_COUNT`, a kod `NN 121/2019` i `NN 114/2023` i izolirani
  `EXTRA_LIST`.
- Otvorena interpretativna napomena ostaje vec formalizirana u dokumentu
  `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`: prolaz ne
  znaci potpunu tekstualnu identicnost NN i `zakon.hr` zapisa, nego stabilnu
  normativnu pokrivenost bez tvrdih fail signala.
- Zavrsna ocjena za cijeli ZPD set je: stabilno zatvoren skup po modelu
  `core + amandmani`, bez otvorenog zahtjeva za novi ingest ili patch alata
  na temelju trenutno evidentiranih artefakata.
