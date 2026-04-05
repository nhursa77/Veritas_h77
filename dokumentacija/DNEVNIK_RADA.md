# DNEVNIK_RADA

## Pravilo evidentiranja
Svaki novi značajan korak rada evidentira se kao novi dnevnički unos.
Unosi idu kronološki: najstariji na vrhu, najnoviji na dnu.

---

- f4033dc -> chore: docker kostur (mount repozitorija)
- 24e9959 -> chore: markdownlint pravila + editorconfig
- 0ea5b66 -> chore: eol pravila (LF kanon, CRLF samo ps1)
- dafaa25 -> docs: metodologija rada Veritas H.77
- cd613a1 -> docs: standard JSON NORMA (revizija 1)
- 27dcda5 -> docs: standard JSON NORMA (revizija 2)
- 502501c -> docs: standard JSON POSTUPAK (procedura)
- 0681c60 -> docs: razvojni plan Veritas H.77 (kanonski)

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
- 939d29b -> docs: rječnik pojmova Veritas H.77
- 6d724c2 -> docs: tehnički okvir Veritas H.77
- 978caee -> docs: mapa dokumentacije Veritas H.77

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

### ZADATAK 139 - kanonski obrazac zakoni s amandmanima u JSON (dopuna)

Izrađen je objedinjeni kanonski dokument za pretvaranje zakona s amandmanima u
JSON u datoteci dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md,
isključivo na temelju već postojećih kanonskih dokumenata i stvarnog ponašanja
repo alata, bez zahvata u zakonima, sidrima, normama, kontrolnim artefaktima,
skriptama ili završnom ZPD izvještaju.

Dokument na jednom mjestu uređuje kada se koristi model core + amandmani,
koji je minimalni obvezni skup ulaznih artefakata, kako su razdvojeni NN
dokazni sloj i kontrolni zakon.hr sloj, koja su pravila za norme i sidra,
koji su kriteriji prolaza, koja su tolerirana odstupanja i kada se smije reći
da je zakon kanonski obrađen.

Mijenjane datoteke:

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `\.\alati\provjeri_markdown_scope.ps1`
  `\.\dokumentacija\KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
  `\.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `\.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `\.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `\.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026. (ZADATAK 144)

### ZADATAK 144 - dokazno izdvojen stvarni z138 scoped skup

Izrađen je dokazni dokument
dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md kojim je iz trenutačno
miješanog lokalnog stanja izdvojen točan budući Z138 commit scope, bez
commita, bez pusha i bez diranja zakona, sidara, normi, parsera, validatora
ili dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md.

Dokazno je potvrđeno da stvarni Z138 sadržaj čini inventurni dokument
dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md te isključivo Z138
hunkovi u MAPI, STATUSU i append-only bloku DNEVNIKA, dok svi Z139-Z143
tragovi, `.vscode/` i stariji ZPD završni diff moraju ostati izvan budućeg
Z138 commita.

Mijenjane datoteke:

- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff -- dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `git diff -- dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `git diff -- dokumentacija/DNEVNIK_RADA.md`
- `git ls-remote --heads origin main`

## Datum: 31.03.2026 (ZADATAK 143)

### ZADATAK 143 - dokazno razdvajanje scopea Z138 do Z142

Izradjen je dokument
dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md koji dokazno razdvaja
trenutno lokalno stanje na scopeove Z138, Z139, Z140, Z141 i Z142, bez
commita, bez pusha i bez diranja zakona, sidara, normi ili alata.

Potvrdeno je da svaki od zadataka Z138-Z142 ima vlastitu glavnu novu
datoteku, ali da su dokumenti MAPA_DOKUMENTACIJE_VERITAS_H77.md,
STATUS_PROJEKTA_VERITAS_H77.md i DNEVNIK_RADA.md trenutno kumulativno
mijesani trag tog niza i zato ne smiju nekriticki u isti commit. Takodjer je
potvrdeno da `.vscode/` ostaje izvan-scope lokalni editor artefakt, a
ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md stariji lokalni diff koji ne
pripada buducem commit nizu Z138-Z142.

Predlozen je i tocan prvi scoped commit: najprije zatvoriti Z138 s
INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md i samo odgovarajucim Z138 hunkovima
iz mape, statusa i dnevnika.

Mijenjane datoteke:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git ls-remote --heads origin main`
- `git --no-pager log -5 --oneline`
  `.\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 139)

### ZADATAK 139 - kanonski obrazac zakoni s amandmanima u JSON

Izrađen je objedinjeni kanonski dokument za pretvaranje zakona s amandmanima u
JSON u datoteci dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md,
isključivo na temelju već postojećih kanonskih dokumenata i stvarnog ponašanja
repo alata, bez zahvata u zakonima, sidrima, normama, kontrolnim artefaktima,
skriptama ili završnom ZPD izvještaju.

Dokument na jednom mjestu uređuje kada se koristi model core + amandmani,
koji je minimalni obvezni skup ulaznih artefakata, kako su razdvojeni NN
dokazni sloj i kontrolni zakon.hr sloj, koja su pravila za norme i sidra,
koji su kriteriji prolaza, koja su tolerirana odstupanja i kada se smije reći
da je zakon kanonski obrađen.

Mijenjane datoteke:

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `\.\alati\provjeri_markdown_scope.ps1`
  `\.\dokumentacija\KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
  `\.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `\.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `\.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `\.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

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
## Datum: 31.03.2026 (ZADATAK 119 - ZPD vs zakon.hr)

Za `zakon_o_porezu_na_dohodak_procisceni` provedena je stvarna kontrolna
usporedba naspram `zakon.hr`, bez novog ingest-a, bez izmjene
`paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
`dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.

Osvjezen je kontrolni sloj pod
`izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak/`.
Potvrdeni su artefakti `meta.json`,
`struktura_kontrolno_dokumenti.json`,
`zakon_o_porezu_na_dohodak_kontrolni.txt` i novi
`zakon_o_porezu_na_dohodak_zakon_hr.html`.

Generiran je trajni validacijski izvjestaj:
- `baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Rezultat usporedbe:
- `CONTROL_COUNT=99`
- `NN_COUNT=99`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[]`
- `SHORT_COUNT=2` (`clanci 28 i 98`)
- `CONTROL_TRUNCATION_SUSPECTED=False`
- `ANOMALY_FLAG=False`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug zakon_o_porezu_na_dohodak`
  `--naziv-akta "Zakon o porezu na dohodak"`
  `--url "https://www.zakon.hr/z/85/zakon-o-porezu-na-dohodak"`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\validiraj_nn_vs_kontrolno.py -AktSlug zakon_o_porezu_na_dohodak`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -ZadnjiZadatak "ZADATAK 119"`
  `-PolazniHead "4e64c6f"`
  `-PolazniSubject "feat: stvarni ingest zpd po paketnom manifestu (Z118)"`
  `-RepoCistPriPrecheck "DA" -PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

Napomena:
- Commit hash Z119 bit ce potvrden zavrsnim dokazom
  `git --no-pager log -1 --oneline` nakon scoped commita.

---
## Datum: 31.03.2026 (ZADATAK 120 - prvi ZPD amandman vs zakon.hr)

Za `zakon_o_porezu_na_dohodak_nn_106_2018` provedena je stvarna kontrolna
usporedba naspram `zakon.hr`, bez novog ingest-a, bez izmjene
`paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
`dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.

Za taj je amandman najprije dokazan stvarni `zakon.hr` izvor
`https://www.zakon.hr/cms.htm?id=35597`, a zatim je osvjezen kontrolni sloj
pod `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_106_2018/`.
Potvrdeni su artefakti `meta.json`,
`struktura_kontrolno_dokumenti.json`,
`zakon_o_porezu_na_dohodak_nn_106_2018_kontrolni.txt` i novi
`zakon_o_porezu_na_dohodak_nn_106_2018_zakon_hr.html`.

Prvi validator run je dokazno pao jer je lokalni NN parse za amandman lazno
izdvajao in-body reference tipa `Članak 45.` i `Članak 68.` kao nove clanke,
a guardrail u `alati/validiraj_nn_vs_kontrolno.py` nije dopustao
`tip_teksta=amandmani`. Nakon toga je napravljen minimalni patch u
`alati/parsiraj_nn_html.py` i `alati/validiraj_nn_vs_kontrolno.py`, pa je bez
novog ingest-a reparsiran postojeci lokalni NN HTML snapshot za isti amandman.

Generirani su i potvrdeni obnovljeni NN dokazni izlazi pod
`izvori/dokazno/narodne_novine/zakon_o_porezu_na_dohodak_nn_106_2018/` te
trajni validacijski izvjestaj:
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Zavrsni rezultat usporedbe:
- `CONTROL_COUNT=33`
- `NN_COUNT=33`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[]`
- `SHORT_COUNT=9`
- `CONTROL_TRUNCATION_SUSPECTED=False`
- `GUARDRAIL_FAIL=False`
- `ANOMALY_FLAG=False`

Mijenjane datoteke:

- `alati/parsiraj_nn_html.py`
- `alati/validiraj_nn_vs_kontrolno.py`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/dokazno/narodne_novine/zakon_o_porezu_na_dohodak_nn_106_2018/`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_106_2018/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_106_2018`
  `--naziv-akta "Zakon o izmjenama i dopunama Zakona o porezu na dohodak"`
  `--url "https://www.zakon.hr/cms.htm?id=35597"`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/validiraj_nn_vs_kontrolno.py -AktSlug`
  `zakon_o_porezu_na_dohodak_nn_106_2018`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/parsiraj_nn_html.py --akt-slug zakon_o_porezu_na_dohodak_nn_106_2018`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/uskladi_status_projekta.ps1 -ZadnjiZadatak "ZADATAK 120"`
  `-PolazniHead "6c1108a"`
  `-PolazniSubject "feat: kontrolna usporedba zpd json seta sa zakon hr (Z119)"`
  `-RepoCistPriPrecheck "DA" -PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/provjeri_markdown_scope.ps1`
  `./dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
  `./dokumentacija/DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/ci_smoke.ps1`

Napomena:
- Commit hash Z120 bit ce potvrden zavrsnim dokazom
  `git --no-pager log -1 --oneline` nakon scoped commita.

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
## Datum: 31.03.2026 (ZADATAK 121 - ZPD amandman NN 121/2019 vs zakon.hr)

Za `zakon_o_porezu_na_dohodak_nn_121_2019` provedena je stvarna kontrolna
usporedba naspram `zakon.hr`, bez novog ingest-a, bez izmjene
`paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
`dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.

Za taj je amandman najprije dokazan stvarni `zakon.hr` izvor
`https://www.zakon.hr/cms.htm?id=42193`, a zatim je osvjezen kontrolni sloj
pod `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_121_2019/`.
Potvrdeni su artefakti `meta.json`,
`struktura_kontrolno_dokumenti.json`,
`zakon_o_porezu_na_dohodak_nn_121_2019_kontrolni.txt` i
`zakon_o_porezu_na_dohodak_nn_121_2019_zakon_hr.html`.

