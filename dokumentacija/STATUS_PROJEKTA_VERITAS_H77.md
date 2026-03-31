# STATUS_PROJEKTA_VERITAS_H77

Datum: 31.03.2026.

## Snapshot repozitorija

- Trenutni commit: `b2fc7c5` - docs: pripremljen manifest ingest-a za
  vazeci zus (Z101)
- Repo čist: DA (pre-check `git status --short` bez izlaza)
- Zadnji dovršeni zadatak: ZADATAK 102
  (stvarni ingest vazećeg ZUS-a po paketnom manifestu)
- ZADATAK 89: plansko uskladjenje nakon zatvaranja rjecnickog toka
- ZADATAK 90: definiran prioritetni redoslijed konverzije zakona u JSON
- ZADATAK 92: za `zakon_o_opcem_upravnom_postupku` utvrdjen rezim
  konverzije prema kanonskom dokumentu
  `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`
- ZADATAK 93: pripremljen je manifest ingest-a
  `paketi/PAKET_ZUP_V1.json` (core + amandman + kontrolni izvor)
- ZADATAK 94: proveden je stvarni ingest paketa
  `paketi/PAKET_ZUP_V1.json` za core i amandman (`EXIT=0`), uz minimalnu
  korekciju manifesta (`tip_teksta` za core: `procisceni`)
- ZADATAK 95: proveden je kontrolni dohvat sa zakon.hr i usporedba
  `baza_zakona/norme/zakon_o_opcem_upravnom_postupku_procisceni/`
  naspram kontrolnog teksta
  `izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/`
  kroz postojeći validator `alati/validiraj_nn_vs_kontrolno.py`
  (CONTROL_COUNT=171, NN_COUNT=171, MISSING_COUNT=0)
  uz heuristicki signal `CONTROL_TRUNCATION_SUSPECTED=True`.
- ZADATAK 96: ciljano su sanirani članci iz SHORT_LIST (15 datoteka)
  uklanjanjem artefakata ingest-a (`". "` prefiks i prijelazni naslovi
  sljedećih cjelina) uz preračun integritetnih hash polja.
  Ponovljena validacija je potvrdila
  `CONTROL_COUNT=171`, `NN_COUNT=171`, `MISSING_COUNT=0` i
  `SHORT_COUNT=15` (članci ostaju kratki po sadržaju, bez truncation
  artefakta).
- ZADATAK 98: revidirana je heuristika u
  `alati/validiraj_nn_vs_kontrolno.py` za detekciju truncation signala
  kontrolnog izvora. Potvrdeno je da `SHORT_COUNT=15` predstavlja legitimno
  kratke članke, a ne truncation artefakt. Ponovljena validacija daje:
  `CONTROL_COUNT=171`, `NN_COUNT=171`, `MISSING_COUNT=0`,
  `SHORT_COUNT=15`, `CONTROL_TRUNCATION_SUSPECTED=False`.
- ZADATAK 99: utvrdjen je kanonski rezim konverzije za
  `zakon_o_upravnim_sporovima` u dokumentu
  `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`.
  Kako na NN pretrazi nije dokazan valjan procisceni signal,
  operativna odluka je:
  `REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL`.
- ZADATAK 100: rezim konverzije za
  `zakon_o_upravnim_sporovima` je ispravljen.
  ZUS se vodi po obrascu tipa `ustav_rh_procisceni`,
  kao jedan vazeci cjeloviti akt (`NN 36/2024`),
  bez koristenja starog niza izmjena i bez modela
  `prekrsajni_zakon` za vazeci ZUS.
- ZADATAK 101: pripremljen je manifest ingest-a
  `paketi/PAKET_ZUS_V1.json` za važeći
  `zakon_o_upravnim_sporovima` (`NN 36/2024`) kao jedan važeći
  cjeloviti akt po obrascu `ustav_rh_procisceni` s `zakon.hr` kao
  kontrolnim izvorom za validaciju.
  Ažurirana dokumentacija: `STATUS_PROJEKTA_VERITAS_H77.md`,
  `MAPA_DOKUMENTACIJE_VERITAS_H77.md`, `DNEVNIK_RADA.md`.
