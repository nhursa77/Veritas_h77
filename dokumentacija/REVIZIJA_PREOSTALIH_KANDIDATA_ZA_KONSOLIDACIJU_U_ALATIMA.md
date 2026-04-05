# REVIZIJA PREOSTALIH KANDIDATA ZA KONSOLIDACIJU U ALATIMA

Datum: 05.04.2026.
Status: read-only revizija.
Opseg: cijela mapa `alati/`, bez izmjene skripti, bez brisanja,
bez preimenovanja, bez commita i bez pusha.

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

- `691c722` - `feat: uklonjeni wrapperi paketa prekrsajnog zakona`
  `nakon konsolidacije`
- `ff8f7b4` - `docs: popis referenci na wrappere paketa prekrsajnog`
  `zakona`
- `68c7471` - `docs: analiza zadrzavanja ili uklanjanja wrappera`
  `paketa prekrsajnog zakona`

Stanje grane i poravnanje:

- `git branch -vv` pokazuje:
  `* main 691c722 [origin/main] feat: uklonjeni wrapperi paketa`
  `prekrsajnog zakona nakon konsolidacije`
- `git rev-parse HEAD` vraca:
  `691c72216084138cd5662c15a4942e95c533d8e7`
- `git ls-remote origin refs/heads/main` vraca isti hash:
  `691c72216084138cd5662c15a4942e95c533d8e7`

Zaključak polaznog dokaza:

- repo je bio čist prije revizije
- `main` je poravnat s `origin/main`
- stash nije diran
- aktivne skupine koje su već konsolidirane i uklonjene ne ulaze u ovu
  reviziju kao novi kandidat

---

## B) Inventar preostalih kandidata

Napomena o metodologiji:

- pregledana je cijela mapa `alati/`
- skripte su grupirane po prefiksu i po stvarnom obrascu rada
- za ozbiljne kandidate površinski je pročitan stvarni sadržaj, a ne samo
  naziv datoteke

### B1) Skupina `PREKRSAJNI_JSON_VALIDATORI_V1`

Članovi jezgre skupine:

- `alati/validiraj_audit_v1.ps1`
- `alati/validiraj_audit_generated_v1.ps1`
- `alati/validiraj_intake_prekrsaji_v1.ps1`
- `alati/validiraj_postupak_v1.ps1`
- `alati/validiraj_predlozak_v1.ps1`
- `alati/validiraj_subsumciju_v1.ps1`

Bliski srodnici iste obitelji:

- `alati/validiraj_delta_ops.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`

Zašto skupina izgleda homogeno:

- svih 6 jezgri imaju isti PowerShell kostur:
  `repoRoot -> schemaPath -> targetRoot -> files -> ConvertFrom-Json ->`
  `VALIDATOR_*_EXIT`
- u više skripti se ponavlja ista pomoćna funkcija
  `Test-RequiredProps`
- razlike su uglavnom u:
  - putanji do sheme
  - filteru ciljnih datoteka
  - nekoliko domenskih enum provjera
- to je vrlo sličan obrazac kakav je već bio dobar kandidat za raniju
  konsolidaciju u drugim skupinama

### B2) Skupina `USTAV_RH_CONVENIENCE_WRAPPERS`

Članovi skupine:

- `alati/run_normiratelj_ustav_rh.ps1`
- `alati/acceptance_ustav_rh_preflight.ps1`

Zašto skupina izgleda homogeno:

- obje skripte su vrlo tanke convenience wrapper skripte
- `run_normiratelj_ustav_rh.ps1` samo poziva
  `run_normiratelj.ps1 -AktSlug "ustav_rh"`
- `acceptance_ustav_rh_preflight.ps1` samo poziva
  `acceptance_preflight.ps1 -AktSlug "ustav_rh"`
- obrazac je jasan, ali skupina je mala i korist od zahvata je ograničena

### B3) Skupina `TOK_RUNNERI_I_DEPRECIRANI_WRAPPERI`

Članovi skupine:

- `alati/run_tok_v1.ps1`
- `alati/run_tok_pn_prigovor_v1.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`
- rubno povezani helperi:
  `generiraj_audit_prekrsaji_v1.ps1` i
  `test_fixtures_audit_prekrsaji_v1.ps1`