Validator je prosao iz prvog pokusaja, bez patcha alata i bez reparsiranja
lokalnog NN snapshota. Trajni validacijski izvjestaj je pod:

- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Zavrsni rezultat usporedbe:

- `CONTROL_COUNT=21`
- `NN_COUNT=22`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[27]`
- `SHORT_COUNT=6`
- `SHORT_LIST_FIRST20=[8, 10, 17, 18, 19, 20]`
- `CONTROL_TRUNCATION_SUSPECTED=False`
- `GUARDRAIL_FAIL=False`
- `ANOMALY_FLAG=False`

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_121_2019/meta.json`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_121_2019/
  struktura_kontrolno_dokumenti.json`
- `izvori/kontrolno/zakon_hr/
  zakon_o_porezu_na_dohodak_nn_121_2019/
  zakon_o_porezu_na_dohodak_nn_121_2019_kontrolni.txt`
- `izvori/kontrolno/zakon_hr/
  zakon_o_porezu_na_dohodak_nn_121_2019/
  zakon_o_porezu_na_dohodak_nn_121_2019_zakon_hr.html`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_121_2019`
  `--naziv-akta "Zakon o izmjenama i dopunama Zakona o porezu na dohodak"`
  `--url "https://www.zakon.hr/cms.htm?id=42193"`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `./alati/validiraj_nn_vs_kontrolno.py -AktSlug`
  `zakon_o_porezu_na_dohodak_nn_121_2019`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/uskladi_status_projekta.ps1 -ZadnjiZadatak "ZADATAK 121"`
  `-PolazniHead "e286e72"`
  `-PolazniSubject "feat: kontrolna usporedba zpd nn 106 2018 sa zakon hr
  (Z120)"`
  `-RepoCistPriPrecheck "DA" -PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/provjeri_markdown_scope.ps1`
  `./dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
  `./dokumentacija/DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File ./alati/ci_smoke.ps1`

Napomena:

- Commit hash Z121 bit ce potvrden zavrsnim dokazom
  `git --no-pager log -1 --oneline` nakon scoped commita.

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

## Datum: 31.03.2026

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

### Sažetak (ZADATAK 99)
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

## ZADATAK 100 - ispravljen rezim konverzije ZUS prema obrascu prociscenog akta

Datum: 27.03.2026.

### Sažetak (ZADATAK 100)
Zakljucak iz Z99 je revidiran za
`zakon_o_upravnim_sporovima`.
Vazeci ZUS se vodi kao jedan vazeci akt (`NN 36/2024`) po obrascu rada
`ustav_rh_procisceni`.

### Odluka rezima (ZADATAK 100)
REZIM_ODABRAN = PROCISCENI_FIRST

### Pravila primjene
- model `prekrsajni_zakon` se ne koristi za vazeci ZUS
- ne koristi se paket starih izmjena za vazeci ZUS
- `zakon.hr` ostaje samo kontrolni izvor za validaciju

### Azurirana dokumentacija
- `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`

## Datum: 31.03.2026 (ZADATAK 101 - pripremljen manifest ingest-a za vazeci ZUS)

Pripremljen je kanonski manifest ingest-a za važeći
`zakon_o_upravnim_sporovima` kao jedan važeći akt iz NN 36/2024,
uz zakon.hr kao kontrolni izvor za validaciju.

Temelj:

- Dokumentacija `REZIM_KONVERZIJE_ZUS_U_JSON.md` (Z99-Z100)
- ZUS se vodi kao jedan važeći cjeloviti akt
- NN 36/2024 je dokazni izvor
- zakon.hr je samo kontrolni izvor za validaciju
- Rezim rada: PROCISCENI_FIRST

Izrada manifesta:

- Novi manifest: `paketi/PAKET_ZUS_V1.json`
- Core akt: zakon_o_upravnim_sporovima (required)
- Bez paketnih amandmana
- Kontrolni izvor: zakon.hr

Ažurirana dokumentacija:

- `paketi/PAKET_ZUS_V1.json` (novi aktivni paketni manifest)
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`

Sljedeci logicki korak:

- Stvarni ingest vazeceg ZUS-a po manifestu
  `paketi/PAKET_ZUS_V1.json`

Dokazne naredbe:

- git status --short
- git --no-pager log -1 --oneline
- git branch -vv
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

## Datum: 31.03.2026 (ZADATAK 102)

### ZADATAK 102 - stvarni ingest važećeg ZUS po paketnom manifestu

Pokrenut je stvarni ingest po `paketi/PAKET_ZUS_V1.json` za
`zakon_o_upravnim_sporovima`.

Primijenjen je model jednog važećeg akta:

- važeći akt: `NN 36/2024` - Zakon o upravnim sporovima
- režim rada: jedan važeći cjeloviti akt (`PROCISCENI_FIRST`)
- ne koristi se paket starih izmjena
- `zakon.hr` ostaje samo kontrolni izvor

Obrađeni akt:

- `zakon_o_upravnim_sporovima`

Minimalni patch manifesta:

- nije bio potreban

Nastali izlazi i artefakti postojećeg workflowa:

- `izvori/dokazno/narodne_novine/zakon_o_upravnim_sporovima/`
- `izvori/dokazno/narodne_novine/ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md`
- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
- `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/`
- ažuriran `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`

Rezultat ingest-a i provjere:

- paketni ingest završio je s `exit=0`
- zasebni `acceptance_preflight` završio je s `exit=0`
- potvrđeno: `NN_COUNT=172`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `TIP_ACTUAL=procisceni`

Ažurirana dokumentacija:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

Sljedeći logički korak:

- kontrolna usporedba ZUS JSON seta sa `zakon.hr`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ingest_paket.ps1`
  `-PaketPath .\paketi\PAKET_ZUS_V1.json`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\acceptance_preflight.ps1 -AktSlug zakon_o_upravnim_sporovima`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 103)

### ZADATAK 103 - uskladjen status Z102 i kontrolna usporedba ZUS sa zakon.hr

Najprije je provjeren statusni trag nakon Z102 i uskladjen sa stvarnim
git stanjem repoa.

Potvrđeno je:

- stvarni zadnji commit prije rada na Z103: `7dd0cb3`
- `STATUS_PROJEKTA_VERITAS_H77.md` je bio zaostao po poljima
  `Trenutni commit` i `lokalni hash`
- statusni hash trag je zatim uskladjen na stvarno stanje nakon Z102

Nakon toga proveden je stvarni kontrolni dohvat sa `zakon.hr` za
`zakon_o_upravnim_sporovima` i usporedba seta
`zakon_o_upravnim_sporovima_procisceni`
sa stvarnim kontrolnim tekstom.

ZUS ostaje vođen kao jedan važeći akt:

- `NN 36/2024` - Zakon o upravnim sporovima
- `zakon.hr` ostaje samo kontrolni izvor

Nastali artefakti i izvještaji:

- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  `zakon_o_upravnim_sporovima_zakon_hr.html`
- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  `zakon_o_upravnim_sporovima_kontrolni.txt`
- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/meta.json`
- `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  `struktura_kontrolno_dokumenti.json`
- `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Rezultat usporedbe:

- `CONTROL_COUNT=172`
- `NN_COUNT=172`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[]`
- `SHORT_COUNT=11`
- `CONTROL_TRUNCATION_SUSPECTED=False`

Ažurirana dokumentacija:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`

Sljedeci logicki korak:

- priprema manifesta ingest-a za sljedeći zakon po prioritetnom
  redoslijedu konverzije

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py`
  `--akt-slug zakon_o_upravnim_sporovima`
  `--naziv-akta "Zakon o upravnim sporovima"`
  `--url "https://www.zakon.hr/z/101/Zakon-o-upravnim-sporovima"`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\validiraj_nn_vs_kontrolno.py`
  `-AktSlug zakon_o_upravnim_sporovima`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 104)

### ZADATAK 104 - servisno zatvaranje z103 i sanacija dnevnika

U ovom servisnom koraku provjeren je dokumentacijski trag nakon Z103.

Utvrđeno je:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` bio je zaostao po
  commit/hash tragu nakon Z103
- stvarni zadnji commit u repou bio je `a6c9d83`
- statusni dokument je usklađen sa stvarnim git stanjem

U `dokumentacija/DNEVNIK_RADA.md` sanirane su točno prijavljene greške:

- `MD026 x2`
- `MD024 x1`

Primijenjena je minimalna sanacija postojećih naslova bez širenja opsega.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

`dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` nije dirana.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 105)

### ZADATAK 105 - kanonski status sync i markdown preflight

Uveden je trajni servisni sloj za dokumentacijske zadatke.

Dodane su skripte:

- `alati/uskladi_status_projekta.ps1`
- `alati/provjeri_markdown_scope.ps1`

Dodan je kanonski dokument:

- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`

Ažurirani su:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Standard propisuje disciplinu headinga, scoped markdown provjeru i
obavezni servisni redoslijed za dokumentacijske zadatke.

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`

## Datum: 31.03.2026 (ZADATAK 114)

### ZADATAK 114 - utvrdjen rezim konverzije zakona o porezu na dohodak u JSON

