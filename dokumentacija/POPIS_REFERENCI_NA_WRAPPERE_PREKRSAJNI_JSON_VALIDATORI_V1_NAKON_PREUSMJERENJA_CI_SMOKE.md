# POPIS REFERENCI NA WRAPPERE VALIDATORA V1 NAKON CI SMOKE

Datum: 05.04.2026.
Status: read-only analiza.
Opseg: samo repo-pretraga, dokazni pregled i izrada ovog jednog dokumenta,
bez izmjene skripti, bez commita i bez pusha.

---

## A) Polazni git dokaz

Obvezni pre-check pokrenut je iz `C:\Veritas_H77` prije izrade dokumenta.

Utvrdeno stanje:

- `git status --short` -> bez izlaza
- `git diff --name-only` -> bez izlaza
- `git diff --cached --name-only` -> bez izlaza
- `git stash list` ->
  `stash@{0}: On main: veritas-pre-rebase-z147`

Zadnja 3 commita:

- `7a09ec7` -> `docs: dopunjeni commit hashovi u dnevniku za zadatke`
  `164 166`
- `cfc1455` -> `docs: uskladjen status projekta nakon zadatka 166`
- `967576a` -> `feat: ci smoke za validatore v1 preusmjeren na`
  `genericki schema-driven alat`

Stanje grane i poravnanje:

- `git branch -vv` pokazuje:
  `* main 7a09ec7 [origin/main] docs: dopunjeni commit hashovi u dnevniku`
  `za zadatke 164 166`
- `git rev-parse HEAD` vraca:
  `7a09ec7910a771f80e0f38858e47e464413fd512`
- `git ls-remote origin refs/heads/main` vraca isti hash:
  `7a09ec7910a771f80e0f38858e47e464413fd512`

Zakljucak polaznog dokaza:

- repo je bio cist
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Tocan scope analize

U ovu analizu ulazi tocno ovih 5 wrapper validatora:

- `alati/validiraj_audit_v1.ps1`
- `alati/validiraj_intake_prekrsaji_v1.ps1`
- `alati/validiraj_postupak_v1.ps1`
- `alati/validiraj_predlozak_v1.ps1`
- `alati/validiraj_subsumciju_v1.ps1`

Obvezni kontekst:

- `alati/ci_smoke.ps1`

Dodatne procitane datoteke radi dokaza preostalih referenci:

- `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
  `PREKRSAJNI_JSON_VALIDATORI_V1.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Rubni kontekst koji nije ukljucen kao ista skupina:

- `alati/validiraj_json_po_shemi_v1.ps1`
- `alati/validiraj_audit_generated_v1.ps1`
- `alati/validiraj_delta_ops.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`

---

## C) Stanje nakon preusmjerenja ci_smoke.ps1

Potvrdeno je da je `alati/ci_smoke.ps1` vec preusmjeren na genericki
alat `alati/validiraj_json_po_shemi_v1.ps1`.

U `ci_smoke.ps1` pet koraka (`validate_audit_v1`,
`validate_intake_prekrsaji_v1`, `validate_postupak_v1`,
`validate_predlozak_v1`, `validate_subsumcija_v1`) vise ne pozivaju
stare wrapper skripte po imenu, nego koriste helper
`Invoke-GenericSchemaValidationSet` i genericki validator.

Ciljana repo-pretraga unutar `alati/**` za svih 5 imena vratila je:

- `No matches found`

To znaci:

- u `ci_smoke.ps1` vise nema aktivnih referenci na 5 wrapper validatora
- glavni operativni blocker iz prethodne analize je uklonjen
- skupina vise nije runtime ovisnost smoke lanca

---

## D) Rezultati repo-pretrage

Repo-pretraga je stvarno provedena iz korijena workspacea i obuhvatila je:

- `dokumentacija/**`
- `alati/**`
- `baza_zakona/**`
- `baza_terminologije/**`
- `izvori/**`
- workspace-wide grep iz korijena repoa, koji pokriva i root `.md`, `.ps1`,
  `.py`, `.json`, `.yml` i `.yaml` datoteke