- ZADATAK 102: proveden je stvarni ingest po
  `paketi/PAKET_ZUS_V1.json` za važeći
  `zakon_o_upravnim_sporovima` kao jedan važeći akt (`NN 36/2024`).
  Manifest nije zahtijevao nikakav patch. Generirani su NN snapshot i
  parsirani izlazi pod
  `izvori/dokazno/narodne_novine/zakon_o_upravnim_sporovima/`,
  selection report
  `izvori/dokazno/narodne_novine/
  ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md`,
  kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  te operativni NORMA set pod
  `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/`.
  Paketni ingest i zasebni `acceptance_preflight` završili su s
  `exit=0`; preflight je potvrdio `NN_COUNT=172`, `MISSING_COUNT=0`,
  `EXTRA_LIST=[]`, `TIP_ACTUAL=procisceni`.
- Zadnji operativni paketni rjecnicki korak ostaje: ZADATAK 87
- Potpuno validiranih natuknica: 40
- Preostali homogeni nizovi za paketno zatvaranje: nema
- Postojeci uzorak rada za konverziju zakona u JSON ostaju:
  `ustav_rh_procisceni` i `prekrsajni_zakon_procisceni`
- Aktivni dokumentacijski guard: append-only zaštita
  `dokumentacija/DNEVNIK_RADA.md`
- Rezultat kontrolne usporedbe: STABILNO
  (nema missing/extra clanaka; nakon revizije heuristike
  `CONTROL_TRUNCATION_SUSPECTED=False`).
- Sljedeci logicki korak: kontrolna usporedba ZUS JSON seta sa
  `zakon.hr` za `zakon_o_upravnim_sporovima`.

## Pravilo sinkronizacije

- Kanonski izvor istine: GitHub (`nhursa77/Veritas_h77`)
- Jedina radna kopija: `C:\Veritas_H77`
- Google Disk: sinkronizirana kopija/backup/pregled, nije paralelni izvor
  uređivanja istih datoteka

Trenutno stanje sinkronizacije (pre-check):

- lokalni hash: `b2fc7c5`
- `git status --short`: prazan
- `main` poravnanje: poravnat
- lokalna detekcija tipičnih Drive putanja: nije potvrđena

## Aktivni gateovi

- `alati/ci_smoke.ps1`
- `alati/lint_markdown.ps1`
- `alati/test_fixtures_audit_prekrsaji_v1.ps1`

## Ključni standardi na snazi