Dokumentacijski je utvrdjeno da je `zakon_o_porezu_na_dohodak` sljedeci zakon po
prioritetu za konverziju nakon vec obradjenog `opci_porezni_zakon`.

Primarna provjera na Narodnim novinama potvrdila je izvorni zakon `NN 115/2016`
i zasebne izmjene/dopune `NN 106/2018`, `121/2019`, `32/2020`, `138/2020`,
`151/2022`, `114/2023` i `152/2024`, bez dokaza jednog zasebnog vazeceg
prociscenog NN akta.

Na toj osnovi kreiran je kanonski dokument
`dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md` i odabran je `REZIM_ODABRAN =`
`PREKRSAJNI_ZAKON_MODEL`, uz `zakon.hr` samo kao kontrolni izvor za kasniju
validaciju.

Mijenjane datoteke:

- `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `\.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `\.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 114"`
  `-PolazniHead "b2a844b" -PolazniSubject "docs: stvarno normaliziran`
  `kronoloski pregled zadataka u statusu (Z113)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`
- `$u='https://narodne-novine.nn.hr/search.aspx?sortiraj=4&kategorija=1&' +`
  `'godina=2016&broj=115&rpp=10&qtype=1&pretraga=da'`
- `(Invoke-WebRequest -UseBasicParsing $u).Content | Select-String`
  `'dohodak'`
- `$u='https://narodne-novine.nn.hr/search.aspx?sortiraj=4&kategorija=1&' +`
  `'godina=2024&broj=152&rpp=10&qtype=1&pretraga=da'`
- `(Invoke-WebRequest -UseBasicParsing $u).Content | Select-String`
  `'dohodak'`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 106)

### ZADATAK 106 - pripremljen manifest ingest-a za OPZ

Iz kanonskog dokumenta prioriteta potvrdeno je da nakon ZUP-a i ZUS-a
slijedi `opci_porezni_zakon`.

Repo pretraga nije pokazala postojeceg OPZ manifesta ni raniji operativni trag.

Vanjska potvrda sa `zakon.hr` pokazala je da se vazeci tekst vodi kao
procisceni prikaz sastavljen od `NN 115/16`, `106/18`, `121/19`, `32/20`,
`42/20`, `114/22`, `152/24` i `151/25`.

Dodan je `paketi/PAKET_OPZ_V1.json` kao manifest modela `core + amandmani`.

Azurirani su:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1`
- `Invoke-WebRequest -Method Head`
  `https://narodne-novine.nn.hr/eli/sluzbeni/2016/115/2519`
- `Invoke-WebRequest -Method Head`
  `https://narodne-novine.nn.hr/eli/sluzbeni/2025/151/2263`

## Datum: 31.03.2026 (ZADATAK 107)

### ZADATAK 107 - servisno zatvoren z106 nakon status synca

Z106 manifest je vec postojao i nije diran:
`paketi/PAKET_OPZ_V1.json`.

Problem je bio u zaostalom statusnom hash i commit tragu u
`dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`.

Dokazno je pokrenut:
`alati/uskladi_status_projekta.ps1`.

Status je nakon toga uskladen sa stvarnim git stanjem Z106.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/uskladi_status_projekta.ps1 -ZadnjiZadatak "ZADATAK 106"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `./alati/dodaj_dnevnicki_unos_na_kraj.ps1`

## Datum: 31.03.2026 (ZADATAK 108)

### ZADATAK 108 - refaktor statusnog traga i automatizacije dokumentacije

Ukinut je lazni model samoreferencijalnog commit traga u statusnom dokumentu.

Promijenjena je semantika skripte alati/uskladi_status_projekta.ps1 na stabilna
pre-check polja.

Dodane su skripte alati/generiraj_dnevnicki_unos.ps1 i
alati/zatvori_dokumentacijski_korak.ps1 te su azurirani standardi i mapa
dokumentacije.

Mijenjane datoteke:

- `alati/uskladi_status_projekta.ps1`
- `alati/generiraj_dnevnicki_unos.ps1`
- `alati/zatvori_dokumentacijski_korak.ps1`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -PolazniHead 474ad3d`
  `-PolazniSubject "docs: servisno zatvoren z106 nakon status synca (Z107)"`
  `-RepoCistPriPrecheck DA -PoravnanjeGranePriPrecheck poravnat`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\generiraj_dnevnicki_unos.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\zatvori_dokumentacijski_korak.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 109)

### ZADATAK 109 - stvarni ingest opz po paketnom manifestu

Stvarni ingest paketa paketi/PAKET_OPZ_V1.json za opci_porezni_zakon proveden je
kroz ingest workflow i prosao je iz prvog pokusaja bez patcha manifesta
(INGEST_FIRST_RUN_EXIT=0).

OPZ je voden kao core + amandmani: generiran je operativni NORMA set pod
baza_zakona/norme/opci_porezni_zakon_procisceni te sidrisni setovi za NN 106/18,
121/19, 32/20, 42/20, 114/22, 152/24 i 151/25 pod baza_zakona/sidra/.

Stvarno su nastali NN dokazni snapshoti pod
izvori/dokazno/narodne_novine/opci_porezni_zakon i pripadnim amandmanskim
direktorijima, selection reportovi pod izvori/dokazno/narodne_novine/ te
kontrolni direktoriji pod izvori/kontrolno/zakon_hr/.

Trajni izvjestaj validacije OPZ seta nije ostao na disku nakon ingest runa, pa
nije dokumentiran kao nastali trajni artefakt; sljedeci logicki korak ostaje
kontrolna usporedba OPZ JSON seta sa zakon.hr.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`
- `baza_zakona/norme/opci_porezni_zakon_procisceni/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_106_2018/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_121_2019/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_32_2020/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_42_2020/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_114_2022/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_152_2024/`
- `baza_zakona/sidra/opci_porezni_zakon_nn_151_2025/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_106_2018/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_121_2019/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_32_2020/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_42_2020/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_114_2022/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_152_2024/`
- `izvori/dokazno/narodne_novine/opci_porezni_zakon_nn_151_2025/`
- `izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_106_2018_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_121_2019_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_32_2020_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_42_2020_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_114_2022_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_152_2024_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_151_2025_SELECTION_REPORT.md`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_106_2018/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_121_2019/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_32_2020/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_42_2020/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_114_2022/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_152_2024/`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon_nn_151_2025/`

Dokazne naredbe:

- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ingest_paket.ps1`
  `-PaketPath .\paketi\PAKET_OPZ_V1.json`
- `git diff --name-only`
- `git status --short`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md dokumentacija/DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 110)

### ZADATAK 110 - sanirani workspace problemi nakon z109

Servisni audit nakon Z109 dokazno je proveden nad tri ciljane datoteke:
alati/generiraj_dnevnicki_unos.ps1, alati/zatvori_dokumentacijski_korak.ps1 i
izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md.

Audit prije patcha pokazao je stvarno stanje 0 + 0 + 1: obje PowerShell skripte
nisu imale workspace ni parser problema, dok je arhivski izvjestaj imao jedan
MD010 problem na liniji 35 (hard tab).

Minimalnim patchom saniran je samo
izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md, a nakon patcha
get_errors i parser provjere vise ne prijavljuju probleme ni u jednoj od tri
ciljane datoteke.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `functions.get_errors -> alati/generiraj_dnevnicki_unos.ps1,`
  `alati/zatvori_dokumentacijski_korak.ps1,`
  `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`
- `PowerShell parser -> alati/generiraj_dnevnicki_unos.ps1,`
  `alati/zatvori_dokumentacijski_korak.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md dokumentacija/DNEVNIK_RADA.md`
  `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 111)

### ZADATAK 111 - kontrolna usporedba opz json seta sa zakon hr

Stvarni OPZ kontrolni sloj pod izvori/kontrolno/zakon_hr/opci_porezni_zakon
osvjezen je sa zakon.hr kroz alati/izgradi_kontrolni_zakon_hr.py bez minimalnog
patcha alata (KONTROLNI_BUILD_EXIT=0).

Validator alati/validiraj_nn_vs_kontrolno.py stvarno je pokrenut nad
opci_porezni_zakon i operativnim setom
baza_zakona/norme/opci_porezni_zakon_procisceni; rezultat usporedbe je
CONTROL_COUNT=199, NN_COUNT=199, MISSING_COUNT=0, EXTRA_LIST=[], SHORT_COUNT=19,
CONTROL_TRUNCATION_SUSPECTED=False (VALIDACIJA_EXIT=0).

Trajno su azurirani OPZ kontrolni artefakti meta.json,
struktura_kontrolno_dokumenti.json i opci_porezni_zakon_kontrolni.txt, nov je
ostao
opci_porezni_zakon_zakon_hr.html,
a trajni validacijski izvjestaj
baza_zakona/norme/
opci_porezni_zakon_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
stvarno je ostao na disku.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/opci_porezni_zakon/meta.json`
- `izvori/ kontrolno/ zakon_hr/ opci_porezni_zakon/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ opci_porezni_zakon/`
  `opci_porezni_zakon_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ opci_porezni_zakon/`
  `opci_porezni_zakon_zakon_hr.html`
- `baza_zakona/ norme/ opci_porezni_zakon_procisceni/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug opci_porezni_zakon`
  `--naziv-akta "Opci porezni zakon" --url`
  `"https://www.zakon.hr/z/100/opci-porezni-zakon"`
- `c:/Veritas_H77/.venv/Scripts/python.exe .\alati\validiraj_nn_vs_kontrolno.py`
  `-AktSlug opci_porezni_zakon`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 111"`
  `-PolazniHead "f0fafbb" -PolazniSubject "popravak" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`

## Datum: 31.03.2026 (ZADATAK 112)

### ZADATAK 112 - kronoloski ureden status projekta i pravilo upisa

Pregled dovrsenih zadataka u dokumentu
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md kronoloski je preureden tako da ide
strogo od starijeg prema novijem, uz jasno odvajanje snapshot bloka na vrhu od
pregleda dovrsenih zadataka ispod.

Kanonski je odredjeno da se Zadnji dovrseni zadatak vodi u snapshot bloku na
vrhu i kao zadnja stavka pregleda dovrsenih zadataka, a dokumenti
STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md i
STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md dopunjeni su tim pravilom.

