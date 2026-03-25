# STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA

Datum: 25.03.2026.
Status: kanonski
Opseg: ručna validacija konačnih NN kandidata i upis potvrđenih sidara u
validirani sloj rječničkih natuknica.

---

## 1) Svrha

Ovaj standard definira završni korak prijelaza iz kandidatskog sloja u
validirani NN-sidreni sloj rječničkih natuknica.

Konačno NN sidro nastaje tek nakon ručne validacije.

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju.json`
- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju_manifest.json`
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json`

Izlaz:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran.json`
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran_manifest.json`

Skripta:

- `alati/upisi_validirana_nn_sidra_u_natuknice.py`

---

## 3) Obavezna pravila ručne validacije

Za svaki nadređeni pojam odabiru se samo kandidati koji su ručno prihvaćeni
kao konačni normativni kontekst.

Nije dopušteno:

- izmišljati nova sidra,
- upisivati sidro bez jasne odluke,
- samovoljno odabrati "najbolji" članak bez ljudske potvrde.

Ako pojam i dalje ostaje višeznačan, dopušten je upis više potvrđenih sidara
uz izričitu napomenu.

Ako nijedan kandidat nije potvrđen, pojam ostaje otvoren.

---

## 4) Obavezna polja validirane natuknice

Svaka natuknica obuhvaćena ručnom validacijom mora sadržavati:

- puni postojeći sadržaj natuknice,
- `nn_sidra` s potvrđenim sidrima,
- `status_validacije`,
- `napomena_veritas`,
- `datum_validacije`,
- `izvor_validacije = "rucna_validacija"`.

---

## 5) Statusna pravila

Dopuštene završne vrijednosti `status_validacije`:

- `NN_VALIDIRANO`
- `NN_DJELOMICNO_VALIDIRANO`
- `CEKA_DALJNJU_RUCNU_VALIDACIJU`

Tumačenje:

- `NN_VALIDIRANO`: postoji jedno jasno potvrđeno sidro ili jasno potvrđen
  skup koji predstavlja konačan normativni kontekst.
- `NN_DJELOMICNO_VALIDIRANO`: neka sidra su potvrđena, ali višeznačnost nije
  potpuno zatvorena.
- `CEKA_DALJNJU_RUCNU_VALIDACIJU`: nema dovoljno osnove za konačan izbor.

Djelomična validacija mora biti izričito označena.
Pojam može ostati otvoren ako nema dovoljno jasne osnove.

---

## 6) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj pojmova u ulazu,
- broj potpuno validiranih,
- broj djelomično validiranih,
- broj onih koji čekaju daljnju validaciju,
- popis potvrđenih sidara po nadređenom pojmu,
- popis pojmova bez konačne odluke.

---

## 7) Deterministički izvještaj

Skripta mora na stdout ispisati za svaki nadređeni pojam:

- broj kandidata u ulazu,
- broj potvrđenih sidara u izlazu,
- završni `status_validacije`.

Skripta mora ispisati i ukupne brojeve po statusima validacije.
