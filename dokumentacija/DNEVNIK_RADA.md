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
