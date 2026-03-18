# STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA

Datum: 18.03.2026.
Status: kanonski
Opseg: tehničko mapiranje EU terminoloških zapisa prema potencijalnim
NN pojmovima bez normativnog sidrenja.

---

## 1) Svrha

Ovaj standard definira tehnički most između izdvojenih EU termina i
potencijalnih pojmova relevantnih za buduće NN sidrenje.

Mapiranje je prijedlog za ručnu provjeru i ne predstavlja pravni zaključak.

---

## 2) Dopuštene osnove mapiranja

U ovom koraku dopuštene su samo dokazive tehničke osnove:

- tekstualno podudaranje
- normalizirano podudaranje naziva
- očita jezična bliskost iz postojećih podataka

Nisu dopušteni:

- izmišljanje članaka, stavaka ili pravnih učinaka
- automatsko proglašenje da je riječ o istom institutu
- normativno sidrenje kao gotova istina

---

## 3) Obavezna polja zapisa mapiranja

- `curia_oznaka_zapisa`
- `curia_pojam_izvornik`
- `curia_ekvivalenti`
- `predlozeni_nn_pojam`
- `osnova_mapiranja`
- `razina_pouzdanosti`
- `zahtijeva_rucnu_provjeru`
- `status_mapiranja`

Obavezne vrijednosti:

- `zahtijeva_rucnu_provjeru = true`
- `status_mapiranja = PREDLOZENO_BEZ_NN_SIDRA`

---

## 4) Razine pouzdanosti

U ovom koraku dopuštene su samo:

- `NISKA`
- `SREDNJA`

`VISOKA` nije dopuštena do ručne i normativne provjere.

---

## 5) Izlazni artefakti

- `baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi_manifest.json`

Manifest mora sadržavati broj obrađenih termina, broj prijedloga,
raspodjelu po pouzdanosti i broj zapisa za ručnu provjeru.