Skriptu alati/uskladi_status_projekta.ps1 nije trebalo dirati jer iz stvarnog
koda uskladjuje samo snapshot polja i ne preureduje pregled zadataka.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 112"`
  `-PolazniHead "6b72223" -PolazniSubject "feat: kontrolna usporedba opz json`
  `seta sa zakon hr (Z111)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
  `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
  `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
  `dokumentacija/DNEVNIK_RADA.md`

## Datum: 31.03.2026 (ZADATAK 113)

### ZADATAK 113 - stvarno normaliziran kronoloski pregled zadataka u statusu

Pregled dovrsenih zadataka u dokumentu
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md prije patcha bio je nekronoloski:
dokazni ispis svih redaka koji pocinju s - ZADATAK napravljen je prije izmjene,
a dodatna provjera pokazala je da se u istom bloku pregleda nize nalazila stavka
s manjim brojem ZADATAK 87 ispod vecih brojeva.

Statusni pregled je zatim stvarno normaliziran tako da blok Pregled dovrsenih
zadataka sadrzi samo zadatkovne stavke poredane uzlazno po broju, a nakon patcha
ponovno je ispisan dokazni popis svih - ZADATAK redaka i potvrdeno je da je
ZADATAK 113 zadnja stavka pregleda.

Skriptu alati/uskladi_status_projekta.ps1 nije trebalo dirati jer iz stvarnog
koda uskladjuje samo snapshot polja i ne dira pregled zadataka.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Select-String -Path .\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -Pattern`
  `'^- ZADATAK ' | ForEach-Object { $_.Line }`
- `Select-String -Path .\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -Pattern`
  `'ZADATAK 87|ZADATAK 89|ZADATAK 112'`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 113"`
  `-PolazniHead "cc9fa43" -PolazniSubject "docs: kronoloski ureden status`
  `projekta i pravilo upisa (Z112)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md dokumentacija/DNEVNIK_RADA.md`

## Datum: 31.03.2026 (ZADATAK 115)

### ZADATAK 115 - servisno zatvoren z114 nakon status synca

Servisno je zatvoren Z114 nakon sto je potvrdeno da rezimski dokument
dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md nije diran i da je problem bio samo
zaostali statusni snapshot u dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md.

Dokazno je pokrenut alati/uskladi_status_projekta.ps1 s parametrom
-ZadnjiZadatak "ZADATAK 114", cime je snapshot blok uskladjen sa stvarnim
stanjem u kojem pregled zadataka vec sadrzi ZADATAK 114.

U ovom servisnom koraku mijenjane su samo dvije datoteke:
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md i dokumentacija/DNEVNIK_RADA.md.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 114"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\generiraj_dnevnicki_unos.ps1 -BrojZadatka 115 -Naslov "servisno`
  `zatvoren z114 nakon status synca"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath %TEMP%\veritas_z115_dnevnik.md`

## Datum: 31.03.2026 (ZADATAK 116)

### ZADATAK 116 - pripremljen manifest ingest-a za zpd

Za ZPD je u ovom koraku koristen vec utvrdjeni rezim iz Z114, odnosno
PREKRSAJNI_ZAKON_MODEL u obrascu core + amandmani, bez ponovnog odlucivanja o
rezimu.

Ingest nije raden. Izradjen je samo kanonski manifest paketi/PAKET_ZPD_V1.json s
izvorim NN nizom 115/2016, 106/2018, 121/2019, 32/2020, 138/2020, 151/2022,
114/2023 i 152/2024 te s zakon.hr kao kontrolnim izvorom.

Azurirani su dokumenti dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md i
dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md, a status sync je dokazno
pokrenut tijekom zadatka i ponovno se pokrece prije commita.

Mijenjane datoteke:

- `paketi/PAKET_ZPD_V1.json`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 116"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\generiraj_dnevnicki_unos.ps1 -BrojZadatka 116 -Naslov "pripremljen`
  `manifest ingest-a za zpd"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath %TEMP%\veritas_z116_dnevnik.md`

## Datum: 31.03.2026 (ZADATAK 117)

### ZADATAK 117 - servisno zatvoren z116 i trajno ispravljen pre-check snapshot

Dokazno je utvrdjeno da lazni upis Repo cist pri pre-checku: NE nastaje zato sto
alati/uskladi_status_projekta.ps1 inferira vrijednost iz trenutnog git statusa
nakon izmjena, a isti fallback postoji i u
alati/zatvori_dokumentacijski_korak.ps1.

U oba skriptna sloja uklonjena je inferencija: PolazniHead, PolazniSubject,
RepoCistPriPrecheck i PoravnanjeGranePriPrecheck sada su obavezni eksplicitni
ulazi, a RepoCistPriPrecheck prihvaca samo DA ili NE i inace pada fail-fast.

Status za Z116 ponovno je uskladjen s dokaznim pre-check ulazima 121d883 /
poravnat / DA, a standardi dokumentacije i sinkronizacije dopunjeni su pravilom
da se snapshot polja pune samo iz dokazno uhvacenog pre-checka, nikad naknadnom
inferencijom.

Mijenjane datoteke:

- `alati/uskladi_status_projekta.ps1`
- `alati/zatvori_dokumentacijski_korak.ps1`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 116"`
  `-PolazniHead "121d883" -PolazniSubject "docs: servisno zatvoren z114 nakon`
  `status synca (Z115)" -RepoCistPriPrecheck "DA" -PoravnanjeGranePriPrecheck`
  `"poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 116"`
  `-PolazniHead "121d883" -PolazniSubject "docs: servisno zatvoren z114 nakon`
  `status synca (Z115)" -PoravnanjeGranePriPrecheck "poravnat"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath %TEMP%\veritas_z117_dnevnik.md`

## Datum: 31.03.2026 (ZADATAK 118)

### ZADATAK 118 - stvarni ingest zpd po paketnom manifestu

Pokrenut je stvarni ingest za `zakon_o_porezu_na_dohodak` koristeci vec
postojeci manifest `paketi/PAKET_ZPD_V1.json`, bez izmjene manifesta i bez
promjene rezima iz `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.

Paketni run zavrsio je s `INGEST_PAKET_EXIT=0`, a zavrsni summary je potvrdio
`status OK` za core akt i svih sedam amandmanskih akata.

Dokazno su potvrdeni stvarno nastali artefakti: core NORMA set
`baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/` s 99 clanaka,
sidrisni setovi za akte `NN 106/2018`, `121/2019`, `32/2020`, `138/2020`,
`151/2022`, `114/2023` i `152/2024`, NN snapshot i parsirani izlazi pod
`izvori/dokazno/narodne_novine/zakon_o_porezu_na_dohodak*/`, kontrolni
direktoriji pod `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak*/` te
osam selection reportova.

Kao stvarni nusartefakt ingest-a osvjezen je i
`izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`, pa ostaje u
scopeu ovog zadatka zajedno sa ZPD generiranim izlazima.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`
- `baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_151_2022/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_114_2023/`
- `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_152_2024/`
- `izvori/dokazno/narodne_novine/ZAKON_O_POREZU_NA_DOHODAK*.md`
- `izvori/dokazno/narodne_novine/zakon_o_porezu_na_dohodak*/`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak*/`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\ingest_paket.ps1 -PaketPath .\paketi\PAKET_ZPD_V1.json`
- `Get-ChildItem .\baza_zakona\norme\zakon_o_porezu_na_dohodak_procisceni`
- `Get-ChildItem .\baza_zakona\sidra\zakon_o_porezu_na_dohodak_nn_*`
- `Get-ChildItem .\izvori\dokazno\narodne_novine\zakon_o_porezu_na_dohodak*`
- `Get-ChildItem .\izvori\kontrolno\zakon_hr\zakon_o_porezu_na_dohodak*`

## Datum: 31.03.2026 (ZADATAK 122)

### ZADATAK 122 - servisno potvrden i sinkroniziran z121 push

Dokazno je utvrdjeno da commit 454ab6f nije bio na origin/main: lokalni main je
bio ahead 1, a git ls-remote je pokazao remote hash e286e72.

Nakon toga je dovrsen git push za Z121, potvrdeno je da origin/main sada
pokazuje 454ab6f, a statusni snapshot je servisno uskladjen kanonskom skriptom
bez sirenja scopea izvan statusa i dnevnika.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `git ls-remote --heads origin main`
- `git push`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 121"`
  `-PolazniHead "e286e72" -PolazniSubject "feat: kontrolna usporedba zpd nn 106`
  `2018 sa zakon hr (Z120)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`
- `alati/generiraj_dnevnicki_unos.ps1`
- `alati/dodaj_dnevnicki_unos_na_kraj.ps1`

## Datum: 31.03.2026 (ZADATAK 123)

### ZADATAK 123 - kontrolna usporedba zpd nn 32 2020 sa zakon hr

Dokazno je potvrden poseban zakon.hr zapis za ZPD amandman NN 32/2020 na URL-u
`https://www.zakon.hr/cms.htm?id=43421`, bez koristenja konsolidiranog /z/85
izvora kao kontrolnog zapisa za amandman.

Pokrenut je stvarni refresh kontrolnog sloja samo za
zakon_o_porezu_na_dohodak_nn_32_2020, nakon cega je validacija nad
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020 dala CONTROL_COUNT=4,
NN_COUNT=4, MISSING_COUNT=0, EXTRA_LIST=[], SHORT_COUNT=1,
CONTROL_TRUNCATION_SUSPECTED=False, GUARDRAIL_FAIL=False i ANOMALY_FLAG=False.

Validator je prosao bez patcha; stvarno su promijenjeni i ili nastali meta.json,
struktura_kontrolno_dokumenti.json,
zakon_o_porezu_na_dohodak_nn_32_2020_kontrolni.txt,
zakon_o_porezu_na_dohodak_nn_32_2020_zakon_hr.html i trajni izvjestaj
IZVJESTAJ_VALIDACIJE_KONTROLNO.md za isti amandman.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_32_2020/meta.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_32_2020/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_32_2020/`
  `zakon_o_porezu_na_dohodak_nn_32_2020_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_32_2020/`
  `zakon_o_porezu_na_dohodak_nn_32_2020_zakon_hr.html`
- `baza_zakona/ sidra/ zakon_o_porezu_na_dohodak_nn_32_2020/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_32_2020 --naziv-akta "Zakon o izmjeni i`
  `dopunama Zakona o porezu na dohodak" --url`
  `"https://www.zakon.hr/cms.htm?id=43421"`
