# DNEVNIK_RADA

## Pravilo evidentiranja
Svaki novi značajan korak rada evidentira se kao novi dnevnički unos.
Unosi idu kronološki: najstariji na vrhu, najnoviji na dnu.

---

## Datum: 16.02.2026

### Sažetak (17.02.2026.)
Napravljen je inicijalni setup repozitorija i postavljeni su temeljni kanonski
artefakti projekta. Uvedeni su tehnički standardi, osnovna struktura i ključni
kanonski dokumenti za metodologiju, normu, postupak i razvojni plan.

### Commitovi (najstariji -> najnoviji) (17.02.2026.)
- 39a19c8 -> chore: inicijalizacija repozitorija
- 275aa3b -> chore: normalizacija završetaka redaka
- 7b3b1f2 -> chore: dodana osnovna struktura mapa
- f4033dc -> chore: docker kostur (mount repozitorija)
- 24e9959 -> chore: markdownlint pravila + editorconfig
- 0ea5b66 -> chore: eol pravila (LF kanon, CRLF samo ps1)
- dafaa25 -> docs: metodologija rada Veritas H.77
- cd613a1 -> docs: standard JSON NORMA (revizija 1)
- 27dcda5 -> docs: standard JSON NORMA (revizija 2)
- 502501c -> docs: standard JSON POSTUPAK (procedura)
- 0681c60 -> docs: razvojni plan Veritas H.77 (kanonski)

### Napomena (17.02.2026.)
Standard JSON NORMA je u povijesti uveden kroz dvije uzastopne revizije
(dva odvojena commita). Obje revizije su kanonske u smislu traga, a važeći
sadržaj je onaj iz zadnje verzije datoteke u grani `main`.

### Status
Repozitorij čist: da (`git status --short` bez izlaza).

---

## Datum: 17.02.2026 (rječnik i tehnički okvir)

### Sažetak (rječnik i tehnički okvir)
Dopunjena je metodologija s rječnikom i gate pravilima statusa izlaza.
Dodan je zaseban rječnik pojmova, tehnički okvir i mapa dokumentacije.

### Commitovi (najstariji -> najnoviji) (rječnik i tehnički okvir)
- 1409d45 -> docs: metodologija (rječnik + gate pravila)
- 939d29b -> docs: rječnik pojmova Veritas H.77
- 6d724c2 -> docs: tehnički okvir Veritas H.77
- 978caee -> docs: mapa dokumentacije Veritas H.77

### Napomena (rječnik i tehnički okvir)
Za datum 17.02.2026. u povijesti repozitorija postoje ova četiri commita.

---

## Datum: 17.02.2026 (NN ingest i parsiranje)

### Sažetak (NN ingest i parsiranje)
Uveden je primarni ingest iz Narodnih novina za sve akte.
Uvedena je kontrola izvora sa statusima OK/NEDOSTAJE/HASH_NEDOSTAJE/
NEVALJAN_IZVOR.
Uvedeno je parsiranje NN HTML izvora u strukturu (`struktura_nn.json`) uz
izvještaj parsiranja.

### Napomena (NN ingest i parsiranje)
zakon.hr je opcionalna kontrola i usporedba, ali nije dokazni temelj.

### Commitovi (najstariji -> najnoviji) (NN ingest i parsiranje)
- 1409d45 -> docs: metodologija (rječnik + gate pravila)
- 939d29b -> docs: rječnik pojmova Veritas H.77
- 6d724c2 -> docs: tehnički okvir Veritas H.77
- 978caee -> docs: mapa dokumentacije Veritas H.77
- 94f5609 -> docs: dnevnik rada (unos 17.02.2026.)
- 2f8ecb2 -> docs: razvojni plan (validacija ranije + pilot + gate)
- f724285 -> chore: baza_zakona struktura (NORMA JSON)
- c066382 -> feat: pilot NORMA JSON (Ustav RH čl. 1) + NN sidro
- ca56955 -> feat: NORMA v1 schema + validacija
- d554f33 -> docs: standard rizik i kolizije
- b858a54 -> feat: pilot NORMA JSON (Ustav RH čl. 2-3) + dopuna sidra
- 964063b -> feat: pilot NORMA JSON (Ustav RH čl. 1-3) kanonski
- 540ade6 -> feat: operativni izvor (zakon.hr) ustav RH
- bb21e6e -> feat: parsiranje izvora (zakon.hr) ustav RH u strukturu
- 99beeb6 -> feat: normiranje (NORMA JSON) ustav RH iz strukture
- 1d1d771 -> feat: validacija NORMA JSON (ustav RH) - gate provjera
- 7e97759 -> fix: uskladena provjera hash polja u validaciji norme
- 1ccc527 -> feat: izvještaj rupa teksta (ustav RH) - za dopunu iz NN
- c3b6d46 -> feat: rupe teksta (ustav RH) - nedostajuci + placeholder +
 prazno
- 3a5a0af -> feat: primarni ingest izvor = Narodne novine (opći okvir +
 kontrola arhive)
- af79517 -> fix: kontrola NN izvora (nevaljan URL + validacija meta)
- 38d490b -> feat: parsiranje NN (HTML) u strukturu (generički)

---

## Datum: 18.02.2026

### Sažetak
Implementiran je Normiratelj iz NN strukture u NORMA JSON.
Pokrenut je pilot za `ustav_rh` preko PS runnera iz repo roota.
Generirani su članci `clanak_XXXX.json` i `IZVJESTAJ_NORMIRANJA.md`.

### Napomena
Ulaz je `struktura_nn.json` uz `meta.json` iz NN arhive kao dokazni izvor.

### Sanity-check normi (OUT vs IN)
Pokrenut je deterministički sanity-check nakon normiranja za `ustav_rh`.
Kriterij je bio: `len(out) < 50` i `len(in) > 200`.
Rezultat: `BAD_COUNT = 0`.

### Parser — rimska oznaka glave
Parser odvaja rimsku oznaku glave iz retka `Članak <broj> <RIMSKI>.`.
Rimska oznaka se sprema odvojeno (`glava_rimski`) i ne ulazi u broj članka.
Time se sprječava lažni missing članak 11.

### Parser — korekcija anomalije `Članak 1 I.` (ustav_rh)
Dodana je specifična korekcija samo za `ustav_rh`:
ako je redoslijed `10, 1(I), 12` i tekst sadrži ključne oznake
grba/zastave/himne,
`1(I)` se mapira na članak `11` uz oznaku `ANOMALIJA_C1I_TO_C11`.

### Kontrolni izvor `zakon.hr` (ustav_rh)
Dodan je kontrolni izvor u `izvori/kontrolno/zakon_hr/ustav_rh/`:
`ustav_rh_kontrolni.txt` (UTF-8, plain text) i `meta.json` s URL-om i vremenom
preuzimanja.

