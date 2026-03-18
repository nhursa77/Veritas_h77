# STANDARD_KANDIDATSKE_PODNATUKNICE_NN

Datum: 18.03.2026.
Status: kanonski
Opseg: razlaganje višeznačnih NN sidara u kandidatske podnatuknice.

---

## 1) Svrha

Ovaj standard definira međukorak nakon prvog NN sidrenja u kojem se
višeznačni ili nejasni pojmovi razlažu u kandidatske podnatuknice po aktu i
normativnom kontekstu, bez konačnog ručnog presuđivanja glavnog sidra.

---

## 2) Obavezna načela

- višeznačni pojam ne smije biti nasilno sveden na jedno sidro,
- razlaganje se prvo radi po aktu/kontekstu iz postojećih `nn_sidra`,
- kandidatska podnatuknica nije konačna natuknica,
- ručna validacija ostaje obvezna.

---

## 3) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json`
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren_manifest.json`

Razlaganje obuhvaća samo natuknice sa statusom sidra:

- `VISE_MOGUCIH_SIDARA`
- `NEJASNO`

Izlaz:

- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn.json`
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_manifest.json`

---

## 4) Obavezna polja kandidatske podnatuknice

Svaka kandidatska podnatuknica mora sadržavati najmanje:

- `nadredeni_pojam_id`
- `nadredeni_kanonski_naziv`
- `kandidat_id`
- `kanonski_naziv_kandidata`
- `naziv_akta`
- `akt_slug`
- `broj_nn`
- `nn_sidra`
- `status_kandidata`
- `osnova_razdvajanja`
- `zahtijeva_rucnu_validaciju`

---

## 5) Pravila polja

- `kanonski_naziv_kandidata` ima oblik:
  `<kanonski_naziv> — <naziv_akta>`
- `status_kandidata` je uvijek `KANDIDAT_NN_SIDRA`
- `osnova_razdvajanja` je:
  `RAZLICIT_AKT` ili `RAZLICIT_NORMATIVNI_KONTEKST`
- `zahtijeva_rucnu_validaciju` je uvijek `true`

---

## 6) Operativne zabrane

U razlaganju kandidata nije dopušteno:

- birati pobjedničko sidro,
- spajati različite akte u jedan kandidatski zapis,
- izmišljati nove članke,
- izmišljati normativne definicije.

---

## 7) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj ulaznih višeznačnih natuknica,
- ukupan broj kandidatskih podnatuknica,
- broj kandidata po nadređenom pojmu,
- broj kandidata po aktu,
- popis svih nadređenih pojmova,
- popis svih kandidatskih `kanonski_naziv_kandidata`.
