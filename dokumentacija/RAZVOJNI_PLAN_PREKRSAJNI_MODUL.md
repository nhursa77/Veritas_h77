# RAZVOJNI PLAN PREKRSAJNI MODUL (v1)

Datum izrade: 20.02.2026.
Datum revizije: 23.02.2026.
Status: kanonski

---

## Razvoj prekršajnog modula — FAZE i točni koraci

## Stanje implementacije (23.02.2026.)

Implementirano:

- P2 (Postupci v1) dovršeno za 4 toka: TOK_PN_PRIGOVOR,
   TOK_PRESUDA_ZALBA, TOK_RJESENJE_ZALBA, TOK_OBUSTAVA.
- `alati/run_tok_v1.ps1` radi kao generički runner za sva 4 toka.
- `alati/ci_smoke.ps1` izvršava run tokovi v1 i validacijske gate korake.
- INTAKE je uveden kroz standard + shemu + validator
   (`STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`,
   `SCHEMA_INTAKE_PREKRSAJI_V1.json`, `validiraj_intake_prekrsaji_v1.ps1`).
- Predlošci v1 postoje za prigovor i žalbu
   (`prigovor_pn` i `zalba_presuda_ili_rjesenje`).
- Standard fer naplate i audit mapiranja su uvedeni i povezani s
   izlaznim nacrtom/validacijom.
- P6 acceptance v1 uveden: generator `audit_generated_v1.json` radi s
   NAP-MIN klasama, semaforom CRVENO/ŽUTO/ZELENO i G1 soft pravilom.
- P6 fixtures acceptance uveden: kanonski skup CRV/ŽUT/ZEL scenarija
   provjerava očekivani semafor i ključne NAP kodove u CI smoke pipelineu.
- Fixtures set je dopunjen scenarijem za `g1.status=INDETERMINATE`
   (soft warning), s očekivanim `preflight=ZUTO` i usklađenim NAP kodom.
- Fixtures kanon je stabiliziran: `expected.g1.status` i
   `expected.nap.must_include/must_not_include` su preferirani format,
   dok su `required_nap/forbidden_nap` označeni kao legacy (deprecirano).
- P6 G1 rokovi usklađeni kao strojno pravilo (soft): kanonska formula
   (`start + 8 kalendarskih dana`), statusi
   `OK|MISSING|LATE|INDETERMINATE`, `g1.*` izlazni blok i validator provjera
   opcionalne G1 strukture.

Sljedeće po redu:

- P7 — proširenje fixture matrice i E2E veze
   (`audit_generated_v1.json` -> izlazni nacrt -> manifest).

Backlog fixtures popune (prioritet nakon kanona):

- ZADATAK 38: DOVRŠENO
   (`TOK_PRESUDA_ZALBA` CRVENO/blocker zatvoren scenarijem 12).
- ZADATAK 39: DOVRŠENO
   (`TOK_PN_PRIGOVOR` + `G1_STATUS=LATE` zatvoren scenarijem 13).
- ZADATAK 40: DOVRŠENO (prva R3 praznina)
   (`TOK_RJESENJE_ZALBA` + `G1_STATUS=MISSING` zatvoren scenarijem 14).
- ZADATAK 41: DOVRŠENO (druga R3 praznina)
   (`TOK_OBUSTAVA` + `G1_STATUS=MISSING` zatvoren scenarijem 15).
- ZADATAK 42: DOVRŠENO (treća R3 praznina)
   (`TOK_PRESUDA_ZALBA` + `G1_STATUS=MISSING` zatvoren scenarijem 16).
- ZADATAK 43: DOVRŠENO (prva R4 sanitarna pokrivenost)
   (`TOK_PN_PRIGOVOR` + `G1_STATUS=OK` zatvoren scenarijem 17).

## Definicije statusa (vrijedi u svim fazama)

- PROLAZ: svi obavezni artefakti postoje + prolaze validacije/gate.
- NEPROLAZ: nedostaje artefakt, krši shemu, ili gate blokira.
- N/A: modul se ne primjenjuje (npr. nema dostavnice pa se modul
  dostave označi N/A uz razlog).

---

