# DUBINSKA_ANALIZA_SKUPINE_ZATVORI_VALIDIRANU_GRANSKU_NATUKNICU

Datum: 04.04.2026.
Status: read-only dubinska analiza.
Opseg: samo skupina `zatvori_*_validiranu_gransku_natuknicu.py`,
bez izmjene postojećih skripti, bez commita i pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrđeno stanje prije izrade ovog dokumenta:

- lokalni HEAD: `5fda624`
- zadnji commit:
  - `5fda624` - `docs: revizija alata i preporuke ciscenja`
- grana: `main`
- stanje grane: `main` je poravnat s `origin/main`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git status --short`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`
- `git ls-remote --heads origin main`: hash odgovara lokalnom HEAD-u

Zaključak pre-checka:

- repozitorij je bio čist za ovu read-only analizu
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Točan scope analize

### Ciljane skripte

Analizirane su točno ove 4 skripte:

- `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

### Dopušteni kontekst koji je stvarno pročitan

- `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`

### Dodatni alati izvan skupine

- nisu čitani dodatni alati izvan dopuštenog minimuma

---

## C) Analiza po skripti

### C1) `zatvori_prvu_validiranu_gransku_natuknicu.py`

#### C1.1 Čemu služi

Služi za inicijalno zatvaranje prve potpuno validirane granske
podnatuknice i za stvaranje početne datoteke
`potpuno_validirane_natuknice.json`.

#### C1.2 Ulaz

Argumenti:

- `--input`
- `--input-manifest`
- `--output`
- `--output-manifest`

Zadane putanje su:

- ulaz:
  `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json`
- ulazni manifest:
  `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json`
- izlaz:
  `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- izlazni manifest:
  `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

#### C1.3 Izlaz

Piše isti par izlaznih struktura kao i ostale skripte:

- `potpuno_validirane_natuknice.json`
- `potpuno_validirane_natuknice_manifest.json`

Ali to radi kao `init` korak: ne čita postojeći izlaz, nego ga gradi od nule.

#### C1.4 Glavne funkcije i koraci

Zajednička jezgra uključuje:

- `_load_json`
- `_write_json`
- `_norm`
- `_sidro_signature`
- `_has_clear_act_slug`
- `_has_unambiguous_context`
- `_has_no_contradictory_sidra`
- `_can_describe_without_invented_definition`
- `_does_not_require_additional_split`
- `_is_eligible`
- `_selection_sort_key`
- `_sidra_for_manifest`
- `run`
- `parse_args`
- `main`

Logika odabira je:

1. učitaj sve `granske_podnatuknice`
2. filtriraj samo redove koji prolaze `_is_eligible`
3. sortiraj po:
   - `kanonski_naziv_podnatuknice`
   - `podnatuknica_id`
4. uzmi prvi rezultat
5. upiši ga kao jedinu stavku izlaza

#### C1.5 Ključna razlika prema ostalima

Ova skripta je jedina koja nema `append` logiku i ne čita postojeći skup
već zatvorenih natuknica.

### C2) `zatvori_drugu_validiranu_gransku_natuknicu.py`

#### C2.1 Čemu služi

Služi za zatvaranje druge potpuno validirane podnatuknice nakon što prva
već postoji u izlaznom JSON-u i manifestu.

#### C2.2 Ulaz

Argumenti:

- `--input`
- `--input-manifest`
- `--existing-validated`
- `--existing-validated-manifest`
- `--output`
- `--output-manifest`

Dakle, za razliku od prve skripte, ova čita i postojeći izlazni skup.

#### C2.3 Izlaz

Piše u iste dvije izlazne datoteke kao i prva skripta, ali uz
`updated_rows = list(existing_rows)` i dodavanje jedne nove stavke.

#### C2.4 Glavne funkcije i koraci

Jezgra funkcija je gotovo ista kao u prvoj skripti.
Dodatno uvodi:

- `_validated_identity`
- učitavanje `previous_manifest`
- isključenje već zatvorenih natuknica iz kandidata

Logika odabira je:

1. učitaj ulazni skup i postojeći validirani skup
2. izračunaj `existing_identities`
3. izbaci već zatvorene natuknice
4. filtriraj `_is_eligible`
5. sortiraj po:
   - `kanonski_naziv_podnatuknice`
   - `podnatuknica_id`
6. dodaj jednu novu natuknicu u postojeći izlaz

#### C2.5 Ključna razlika prema ostalima

- više nije `init`, nego `append`
- manifest bilježi samo jednu prethodno zatvorenu natuknicu kroz polje
  `prethodno_zatvorena_natuknica`
- status je specifično imenovan kao
  `DRUGA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA`

### C3) `zatvori_sljedecu_validiranu_gransku_natuknicu.py`

#### C3.1 Čemu služi

Služi za zatvaranje sljedeće potpuno validirane podnatuknice nakon što u
izlazu već postoji više prethodno zatvorenih stavki.

#### C3.2 Ulaz

Ulazni argumenti su isti kao u drugoj skripti:

- `--input`
- `--input-manifest`
- `--existing-validated`
- `--existing-validated-manifest`
- `--output`
- `--output-manifest`

#### C3.3 Izlaz

Piše u iste dvije izlazne strukture:

- `potpuno_validirane_natuknice.json`
- `potpuno_validirane_natuknice_manifest.json`

#### C3.4 Glavne funkcije i koraci

Jezgra je opet gotovo ista, ali postoji važna razlika u odabiru:

- uvodi `_first_article_value`
- uvodi `_article_sort_key`
- `_selection_sort_key` više nije samo `naziv + id`, nego:
  - `kanonski_naziv_podnatuknice`
  - članak prvog sidra
  - `podnatuknica_id`

Time ova skripta daje stroži i eksplicitniji deterministički poredak.

Manifest također više ne bilježi samo jednu prethodnu stavku, nego listu:

- `prethodno_zatvorene_natuknice`

#### C3.5 Ključna razlika prema ostalima

- odabir je precizniji nego u skripti `drugu`
- naziv joj je već opći i ne vezuje se uz samo jedan ordinalni korak
- najviše nalikuje mogućem generičkom alatu

### C4) `zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

