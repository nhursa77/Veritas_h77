# POPIS_REFERENCI_NA_WRAPPERE_GRANSKIH_NATUKNICA

Datum: 04.04.2026.
Status: read-only repo pretraga.
Opseg: samo pretraga referenci i izrada jednog novog dokumenta,
bez izmjene postojećih skripti, bez commita i bez pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrđeno stanje prije izrade ovog dokumenta:

- `git status --short`: prazno
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`
- zadnja 3 commita:
  - `f9f0f5c` -
    `docs: analiza zadrzavanja ili uklanjanja wrappera granskih natuknica`
  - `8e3e5a3` -
    `feat: wrapperi granskih natuknica preusmjereni na genericki alat`
  - `d99769c` -
    `feat: uveden genericki alat za zatvaranje granskih natuknica`
- `git branch -vv`:
  - `main` je na `f9f0f5c`
  - `main` nosi oznaku `[origin/main]`
- `git ls-remote --heads origin main`:
  - udaljeni `main` pokazuje isti hash
    `f9f0f5c54e618307e3fbbe6d2d567bc5a2df798c`

Zaključak polaznog dokaza:

- repozitorij je čist
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Točan scope pretrage

### Traženi nazivi

Repo pretraga obuhvatila je točno ova 4 wrapper naziva:

- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

Tražene su i varijante bez prefiksa `alati/` te isti nazivi u relativnim
pozivima poput `./alati/...` i `--help` dokaznih naredbi, gdje su stvarno
prisutni.

### Obuhvaćeni dijelovi repoa

Pretraga je izvedena kroz cijeli repo, uključujući barem:

- `dokumentacija/**`
- `alati/**`
- `baza_zakona/**`
- `baza_terminologije/**`
- `izvori/**`
- root datoteke odgovarajućih tipova

### Obuhvaćeni tipovi datoteka

Obuhvaćeni su tipovi:

- `*.md`
- `*.ps1`
- `*.py`
- `*.json`
- `*.yml`
- `*.yaml`

Dokaz pretrage:

- workspace-wide `grep` nad `**/*.{md,ps1,py,json,yml,yaml}`
- dodatne ciljane provjere na:
  - `alati/**/*.{ps1,py}`
  - `baza_zakona/**`
  - `baza_terminologije/**`
  - `izvori/**`

Utvrđeno je da su rezultati koncentrirani u `dokumentacija/`, dok u
`alati/`, `baza_zakona/`, `baza_terminologije/` i `izvori/` nisu nađene
aktivne reference na stara wrapper imena.

---

## C) Rezultati po wrapperu

### C1) `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`

- broj pronađenih referenci: **14**
- pronađene u:
  - `dokumentacija/DNEVNIK_RADA.md`
  - `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
    `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
    `WRAPPERA_GRANSKIH_NATUKNICA.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - `dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
  - `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- klasifikacija referenci:
  - aktivne operativne reference: **0**
  - dokumentacijske reference: **da**
  - povijesni tragovi: **da**
  - self-reference / naziv same datoteke u kodu: **0**

### C2) `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`

- broj pronađenih referenci: **13**
- pronađene u:
  - `dokumentacija/DNEVNIK_RADA.md`
  - `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
    `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
    `WRAPPERA_GRANSKIH_NATUKNICA.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- klasifikacija referenci:
  - aktivne operativne reference: **0**
  - dokumentacijske reference: **da**
  - povijesni tragovi: **da**
  - self-reference / naziv same datoteke u kodu: **0**

### C3) `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`

- broj pronađenih referenci: **14**
- pronađene u:
  - `dokumentacija/DNEVNIK_RADA.md`
  - `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
    `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
    `WRAPPERA_GRANSKIH_NATUKNICA.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- klasifikacija referenci:
  - aktivne operativne reference: **0**
  - dokumentacijske reference: **da**
  - povijesni tragovi: **da**
  - self-reference / naziv same datoteke u kodu: **0**

### C4) `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

- broj pronađenih referenci: **13**
- pronađene u:
  - `dokumentacija/DNEVNIK_RADA.md`
  - `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
  - `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
    `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
  - `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
    `WRAPPERA_GRANSKIH_NATUKNICA.md`
  - `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- klasifikacija referenci:
  - aktivne operativne reference: **0**
  - dokumentacijske reference: **da**
  - povijesni tragovi: **da**
  - self-reference / naziv same datoteke u kodu: **0**

### Sažeti obrazac rezultata

Pretraga nije pokazala stvarne aktivne pozive na stara wrapper imena u:

- `alati/**/*.ps1`
- `alati/**/*.py`
- `baza_zakona/**`
- `baza_terminologije/**`
- `izvori/**`

Sve stvarno pronađene reference nalaze se u dokumentaciji i dokaznim
tragovima.

---

## D) Procjena kompatibilnosti

### Postoje li još aktivni pozivi ili oslanjanja na stare nazive

**Ne postoji dokaz o aktivnim operativnim pozivima** na stara wrapper
imena kroz ostatak repoa.

Nisu pronađene reference u aktivnim orkestracijskim skriptama pod
`alati/`, niti u podatkovnim i dokaznim slojevima pod
`baza_zakona/`, `baza_terminologije/` i `izvori/`.

### Postoji li razlog da wrapperi ostanu

Postoji još **prijelazni dokumentacijski razlog**, ali ne i snažan dokaz
runtime potrebe.

Drugim riječima:

- razlog za zadržavanje je pretežno radi uredne tranzicije i dokumentacije
- razlog nije u stvarnoj preostaloj poslovnoj logici ili aktivnom pozivanju

### Jesu li reference većinom samo povijesne / dokumentacijske

**Da.**

Pronađene reference su gotovo u cijelosti:

- dokumentacijske reference
- povijesni i dokazni tragovi
- statusni zapisi ranijih koraka

To znači da kompatibilnost više nije prvenstveno tehnička, nego
revizijsko-dokumentacijska.

---

## E) Zaključak

`WRAPPERI_SU_SPREMNI_ZA_PLANIRANI_REMOVAL`

Sljedeći smisleni zadatak:

- pripremiti kontrolirani removal korak uz obvezno ažuriranje
  dokumentacije tako da `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`,
  `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md`, `DNEVNIK_RADA.md` i
  `TEHNIČKI_OKVIR_VERITAS_H77.md` više ne upućuju operativno na stare
  wrapper nazive prije njihova planiranog uklanjanja.
