# ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_PREKRSAJNI_JSON_VALIDATORI_V1

Datum: 05.04.2026.
Status: read-only analiza.
Opseg: samo dokazna analiza skupine `PREKRSAJNI_JSON_VALIDATORI_V1`
i izrada ovog dokumenta, bez izmjene skripti, bez commita i bez pusha.

---

## A) Polazni git dokaz

Obvezni pre-check pokrenut je iz `C:\Veritas_H77` prije izrade dokumenta.

Utvrđeno stanje:

- `git status --short` -> bez izlaza
- `git diff --name-only` -> bez izlaza
- `git diff --cached --name-only` -> bez izlaza
- `git stash list` ->
  `stash@{0}: On main: veritas-pre-rebase-z147`

Zadnja 3 commita:

- `d9965b4` - `feat: validatori prekrsajnog json v1 preusmjereni na`
  `genericki schema-driven alat`
- `a20b24d` - `feat: uveden genericki schema-driven validator v1`
- `585a303` - `docs: dubinska analiza skupine prekrsajni json`
  `validatori v1`

Stanje grane i poravnanje:

- `git branch -vv` pokazuje:
  `* main d9965b4 [origin/main] feat: validatori prekrsajnog json v1`
  `preusmjereni na genericki schema-driven alat`
- `git rev-parse HEAD` vraća:
  `d9965b482c57729634ff00aef3b0a8ae41e7c94f`
- `git ls-remote origin refs/heads/main` vraća isti hash:
  `d9965b482c57729634ff00aef3b0a8ae41e7c94f`

Zaključak polaznog dokaza:

- repo je bio čist
- `main` je poravnat s `origin/main`
- stash nije diran
- analiza se temelji na stvarno pročitanom kodu i stvarnoj repo-pretrazi

---

## B) Točan scope analize

### B1) Jezgra koja ulazi u ovu analizu

Generička jezgra:

- `alati/validiraj_json_po_shemi_v1.ps1`

Pet wrapper validatora koji ulaze u zaključak:

- `alati/validiraj_audit_v1.ps1`
- `alati/validiraj_intake_prekrsaji_v1.ps1`
- `alati/validiraj_postupak_v1.ps1`
- `alati/validiraj_predlozak_v1.ps1`
- `alati/validiraj_subsumciju_v1.ps1`

### B2) Dodatne datoteke pročitane radi dokaza kompatibilnosti

- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_V1.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `alati/ci_smoke.ps1`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`

### B3) Rubni kontekst koji nije uključen kao ista skupina

Sljedeće skripte su uzete samo kao rubni kontekst i ne ulaze u završni
zaključak o wrapperima ove skupine:

- `alati/validiraj_audit_generated_v1.ps1`
- `alati/validiraj_delta_ops.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`

---

## C) Stanje wrappera nakon migracije

### C1) `validiraj_audit_v1.ps1`

- delegira na `validiraj_json_po_shemi_v1.ps1`
- koristi `SCHEMA_AUDIT_V1.json`
- javno ime skripte i no-arg usage obrazac ostali su zadržani
- wrapper je tanak, ali nije potpuno trivijalan:
  zadržava minimalnu kompatibilnosnu logiku za normalizaciju
  `moduli[].ulazi` i `moduli[].izlazi` prije delegacije
- novu poslovnu logiku ne uvodi

### C2) `validiraj_intake_prekrsaji_v1.ps1`

- delegira na `validiraj_json_po_shemi_v1.ps1`
- koristi `SCHEMA_INTAKE_PREKRSAJI_V1.json`
- zadržava isto javno ime i isti osnovni usage obrazac
- stvarno je tanak wrapper:
  path/schema check, enumeracija ciljnih datoteka, delegacija i završni
  `exit code`
- nema dodatnu poslovnu logiku izvan delegacije

### C3) `validiraj_postupak_v1.ps1`

- delegira na `validiraj_json_po_shemi_v1.ps1`
- koristi `SCHEMA_POSTUPAK_V1.json`
- zadržava isto javno ime i isti usage obrazac
- stvarno je tanak wrapper bez starog copy-paste kostura
- vlastita logika svedena je na pronalazak `postupak.json` datoteka i
  prijenos izlaznog statusa

### C4) `validiraj_predlozak_v1.ps1`

- delegira na `validiraj_json_po_shemi_v1.ps1`
- koristi `SCHEMA_PREDLOZAK_V1.json`
- zadržava isto javno ime i isti usage obrazac
- stvarno je tanak wrapper
- nema dodatnu poslovnu logiku; služi kao kompatibilni ulazni naziv

### C5) `validiraj_subsumciju_v1.ps1`

- delegira na `validiraj_json_po_shemi_v1.ps1`
- koristi `SCHEMA_SUBSUMPCIJA_V1.json`
- zadržava isto javno ime i isti usage obrazac
- stvarno je tanak wrapper
- nema dodatnu poslovnu logiku; zadržava samo file discovery i prijenos
  izlaznog statusa

Sažetak stanja wrappera:

- svih 5 skripti ostaju izvršive pod starim imenima
- svih 5 delegiraju na isti generički alat
- 4 od 5 su čisti tanki wrapperi
- `validiraj_audit_v1.ps1` zadržava malu kompatibilnosnu prilagodbu

---

## D) Rezultati repo-pretrage

Repo-pretraga je stvarno provedena nad cijelim workspaceom, uz dodatne
ciljane pretrage po mapama:

- `dokumentacija/**`
- `alati/**`
- `baza_zakona/**`
- `baza_terminologije/**`
- `izvori/**`
- root `.md`, `.ps1`, `.py`, `.json`, `.yml`, `.yaml` kroz workspace-wide
  grep iz korijena repoa

Zajednički rezultat po mapama:

- `alati/**` -> pronađeno točno 5 aktivnih operativnih referenci,
  sve u `alati/ci_smoke.ps1`
- `dokumentacija/**` -> pronađeni su dokumentacijski i povijesni tragovi
- `baza_zakona/**` -> nema pogodaka
- `baza_terminologije/**` -> nema pogodaka
- `izvori/**` -> nema pogodaka
- u root konfiguracijskim datotekama nije nađena dodatna aktivna referenca

### D1) `validiraj_audit_v1.ps1`

Broj pronađenih referenci: **10**

- aktivne operativne reference:
  - `alati/ci_smoke.ps1` (1)
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- povijesni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (3)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (3)
- self-reference:
  - nema zasebnog tekstualnog self-matcha u tijelu skripte

### D2) `validiraj_intake_prekrsaji_v1.ps1`

Broj pronađenih referenci: **11**

- aktivne operativne reference:
  - `alati/ci_smoke.ps1` (1)
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
- povijesni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (3)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (3)
- self-reference:
  - nema zasebnog tekstualnog self-matcha u tijelu skripte

### D3) `validiraj_postupak_v1.ps1`

Broj pronađenih referenci: **9**

- aktivne operativne reference:
  - `alati/ci_smoke.ps1` (1)
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- povijesni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (3)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (3)
- self-reference:
  - nema zasebnog tekstualnog self-matcha u tijelu skripte

### D4) `validiraj_predlozak_v1.ps1`

Broj pronađenih referenci: **10**

- aktivne operativne reference:
  - `alati/ci_smoke.ps1` (1)
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- povijesni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (3)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (3)
- self-reference:
  - nema zasebnog tekstualnog self-matcha u tijelu skripte

### D5) `validiraj_subsumciju_v1.ps1`

Broj pronađenih referenci: **10**

- aktivne operativne reference:
  - `alati/ci_smoke.ps1` (1)
- dokumentacijske reference:
  - `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- povijesni tragovi:
  - `dokumentacija/DNEVNIK_RADA.md` (3)
  - `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
    `ALATIMA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNI_JSON_VALIDATORI_`
    `V1.md` (3)
- self-reference:
  - nema zasebnog tekstualnog self-matcha u tijelu skripte

Glavni zaključak repo-pretrage:

- aktivne operativne reference **postoje** i centralizirane su u
  `alati/ci_smoke.ps1`
- izvan `alati/` pronađeni su uglavnom dokumentacijski i povijesni tragovi
- nisu pronađene dodatne aktivne reference u `baza_zakona/`,
  `baza_terminologije/` ni `izvori/`

---

## E) Procjena potrebe za zadržavanjem

Odgovor na tražena pitanja:

- postoji dokaz da stare nazive još treba zadržati radi kompatibilnosti:
  **da**
- taj dokaz je eksplicitna aktivna operativna upotreba u
  `alati/ci_smoke.ps1`, koji ih i dalje poziva po starim imenima
- postoje reference koje trenutno blokiraju removal:
  **da**
- blokiraju ga:
  - aktivni smoke entrypointi u `alati/ci_smoke.ps1`
  - aktualna dokumentacija koja ih još navodi kao postojeće javne nazive
- bi li trenutno uklanjanje bilo sigurno:
  **ne**
- bi li trenutno uklanjanje bilo prerano:
  **da**

Dodatna procjena:

- wrapperi trenutno imaju stvarnu kompatibilnosnu vrijednost jer čuvaju
  stare ulazne točke bez potrebe da ostatak repoa odmah prijeđe na novi
  pozivni obrazac
- `validiraj_audit_v1.ps1` dodatno nosi malu prilagodbu kompatibilnosti,
  što još više govori protiv trenutnog uklanjanja

---

## F) Procjena rizika uklanjanja

Procjena za cijelu skupinu:

- rizik uklanjanja: **srednji**
- glavni razlog tog rizika:
  aktivne operativne reference su malobrojne i centralizirane, ali još
  uvijek stvarno postoje; uz to je dokumentacija već usklađena s time da
  wrapperi postoje kao javna kompatibilnosna imena

Što mora biti dokazano prije eventualnog removal koraka:

- da `alati/ci_smoke.ps1` više ne poziva stara imena
- da je dokumentacija usklađena s novim stanjem
- da nema dodatnih repo-referenci nakon ponovne grep provjere
- da smoke i help/usage provjere prolaze i bez tih datoteka
- da je posebno riješena ili uklonjena audit-kompatibilnosna prilagodba,
  ako više ne bude potrebna

---

## G) Zaključak

`WRAPPERE_VALIDATORA_ZA_SAD_ZADRZATI`

Sljedeći smisleni zadatak:

- pripremiti zaseban scoped korak za uklanjanje aktivnih referenci iz
  `alati/ci_smoke.ps1` i obvezno uskladiti dokumentaciju
  (`TEHNIČKI_OKVIR_VERITAS_H77.md` i `STATUS_PROJEKTA_VERITAS_H77.md`)
  prije eventualnog planned removal koraka