- `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`
- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/STANDARD_JSON_POSTUPAK.md`
- `dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md`
- `dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md`
- `dokumentacija/STANDARD_JSON_HIJERARHIJA.md`
- `dokumentacija/STANDARD_JSON_PREDLOZAK.md`
- `dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
- `dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
- `dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
- `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`
- `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
- `dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
- `dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md`
- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`

## Faza po planovima i standardima

### RAZVOJNI_PLAN_VERITAS_H77.md

- Definira globalne faze 0-9 i gate logiku za cijeli sustav.
- Trenutni modul rada pripada prekršajnoj pilot domeni unutar tog okvira.
- CI i validacijski gateovi su obavezni za prolaz između faza.

### RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md

- P2 je dovršen za sva 4 toka (`TOK_PN_PRIGOVOR`,
  `TOK_PRESUDA_ZALBA`, `TOK_RJESENJE_ZALBA`, `TOK_OBUSTAVA`).
- P6 acceptance i fixture matrica su dovedeni do pokrivenosti kroz ZAD 50.
- Sljedeće po redu je P7 (E2E veza audit -> nacrt -> manifest).

### MAPA_DOKUMENTACIJE_VERITAS_H77.md

- Definira kanonske dokumente i redoslijed čitanja.
- Potvrđuje da su planovi i standardi prekršajnog modula aktivni.
- Upućuje na obavezne validatore i `ci_smoke` kao operativne gateove.

### DNEVNIK_RADA.md (zadnji pregledani blok)

- U završnom bloku su unosi za terminološke korake 52-63.
- Dnevnik sadrži dokazne naredbe po zadacima i commit tragu.
- Kronologija unosa je dokumentirana uz commit listu kao dokaz reda.

### Razlaganje višeznačnih sidara (ZADATAK 68)

- Dodana je skripta `alati/razlozi_viseznacna_nn_sidra_po_aktu.py`.
- Generirani su `kandidatske_podnatuknice_nn.json` i pripadni manifest.
- Kandidatske podnatuknice ostaju nekonačne i ručno validirane.

### Ispravak razlaganja kandidata (ZADATAK 69)

- Dodana je skripta `alati/ispravi_razlaganje_nn_kandidata.py`.
- Generirani su `kandidatske_podnatuknice_nn_v2.json` i pripadni v2 manifest.
- V2 kandidati razlažu se po pojedinom sidru, a ne samo po nadređenom pojmu.

### Sužavanje kandidata za ručnu validaciju (ZADATAK 70)

- Dodana je skripta `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`.
- Generirani su `konacni_nn_kandidati_za_validaciju.json` i pripadni
  manifest.
- Uveden je standard `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`.
- U ovom skupu nije bilo spajanja istog konteksta (`grupirani=0`), a svi
  kandidati ostaju za ručnu validaciju (`zadrzani=40`).

### Ručna validacija i upis potvrđenih sidara (ZADATAK 71)

- Dodana je skripta `alati/upisi_validirana_nn_sidra_u_natuknice.py`.
- Generirani su `osnovni_postupovni_skup_nn_validiran.json` i pripadni
  manifest.
- Uveden je standard `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`.
- Statusi validacije za 8 ciljanih pojmova su upisani u validirani sloj:
  `NN_VALIDIRANO=0`, `NN_DJELOMICNO_VALIDIRANO=8`,
  `CEKA_DALJNJU_RUCNU_VALIDACIJU=0`.

### Granska konsolidacija validiranih sidara (ZADATAK 72)

- Dodana je skripta `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`.
- Generirani su `granske_podnatuknice_nn.json` i pripadni manifest.
- Uveden je standard `STANDARD_GRANSKE_PODNATUKNICE_NN.md`.
- Za 8 ciljanih općih pojmova izvedena je deterministička granska podnatuknica
  po dokazivom kontekstu (`ukupno podnatuknica=8`).

### Sanacija i korekcija granske konsolidacije (ZADATAK 72A)

- Ispravljena je skripta `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`.
- Generirani su `granske_podnatuknice_nn_v2.json` i pripadni v2 manifest.
- Uklonjeno je lažno sažimanje `5 -> 1`; za svih 8 pojmova rezultat je
  `5 -> 5` po dokazivom normativnom kontekstu (`ukupno podnatuknica=40`).
- Pylance provjere za ciljane skripte su bez grešaka prije i poslije izmjene.

### Prva potpuno validirana granska natuknica (ZADATAK 73)

- Dodana je skripta `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`.
- Generirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Uveden je standard `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`.
- Deterministicki je zatvorena jedna natuknica iz v2 granskog sloja:
  `apsolutna nenadležnost — prekršajni zakon — čl. 101`.

### Druga potpuno validirana granska natuknica (ZADATAK 74B)

- Dodana je skripta `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Po strogom modelu zatvorena je nova natuknica različita od prve:
  `apsolutna nenadležnost — prekršajni zakon — čl. 102`.

### Sljedeca potpuno validirana granska natuknica (ZADATAK 75)

- Dodana je skripta `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Deterministicki je zatvorena tocno jedna nova natuknica nakon 101 i 102:
  `apsolutna nenadležnost — prekršajni zakon — čl. 103`.

### Jos jedna potpuno validirana granska natuknica (ZADATAK 76)

- Dodana je skripta
  `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Deterministicki je zatvorena tocno jedna nova natuknica nakon 101, 102 i
  103:
  `apsolutna nenadležnost — prekršajni zakon — čl. 122`.

### Stabilizacija dnevnika i analiza skoka niza (ZADATAK 77)

