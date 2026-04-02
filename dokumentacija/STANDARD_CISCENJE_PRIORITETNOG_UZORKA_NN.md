# STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN

Datum: 18.03.2026.
Status: kanonski
Opseg: tehničko čišćenje prioritetnog uzorka na NN-sidrenju podobne
pojmove.

---

## 1) Svrha

Ovaj standard definira kako iz prioritetnog uzorka izdvojiti uži, operativno
koristan skup kandidata za budući NN pregled.

U ovom koraku nema dohvaćanja Narodnih novina i nema pravnog zaključivanja.

---

## 2) Što se uklanja

Uklanjaju se očiti tehnički i neupotrebljivi kandidati, primjerice:

- dvoslovne kratice država/jezika
- generičke oznake (`EU`, `Law`, `No`, `not validated`)
- tehničke kombinacije oznaka koje nisu naziv pojma/instituta

---

## 3) Što se zadržava

Zadržavaju se kandidati koji po samom tekstu izgledaju kao:

- pravni naziv
- procesni pojam
- akt ili radnja

Svaki zadržani zapis dobiva:

- `status_podobnosti_nn_sidrenja = PODOBAN_ZA_NN_PREGLED`
- `osnova_podobnosti` (`PRAVNI_NAZIV`, `PROCESNI_POJAM`,
  `AKT_ILI_RADNJA`)

---

## 4) Ograničenja

Nije dopušteno:

- upisivati članke, stavke ili nazive zakona
- upisivati pravni učinak
- zaključivati da je kandidat potvrđeno NN sidro

Ovaj sloj je tehnička priprema za sljedeći korak ručnog NN pregleda.

---

## 5) Izlazni artefakti

- `baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/`
    `nn_sidrenju_podobni_pojmovi_manifest.json`

Manifest mora sadržavati broj ulaznih, zadržanih i odbačenih zapisa,
raspodjelu po osnovi podobnosti i top liste zadržanih/
odbačenih kandidata.