## FAZA P0 — Kanon i “šine” (dokumentacija)

Cilj: prekršajni modul definiran kao kanon (da Copilot ne interpretira).

Koraci:

1) README s kanonskom specifikacijom (struktura + M0–M9 + gate)
   — završeno.
2) DNEVNIK: upis o kanonskoj specifikaciji — završeno.
3) MAPA_DOKUMENTACIJE: dodati prekršajni modul kao “pilot domena”
   (linkovi).
4) TEHNIČKI_OKVIR: dodati sekciju “Prekršajni modul” s:
   - fizičke putanje,
   - WORM audit,
   - vanjski izlaz gate.

Ulaz: docx specifikacija + postojeća dokumentacija.
Izlaz: dopunjena dokumentacija.
Gate: lint_markdown.ps1 PROLAZ + commit clean.

---

## FAZA P1 — Skeleton struktura (mape)

Cilj: fizički scaffolding tokova, predložaka i predmeta postoji u repou.

Koraci:

1) Kreirati mape tokova TOK_* pod
   `postupci/sud/prekrsajni/.../v1`.
2) Kreirati mape predložaka pod
   `predlosci/sud/prekrsajni/.../v1`.
3) Kreirati jedan ogledni predmet:
   `predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/{dokazi,audit,izlazi}`.
4) Dodati .gitkeep u svaku novu mapu (git tracking).

Ulaz: README definicija putanja.
Izlaz: mape + .gitkeep.
Gate: repo clean nakon commita + ci_smoke.ps1 PROLAZ.

---

## FAZA P2 — Postupci v1 (metadata i koraci bez prava)

Status: DOVRŠENO (4 toka u v1).

Cilj: svaki tok ima minimalan postupak.json i minimalne korake po
STANDARD_JSON_POSTUPAK, ali još bez “pravnog sadržaja”.

Koraci (za svaki TOK_*):

1) Izraditi postupak.json (meta):
   - naziv,
   - verzija,
   - opis,
   - ulazni tip akta (PN/presuda/rješenje/obustava),
   - očekivani izlazi (audit/nacrt),
   - gateovi.
2) Izraditi minimalne korake korak_001...korak_00N (stub):
   - K0 učitaj predmet i dokaze
   - K1 odaberi modul M0–M9 (redoslijed fiksan)
   - K2 validacije ulaza (dokazi, datumi)
   - K3 generiraj audit skeleton
   - K4 generiraj “nalaz nepravilnosti” stub (ako fail)
   - K5 generiraj nacrt stub (ako prolaz)

Ulaz: STANDARD_JSON_POSTUPAK.
Ulaz: RAZVOJNI_PLAN_VERITAS_H77.
Izlaz: JSON postupci + koraci.
Gate: validacija JSON-a (schema) + ci_smoke.ps1.

---

## FAZA P3 — Standardi koji nedostaju
## (AUDIT/SUBSUMPCIJA/HIJERARHIJA/PREDLOŽAK)

Cilj: formalizirati ono što docx traži kao kanonske standarde.

Koraci:

1) Dodati u dokumentacija/:
   - STANDARD_JSON_AUDIT_PRIMJENE.md
   - STANDARD_JSON_SUBSUMPCIJA.md
   - STANDARD_JSON_HIJERARHIJA.md
   - STANDARD_JSON_PREDLOZAK.md
2) U MAPA_DOKUMENTACIJE dodati redoslijed čitanja.
3) U RJEČNIK_POJMOVA dodati ključne pojmove:
   audit, subsumcija, matrica pogrešaka, PROLAZ/NEPROLAZ/N/A, WORM.

Ulaz: docx + postojeći standardi NORMA/POSTUPAK.
Ulaz: PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.
Izlaz: novi standardi.
Gate: lint + deterministički format + commit.

---

## FAZA P4 — Sheme i validatori (gate na JSON artefakte)

Cilj: sve što modul proizvodi mora biti strojno provjerljivo.

Koraci:

1) Uvesti JSON sheme (gdje god već držiš sheme u repo;
   ako nema mape, napraviti `alati/sheme/`):
   - SCHEMA_AUDIT.json
   - SCHEMA_PREDLOZAK.json
   - SCHEMA_SUBSUMPCIJA.json (ili kao dio audita)
