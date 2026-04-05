# DUBINSKA ANALIZA SKUPINE PREKRSAJNI_JSON_VALIDATORI_V1

Datum: 05.04.2026.
Status: read-only dubinska analiza.
Opseg: samo skupina validatora `PREKRSAJNI_JSON_VALIDATORI_V1`,
bez izmjene skripti, bez brisanja, bez preimenovanja,
bez commita i bez pusha.

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

- `564d054` - `docs: revizija preostalih kandidata za konsolidaciju u`
  `alatima`
- `691c722` - `feat: uklonjeni wrapperi paketa prekrsajnog zakona nakon`
  `konsolidacije`
- `ff8f7b4` - `docs: popis referenci na wrappere paketa prekrsajnog`
  `zakona`

Stanje grane i poravnanje:

- `git branch -vv` pokazuje:
  `* main 564d054 [origin/main] docs: revizija preostalih kandidata za`
  `konsolidaciju u alatima`
- `git rev-parse HEAD` vraca:
  `564d054be763e61d090904ed6ef6a8dd98f08593`
- `git ls-remote origin refs/heads/main` vraca isti hash:
  `564d054be763e61d090904ed6ef6a8dd98f08593`

Zaključak polaznog dokaza:

- repo je bio čist
- `main` je poravnat s `origin/main`
- stash nije diran
- analiza se temelji na stvarno pročitanom kodu, ne na nagađanju

---

## B) Točan scope analize

### B1) Jezgra skupine koja stvarno ulazi u analizu

Na temelju prethodne revizije i stvarno pročitanog koda,
jezgru skupine `PREKRSAJNI_JSON_VALIDATORI_V1` čine ovih 6 skripti:

- `alati/validiraj_audit_v1.ps1`
- `alati/validiraj_audit_generated_v1.ps1`
- `alati/validiraj_intake_prekrsaji_v1.ps1`
- `alati/validiraj_postupak_v1.ps1`
- `alati/validiraj_predlozak_v1.ps1`
- `alati/validiraj_subsumciju_v1.ps1`

To su stvarni članovi skupine jer:

- svi validiraju JSON artefakte `v1` iz istog prekršajnog domena rada
- svi imaju isti operativni obrazac `load -> enumerate -> validate ->`
  `Write-Host exit marker`
- svih 6 je orkestrirano kroz `alati/ci_smoke.ps1`

### B2) Rubno srodne skripte koje su dodatno pročitane za usporedbu

Pročitane su još 2 pomoćne skripte jer su u prethodnoj reviziji bile
navedene kao bliski srodnici:

- `alati/validiraj_delta_ops.ps1`
- `alati/validiraj_izlaz_tok_pn_prigovor_v1.ps1`

Zaključak o statusu te 2 skripte:

- **nisu** jezgra skupine `PREKRSAJNI_JSON_VALIDATORI_V1`
- `validiraj_delta_ops.ps1` je generički validator `delta_ops` datoteka
  u kontrolnom sloju `zakon.hr`, a ne validator prekršajnih `v1` artefakata
- `validiraj_izlaz_tok_pn_prigovor_v1.ps1` validira tekstualni izlaz
  nacrta (`.txt`), a ne JSON strukturu po shemi

### B3) Dodatni dokumentacijski kontekst koji je stvarno pročitan

- `dokumentacija/REVIZIJA_PREOSTALIH_KANDIDATA_ZA_KONSOLIDACIJU_U_`
  `ALATIMA.md`
- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

---

## C) Analiza po skripti

### C1) `validiraj_audit_v1.ps1`

#### C1.1 Čemu služi

Validira osnovne `audit_v*.json` datoteke unutar
`predmeti\sud\prekrsajni\**\audit\`.

#### C1.2 Ulaz

- nema CLI argumenata
- sam računa:
  - `$repoRoot`
  - `$schemaPath`
  - `$targetRoot`
- ciljne datoteke nalazi preko:
  `Get-ChildItem -Recurse -File -Filter "audit_v*.json"`
  uz dodatni uvjet da putanja sadrži `\audit\`

#### C1.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_AUDIT_V1.json`

#### C1.4 Kako provodi validaciju

