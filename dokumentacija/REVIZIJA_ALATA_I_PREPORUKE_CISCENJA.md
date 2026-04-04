# REVIZIJA_ALATA_I_PREPORUKE_CISCENJA

Datum: 04.04.2026.
Status: read-only revizijski zaključak.
Opseg: stanje mape `alati/`, bez izmjene postojećih skripti,
bez commita i pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrđeno stanje prije izrade ovog dokumenta:

- lokalni HEAD: `21b84cd`
- grana: `main`
- stanje grane: `main` je poravnat s `origin/main`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git status --short`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`

Zaključak pre-checka:

- repozitorij je čist za ovu read-only reviziju
- nema tracked ni staged diffa
- stash nije diran

---

## B) Kratki inventar mape `alati/`

Pregled mape `alati/` pokazuje `78` skripti i pomoćnih alata.

Većina njih nije dokumentacijski šum nego operativni sloj za:

- CI, lint i acceptance gateove
- ingest i normiranje NN izvora
- specijalni tok za `ustav_rh`
- terminološke i natukničke obrade
- prekršajni audit i generiranje nacrta
- servisne dokumentacijske i layout korake

Prvi zaključak:

- u `alati/` nema velik homogen blok mrtvih datoteka kao što je ranije
  postojao u dijelu dokumentacije
- glavni problem nije broj alata sam po sebi, nego neujednačeno
  imenovanje i zadržani specijalizirani wrapperi

---

## C) Procjena po skupinama

### C1) CI, lint i acceptance jezgra — `OSTAVITI`

Jezgru čine barem:

- `ci_smoke.ps1`
- `lint_markdown.ps1`
- `lint_markdown.py`
- `provjeri_markdown_scope.ps1`
- `acceptance_preflight.ps1`
- `acceptance_paket.ps1`
- `validiraj_*_v1.ps1`
- `run_tok_v1.ps1`

Dokaz aktivne uporabe:

- `ci_smoke.ps1` orkestrira scoped lint, full repo lint signal,
  `preflight`, validatore, generator audita, fixture testove i
  `run_tok_v1.ps1`

Procjena:

- ovo je aktivni operativni kostur repoa
- nije kandidat za cleanup brisanjem
- eventualno samo kasnije harmonizirati imenovanje

### C2) NN ingest i normiranje — `OSTAVITI`

Jezgru čine barem:

- `dohvati_nn.ps1`
- `parsiraj_nn_html.ps1`
- `parsiraj_nn_html.py`
- `eli_issue_pdf_slicer.py`
- `kontroliraj_arhivu_nn.ps1`
- `kontroliraj_arhivu_nn.py`
- `run_normiratelj.ps1`
- `normiratelj_iz_strukture_nn.py`
- `validiraj_nn_vs_kontrolno.py`
- `provjeri_usklađenost_norme.ps1`
- `provjeri_usklađenost_norme.py`

Dokaz aktivne uporabe:

- `run_normiratelj.ps1` radi selection report i preferira operativni
  `procisceni` izvor kada postoji
- `parsiraj_nn_html.py` ima fallback prema PDF sloju kada HTML nije
  dovoljan

Procjena:

- ovo je kanonski ingest i normativni pipeline
- ne dirati kao skupinu za fizičko čišćenje

### C3) Specijalni kanal `ustav_rh` / `zakon.hr` —
`OSTAVITI_UZ_ARHIVSKU_SVIJEST`

Skupina uključuje:

- `dohvati_ustav_zakonhr.ps1`
- `parsiraj_ustav_zakonhr.ps1`
- `parsiraj_ustav_zakonhr.py`
- `normiraj_ustav_u_norma_json.ps1`
- `normiraj_ustav_u_norma_json.py`
- `run_normiratelj_ustav_rh.ps1`
- `diff_ustav_rh_sets.py`
- `izgradi_kontrolni_zakon_hr.py`

Dokaz karaktera skupine:

- `run_normiratelj_ustav_rh.ps1` je tanki wrapper koji samo zove
  `run_normiratelj.ps1 -AktSlug "ustav_rh"`

Procjena:

- skupina je specijalizirana i uža od općeg NN kanala
- nije dobar kandidat za brisanje
- jest dobar kandidat za jasnije odvajanje od općih alata pri budućem
  preoznačavanju

### C4) Terminologija i natuknice — `OSTAVITI`, ali `KONSOLIDIRATI`

Skupina uključuje više aktivnih koraka:

- `pretvori_curia_xlsx_u_json.py`
- `normaliziraj_curia_terminologiju.py`
- `segmentiraj_curia_terminoloske_zapise.py`
- `mapiraj_curia_na_potencijalne_nn_pojmove.py`
- `sidri_osnovni_postupovni_skup_na_nn.py`
- `suzi_nn_kandidate_za_rucnu_validaciju.py`
- `upisi_validirana_nn_sidra_u_natuknice.py`
- `rangiraj_sljedeci_homogeni_niz_za_paket.py`
- `razlozi_viseznacna_nn_sidra_po_aktu.py`

