# ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_GRANSKIH_NATUKNICA

Datum: 04.04.2026.
Status: read-only analiza nakon migracije na generički alat.
Opseg: samo analiza skupine wrapper skripti i izrada jednog novog dokumenta,
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
  - `8e3e5a3` -
    `feat: wrapperi granskih natuknica preusmjereni na genericki alat`
  - `d99769c` -
    `feat: uveden genericki alat za zatvaranje granskih natuknica`
  - `e1e4122` -
    `docs: dubinska analiza skupine zatvori validiranu gransku natuknicu`
- `git branch -vv`:
  - `main` je na `8e3e5a3`
  - `main` nosi oznaku `[origin/main]`
- `git ls-remote --heads origin main`:
  - udaljeni `main` pokazuje isti hash
    `8e3e5a3b68d1f36b13597105f9d5fcabba1c7ed0`

Zaključak polaznog dokaza:

- repozitorij je čist
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Točan scope analize

### Obvezno pročitane datoteke

- `alati/zatvori_validiranu_gransku_natuknicu.py`
- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
  `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

### Dodatne datoteke pregledane za dokaz kompatibilnosti

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Ove dodatne datoteke bile su potrebne samo za provjeru postoje li još
reference na stara imena wrappera.

---

## C) Stanje wrappera nakon migracije

### C1) `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`

- delegira na `alati/zatvori_validiranu_gransku_natuknicu.py`
- fiksni način delegiranja: `--nacin prva`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - blokira ručno zadavanje `--nacin`
  - pronalazi generički alat po imenu datoteke
  - prosljeđuje ostale argumente kroz `subprocess.run(...)`
- zadržano javno ime i ulazni obrazac: **DA**

### C2) `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`

- delegira na `alati/zatvori_validiranu_gransku_natuknicu.py`
- fiksni način delegiranja: `--nacin druga`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - ista minimalna zaštita protiv dodatnog `--nacin`
  - nema vlastitu domensku logiku zatvaranja
- zadržano javno ime i ulazni obrazac: **DA**

### C3) `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`

- delegira na `alati/zatvori_validiranu_gransku_natuknicu.py`
- fiksni način delegiranja: `--nacin sljedeca`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - samo minimalni CLI guard i prosljeđivanje poziva
  - nema više vlastiti selection algoritam
- zadržano javno ime i ulazni obrazac: **DA**

### C4) `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

- delegira na `alati/zatvori_validiranu_gransku_natuknicu.py`
- fiksni način delegiranja: `--nacin jos_jedna`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - samo minimalni CLI guard i prosljeđivanje poziva
  - nema više vlastitu poslovnu logiku
- zadržano javno ime i ulazni obrazac: **DA**

### Sažetak stanja skupine

Generički alat sada sadrži stvarnu zajedničku jezgru kroz `MODE_CONFIGS`
i jedinstveni CLI `--nacin {prva,druga,sljedeca,jos_jedna}`.
Četiri stare skripte više ne nose stvarnu domensku logiku, nego samo
kompatibilni ulazni sloj.

---

## D) Procjena potrebe za zadržavanjem

### Postoji li dokaz da stare nazive treba zadržati radi kompatibilnosti

**Da, ali taj dokaz je pretežno dokumentacijski i povijesni, a ne
programski.**

Dokaz iz pročitanih materijala i pretrage repoa pokazuje da su stara imena
još uvijek prisutna u:

- `dokumentacija/DNEVNIK_RADA.md`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_`
  `ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

### Postoje li još reference na stara imena

**Da, u dokumentaciji postoje.**

`grep` provjera nad `**/*.{md,py,ps1,json}` pokazuje reference na stara
imena wrappera u više dokumentacijskih tragova i statusnih zapisa.

**Ne postoji dokaz o aktivnim pozivima iz drugih operativnih skripti**
izvan samih wrapper datoteka. Drugim riječima, u repou nije nađen jasan
runtime ovisnički lanac koji bi zahtijevao da stara imena odmah ostanu
zbog drugih `ps1` ili `py` orkestratora.

### Bi li trenutno uklanjanje bilo prerano ili sigurno

**Trenutno uklanjanje bilo bi prerano.**

Razlog nije u tome što wrapperi nose važnu logiku, nego u tome što bi
uklanjanje sada ostavilo nesklad između stvarnog stanja koda i više
postojećih kanonskih i povijesnih dokumentacijskih tragova.

---

## E) Procjena rizika uklanjanja

- rizik uklanjanja: **srednji**
- glavni razlog rizika:
  - kodni rizik je nizak jer su wrapperi stvarno tanki
  - dokumentacijski i kompatibilnosni rizik je srednji jer više dokumenata
    i dalje navodi stara imena kao operativne korake ili povijesne tragove

Prije eventualnog removal koraka mora biti dokazano sve sljedeće:

1. da u repou više nema aktivnih procesa koji očekuju stara imena
2. da su svi relevantni dokumenti ažurirani na generički alat
3. da jedan puni provjereni tok prolazi i bez oslanjanja na stara imena
4. da je prijelaz dokumentiran kao poseban, kontrolirani korak

---

## F) Zaključak

`WRAPPERI_SU_KANDIDAT_ZA_KASNIJI_REMOVAL`

Sljedeći smisleni zadatak:

- pripremiti kontrolirani removal-ready audit i obvezno ažurirati
  dokumentaciju tako da `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`,
  `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md` i
  `TEHNIČKI_OKVIR_VERITAS_H77.md` upućuju na generički alat prije bilo
  kakvog budućeg uklanjanja wrappera.