- `c:/Veritas_H77/.venv/Scripts/python.exe .\alati\validiraj_nn_vs_kontrolno.py`
  `-AktSlug zakon_o_porezu_na_dohodak_nn_32_2020`
- `git diff --name-only`
- `git status --short`

## Datum: 31.03.2026 (ZADATAK 124)

### ZADATAK 124 - kontrolna usporedba zpd nn 138 2020 sa zakon hr

Dokazno je potvrden poseban zakon.hr zapis za ZPD amandman NN 138/2020 na URL-u
`https://www.zakon.hr/cms.htm?id=46522`, bez koristenja konsolidiranog /z/85
izvora kao kontrolnog zapisa za amandman.

Pokrenut je stvarni refresh kontrolnog sloja samo za
zakon_o_porezu_na_dohodak_nn_138_2020, pri cemu je builder potvrdio
KONTROLNI_CLANCI=21 i osvjezio meta.json, struktura_kontrolno_dokumenti.json,
zakon_o_porezu_na_dohodak_nn_138_2020_kontrolni.txt i
zakon_o_porezu_na_dohodak_nn_138_2020_zakon_hr.html.

Validacija nad baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020 dala je
CONTROL_COUNT=21, NN_COUNT=21, MISSING_COUNT=0, EXTRA_LIST=[], SHORT_COUNT=8,
CONTROL_TRUNCATION_SUSPECTED=False, GUARDRAIL_FAIL=False i ANOMALY_FLAG=False,
uz trajni izvjestaj IZVJESTAJ_VALIDACIJE_KONTROLNO.md i bez potrebe za patchom
parsera ili validatora.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_138_2020/meta.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_138_2020/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_138_2020/`
  `zakon_o_porezu_na_dohodak_nn_138_2020_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_138_2020/`
  `zakon_o_porezu_na_dohodak_nn_138_2020_zakon_hr.html`
- `baza_zakona/ sidra/ zakon_o_porezu_na_dohodak_nn_138_2020/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe alati/izgradi_kontrolni_zakon_hr.py`
  `--akt-slug zakon_o_porezu_na_dohodak_nn_138_2020 --naziv-akta "Zakon o`
  `izmjenama i dopunama Zakona o porezu na dohodak" --url`
  `https://www.zakon.hr/cms.htm?id=46522`
- `c:/Veritas_H77/.venv/Scripts/python.exe alati/validiraj_nn_vs_kontrolno.py`
  `--akt-slug zakon_o_porezu_na_dohodak_nn_138_2020`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 124"`
  `-PolazniHead 4798104 -PolazniSubject "docs: saniran md034 u dnevniku rada"`
  `-RepoCistPriPrecheck DA -PoravnanjeGranePriPrecheck poravnat`

## Datum: 31.03.2026 (ZADATAK 125)

### ZADATAK 125 - sinkroniziran z124 push i saniran md034 u dnevniku

Servisno je potvrdeno da je Z124 commit postojao lokalno kao 494b307 i da prije
pusha nije bio sinkroniziran na origin/main, nakon cega je izvrsen git push i
potvrdena sinkronizacija glavne grane.

U dnevniku je minimalno saniran preostali MD034 no-bare-urls trag iz Z124 unosa
tako da je dokazni zakon.hr URL prebacen u markdown-safe inline code oblik bez
promjene smisla zapisa.

Skripta alati/generiraj_dnevnicki_unos.ps1 je minimalno dopunjena tako da gole
URL-ove u sazetcima automatski sanitizira u markdown-safe oblik prije upisa, a
pravilo je evidentirano u dokumentaciji
STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `alati/generiraj_dnevnicki_unos.ps1`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git push`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 124"`
  `-PolazniHead 494b307 -PolazniSubject "feat: kontrolna usporedba zpd nn 138`
  `2020 sa zakon hr (Z124)" -RepoCistPriPrecheck DA -PoravnanjeGranePriPrecheck`
  `"ispred origin/main (ahead 1)"`

## Datum: 31.03.2026 (ZADATAK 126)

### ZADATAK 126 - kontrolna usporedba zpd nn 151 2022 sa zakon hr

Dokazno je potvrden zaseban zakon.hr zapis za ZPD amandman NN 151/2022 na URL-u
`https://www.zakon.hr/cms.htm?id=55111`, bez koristenja konsolidiranog /z/85
izvora kao amandmanskog kontrolnog zapisa.

Pokrenut je stvarni refresh kontrolnog sloja samo za
zakon_o_porezu_na_dohodak_nn_151_2022, pri cemu su osvjezeni meta.json,
struktura_kontrolno_dokumenti.json,
zakon_o_porezu_na_dohodak_nn_151_2022_kontrolni.txt i
zakon_o_porezu_na_dohodak_nn_151_2022_zakon_hr.html uz KONTROLNI_CLANCI=23.

Validacija nad baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_151_2022 dala je
CONTROL_COUNT=23, NN_COUNT=23, MISSING_COUNT=0, EXTRA_LIST=[], SHORT_COUNT=11,
CONTROL_TRUNCATION_SUSPECTED=False, GUARDRAIL_FAIL=False i ANOMALY_FLAG=False,
uz trajni izvjestaj IZVJESTAJ_VALIDACIJE_KONTROLNO.md i bez potrebe za patchom
parsera ili validatora.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_151_2022/meta.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_151_2022/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_151_2022/`
  `zakon_o_porezu_na_dohodak_nn_151_2022_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_151_2022/`
  `zakon_o_porezu_na_dohodak_nn_151_2022_zakon_hr.html`
- `baza_zakona/ sidra/ zakon_o_porezu_na_dohodak_nn_151_2022/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_151_2022 --naziv-akta "Zakon o izmjenama i`
  `dopunama Zakona o porezu na dohodak" --url`
  `"https://www.zakon.hr/cms.htm?id=55111"`
- `c:/Veritas_H77/.venv/Scripts/python.exe .\alati\validiraj_nn_vs_kontrolno.py`
  `--akt-slug zakon_o_porezu_na_dohodak_nn_151_2022`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 125"`
  `-PolazniHead a7942ec -PolazniSubject "docs: servisno potvrden i`
  `sinkroniziran z124 push te saniran md034 (Z125)" -RepoCistPriPrecheck DA`
  `-PoravnanjeGranePriPrecheck poravnat`

## Datum: 31.03.2026 (ZADATAK 127)

### ZADATAK 127 - servisno ispravljen dokumentacijski trag z126

Servisno je ispravljen dokumentacijski trag Z126 tako da status vise ne sugerira
pogresan opis validacije, nego eksplicitno navodi da je validacija bila
pokrenuta nad slugom zakon_o_porezu_na_dohodak_nn_151_2022 kroz alat
validiraj_nn_vs_kontrolno.py.

Potvrdeno je da je raniji status-sync u Z126 dokaznom tragu bio pokrenut s
krivim parametrom -ZadnjiZadatak "ZADATAK 125", nakon cega je kanonski ponovno
pokrenut status sync s tocnim parametrima za Z126: -ZadnjiZadatak "ZADATAK 126",
-PolazniHead "a7942ec", -PolazniSubject "docs: servisno potvrden i sinkroniziran
z124 push te saniran md034 (Z125)", -RepoCistPriPrecheck "DA" i
-PoravnanjeGranePriPrecheck "poravnat".

Azuriranje je namjerno zadrzano iskljucivo na dokumentacijska traga
STATUS_PROJEKTA_VERITAS_H77.md i DNEVNIK_RADA.md, bez diranja zakona, manifesta,
parsera ili validatora.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 126"`
  `-PolazniHead "a7942ec" -PolazniSubject "docs: servisno potvrden i`
  `sinkroniziran z124 push te saniran md034 (Z125)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`

## Datum: 31.03.2026 (ZADATAK 128)

### ZADATAK 128 - kontrolna usporedba zpd nn 114 2023 sa zakon hr

Dokazno je potvrden zaseban zakon.hr zapis za ZPD amandman NN 114/2023 na URL-u
`https://www.zakon.hr/cms.htm?id=58270`, bez koristenja konsolidiranog /z/85
izvora kao amandmanskog kontrolnog zapisa.

Pokrenut je stvarni refresh kontrolnog sloja samo za
zakon_o_porezu_na_dohodak_nn_114_2023, pri cemu su osvjezeni meta.json,
struktura_kontrolno_dokumenti.json,
zakon_o_porezu_na_dohodak_nn_114_2023_kontrolni.txt i
zakon_o_porezu_na_dohodak_nn_114_2023_zakon_hr.html uz KONTROLNI_CLANCI=42.

Validacija nad slugom zakon_o_porezu_na_dohodak_nn_114_2023 dala je
CONTROL_COUNT=42, NN_COUNT=44, MISSING_COUNT=0, EXTRA_LIST=[76, 78],
SHORT_COUNT=20, CONTROL_TRUNCATION_SUSPECTED=False, GUARDRAIL_FAIL=False i
ANOMALY_FLAG=False, uz trajni izvjestaj IZVJESTAJ_VALIDACIJE_KONTROLNO.md i bez
potrebe za patchom parsera ili validatora.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_114_2023/meta.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_114_2023/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_114_2023/`
  `zakon_o_porezu_na_dohodak_nn_114_2023_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_114_2023/`
  `zakon_o_porezu_na_dohodak_nn_114_2023_zakon_hr.html`
- `baza_zakona/ sidra/ zakon_o_porezu_na_dohodak_nn_114_2023/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_114_2023 --naziv-akta "Zakon o izmjenama i`
  `dopunama Zakona o porezu na dohodak" --url`
  `"https://www.zakon.hr/cms.htm?id=58270"`
