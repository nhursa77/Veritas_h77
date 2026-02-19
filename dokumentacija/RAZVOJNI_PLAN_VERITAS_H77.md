# RAZVOJNI PLAN VERITAS H.77 (kanonski)

## 0) Definicija “funkcionalan Veritas” (MVP)
Veritas H.77 se smatra funkcionalnim na lokalnom desktopu kada može, bez
cloud-a:

1) Zaprimiti “predmet” (slučaj) s činjenicama i dokazima.
2) Voditi lanac skrbništva (ručno/automatizirano) i izračunati SHA-256 hasheve
   priloga.
3) Koristiti normativnu bazu u JSON formatu (chunk = članak) za citiranje
   normi.
4) Koristiti proceduralnu bazu u JSON formatu (koraci postupka) za predlaganje
   redoslijeda radnji.
5) Generirati nacrt podneska iz predloška + činjenica + citata normi.
6) Ugraditi “gate” pravila: bez sidara norme i bez potpisa nositelja nema
   vanjskog izlaza.
7) Reproducibilno se pokrenuti lokalno (Docker kostur + lokalni runtime).

Veritas može generirati nacrt i bez punog sidra, ali tada nema vanjske
uporabe.
Vanjski izlaz znači dokument predviđen za slanje instituciji.
Vanjski izlaz je blokiran bez sidra norme (puno ili djelomično uz eksplicitnu
napomenu o riziku) i bez potpisa čovjeka.

Nositelj uvijek pregledava i potpisuje. Veritas ne šalje ništa “sam od sebe”.

---

## 1) Operativna arhitektura (tekstualno)
Ulazi (činjenice + dokazi)
→ Integritet (hash + lanac skrbništva)
→ Norme (JSON NORMA, članci) + sidra (NN)
→ Postupci (JSON POSTUPAK, koraci)
→ Predložak dokumenta
→ Nacrt dokumenta (spreman za potpis)
→ Potpis nositelja (gate)
→ Izvoz paketa (podnesak + prilozi + manifest + hash)

---

## 2) KANONSKA PRAVILA (obavezno)
1) Jezik repoa i dokumentacije: isključivo hrvatski.
2) Datumi u dokumentaciji i JSON zapisima: `DD.MM.YYYY.`
3) Datoteke kanonske dokumentacije: samo opisna imena
   (bez DOKUMENT_01/02/03 prefiksa).
4) Norma je “chunk = članak” i mora biti citabilna na razini čl./st./t.
5) Postupak je “korak = JSON objekt” i ne izvršava se bez gate uvjeta.
6) Vanjski izlaz vrijedi tek nakon potpisa nositelja.
7) Primarni izvor normi: Narodne novine (dokazni i operativni tekst).
  zakon.hr je kontrolni izvor za validaciju i detekciju rupa/anomalija;
  nikad ne zamjenjuje dokazni izvor NN.
8) Ne ide se na skaliranje i UI prije nego što MVP end-to-end radi na jednom
   stvarnom predmetu.

### KANONSKA_STRUKTURA_BAZE
- `baza_zakona/norme/` sadrži isključivo operativne kanone
  (npr. `prekrsajni_zakon`, `prekrsajni_zakon_procisceni`, `ustav_rh`).
- `baza_zakona/sidra/` sadrži isključivo NN sidrišta i njihove verzije
  (`*_nn_*`, core i amandmani).
- `baza_zakona/arhiva/` sadrži isključivo hladnu arhivu, obavezno pod
  verzioniranim putanjama (`arhiva/<verzija>/<akt_slug>/`).

Pravilo odabira izvora:
- Operativni izlaz uvijek se gradi iz NN izvora (`sidra`), uz
  `procisceni`-first selekciju kada je dostupna.
- `norme` je ciljna operativna projekcija za postupanje i citiranje;
  `sidra` ostaju audit/dokazni sloj i ne zamjenjuju operativni kanon.
- `zakon.hr` je kontrolni izvor za usporedbu i detekciju anomalija,
  nikad izvor istine.

---

## 3) Repozitorij: minimalna struktura (dogovor)
U repou moraju postojati ove cjeline
(stvarne mape se uvode po fazama, ne sve odjednom):

- `dokumentacija/` — kanonski dokumenti i dnevnik rada
- `baza_normi/` — JSON NORMA (članak) po aktu i “stanje na dan”
- `baza_postupaka/` — JSON POSTUPAK (koraci)
- `predlosci/` — predlošci dokumenata (Markdown)
- `predmeti/` — stvarni predmeti (činjenice, dokazi, izlazi, manifest)
- `alati/` — skripte i pomoćni alati (hash, manifest, validacija)
- `docker/` — docker compose i minimalni runtime (kada dođe faza)