#### C4.1 Čemu služi

Formalno služi za zatvaranje još jedne potpuno validirane podnatuknice.

#### C4.2 Ulaz

Ulazni argumenti su isti kao u skripti `sljedecu`:

- `--input`
- `--input-manifest`
- `--existing-validated`
- `--existing-validated-manifest`
- `--output`
- `--output-manifest`

#### C4.3 Izlaz

Piše u iste dvije izlazne strukture kao i skripta `sljedecu`.

#### C4.4 Glavne funkcije i koraci

Po stvarno pročitanom kodu, ova skripta ima istu jezgru kao i skripta
`sljedecu`:

- iste pomoćne funkcije
- isti `_selection_sort_key`
- isto isključivanje `existing_identities`
- isto `append` ponašanje nad `updated_rows`
- istu listu `prethodno_zatvorene_natuknice`

#### C4.5 Ključna razlika prema ostalima

Razlika je praktično samo u:

- status stringu
  `JOS_JEDNA_POTPUNO_VALIDIRANA_NATUKNICA_ZATVORENA`
- tekstu opisa u `argparse` i `napomena_veritas`

Funkcionalna razlika prema skripti `sljedecu` iz pročitanog koda nije
stvarno dokazana.

---

## D) Usporedna matrica

- `zatvori_prvu_validiranu_gransku_natuknicu.py`
  - `zajednička jezgra logike`:
    isti helperi za JSON, normiranje i `_is_eligible`
  - `specifični kriterij odabira`:
    prvo po `kanonski_naziv_podnatuknice`, zatim `podnatuknica_id`
  - `piše li u iste strukture`:
    da, isti izlazni JSON i isti manifest
  - `može li biti parametar umjesto zasebne datoteke`:
    da, kao `--mode init`
  - `procjena`:
    `KANDIDAT_ZA_KONSOLIDACIJU`