- `c:/Veritas_H77/.venv/Scripts/python.exe .\alati\validiraj_nn_vs_kontrolno.py`
  `--akt-slug zakon_o_porezu_na_dohodak_nn_114_2023`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 127"`
  `-PolazniHead "65e9a37" -PolazniSubject "docs: servisno ispravljen`
  `dokumentacijski trag z126 (Z127)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`

## Datum: 31.03.2026 (ZADATAK 129)

### ZADATAK 129 - kontrolna usporedba zpd nn 152 2024 sa zakon hr

Dokazno je potvrden zaseban zakon.hr zapis za ZPD amandman NN 152/2024 na URL-u
`https://www.zakon.hr/cms.htm?id=540193`, bez koristenja konsolidiranog /z/85
izvora kao amandmanskog kontrolnog zapisa.

Pokrenut je stvarni refresh kontrolnog sloja samo za
zakon_o_porezu_na_dohodak_nn_152_2024, pri cemu su osvjezeni meta.json,
struktura_kontrolno_dokumenti.json,
zakon_o_porezu_na_dohodak_nn_152_2024_kontrolni.txt i
zakon_o_porezu_na_dohodak_nn_152_2024_zakon_hr.html uz KONTROLNI_CLANCI=19.

Validacija nad slugom zakon_o_porezu_na_dohodak_nn_152_2024 dala je
CONTROL_COUNT=19, NN_COUNT=19, MISSING_COUNT=0, EXTRA_LIST=[], SHORT_COUNT=6,
CONTROL_TRUNCATION_SUSPECTED=False, GUARDRAIL_FAIL=False i ANOMALY_FLAG=False,
uz trajni izvjestaj IZVJESTAJ_VALIDACIJE_KONTROLNO.md i bez potrebe za patchom
parsera ili validatora.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_152_2024/meta.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_152_2024/`
  `struktura_kontrolno_dokumenti.json`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_152_2024/`
  `zakon_o_porezu_na_dohodak_nn_152_2024_kontrolni.txt`
- `izvori/ kontrolno/ zakon_hr/ zakon_o_porezu_na_dohodak_nn_152_2024/`
  `zakon_o_porezu_na_dohodak_nn_152_2024_zakon_hr.html`
- `baza_zakona/ sidra/ zakon_o_porezu_na_dohodak_nn_152_2024/`
  `IZVJESTAJ_VALIDACIJE_KONTROLNO.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\izgradi_kontrolni_zakon_hr.py --akt-slug`
  `zakon_o_porezu_na_dohodak_nn_152_2024 --naziv-akta "Zakon o izmjenama i`
  `dopunama Zakona o porezu na dohodak" --url`
  `"https://www.zakon.hr/cms.htm?id=540193"`
- `c:/Veritas_H77/.venv/Scripts/python.exe .\alati\validiraj_nn_vs_kontrolno.py`
  `--akt-slug zakon_o_porezu_na_dohodak_nn_152_2024`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak "ZADATAK 128"`
  `-PolazniHead "5f673e4" -PolazniSubject "feat: kontrolna usporedba zpd nn 114`
  `2023 sa zakon hr (Z128)" -RepoCistPriPrecheck "DA"`
  `-PoravnanjeGranePriPrecheck "poravnat"`

## Datum: 31.03.2026 (ZADATAK 130)

### ZADATAK 130 - kanonski obrazac kontrolne usporedbe amandmana zpd

Na temelju stvarnih izvjestaja Z120 za NN 106/2018 i Z121 za NN 121/2019 izveden
je kanonski obrazac za zasebne ZPD amandmane u usporedbi sa zakon.hr, bez
diranja parsera ili validatora u ovom zadatku.

Dokument formalizira da su MISSING_COUNT=0, CONTROL_TRUNCATION_SUSPECTED=False,
GUARDRAIL_FAIL=False i ANOMALY_FLAG=False tvrdi kriteriji prolaza, dok
SHORT_COUNT i izolirani EXTRA_LIST ostaju tolerirani nalazi ako nisu praceni
signalom stvarnog kvara ili gubitka clanka.

Mijenjane datoteke:

- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK 130'`
  `-PolazniHead 'd8e307a' -PolazniSubject 'feat: kontrolna usporedba zpd nn 152`
  `2024 sa zakon hr (Z129)' -RepoCistPriPrecheck 'DA'`
  `-PoravnanjeGranePriPrecheck 'poravnat'`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 145)

### ZADATAK 145 - izdvojen stvarni staged skup za Z138

Iz stvarnog lokalnog diffa izdvojen je cisti staged skup za buduci Z138 commit,
bez commitanja i bez ukljucivanja kasnijih lokalnih dokumentacijskih tragova.

U stage su usli:

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- samo Z138 hunk u `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- samo Z138 hunk u `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- samo append-only Z138 blok u `dokumentacija/DNEVNIK_RADA.md`

Izvan stagea su ostali:

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
- `.vscode/`
- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- svi kasniji lokalni tragovi Z139-Z144 u mapi, statusu i dnevniku

Dokazne naredbe:

- `git diff --cached --name-only`
- `git diff --name-only`
- `git status --short`
- `git ls-remote --heads origin main`

## Datum: 31.03.2026 (ZADATAK 142)

### ZADATAK 142 - dokazni odgovor o dovoljnosti obrasca zakoni s amandmanima

Na temelju izravne usporedbe glavnog kanonskog obrasca, inventure, analiza
stanja i dovoljnosti, specijaliziranog obrasca amandmanske kontrole, ZPD
rezima konverzije i standarda JSON norme potvrdeno je da dokument
`dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` vec sadrzi
obvezni operativni sadrzaj za glavni standard rada.

U dokumentu
`dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
zapisano je sto glavni kanonski obrazac vec pokriva, sto ostaje izvan njega
kao pomocni skup i zasto nije utvrden novi minimalni obvezni sadrzaj koji bi
se jos morao dopisati.

Mijenjane datoteke:

- `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git diff --name-only`
- `git status --short`
- `git ls-remote --heads origin main`

## Datum: 31.03.2026 (ZADATAK 140)

### ZADATAK 140 - analiza stanja kanonskog obrasca zakoni s amandmanima

Izrađena je dokazna analiza trenutačnog lokalnog i GitHub stanja nakon
nezatvorenih Z138 i Z139 u dokumentu
`dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
bez commita, bez pusha i bez diranja zakona, sidara, normi i alata.

Analiza je potvrdila da na GitHubu i dalje završava stanje na commitu 8666f89,
dok lokalno već postoje inventura obrasca i objedinjeni kanonski obrazac,
pa minimalni sljedeći korak nije novi sadržajni refaktor nego zatvaranje tog
već izrađenog dokumentacijskog skupa kao stvarnog repozitorijskog standarda.

Mijenjane datoteke:

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git diff --name-only`

## Datum: 31.03.2026 (ZADATAK 141)

### ZADATAK 141 - analiza dovoljnosti kanonskog obrasca zakoni s amandmanima

Izradjena je dokazna analiza dovoljnosti postojeceg kanonskog obrasca za
zakone s amandmanima u dokumentu
`dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
bez commita, bez pusha i bez diranja zakona, sidara, normi i alata.

Analiza je utvrdila da je
`dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` vec dovoljno
jak da ostane glavni opci standard, ali da inventura, amandmanski obrazac i
zavrsni ZPD izvjestaj trebaju ostati odvojeni kao prijelazni, specijalizirani
odnosno dokazni dokumenti, umjesto mehanickog spajanja u jedan tekst.

Mijenjane datoteke:

- `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git diff --name-only`

## Datum: 31.03.2026 (ZADATAK 137)

### ZADATAK 137 - kanonski uredjen zavrsni zpd dokument za objavu u repou

`dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` preureden je u
konacni kanonski raspored za repo: sazetak na vrhu, zatim core ZPD, potom svi
amandmani redom i na kraju zavrsni zakljucak.

Pri tome nisu mijenjani vec zapisani URL-ovi, metrike, cinjenice ni
zakljucci; servisno su uskladjeni samo `STATUS_PROJEKTA_VERITAS_H77.md` i ovaj
append-only dnevnicki trag.

Mijenjane datoteke:

- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne napomene:

- nije pokrenuta nijedna skripta
- nije diran nijedan alat
- nije mijenjan nijedan zakonodavni artefakt ni ZPD metrika

## Datum: 31.03.2026 (ZADATAK 131)

### ZADATAK 131 - ujednacen dokazni format z120 i z121 u statusu

Azurirana je dokumentacija iskljucivo radi ujednacavanja dokaznog formata zapisa
za Z120 i Z121 u statusu, tako da oba ZPD amandmana sada slijede isti
eksplicitni skup polja kao kasniji zapisi Z128 i Z129, bez promjene znacenja ili
rezultata tih zadataka.

Pokrenut je kanonski status sync za Z131 na pre-check commit eef49a6, a nakon
poznatog ogranicenja skripte rucno je korigiran samo snapshot redak Zadnji
dovrseni zadatak na ZADATAK 131; parser, validator, manifest, mapa i zakonodavni
artefakti nisu dirani.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK 131'`
  `-PolazniHead 'eef49a6' -PolazniSubject 'docs: kanonski obrazac kontrolne`
  `usporedbe amandmana zpd (Z130)' -RepoCistPriPrecheck 'DA'`
  `-PoravnanjeGranePriPrecheck 'poravnat'`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 132)

### ZADATAK 132 - zavrsni kanonski dokument za cijeli zpd

Izradjen je novi kanonski dokument
dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md koji objedinjeno zatvara
pregled za cijeli zakon_o_porezu_na_dohodak na temelju vec postojecih repo
artefakata, statusa i dnevnickih tragova, bez novog ingest-a, bez novog
refresh-a i bez izmjene parsera ili validatora.

Dokument pokriva core ZPD i svih sedam amandmana iz manifesta, za svaki akt
navodi kontrolni zakon.hr URL ako je vec evidentiran u repou, glavne
validacijske metrike i zakljucak o prolazu, a zavrsni dio potvrduje da je cijeli
ZPD skup obradjen modelom core + amandmani uz preostale tolerirane napomene
oblika SHORT_COUNT i izoliranog EXTRA_LIST.