---

## 4) Faze razvoja (strogi redoslijed)
Svaka faza ima: Cilj, Ulaz, Izlaz, Provjera, Gate.

### FAZA 0 — Kanonska dokumentacija i pravila repoa
CILJ: Repo je stabilan, pravila su zaključana, dokumentacija kanonska.
ULAZ: postojeći repo.
IZLAZ:
- `.gitattributes`, `.editorconfig`, `.markdownlint.json` zaključani
- kanonski dokumenti: `METODOLOGIJA_RADA_VERITAS_H77.md`,
  `STANDARD_JSON_NORMA.md`, `RJEČNIK_POJMOVA_VERITAS_H77.md`,
  `TEHNIČKI_OKVIR_VERITAS_H77.md`, `MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `DNEVNIK_RADA.md` (uvodi se čim počnemo standardizirane radove)
PROVJERA:
- `git status` čist
- warnings o EOL svedeni na nulu (ili objašnjeni i prihvaćeni)
GATE:
- bez ove faze nema novih standarda ni alata

### FAZA 1 — Ingest NN izvora + arhiva izvora
CILJ: Uspostaviti deterministički dohvat i arhivu primarnog izvora iz NN.
NN je primarni izvor za sve zakone i propise.
ULAZ:
- URL službene objave u NN
- akt slug, naziv akta, vrsta akta
IZLAZ:
- `izvori/dokazno/narodne_novine/<akt_slug>/izvor_nn.<ext>`
- `izvori/dokazno/narodne_novine/<akt_slug>/meta.json`
- opcionalno kontrolno: `izvori/kontrolno/zakon_hr/<akt_slug>/` (txt + meta)
- hash (`sha256_datoteke`) i datum pristupa (`DD.MM.YYYY.`)
PROVJERA:
- provjera da datoteka postoji i da je hash zapisan u `meta.json`
GATE:
- bez arhiviranog i hashiranog NN izvora nema vanjskog izlaza
- kontrola izvora mora vratiti status `OK` prije parsiranja

### FAZA 2 — Parsiranje NN izvora u strukturu
CILJ: Iz NN izvora dobiti strukturirani zapis članaka/stavaka za daljnju obradu.
ULAZ:
- arhivirani NN izvor (`izvor_nn.html` ili `izvor_nn.pdf`)
- `meta.json`
IZLAZ:
- strukturirani JSON članci (bez izmišljanja teksta)
PROVJERA:
- broj članaka i osnovna struktura su konzistentni s izvorom
- parser odvaja `Članak <broj> <RIMSKI>.` na broj članka + oznaku glave
- rimska oznaka glave se ne smije interpretirati kao dio broja članka
- parser normalizira tipfelere broja članka `I/l -> 1`
  (npr. `Članak I35.` -> `Članak 135.`)
- kada NN HTML vrati `Sadržaj je nedostupan` ili ne sadrži markere članka,
  parser mora aktivirati fallback na `eli_pdf_url` (ELI PDF), izvući tekst i
  proizvesti parsabilni izlaz (`izvor_nn.html`/`izvor_nn_issue.txt`) uz
  guardrail: `FOUND_MULTIPLE_ACTS_IN_PDF` -> fail (`exit 12`)
- fallback za issue PDF mora koristiti title-anchor slicing
  (`alati/eli_issue_pdf_slicer.py`) s poljem `pdf_title_anchor` iz source meta,
  kako bi se iz cijelog broja NN izdvojio samo ciljani akt prije parsiranja
- za `ustav_rh` vrijedi specifična korekcija anomalije `Članak 1 I.` -> čl. 11
   (uz položaj `10, 1(I), 12` i sadržajni keyword-check)
GATE:
- bez strukturiranog izlaza iz NN nema normiranja
- kontrola izvora mora biti `OK` prije pokretanja parsera

Sljedeći korak:
- normiranje iz NN strukture u NORMA JSON

### FAZA 2.1 — Validacija NN vs kontrolni izvor (zakon.hr)
CILJ: Usporediti strukturu članaka iz NN s kontrolnim tekstom zakon.hr radi
detekcije rupa i anomalija prije/uz normiranje.
ULAZ:
- `izvori/dokazno/narodne_novine/<akt_slug>/struktura_nn.json`
- `izvori/kontrolno/zakon_hr/<akt_slug>/<akt_slug>_kontrolni.txt`
- `izvori/dokazno/narodne_novine/<akt_slug>/izvor_nn.html`
IZLAZ:
- `baza_zakona/norme/<akt_slug>/IZVJESTAJ_VALIDACIJE_KONTROLNO.md`
PROVJERA:
- evidentirani `missing_in_nn`, `extra_in_nn`, `short_text_in_nn`
- heuristika anomalije bloka `Članak 10.`–`Članak 12.` (signal `Članak 1 I.`)
- validator ispisuje konkretne liste članaka (missing/extra/short) na stdout
  i u reportu, uz anomaly hints (`FOUND_BETWEEN_10_12` + ključne fraze)
- parser kontrolnog izvora je striktan: broji samo headere `Članak <N>` na
  početku retka (bez fallback hvatanja brojeva iz tijela teksta)
- kontrolni parser radi header-only nad linijama oblika `Članak N.` te ima
  sanitizaciju tipfelera `I/l -> 1` (npr. `Članak I35.` -> `135`)
- za `ustav_rh` parser i validator rade document split:
  `ustav_rh_procisceni` je odvojen od amandmana/promjena
  (`Ustavni zakon...`, `Promjena Ustava...`)
- normiranje i usporedba brojeva članaka rade se isključivo nad
  `ustav_rh_procisceni`; amandmani ostaju izdvojeni za evidenciju
- cutoff marker u kontrolnom TXT-u je obavezan signal početka amandmana;
  parser vodi `PROCISCENI_CUTOFF_MARKER`, `PROCISCENI_CHAR_LEN` i
  `AMANDMANI_CHAR_LEN` u reportu radi audit-traga
GATE:
- rezultat validacije ulazi u odluku o ručnim/automatiziranim parser pravilima

### FAZA 3 — Normiranje u NORMA JSON
CILJ: Iz strukturiranog NN izlaza generirati NORMA JSON zapise (chunk=članak).
ULAZ:
- strukturirani JSON iz faze 2
- kanonski `STANDARD_JSON_NORMA.md`
IZLAZ:
- NORMA JSON datoteke po člancima
- status sidra i integritet po zapisu
PROVJERA:
- ručno: uzmi 3 članka i citiraj ih čl./st./t. iz JSON-a
- provjeri da `stanje_na_dan` postoji i da je format `DD.MM.YYYY.`
- sanity-check OUT vs IN:
  `len(out) < 50` i `len(in) > 200` mora imati `BAD_COUNT = 0`
GATE:
- bez konzistentne NORMA baze ne prelazi se na postupke
- sanity-check OUT vs IN je obavezan prije prelaska na sljedeću fazu

Status pilot (18.02.2026.):
- pilot za `ustav_rh` je pokrenut iz `struktura_nn.json`
- ulazi: `struktura_nn.json` + `meta.json` iz NN arhive
- izlazi: `baza_zakona/norme/ustav_rh_procisceni/clanak_XXXX.json`
- artefakti: `IZVJESTAJ_NORMIRANJA.md` i integritet po članku
- za `ustav_rh` normiranje koristi `struktura_nn_dokumenti.json`
  i normira isključivo dokument `ustav_rh_procisceni`
  (amandmani su evidentirani u izvještaju, ali se ne normiraju)
- operativni izvor za `ustav_rh` je pročišćeni NN `85/2010`
  (`ustav_rh_nn_85_2010`), dok stariji `NN 56/1990` snapshot ostaje
  sačuvan u arhivi radi usporedbe i traga izvora
- nakon promjene operativnog izvora obavezno se generira diff izvještaj
  142 vs 152 (`IZVJESTAJ_DIFF_142_VS_152.md`) kao strojna kontrola
  dodanih/uklonjenih/promijenjenih članaka
- odabir operativnog izvora za `ustav_rh` je centraliziran i
  deterministički (`procisceni`-first) na temelju source meta polja:
  `tip_teksta`, `preferenca`, `ocekivani_broj_clanaka`
- svaki run mora generirati
  `izvori/dokazno/narodne_novine/USTAV_RH_SELECTION_REPORT.md`
  (audit ranking kandidata + odabrani source)
- validator mora signalizirati `SOURCE_SELECTION_MISMATCH` kada
  `NN_COUNT` odstupa od `ocekivani_broj_clanaka` odabranog izvora
- pre-flight guardrail je obavezan prije acceptance/prolaza:
  `exit 2` ako odabrani izvor nije `procisceni`, `exit 3` ako
  `NN_COUNT` odstupa od `ocekivani_broj_clanaka`
- standardni one-click run na Windowsu: `alati/acceptance_ustav_rh_preflight.ps1`
- uvedeni su generički entrypointi po `-AktSlug`:
  `alati/run_normiratelj.ps1` i `alati/acceptance_preflight.ps1`
  kako bi selection + guardrail bili primjenjivi na sve akte, ne samo `ustav_rh`
- validator podržava `-AktSlug` i standardizirani override prioritet
  (`VERITAS_<AKT_SLUG>_EXPECTED_COUNT_OVERRIDE` pa
  `VERITAS_EXPECTED_COUNT_OVERRIDE`, pa meta expected)

#### Paketi
- uveden je paketni acceptance runner (`alati/acceptance_paket.ps1`) koji
  učitava manifest i pokreće generički preflight po `-AktSlug` za svaki akt
- paketni izlaz koristi status kodove 0/20/21/22
  (`required fail`, `optional fail`, `manifest invalid`) i ostavlja
  `git status` čist nakon cleanup-a artefakata
- ingestiran je core akt `prekrsajni_zakon` kroz
  `INGEST_PREKRSAJNI_ZAKON_V1` (snapshot + parsiranje + normiranje +
  preflight pass)
- paket `PAKET_PREKRSAJNI_V1` više ne pada na missing-source za required core
  akt; trenutni paketni status ostaje `11` dok optional akti
  (`zakon_o_kaznenom_postupku`, `kazneni_zakon`) nisu ingestani
- za zakone s izmjenama i dopunama obavezan je paketni pristup (core +
  amandmani) kroz jedan manifest i generičke skripte (`ingest_paket.ps1`,
  `acceptance_paket.ps1`), bez novih per-zakon runnera
- paketni ingest za akte s `eli_pdf_url` upisuje i koristi
  `pdf_title_anchor` u source snapshot meta te automatski generira
  kontrolni TXT iz NN parsiranog izlaza prije preflighta
- paketni preflight je tip-aware po aktu (`tip_teksta`) i radi u
  strict modu po očekivanom tipu:
  `procisceni` za core operativni set, `amandmani` za amandmanske akte
- za `amandmani` guardrail ne traži `procisceni`; obavezno je
  `SELECTED_NN_TIP_TEKSTA=amandmani`, uz optional expected-count check
  i minimalni content sanity (`NN_COUNT >= 1` + prisutni `clanak_*.json`)

### FAZA 4 — Kontrola arhive (usporedba JSON ↔ NN izvor)
CILJ: Potvrditi da svaki akt koji postoji u NORMA bazi ima NN arhivu i meta hash.
ULAZ:
- `baza_zakona/norme/**`
- `izvori/dokazno/narodne_novine/**`
IZLAZ:
- izvještaj kontrole arhive sa statusima `OK`, `NEDOSTAJE`, `HASH_NEDOSTAJE`
PROVJERA:
- za svaki akt slug postoji kontrolni status i razlog
GATE:
- ako postoji `NEDOSTAJE` ili `HASH_NEDOSTAJE` za akt u predmetu,
  vanjski izlaz je zabranjen

### FAZA 5 — Standard JSON POSTUPAK (koraci) + minimalni set postupaka
CILJ: Postupci su opisani kao koraci, s hitnošću, rokovima, dokazima i
izlazom.
ULAZ:
- kanonski `STANDARD_JSON_POSTUPAK.md` (izraditi u ovoj fazi)
IZLAZ:
- `baza_postupaka/` sa barem 2 postupka:
  1) telekom: prigovor / reklamacija / eskalacija
  2) upravni: zahtjev / žalba / dopuna / prigovor roka
- svaki postupak ima 3–7 koraka, svaki korak ima gate + izlaz
PROVJERA:
- prođi jedan postupak “na suho” i provjeri da se svaki korak može izvršiti
  samo ako su dokazi navedeni
GATE:
- bez gate pravila nema “izlaza” dokumenta

### FAZA 6 — Standard “PREDMET” (slučaj) + lanac skrbništva
CILJ: Predmet je formalna jedinica rada: činjenice, dokazi, rokovi, odluke,
izlazi.
ULAZ:
- postojeći standardi NORMA i POSTUPAK
IZLAZ:
- uveden format `predmeti/<podrucje>/<naziv_predmeta>/`
- za predmet postoji:
  - `predmet.json` (meta + činjenice + rokovi + status)
  - `dokazi/` (prilozi)
  - `lanac_skrbnistva.json` (zapisi)
  - `izlazi/` (nacrti dokumenata)
  - `manifest.json` (popis datoteka + hash)
PROVJERA:
- dodaj 1 dokaz, izračunaj hash, upiši u manifest,
  evidentiraj lanac skrbništva
GATE:
- bez lanca skrbništva nema vanjskog paketa

### FAZA 7 — Testovi i validacije (gating)
CILJ: Sustav odbija pogrešne ulaze i sprječava “gluposti” prije nego izađu van.
ULAZ:
- dovršene faze 0–3
IZLAZ:
- validatori:
  - JSON schema provjera (NORMA/POSTUPAK/PREDMET)
  - provjera datuma `DD.MM.YYYY.`
  - provjera “potpis obavezan” za vanjski izlaz
  - provjera “sidro obavezno” za vanjski izlaz
PROVJERA:
- namjerno pokvari jednu normu i vidi da validator pada
GATE:
- bez validacije nema ozbiljne uporabe

### FAZA 8 — Predlošci i generator nacrta dokumenata
CILJ: Iz činjenica + citata normi + predloška generira se nacrt dokumenta.
ULAZ:
- minimalni predmet + norme + postupak
IZLAZ:
- `predlosci/` s barem:
  - prigovor (telekom)
  - zahtjev (upravni)
- generator (može biti skripta ili ručni proces u prvoj iteraciji) koji:
  - ubacuje činjenice
  - ubacuje citate normi
  - ubacuje popis priloga
  - generira nacrt u `predmeti/.../izlazi/`
PROVJERA:
- napravi nacrt dokumenta u 1 predmetu i provjeri da je citiranje ispravno
GATE:
- nacrt mora sadržavati “vrijedi tek nakon potpisa nositelja”

### FAZA 9 — Pilot end-to-end (bez agenata)
CILJ: Potvrditi puni tijek na jednom predmetu prije automatizacije.
ULAZ:
- 1 predmet, 1 prilog, 1 NORMA članak, 1 POSTUPAK i 1 predložak
IZLAZ:
- 1 nacrt dokumenta uz manifest i status izlaza prema gate pravilima
PROVJERA:
- predmet prolazi cijeli tijek ručno, bez agenata, uz kontrolu svih gate uvjeta
GATE:
- bez ove kontrolne faze nema uvođenja automatizacije

### FAZA 10 — Lokalni runtime: Ollama + agenti (bez cloud-a)
CILJ: Lokalni modeli služe kao pomoć, ali strogo unutar gate pravila.
ULAZ:
- baze normi i postupaka
IZLAZ:
- definiran minimalni skup agenata:
  1) agent za strukturiranje predmeta (činjenice → predmet.json)
  2) agent za citiranje normi (pretraži NORMA bazu, vrati citate)
  3) agent za proceduru (odaberi postupak i korake)
  4) agent za nacrt (predložak + činjenice + citati)
PROVJERA:
- jedan predmet prođe end-to-end: predmet → citati → koraci → nacrt
GATE:
- agenti ne smiju generirati vanjski izlaz bez sidra + potpisa

### FAZA 11 — Docker: reproducibilnost i izolacija
CILJ: Sve radi jednako na istoj mašini i kasnije na drugoj mašini.
ULAZ:
- postojeći docker compose kostur
IZLAZ:
- docker compose za minimalni runtime (bez “servisa viška”)
- mount repoa + pokretanje alata/generatora unutar kontejnera
PROVJERA:
- `docker compose up` i generiranje nacrta iz kontejnera
  (artefakt nastane u repou)
GATE:
- bez reproducibilnosti nema širenja sustava

### FAZA 12 — Prvi živi predmet (dokaz sustava)
CILJ: Jedan stvarni predmet se odradi od početka do kraja.
ULAZ:
- stvarni dokazi + činjenice
IZLAZ:
- uredan nacrt podneska + manifest + hash + lanac skrbništva
PROVJERA:
- nositelj pročita i potpiše (ili odbije) —
  sustav je ispravan neovisno o odluci
GATE:
- tek nakon ove faze se planira UI ili širenje baze zakona

---

## 5) Minimalni kriteriji kvalitete (ne pregovaramo)
1) Nema miješanja jezika.
2) Norma je citabilna.
3) Postupak je deterministički i gated.
4) Dokazi imaju hash i lanac skrbništva.
5) Vanjski izlaz je blokiran bez sidra i potpisa.
6) Jedan stvarni predmet prolazi end-to-end.

---

## 6) Pravilo rada (ritam)
Radimo “jedan korak po korak”:
- definiraj standard → zapiši u dokumentaciju → tek onda alat/agent.
Svaki značajan korak se bilježi u `DNEVNIK_RADA.md`.
