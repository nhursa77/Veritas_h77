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
7) Operativni tekst normi: zakon.hr (pročišćeni tekst) —
   ali dokazno sidro: Narodne novine (ili drugi službeni izvor).
8) Ne ide se na skaliranje i UI prije nego što MVP end-to-end radi na jednom
   stvarnom predmetu.

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
  `STANDARD_JSON_NORMA.md`
- `DNEVNIK_RADA.md` (uvodi se čim počnemo standardizirane radove)
PROVJERA:
- `git status` čist
- warnings o EOL svedeni na nulu (ili objašnjeni i prihvaćeni)
GATE:
- bez ove faze nema novih standarda ni alata

### FAZA 1 — Standard JSON NORMA (članak) + minimalni set normi
CILJ: Imamo minimalnu bazu normi u JSON formatu, citabilnu i stabilnu.
ULAZ:
- kanonski `STANDARD_JSON_NORMA.md`
IZLAZ:
- `baza_normi/` sa barem:
  - `ustav_rh` (minimalno ključni članci koji se često citiraju u praksi)
  - jedan procesni zakon (npr. ZUP ili ZPP) u minimalnom opsegu (pilot)
- svaka norma ima:
  - operativni izvor (zakon.hr)
  - dokazna sidra (NN) ili status `djelomicno` uz napomenu
PROVJERA:
- ručno: uzmi 3 članka i citiraj ih čl./st./t. iz JSON-a
- provjeri da `stanje_na_dan` postoji i da je format `DD.MM.YYYY.`
GATE:
- bez minimalne baze normi ne prelazimo na postupke

### FAZA 2 — Standard JSON POSTUPAK (koraci) + minimalni set postupaka
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

### FAZA 3 — Standard “PREDMET” (slučaj) + lanac skrbništva
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

### FAZA 4 — Predlošci i generator nacrta dokumenata
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

### FAZA 5 — Verifikacija izvora: zakon.hr (operativno) + NN (sidra)
CILJ: Sustav razlikuje operativni tekst i dokazno sidro, i zna status sidra.
ULAZ:
- norma JSON zapisi
IZLAZ:
- pravilo: “operativno = zakon.hr, dokazno = NN”
- mehanizam (ručno ili skripta) da se za normu unesu NN sidra
PROVJERA:
- za 5 normi potvrdi `status_sidra_norme = puno` s konkretnim sidrima
GATE:
- bez sidra: dokument može biti samo interna priprema, ne vanjski izlaz

### FAZA 6 — Lokalni runtime: Ollama + agenti (bez cloud-a)
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

### FAZA 7 — Docker: reproducibilnost i izolacija
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

### FAZA 8 — Testovi i validacije (gating)
CILJ: Sustav odbija pogrešne ulaze i sprječava “gluposti” prije nego izađu van.
ULAZ:
- sve prethodne faze
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

### FAZA 9 — Prvi živi predmet (dokaz sustava)
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
