# MATRICA PROVEDBE NORMI AI SUSTAVA VERITAS H.77

Datum provjere: 18.07.2026.
Status: radna dokazna matrica
Opseg: poprečne interne norme sustava i njihova stvarna provedba u repou.

---

## 1) Pravilo čitanja matrice

Matrica razlikuje postojanje pravila od dokaza njegove provedbe.

Ocjene su:

- `SUKLADNO`: norma je u promatranom opsegu potpuno dokazana;
- `DJELOMIČNO`: postoji dio potrebnog normativnog i provedbenog lanca;
- `NESUKLADNO`: potvrđeno stanje proturječi normi;
- `NEDOVOLJNO_DOKAZA`: nema dovoljno podataka za pouzdan zaključak;
- `NIJE_PRIMJENJIVO`: postoji dokumentirano isključenje iz opsega.

Oznake dokaza `D0` do `D5` definirane su u dokumentu
`INVENTURA_NORMATIVNOG_OKVIRA_AI_SUSTAVA_VERITAS_H77.md`.

Ocjena vrijedi samo za navedeni opseg. Prolaz prekršajnog pilota ne dokazuje
prolaz drugih pravnih modula niti ukupnu pravnu sukladnost Veritasa.

---

## 2) Upravljanje i ljudska odluka

### UPR-001 — Čovjek je konačni donositelj odluke

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `AGENTS.md`, odjeljci 1., 2. i 6.;
  - `METODOLOGIJA_RADA_VERITAS_H77.md`, odjeljci 1., 2. i 3.
- Provedba: zabrana autonomnog pravnog djelovanja zapisana je u kanonu.
- Test: nije moguć potpuni automatski test stvarne ljudske odluke.
- Potreban ljudski dokaz: evidencija pregleda, odluke i potpisa za svaki
  vanjski izlaz.
- Razina: `D1`; za konkretni predmet potreban je `D5`.
- Ocjena: `DJELOMIČNO`.
- Praznina: ne postoji jedinstveni strojno čitljivi zapis ljudskog odobrenja.

### UPR-002 — AI radi samo unutar odobrenog opsega

- Snaga: `TVRDI_GATE`
- Kanonski zapis: `AGENTS.md`, odjeljci 3. i 4.
- Provedba: radni ciklus zahtijeva cilj, opseg, rizik, provjeru i odobrenje.
- Test: nema automatskog testa koji uspoređuje odobreni i stvarni opseg.
- Razina: `D1`.
- Ocjena: `DJELOMIČNO`.
- Praznina: odobreni paket nije zaseban strukturirani artefakt repozitorija.

### UPR-003 — Proturječje se ne razrješava prešutno

- Snaga: `OBVEZNO`
- Kanonski zapis: `AGENTS.md`, odjeljak 5.
- Provedba: obveza je dokumentirana.
- Test: nema validatora proturječnih kanonskih tvrdnji.
- Razina: `D1`.
- Ocjena: `DJELOMIČNO`.
- Dokazani primjer: uloga `zakon.hr` nije jednako određena u metodologiji i
  mapi dokumentacije.

---

## 3) Izvori prava i NN gate

### IZV-001 — Narodne novine su primarni dokazni izvor

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `METODOLOGIJA_RADA_VERITAS_H77.md`, odjeljak 5.;
  - `TEHNIČKI_OKVIR_VERITAS_H77.md`, odjeljak o izvorima;
  - `AGENTS.md`, odjeljak 6.
- Provedba:
  - `alati/run_tok_v1.ps1` provjerava postojanje NORMA reference;
  - isti alat zahtijeva `status_sidra = "puno"`;
  - `alati/acceptance_preflight.ps1` provjerava paket izvora.
- Pozitivni i negativni test:
  - `alati/test_run_tok_p7_v1.ps1`;
  - slučajevi bez sidra i s nevaljanim sidrom moraju stati bez izlaza.
- CI: `alati/ci_smoke.ps1` uključuje P7 test i preflight kada je omogućen.
- Razina: `D4` za prvi prekršajni tok.
- Ocjena: `SUKLADNO` za testirani tok; `NEDOVOLJNO_DOKAZA` za cijeli sustav.