Zajednicki rezultat po mapama:

- `dokumentacija/**` -> `62` pogotka, svi dokumentacijski ili povijesni
- `alati/**` -> `0` pogodaka
- `baza_zakona/**` -> `0` pogodaka
- `baza_terminologije/**` -> `0` pogodaka
- `izvori/**` -> `0` pogodaka
- root konfiguracijske i skriptne datoteke -> nema dodatnih pogodaka

### D1) `validiraj_audit_v1.ps1`

Broj pronadenih referenci u sadrzaju repoa: `14`

- aktivne operativne reference: `0`
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` (`1`)
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` (`1`)
- povijesni / dokazni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (`3`)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md` (`1`)
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
    `PREKRSAJNI_JSON_VALIDATORI_V1.md` (`5`)
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (`3`)
- self-reference / naziv same datoteke u sadrzaju skripti: `0`

### D2) `validiraj_intake_prekrsaji_v1.ps1`

Broj pronadenih referenci u sadrzaju repoa: `13`

- aktivne operativne reference: `0`
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` (`1`)
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` (`1`)
  - `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md` (`1`)
- povijesni / dokazni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (`3`)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md` (`1`)
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
    `PREKRSAJNI_JSON_VALIDATORI_V1.md` (`3`)
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (`3`)
- self-reference / naziv same datoteke u sadrzaju skripti: `0`

### D3) `validiraj_postupak_v1.ps1`

Broj pronadenih referenci u sadrzaju repoa: `11`

- aktivne operativne reference: `0`
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` (`1`)
- povijesni / dokazni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (`3`)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md` (`1`)
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
    `PREKRSAJNI_JSON_VALIDATORI_V1.md` (`3`)
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (`3`)
- self-reference / naziv same datoteke u sadrzaju skripti: `0`

### D4) `validiraj_predlozak_v1.ps1`

Broj pronadenih referenci u sadrzaju repoa: `12`

- aktivne operativne reference: `0`
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` (`1`)
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` (`1`)
- povijesni / dokazni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (`3`)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md` (`1`)
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
    `PREKRSAJNI_JSON_VALIDATORI_V1.md` (`3`)
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (`3`)
- self-reference / naziv same datoteke u sadrzaju skripti: `0`

### D5) `validiraj_subsumciju_v1.ps1`

Broj pronadenih referenci u sadrzaju repoa: `12`

- aktivne operativne reference: `0`
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` (`1`)
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` (`1`)
- povijesni / dokazni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (`3`)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md` (`1`)
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_`
    `PREKRSAJNI_JSON_VALIDATORI_V1.md` (`3`)
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (`3`)
- self-reference / naziv same datoteke u sadrzaju skripti: `0`

Sa zbrojnog stajalista repo-pretrage vrijedi:

- aktivne operativne reference na 5 wrapper validatora vise nisu pronadene
- preostale reference nalaze se samo u dokumentaciji i povijesnim tragovima
- izvan `dokumentacija/**` nije naden nijedan aktivni poziv ni ovisnost

---

## E) Procjena removal spremnosti

Odgovori na obvezna pitanja:

- postoji li jos ijedan aktivni operativni blocker -> `NE`
- je li glavni blocker iz `ci_smoke.ps1` uklonjen -> `DA`
- jesu li preostale reference sada samo dokumentacijske / povijesne -> `DA`
- bi li planned removal sada bio -> `dopusten nakon jos jedne`
  `dokumentacijske uskladbe`

Prakticno tumacenje:

- planned removal vise nije blokiran runtime ovisnoscu
- prije samog fizickog uklanjanja wrappera treba u istom scoped zadatku
  uskladiti referentnu dokumentaciju koja ih jos navodi
- zbog toga removal nije prerani, ali ga treba provesti kao kontrolirani
  korak s obveznim doc updateom

---

## F) Zakljucak

`WRAPPERI_VALIDATORA_SU_SPREMNI_ZA_PLANIRANI_REMOVAL`

Sljedeci smisleni zadatak:

- provesti scoped planned removal ovih 5 wrapper validatora uz obvezno
  azuriranje `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`
