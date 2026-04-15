# REVIZIJA KANDIDATA ZA KONSOLIDACIJU U ALATIMA NAKON PJV1

Datum: 15.04.2026.
Status: read-only revizija.
Opseg: cijela mapa `alati/`, bez izmjene skripti, bez brisanja,
bez preimenovanja, bez commita i bez pusha.

---

## A) Polazni git dokaz

Obvezni pre-check pokrenut je iz `C:\Veritas_H77` prije izrade dokumenta.

Utvrdeno stanje:

- `git status --short` -> bez izlaza
- `git diff --name-only` -> bez izlaza
- `git diff --cached --name-only` -> bez izlaza
- `git stash list` ->
  `stash@{0}: On main: veritas-pre-rebase-z147`

Stanje grane i poravnanje:

- `git rev-parse HEAD` i `git ls-remote origin refs/heads/main`
  vracaju isti hash:
  `dfdc31faa72dfc01d76459f9f61072c69cf5766f`

Zakljucak polaznog dokaza:

- repo je bio cist prije ove revizije
- `main` je poravnat s `origin/main`
- stash nije diran
- skupina `PREKRSAJNI_JSON_VALIDATORI_V1` vec je zatvorena kroz
  konsolidaciju na `validiraj_json_po_shemi_v1.ps1` i uklanjanje 5
  legacy wrapper validatora

---

## B) Trenutno stanje mape alati

Top-level inventar:

- `ALATI_FILE_COUNT=64`

Serije po prefiksu/uzorku (top-level):

- `acceptance_* = 3`
- `run_* = 4`
- `validiraj_* = 5`
- `parsiraj_* = 4`
- `normiraj_* = 2`
- `dohvati_* = 2`
- `kontroliraj_* = 2`
- `zatvori_* = 3`
- `*curia* = 5`

Napomena o metodologiji:

- kandidati su procijenjeni po stvarnom sadrzaju skripti
- nije radena procjena samo po nazivu datoteka
- procjena je radena nakon zatvaranja skupine
  `PREKRSAJNI_JSON_VALIDATORI_V1`

---

## C) Ozbiljni kandidati nakon zatvaranja PREKRSAJNI_JSON_VALIDATORI_V1

### C1) Skupina `USTAV_RH_CONVENIENCE_WRAPPERS`

Clanovi:

- `alati/run_normiratelj_ustav_rh.ps1`
- `alati/acceptance_ustav_rh_preflight.ps1`

Dokazana homogenost sadrzajem:

- oba alata su tanka delegacija na genericke ulaze
- `run_normiratelj_ustav_rh.ps1` delegira na
  `run_normiratelj.ps1 -AktSlug "ustav_rh"`
- `acceptance_ustav_rh_preflight.ps1` delegira na
  `acceptance_preflight.ps1 -AktSlug "ustav_rh"`

Procjena:

- duplikacija: **srednja**
- korist konsolidacije: **srednja**
- rizik: **nizak**

### C2) Skupina `TOK_PN_DEPRECATED_I_POVEZANI_VALIDATOR`

Clanovi:

- `alati/run_tok_pn_prigovor_v1.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`
- referentna jezgra: `alati/run_tok_v1.ps1`

Procjena homogenosti:

- postoji jasan deprecated signal u
  `run_tok_pn_prigovor_v1.ps1` (kanonski runner je `run_tok_v1.ps1`)
- ali skupina nije cisti wrapper blok:
  ukljucuje i zasebni izlazni validator s marker-pravilima

Procjena:

- duplikacija: **niska do srednja**
- korist konsolidacije: **srednja**
- rizik: **srednji**

### C3) Skupina `PS1_LAUNCHERI_PYTHON_ENGINEA`

Primjeri:

- `parsiraj_ustav_zakonhr.ps1` + `parsiraj_ustav_zakonhr.py`
- `parsiraj_nn_html.ps1` + `parsiraj_nn_html.py`
- `kontroliraj_arhivu_nn.ps1` + `kontroliraj_arhivu_nn.py`
- `normiraj_ustav_u_norma_json.ps1` + `normiraj_ustav_u_norma_json.py`

Procjena homogenosti:

- PS1 launcheri jesu slicni kao pozivni sloj
- ali Python jezgre rade razlicite domenske poslove
- to je zajednicki launcher obrazac, ne jedan homogen refaktor blok

Procjena:

- duplikacija: **srednja (launcher), niska (domena)**
- korist konsolidacije: **niska do srednja**
- rizik: **srednji do visok**

---

## D) Odabir jedne sljedece skupine

U ovom ciklusu prednost ima skupina koja je:

- dovoljno homogena po stvarnom kodu
- niskog operativnog rizika
- dovoljno mala za deterministicki dokaz kroz CI/gate korake

Usporedni zakljucak:

- `USTAV_RH_CONVENIENCE_WRAPPERS` ima najcistiji post-closure obrazac
  i najmanji rizik
- `TOK_PN_DEPRECATED_I_POVEZANI_VALIDATOR` trazi dodatnu analizu
  ovisnosti prije reza
- `PS1_LAUNCHERI_PYTHON_ENGINEA` nije pogodan za brzu konsolidaciju
  jer je domena heterogena

---

## E) Zavrsni odabir

`SLJEDECA_SKUPINA_ZA_OBRADU = USTAV_RH_CONVENIENCE_WRAPPERS`

Točno jedan sljedeci smisleni zadatak:

- napraviti read-only dubinsku analizu uklanjanja ili zadrzavanja
  convenience wrappera `run_normiratelj_ustav_rh.ps1` i
  `acceptance_ustav_rh_preflight.ps1`, uz obavezno azuriranje
  `dokumentacija/TEHNICKI_OKVIR_VERITAS_H77.md` i
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` prema rezultatu
  analize

Zavrsni zakljucak:

- nakon zatvaranja `PREKRSAJNI_JSON_VALIDATORI_V1`, najrazumniji
  sljedeci kandidat je mali i niski-rizicni wrapper blok za
  `ustav_rh`
- ostale skupine za sada ostaju kandidat za kasniji ciklus
  zbog vise heterogenosti ili veceg rizika

