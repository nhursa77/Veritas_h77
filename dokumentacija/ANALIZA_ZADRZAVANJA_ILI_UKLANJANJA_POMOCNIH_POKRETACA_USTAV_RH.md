# ANALIZA ZADRZAVANJA ILI UKLANJANJA POMOCNIH POKRETACA USTAV RH

Datum: 15.04.2026.
Status: read-only analiza removal spremnosti.
Opseg: samo skupina `POMOCNI_POKRETACI_USTAV_RH`,
bez izmjene skripti, bez brisanja, bez preimenovanja,
bez commita i bez pusha.

---

## A) Polazni git dokaz

Obvezni pre-check pokrenut je iz `C:\Veritas_H77` prije izrade dokumenta.

Utvrdeno stanje repoa:

- `git status --short` -> bez izlaza
- `git diff --name-only` -> bez izlaza
- `git diff --cached --name-only` -> bez izlaza
- `git stash list` ->
  `stash@{0}: On main: veritas-pre-rebase-z147`

Zadnjih 5 commitova:

- `8f4e6e7` - `docs: uskladjen hrvatski naziv skupine pomocni`
  `pokretaci ustav rh`
- `b6cc0be` - `feat: ustav rh convenience wrapperi preusmjereni na`
  `zajednicku jezgru`
- `45d655a` - `docs: dubinska analiza skupine ustav rh convenience`
  `wrappers`
- `be680a5` - `docs: revizija preostalih kandidata za konsolidaciju`
  `u alatima nakon prekrsajni json validatori v1`
- `dfdc31f` - `feat: uklonjeni wrapperi validatora prekrsajnog json`
  `v1 nakon konsolidacije`

Stanje grane:

- `git branch -vv` pokazuje:
  `* main 8f4e6e7 [origin/main] docs: uskladjen hrvatski naziv`
  `skupine pomocni pokretaci ustav rh`

Poravnanje s `origin/main`:

- `git rev-parse HEAD` vraca:
  `8f4e6e739dd769bb07e940eda4a02bcfa7a7da63`
- `git ls-remote origin refs/heads/main` vraca isti hash:
  `8f4e6e739dd769bb07e940eda4a02bcfa7a7da63`

Zakljucak polaznog dokaza:

- repo je bio cist
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Tocan scope analize

Analiza obuhvaca tocno ove datoteke:

- `alati/run_normiratelj_ustav_rh.ps1`
- `alati/acceptance_ustav_rh_preflight.ps1`
- `alati/ustav_rh_convenience_core.ps1`
- `alati/run_normiratelj.ps1`
- `alati/acceptance_preflight.ps1`

Dodatni procitani dokumentacijski kontekst:

- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_POMOCNI_POKRETACI_`
  `USTAV_RH.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Repo-pretraga stvarno je pokrenuta kroz:

- `dokumentacija/`
- `alati/`
- `baza_zakona/`
- `baza_terminologije/`
- `izvori/`
- root datoteke uzoraka `.md`, `.ps1`, `.py`, `.json`, `.yml`, `.yaml`

---

## C) Stanje nakon konsolidacije

Stanje nakon uvedene zajednicke jezgre je sljedece:

- `run_normiratelj_ustav_rh.ps1` sada delegira na
  `ustav_rh_convenience_core.ps1 -Mode "run_normiratelj"`
- `acceptance_ustav_rh_preflight.ps1` sada delegira na
  `ustav_rh_convenience_core.ps1 -Mode "acceptance_preflight"`
- `ustav_rh_convenience_core.ps1` delegira dalje na genericke jezgre
  `run_normiratelj.ps1` i `acceptance_preflight.ps1`

Vlastita logika u wrapperima:

- `run_normiratelj_ustav_rh.ps1` nema vlastitu poslovnu logiku;
  sadrzi samo `[CmdletBinding()]`, `param()`, izracun putanje do
  zajednicke jezgre i poziv s fiksnim `Mode`
- `acceptance_ustav_rh_preflight.ps1` nema vlastitu poslovnu logiku;
  sadrzi samo `[CmdletBinding()]`, opcionalni parametar
  `ExpectedCountOverride`, izracun putanje do zajednicke jezgre i
  passthrough poziv

Operativni razlog da ostanu kao javna kompatibilna imena:

- postoji UX i kompatibilnosni razlog jer i dalje nude one-command
  javna imena za `ustav_rh`
- ali po stvarno procitanom kodu taj razlog vise nije tehnicki blocker
  za planned removal; to je prije svega pitanje dokumentacijskog i
  operativnog naming sloja

Zakljucak stanja nakon konsolidacije:

- wrapperi vise nisu jezgra
- wrapperi su sada samo tanki kompatibilni sloj iznad zajednicke jezgre

---

## D) Rezultati repo-pretrage

### D1) `run_normiratelj_ustav_rh.ps1`

Ukupan broj pronadenih referenci u repou:

- `17`

Gdje su pronadjene:

- `dokumentacija/DNEVNIK_RADA.md` -> `3` novija i `1` starija traga
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` -> `1`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` -> `1`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_POMOCNI_POKRETACI_`
  `USTAV_RH.md` -> `4`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md` -> `3`
- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
  `ALATIMA.md` -> `2`
- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
  `ALATIMA_NAKON_PREKRSAJNI_JSON_VALIDATORI_V1.md` -> `3`

Klasifikacija referenci:

- aktivne operativne reference: `0`
- dokumentacijske reference: `4`
  `STATUS_PROJEKTA_VERITAS_H77.md`, `TEHNIČKI_OKVIR_VERITAS_H77.md`,
  `RAZVOJNI/REVIZIJSKI` dokumenti kao aktivni opisni tragovi
- povijesni tragovi: `4`
  stariji i noviji unosi u `DNEVNIK_RADA.md`
- self-reference: `4`
  reference unutar dubinske analize iste skupine
- ostale dokumentacijsko-analiticke reference: `5`
  preostali revizijski dokumenti koji nisu operativni pozivi

Zakljucak za ovaj wrapper:

- nije dokazana nijedna aktivna operativna referenca iz skripti,
  podataka, izvora ni root konfiguracije

### D2) `acceptance_ustav_rh_preflight.ps1`

Ukupan broj pronadenih referenci u repou:

- `15`

Gdje su pronadjene:

- `dokumentacija/DNEVNIK_RADA.md` -> `3` novija i `1` stariji trag
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` -> `1`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` -> `1`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_POMOCNI_POKRETACI_`
  `USTAV_RH.md` -> `4`
- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
  `ALATIMA.md` -> `2`
- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
  `ALATIMA_NAKON_PREKRSAJNI_JSON_VALIDATORI_V1.md` -> `3`
- `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md` -> `1`

Klasifikacija referenci:

- aktivne operativne reference: `0`
- dokumentacijske reference: `4`
  `STATUS_PROJEKTA_VERITAS_H77.md`, `TEHNIČKI_OKVIR_VERITAS_H77.md`,
  `RAZVOJNI_PLAN_VERITAS_H77.md` i aktivni revizijski tragovi
- povijesni tragovi: `4`
  stariji i noviji unosi u `DNEVNIK_RADA.md`
- self-reference: `4`
  reference unutar dubinske analize iste skupine
- ostale dokumentacijsko-analiticke reference: `3`
  preostali revizijski dokumenti koji nisu operativni pozivi

Zakljucak za ovaj wrapper:

- nije dokazana nijedna aktivna operativna referenca iz skripti,
  podataka, izvora ni root konfiguracije

### D3) Sažetak repo-pretrage po zonama

- `dokumentacija/` -> sve stvarno pronadjene reference su ovdje
- `alati/` -> `0` pogodaka u sadrzaju datoteka
- `baza_zakona/` -> `0`
- `baza_terminologije/` -> `0`
- `izvori/` -> `0`
- root `.md`, `.ps1`, `.py`, `.json`, `.yml`, `.yaml` -> `0`
  izvan vec pronadjenih dokumentacijskih tragova

Zakljucak zone pretrage:

- cijeli preostali trag je dokumentacijski ili povijesni
- aktivni operativni call-site nije dokazan

---

## E) Procjena removal spremnosti

Postoji li jos aktivni operativni blocker:

- `NE`

Bi li planned removal sada bio prerani:

- kao tehnicki rez `NE`
- kao kanonski dokumentacijski rez `DA`, ako se prethodno ne usklade
  svi aktivni dokumentacijski tragovi koji jos navode wrapper imena

Je li removal dopusten nakon jos jedne dokumentacijske uskladbe:

- `DA`

Je li odmah siguran bez dodatnog rada:

- `NE`

Razlog procjene:

- zajednicka jezgra vec postoji i operativna logika nije u wrapperima
- wrapperi vise nisu referencirani iz `alati/`, `baza_zakona/`,
  `baza_terminologije/`, `izvori/` ni root konfiguracijskog sloja
- preostale reference su dokumentacijske, povijesne ili self-reference
- planned removal trazi jos jedan kontrolirani dokumentacijski korak da
  se kanonski tekstovi i analiticki tragovi usklade sa stanjem bez
  wrappera

---

## F) Zakljucak

`POMOCNI_POKRETACI_USTAV_RH_SU_SPREMNI_ZA_PLANIRANI_REMOVAL`

Tocno jedan sljedeci smisleni zadatak:

- pripremiti scoped removal korak za
  `run_normiratelj_ustav_rh.ps1` i
  `acceptance_ustav_rh_preflight.ps1`, uz obvezno azuriranje
  `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`,
  `dokumentacija/DNEVNIK_RADA.md` i svih aktivnih dokumentacijskih
  referenci koje jos navode ta imena
