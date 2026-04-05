# Dubinska analiza skupine `zatvori_paket_*_prekrsajni_zakon.py`

Datum: 05.04.2026.

## A) Polazni git dokaz

Obvezni pre-check je pokrenut prije bilo kakve izrade dokumenta.

Stanje repoa:

- `git status --short` -> bez izlaza
- `git diff --name-only` -> bez izlaza
- `git diff --cached --name-only` -> bez izlaza

Zadnji commit:

- `05bcbc2` — `feat: uklonjeni wrapperi granskih natuknica nakon`
  `konsolidacije`

Stanje grane:

- `git branch -vv` pokazuje:
  `* main 05bcbc2 [origin/main] feat: uklonjeni wrapperi granskih`
  `natuknica nakon konsolidacije`

Poravnanje s `origin/main`:

- lokalni `HEAD` je `05bcbc2`
- `git ls-remote --heads origin main` vraca hash koji pocinje s
  `05bcbc258dd2015d45b0fccf70a25be191d63455`
- lokalni `main` i `origin/main` su poravnati

Stash:

- `git stash list` i dalje pokazuje samo:
  `stash@{0}: On main: veritas-pre-rebase-z147`
- stash nije diran

Zakljucak polaznog dokaza:

- repo je bio cist
- analiza je radena read-only nad postojecim kodom
- jedini novi artefakt ovog zadatka je ovaj dokument

## B) Tocan scope analize

Procitani clanovi skupine koji stvarno postoje u repou:

- `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`
- `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`
- `alati/zatvori_paket_dostava_prekrsajni_zakon.py`
- `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`
- `alati/zatvori_paket_presuda_prekrsajni_zakon.py`
- `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`
- `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`
- `alati/zatvori_paket_zalba_prekrsajni_zakon.py`

Dodatni procitani kontekst:

- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`

Napomena o stvarnom scopeu:

- u ovoj obitelji postoji ukupno `8` clanova
- svi su obuhvaceni analizom
- nije pronaden dodatni deveti clan iste obitelji

## C) Analiza po skripti

### C1) `zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`

Cemu sluzi:

- paketno zatvara jednoznacne podnatuknice za pojam
  `apsolutna nenadležnost` unutar akta `prekrsajni_zakon`

Ulazni argumenti:

- `--input`
- `--input-manifest`
- `--existing-validated`
- `--existing-validated-manifest`
- `--output`
- `--output-manifest`

Sto cita:

- `granske_podnatuknice_nn_v2.json`
- `granske_podnatuknice_nn_v2_manifest.json`
- `potpuno_validirane_natuknice.json`
- `potpuno_validirane_natuknice_manifest.json`

Sto pise:

- opet pise u `potpuno_validirane_natuknice.json`
- opet pise u `potpuno_validirane_natuknice_manifest.json`

Glavne funkcije i koraci:

- `_load_json`, `_write_json`, `_norm`
- `_sidro_signature`, `_selection_sort_key`, `_validated_identity`
- `_sidra_for_manifest`, `_check_eligibility`
- `run` filtrira samo ciljnu kombinaciju pojma i akta
- iskljucuje vec zatvorene clanke `101`, `102`, `103`, `122`
- nove retke dopunjava statusom `POTPUNO_VALIDIRANO`

Kljucna razlika prema ostalima:

- jedina ima `EXCLUDE_CLOSED_ARTICLES`
- ciljni pojam i akt su potpuno hardkodirani
- ne cita rang-listu

### C2) `zatvori_paket_dokaz_prekrsajni_zakon.py`

Cemu sluzi:

- paketno zatvara homogeni niz `dokaz` za `prekrsajni_zakon`

Ulazni argumenti:

- svi argumenti iz C1
- dodatno `--ranking-manifest`

Sto cita:

- iste ulazne i izlazne JSON datoteke kao C1
- dodatno `rang_lista_homogenih_nizova_za_paket_manifest.json`

Sto pise:

- iste dvije izlazne strukture kao C1

Glavne funkcije i koraci:

- dijeli istu jezgru helper-funkcija kao C1
- uvodi `_validate_recommendation`
- prije zatvaranja provjerava da je preporuka iz rang-manifesta bas
  `dokaz` + `prekrsajni_zakon`
- zatim radi isti append u potpuno validirane natuknice

Kljucna razlika prema ostalima:

- i dalje je hardkodiran pojam `dokaz`
- ali vec uvodi vanjsku potvrdu iz rang-manifesta
- to je prijelazni korak prema generickijem obrascu

### C3) `zatvori_paket_dostava_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara prvi sljedeci preporuceni homogeni niz nakon vec obradenih
  nizova `apsolutna nenadležnost` i `dokaz`