- učita shemu kroz `ConvertFrom-Json`
- za svaku datoteku učita JSON dokument
- koristi zajednički helper `Test-RequiredProps`
- provjerava obvezna polja na razinama:
  - `root`
  - `meta`
  - `preporuceni_pravni_lijek`
  - `gate_stanje`
  - `moduli[]`
  - `nalazi[]`
  - `rokovi[]`
- dodatno provjerava enum vrijednosti za:
  - `moduli[].status`
  - `nalazi[].tezina`

#### C1.5 Kako vraća rezultat

- ako shema nedostaje: ispisuje grešku i izlazi s `exit 1`
- ako nema ciljnih datoteka: ispisuje `NEMA_DATOTEKA=1` i vraća
  `exit 0`
- ako validacija prođe: ispisuje `VALIDATOR_AUDIT_V1_EXIT=0`
- ako padne: ispisuje `VALIDATOR_AUDIT_V1_EXIT=1`

#### C1.6 Glavne funkcije / koraci

- `Test-RequiredProps`
- enumeracija datoteka
- `ConvertFrom-Json`
- provjera obveznih polja i enum vrijednosti
- završni `VALIDATOR_*_EXIT`

#### C1.7 Ključne razlike prema ostalima

- ima najširu i najdublju strukturu među članovima jezgre
- provjerava više različitih podblokova nego intake, predložak i
  subsumpcija

### C2) `validiraj_audit_generated_v1.ps1`

#### C2.1 Čemu služi

Validira generirani `audit_generated_v1.json` nakon izračuna audit sloja.

#### C2.2 Ulaz

- nema CLI argumenata
- ciljne datoteke nalazi pod:
  `predmeti\sud\prekrsajni\**\audit\audit_generated_v1.json`

#### C2.3 Shema ili pravilo koje validira

- **ne koristi vanjsku JSON shemu**
- validira ručno definirana poslovna pravila i konzistenciju izlaza

#### C2.4 Kako provodi validaciju

- učitava JSON kroz `ConvertFrom-Json`
- provjerava postojanje `meta` i `gate_stanje`
- ako postoji blok `g1`, provjerava njegova polja i tipove
- provjerava da `nalazi` bude lista ispravnih objekata
- provjerava obvezne kodove:
  - `NAP-G1`
  - `NAP-G2`
  - `NAP-G3`
  - `NAP-SEM`
  - `NAP-ODL`
- iz `NAP-SEM.opis` izvlači `preflight=(ZELENO|ZUTO|CRVENO)`
- zatim provjerava usklađenost između semafora, prisutnih kodova i
  `gate_stanje.blocked`

#### C2.5 Kako vraća rezultat

- `NEMA_DATOTEKA=1` i `exit 0` ako datoteka nema
- `VALIDATOR_AUDIT_GENERATED_V1_EXIT=0` na prolazu
- `VALIDATOR_AUDIT_GENERATED_V1_EXIT=1` na padu

#### C2.6 Glavne funkcije / koraci

- učitavanje JSON-a
- provjera strukture `g1` bloka
- provjera `nalazi[]`
- semaforska logika `preflight`
- provjera usklađenosti `blocked` stanja

#### C2.7 Ključne razlike prema ostalima

- nema `schemaPath` ni učitavanje vanjske sheme
- najviše je poslovno-orijentiran i najmanje je čist schema validator
- zato pripada skupini, ali nije najbolji kandidat za prvi generički rez

### C3) `validiraj_intake_prekrsaji_v1.ps1`

#### C3.1 Čemu služi

Validira `intake_v*.json` u prekršajnim predmetima.

#### C3.2 Ulaz

- nema CLI argumenata
- ciljne datoteke nalazi kroz:
  `Get-ChildItem -Recurse -File -Filter "intake_v*.json"`
  uz uvjet da su pod `\intake\`

#### C3.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_INTAKE_PREKRSAJI_V1.json`

#### C3.4 Kako provodi validaciju

- učita shemu
- koristi isti helper `Test-RequiredProps`
- provjerava:
  - `root`
  - `meta`
  - `kontradikcije`
- provjerava enum za:
  - `cilj`
  - `osporavanja[]`
- provjerava tipove za:
  - `kontradikcije.ima_kontradikcija`
  - `kontradikcije.opis`

#### C3.5 Kako vraća rezultat

- isti obrazac kao i `audit_v1`:
  `NEMA_DATOTEKA=1`, odnosno
  `VALIDATOR_INTAKE_PREKRSAJI_V1_EXIT=0/1`