### IZV-002 — Operativni tekst nastaje iz NN objava i svih izmjena

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`;
  - `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`;
  - režimi konverzije pojedinih zakona.
- Provedba: postoje alati za dohvat, parsiranje, normiranje i kontrolnu
  usporedbu.
- Test: ne postoji jedinstveni test koji za svaki aktivni zakon dokazuje
  cjelovit lanac izvornik–izmjene–operativni tekst–kontrolna usporedba.
- Razina: `D2` u dijelu zakonskih paketa.
- Ocjena: `DJELOMIČNO`.

### IZV-003 — `zakon.hr` je samo kontrolni izvor

- Snaga: `OBVEZNO`
- Kanonski zapis:
  - metodologija ga određuje kao opcionalni kontrolni izvor;
  - tehnički okvir, rječnik i mapa dokumentacije koriste istu podjelu.
- Provedba: `alati/validiraj_nn_vs_kontrolno.py` provodi usporedbu.
- Test: postoje pojedinačni kontrolni paketi, ali nema općeg testa zabrane
  uporabe `zakon.hr` kao jedinog dokaznog izvora.
- Razina: `D1` za kanonski zapis i `D2` za kontrolnu usporedbu.
- Ocjena: `DJELOMIČNO`.
- Zatvoreno proturječje: vlasnik je potvrdio, a dokumenti su 18.07.2026.
  usklađeni tako da je NN dokazni izvor, Veritasov izvedeni tekst operativni
  sloj, a `zakon.hr` kontrolni izvor.

---

## 4) Nacrt, potpis i vanjski izlaz

### IZL-001 — Svaki Veritasov dokument nastaje kao nacrt

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `METODOLOGIJA_RADA_VERITAS_H77.md`, odjeljak 3.;
  - `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`.
- Provedba:
  - generator i validator izlaza zahtijevaju markere nacrta;
  - P8 paket uključuje nacrt, audit, manifest i lanac skrbništva.
- Test:
  - `alati/test_run_tok_p7_v1.ps1`;
  - `alati/test_p8_manifest_lanac_v1.ps1`.
- CI: oba testa su uključena u `alati/ci_smoke.ps1`.
- Razina: `D4` za prekršajni tok.
- Ocjena: `SUKLADNO` za testirani tok; izvan njega `NEDOVOLJNO_DOKAZA`.

### IZL-002 — Bez sidra i ljudske odluke nema vanjskog izlaza

- Snaga: `TVRDI_GATE`
- Kanonski zapis: `AGENTS.md`, odjeljak 6.
- Provedba: P7 blokira izlaz bez punog sidra.
- Negativni test: P7 slučajevi blokiranog audita i nedostajućeg sidra.
- Ljudski dokaz: zasebna potvrda pregleda i odluke još nije normirana kao
  strukturirani artefakt.
- Razina: `D4` za sidro i `D1` za ljudsku odluku.
- Ocjena: `DJELOMIČNO`.

### IZL-003 — Veritas ne potpisuje i ne šalje samostalno

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `AGENTS.md`, odjeljci 3. i 6.;
  - `METODOLOGIJA_RADA_VERITAS_H77.md`, odjeljak 3.
- Provedba: u repozitoriju nije utvrđena aktivna funkcija autonomnog potpisa
  ili slanja u testiranom toku.
- Test: ne postoji opći negativni test mrežnog ili integracijskog slanja.
- Razina: `D1`.
- Ocjena: `DJELOMIČNO`.

---

## 5) Privatnost i lokalni predmeti

### PRI-001 — Stvarni predmeti ostaju lokalni i izvan Gita

- Snaga: `TVRDI_GATE`
- Kanonski zapis:
  - `AGENTS.md`, odjeljak 7.;
  - `STANDARD_JSON_PREDMET_I_PRIVATNOST_PREKRSAJI_V1.md`.
- Provedba:
  - `alati/privatnost_predmeta_core.ps1`;
  - `alati/validiraj_predmet_prekrsaji_v1.ps1`;
  - `alati/provjeri_privatnost_repozitorija_v1.ps1`;
  - `.githooks/pre-commit`.
- Pozitivni i negativni test:
  - `alati/test_p9_privatnost_v1.ps1`;
  - `alati/test_p9_lokalni_e2e_v1.ps1`.
- CI: privatnosni gate i oba testa dio su `alati/ci_smoke.ps1`.
- Razina: `D4` za prekršajni model predmeta.
- Ocjena: `SUKLADNO` u testiranom opsegu.
- Vanjska praznina: još nema potpune GDPR evidencije svrha, pravnih osnova,
  rokova čuvanja, primatelja, izvršitelja obrade i prijenosa.

---

## 6) Podatkovni ugovori i validacija

### POD-001 — Aktivni JSON artefakt odgovara svojoj shemi

- Snaga: `TVRDI_GATE`
- Kanonski zapis: specijalizirani `STANDARD_JSON_*` dokumenti i devet shema
  u `dokumentacija/sheme/`.
- Provedba: `alati/validiraj_json_po_shemi_v1.ps1` i specijalizirani
  validatori.
- CI: aktivne sheme prekršajnog toka provjeravaju se u `alati/ci_smoke.ps1`.
- Dokazani nedostatak:
  - osam od devet korijenskih shema nema `additionalProperties: false`;
  - generički validator ne provodi ključnu riječ `additionalProperties`.
- Razina: `D4` za podržani podskup pravila sheme, ne za cijeli JSON Schema
  Draft 2020-12.
- Ocjena: `DJELOMIČNO`.

### POD-002 — Nedeklarirana polja ne ulaze u kanonske artefakte

- Snaga: još nije jednoznačno propisana za sve artefakte.
- Kanonski zapis: samo `SCHEMA_DELTA_OPS.json` zatvara dodatna polja na
  korijenu.
- Provedba: specijalizirani delta validator provodi zabranu.
- Razina: `D4` za delta operacije i `D0` ili `D1` za ostale artefakte.
- Ocjena: `NEDOVOLJNO_DOKAZA` za cijeli sustav.
- Potrebna odluka: odrediti koji ugovori moraju biti zatvoreni, a koji smiju
  imati kontrolirana proširenja.

---

## 7) Audit, integritet i sljedivost

### TRA-001 — Izlaz ima audit, manifest i provjerljiv lanac skrbništva

- Snaga: `TVRDI_GATE` za P8 prekršajnog toka.
- Kanonski zapis:
  - `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`;
  - `STANDARD_MANIFEST_I_LANAC_SKRBNISTVA_PREKRSAJI_V1.md`.
- Provedba:
  - `alati/generiraj_audit_prekrsaji_v1.ps1`;
  - `alati/generiraj_p8_manifest_i_lanac_v1.ps1`;
  - `alati/validiraj_p8_manifest_i_lanac_v1.ps1`.
- Test: P6 fixturei, P7 test, P8 test i P9 lokalni E2E.
- CI: provedba je uključena u `alati/ci_smoke.ps1`.
- Razina: `D4` za prvi prekršajni tok.
- Ocjena: `SUKLADNO` za testirani tok; izvan njega `NEDOVOLJNO_DOKAZA`.

### TRA-002 — Dnevnik rada je append-only

- Snaga: `OBVEZNO`
- Kanonski zapis:
  - `AGENTS.md`, odjeljak 10.;
  - `STANDARD_ZASTITA_DNEVNIKA_RADA.md`.
- Provedba: kanonski alati za dodavanje i zatvaranje dokumentacijskog koraka.
- Test: postoji provjera načina izmjene, ali nije dokazana potpuna zaštita od
  svih izravnih promjena povijesnog sadržaja.
- Razina: `D2`.
- Ocjena: `DJELOMIČNO`.

---

## 8) Jezik i dokumentacija

### JEZ-001 — Projektni jezik je standardni hrvatski

- Snaga: `OBVEZNO`
- Kanonski zapis:
  - `AGENTS.md`, odjeljak 10.;
  - `METODOLOGIJA_RADA_VERITAS_H77.md`, odjeljak 12.
- Provedba: nema automatskog terminološkog ili jezičnog validatora.
- Test: ne postoji negativni test miješanja hrvatskog, srpskog ili slovenskog
  izraza u normativnom izlazu.
- Razina: `D1`.
- Ocjena: `DJELOMIČNO`.

### DOC-001 — Markdown dokumentacija prolazi kanonska pravila

- Snaga: `OBVEZNO`
- Kanonski zapis:
  - `AGENTS.md`, odjeljak 10.;
  - `STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`;
  - `.markdownlint.json`.
- Provedba: `alati/lint_markdown.py` i `alati/provjeri_markdown_scope.ps1`.
- CI: Markdown lint je obvezni korak `alati/ci_smoke.ps1`.
- Razina: `D4` za pravila uključena u konfiguraciju i scoped provjeru.
- Ocjena: `SUKLADNO` za uključena pravila.
- Praznina: normativni popis svih Markdown pravila nije jedinstveno povezan s
  oba provedbena mehanizma.

---

## 9) Git i upravljanje paketom

### GIT-001 — Jedan aktivni paket, zasebna grana i provjereni commitovi

- Snaga: `OBVEZNO`
- Kanonski zapis: `AGENTS.md`, odjeljci 3., 4. i 5.
- Provedba: radni postupak je ljudski i agentski vođen.
- Test: CI provjerava da vlastito pokretanje nije promijenilo radno stablo.
- Razina: `D1`, uz pojedinačni `D4` za higijenu CI izvršavanja.
- Ocjena: `DJELOMIČNO`.

### GIT-002 — Spajanje u `main` zahtijeva zasebno odobrenje

- Snaga: `TVRDI_GATE`
- Kanonski zapis: `AGENTS.md`, odjeljci 3. i 4.
- Provedba: proceduralna odluka vlasnika; GitHub zaštita grane nije dokazana.
- Razina: `D1` i ljudski dokaz za svaki PR.
- Ocjena: `DJELOMIČNO`.

---

## 10) Vanjski propisi i životni ciklus

### REG-001 — Svaki primjenjivi propis ima aktualni dokazni paket

- Snaga: budući `TVRDI_GATE`.
- Kanonski zapis:
  - `INVENTURA_NORMATIVNOG_OKVIRA_AI_SUSTAVA_VERITAS_H77.md`;
  - kanonski obrazac za zakone s amandmanima.
- Provedba: postoji obrazac za pojedinačne zakone, ali nema potpunog registra
  svih propisa koji uređuju sam AI sustav.
- Razina: `D1`.
- Ocjena: `DJELOMIČNO`.

### REG-002 — Promjena propisa pokreće ponovnu procjenu sukladnosti

- Snaga: kandidat za `TVRDI_GATE`; još nije kanonski određena.
- Provedba: ne postoji jedinstveni periodični ili događajni mehanizam.
- Razina: `D0`.
- Ocjena: `NEDOVOLJNO_DOKAZA` dok vlasnik ne potvrdi normu i intervale.

### REG-003 — Uloga prema Aktu o umjetnoj inteligenciji je dokumentirana

- Snaga: `TVRDI_GATE` prije stavljanja sustava u uporabu ili na tržište.
- Provedba: nije utvrđeno djeluje li vlasnik u konkretnoj uporabi kao
  pružatelj, subjekt koji uvodi sustav ili druga propisana uloga.
- Razina: `D0`.
- Ocjena: `NEDOVOLJNO_DOKAZA`.

### REG-004 — Osobe koje rade sa sustavom imaju dokazivu AI pismenost

- Snaga: `OBVEZNO` prema članku 4. Uredbe (EU) 2024/1689 kada se primjenjuje.
- Provedba: projekt ima radne upute, ali nema evidenciju potrebnih znanja,
  osposobljavanja i provjere u odnosu na kontekst uporabe.
- Razina: `D0` za formalni dokaz AI pismenosti.
- Ocjena: `DJELOMIČNO`.

---

## 11) Sažeta početna ocjena

Najjače dokazani dijelovi trenutačno su:

- privatnosna karantena stvarnih prekršajnih predmeta;
- NN sidro u prvom prekršajnom toku;
- audit, nacrt, manifest i lanac skrbništva P6–P9;
- tehnička pravila Markdown dokumentacije.

Najvažnije otvorene praznine su:

- jedinstvena hijerarhija normativnih artefakata;
- registar svih primjenjivih vanjskih propisa i njihovih izmjena;
- pravna uloga Veritasa prema Aktu o umjetnoj inteligenciji;
- potpuna GDPR dokumentacija i evidencija obrade;
- formalni dokaz ljudske odluke prije vanjskog izlaza;
- zatvorenost podatkovnih ugovora i puna podrška JSON Schema pravilima;
- jezična i terminološka kontrola;
- kibernetički model prijetnji, incidenti i životni ciklus ranjivosti;
- autorskopravni režim izvora i rudarenja teksta i podataka;
- pravila tržišta, potrošača i pružanja pravne pomoći, ako se aktiviraju.

Ukupna početna ocjena ostaje:

`DJELOMIČNO SUKLADNO / NEDOVOLJNO DOKAZA ZA UKUPNU SUKLADNOST`.

Ta ocjena ne dopušta predstavljanje Veritasa kao potpuno pravno ili
regulatorno usklađenog sustava.
