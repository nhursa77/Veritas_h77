# INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA

Datum: 31.03.2026.
Status: kanonski
Opseg: analitička inventura postojećeg obrasca za pretvaranje zakona s
amandmanima u JSON na temelju stvarnog sadržaja repoa.

---

## 1) Što već postoji u repou

### Djelomični obrazac već postoji kao skup više kanonskih dokumenata

Postojeći djelomični obrazac trenutačno zajedno čine:

- `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `alati/ingest_paket.ps1`
- `alati/parsiraj_nn_html.py`
- `alati/validiraj_nn_vs_kontrolno.py`

### Što je već kanonski definirano

#### `core + amandmani`

Kanonska odluka da se zakon vodi modelom `core + amandmani` već postoji u
`dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.

Taj dokument jasno definira:

- kada se bira model pročišćenog akta
- kada se mora birati model izvornog akta plus amandmani
- da je za ZPD odabran `PREKRSAJNI_ZAKON_MODEL`

#### NN dokazni izvor

Primat Narodnih novina već je kanonski definiran kroz:

- `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `alati/parsiraj_nn_html.py`

Već je definirano da su Narodne novine primarni dokazni izvor i da parser
izvlači stvarni člankovni tok iz NN HTML-a, uz ELI PDF fallback kad HTML nije
dostupan ili nema članke.

#### Kontrolni `zakon.hr` sloj

Kontrolni sloj već je djelomično kanonski definiran kroz:

- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `alati/ingest_paket.ps1`
- `alati/validiraj_nn_vs_kontrolno.py`

Već je definirano da je `zakon.hr` pomoćni kontrolni izvor, a ne primarni
dokazni temelj, te da se kontrolni TXT i pripadni meta tragovi vode odvojeno
od NN dokaznog sloja.

#### Sidra

Sidra su djelomično kanonski definirana kroz:

- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
- `alati/ingest_paket.ps1`

Već je definirano:

- da svaki članak treba dokazno sidro ili status nepotpunosti
- da je `status_sidra` obvezan signal
- da se amandmanski izlazi vode pod `baza_zakona/sidra/<akt_slug>/`

#### Validacija

Validacijski sloj već je djelomično kanonski definiran kroz:

- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `alati/validiraj_nn_vs_kontrolno.py`
- `alati/ingest_paket.ps1`

Već su definirani:

- kriteriji `MISSING_COUNT`, `EXTRA_LIST`, `SHORT_COUNT`
- truncation i anomaly guardraili
- source-selection guardrail
- razlika između tvrdog fail signala i toleriranog odstupanja

#### Završni izvještaj

Završni izvještaj već postoji za ZPD kroz
`dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`.

Taj dokument već definira završni pregled jednog konkretnog zakona koji je
obrađen modelom `core + amandmani`, ali ne definira opći kanonski obrazac za
sve buduće zakone tog tipa.

## 2) Što nedostaje

Još ne postoji jedan objedinjeni kanonski dokument koji od početka do kraja
opisuje obrazac za pretvaranje zakona s amandmanima u JSON.

Nedostaje objedinjeni dokument koji bi na jednom mjestu povezao:

- kriterij odluke za izbor modela `core + amandmani`
- strukturu manifesta
- pravila za NN dokazni sloj
- pravila za parsiranje i razdvajanje dokumenata
- razliku između `norme/` i `sidra/`
- pravila za kontrolni `zakon.hr` sloj
- kanonske validacijske kriterije
- pravila za završni izvještaj na razini cijelog zakona

Drugim riječima, repou ne nedostaju činjenice i mehanizmi, nego im nedostaje
jedinstvena kanonska sinteza u jednom dokumentu.

## 3) Što treba dodati

Budućem kanonskom dokumentu treba dodati barem ove sekcije:

1. svrhu i opseg obrasca za zakone s amandmanima
2. ulazni kriterij za izbor modela `core + amandmani`
3. obveznu strukturu paketa i manifesta
4. pravila za NN dokazni sloj i dopuštene fallback mehanizme
5. pravila parsiranja i razdvajanja `procisceni` naspram `amandmani`
6. pravila izlaza u `baza_zakona/norme/` za core i `baza_zakona/sidra/` za
   amandmane
7. ulogu i ograničenja kontrolnog sloja `zakon.hr`
8. obvezne validacijske metrike i tumačenje rezultata
9. pravila kada je patch parsera ili validatora dopušten, a kada nije
10. obvezne završne artefakte i dokumentacijski trag za jedan zakon
11. Definition of Done za zakon obrađen tim obrascem

## 4) Prijedlog konačne strukture budućeg kanonskog dokumenta

Predložena konačna struktura budućeg kanonskog dokumenta obrasca:

1. svrha i opseg
2. kada se bira model zakona s amandmanima
3. ulazni artefakti i manifest paketa
4. dokazni NN sloj
5. parser i razdvajanje dokumenata
6. operativni JSON izlazi: core norme i amandmanska sidra
7. kontrolni `zakon.hr` sloj
8. validacija i guardrail pravila
9. tolerirana odstupanja naspram tvrdih fail signala
10. završni izvještaj za zakon
11. dokumentacijski trag, gateovi i završni git dokazi
12. Definition of Done

Takav dokument bio bi opći obrazac, dok bi postojeći ZPD dokumenti ostali
primjeri stvarne primjene tog obrasca.

## 5) Jasan zaključak

Jasan zaključak je:

- još nemamo jedan objedinjeni kanonski dokument obrasca za pretvaranje
  zakona s amandmanima u JSON
- imamo više kanonskih dokumenata i alata koji zajedno već čine djelomični,
  funkcionalni obrazac
- sljedeći logički korak je izraditi jedan opći kanonski dokument koji će te
  postojeće elemente spojiti u jedinstveni standard
