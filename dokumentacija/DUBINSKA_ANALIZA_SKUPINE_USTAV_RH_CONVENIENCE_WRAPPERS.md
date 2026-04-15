# DUBINSKA ANALIZA SKUPINE USTAV_RH_CONVENIENCE_WRAPPERS

Datum: 15.04.2026.
Status: read-only dubinska analiza.
Opseg: samo skupina `USTAV_RH_CONVENIENCE_WRAPPERS`,
bez izmjene postojecih skripti, bez commita i bez pusha.

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
  `be680a5c360f0e3d3fccd619253acdca800577de`

Zakljucak polaznog dokaza:

- repo je bio cist prije ove analize
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Tocan scope analize

### B1) Ciljane skripte skupine

Analizirane su točno ove 2 skripte:

- `alati/run_normiratelj_ustav_rh.ps1`
- `alati/acceptance_ustav_rh_preflight.ps1`

### B2) Usporedna jezgra (genericki alati)

Za stvarnu usporedbu procitane su i ove 2 skripte:

- `alati/run_normiratelj.ps1`
- `alati/acceptance_preflight.ps1`

### B3) Dodatni dokumentacijski kontekst

Procitani kontekst za kontinuitet i status:

- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_`
  `U_ALATIMA_NAKON_PREKRSAJNI_JSON_VALIDATORI_V1.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

---

## C) Analiza po skripti

### C1) `run_normiratelj_ustav_rh.ps1`

#### C1.1 Cemu sluzi

Convenience wrapper za one-command pokretanje normiranja za
`ustav_rh`.

#### C1.2 Ulaz

- nema deklariranih parametara (`param()`)

#### C1.3 Delegacija

- racuna putanju do genericke jezgre:
  `Join-Path $PSScriptRoot "run_normiratelj.ps1"`
- poziva jezgru tocnim argumentom:
  `-AktSlug "ustav_rh"`
- prenosi izlazni kod poziva kroz:
  `exit $LASTEXITCODE`

#### C1.4 Vlastita poslovna logika

- nema dodatne poslovne logike
- nema vlastitih guardrail provjera
- nema vlastitog I/O ugovora

Zakljucak C1:

- skripta je tanki convenience wrapper bez vlastite domenske jezgre

### C2) `acceptance_ustav_rh_preflight.ps1`

#### C2.1 Cemu sluzi

Convenience wrapper za one-command acceptance preflight za `ustav_rh`.

#### C2.2 Ulaz

- opcionalni parametar:
  `-ExpectedCountOverride` (int)

#### C2.3 Delegacija

- racuna putanju do genericke jezgre:
  `Join-Path $PSScriptRoot "acceptance_preflight.ps1"`
- uvijek prosljeduje `-AktSlug "ustav_rh"`
- uvjetno prosljeduje `-ExpectedCountOverride` ako je zadan
- prenosi izlazni kod poziva kroz:
  `exit $LASTEXITCODE`

#### C2.4 Vlastita poslovna logika

- nema domenske validacije niti vlastitih pravila
- nema vlastitih datotecnih putanja osim putanje do jezgre
- jedina dodatna logika je tehnicka passthrough grana za opcionalni
  parametar

Zakljucak C2:

- skripta je tanki convenience wrapper s minimalnim parametarskim
  passthroughom

### C3) Usporedba s generickim jezgrama

`run_normiratelj.ps1`:

- sadrzi punu orkestraciju parsera i normiratelja
- sadrzi izbor izvora, selection report, fallback python poziv,
  putanje norme/sidra i guardrail grananje
- predstavlja stvarnu poslovnu i operativnu jezgru

`acceptance_preflight.ps1`:

- sadrzi layout guardrail (`norme`, `sidra`), tip-mode grananje,
  delta-control provjere, poziv python validatora i izlazne ugovore
- predstavlja stvarnu acceptance i validator jezgru

Sa stajalista koda:

- wrapperi iz ove skupine ne dupliciraju jezgrenu logiku
- wrapperi samo fiksiraju `AktSlug="ustav_rh"` i zadrzavaju
  one-command UX

---

## D) Usporedna matrica

- `run_normiratelj_ustav_rh.ps1`
  - zajednicka jezgra logike: `DA` (delegirano 100%)
  - specificni kriterij: fiksni `AktSlug=ustav_rh`
  - pise li u iste strukture kao genericka jezgra: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- `acceptance_ustav_rh_preflight.ps1`
  - zajednicka jezgra logike: `DA` (delegirano 100%)
  - specificni kriterij: fiksni `AktSlug=ustav_rh` + passthrough
    `ExpectedCountOverride`
  - pise li u iste strukture kao genericka jezgra: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

Sažetak matrice:

- oba clana su convenience wrapperi bez vlastite poslovne jezgre
- funkcionalna razlika je samo UX razina (fiksni slug i jednostavniji
  poziv)

---

## E) Repo-wide reference analiza po trazenim zonama

Trazeni uzorak pretrage:

- `run_normiratelj_ustav_rh.ps1`
- `acceptance_ustav_rh_preflight.ps1`

### E1) Zona `dokumentacija/**`

- pronadjeno: `16` pogodaka
- tip pogodaka: revizije, plan i dnevnicki tragovi
- zakljucak: reference su uglavnom dokumentacijske i operativno meke

### E2) Zona `alati/**`

- pronadjeno: `0` pogodaka u sadrzaju datoteka
- zakljucak: nema unutar-alatnog lančanog oslanjanja po imenu wrappera

### E3) Zona `baza_zakona/**`

- pronadjeno: `0` pogodaka
- zakljucak: baza normi/sidra ne ovisi o imenima wrappera

### E4) Zona `baza_terminologije/**`

- pronadjeno: `0` pogodaka
- zakljucak: terminoloski sloj ne ovisi o imenima wrappera

### E5) Zona `izvori/**`

- pronadjeno: `0` pogodaka
- zakljucak: dokazni/kontrolni izvori ne ovise o imenima wrappera

### E6) Root extension set (`README.md`, `docker-compose.yml`,
`requirements.txt`)

- pronadjeno: `0` pogodaka
- zakljucak: root-level operativne datoteke ne referenciraju wrappere

Ukupni zakljucak reference analize:

- aktivna vezanost za ova imena je koncentrirana u dokumentaciji
- tvrde operativne reference iz skriptnih i podatkovnih zona nisu
  dokazane

---

## F) Procjena rizika i zakljucak

Procjena razine rizika konsolidacije:

- `NIZAK_RIZIK`

Razlog:

- wrapperi su tanki delegatori bez vlastite jezgre
- jezgre su vec centralizirane u `run_normiratelj.ps1` i
  `acceptance_preflight.ps1`
- repo-wide pretraga nije dokazala tvrde ovisnosti izvan dokumentacije

Sto ostaje obvezno prije eventualnog uklanjanja wrappera:

1. azurirati dokumentacijske reference na genericke naredbe
2. osigurati da operativni playbook i CI koraci koriste izravne
   pozive generickih jezgri
3. ponoviti smoke i markdown gate nakon takve promjene

`SKUPINA_JE_KANDIDAT_ZA_KONSOLIDACIJU`
