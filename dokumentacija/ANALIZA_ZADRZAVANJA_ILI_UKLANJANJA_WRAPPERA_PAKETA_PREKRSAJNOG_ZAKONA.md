# ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_PAKETA_PREKRSAJNOG_ZAKONA

Datum: 05.04.2026.
Status: read-only analiza nakon migracije na genericki alat.
Opseg: samo analiza skupine wrapper skripti i izrada jednog novog
Dokumenta, bez izmjene postojecih skripti, bez commita i bez pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrdeno stanje prije izrade ovog dokumenta:

- `git status --short`: prazno
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`
- zadnja 3 commita:
  - `763e441` -
    `feat: wrapperi paketa prekrsajnog zakona preusmjereni na`
    `genericki alat`
  - `03c7ec0` -
    `feat: uveden genericki alat za zatvaranje paketa prekrsajnog`
    `zakona`
  - `308a7b7` -
    `docs: dubinska analiza skupine zatvori paket prekrsajni zakon`
- `git branch -vv`:
  - `main` je na `763e441`
  - `main` nosi oznaku `[origin/main]`
- `git ls-remote --heads origin main`:
  - udaljeni `main` pokazuje isti hash
    `763e44177c0edf576423a8bff779a25ea18334c6`

Zakljucak polaznog dokaza:

- repozitorij je cist
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Tocan scope analize

### Obvezno procitane datoteke

- `alati/zatvori_paket_prekrsajni_zakon.py`
- `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`
- `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`
- `alati/zatvori_paket_dostava_prekrsajni_zakon.py`
- `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`
- `alati/zatvori_paket_presuda_prekrsajni_zakon.py`
- `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`
- `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`
- `alati/zatvori_paket_zalba_prekrsajni_zakon.py`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_ZATVORI_PAKET_`
  `PREKRSAJNI_ZAKON.md`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

### Dodatne datoteke pregledane za dokaz kompatibilnosti

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
- `dokumentacija/DNEVNIK_RADA.md`

Te dodatne datoteke pregledane su radi provjere postoji li jos
stvarnih referenci na stara wrapper imena nakon migracije na genericki
alat.

---

## C) Stanje wrappera nakon migracije

### C1) `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`

- delegira `--vrsta-paketa apsolutna_nenadleznost`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - definira samo `VRSTA_PAKETA`
  - pronalazi `zatvori_paket_prekrsajni_zakon.py`
  - prosljeduje `sys.argv[1:]` kroz `subprocess.run(...)`
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C2) `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`

- delegira `--vrsta-paketa dokaz`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema vlastitu domensku logiku zatvaranja
  - samo gradi poziv prema generickom alatu
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C3) `alati/zatvori_paket_dostava_prekrsajni_zakon.py`

- delegira `--vrsta-paketa dostava`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema vise vlastiti selection algoritam
  - samo preusmjerava poziv na genericki alat
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C4) `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`

- delegira `--vrsta-paketa izvrsenje`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema vlastite paketne provjere ni JSON obradu
  - samo poziva genericki alat i vraca isti exit code
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C5) `alati/zatvori_paket_presuda_prekrsajni_zakon.py`

- delegira `--vrsta-paketa presuda`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema vise vlastitu poslovnu logiku
  - samo zadrzava staro ulazno ime skripte
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C6) `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`

- delegira `--vrsta-paketa prigovor`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - svedena je na minimalni kompatibilni ulazni sloj
  - sva stvarna obrada ostaje u generickom alatu
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C7) `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`

- delegira `--vrsta-paketa rjesenje`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema domenske razlike prema ostalim wrapperima
  - samo prosljeduje poziv i rezultat izvodenja
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### C8) `alati/zatvori_paket_zalba_prekrsajni_zakon.py`

- delegira `--vrsta-paketa zalba`
- stvarno je tanak wrapper: **DA**
- vlastita logika:
  - nema vise vlastito osvjezavanje rang-liste ni paketnu logiku
  - sve radi genericki alat
- zadrzao je isto javno ime i ulazni obrazac: **DA**

### Sažetak stanja skupine

Genericki alat sada nosi stvarnu zajednicku jezgru kroz `PackageConfig`,
`PACKAGE_CONFIGS`, zajednicku JSON obradu, izbor ciljnog niza i
jedinstveni CLI `--vrsta-paketa`.

Osam starih skripti vise ne nose stvarnu domensku logiku, nego samo
kompatibilni ulazni sloj pod starim imenima.

---

## D) Procjena potrebe za zadrzavanjem

### Postoji li dokaz da stare nazive treba zadrzati radi kompatibilnosti

**Da, ali taj dokaz je pretezno dokumentacijski i povijesni, a ne
programski.**

Procitana dokumentacija i repo pretraga pokazuju da stara imena i dalje
postoje u:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_ZATVORI_PAKET_`
  `PREKRSAJNI_ZAKON.md`

### Postoje li reference u dokumentaciji ili procesima koje jos upucuju na
stare nazive

**Da, u dokumentaciji postoje.**

Repo pretraga nad radnim stablom pokazuje vise dokumentacijskih tragova
koji jos izrijekom navode osam starih naziva wrappera kao operativne
ili povijesne korake.

**Nije pronaden jasan dokaz o aktivnim runtime pozivima iz drugih `.py`
ili `.ps1` orkestratora** izvan samih wrapper datoteka. Drugim rijecima,
kompatibilnost je trenutno vise dokumentacijska i korisnicka nego strogo
kodska.

### Bi li trenutno uklanjanje bilo prerano ili sigurno

**Trenutno uklanjanje bilo bi prerano.**

Razlog nije u tome sto wrapperi nose vaznu logiku, nego u tome sto bi
uklanjanje sada ostavilo nesklad izmedu stvarnog koda i vise vazecih
statusnih, standardnih i revizijskih dokumenata koji jos navode stara
imena.

---

## E) Procjena rizika uklanjanja

- rizik uklanjanja: **srednji**
- glavni razlog rizika:
  - kodni rizik je nizak jer su wrapperi stvarno tanki
  - dokumentacijski i kompatibilnosni rizik je srednji jer vise
    dokumenata jos upucuje na stara imena i operativni obrazac

Prije eventualnog removal koraka mora biti dokazano sve sljedece:

1. da su svi relevantni dokumenti azurirani na genericki alat
2. da u repou vise nema aktivnih poziva na stara imena iz procesa,
   uputa ili skripti
3. da jedan puni provjereni tok prolazi iskljucivo preko
   `alati/zatvori_paket_prekrsajni_zakon.py`
4. da je prijelaz dokumentiran kao zaseban, kontrolirani korak

---

## F) Zakljucak

`WRAPPERI_PAKETA_SU_KANDIDAT_ZA_KASNIJI_REMOVAL`

Sljedeci smisleni zadatak:

- napraviti removal-ready audit i obvezno azurirati dokumentaciju tako
  da `STATUS_PROJEKTA_VERITAS_H77.md`,
  `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`,
  `MAPA_DOKUMENTACIJE_VERITAS_H77.md` i
  `TEHNIČKI_OKVIR_VERITAS_H77.md` primarno upucuju na genericki alat
  prije bilo kakvog buduceg uklanjanja wrappera.