### Validator NN vs kontrolni izvor (ustav_rh)
Dodan je alat `alati/validiraj_nn_vs_kontrolno.py` koji uspoređuje
`struktura_nn.json` s `ustav_rh_kontrolni.txt` i generira
`IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.

### Validator report — proširenje lista i anomaly hints
Validator sada eksplicitno ispisuje `MISSING_LIST`, `EXTRA_LIST`,
`SHORT_LIST_FIRST20/COUNT` na stdout i u report dodaje sekcije
"Missing in NN", "Extra in NN", "Short texts in NN" i "Anomaly hints".

### Fix kontrolnog extractor-a (`Članak <N>`)
Extractor za `ustav_rh_kontrolni.txt` je pooštren da hvata samo stvarne
headere `Članak <N>` na početku retka; dodan je debug output
`CONTROL_HEADERS_COUNT`, `CONTROL_FIRST20_HEADERS` i `CONTROL_HAS_10/11/12`.

### Fix: header-only + sanitizacija `I35 -> 135`
Kontrolni parser sada parsira isključivo linije `Članak N.` te sanitizira
tipfelere `I/l` kao `1`; uklonjeni su fantomski brojevi i u anomaly hints je
dodan `FOUND_TYPO_HEADERS` (npr. `Članak I35 -> 135`).

### NN parser typo fix `I35 -> 135` (ustav_rh)
NN parser sada normalizira tipfelere broja članka `I/l -> 1` u headeru,
regenerirana je `struktura_nn.json` i NORMA izlaz, te je kreiran
`baza_zakona/norme/ustav_rh_procisceni/clanak_0135.json`.

### Ustav RH — document split (pročišćeni vs amandmani)
U parseru i validatoru uvedeno je razdvajanje dokumenata:
`ustav_rh_procisceni` je odvojen od amandmanskih/promjenskih dokumenata.
Generiraju se novi izlazi:
`izvori/dokazno/narodne_novine/ustav_rh/struktura_nn_dokumenti.json`
te
`izvori/kontrolno/zakon_hr/ustav_rh/struktura_kontrolno_dokumenti.json`.
Validacija NN vs kontrolno sada uspoređuje samo `ustav_rh_procisceni`,
a report sadrži sekciju `Document split summary` i ispis
`CONTROL_DOCS_FOUND` / `NN_DOCS_FOUND`.

### Validator — zakon.hr cutoff marker + stabilniji header parsing
Uveden je cutoff marker za odvajanje pročišćenog teksta od amandmana u
`ustav_rh_kontrolni.txt`, a amandmanski dio je izbačen iz usporedbe.
Parser zaglavlja je stabiliziran (anchored `Članak <N>` + heuristika za
sumnjive truncirane headere), čime je uklonjen ghost efekt `12` umjesto `123`.

### Normiratelj — doc split ulaz i procisceni-only norme
Normiratelj za `ustav_rh` prebačen je na ulaz
`struktura_nn_dokumenti.json` i generira norme samo iz
`ustav_rh_procisceni`; amandmani su ignorirani u normama i evidentirani
u `IZVJESTAJ_NORMIRANJA.md` kroz sekciju "Document split (NN)".

### Ustav RH — NN 85/2010 kao operativni izvor (152 čl.)
Dodan je novi dokazni snapshot `ustav_rh_nn_85_2010` (NN 85/2010,
pročišćeni tekst) i iz njega je generiran operativni set od 152 normi.
Stari operativni set (142) je arhiviran u
`baza_zakona/arhiva/ustav_rh_nn_56_1990_1092_142/`.

### Diff 142 vs 152 — automatizirani izvještaj
Dodan je alat `alati/diff_ustav_rh_sets.py` koji uspoređuje arhivski set
142 s operativnim setom 152 i generira
`baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_DIFF_142_VS_152.md`.

### Ustav RH — source selection (procisceni-first) + selection report
`run_normiratelj_ustav_rh.ps1` sada deterministički bira izvor iz NN
kandidata prema pravilu: `input_exists`, `tip_teksta=procisceni`,
`preferenca`, `ocekivani_broj_clanaka`, `slug`.
Obavezno se generira
`izvori/dokazno/narodne_novine/USTAV_RH_SELECTION_REPORT.md` s rankingom.
Meta standard za `ustav_rh` izvore je dopunjen poljima:
`tip_teksta`, `ocekivani_broj_clanaka`, `preferenca`.

### Validator — sanity hook `SOURCE_SELECTION_MISMATCH`
Validator `alati/validiraj_nn_vs_kontrolno.py` sada koristi isti odabir
NN izvora i provodi sanity check: ako `NN_COUNT` odstupa od
`ocekivani_broj_clanaka` odabranog izvora, postavlja
`SOURCE_SELECTION_MISMATCH=True` i podiže anomaly signal.

### Ustav RH — pre-flight guardrail (hard fail)
U validator je uveden obavezni pre-flight check: run pada s `exit 2` ako
odabrani NN izvor nije `procisceni`, odnosno s `exit 3` ako
`NN_COUNT != ocekivani_broj_clanaka`. Dodana je skripta
`alati/acceptance_ustav_rh_preflight.ps1` za one-click acceptance na Windowsu.

### Generički runner/preflight po `-AktSlug`
Uvedeni su `alati/run_normiratelj.ps1` i `alati/acceptance_preflight.ps1`
kao generički entrypointi za sve akte; validator
`alati/validiraj_nn_vs_kontrolno.py` sada podržava `-AktSlug` i
standardizirani override expected count-a po aktu/globalno.

### PAKET_PREKRSAJNI_V1 — manifest + paketni acceptance
Dodan je `paketi/PAKET_PREKRSAJNI_V1.json` (core + vezani akti) i
`alati/acceptance_paket.ps1` za one-click paketni preflight preko
generičkog `-AktSlug` pipelinea.

### INGEST_PREKRSAJNI_ZAKON_V1 — snapshot + norme + preflight
Uveden je novi akt `prekrsajni_zakon` kao core član paketa
`PAKET_PREKRSAJNI_V1`.
Kreirani su dokazni snapshoti izvora (`prekrsajni_zakon` i
`prekrsajni_zakon_nn_107_2007`), parsirana NN struktura i generiran
operativni NORMA set za `prekrsajni_zakon`.
Dodani su kontrolni artefakti u `izvori/kontrolno/zakon_hr/prekrsajni_zakon/`
te je potvrđen prolaz `acceptance_preflight -AktSlug prekrsajni_zakon`.
Paketni run više ne faila na missing-source za core akt `prekrsajni_zakon`
(status paketa ostaje `11` zbog optional akta koji još nisu ingestani).

### NN_FALLBACK_PDF_INGEST — prekrsajni_zakon (bez zakon.hr bootstrapa)
Za `prekrsajni_zakon` uklonjen je bootstrap sadržaj i izvor je vraćen na
kanonski NN članak (`2007_10_107_3125.html`).
U parseru je uveden fallback: kada NN HTML vrati `Sadržaj je nedostupan`
ili nema markere članka, parser pokušava dohvatiti ELI PDF (`eli_pdf_url`),
izvući tekst i zapisati parsabilni pseudo-HTML/TXT u isti snapshot folder.
Dodan je guardrail `FOUND_MULTIPLE_ACTS_IN_PDF` koji završava parser s
`exit 12` ako segmentacija PDF-a nije sigurna.
`run_normiratelj.ps1 -AktSlug prekrsajni_zakon` i
`acceptance_preflight.ps1 -AktSlug prekrsajni_zakon` prolaze na NN izvoru,
bez operativnog oslanjanja na `zakon.hr`.

### PAKET_PREKRSAJNI_V1 — ingest core + amandmani (generički)
`PAKET_PREKRSAJNI_V1` je proširen na core + 6 amandmana:
`NN 39/2013`, `157/2013`, `110/2015`, `70/2017`, `118/2018`, `114/2022`.
Dodana je generička skripta `alati/ingest_paket.ps1` (bez per-zakon skripti)
koja po manifestu radi: dohvat NN izvora, parsiranje, normiranje i preflight.
`alati/acceptance_paket.ps1` usklađen je s kodovima izlaza:
`0` (sve OK), `20` (required fail), `21` (optional fail),
`22` (manifest invalid).
Acceptance rezultat za paket je deterministički:
core (`prekrsajni_zakon`) prolazi, optional amandmani trenutno padaju bez
kontrolnog TXT izvora pa paket završava s `exit 21` (bez crash-a).

### ELI issue PDF slicer + parser integracija (prekrsajni paket)
Dodana je skripta `alati/eli_issue_pdf_slicer.py` koja radi title-anchor
slicing cijelog NN issue PDF-a i izdvaja samo ciljano tijelo akta.
`alati/parsiraj_nn_html.py` je prebačen da PDF fallback ide preko slicera
(umjesto internog inline rezanja), uz hard-fail `exit 12` kada je
`pdf_title_anchor` nejednoznačan.
`alati/ingest_paket.ps1` je dopunjen da u source meta upisuje
`pdf_title_anchor` i generira kontrolni TXT iz NN parsiranog izlaza prije
normiranja/preflighta.
Manifest `paketi/PAKET_PREKRSAJNI_V1.json` je dopunjen `pdf_title_anchor`
poljem za svih 6 amandmana.

### Verifikacija nakon slicer integracije
Pilot za `prekrsajni_zakon_nn_114_2022` potvrđuje prolaz parser+normiranje.
Full `ingest_paket` prolazi na required core aktu, dok optional amandmani i
dalje deterministički padaju na preflight guardrailu (`tip_teksta=amandmani`),
pa paketni status ostaje `optional fail` (`exit 21`).

### Paket-aware preflight (core strict, amandmani strict-but-different)
`alati/acceptance_preflight.ps1` je proširen parametrima
`-ExpectedTipTeksta` i `-PaketMode` tako da guardrail radi po očekivanom tipu
akta iz manifesta.
Za core (`procisceni`) ponašanje ostaje kao prije.
Za amandmane (`amandmani`) preflight ne traži `procisceni`, nego striktno
traži `TIP_ACTUAL=amandmani` (tip mismatch ostaje `exit 2`),
zadržava expected-count mismatch `exit 3` kada je expected count zadan,
i dodaje minimalni content sanity (`NN_COUNT >= 1` i prisutan
`clanak_0001.json` ili barem jedan `clanak_*.json`).
`alati/ingest_paket.ps1` i `alati/acceptance_paket.ps1` sada prosljeđuju
očekivani tip po aktu (`tip_teksta`) i paketni summary prikazuje
`TIP_EXPECTED` vs `TIP_ACTUAL`.

---

## Datum: 19.02.2026

### VH77-PRAVILA-BAZE-001 — kanonska pravila spremanja + enforce
Uvedeno je striktno pravilo da `baza_zakona/norme/` sadrži samo operativne
setove sa sufiksom `_procisceni`, dok su NN/amandmanski setovi u `sidra`,
a snapshotovi u `arhiva/<akt_slug>/<source_set_slug>/`.

Dodan je alat `alati/enforce_baza_layout.ps1` koji detektira kršenja u
`norme/` (mape bez `_procisceni`) i deterministički ih premješta u
kanonsku arhivsku strukturu, uz audit ispis `MOVE: old -> new` i
`SUMMARY` broj premještaja.

Operativni alias lookup je generaliziran: zahtjev za slug bez sufiksa
automatski mapira na `<akt_slug>_procisceni`.

### KANONSKA_STRUKTURA_BAZE (norme/sidra/arhiva)
Normaliziran je layout `baza_zakona`:
- svi `*_nn_*` setovi premješteni su iz `baza_zakona/norme/` u
 `baza_zakona/sidra/`;
- `baza_zakona/norme/` ostaje isključivo operativni sloj;
- arhivni Ustav set `NN 56/1990` premješten je u verzionirani put
 `baza_zakona/arhiva/ustav_rh/nn_56_1990_1092_142/`.

Pravilo odabira izvora je učvršćeno:
- `sidra` su jedini NN izvor (core + amandmani);
- `norme` su operativna projekcija za rad;
- `zakon.hr` ostaje isključivo kontrolni/usporedni izvor.

### VH77-ARHIVA-001 — normalizacija arhivskog layouta
Uvedena je kanonska struktura arhive:
`baza_zakona/arhiva/<akt_slug>/<izvor_set_slug>/`.

Dodan je alat `alati/normalize_arhiva_layout.ps1` koji detektira
nekanonske putanje i premješta ih u kanonski oblik uz audit ispis
`MOVE: old -> new`.

Arhivski Ustav snapshot je normaliziran iz obrnutog layouta
`arhiva/nn_56_1990_1092_142/ustav_rh/` u
`arhiva/ustav_rh/nn_56_1990_1092_142/`.

### Windows CI smoke (preflight + paket)
Dodan je GitHub Actions workflow `.github/workflows/ci_smoke_windows.yml` za
minimalni Windows smoke CI (`windows-latest`, `pwsh`).
Workflow pokreće komande:
`acceptance_preflight -AktSlug ustav_rh`,
`acceptance_paket -PaketPath paketi/PAKET_PREKRSAJNI_V1.json` i
`acceptance_preflight -AktSlug prekrsajni_zakon`.

### CI-safe paket smoke bez bootstrap artefakata
Iz workflowa je uklonjeno runtime generiranje kontrolnih TXT datoteka.
`alati/acceptance_paket.ps1` sada tretira nedostajući kontrolni TXT za
OPTIONAL amandman kao `MISSING_CONTROL_TEXT` (soft optional fail), pa paketni
smoke ostaje `exit 0` dok god REQUIRED akti prolaze.

### Jedinstveni CI entrypoint (`ci_smoke.ps1`)
Dodan je `alati/ci_smoke.ps1` kao jedini ulaz za Windows smoke CI.
Skript pokreće preflight (`ustav_rh`), paket acceptance
(`PAKET_PREKRSAJNI_V1`) i preflight (`prekrsajni_zakon`), ispisuje
`CI_SMOKE_STEP`/`CI_SMOKE_EXIT` markere te provjerava da `git status`
ostane nepromijenjen nakon runa.

### P2.3 — hygiene fallback kad git nije dostupan
`alati/ci_smoke.ps1` sada detektira dostupnost `git` i ispisuje marker
`CI_SMOKE_GIT_AVAILABLE=True/False`.
Kad je `git` dostupan, hygiene ostaje obavezan (`CI_SMOKE_HYGIENE=ENFORCED`);
kad nije dostupan, hygiene check se preskače (`CI_SMOKE_HYGIENE=SKIP_NO_GIT`).

### P2.4 — pip cache u Windows CI smoke
U `.github/workflows/ci_smoke_windows.yml` dodan je `actions/setup-python`
`cache: pip` s dependency path-om za `requirements.txt` (i budući
`pyproject.toml`), uz brži i deterministički install ovisnosti.
Time se skraćuje runtime smoke workflowa bez promjene acceptance logike.

### P2.5 — normalizirani CI smoke markeri
`alati/ci_smoke.ps1` sada ima stabilne markere
`CI_SMOKE_BEGIN/END`, `CI_SMOKE_STEP_BEGIN/END` i završni `CI_SMOKE_EXIT`.
Dodani su i standardni runtime markeri (`CI_SMOKE_TIMESTAMP`,
`CI_SMOKE_PWSH_VERSION`) radi lakšeg grepanja CI logova.

### Delta control mode za amandmane u paket acceptanceu
`alati/acceptance_paket.ps1` sada za `tip_teksta=amandmani` koristi
`CONTROL_MODE=delta`: kontrola je zadovoljena ako postoji
`*_delta_ops.json` ili `*_kontrolni.txt`.
Ako nema nijednog od ta dva artefakta, optional akt dobiva soft razlog
`MISSING_DELTA_CONTROL` (umjesto `MISSING_CONTROL_TEXT`).

### ND-PREKR-DELTA-001 — ingest auto-generira `*_delta_ops.json`
Dodan je novi alat `alati/generiraj_delta_ops.py` koji iz
`struktura_nn_dokumenti.json` heuristički izdvaja delta operacije za
amandmanske tekstove i zapisuje stabilni izlaz:
`akt_slug`, `generated_utc`, `source_doc_id`, `ops[]` s
`op`, `target_article`, `ref_article`, `note`, `excerpt_hash`.

`alati/ingest_paket.ps1` je dopunjen tako da za akte s
`tip_teksta=amandmani` nakon parsiranja automatski poziva generator i
upisuje `izvori/kontrolno/zakon_hr/<akt_slug>/<akt_slug>_delta_ops.json`.
Time paket acceptance za optional amandmane više ne ovisi samo o
`*_kontrolni.txt`, nego dobiva stvarni delta-kontrolni artefakt.

### VERITAS_RJECNIK_PROCISCENI_001 — pojam „Pročišćeni tekst”
Rječnik pojmova je dopunjen pojmom „Pročišćeni tekst” s operativnom
definicijom za Veritas.
Uvedeno je pravilo korištenja: pročišćeni tekst je operativni set za
postupanje/analizu/proceduru, dok NN core + amandmani ostaju sidrišta/audit
sloj za dokazni trag i verifikaciju promjena.
Navedeno je i da se zakon.hr koristi samo za usporedbu/validaciju, ne kao
izvor istine (izvor istine je NN/ELI gdje je primjenjivo).

---

## Datum: 19.02.2026 (delta control kanon + UTF-8 stabilizacija)

### VH77-DELTA-CONTROL-001 — kanonski delta control artefakt
`acceptance_preflight.ps1` i `acceptance_paket.ps1` su usklađeni na
deterministički kanon za amandmane: delta kontrola se provjerava isključivo na
putanji
`izvori/kontrolno/zakon_hr/<akt_slug>/<akt_slug>_delta_ops.json`.
Za `CONTROL_MODE=delta` više nema fallback traženja po više lokacija;
`MISSING_DELTA_CONTROL` ostaje standardizirani razlog pada.

### VH77-DELTA-CONTROL-002 — generator minimalnog `*_delta_ops.json`
`alati/generiraj_delta_ops.py` je prebačen na ulaz iz
`baza_zakona/sidra/<amandman_slug>/clanak_*.json` i generira minimalni
kanonski JSON:
`akt_slug`, `control_mode=delta`, `source`, `affected_articles`, `ops=[]`,
`notes`.
`alati/ingest_paket.ps1` je dopunjen da za `tip_teksta=amandmani` poziva
generator nakon normiranja sidra seta i zapisuje artefakt u kanonski
`izvori/kontrolno/zakon_hr/<akt_slug>/` folder.

### VH77-ENCODING-001 — UTF-8 izlaz na PS5.1
U `acceptance_preflight.ps1`, `acceptance_paket.ps1` i `ci_smoke.ps1`
postavljen je UTF-8 runtime (`chcp 65001`, `Console.OutputEncoding`,
`$OutputEncoding`) kako bi logovi ostali čitki i bez mojibake u porukama
tipa "preskoćen".

---

## Datum: 19.02.2026 (baza postupaka vs postupci)

### VERITAS-DOCS-PUTANJE-POSTUPCI — razjašnjenje koncepta i putanje
Usklađena je dokumentacija da se jasno razlikuje logički naziv od fizičke
putanje:
- logički naziv ostaje "baza postupaka" kao dokumentacijski koncept;
- trenutačna fizička putanja proceduralnih sadržaja je `postupci/`;
- `baza_postupaka/` ostaje planirana migracija (TODO) i ne tretira se kao
  postojeća putanja dok se ne napravi zaseban commit.

`dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` i `README.md` su usklađeni s
tim pravilom kako bi se uklonila dvosmislenost u kanonskim putanjama.

---

## Datum: 19.02.2026 (delta_ops JSON shema)

### VERITAS-DELTAOPS-SCHEMA-001 — kanonska shema
Dodana je kanonska JSON shema za `*_delta_ops.json` na putanji
`dokumentacija/sheme/SCHEMA_DELTA_OPS.json`.

Shema definira:
- root objekt,
- obavezno polje `ops` (array),
- `ops[]` objekt s obaveznim `op` (string),
- opcionalni `meta` objekt za buduće proširenje,
- `additionalProperties: false` na rootu i na `ops[]` objektu.

U `dokumentacija/STANDARD_JSON_POSTUPAK.md` dodana je kratka napomena gdje se
nalazi kanonska shema za delta kontrolne artefakte.

---

## Datum: 19.02.2026 (delta_ops shema gate)

### VERITAS-DELTAOPS-VALIDATOR-001 — validacija delta_ops po shemi
Dodan je alat `alati/validiraj_delta_ops.ps1` koji deterministički:
- pronalazi sve `*_delta_ops.json` pod `izvori/kontrolno/zakon_hr/**`,
- učitava kanonsku shemu `dokumentacija/sheme/SCHEMA_DELTA_OPS.json`,
- validira svaki artefakt preko Python `jsonschema` engine-a.

`alati/ci_smoke.ps1` je dopunjen korakom `validate_delta_ops_schema`.
Ako bilo koji `*_delta_ops.json` padne na shemi, run završava s non-zero
exit kodom (gate fail).

Smoke dokaz zatvaranja gate-a:
- `alati/ci_smoke.ps1` prolazi s `CI_SMOKE_EXIT=0`.
- korak `validate_delta_ops_schema` prolazi za sve postojeće
  `*_delta_ops.json` artefakte.

---

## Datum: 19.02.2026 (deterministički markdown lint gate)

### VERITAS-MD-LINT-RUNNER-001 — Python runner za MD hard gate
Dodan je deterministički lint runner:
- `alati/lint_markdown.py` (čita `.markdownlint.json`, provjerava `MD013`),
- `alati/lint_markdown.ps1` (PowerShell wrapper).

Runner lint-a ciljane markdown putanje:
`README.md`, `.github/copilot-instructions.md` i `dokumentacija/**/*.md`.
Ispisuje stabilne markere `MDLINT_BEGIN/END/EXIT=<code>` i točne
`datoteka:linija` prekršaje.

`alati/ci_smoke.ps1` je dopunjen korakom `lint_markdown`; pad markdown lint-a
zaustavlja smoke s non-zero exit kodom.

Runner je zatim prebačen u scoped mod:
- ciljne `.md` datoteke računa iz `git diff --cached --name-only`
  (ako postoje staged promjene), inače iz `git diff --name-only`;
- lint se izvršava samo nad tim popisom, pa gate ne pada na stare MD dugove
  izvan trenutnog opsega zadatka.

---

## Datum: 19.02.2026 (norme layout hard gate)

### VERITAS-NORME-GUARD-001 — zabrana non-`_procisceni` u norme
U `alati/acceptance_preflight.ps1` dodan je hard guard za
`baza_zakona/norme/`:
- dozvoljene su isključivo mape koje završavaju na `_procisceni`;
- ako postoji ijedan prekršitelj, preflight ispisuje
  `NORME_LAYOUT_OFFENDER` popis i pada s non-zero exit kodom.

Time je isti uvjet automatski propagiran i na `alati/ci_smoke.ps1`
jer smoke koristi `acceptance_preflight` kao ulazni gate.

### VERITAS-DELTAOPS-SOFT-STATUS-001 — standardni soft markeri
Za amandmanski preflight standardizirani su markeri kontrole delta artefakta:
- prisutno: `DELTA_OPS_CONTROL=OK`
- nedostaje (soft, bez faila):
  `DELTA_OPS_CONTROL=OPTIONAL_SOFT_MISSING_CONTROL`,
  `DELTA_OPS_MISSING: <putanja>`,
  `DELTA_OPS_HINT: generiraj_delta_ops.py`

U soft-missing stanju izlazni kod ostaje `0`, a signalizacija ostaje
stabilna i grep-friendly za CI/dnevnik.

### VERITAS-SIDRA-GUARD-001 — zabrana sidra bez NN obrasca
U `alati/acceptance_preflight.ps1` dodan je hard guard za
`baza_zakona/sidra/`:
- dozvoljene su samo mape koje sadrže obrazac `_nn_<broj>_<godina>`;
- ako postoji ijedan prekršitelj, preflight ispisuje
  `SIDRA_LAYOUT_OFFENDER` i pada s non-zero exit kodom.

Time je kanonski layout baze zatvoren s oba hard gate-a:
`norme` (`*_procisceni`) i `sidra` (`*_nn_<broj>_<godina>`).

### VERITAS-PRIMOPREDAJA-001 — paket stanja repozitorija
Dodana je datoteka
`dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md` kao
kanonski snapshot trenutačnog stanja repozitorija.

Dokument sadrži:
- datum i vrijeme,
- granu i HEAD commit,
- zadnjih 10 commitova,
- čistoću repoa,
- tree baze (`norme/sidra/arhiva`),
- popis aktivnih gate markera.

`dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` je dopunjena stavkom
za novi dokument.

Verifikacija (komande):
- `git --no-pager log -10 --oneline`
- `git status --short`
- `Get-ChildItem .\baza_zakona -Directory ...`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\ci_smoke.ps1`