No unutar te skupine postoji jasan podblok za konsolidaciju:

- `zatvori_prvu_validiranu_gransku_natuknicu.py`
- `zatvori_drugu_validiranu_gransku_natuknicu.py`
- `zatvori_sljedecu_validiranu_gransku_natuknicu.py`
- `zatvori_jos_jednu_validiranu_gransku_natuknicu.py`

Dokaz:

- te četiri skripte ponavljaju isti obrazac rada nad istim ulazima i
  izlazima, a razlikuju se uglavnom po fazi odabira i status poruci

Procjena:

- ne brisati naslijepo
- ovo je jedan od najčišćih kandidata za budući
  `KONSOLIDIRATI` rez

### C5) Paketni zatvarači za `prekrsajni_zakon` — `KONSOLIDIRATI`

Skupina uključuje:

- `zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`
- `zatvori_paket_dokaz_prekrsajni_zakon.py`
- `zatvori_paket_dostava_prekrsajni_zakon.py`
- `zatvori_paket_izvrsenje_prekrsajni_zakon.py`
- `zatvori_paket_presuda_prekrsajni_zakon.py`
- `zatvori_paket_prigovor_prekrsajni_zakon.py`
- `zatvori_paket_rjesenje_prekrsajni_zakon.py`
- `zatvori_paket_zalba_prekrsajni_zakon.py`

Dokaz:

- skripte rade isti tip paketnog zatvaranja, a mijenja se prvenstveno
  ciljni pojam i manifestni cilj

Procjena:

- ovo je drugi vrlo čisti kandidat za budući `KONSOLIDIRATI` rez
- najlogičniji kraj bio bi jedan parametrizirani alat uz manifest ili
  `--pojam` argument

### C6) Dokumentacijski i repo-servisni helperi — `OSTAVITI`

Skupina uključuje:

- `generiraj_dnevnicki_unos.ps1`
- `dodaj_dnevnicki_unos_na_kraj.ps1`
- `uskladi_status_projekta.ps1`
- `zatvori_dokumentacijski_korak.ps1`
- `enforce_baza_layout.ps1`
- `normalize_arhiva_layout.ps1`
- `ingest_paket.ps1`

Procjena:

- helperi su uski, ali svrhoviti
- ne čine veći šum
- za sada im je veća vrijednost od troška održavanja

### C7) Najjasniji arhivski trag — `ARHIVSKI_PREOZNACITI`

Najčišći pojedinačni kandidat nije skupina za brisanje, nego za
jasno arhivsko odvajanje:

- `run_tok_pn_prigovor_v1.ps1`

Dokaz:

- sama datoteka počinje oznakom `DEPRECATED (KANONSKI)`
- u zaglavlju izrijekom piše da je kanonski runner od `22.02.2026.`
  `alati\run_tok_v1.ps1`
- `ci_smoke.ps1` koristi generički `run_tok_v1.ps1`, ne taj stari
  runner

Procjena:

- datoteka ima revizijsku vrijednost
- ali više ne pripada aktivnom vrhu mape `alati/`

---

## D) Ima li još smislenog skupinskog čišćenja

Da, ali ne u obliku masovnog brisanja.

Najčišće buduće skupine su:

1. `specijalizirani sekvencijski zatvarači natuknica`
   - četiri `zatvori_*_validiranu_gransku_natuknicu.py` skripte
   - preporuka: `KONSOLIDIRATI`

2. `tematski paketni zatvarači za prekrsajni_zakon`
   - osam `zatvori_paket_*_prekrsajni_zakon.py` skripti
   - preporuka: `KONSOLIDIRATI`

3. `deprecirani ili tanki wrapperi`
   - najjasnije `run_tok_pn_prigovor_v1.ps1`
   - sekundarno `run_normiratelj_ustav_rh.ps1` kao convenience wrapper
   - preporuka: `ARHIVSKI_PREOZNACITI`, ne nužno brisati

Manje je uvjerljiv bilo kakav veliki rez nad CI, validatorima ili NN
ingest jezgrom, jer bi takav rez dirao aktivni kanonski tok repoa.

---

## E) Završni zaključak

`ALATI_NE_TRAZE_VELIKO_FIZICKO_CISCENJE`

`ALATI_TRAZE_CILJANU_KONSOLIDACIJU_I_JASNIJE_PREOZNACAVANJE`

Drugim riječima:

- operativna jezgra je legitimna i aktivna
- pravi višak nije funkcionalni, nego imenoslovni i povijesni
- sljedeći smisleni rez, ako se bude radio, trebao bi biti
  `konsolidacijski`, a ne `brisajuci`