- Dodana je skripta `alati/dodaj_dnevnicki_unos_na_kraj.ps1` kao kanonska
  append-only metoda upisa na EOF.
- Dopunjen je `STANDARD_ZASTITA_DNEVNIKA_RADA.md` zabranom kontekstnog
  umetanja dnevnickog unosa po sredini datoteke.
- Izradena je dokumentacija
  `dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`.
- Potvrdeno je da je skok `103 -> 122` ispravan jer u ulaznom nizu za taj
  pojam ne postoje clanci `104-121`.

### Paketno zatvaranje homogenog niza (ZADATAK 78)

- Dodana je skripta
  `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Paketno je zatvoren preostali jednoznacni clanak iz niza
  `apsolutna nenadležnost — prekršajni zakon`: `čl. 161`.
- Izvan paketa su evidentirane vec zatvorene stavke `101`, `102`, `103`,
  `122` kao preskocene u manifestu s razlogom.

### Rangiranje sljedeceg homogenog niza (ZADATAK 79)

- Dodana je skripta `alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`.
- Generirani su:
  `rang_lista_homogenih_nizova_za_paket.json` i pripadni manifest.
- Korak je analiza-only: broj novih zatvaranja u ovom zadatku je `0`.
- Top preporuka za sljedeci paket je niz:
  `dokaz` + `prekrsajni_zakon` (score `550`).

### Paketno zatvaranje homogenog niza dokaz (ZADATAK 80)

- Dodana je skripta `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Skripta obavezno provjerava rang-manifest i potvrdu preporuke:
  `dokaz` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `78`, `85`, `87`,
  `88`, `89`.
- Broj potpuno validiranih natuknica je povecan s `5` na `10`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 81)

- Dodana je skripta `alati/zatvori_paket_dostava_prekrsajni_zakon.py`.
- Odabrani niz je `dostava` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon` i
  `dokaz` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `114`, `117`,
  `118`, `122`, `87`.
- Broj potpuno validiranih natuknica je povecan s `10` na `15`.

### Paketno zatvaranje novog homogenog niza (ZADATAK 82)

- Dodana je skripta `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`.
- Odabrani niz je `izvršenje` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon` i `dostava` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `13`, `14`, `34`,
  `42`, `44`.
- Broj potpuno validiranih natuknica je povecan s `15` na `20`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 83)

- Dodana je skripta `alati/zatvori_paket_presuda_prekrsajni_zakon.py`.
- Odabrani niz je `presuda` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon` i
  `izvršenje` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `33`, `40`, `99`,
  `106`, `109`.
- Broj potpuno validiranih natuknica je povecan s `20` na `25`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 84)

- Dodana je skripta `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`.
- Odabrani niz je `prigovor` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon`,
  `izvršenje` + `prekrsajni_zakon` i `presuda` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `93`, `102`, `120`,
  `121`, `221`.
- Broj potpuno validiranih natuknica je povecan s `25` na `30`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 85)

- Dodana je skripta `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`.
- Odabrani niz je `rješenje` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon`,
  `izvršenje` + `prekrsajni_zakon`, `presuda` + `prekrsajni_zakon` i
  `prigovor` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `34`, `59`, `89`,
  `92`, `99`.
- Broj potpuno validiranih natuknica je povecan s `30` na `35`.

### Paketno zatvaranje homogenog niza zalba (ZADATAK 87)

- Dodana je skripta `alati/zatvori_paket_zalba_prekrsajni_zakon.py`.
- Odabrani niz je `žalba` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: zadnji preostali homogeni niz s otvorenim i jednoznacno
  spremnim kandidatima nakon zatvaranja nizova
  `apsolutna nenadležnost`, `dokaz`, `dostava`, `izvršenje`, `presuda`,
  `prigovor` i `rješenje` za isti akt.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `87`, `89`, `95`,
  `99`, `100`.
- Broj potpuno validiranih natuknica je povecan s `35` na `40`.
- Osvjezena je rang-lista homogenih nizova i potvrdeno je da vise nema
  preostalih preporucenih nizova za paketno zatvaranje.