#### C3.6 Glavne funkcije / koraci

- `Test-RequiredProps`
- enumeracija JSON datoteka
- schema-driven required checks
- enum i type checks

#### C3.7 Ključne razlike prema ostalima

- uži je od `audit_v1`
- radi nad manjom i ravnijom strukturom
- vrlo je dobar kandidat da postane čisti parametar generičkog
  validatora

### C4) `validiraj_postupak_v1.ps1`

#### C4.1 Čemu služi

Validira `postupak.json` za prekršajne proceduralne tokove.

#### C4.2 Ulaz

- nema CLI argumenata
- ciljne datoteke traži u:
  `postupci\sud\prekrsajni\**\postupak.json`

#### C4.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_POSTUPAK_V1.json`

#### C4.4 Kako provodi validaciju

- učita shemu
- koristi `Test-RequiredProps`
- provjerava:
  - `root`
  - `meta`
  - `koraci[]`
  - `koraci[].gate[]`
- dodatno provjerava:
  - da su `korak.id` stringovi
  - da su `ulazi` i `izlazi` polja nizovi
  - da `gate.operator` i `gate.akcija_na_fail` budu u dopuštenim
    enumima

#### C4.5 Kako vraća rezultat

- `VALIDATOR_POSTUPAK_V1_EXIT=0` ili `1`
- kod praznog targeta vraća `NEMA_DATOTEKA=1` i `exit 0`

#### C4.6 Glavne funkcije / koraci

- isti opći kostur kao ostali schema-driven validatori
- dodatno ima jaču provjeru tipova i ugovora za proceduralni DSL

#### C4.7 Ključne razlike prema ostalima

- jedini glavni član koji ne cilja `predmeti/` ili `predlosci/`, nego
  `postupci/`
- ipak zadržava isti validator kostur i isti izlazni ugovor

### C5) `validiraj_predlozak_v1.ps1`

#### C5.1 Čemu služi

Validira `predlozak.json` za prekršajne predloške dokumenata.

#### C5.2 Ulaz

- nema CLI argumenata
- ciljne datoteke traži u:
  `predlosci\sud\prekrsajni\**\predlozak.json`

#### C5.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_PREDLOZAK_V1.json`

#### C5.4 Kako provodi validaciju

- učitava shemu
- koristi `Test-RequiredProps`
- provjerava:
  - `root`
  - `meta`
  - `sekcije[]`
  - `sekcije[].polja[]`
  - `mapiranje`
  - `mapiranje.pravila[]`
- dodatno provjerava enum za `transformacija`

#### C5.5 Kako vraća rezultat

- `VALIDATOR_PREDLOZAK_V1_EXIT=0` ili `1`
- kod praznog targeta `NEMA_DATOTEKA=1` i `exit 0`

#### C5.6 Glavne funkcije / koraci

- isti kostur kao `intake`, `postupak` i `subsumcija`
- razlika je samo u dubini i imenima podstruktura

#### C5.7 Ključne razlike prema ostalima

- cilja predložak, a ne audit ili intake artefakte
- ali po kodu je gotovo školski primjer parametarskog schema validatora

### C6) `validiraj_subsumciju_v1.ps1`

#### C6.1 Čemu služi

Validira `subsumcija_v*.json` u audit sloju prekršajnih predmeta.

#### C6.2 Ulaz

- nema CLI argumenata
- ciljne datoteke traži pod:
  `predmeti\sud\prekrsajni\**\audit\subsumcija_v*.json`

#### C6.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_SUBSUMPCIJA_V1.json`

#### C6.4 Kako provodi validaciju

- učita shemu
- koristi `Test-RequiredProps`
- provjerava:
  - `root`
  - `meta`
  - `elementi_bica[]`
- provjerava enum `elementi_bica[].status`

#### C6.5 Kako vraća rezultat

- `VALIDATOR_SUBSUMPCIJA_V1_EXIT=0` ili `1`
- kod praznog targeta `NEMA_DATOTEKA=1` i `exit 0`

#### C6.6 Glavne funkcije / koraci

- isti schema-driven kostur kao kod intake i predloška
- manji broj dodatnih poslovnih pravila

#### C6.7 Ključne razlike prema ostalima

- najjednostavniji je među schema-driven članovima jezgre
- zbog toga je i najsigurniji kandidat za prvi parametarski prijenos