Zašto djeluje djelomično homogeno:

- `run_tok_pn_prigovor_v1.ps1` je eksplicitno označen kao
  `DEPRECATED (KANONSKI)` i upućuje na `run_tok_v1.ps1`
- postoji jasna generička jezgra za tokove (`run_tok_v1.ps1`)
- ali ostatak skupine nije čisti wrapper blok nego kombinacija runnera,
  validatora i fixture testova

### B4) Skupina `PS1_LAUNCHERI_PYTHON_ENGINEA`

Članovi koji pokazuju sličan uzorak:

- `alati/kontroliraj_arhivu_nn.ps1` +
  `alati/kontroliraj_arhivu_nn.py`
- `alati/parsiraj_nn_html.ps1` + `alati/parsiraj_nn_html.py`
- `alati/parsiraj_ustav_zakonhr.ps1` +
  `alati/parsiraj_ustav_zakonhr.py`
- `alati/normiraj_ustav_u_norma_json.ps1` +
  `alati/normiraj_ustav_u_norma_json.py`
- `alati/izvuci_rupe_teksta_norme.ps1` +
  `alati/izvuci_rupe_teksta_norme.py`

Zašto djeluje samo djelomično homogeno:

- PowerShell sloj je sličan jer uglavnom poziva Python jezgru iz `.venv`
- ali stvarna domena rada nije ista:
  - arhiva NN
  - parsiranje HTML-a
  - parsiranje `zakon.hr`
  - normiranje `ustav_rh`
  - dijagnostika rupa teksta norme
- zato to nije jedan čist refaktorski blok nego samo zajednički launcher
  obrazac

### B5) Skupina `CURIA_I_NN_SIDRENJE_PIPELINE`

Članovi primjera:

- `alati/pretvori_curia_xlsx_u_json.py`
- `alati/normaliziraj_curia_terminologiju.py`
- `alati/segmentiraj_curia_terminoloske_zapise.py`
- `alati/sidri_osnovni_postupovni_skup_na_nn.py`
- `alati/upisi_validirana_nn_sidra_u_natuknice.py`

Zašto izgleda samo djelomično homogeno:

- radi se o jednoj poslovnoj domeni, ali ne o jednom istom algoritmu
- svaka skripta radi drugi korak nad drugim ulazno/izlaznim strukturama
- to je procesni pipeline, a ne skup skoro-istih wrappera ili skoro-istih
  validatora

---

## C) Kandidati koje ne treba dirati

### C1) CI i gate jezgra

Za sada ne dirati:

- `alati/ci_smoke.ps1`
- `alati/lint_markdown.ps1`
- `alati/lint_markdown.py`
- `alati/provjeri_markdown_scope.ps1`
- `alati/acceptance_preflight.ps1`
- `alati/acceptance_paket.ps1`

Razlog:

- to je aktivni operativni kostur repoa
- promjene tu nose previsok rizik za svakodnevne gateove
- homogenost postoji samo djelomično, ali je rizik veći od trenutne koristi

### C2) Opći NN ingest i normiranje

Za sada ne dirati:

- `alati/dohvati_nn.ps1`
- `alati/parsiraj_nn_html.ps1`
- `alati/parsiraj_nn_html.py`
- `alati/normiratelj_iz_strukture_nn.py`
- `alati/provjeri_usklađenost_norme.ps1`
- `alati/provjeri_usklađenost_norme.py`

Razlog:

- to su kanonski operativni alati za ingest i validaciju normi
- sličnost je funkcionalna, ali ne i dovoljno duplicirana za siguran brzi
  rez
- svaka pogrešna apstrakcija ovdje bi dirala glavni tok baze zakona

### C3) CURIA i rječnički pipeline

Za sada ne dirati:

- `alati/pretvori_curia_xlsx_u_json.py`
- `alati/normaliziraj_curia_terminologiju.py`
- `alati/segmentiraj_curia_terminoloske_zapise.py`
- `alati/mapiraj_curia_na_potencijalne_nn_pojmove.py`
- `alati/sidri_osnovni_postupovni_skup_na_nn.py`
- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`
- `alati/upisi_validirana_nn_sidra_u_natuknice.py`

Razlog:

- lanac je dovoljno važan, ali nije dovoljno homogen
- to su različite faze iste obrade, ne ista skripta u više varijanti
- trenutno nema dovoljno duplikacije da bi konsolidacija bila najisplativiji
  sljedeći potez

---

## D) Usporedna procjena kandidata

### D1) `PREKRSAJNI_JSON_VALIDATORI_V1`

- procjena homogenosti: **visoka**
- procjena rizika: **srednja**
- procjena koristi od konsolidacije: **visoka**
- preporuka: `SLJEDECI_KANDIDAT`

Obrazloženje:

- skupina ima najviše ponovljenog kostura po stvarnom sadržaju
- razlike su lokalne i uglavnom parametarske
- postoji dobra prilika za jedan generički validator uz parametre:
  `schema`, `root`, `filter` i `exit-marker`
- istodobno je rizik još uvijek kontroliran jer je domena uska i već je
  strogo provjeravana kroz `ci_smoke.ps1`

### D2) `USTAV_RH_CONVENIENCE_WRAPPERS`

- procjena homogenosti: **visoka**
- procjena rizika: **nizak**
- procjena koristi od konsolidacije: **srednja**
- preporuka: `KASNIJI_KANDIDAT`

Obrazloženje:

- skupina je gotovo čisti wrapper obrazac
- ali radi se samo o dva mala convenience ulaza
- korist od zahvata je manja nego kod validatora jer se uklanja manje
  dupliciranog koda i manje ukupnog šuma

### D3) `TOK_RUNNERI_I_DEPRECIRANI_WRAPPERI`

- procjena homogenosti: **srednja**
- procjena rizika: **srednji**
- procjena koristi od konsolidacije: **srednja**
- preporuka: `KASNIJI_KANDIDAT`

Obrazloženje:

- postoji jasan deprecated trag u `run_tok_pn_prigovor_v1.ps1`
- ali obitelj nije čista: u njoj se miješaju runner, validator i testni
  fixture sloj
- prije bilo kakvog reza treba dodatna dubinska provjera CI ovisnosti

### D4) `PS1_LAUNCHERI_PYTHON_ENGINEA`

- procjena homogenosti: **srednja**
- procjena rizika: **srednji do visok**
- procjena koristi od konsolidacije: **niska do srednja**
- preporuka: `ZA_SAD_NE_DIRATI`

Obrazloženje:

- zajednički launcher uzorak postoji, ali stvarne domene i izlazi su
  previše različiti
- takav rez bi lako proizveo umjetnu apstrakciju bez stvarne koristi
- trenutno je važnije čuvati jasne operativne ulaze nego spajati sve
  `.ps1` launchere pod isti kalup

---

## E) Završni odabir

`SLJEDECA_SKUPINA_ZA_OBRADU = PREKRSAJNI_JSON_VALIDATORI_V1`

Zašto baš ta skupina:

- pokazuje najčišći preostali obrazac stvarne duplikacije u `alati/`
- homogenost je dokazana sadržajem, a ne samo prefiksom naziva
- skupina je dovoljno velika da konsolidacija donese mjerljivu korist,
  ali i dovoljno ograničena da dokazni ciklus ostane pod kontrolom

Točno jedan sljedeći smisleni zadatak:

- napraviti read-only dubinsku analizu skupine
  `validiraj_*_v1.ps1`, utvrditi minimalnu zajedničku jezgru budućeg
  generičkog validatora i to dokumentirati u novom dokumentu
  `dokumentacija/DUBINSKA_ANALIZA_SKUPINE_PREKRSAJNIH_VALIDATORA_V1.md`

Završni zaključak:

- sljedeći prioritet nije veliki rez nad cijelom mapom `alati/`
- sljedeći prioritet je ciljana konsolidacija skupine
  `PREKRSAJNI_JSON_VALIDATORI_V1`
- ostale djelomično homogene skupine treba ostaviti za kasniji ciklus ili
  za sada ne dirati