Commit hash: (upisano nakon commita)

---

## Datum: 20.02.2026

README dopunjen: uvedena kanonska specifikacija prekršajnog modula
(struktura + pipeline M0–M9 + gate).

---

## Datum: 20.02.2026 (scaffold mapa)
Kreirane kanonske mape prekršajnog modula (tokovi, predlošci, ogledni
predmet) + .gitkeep za praćenje u git-u.

---

## Datum: 20.02.2026 (specifikacija plana)

Dodana kanonska specifikacija: RAZVOJNI_PLAN_PREKRSAJNI_MODUL v1
(faze, putanje, gate kriteriji).

---

## Datum: 20.02.2026 (audit standard)

Dodano: STANDARD_JSON_AUDIT_PRIMJENE v1 (kanonska struktura audita).

---

## Datum: 20.02.2026 (subsumcija standard)

Dodano: STANDARD_JSON_SUBSUMPCIJA v1 (kanonska struktura subsumcije).

---

## Datum: 20.02.2026 (hijerarhija standard)

Dodano: STANDARD_JSON_HIJERARHIJA v1 (pravila hijerarhije i kolizije).

---

## Datum: 20.02.2026 (predložak standard)

Dodano: STANDARD_JSON_PREDLOZAK v1 (kanonska struktura predloška).

---

## Datum: 20.02.2026 (fix-only standardi)

fix-only: zatvoreni JSON code blokovi + kanonsko mapiranje kolizije u
AUDIT v1 (nalazi[]), bez novih ključeva

---

## Datum: 20.02.2026 (sheme i validatori)

Dodano: JSON sheme (v1) + PS validatori (audit/subsumcija/predložak) i
hard-gate u ci_smoke.

---

## Datum: 20.02.2026 (ogledni json artefakti)

Dodano: ogledni audit_v1.json i predlozak.json (v1) koji prolaze sheme;
(opcionalno) dodana i subsumcija_v1.json.

---

## Datum: 20.02.2026 (postupak tok pn prigovor)

Dodano: postupak.json za TOK_PN_PRIGOVOR v1 + shema/validator postupka i
hard-gate u ci_smoke.

---

## Datum: 20.02.2026 (p2 dovrsetak tokova)

Dodano: postupak.json v1 za TOK_PRESUDA_ZALBA, TOK_RJESENJE_ZALBA,
TOK_OBUSTAVA (P2 dovršen).

---

## Datum: 20.02.2026 (fer naplata standard)

Dodano: STANDARD_FER_NAPLATA_PREKRSAJI v1 (preflight + semafor + gate
G1–G3; zabrana naplate bez realne šanse; zabrana ‘prodaje nade’).

---

## Datum: 22.02.2026 (audit naplate mapiranje)

Dopuna: STANDARD_JSON_AUDIT_PRIMJENE v1 — kanonsko mapiranje audita naplate
(Preflight semafor + gateovi G1–G3 + odluka naplate) kroz nalazi[].

---

## Datum: 22.02.2026

Dopuna: ogledni audit_v1.json — dodani NAP-* nalazi (semafor, G1–G3,
odluka naplate) po kanonskom mapiranju.

---

## Datum: 22.02.2026 (intake + preflight kompozit)

Dodano: STANDARD_JSON_INTAKE_PREKRSAJI v1 + shema/validator; uveden
Preflight korak (M1P) u sva 4 toka; hard-gate u ci_smoke.