### C7) `validiraj_delta_ops.ps1` — rubno srodan, ali izvan jezgre

#### C7.1 Čemu služi

Validira sve `*_delta_ops.json` datoteke u
`izvori\kontrolno\zakon_hr\`.

#### C7.2 Ulaz

- nema CLI argumenata
- skenira cijeli delta control sloj pod `zakon.hr`

#### C7.3 Shema ili pravilo koje validira

- `dokumentacija\sheme\SCHEMA_DELTA_OPS.json`

#### C7.4 Kako provodi validaciju

- ne koristi `Test-RequiredProps`
- dinamički generira privremenu Python skriptu
- pokušava koristiti `jsonschema.Draft202012Validator`
- ako modul nije dostupan, koristi interni fallback validator

#### C7.5 Kako vraća rezultat

- ispisuje:
  - `DELTA_OPS_VALID: ...`
  - `DELTA_OPS_INVALID: ...`
  - `DELTA_OPS_SCHEMA_VALIDATION=OK`
- exit kod nije u istom `VALIDATOR_*_EXIT` formatu kao jezgra skupine

#### C7.6 Ključna razlika prema ostalima

- to je već polugenerički alat, ne standardni prekršajni `v1`
  validator
- po stvarnom kodu nije kandidat da uđe u prvi isti refaktorski rez

### C8) `validiraj_izlaz_tok_pn_prigovor_v1.ps1` — rubno srodan,
ali izvan jezgre

#### C8.1 Čemu služi

Validira gotovi tekstualni izlaz nacrta `nacrt_prigovor_pn_v1.txt`.

#### C8.2 Ulaz

- opcionalni argument `-OutputPath`
- ako argument nije zadan, koristi zadanu putanju u
  `predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\izlazi\`

#### C8.3 Shema ili pravilo koje validira

- ne koristi JSON shemu
- provjerava prisutnost obveznih tekstualnih markera u `.txt` izlazu

#### C8.4 Kako provodi validaciju

- provjerava postoji li datoteka i je li prazna
- učitava sadržaj kao tekst
- traži markere:
  - `NACRT - bez potpisa`
  - `TOK=`
  - `PREDMET_ID=`
  - `DATUM=`
  - `AUDIT_NALAZI_BEGIN`
  - `AUDIT_NALAZI_END`
  - `INTAKE_BEGIN`
  - `INTAKE_END`

#### C8.5 Kako vraća rezultat

- `VALIDATOR_IZLAZ_TOK_EXIT=0` ili `1`

#### C8.6 Ključna razlika prema ostalima

- ne validira JSON niti schema objekt
- ovo je validator tekstualnog proizvoda, ne validator prekršajnog JSON
  ugovora

---

## D) Usporedna matrica

### D1) `validiraj_audit_v1.ps1`

- zajednička jezgra logike:
  schema + `Test-RequiredProps` + enum provjere
- specifična schema / cilj validacije:
  `SCHEMA_AUDIT_V1.json`
- razina duplikacije: visoka
- može li biti parametar umjesto zasebne datoteke: da
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D2) `validiraj_audit_generated_v1.ps1`

- zajednička jezgra logike:
  file loop + JSON parse + exit ugovor
- specifična schema / cilj validacije:
  poslovna pravila bez vanjske sheme
- razina duplikacije: srednja
- može li biti parametar umjesto zasebne datoteke:
  djelomično, ali ne u prvom rezu
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D3) `validiraj_intake_prekrsaji_v1.ps1`

- zajednička jezgra logike:
  schema + `Test-RequiredProps` + enum provjere
- specifična schema / cilj validacije:
  `SCHEMA_INTAKE_PREKRSAJI_V1.json`
- razina duplikacije: visoka
- može li biti parametar umjesto zasebne datoteke: da
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D4) `validiraj_postupak_v1.ps1`

- zajednička jezgra logike:
  schema + `Test-RequiredProps` + enum provjere
- specifična schema / cilj validacije:
  `SCHEMA_POSTUPAK_V1.json`
- razina duplikacije: visoka
- može li biti parametar umjesto zasebne datoteke: da
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D5) `validiraj_predlozak_v1.ps1`

- zajednička jezgra logike:
  schema + `Test-RequiredProps` + enum provjere
- specifična schema / cilj validacije:
  `SCHEMA_PREDLOZAK_V1.json`
- razina duplikacije: visoka
- može li biti parametar umjesto zasebne datoteke: da
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D6) `validiraj_subsumciju_v1.ps1`

- zajednička jezgra logike:
  schema + `Test-RequiredProps` + enum provjere
- specifična schema / cilj validacije:
  `SCHEMA_SUBSUMPCIJA_V1.json`
- razina duplikacije: visoka
- može li biti parametar umjesto zasebne datoteke: da
- procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

### D7) `validiraj_delta_ops.ps1`

- zajednička jezgra logike:
  samo djelomično sličan ulazni kostur
- specifična schema / cilj validacije:
  temp Python + `jsonschema` nad `delta_ops`
- razina duplikacije: niska
- može li biti parametar umjesto zasebne datoteke:
  već je djelomično generički
- procjena: `OSTAVITI_ODVOJENO`

### D8) `validiraj_izlaz_tok_pn_prigovor_v1.ps1`

- zajednička jezgra logike:
  samo izlazni exit marker obrazac
- specifična schema / cilj validacije:
  tekstualni `.txt` marker check
- razina duplikacije: niska
- može li biti parametar umjesto zasebne datoteke:
  ne u istoj jezgri
- procjena: `OSTAVITI_ODVOJENO`

Sažetak matrice:

- najjače preklapanje postoji među 5 schema-driven validatora:
  `audit_v1`, `intake`, `postupak`, `predlozak` i `subsumcija`
- `audit_generated_v1` pripada istoj operativnoj obitelji,
  ali je funkcionalno izdvojen zbog ručnih poslovnih pravila
- `delta_ops` i `izlaz_tok` nisu dobar kandidat za isti prvi refaktorski
  rez

---

## E) Procjena rizika konsolidacije

### E1) Opća procjena rizika

`RIZIK_KONSOLIDACIJE = SREDNJI`

Konsolidacija nije visokog rizika jer je zajednička jezgra stvarno jaka,
ali nije ni niskog rizika jer cijela skupina nije potpuno homogena.

### E2) Glavni rizik

Glavni rizik nije u 5 schema-driven validatora,
nego u tome da se prerano pokuša u isti generički kalup ugurati i:

- `validiraj_audit_generated_v1.ps1`
- `validiraj_delta_ops.ps1`
- `validiraj_izlaz_tok_pn_prigovor_v1.ps1`

Ta tri člana imaju drukčiji tip validacije:

- ručna poslovna pravila
- Python `jsonschema` most
- provjera tekstualnog izlaza

Ako bi se sve spojilo odjednom,
porasla bi složenost generičkog alata i smanjila bi se čitljivost grešaka.

### E3) Što mora biti dokazano prije refaktora

Prije bilo kakvog refaktora mora ostati dokazano:

- da target path logika ostaje identična
- da `NEMA_DATOTEKA=1` i dalje daje `exit 0` gdje je to sada pravilo
- da se zadrže isti `VALIDATOR_*_EXIT` markeri za `ci_smoke.ps1`
- da greške i enum provjere ostanu determinističke
- da `ci_smoke.ps1` i dalje prolazi bez promjene ponašanja validacije

### E4) Ima li smisla jedan generički validator

Da, ali **ne za cijelu proširenu obitelj odjednom**.

Najviše smisla ima prvi rez u ovom obliku:

- izdvojiti jednu generičku jezgru za schema-driven validatore
- tu jezgru parametrizirati s:
  - putanjom do sheme
  - ciljnom baznom mapom
  - filterom datoteka
  - konfiguracijom potrebnih polja i enum provjera
- postojeće skripte zadržati kao tanke wrapper ulaze

Time se dobiva sigurniji put:

- mala promjena ponašanja
- jasna reverzibilnost
- lakša provjera kroz postojeći CI i smoke

---

## F) Zaključak

`SKUPINA_JE_KANDIDAT_ZA_KONSOLIDACIJU`

Točno jedan sljedeći smisleni zadatak:

- u zasebnom scoped koraku uvesti generičku jezgru za 5 schema-driven
  validatora (`audit_v1`, `intake`, `postupak`, `predlozak`,
  `subsumcija`), zadržati postojeće nazive kao tanke wrapper ulaze i
  obavezno ažurirati `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`