2) Dodati alate:
   - alati/validiraj_audit.ps1
   - alati/validiraj_predloske.ps1
   - alati/validiraj_subsumciju.ps1
3) Ugraditi u ci_smoke.ps1 nove gate korake:
   schema validation za gore navedeno.

Ulaz: standardi iz P3.
Izlaz: sheme + validatori + CI gate.
Gate: ci_smoke.ps1 PROLAZ.

---

## FAZA P5 — Predlošci v1 (realni, ali minimalni)

Cilj: imati formalne predloške koji se pune iz AUDIT zapisa.

Koraci:

1) `predlosci/sud/prekrsajni/prigovor_pn/v1/predlozak.json`
2) `predlosci/sud/prekrsajni/zalba_presuda_ili_rjesenje/v1/predlozak.json`
3) Validirati predloške shemom (P4).

Ulaz: STANDARD_JSON_PREDLOZAK.
Izlaz: predlošci v1.
Gate: validiraj_predloske.ps1 PROLAZ.

---

## FAZA P6 — Audit engine v1 (M0–M9 kao podaci, ne “AI priča”)

Status: U TIJEKU (acceptance v1 uveden za NAP-MIN + semafor + G1 soft).

Cilj: generirati audit_v1.json iz predmeta deterministički.

Koraci:

1) Definirati strukturu audit_v1.json:
   - modul_results: M0–M9 status + razlog
   - findings: lista grešaka s kodom, normom, težinom, posljedicom
   - deadlines: rokovi i izračun
   - remedy: preporučeni lijek
2) Implementirati generator audita (Python alat ili dio offline agent-a):
   - ulaz: predmet.json + dokazi + norme (NORMA JSON) + postupak
   - izlaz: audit_v1.json
3) Dodati WORM pravilo: ne prepisivati, nego audit_v2.json itd.

Ulaz: P2 postupci + P3/P4 standardi/sheme.
Izlaz: audit datoteke u predmetu.
Gate: validiraj_audit.ps1 PROLAZ.

---

## FAZA P7 — Generator nacrta v1 (predložak + audit)

Status: U TIJEKU (P6 + fixtures acceptance pripremljen za E2E proširenje).

Cilj: iz predlozak.json + audit_v1.json generirati nacrt.

Koraci:

1) Implementirati generator:
   - ulaz: predložak + audit + metadata predmeta
   - izlaz: izlazi/nacrt_v1.md (ili docx kasnije)
2) Ugraditi zabrane:
   - bez potpisa → “nacrt” watermark/oznaka
   - bez NN sidra → nema nacrta, samo nalaz

Ulaz: P5 + P6.
Izlaz: nacrt.
Gate: ci_smoke.ps1 + provjera da “blocked state” ne proizvodi nacrt.

---

## FAZA P8 — Predmet i lanac skrbništva (dokazni paket)

Cilj: predmet ima sve dokazne artefakte i hash/manifest.

Koraci:

1) lanac_skrbnistva.json generator:
   - tko/što/kad je dodano,
   - hash svakog dokaza
2) manifest.json generator:
   - popis svih artefakata (dokazi, audit, nacrt),
   - hashovi,
   - verzije
3) Gate: bez manifest+hash nema “spremno za potpis”.

Ulaz: predmet folder + dokazi.
Izlaz: chain-of-custody + manifest.
Gate: verifikator manifesta (skripta) PROLAZ.

---

## FAZA P9 — End-to-end pilot (jedan stvarni predmet)

Cilj: dokazati tok na jednom predmetu bez ručnog krpanja.

Koraci:

1) Unijeti predmet (dokazno) u predmeti/... s minimalnim dokazima.
2) Pokrenuti tok (odabir TOK_PN_PRIGOVOR ili drugi).
3) Generirati audit + nacrt + manifest.
4) Pregledati rupe i otvoriti “rupa izvještaj” ako nešto fali.

Ulaz: stvarni predmet.
Izlaz: kompletan paket spreman za ljudski potpis.
Gate: svi validatori + CI smoke PROLAZ.