---

## Datum: 22.02.2026 (runner tok pn prigovor)

Dodano: minimalni runner v1 za TOK_PN_PRIGOVOR + validator izlaza i smoke
integracija (STOP/OK deterministički).

---

## Datum: 22.02.2026 (genericki runner 4 toka)

Dodano: generički runner run_tok_v1.ps1 + ci_smoke izvršava sva 4 toka
(OK/STOP deterministički), generična validacija izlaza.

---

## Datum: 22.02.2026 (predlozak zalba v1)

Dodano: predlozak.json v1 za zalba_presuda_ili_rjesenje (da žalbeni tokovi
imaju kanonski predložak na referenciranoj putanji).

---

## Datum: 22.02.2026 (gitignore runtime izlazi)

Standardizirano: runtime nacrti u predmeti/**/izlazi/*.txt su u
.gitignore; uklonjen cleanup izlaza iz ci_smoke.

---

## Datum: 22.02.2026 (runner obavezni predlozak)

Pojačano: run_tok_v1.ps1 — predložak je obavezan; missing/invalid predložak
→ STOP (uklonjena tolerancija).

---

## Datum: 22.02.2026 (predlozak intake izvor)

Usklađeno: PREDLOŽAK v1 dopušta intake.* kao izvor (Gate 2),
shema ažurirana.

---

## Datum: 22.02.2026 (zalba predlozak intake mapiranje)

Usklađeno: predlozak zalba_presuda_ili_rjesenje v1 — mapiranje sada
uključuje intake i pravila za cilj/osporavanja.

---

## Datum: 22.02.2026 (runner predlozak stop detail)

Pojačano: run_tok_v1.ps1 — predložak je obavezan; missing/invalid predložak
→ STOP (uklonjena tolerancija).

---

## Datum: 22.02.2026 (runner standardizacija generic only)

Standardizirano: CI koristi samo generički runner run_tok_v1.ps1;
run_tok_pn_prigovor_v1.ps1 označen kao DEPRECATED (povijest).

---

## Datum: 22.02.2026 (standard izlazni nacrt v1)

Dodano: STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1 + pojačana validacija izlaza
(obavezni markeri) u validiraj_izlaz_tok_pn_prigovor_v1.ps1.

---

## Datum: 22.02.2026 (runner obavezni output markeri)

Pojačano: run_tok_v1.ps1 u OK izlazu sada deterministički generira obavezne
markere NACRT/TOK/PREDMET_ID/DATUM te AUDIT_NALAZI_BEGIN/END i
INTAKE_BEGIN/END.

---

## Datum: 22.02.2026 (stabilizacija VS Code PSES na pwsh)

Operativno: stabiliziran VS Code PowerShell Extension (PSES) — prebačeno na
PowerShell 7 (pwsh), restartan language server; potvrđeno PSVersion=7.x i
CI smoke prolazi bez rušenja sessiona.

---

## Datum: 22.02.2026 (ažurirana mapa dokumentacije prekršajni kanon)

Usklađeno: MAPA_DOKUMENTACIJE_VERITAS_H77.md dopunjena je novim aktivnim
kanonskim dokumentima prekršajnog modula i redoslijedom čitanja
(plan → standardi → sheme → alati).

---

## Datum: 22.02.2026 (usklađen razvojni plan prekršajnog modula)

Usklađeno: RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md ažuriran je na stvarno stanje
implementacije (P2 dovršen za 4 toka, generic runner, smoke gate,
intake standard/shema/validator, predlošci i fer naplata), uz jasno
označen sljedeći korak P6 — deterministički generator audita iz predmeta.

---

## Datum: 22.02.2026 (kontrola konzistentnosti predlozak/intake/ci)

Kontrola konzistentnosti: OK.
`STANDARD_JSON_PREDLOZAK.md` i `SCHEMA_PREDLOZAK_V1.json` dopuštaju
`intake.*`, žalbeni predložak koristi `mapiranje.izvori` s `intake`, a
`ci_smoke.ps1` koristi isključivo generički runner `run_tok_v1.ps1`.

---

## Datum: 22.02.2026 (standard generiranje audit prekrsaji v1)

Dodano: STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1 (P6) — definiran izlaz
audit_generated_v1.json, minimalni NAP-* nalazi i STOP uvjeti.

---

## Datum: 22.02.2026 (generator audita v1 + smoke integracija)

Dodano: generiraj_audit_prekrsaji_v1.ps1 + validiraj_audit_generated_v1.ps1
ci_smoke generira i validira audit_generated prije run_tokovi.

---

## Datum: 22.02.2026 (P6 acceptance NAP-MIN + semafor + G1 soft)

Pojačano: P6 generator uvodi NAP-MIN klase (blocker/warning/ok),
deterministički semafor CRVENO/ŽUTO/ZELENO i G1 soft pravilo
(NAP-G1-MISSING/NAP-G1-LATE bez samostalnog blockera), uz validaciju
generated audita i prolaz smoke pipelinea.

---

## Datum: 22.02.2026 (P6 fixtures CRV/ŽUT/ZEL acceptance)

Dodano: kanonski fixtures skup (10 scenarija) +
`test_fixtures_audit_prekrsaji_v1.ps1`.
ci_smoke sada hard-fail provjerava očekivani semafor i ključne NAP kodove
po scenariju nakon generate/validate koraka.

---

## Datum: 23.02.2026 (P6 G1 rok kalkulator soft + analyzer hygiene)

Uvedena je kanonska formula G1 roka u generatoru audita:
trigger `intake.meta.datum_izrade`, rok `8` kalendarskih dana,
izračun `g1.due_date = start + 8`.

Dodani su statusi `OK|MISSING|LATE|INDETERMINATE` i opcionalni
izlazni blok `g1` (`status`, `start_date`, `due_date`, `days`, `note`),
uz konzistentno mapiranje warning nalaza (`NAP-G1-MISSING`,
`NAP-G1-LATE`, `NAP-G1-INDETERMINATE`).

Potvrđeno je soft pravilo: G1 nikad samostalno ne aktivira blocker ni
CRVENO stanje.

U istom patchu riješene su PSScriptAnalyzer higijenske stavke u
generatoru: uklonjena je neiskorištena varijabla (`postupak` assignment)
i funkcija je preimenovana iz `Try-ParseVeritasDate` u
`ConvertTo-VeritasDate` (odobren glagol).

### Commitovi (23.02.2026.)

Redoslijed unosa nije vremenski; dokaz redoslijeda je u commit listi.

```text
c8d7b97 P6: fixture G1 LATE TOK_OBUSTAVA (R2)
f3d9fc8 P6: fixture G1 MISSING TOK_PN_PRIGOVOR (R3)
fd4ca33 P6: fixture G1 LATE TOK_PRESUDA_ZALBA (R2)
73fee5b P6: fixture G1 LATE TOK_RJESENJE_ZALBA (R2)
bd97953 P6: fixture G1 OK TOK_RJESENJE_ZALBA (R4)
2f73dde P6: fixture G1 OK TOK_PRESUDA_ZALBA (R4)
38cf112 P6: fixture G1 OK (R4)
8826cd4 P6: fixture G1 MISSING TOK_PRESUDA_ZALBA (R3)
8a6af69 P6: fixture G1 MISSING TOK_OBUSTAVA (R3)
cf70504 P6: fixture G1 MISSING (R3)
b92122b P6: fixture G1 LATE (R2)
b103f7f P6: fixture CRVENO blocker (R1)
d479739 P6: prioritet praznina fixtures matrice
a711d1e P6: kanon fixturesa + matrica pokrivenosti
ad6c5f9 P6: fixture G1 INDETERMINATE (soft)
4e26b02 P6: G1 rokovi kao strojno pravilo (soft)
db8336d P6: fixtures CRV/ZUT/ZEL acceptance
2235974 P6: acceptance NAP-MIN + semafor + G1 soft
```

---

## Datum: 23.02.2026 (fixture G1 INDETERMINATE soft)

Dodan je novi kanonski fixture scenarij za `g1.status=INDETERMINATE` s
očekivanjima `preflight=ZUTO` (bez blockera) i
`NAP-G1-INDETERMINATE` warning kodom.

Fixtures runner je minimalno proširen da, kada je definirano
`expected.g1.status`, validira status iz generiranog audita.
Istovremeno je dodana kompatibilna podrška za
`expected.nap.must_include/must_not_include` uz postojeći
`required_nap/forbidden_nap` format.

---

## Datum: 23.02.2026 (kanon fixturesa + matrica pokrivenosti)

Dokumentacija fixtures acceptance je stabilizirana bez dodavanja novog koda
ili novih scenarija.

U standardu je definiran kanonski format `scenario.json`:
`id` (scenario_id), opcionalni `naziv`, `tok`, ulazi i expected blok s
preferiranim `expected.g1.status` te
`expected.nap.must_include/must_not_include`.

Legacy polja `required_nap/forbidden_nap` su eksplicitno označena kao
podržana, ali deprecirana.

Dodana je matrica pokrivenosti po toku i G1 statusu kako bi sljedeća
proširenja fixturesa bila vođena jasnim prazninama pokrivenosti.

---

## Datum: 23.02.2026 (prioritet praznina fixtures matrice)

Doc-only odluka: iz postojeće matrice izvučene su prazne ćelije po
tokovima i G1 statusima, bez dodavanja novih scenarija.

Usvojen je kanonski redoslijed rizika popune:
R1 CRVENO/blocker po toku, R2 G1_LATE za prigovor/žalbu,
R3 G1_MISSING, R4 G1_OK, R5 dodatni INDETERMINATE.

U standard je dodan roadmap sljedećih fixturesa (SCN_12..SCN_20)
kao plan implementacije za iduće zadatke, a razvojni plan je dopunjen
backlog stavkama ZADATAK 38-42.

---

## Datum: 23.02.2026 (R1 CRVENO blocker fixture za postojeći tok)

Dodan je `scenario_12` za `TOK_PRESUDA_ZALBA` s determinističkim
očekivanjem `preflight=CRVENO` i obaveznim blocker kodom
`NAP-RED-BLOCKER`.

Scenarij koristi postojeći mehanizam blockera (`G2` fail kroz
`kontradikcije.ima_kontradikcija=true`) bez izmjena generatora.

Matrica pokrivenosti je dopunjena tako da je R1 praznina zatvorena,
a razvojni plan označava ZADATAK 38 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `Get-ChildItem ... scenario.json | ... | Sort-Object -Unique`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R2 G1 LATE fixture za TOK_PN_PRIGOVOR)

Dodan je `scenario_13` za `TOK_PN_PRIGOVOR` s očekivanim
`preflight=ZUTO` i `g1.status=LATE`, bez blockera.

Deterministički uvjet je postavljen datumima:
`intake.meta.datum_izrade=01.02.2026.` i
`audit_v1.meta.datum_izrade=20.02.2026.`, pa je
`due_date = 09.02.2026.` i referentni datum je nakon roka.

Scenarij očekuje warning kod `NAP-G1-LATE`, a zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti i razvojni plan su ažurirani tako da je
ZADATAK 39 označen kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R4 G1 OK sanitarni fixture za TOK_OBUSTAVA)

Dodan je `scenario_24` za `TOK_OBUSTAVA` s očekivanjima
`preflight=ZELENO` i `g1.status=OK`.

Datumi su postavljeni unutar roka:
`intake.meta.datum_izrade=10.02.2026.` i
`audit_v1.meta.datum_izrade=12.02.2026.`.

Scenarij zabranjuje G1 warning kodove (`NAP-G1-MISSING`,
`NAP-G1-LATE`, `NAP-G1-INDETERMINATE`) i blocker kod
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_OBUSTAVA × OK`, a razvojni plan označava
ZADATAK 50 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R2 G1 LATE fixture za TOK_OBUSTAVA)

Dodan je `scenario_23` za `TOK_OBUSTAVA` s očekivanjima
`preflight=ZUTO` i `g1.status=LATE` bez blockera.

LATE je postavljen istim pravilom kao i u ranijim R2 scenarijima:
`audit_v1.meta.datum_izrade` je nakon
`intake.meta.datum_izrade + 8 dana`
(`10.02.2026.` -> `20.02.2026.`).

Scenarij zahtijeva `NAP-G1-LATE` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_OBUSTAVA × LATE`, a razvojni plan označava
ZADATAK 49 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R3 G1 MISSING fixture za TOK_PN_PRIGOVOR)

Dodan je `scenario_22` za `TOK_PN_PRIGOVOR` s očekivanjima
`preflight=ZUTO` i `g1.status=MISSING` bez blockera.

MISSING okidač je isti kao u prethodnim R3 scenarijima:
izostavljen je `intake.meta.datum_izrade`, čime je
`g1StartDate=null` i status postaje `MISSING`.

Scenarij zahtijeva `NAP-G1-MISSING` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_PN_PRIGOVOR × MISSING`, a razvojni plan označava
ZADATAK 48 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R2 G1 LATE fixture za TOK_PRESUDA_ZALBA)

Dodan je `scenario_21` za `TOK_PRESUDA_ZALBA` s očekivanjima
`preflight=ZUTO` i `g1.status=LATE` bez blockera.

LATE je postavljen istim pravilom kao u ZAD 39 i ZAD 46:
`audit_v1.meta.datum_izrade` je nakon
`intake.meta.datum_izrade + 8 dana`
(`10.02.2026.` -> `20.02.2026.`).

Scenarij zahtijeva `NAP-G1-LATE` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_PRESUDA_ZALBA × LATE`, a razvojni plan označava
ZADATAK 47 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R2 G1 LATE fixture za TOK_RJESENJE_ZALBA)

Dodan je `scenario_20` za `TOK_RJESENJE_ZALBA` s očekivanjima
`preflight=ZUTO` i `g1.status=LATE` bez blockera.

LATE je postavljen kanonskim pravilom:
`audit_v1.meta.datum_izrade` je nakon
`intake.meta.datum_izrade + 8 dana`
(`10.02.2026.` -> `20.02.2026.`).

Scenarij zahtijeva `NAP-G1-LATE` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_RJESENJE_ZALBA × LATE`, a razvojni plan označava
ZADATAK 46 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R4 G1 OK sanitarni fixture za TOK_RJESENJE_ZALBA)

Dodan je `scenario_19` za `TOK_RJESENJE_ZALBA` s očekivanjima
`preflight=ZELENO` i `g1.status=OK`.

Datumi su postavljeni unutar roka:
`intake.meta.datum_izrade=10.02.2026.` i
`audit_v1.meta.datum_izrade=12.02.2026.`.

Scenarij zabranjuje G1 warning kodove (`NAP-G1-MISSING`,
`NAP-G1-LATE`, `NAP-G1-INDETERMINATE`) i blocker kod
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_RJESENJE_ZALBA × OK`, a razvojni plan označava
ZADATAK 45 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R4 G1 OK sanitarni fixture za TOK_PRESUDA_ZALBA)

Dodan je `scenario_18` za `TOK_PRESUDA_ZALBA` s očekivanjima
`preflight=ZELENO` i `g1.status=OK`.

Datumi su postavljeni unutar roka:
`intake.meta.datum_izrade=10.02.2026.` i
`audit_v1.meta.datum_izrade=12.02.2026.`.

Scenarij zabranjuje G1 warning kodove (`NAP-G1-MISSING`,
`NAP-G1-LATE`, `NAP-G1-INDETERMINATE`) i blocker kod
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_PRESUDA_ZALBA × OK`, a razvojni plan označava
ZADATAK 44 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R4 G1 OK sanitarni fixture za TOK_PN_PRIGOVOR)

Dodan je `scenario_17` za `TOK_PN_PRIGOVOR` s očekivanjima
`preflight=ZELENO` i `g1.status=OK`.

Datumi su postavljeni deterministički unutar roka:
`intake.meta.datum_izrade=10.02.2026.` i
`audit_v1.meta.datum_izrade=12.02.2026.`, pa je
referentni datum unutar granice od 8 dana.

Scenarij zabranjuje G1 warning kodove (`NAP-G1-MISSING`,
`NAP-G1-LATE`, `NAP-G1-INDETERMINATE`) i blocker kod
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_PN_PRIGOVOR × OK`, a razvojni plan označava
ZADATAK 43 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R3 G1 MISSING fixture za TOK_PRESUDA_ZALBA)

Dodan je `scenario_16` za `TOK_PRESUDA_ZALBA` s očekivanjima
`preflight=ZUTO` i `g1.status=MISSING` bez blockera.

MISSING okidač je isti kao u prethodnim R3 scenarijima:
izostavljen je `intake.meta.datum_izrade`, što daje
`g1StartDate=null` i `G1_STATUS=MISSING`.

Scenarij zahtijeva `NAP-G1-MISSING` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_PRESUDA_ZALBA × MISSING`, a razvojni plan označava
ZADATAK 42 kao dovršen (treća R3 praznina).

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R3 G1 MISSING fixture za TOK_OBUSTAVA)

Dodan je `scenario_15` za `TOK_OBUSTAVA` s očekivanjima
`preflight=ZUTO` i `g1.status=MISSING` bez blockera.

MISSING je postavljen istim okidačem kao u ZAD 40:
izostavljen je `intake.meta.datum_izrade`, što daje
`g1StartDate=null` i `G1_STATUS=MISSING`.

Scenarij zahtijeva `NAP-G1-MISSING` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_OBUSTAVA × MISSING`, a razvojni plan označava
ZADATAK 41 kao dovršen.

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`

---

## Datum: 23.02.2026 (R3 G1 MISSING fixture za TOK_RJESENJE_ZALBA)

Dodan je `scenario_14` za `TOK_RJESENJE_ZALBA` s očekivanjima
`preflight=ZUTO` i `g1.status=MISSING` bez blockera.

Deterministički okidač `MISSING` je namjerno postavljen izostavljanjem
`intake.meta.datum_izrade` (trigger datuma), uz validne G2/G3 ulaze.

Scenarij zahtijeva `NAP-G1-MISSING` i `NAP-SEM`, te zabranjuje
`NAP-RED-BLOCKER`.

Matrica pokrivenosti je dopunjena za ćeliju
`TOK_RJESENJE_ZALBA × MISSING`, a razvojni plan označava
ZADATAK 40 kao dovršen (prva R3 praznina).

Dokazne naredbe:

- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `git diff --name-only`
## Datum: 18.03.2026 (osnovni postupovni skup iz jezgre i pilota)

Iz pilot-skupa i već izdvojene jezgre formiran je osnovni postupovni skup
rječničkih natuknica za prvi praktični ciklus NN sidrenja.

Napravljena je skripta
`alati/prosiri_jezgrene_natuknice_na_osnovni_postupovni_skup.py`.

Dodani su izlazi:
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/
  osnovni_postupovni_skup_za_nn_sidrenje_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`

Skup zadržava svih 7 jezgrenih natuknica i dodaje opće natuknice koje su
deterministički prepoznate kao postupovno relevantne bez uskog konteksta.

Dokazne naredbe:

- `python .\alati\prosiri_jezgrene_natuknice_na_osnovni_postupovni_skup.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 18.03.2026 (jezgrene natuknice iz pilot-skupa)

Iz postojećeg pilot-skupa izdvojen je uži skup jezgrenih rječničkih
natuknica za prvi stvarni ciklus NN sidrenja.

Napravljena je skripta `alati/izdvoji_jezgrene_natuknice_iz_pilota.py`.

Dodani su izlazi:
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`

Jezgreni skup zadržava puni sadržaj pilot-zapisa i dodaje polja
`jezgrena_natuknica=true`, `osnova_jezgrenosti` i
`redoslijed_jezgrenog_skupa`.

Složeni i izvedeni izrazi izdvojeni su u popis odbačenih natuknica u
manifestu; NN sidra i definicije nisu dodavane.

Dokazne naredbe:

- `python .\alati\izdvoji_jezgrene_natuknice_iz_pilota.py`

## Datum: 25.03.2026 (ZADATAK 72B - ciscenje Problems panela za repo)

Ociscene su aktivne stavke Problems panela koje nisu dio repozitorija,
uz strogo filtriranje samo na datoteke unutar `C:\Veritas_H77`.

Pocetni broj repo-gresaka u Problems panelu: `0`.

Zahvacene datoteke (provjerene):

- `alati/upisi_validirana_nn_sidra_u_natuknice.py`
- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`
- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`
- sve ostale `.py` datoteke iz repozitorija (`alati/*.py`)

Uklonjene greske:

- nema repo-gresaka za uklanjanje; aktivne stavke su bile samo u
  `Ask.agent.md`, `Explore.agent.md`, `Plan.agent.md` unutar
  `globalStorage`, sto je izvan scopea i eksplicitno ignorirano.

Zavrsni broj repo-gresaka u Problems panelu: `0`.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- provjera Problems panela za repo `.py` datoteke
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 18.03.2026 (pilot-skup natuknica za prvo NN sidrenje)

Iz početnog skupa rječničkih natuknica izdvojen je mali pilot-skup za prvi
operativni ciklus ručnog NN sidrenja.

Napravljena je skripta `alati/izdvoji_pilot_natuknice_za_nn_sidrenje.py`.

Dodani su izlazi:
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`

Svaka izdvojena natuknica zadržava puni izvorni sadržaj i dodatna
pilot-polja: `pilot_skup=true`, `osnova_ulaska_u_pilot`,
`redoslijed_pilota`.

Pilot-sloj ne uvodi NN sidra ni definicije; zadržava
`status_validacije=CEKA_NN_SIDRO`.

Dokazne naredbe:

- `python .\alati\izdvoji_pilot_natuknice_za_nn_sidrenje.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (ZADATAK 74B - druga potpuno validirana natuknica)

Deterministicki je zatvorena druga potpuno validirana natuknica iz ulaza
`granske_podnatuknice_nn_v2.json`, uz iskljucenje vec zatvorene natuknice
`apsolutna nenadležnost — prekršajni zakon — čl. 101`.

Napravljena je skripta:

- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`

Ažurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Početni broj potpuno validiranih natuknica: `1`.
Završni broj potpuno validiranih natuknica: `2`.
Novo zatvorena natuknica:
`apsolutna nenadležnost — prekršajni zakon — čl. 102`.
Broj potvrđenih sidara u novo zatvorenoj natuknici: `1`.
Završni status:
`DRUGA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA`.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_drugu_validiranu_gransku_natuknicu.py`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (sanacija Copilot agent upozorenja u globalStorage)

Sanirana su VS Code Copilot agent upozorenja iz globalStorage i potvrdeno je
da problem nije bio u Veritas repou.

Zahvacene datoteke izvan repoa:

- `C:\Users\User\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\`
  `ask-agent\Ask.agent.md`
- `C:\Users\User\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\`
  `explore-agent\Explore.agent.md`
- `C:\Users\User\AppData\Roaming\Code\User\globalStorage\github.copilot-chat\`
  `plan-agent\Plan.agent.md`

Pocetni broj upozorenja: `18`.
Zavrsni broj upozorenja: `0`.

Uklonjeni su nepodrzani alati iz `tools` polja:

- `github/issue_read`
- `github.vscode-pull-request-github/issue_fetch`
- `github.vscode-pull-request-github/activePullRequest`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- provjera Problems panela za `Ask.agent.md`, `Explore.agent.md`,
  `Plan.agent.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 18.03.2026 (kanonski model rječničke natuknice)

Uveden je kanonski JSON model jedne rječničke natuknice Veritas H.77 i
iz postojećeg skupa `nn_sidrenju_podobni_pojmovi.json` generiran je početni
operativni skup bez NN sidra.

Napravljena je skripta `alati/izgradi_pocetne_rjecnicke_natuknice.py`.

Dodani su izlazi:
- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice.json`
- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`

U ovom koraku sva polja bez dokazive osnove ostavljena su na praznim
vrijednostima (`null`, `[]`, `{}`), `nn_sidra` je prazna struktura spremna
za buduće sidrenje, `status_validacije=CEKA_NN_SIDRO`, a
`razina_pouzdanosti` je prenesena iz ulaza gdje postoji.

Dokazne naredbe:

- `python .\alati\izgradi_pocetne_rjecnicke_natuknice.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (ZADATAK 73 - prva potpuno validirana natuknica)

Iz ulaza `granske_podnatuknice_nn_v2.json` deterministicki je odabrana i
zatvorena prva podnatuknica koja zadovoljava uvjete jednoznacnog konteksta,
jednog `akt_slug` i nekontradiktornih dokazivih NN sidara.

Napravljena je skripta:

- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`

Dodani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Odabrana i zatvorena natuknica:

- `apsolutna nenadležnost — prekršajni zakon — čl. 101`

Broj ulaznih granskih podnatuknica: `40`.
Broj potvrdenih sidara odabrane natuknice: `1`.
Zavrsni status: `POTPUNO_VALIDIRANO`.

Dodan je standard:

- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_prvu_validiranu_gransku_natuknicu.py`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 18.03.2026 (ciscenje prioritetnog uzorka za NN sidrenje)

Iz prioritetnog uzorka izdvojen je uži skup kandidata tekstualno podobnih
za budući NN pregled, uz uklanjanje očitog tehničkog šuma.

Napravljena je skripta `alati/ocisti_prioritetni_uzorak_za_nn_sidrenje.py`
koja zadržane zapise označava s
`status_podobnosti_nn_sidrenja=PODOBAN_ZA_NN_PREGLED` i jednom od osnova
`PRAVNI_NAZIV`, `PROCESNI_POJAM`, `AKT_ILI_RADNJA`.

Dodani su izlazi:
- `baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/
  nn_sidrenju_podobni_pojmovi_manifest.json`

Dodan je standard `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 18.03.2026 (prioritetni uzorak za NN sidrenje)

Iz postojećeg skupa EU -> NN prijedloga mapiranja izdvojen je prioritetni
radni uzorak kandidata za prvo NN sidrenje, bez dohvaćanja i bez potvrde
članaka Narodnih novina.

Napravljena je skripta `alati/izdvoji_prioritetni_uzorak_za_nn_sidrenje.py`
koja deterministički označava prioritet po osnovama:
`POUZDANOST_SREDNJA`, `UCESTALI_KANDIDAT`, `PROCESNI_NAZIV`.

Dodani su izlazi:
- `baza_terminologije/mape/eu_prema_nn/prioritetni_uzorak_za_nn_sidrenje.json`
- `baza_terminologije/mape/eu_prema_nn/
  prioritetni_uzorak_za_nn_sidrenje_manifest.json`

Dodan je standard
`STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 18.03.2026 (EU most prema potencijalnim NN pojmovima)

Iz hrvatski relevantnog CURIA skupa dodan je tehnički sloj mapiranja prema
potencijalnim NN pojmovima bez normativnog sidrenja i bez pravnog
zaključivanja.

Napravljena je skripta `alati/mapiraj_curia_na_potencijalne_nn_pojmove.py`
koja koristi samo postojeće ulaze i za svaki prijedlog postavlja
`zahtijeva_rucnu_provjeru=true` i
`status_mapiranja=PREDLOZENO_BEZ_NN_SIDRA`.

Dodani su izlazi:
- `baza_terminologije/mape/eu_prema_nn/
  curia_prema_nn_potencijalni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/
  curia_prema_nn_potencijalni_pojmovi_manifest.json`

Dodan je novi standard `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md` i
ažurirani su status i mapa dokumentacije za terminološki tok.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---
## Datum: 18.03.2026 (tvrda zastita DNEVNIK_RADA.md)

U projektnoj dokumentaciji uvedena je tvrda zaštita datoteke
`dokumentacija/DNEVNIK_RADA.md` kroz novi kanonski standard i dopune
metodologije i mape dokumentacije.

Dodan je novi dokument:
- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`

Uvedena su pravila:
- dnevnik rada je zaštićena evidencijska datoteka,
- dopušten je samo append,
- potpuno prepisivanje je zabranjeno,
- sanacija je dopuštena samo po posebnom zadatku,
- prije i poslije svake izmjene obavezni su dokazni ispisi završnog dijela
  datoteke.

Dokazne naredbe:

- `Write-Host "DNEVNIK_TAIL_BEFORE_BEGIN"`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 40`
- `Write-Host "DNEVNIK_TAIL_BEFORE_END"`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `Write-Host "DNEVNIK_TAIL_AFTER_BEGIN"`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 60`
- `Write-Host "DNEVNIK_TAIL_AFTER_END"`

---
## Datum: 18.03.2026 (prvo NN sidrenje osnovnog postupovnog skupa)

Za osnovni postupovni skup (9 natuknica) izrađen je prvi stvarni
NN-sidreni sloj bez izmišljanja članaka i bez prisilnog sužavanja
višeznačnih pojmova.

Napravljena je skripta:
- `alati/sidri_osnovni_postupovni_skup_na_nn.py`

Dodani su izlazi:
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json`
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`

Obrađene natuknice (kanonski_naziv | status_sidra | broj sidara):

- `dokaz | VISE_MOGUCIH_SIDARA | 5`
- `dostava | VISE_MOGUCIH_SIDARA | 5`
- `izvršenje | VISE_MOGUCIH_SIDARA | 5`
- `presuda | VISE_MOGUCIH_SIDARA | 5`
- `prigovor | VISE_MOGUCIH_SIDARA | 5`
- `rješenje | VISE_MOGUCIH_SIDARA | 5`
- `žalba | VISE_MOGUCIH_SIDARA | 5`
- `apsolutna nenadležnost | NEJASNO | 5`
- `glavni postupak | NEDOSTAJE | 0`

Ukupni statusi validacije:

- `NN_SIDRENO = 0`
- `CEKA_RUCNU_PROVJERU_NN = 8`
- `CEKA_NN_SIDRO = 1`

Dokazne naredbe:

- `python .\alati\sidri_osnovni_postupovni_skup_na_nn.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---
## Datum: 18.03.2026 (razlaganje višeznačnih NN sidara)

Za višeznačne i nejasne natuknice iz NN-sidrenog osnovnog postupovnog skupa
uveden je kandidatski sloj razlaganja po aktu/kontekstu, bez konačnog
odabira glavnog sidra.

Napravljena je skripta:
- `alati/razlozi_viseznacna_nn_sidra_po_aktu.py`

Dodani su izlazi:
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn.json`
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_manifest.json`

Dodan je standard:
- `dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`

Razložene natuknice i broj kandidata:

- `dokaz -> 1`
- `dostava -> 1`
- `izvršenje -> 1`
- `presuda -> 1`
- `prigovor -> 1`
- `rješenje -> 1`
- `žalba -> 1`
- `apsolutna nenadležnost -> 1`

Ukupan broj kandidata: `8`

Dokazne naredbe:

- `python .\alati\razlozi_viseznacna_nn_sidra_po_aktu.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---
## Datum: 18.03.2026 (ispravak razlaganja NN kandidata na stvarne kandidate)

Ispravljeno je razlaganje višeznačnih i nejasnih NN sidara tako da se
kandidati v2 stvaraju po pojedinom sidru (jedinstvena kombinacija akt/NN/
članak/stavak/točka), umjesto jednog kandidata po nadređenom pojmu.

Napravljena je skripta:
- `alati/ispravi_razlaganje_nn_kandidata.py`

Dodani su izlazi:
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2.json`
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2_manifest.json`

Ulaz/izlaz po nadređenoj natuknici (sidra -> kandidati v2):

- `dokaz: 5 -> 5`
- `dostava: 5 -> 5`
- `izvršenje: 5 -> 5`
- `presuda: 5 -> 5`
- `prigovor: 5 -> 5`
- `rješenje: 5 -> 5`
- `žalba: 5 -> 5`
- `apsolutna nenadležnost: 5 -> 5`

Ukupan broj kandidata v2: `40`.

Dokazne naredbe:

- `python .\alati\ispravi_razlaganje_nn_kandidata.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (sužavanje NN kandidata za ručnu validaciju)

Iz v2 sloja kandidata izrađen je konačni kandidatski skup za ručnu pravnu
validaciju, bez automatskog odabira glavnog sidra i bez unošenja novih
normativnih podataka.

Zabilježen je obavezni zaštitni ispis dnevnika prije izmjene:

- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`

Napravljena je skripta:

- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`

Dodani su izlazi:

- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju.json`
- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju_manifest.json`

Dodan je standard:

- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`

Statistike sužavanja po nadređenom pojmu (prije -> poslije):

- `apsolutna nenadležnost: 5 -> 5`
- `dokaz: 5 -> 5`
- `dostava: 5 -> 5`
- `izvršenje: 5 -> 5`
- `presuda: 5 -> 5`
- `prigovor: 5 -> 5`
- `rješenje: 5 -> 5`
- `žalba: 5 -> 5`

Ukupne statistike:

- `ukupno prije: 40`
- `ukupno poslije: 40`
- `grupiran_isti_kontekst: 0`
- `zadržan_različit_akt_ili_kontekst: 40`

Dokazne naredbe:

- `python .\alati\suzi_nn_kandidate_za_rucnu_validaciju.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (ručna validacija i upis potvrđenih NN sidara)

Provedena je ručna validacija konačnih NN kandidata i upis potvrđenih sidara
u novi validirani sloj osnovnog postupovnog skupa.

Zabilježen je obavezni zaštitni ispis dnevnika prije izmjene:

- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`

Napravljena je skripta:

- `alati/upisi_validirana_nn_sidra_u_natuknice.py`

Dodani su izlazi:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran.json`
- `baza_terminologije/rjecnik/
 osnovni_postupovni_skup_nn_validiran_manifest.json`

Dodan je standard:

- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`

Rezultati po nadređenom pojmu
(ulazni kandidati -> potvrđena sidra | status):

- `dokaz: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `dostava: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `izvršenje: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `presuda: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `prigovor: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `rješenje: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `žalba: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`
- `apsolutna nenadležnost: 5 -> 5 | NN_DJELOMICNO_VALIDIRANO`

Ukupni statusi validacije:

- `NN_VALIDIRANO: 0`
- `NN_DJELOMICNO_VALIDIRANO: 8`
- `CEKA_DALJNJU_RUCNU_VALIDACIJU: 0`

Dokazne naredbe:

- `python .\alati\upisi_validirana_nn_sidra_u_natuknice.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (konsolidacija validiranih NN sidara po granama)

Iz validiranog NN sloja izvedene su granske rječničke podnatuknice za
ciljanih 8 općih pojmova, bez izmišljanja članaka i bez spajanja različitih
konteksta u jedan zapis.

Zabilježen je obavezni zaštitni ispis dnevnika prije izmjene:

- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`

Napravljena je skripta:

- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`

Dodani su izlazi:

- `baza_terminologije/rjecnik/granske_podnatuknice_nn.json`
- `baza_terminologije/rjecnik/granske_podnatuknice_nn_manifest.json`

Dodan je standard:

- `dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md`

Rezultati po nadređenom pojmu
(broj potvrđenih sidara u ulazu -> broj granskih podnatuknica u izlazu):

- `dokaz: 5 -> 1`
- `dostava: 5 -> 1`
- `izvršenje: 5 -> 1`
- `presuda: 5 -> 1`
- `prigovor: 5 -> 1`
- `rješenje: 5 -> 1`
- `žalba: 5 -> 1`
- `apsolutna nenadležnost: 5 -> 1`

Ukupan broj granskih podnatuknica: `8`.

Dokazne naredbe:

- `python .\alati\konsolidiraj_nn_validirane_pojmove_po_grani.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (sanacija grešaka i korekcija granske konsolidacije v2)

Sanirane su ciljane Python/Pylance provjere i ispravljena je lažna granska
konsolidacija tako da opći pojmovi više nisu automatski sažeti u jedan zapis
bez stvarnog razdvajanja po normativnom kontekstu.

Zabilježen je obavezni zaštitni ispis dnevnika prije izmjene:

- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`

Provjera Pylance grešaka prije popravka:

- `alati/upisi_validirana_nn_sidra_u_natuknice.py`: bez grešaka
- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`: bez grešaka
- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`: bez grešaka

Ispravljena skripta:

- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`

Dodani v2 izlazi:

- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json`
- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json`

Rezultati po nadređenom pojmu
(broj sidara u ulazu -> broj granskih podnatuknica u izlazu v2):

- `dokaz: 5 -> 5`
- `dostava: 5 -> 5`
- `izvršenje: 5 -> 5`
- `presuda: 5 -> 5`
- `prigovor: 5 -> 5`
- `rješenje: 5 -> 5`
- `žalba: 5 -> 5`
- `apsolutna nenadležnost: 5 -> 5`

Ukupan broj granskih podnatuknica v2: `40`.

Provjera Pylance grešaka nakon popravka:

- `alati/upisi_validirana_nn_sidra_u_natuknice.py`: bez grešaka
- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`: bez grešaka
- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`: bez grešaka

Dokazne naredbe:

- `python .\alati\konsolidiraj_nn_validirane_pojmove_po_grani.py`
- `git status --short`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 25.03.2026 (ZADATAK 74A - standard sinkronizacije repoa)

Uveden je kanonski standard sinkronizacije repoa:

- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`

GitHub je proglasen kanonskim izvorom istine.
Lokalni repo `C:\Veritas_H77` je jedina radna kopija za razvoj i Copilot
zadatke.
Google Disk je definiran kao sinkronizirana kopija i backup, bez paralelnog
uredjivanja istih `.md`, `.py` i `.json` datoteka.

Utvrdene cinjenice prije izmjena:

- lokalni hash: `6e1e938`
- `git status --short`: prazan
- `main` prema `origin/main`: `ahead 1` (nije poravnat)
- tipicne lokalne Drive putanje nisu detektirane ovom provjerom

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git diff --name-only`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (ZADATAK 75 - sljedeca potpuno validirana natuknica)

Iz ulaza `granske_podnatuknice_nn_v2.json` deterministicki je zatvorena tocno
jedna nova potpuno validirana natuknica, razlicita od vec zatvorenih
`apsolutna nenadležnost — prekršajni zakon — čl. 101` i
`apsolutna nenadležnost — prekršajni zakon — čl. 102`.

Napravljena je skripta:

- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `2`.
Zavrsni broj potpuno validiranih natuknica: `3`.
Novo zatvorena natuknica:
`apsolutna nenadležnost — prekršajni zakon — čl. 103`.
Broj potvrdenih sidara u novo zatvorenoj natuknici: `1`.
Zavrsni status:
`SLJEDECA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA`.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (ZADATAK 76 - jos jedna potpuno validirana natuknica)

Iz ulaza `granske_podnatuknice_nn_v2.json` deterministicki je zatvorena tocno
jedna nova potpuno validirana natuknica, razlicita od vec zatvorenih
`apsolutna nenadležnost — prekršajni zakon — čl. 101`,
`apsolutna nenadležnost — prekršajni zakon — čl. 102` i
`apsolutna nenadležnost — prekršajni zakon — čl. 103`.

Napravljena je skripta:

- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `3`.
Zavrsni broj potpuno validiranih natuknica: `4`.
Novo zatvorena natuknica:
`apsolutna nenadležnost — prekršajni zakon — čl. 122`.
Broj potvrdenih sidara u novo zatvorenoj natuknici: `1`.
Zavrsni status:
`JOS_JEDNA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA`.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (ZADATAK 77 - stabilizacija dnevnika i analiza skoka)

Rijesen je uzrok zbog kojeg je novi dnevnicki unos ponekad zavrsavao u sredini
`dokumentacija/DNEVNIK_RADA.md` umjesto na kraju.

Uzrok:

- unos se u prethodnim zadacima povremeno dodavao kontekstnim patchanjem uz
  ponavljajuce markere (`---`), pa je alat mogao odabrati prvo podudaranje u
  sredini datoteke umjesto stvarnog EOF-a.

Trajno rjesenje:

- uvedena je kanonska append-only skripta
  `alati/dodaj_dnevnicki_unos_na_kraj.ps1` koja dodaje unos iskljucivo na EOF
  i ne dira stare retke.

Analiza skoka `103 -> 122` je provedena i dokumentirana u:

- `dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`

Zakljucak analize:

- skok `103 -> 122` je potvrden kao ispravan,
- za ciljani niz u ulazu postoje clanci `101, 102, 103, 122, 161`,
- clanci `104-121` ne postoje u ulazu i zato nisu mogli biti zatvoreni.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git --no-pager show ae7b980 -- dokumentacija/DNEVNIK_RADA.md`
- `git --no-pager show d501911 -- dokumentacija/DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath $entryPath`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 27.03.2026 (ZADATAK 78 - paketno zatvaranje homogenog niza)

Provedeno je paketno zatvaranje preostalih jednoznacnih natuknica iz
homogenog niza `apsolutna nenadležnost — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `4`.
Zavrsni broj potpuno validiranih natuknica: `5`.

Popis novozatvorenih clanaka u paketu:

- `161`

Popis preskocenih clanaka u paketu:

- `101` (vec zatvoren)
- `102` (vec zatvoren)
- `103` (vec zatvoren)
- `122` (vec zatvoren)

Broj novozatvorenih natuknica u paketu: `1`.
Broj preskocenih stavki u paketu: `4`.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath $entryPath`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

---

## Datum: 27.03.2026 (ZADATAK 79 - rangiranje sljedeceg homogenog niza)

Proveden je analiza-only korak za odabir sljedeceg homogenog paketa bez
zatvaranja novih natuknica.

Napravljena je skripta:

- `alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`

Generirani su izlazi:

- `baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json`
- `baza_terminologije/rjecnik/`
  `rang_lista_homogenih_nizova_za_paket_manifest.json`

Rezultat rangiranja:

- preporuceni sljedeci homogeni niz: `dokaz` + `prekrsajni_zakon`
- score preporuke: `550`
- broj novih zatvaranja u ovom koraku: `0`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

---

## Datum: 27.03.2026 (ZADATAK 80 - paketno zatvaranje niza dokaz)

Provedeno je paketno zatvaranje jednoznacnih natuknica iz homogenog niza
`dokaz — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `5`.
Zavrsni broj potpuno validiranih natuknica: `10`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu:

- `78`
- `85`
- `87`
- `88`
- `89`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_dokaz_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

---

## Datum: 27.03.2026 (ZADATAK 81 - sljedeci homogeni niz iz rang-liste)

Provedeno je paketno zatvaranje sljedeceg preporucenog homogenog niza iz
postojece rang-liste, uz strogo ogranicenje na jedan niz.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `dostava`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost — prekrsajni_zakon` i
  `dokaz — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_dostava_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `10`.
Zavrsni broj potpuno validiranih natuknica: `15`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu:

- `114`
- `117`
- `118`
- `122`
- `87`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_dostava_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

---

## Datum: 27.03.2026 (ZADATAK 82 - novi homogeni niz iz rang-liste)

Provedeno je paketno zatvaranje sljedeceg preporucenog homogenog niza iz
postojece rang-liste, uz strogo ogranicenje na jedan niz.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `izvršenje`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost — prekrsajni_zakon`,
  `dokaz — prekrsajni_zakon` i `dostava — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `15`.
Zavrsni broj potpuno validiranih natuknica: `20`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu (numericki uzlazno):

- `13`
- `14`
- `34`
- `42`
- `44`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

## Datum: 27.03.2026 (ZADATAK 83 - sljedeci homogeni niz)

Provedeno je paketno zatvaranje sljedeceg preporucenog homogenog niza iz
postojece rang-liste, uz strogo ogranicenje na jedan niz.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `presuda`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost — prekrsajni_zakon`,
  `dokaz — prekrsajni_zakon`, `dostava — prekrsajni_zakon` i
  `izvršenje — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_presuda_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `20`.
Zavrsni broj potpuno validiranih natuknica: `25`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu (numericki uzlazno):

- `33`
- `40`
- `99`
- `106`
- `109`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_presuda_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

## Datum: 27.03.2026 (ZADATAK 84 - sljedeci homogeni niz)

Provedeno je paketno zatvaranje sljedeceg preporucenog homogenog niza iz
postojece rang-liste, uz strogo ogranicenje na jedan niz.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `prigovor`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost — prekrsajni_zakon`,
  `dokaz — prekrsajni_zakon`, `dostava — prekrsajni_zakon`,
  `izvršenje — prekrsajni_zakon` i `presuda — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `25`.
Zavrsni broj potpuno validiranih natuknica: `30`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu (numericki uzlazno):

- `93`
- `102`
- `120`
- `121`
- `221`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_prigovor_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

## Datum: 27.03.2026 (ZADATAK 85 - sljedeci homogeni niz)

Provedeno je paketno zatvaranje sljedeceg preporucenog homogenog niza iz
postojece rang-liste, uz strogo ogranicenje na jedan niz.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `rješenje`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost — prekrsajni_zakon`,
  `dokaz — prekrsajni_zakon`, `dostava — prekrsajni_zakon`,
  `izvršenje — prekrsajni_zakon`, `presuda — prekrsajni_zakon` i
  `prigovor — prekrsajni_zakon`.

Napravljena je skripta:

- `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

Pocetni broj potpuno validiranih natuknica: `30`.
Zavrsni broj potpuno validiranih natuknica: `35`.
Broj analiziranih kandidata u paketu: `5`.
Broj novozatvorenih natuknica u paketu: `5`.

Popis novozatvorenih clanaka u paketu (numericki uzlazno):

- `34`
- `59`
- `89`
- `92`
- `99`

Popis preskocenih stavki:

- nema preskocenih stavki (`0`)

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

## Datum: 27.03.2026 (ZADATAK 86 - uskladjenje statusa i rang-liste)

Proveden je servisni analysis/sync korak bez zatvaranja novih natuknica.

Stvarni HEAD commit prije izmjena:

- `36fb4f0`

Zadnji dovrseni operativni paketni zadatak prije ovog koraka:

- `ZADATAK 85`

Osvjezena je rang-lista homogenih nizova:

- `baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json`
- `baza_terminologije/rjecnik/`
  `rang_lista_homogenih_nizova_za_paket_manifest.json`

Novi rezultat rangiranja:

- prvi sljedeci homogeni niz: `žalba — prekrsajni_zakon`
- broj nizova s barem jednom preostalom stavkom: `1`
- potvrda: `žalba — prekrsajni_zakon` je sljedeci i ujedno zadnji
  preostali homogeni niz.

Uskladjen je statusni dokument:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Nema novih zatvaranja natuknica u ovom zadatku.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`
- `Get-Content ./dokumentacija/DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `./dokumentacija/DNEVNIK_RADA.md -EntryPath $entryPath`

## Datum: 27.03.2026 (ZADATAK 87 - paketno zatvaranje niza zalba)

Provedeno je paketno zatvaranje homogenog niza `žalba — prekrsajni_zakon`
kao zavrsni operativni korak terminoloskog toka.

Odabrani niz:

- `nadredeni_kanonski_naziv`: `žalba`
- `akt_slug`: `prekrsajni_zakon`
- `score`: `550`
- razlog odabira: sljedeci i zadnji preostali homogeni niz s otvorenim
  kandidatima nakon prethodno zatvorenih nizova.

Napravljena je skripta:

- `alati/zatvori_paket_zalba_prekrsajni_zakon.py`

Azurirani su izlazi:

- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`
- `baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json`
- `baza_terminologije/rjecnik/`
  `rang_lista_homogenih_nizova_za_paket_manifest.json`

Pocetni broj potpuno validiranih natuknica: `35`.
Zavrsni broj potpuno validiranih natuknica: `40`.
Broj novozatvorenih natuknica: `5`.

Popis novozatvorenih clanaka (numericki uzlazno):

- `87`
- `89`
- `95`
- `99`
- `100`

Potvrda prethodno zatvorenih nizova:

- `apsolutna nenadležnost`, `dokaz`, `dostava`, `izvršenje`, `presuda`,
  `prigovor` i `rješenje` vec su zatvoreni prije ovog koraka.

Potvrda stanja nakon Z87:

- nema preostalih homogenih nizova za paketno zatvaranje
  (`preporuceni_sljedeci_niz_za_paket = null`).

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/zatvori_paket_zalba_prekrsajni_zakon.py`
- `git diff --name-only`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 88 - zavrsni servisni snapshot)

Proveden je zavrsni servisni snapshot rjecnickog toka nakon Z87, bez novih
operativnih zatvaranja natuknica.

Potvrde stanja nakon Z87:

- nema preostalih homogenih nizova za paketno zatvaranje
  (`preporuceni_sljedeci_niz_za_paket = null`)
- broj potpuno validiranih natuknica ostaje `40`
- GitHub je poravnat na commit `062ed37`

Popis provjerenih datoteka:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`
- `baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json`
- `baza_terminologije/rjecnik/`
  `rang_lista_homogenih_nizova_za_paket_manifest.json`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 89 - uskladjenje razvojnog plana)

Provedeno je plansko uskladjenje nakon zatvaranja rjecnickog toka.

Potvrde:

- rjecnicki tok je zatvoren kroz Z87 i Z88
- planski dokument je azuriran
- azurirana planska datoteka:
  `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 90 - prioriteti konverzije zakona u JSON)

Izraden je novi kanonski dokument prioriteta daljnje konverzije zakona u
JSON.

Novi dokument:

- `dokumentacija/PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`

Potvrde:

- `ustav_rh_procisceni` i `prekrsajni_zakon_procisceni` ostaju postojeci
  uzorak rada
- dokument definira redoslijed daljnje konverzije zakona po paketima

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 91 - uskladjenje statusa nakon Z89 i Z90)

Provedeno je servisno uskladjenje statusnog dokumenta sa stvarnim stanjem
repoa nakon Z89 i Z90.

Potvrde prije uskladjenja:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` bio je zaostao na Z88
- Z89 i Z90 vec su bili dokazivo prisutni u
  `dokumentacija/DNEVNIK_RADA.md`
- novi kanonski dokument prioriteta vec je bio uvrsten u
  `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`

Potvrda nakon uskladjenja:

- statusni dokument je uskladen sa stvarnim stanjem nakon Z90

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 92 - utvrdjen rezim konverzije ZUP u JSON)

Analiziran je `zakon_o_opcem_upravnom_postupku` kao prvi zakon iz
paketa A prioriteta konverzije.

Provedena je provjera statusa na Narodnim novinama i utvrdjeno je da za
ovaj korak nije dokazano postojanje valjanog prociscenog teksta za izravnu
konverziju.

Na temelju toga odabran je rezim konverzije:

- `REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL`

Novi kanonski dokument:

- `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`

Azurirana dokumentacija:

- `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 93 - pripremljen manifest ingest-a za ZUP)

Pripremljen je kanonski ulazni manifest ingest-a za
`zakon_o_opcem_upravnom_postupku` bez pokretanja ingest-a i normiranja.

Potvrdjeni akti:

- `NN 47/2009` (core)
- `NN 110/2021` (amandman)

Dodan je kontrolni zakon.hr link za usporedbu i validaciju JSON formata,
uz pravilo da primarni dokazni izvor ostaju Narodne novine.

Izradjen je:

- `paketi/PAKET_ZUP_V1.json`

Rezim rada ostaje:

- `PREKRSAJNI_ZAKON_MODEL`

Azurirana dokumentacija:

- `paketi/PAKET_ZUP_V1.json`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\\dokumentacija\\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\\alati\\ci_smoke.ps1`

## Datum: 27.03.2026 (ZADATAK 94 - stvarni ingest ZUP po manifestu)

Proveden je stvarni ingest paketa za
zakon_o_opcem_upravnom_postupku prema postojecem paketnom modelu.

Manifest i rezim:

- paketi/PAKET_ZUP_V1.json
- dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md

Tijekom prvog pokretanja ingest-a preflight je odbio vrijednost
tip_teksta=izvorni za required core akt jer prihvaca samo
procisceni ili amandmani.

Primijenjena je minimalna korekcija manifesta:

- tip_teksta za core akt promijenjen je u procisceni

Nakon korekcije, ponovljeni ingest je uspjesno zavrsio:

- required core akt: EXIT=0
- optional amandman akt: EXIT=0
- paketni ishod: Z94_INGEST_RERUN_EXIT=0

Dokazne naredbe:

- git status --short
- git --no-pager log -1 --oneline
- git branch -vv
- Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

## Datum: 27.03.2026 (ZADATAK 95 - kontrolna usporedba ZUP JSON sa zakon.hr)

Proveden je kontrolni dohvat sa zakon.hr za akt
zakon_o_opcem_upravnom_postupku.
Kontrolni sloj je izgradjen po istom modelu kontrole koji je koristen za
prekrsajni_zakon,
uz zadrzavanje pravila: NN je primarni dokazni izvor,
zakon.hr je kontrolni izvor.

Nastali kontrolni artefakti i izvjestaji:

- alati/izgradi_kontrolni_zakon_hr.py
- izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/
  zakon_o_opcem_upravnom_postupku_zakon_hr.html
- izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/
  zakon_o_opcem_upravnom_postupku_kontrolni.txt
- izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/meta.json
- izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/
  struktura_kontrolno_dokumenti.json
- baza_zakona/norme/zakon_o_opcem_upravnom_postupku_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md

Sazetak nalaza usporedbe:

- CONTROL_COUNT=171
- NN_COUNT=171
- MISSING_COUNT=0
- EXTRA_LIST: prazno
- postoje kratki/sumnjivo kratki clanci (SHORT_COUNT=15)
- prisutan je heuristicki signal CONTROL_TRUNCATION_SUSPECTED=True
- rezultat: djelomicno odstupanje / otvorena sanacija

Azurirana dokumentacija:

- dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
- dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md

## Datum: 27.03.2026 (ZADATAK 96 - ciljana sanacija kratkih ZUP clanaka)

Provedena je ciljana sanacija iskljucivo clanaka iz SHORT_LIST izvjestaja
`baza_zakona/norme/zakon_o_opcem_upravnom_postupku_procisceni/
IZVJESTAJ_VALIDACIJE_KONTROLNO.md` bez ponovnog ingest-a.

Sanirani clanci (15):

- 70, 96, 107, 109, 125, 132, 134, 136, 145, 149, 163, 164, 165, 168, 170

Primijenjene korekcije po clanku:

- uklonjen je vodeci ingest artefakt `". "`
- uklonjen je prijelazni naslov sljedece cjeline koji nije dio clanka
- preračunata su polja `integritet.sha256_teksta` i
  `integritet.sha256_datoteke`

Kontrolna revalidacija:

- alat: `alati/acceptance_preflight.ps1 -AktSlug`
  `zakon_o_opcem_upravnom_postupku`
- CONTROL_COUNT=171
- NN_COUNT=171
- MISSING_COUNT=0
- SHORT_COUNT=15
- CONTROL_TRUNCATION_SUSPECTED=True

Zakljucak:

- ciljane datoteke su sanirane od truncation artefakta
- SHORT_COUNT ostaje 15 jer su ti clanci sadrzajno kratki i nakon sanacije

Dokazne naredbe:

- git status --short
- powershell -NoProfile -ExecutionPolicy Bypass -File
  .\alati\acceptance_preflight.ps1 -AktSlug
  "zakon_o_opcem_upravnom_postupku"
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

## Datum: 27.03.2026 (ZADATAK 97 - uskladjenje statusa nakon Z96)

Provedeno je servisno uskladjenje statusnog dokumenta nakon Z96.

Utvrdeno stanje prije uskladjenja:

- statusni dokument je bio neusklađen po commit/hash tragu
- Z96 ostaje zadnji dovrseni zadatak

Primijenjeno uskladjenje:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` je poravnat sa stvarnim
  stanjem repoa
- `Trenutni commit` i `lokalni hash` uskladjeni su na stvarni zadnji
  commit nakon Z96
- odredjen je sljedeci logicki korak nakon Z96:
  revizija heuristike i/ili dodatna sanacija za preostali
  `SHORT_COUNT=15` i `CONTROL_TRUNCATION_SUSPECTED=True`

Napomena:

- nema novih operativnih promjena na ZUP setu
- ingest, validator i heuristika nisu mijenjani u ovom zadatku

Dokazne naredbe:

- git status --short
- git --no-pager log -1 --oneline
- git branch -vv
- Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

## Datum: 27.03.2026 (ZADATAK 98 - revizija heuristike validacije ZUP kontrole)

Analiziran je preostali `SHORT_COUNT=15` i signal
`CONTROL_TRUNCATION_SUSPECTED=True` za ZUP.

Analiza je pokazala da su kratki clanci legitimno kratki po normativnom
sadrzaju, a da je truncation signal bio lazno pozitivan zbog heuristike koja
je tretirala prisutnost 12/13/14 kao sumnju i kad su to regularni clanci.

U ovom zadatku mijenjan je i kod:

- `alati/validiraj_nn_vs_kontrolno.py` (minimalna revizija heuristike)

Ponovna validacija nakon revizije:

- CONTROL_COUNT=171
- NN_COUNT=171
- MISSING_COUNT=0
- SHORT_COUNT=15
- CONTROL_TRUNCATION_SUSPECTED=False

Azurirana dokumentacija:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` nije mijenjana

Dokazne naredbe:

- git status --short
- git --no-pager log -1 --oneline
- git branch -vv
- c:/Veritas_H77/.venv/Scripts/python.exe
  .\alati\validiraj_nn_vs_kontrolno.py
  -AktSlug zakon_o_opcem_upravnom_postupku
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

## Datum: 27.03.2026 (ZADATAK 99 - utvrdjen rezim konverzije ZUS u JSON)

### Sažetak
Utvrdjen je kanonski rezim konverzije za `zakon_o_upravnim_sporovima` i
dokumentiran u `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`.
Deterministicka provjera NN pretrage nije dala eksplicitan dokaz valjanog
prociscenog ulaza, pa je odabran model kao za `prekrsajni_zakon`.

### Odluka rezima
REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL

### Ažurirani dokumenti
- `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`

### Verifikacija
- `alati/lint_markdown.ps1` -> `MDLINT_EXIT=0`
- `alati/ci_smoke.ps1` -> `CI_SMOKE_EXIT=0`