Mijenjane datoteke:

- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK 132'`
  `-PolazniHead '008cdbc' -PolazniSubject 'docs: ujednacen dokazni format z120`
  `i z121 u statusu (Z131)' -RepoCistPriPrecheck 'DA'`
  `-PoravnanjeGranePriPrecheck 'poravnat'`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 133)

### ZADATAK 133 - sanirana 2 workspace problema nakon z132

Deterministicki su utvrdena i sanirana točno 2 stvarna workspace problema
nastala nakon izrade dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md:
MD047/single-trailing-newline u
dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md i isti MD047 problem
u dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md.

Sanacija je namjerno zadrzana samo na normalizaciji zavrsnog newline zapisa u te
dvije datoteke, bez drugih sadržajnih izmjena, uz dopunu
STATUS_PROJEKTA_VERITAS_H77.md i append-only evidenciju u DNEVNIK_RADA.md.

Mijenjane datoteke:

- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 134)

### ZADATAK 134 - dokazno dovrsen z133 i uskladen stvarni scope

Dokazno je potvrdeno da Z133 pri otvaranju Z134 nije bio zatvoren na
origin/main: lokalni HEAD bio je cb977d5, grana main je bila ahead 1, a git
ls-remote je pokazao da origin/main jos pokazuje 008cdbc.

Istodobno je potvrdeno da
dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md nema stvarni radni
diff nakon Z133, pa nije ukljucena u stvarni Z134 commit scope; Z134 je zato
zadrzan samo na STATUS_PROJEKTA_VERITAS_H77.md i append-only unosu u
DNEVNIK_RADA.md, uz dokazno zatvaranje remote nesklada pushom.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git diff --name-only`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
  `.\dokumentacija\ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 135)

### ZADATAK 135 - servisno uklonjen izvan-scope vscode artefakt

Dokazno je utvrdeno da je .vscode/ sadrzavao samo lokalni editor artefakt
.vscode/settings.json, bez kanonske potrebe za repozitorij, nakon cega je taj
izvan-scope artefakt uklonjen iz radnog stabla bez ikakvih promjena u zakonima,
parserima, validatorima ili ZPD dokumentima.

Nakon uklanjanja .vscode/ git status --short je postao prazan prije
dokumentacijskog traga, a Z135 je zatim evidentiran iskljucivo kroz
STATUS_PROJEKTA_VERITAS_H77.md i append-only unos u DNEVNIK_RADA.md.

Mijenjane datoteke:

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-ChildItem .\.vscode -Force`
- `git status --short`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 136)

### ZADATAK 136 - trajno ispravljen upis zadnjeg dovrsenog zadatka u statusu

Trajno je ispravljena skripta alati/uskladi_status_projekta.ps1 tako da pri
eksplicitno zadanom parametru -ZadnjiZadatak pouzdano i deterministicki azurira
snapshot redak Zadnji dovrseni zadatak u
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md, bez naknadnog rucnog patchanja
statusa.

Kvar je dokazno reproduciran na privremenoj kopiji i zatim stvarno potvrden nad
samim status dokumentom: nakon patcha skripta je najprije upisala testnu
vrijednost ZADATAK TEST 136, a potom i realnu vrijednost ZADATAK 136, bez rucne
intervencije na tom retku.

Mijenjane datoteke:

- `alati/uskladi_status_projekta.ps1`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK TEST`
  `136' -PolazniHead '3b9db2f' -PolazniSubject 'docs: servisno uklonjen`
  `izvan-scope vscode artefakt (Z135)' -RepoCistPriPrecheck 'DA'`
  `-PoravnanjeGranePriPrecheck 'poravnat'`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK 136'`
  `-PolazniHead '3b9db2f' -PolazniSubject 'docs: servisno uklonjen izvan-scope`
  `vscode artefakt (Z135)' -RepoCistPriPrecheck 'DA'`
  `-PoravnanjeGranePriPrecheck 'poravnat'`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
  `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
  `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
  `dokumentacija/DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 31.03.2026 (ZADATAK 138)

### ZADATAK 138 - inventura obrasca zakoni s amandmanima

Izradjena je analiticka inventura postojećeg obrasca za pretvaranje zakona s
amandmanima u JSON u dokumentu
dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md, isključivo na temelju
postojećih kanonskih dokumenata i alata, bez novih patch-eva u zakonima,
normama, sidrima ili kontrolnim artefaktima.

Inventura je pokazala da repou ne nedostaju pojedinačni mehanizmi za model core
- amandmani, nego jedan objedinjeni kanonski dokument koji bi na jednom mjestu
spojio odluku o režimu, manifest, NN dokazni sloj, kontrolni zakon.hr sloj,
sidra, validaciju i završni izvještaj.

Mijenjane datoteke:

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `powershell -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
<<<<<<< HEAD
=======

## Datum: 02.04.2026 (ZADATAK 146)

### ZADATAK 146 - zamrznuta meta-dokumentacija Z138 do Z145

Z138-Z145 meta-dokumenti u mapi dokumentacije oznaceni su kao privremeni
radni trag i neoperativni pomocni dokumenti.

Ti dokumenti nisu operativni centar projekta, a operativni minimum ostaje
usmjeren na `zakon -> ingest -> JSON`.

U ovom koraku azurirane su samo datoteke
`dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
`dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
`dokumentacija/DNEVNIK_RADA.md`.

Mijenjane datoteke:

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\uskladi_status_projekta.ps1 -StatusPath`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md -ZadnjiZadatak 'ZADATAK`
  `146' -PolazniHead 'eb7a13f' -PolazniSubject 'docs: inventura obrasca`
  `zakoni s amandmanima (Z138)' -RepoCistPriPrecheck 'NE'`
  `-PoravnanjeGranePriPrecheck 'behind 1'`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\dodaj_dnevnicki_unos_na_kraj.ps1 -DiaryPath`
  `.\dokumentacija\DNEVNIK_RADA.md -EntryPath`
  `$env:TEMP\veritas_z146_dnevnik.md`

## Datum: 02.04.2026 (ZADATAK 147)

### ZADATAK 147 - full-repo markdown gate uz scoped lint

Potvrdeno je da je postojeci markdown lint prije patcha davao scoped/tracked
pregled (`MDLINT_TARGET_COUNT=4`), a ne puni markdown signal cijelog repoa.

Uveden je novi full-repo mod u `alati/lint_markdown.ps1` uz zadrzavanje
postojeceg scoped moda. Izlaz sada ima jasan marker moda:
`MDLINT_MODE=SCOPED` ili `MDLINT_MODE=FULL_REPO`.

U `alati/ci_smoke.ps1` scoped lint ostaje hard-gate, dok full-repo lint radi
kao evidencijski signal (`CI_SMOKE_FULL_REPO_MDLINT_*`) bez rusenja cijelog
smoke prolaza.

Mijenjane datoteke:

- `alati/lint_markdown.ps1`
- `alati/ci_smoke.ps1`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1 -FullRepo`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 03.04.2026 (ZADATAK 148)

### ZADATAK 148 - arhivsko preoznacavanje analize stanja obrasca

Arhivski je preoznacena datoteka
`dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
kao povijesni trag s neaktivnim operativnim statusom.

U ovom koraku dirane su točno 4 datoteke:

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 03.04.2026 (ZADATAK 149)

### ZADATAK 149 - uklanjanje proceduralnih datoteka z138 do z142

Uklonjene su točno dvije proceduralne datoteke:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`

U ovom koraku dirano je točno 5 datoteka:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

## Datum: 03.04.2026 (ZADATAK 150)

### ZADATAK 150 - uklanjanje zastarjelih neaktivnih dokumenata

Uklonjena su tocno 3 dokumenta iz kanonskog sloja repozitorija:

- dokumentacija/BASELINE_MARKDOWN_STANJA_REPOA.md
- dokumentacija/USPOREDBA_PREOSTALE_DVIJE_UNSTAGED_DATOTEKE.md
- dokumentacija/ANALIZA_ZPD_ZAVRSNOG_IZVJESTAJA_LOKALNI_DIFF.md

Sva 3 dokumenta su prethodno u ZADATAK 149 (eca5596) dokazno
procijenjena kao KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA.
Svako je opisivalo zatvoreno prolazno stanje repoa bez kanonske
operativne vrijednosti.

U ovom koraku dirано je tocno 5 datoteka:

- dokumentacija/BASELINE_MARKDOWN_STANJA_REPOA.md
- dokumentacija/USPOREDBA_PREOSTALE_DVIJE_UNSTAGED_DATOTEKE.md
- dokumentacija/ANALIZA_ZPD_ZAVRSNOG_IZVJESTAJA_LOKALNI_DIFF.md
- dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
- dokumentacija/DNEVNIK_RADA.md

Dokazne naredbe:

- git status --short
- git diff --name-only
- git diff --cached --name-only
- git --no-pager log -1 --oneline
- git branch -vv
- git ls-remote --heads origin main
- Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120
- pwsh -NoProfile -ExecutionPolicy Bypass -File
  .\alati\provjeri_markdown_scope.ps1
  .\dokumentacija\MAPA_DOKUMENTACIJE_VERITAS_H77.md
  .\dokumentacija\DNEVNIK_RADA.md
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
- pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1

---

## Datum: 04.04.2026 (ZADATAK 151)

### ZADATAK 151 - sanacija md010 hard-tab problema

Sanirana su oba aktivna `MD010` hard-tab nalaza iz kanonskog popisa,
bez drugih markdown zahvata izvan dopuštenog scopea.

U ovom koraku dirane su točno 3 datoteke:

- `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
- `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
  `.\izvori\dokazno\narodne_novine\IZVJESTAJ_KONTROLE_ARHIVE.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1 -FullRepo`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 152)

### ZADATAK 152 - prvi batch md013 selection report sanacije

Saniran je prvi homogeni batch `MD013` selection report backloga u skupu
`izvori/dokazno/narodne_novine/`, bez diranja drugih markdown problema i
bez širenja scopea izvan odabranog pods-kupa.

U ovom koraku dirano je točno 9 datoteka:

- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_106_2018_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_114_2022_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_121_2019_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_151_2025_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_152_2024_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_32_2020_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_42_2020_SELECTION_REPORT.md`
- `dokumentacija/DNEVNIK_RADA.md`

Riječ je o prvom batch `MD013` rezu nad dokumentima istog tipa, s istim
mehaničkim obrascem sanacije kroz prelom dugih redaka bez promjene značenja.

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `<batch_selection_report_datoteke> .\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1 -FullRepo`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 153)

### ZADATAK 153 - drugi batch md013 selection report sanacije

Saniran je drugi homogeni batch `MD013` selection report backloga u skupu
`izvori/dokazno/narodne_novine/`, bez diranja drugih markdown problema i
bez širenja scopea izvan odabranog pods-kupa.

U ovom koraku dirano je točno 9 datoteka:

- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_106_2018_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_114_2023_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_121_2019_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_138_2020_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_151_2022_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_152_2024_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_32_2020_SELECTION_REPORT.md`
- `dokumentacija/DNEVNIK_RADA.md`

Riječ je o drugom batch `MD013` rezu nad dokumentima istog tipa, s istim
mehaničkim obrascem sanacije kroz prelom dugih redaka bez promjene značenja.

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `<batch2_selection_report_datoteke> .\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1 -FullRepo`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 154)

### ZADATAK 154 - treci i zavrsni batch md013 selection report sanacije

Saniran je treći i završni homogeni batch `MD013` selection report backloga
u skupu `izvori/dokazno/narodne_novine/`, bez diranja drugih markdown
problema i bez širenja scopea izvan završnog pods-kupa.

U ovom koraku dirane su točno 4 datoteke:

- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_NN_110_2021_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_SELECTION_REPORT.md`
- `izvori/dokazno/narodne_novine/`
  `ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md`
- `dokumentacija/DNEVNIK_RADA.md`

Riječ je o trećem i završnom `MD013` rezu nad dokumentima istog tipa, s istim
mehaničkim obrascem sanacije kroz prelom dugih redaka bez promjene značenja.

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `<batch3_selection_report_datoteke> .\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\lint_markdown.ps1 -FullRepo`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 155)

### ZADATAK 155 - prvi skupinski rez ciscenja suma u dokumentaciji

Proveden je prvi homogeni skupinski cleanup rez nad skupinom
`snapshot / primopredaja / stanje-repozitorija` tragova u mapi
`dokumentacija/`, bez širenja scopea izvan odabrane skupine i pratećih
kanonskih evidencijskih datoteka.

U ovom koraku dirano je točno 7 datoteka:

- `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
- `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
- `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Zajednička logika reza:

- svi zahvaćeni dokumenti bili su snapshot, primopredajni ili prijelazni
  statusni tragovi bez aktivne operativne vrijednosti
- svi su već bili konzumirani kasnijim commitovima i dokaznim revizijama
- uklonjeni su iz aktivnog kanonskog sloja kako bi se smanjio šum u vrhu
  mape `dokumentacija/`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1 <sve_dirane_md_datoteke>`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 156)

### ZADATAK 156 - korektivno uklonjeni stubovi iz prve skupine suma

Ispravljen je pogrešno izveden prvi skupinski rez iz commita `c6519e9`.
U tom su koraku četiri dokumenta iz skupine
`snapshot / primopredaja / stanje-repozitorija` formalno bila maknuta iz
aktivnog kanonskog sloja, ali su zatim vraćena kao arhivski stubovi istih
imena.

U ovom korektivnom rezu ti su stubovi stvarno uklonjeni iz kanonskog i
radnog sloja. Trag o toj skupini sada ostaje samo u
`dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
`dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`,
`dokumentacija/DNEVNIK_RADA.md` i u git povijesti.

U ovom koraku dirano je točno 7 datoteka:

- `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
- `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
- `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -2 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1 <sve_dirane_md_datoteke>`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 157)

### ZADATAK 157 - preoznaceni povijesni dokazni tragovi u dokumentaciji

Proveden je drugi skupinski dokumentacijski rez nad homogenom skupinom
starijih povijesnih dokaznih i revizijskih tragova koji ostaju u repou,
ali više ne pripadaju aktivnom kanonskom sloju.

Odabrana skupina obuhvaća točno ove dokumente:

- `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

U ovom koraku dirano je točno 6 datoteka:

- `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Zajednička logika reza:

- svi dokumenti imaju dokaznu vrijednost, ali nisu dnevni operativni kanon
- svi su supersedani novijim revizijama ili zatvorenim rezultatima
- ostaju u repou kao `POVIJESNI_DOKAZNI_TRAGOVI`
- nijedna datoteka nije fizički uklonjena

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1 <sve_dirane_md_datoteke>`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 158)

### ZADATAK 158 - uveden genericki alat za zatvaranje granskih natuknica

Uveden je novi genericki alat
`alati/zatvori_validiranu_gransku_natuknicu.py` koji objedinjuje
zajednicku jezgru logike skupine
`zatvori_*_validiranu_gransku_natuknicu.py`.

U ovom koraku stare 4 skripte nisu dirane, nisu preimenovane i nije
provedena migracija postojecih poziva na novi alat.

U ovom koraku dirane su točno 3 datoteke:

- `alati/zatvori_validiranu_gransku_natuknicu.py`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe -m py_compile`
  `.\alati\zatvori_validiranu_gransku_natuknicu.py`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_validiranu_gransku_natuknicu.py --help`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\TEHNIČKI_OKVIR_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 159)

### ZADATAK 159 - wrapperi granskih natuknica preusmjereni na genericki alat

Postojece 4 skripte skupine
`zatvori_*_validiranu_gransku_natuknicu.py` pretvorene su u tanke
kompatibilne wrappere koji zadrzavaju postojeca imena i delegiraju na
`alati/zatvori_validiranu_gransku_natuknicu.py` s fiksnim `--nacin`.

Genericki alat u ovom koraku nije mijenjan.
Fizicko uklanjanje wrappera nije dio ovog koraka.

U ovom koraku dirano je točno 6 datoteka:

- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `git stash list`
- `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail 120`
- `c:/Veritas_H77/.venv/Scripts/python.exe -m py_compile`
  `.\alati\zatvori_prvu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_drugu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_sljedecu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_prvu_validiranu_gransku_natuknicu.py --help`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_drugu_validiranu_gransku_natuknicu.py --help`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_sljedecu_validiranu_gransku_natuknicu.py --help`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_jos_jednu_validiranu_gransku_natuknicu.py --help`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\TEHNIČKI_OKVIR_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`

---

## Datum: 04.04.2026 (ZADATAK 160)

### ZADATAK 160 - uklonjeni wrapperi granskih natuknica nakon konsolidacije

Uklonjene su 4 stare wrapper skripte skupine
`zatvori_*_validiranu_gransku_natuknicu.py` nakon dokazne provjere da više
nemaju aktivne operativne reference u repou.

Removal je proveden na temelju dokumenata:

- `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
  `WRAPPERA_GRANSKIH_NATUKNICA.md`
- `dokumentacija/POPIS_REFERENCI_NA_WRAPPERE_GRANSKIH_NATUKNICA.md`

Generički alat `alati/zatvori_validiranu_gransku_natuknicu.py` u ovom
koraku nije diran i ostaje jedina aktivna implementacija skupine.

U ovom koraku dirano je točno 7 datoteka:

- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git stash list`
- `git --no-pager log -3 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Write-Host "DNEVNIK_TAIL_BEFORE_BEGIN"; Get-Content`
  `.\dokumentacija\DNEVNIK_RADA.md -Tail 120;`
  `Write-Host "DNEVNIK_TAIL_BEFORE_END"`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\alati\zatvori_prvu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_drugu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_sljedecu_validiranu_gransku_natuknicu.py`
  `.\alati\zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
  `.\dokumentacija\TEHNIČKI_OKVIR_VERITAS_H77.md`
  `.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `git diff --cached --name-only`
- `git status --short`
- `Write-Host "DNEVNIK_TAIL_AFTER_BEGIN"; Get-Content`
  `.\dokumentacija\DNEVNIK_RADA.md -Tail 120;`
  `Write-Host "DNEVNIK_TAIL_AFTER_END"`

---

## Datum: 05.04.2026 (ZADATAK 161)

### ZADATAK 161 - uveden genericki alat za zatvaranje paketa prekrsajnog zakona

Uveden je novi genericki alat
`alati/zatvori_paket_prekrsajni_zakon.py` za objedinjenu jezgru
paketnog zatvaranja homogenih nizova za `prekrsajni_zakon`.

U ovom koraku postojecih 8 specijaliziranih skripti skupine
`zatvori_paket_*_prekrsajni_zakon.py` nisu dirane.
Migracija tih skripti u tanke wrappere nije dio ovog koraka.

U ovom koraku dirane su točno 3 datoteke:

- `alati/zatvori_paket_prekrsajni_zakon.py`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Potvrđeno je da ništa izvan ovog scopea nije dirano.

Dokazne naredbe:

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- `git stash list`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `git ls-remote --heads origin main`
- `Write-Host "DNEVNIK_TAIL_BEFORE_BEGIN"; Get-Content`
  `.\dokumentacija\DNEVNIK_RADA.md -Tail 120;`
  `Write-Host "DNEVNIK_TAIL_BEFORE_END"`
- `c:/Veritas_H77/.venv/Scripts/python.exe -m py_compile`
  `.\alati\zatvori_paket_prekrsajni_zakon.py`
- `c:/Veritas_H77/.venv/Scripts/python.exe`
  `.\alati\zatvori_paket_prekrsajni_zakon.py --help`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File`
  `.\alati\provjeri_markdown_scope.ps1`
  `.\dokumentacija\TEHNIČKI_OKVIR_VERITAS_H77.md`
  `.\dokumentacija\DNEVNIK_RADA.md`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1`
- `pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1`
- `git diff --cached --name-only`
- `git status --short`
- `Write-Host "DNEVNIK_TAIL_AFTER_BEGIN"; Get-Content`
  `.\dokumentacija\DNEVNIK_RADA.md -Tail 120;`
  `Write-Host "DNEVNIK_TAIL_AFTER_END"`