Ulazni argumenti:

- `--ranking`
- `--ranking-manifest`
- svi standardni ulazno-izlazni argumenti iz C1

Sto cita:

- iste radne JSON datoteke kao C1
- `rang_lista_homogenih_nizova_za_paket.json`
- `rang_lista_homogenih_nizova_za_paket_manifest.json`

Sto pise:

- iste dvije izlazne strukture kao i svi ostali clanovi skupine

Glavne funkcije i koraci:

- uvodi `_pick_target_from_ranking`
- koristi `EXCLUDED_ALREADY_PROCESSED` da preskoci vec obradene nizove
- iz rang-liste uzima prvi sljedeci preporuceni niz
- onda pokrece istu provjeru jednoznacnosti i isti append u izlazni JSON

Kljucna razlika prema ostalima:

- ovo je prvi clan koji pojam ne bira samo hardkodirano nego ga uzima iz
  rang-liste
- jos nema `EXPECTED_TARGET_POJAM` sigurnosnu provjeru

### C4) `zatvori_paket_izvrsenje_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara niz `izvršenje` za `prekrsajni_zakon`

Ulazni argumenti:

- isti kao C3

Sto cita i pise:

- iste strukture kao C3 i ostali clanovi skupine

Glavne funkcije i koraci:

- ista jezgra kao u C3
- ima `EXPECTED_TARGET_POJAM = "izvršenje"`
- provjerava da je izabrani niz iz rang-liste stvarno uskladen sa
  skriptom
- sortira zavrsne popise clanaka i preskocenih stavki

Kljucna razlika prema ostalima:

- razlika je gotovo samo u ciljnom pojmu i prosirenom skupu vec
  obradenih nizova

### C5) `zatvori_paket_presuda_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara niz `presuda` za `prekrsajni_zakon`

Ulazni argumenti:

- isti kao C3 i C4

Sto cita i pise:

- iste ulazne i izlazne strukture kao C4

Glavne funkcije i koraci:

- ista jezgra helpera i isti `run` obrazac
- `EXPECTED_TARGET_POJAM = "presuda"`
- isti kriteriji podobnosti: jedinstven `akt_slug`, jedinstven potpis
  sidra, uskladeni `broj_nn` i `naziv_akta`, puna opisna polja

Kljucna razlika prema ostalima:

- funkcionalna razlika je svedena na odabrani pojam i tekst napomene u
  manifestu

### C6) `zatvori_paket_prigovor_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara niz `prigovor` za `prekrsajni_zakon`

Ulazni argumenti:

- isti kao C3, C4 i C5

Sto cita i pise:

- iste JSON strukture kao i ostale skripte u obitelji

Glavne funkcije i koraci:

- opet koristi `_pick_target_from_ranking`
- opet potvrduje `EXPECTED_TARGET_POJAM = "prigovor"`
- opet dodaje iste izlazne kljuceve i isti status zatvaranja

Kljucna razlika prema ostalima:

- nema novu poslovnu logiku; razlikuje se gotovo samo po parametru
  ciljnog niza

### C7) `zatvori_paket_rjesenje_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara niz `rješenje` za `prekrsajni_zakon`

Ulazni argumenti:

- isti kao C3 do C6

Sto cita i pise:

- iste ulazno-izlazne strukture kao ostali clanovi skupine

Glavne funkcije i koraci:

- identican obrazac kao kod `izvrsenje`, `presuda` i `prigovor`
- jedina bitna konstanta je `EXPECTED_TARGET_POJAM = "rješenje"`
- ista logika sortiranja i zapisivanja manifesta

Kljucna razlika prema ostalima:

- razlika opravdava parametar, ali ne i zasebnu jezgru logike

### C8) `zatvori_paket_zalba_prekrsajni_zakon.py`

Cemu sluzi:

- zatvara niz `žalba` za `prekrsajni_zakon`
- nakon toga osvjezava rang-listu kako bi pokazala da nema vise
  preporucenih homogenih paketa

Ulazni argumenti:

- isti kao C3 do C7

Sto cita:

- iste ulaze kao C7
- na kraju poziva i `alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`

Sto pise:

- iste dvije izlazne strukture kao i ostali clanovi skupine
- posredno osvjezava i rang-listu preko zasebnog helpera

Glavne funkcije i koraci:

- ista paketna jezgra zatvaranja kao C4 do C7
- `EXPECTED_TARGET_POJAM = "žalba"`
- nakon `run(...)` u `main()` izvodi:
  `subprocess.run([sys.executable, str(ranking_script)], check=True)`
- ispisuje `RANG_LISTA_OSVJEZENA=True`

Kljucna razlika prema ostalima:

- jedina ima dodatni post-korak za osvjezavanje rang-liste
- i ta razlika je i dalje parametarski ili post-hook karaktera, a ne
  nova jezgra poslovne logike

## D) Usporedna matrica

Usporedni pregled po trazenim stupcima:

- Skripta: `apsolutna_nenadleznost`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `TARGET_POJAM` + `TARGET_AKT_SLUG` + `EXCLUDE_CLOSED_ARTICLES`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `dokaz`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    fiksni pojam + provjera `ranking_manifest`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `dostava`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` nakon iskljucenja vec obradenih nizova
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `izvrsenje`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` + `EXPECTED_TARGET_POJAM`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `presuda`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` + `EXPECTED_TARGET_POJAM`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `prigovor`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` + `EXPECTED_TARGET_POJAM`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `rjesenje`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` + `EXPECTED_TARGET_POJAM`
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

- Skripta: `zalba`
  - zajednicka jezgra logike: `DA`
  - specificni kriterij vrste paketa:
    `ranking-next` + `EXPECTED_TARGET_POJAM` + refresh rang-liste
  - pise li u iste strukture: `DA`
  - moze li biti parametar umjesto zasebne datoteke: `DA`
  - procjena: `KANDIDAT_ZA_KONSOLIDACIJU`

Sažetak matrice:

- svih `8/8` skripti pise u iste dvije kanonske JSON strukture
- svih `8/8` skripti koriste gotovo isti set helper-funkcija
- glavna razlika je odabir ciljnog pojma i mali broj zastitnih guardova
- stvarna poslovna jezgra je zajednicka

## E) Procjena rizika konsolidacije

Procjena razine rizika:

- `SREDNJI_RIZIK`

Zasto nije `NISKI_RIZIK`:

- ove skripte ne rade samo analizu nego mijenjaju kanonsku datoteku
  `potpuno_validirane_natuknice.json`
- greska u parametrizaciji moze zatvoriti pogresan homogeni niz ili
  promijeniti redoslijed i sadrzaj manifesta

Zasto nije `VISOKI_RIZIK`:

- kod pokazuje vrlo velik stupanj ponavljanja
- zajednicka jezgra je jasno vidljiva i stabilna
- razlike su uglavnom:
  - fiksni pojam
  - skup vec obradenih nizova
  - provjera rang-manifesta
  - opcionalni post-korak osvjezavanja rang-liste

Sto mora biti dokazano prije refaktora:

1. da genericki alat na istim ulazima proizvede isti izlazni JSON i isti
   manifest kao svih osam zasebnih skripti
2. da redoslijed `popis_novozatvorenih_clanaka_u_paketu` ostane isti
3. da `zalba` i dalje moze opcionalno osvjeziti rang-listu na kraju
4. da postojece CLI ulazne putanje i status-poruke ostanu kompatibilne

Postoji li smisao za jedan genericki alat:

- `DA`
- na temelju stvarno procitanog koda smislen je jedan genericki alat koji
  bi primao barem:
  - ciljni pojam
  - `akt_slug`
  - nacin odabira cilja (`fixed`, `ranking-confirmed`, `ranking-next`)
  - popis vec obradenih nizova
  - opcionalni post-hook za osvjezavanje rang-liste

Najsigurniji prvi refaktorski korak:

- ne brisati ovih osam skripti u prvom koraku
- prvo uvesti jednu zajednicku jezgru ili jedan genericki alat
- postojece skripte privremeno ostaviti kao tanke wrappere dok se ne
  potvrdi da je izlaz 1:1 isti

## F) Zakljucak

`SKUPINA_JE_KANDIDAT_ZA_KONSOLIDACIJU`

Sljedeci smisleni zadatak:

- uvesti jedan genericki alat za paketno zatvaranje homogenih nizova za
  `prekrsajni_zakon`, zadrzati postojecih osam skripti kao tanke wrappere
  u prvom koraku i obvezno azurirati
  `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`