- `zatvori_drugu_validiranu_gransku_natuknicu.py`
  - `zajednička jezgra logike`:
    ista jezgra kao `prvu`, uz `append` nad postojećim izlazom
  - `specifični kriterij odabira`:
    isto `naziv + id`, ali nakon isključenja već zatvorenih stavki
  - `piše li u iste strukture`:
    da
  - `može li biti parametar umjesto zasebne datoteke`:
    da, kao `--mode append --step second`
  - `procjena`:
    `KANDIDAT_ZA_KONSOLIDACIJU`

- `zatvori_sljedecu_validiranu_gransku_natuknicu.py`
  - `zajednička jezgra logike`:
    isto filtriranje, isti append i isti izlazni format
  - `specifični kriterij odabira`:
    `naziv + članak + id`
  - `piše li u iste strukture`:
    da
  - `može li biti parametar umjesto zasebne datoteke`:
    da, vrlo prirodno
  - `procjena`:
    `KANDIDAT_ZA_KONSOLIDACIJU`

- `zatvori_jos_jednu_validiranu_gransku_natuknicu.py`
  - `zajednička jezgra logike`:
    gotovo ista kao `sljedecu`
  - `specifični kriterij odabira`:
    `naziv + članak + id`
  - `piše li u iste strukture`:
    da
  - `može li biti parametar umjesto zasebne datoteke`:
    da, bez vidljive funkcionalne zapreke
  - `procjena`:
    `KANDIDAT_ZA_KONSOLIDACIJU`

Sažetak matrice:

- sve 4 skripte pišu u isti izlazni JSON i isti manifest
- sve 4 koriste istu ili gotovo istu jezgru provjere podobnosti
- stvarno velika funkcionalna razlika postoji samo između `init` koraka i
  `append` koraka
- razlika između `sljedecu` i `jos_jednu` iz koda izgleda gotovo samo
  proceduralno-sekvencijska

---

## E) Procjena rizika konsolidacije

Procjena rizika: `SREDNJI`.

To nije visok rizik zato što je preklapanje logike očito veliko.
Ipak, nije ni nizak bez uvjeta, jer postoje dvije stvarne opasnosti:

1. može se nenamjerno promijeniti deterministički redoslijed odabira
   kandidata
2. može se promijeniti oblik manifesta i audit trag koji sada nose
   različite status stringove

Glavni rizik nije u poslovnom pravilu podobnosti, nego u tome da refaktor:

- ne promijeni poredak odabira
- ne promijeni `status_zadataka`
- ne promijeni sadržaj izlaznog manifesta
- ne zamijeni `init` ponašanje s `append` ponašanjem

Prije bilo kakvog refaktora mora biti dokazano:

- da generički alat na istim ulazima daje isti odabrani zapis
- da `potpuno_validirane_natuknice.json` ostaje istog oblika
- da manifest ostaje istog oblika i s istim statusnim signalima
- da je jasno odvojeno `init` od `append` moda

Postoji smisao za jedan generički alat umjesto 4 skripte.
Najbolji kandidat da postane jezgra tog alata je:

- `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`

Razlog:

- naziv joj je već opći
- radi nad postojećim skupom zatvorenih natuknica
- ima stroži i jasniji sort kriterij `naziv + članak + id`
- najsličnija je skripti `jos_jednu`, koja izgleda kao gotovo isti kod
  s drugim statusnim labelom

Najsigurniji prvi refaktorski korak ne bi bio trenutno brisanje datoteka,
nego:

- izdvajanje zajedničkih helper funkcija u jednu zajedničku jezgru
- zadržavanje postojećih wrapper imena dok se ne dokaže potpuna
  ekvivalentnost izlaza

---

## F) Zaključak

`SKUPINA_JE_KANDIDAT_ZA_KONSOLIDACIJU`

Sljedeći smisleni zadatak:

- pripremiti scoped plan sigurnog refaktora za izdvajanje zajedničke
  helper jezgre u generički alat, uz obvezno ažuriranje
  `dokumentacija/REVIZIJA_ALATA_I_PREPORUKE_CISCENJA.md`
