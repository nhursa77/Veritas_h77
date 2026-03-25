# STATUS_PROJEKTA_VERITAS_H77

Datum: 25.03.2026.

## Snapshot repozitorija

- Trenutni commit: `f6a24c4` - Rjecnik: uklonjene aktivne repo greske iz
  Problems panela
- Repo čist: DA (pre-check `git status --short` bez izlaza)
- Zadnji dovršeni terminološki zadatak: ZADATAK 73
  (zatvorena prva potpuno validirana granska natuknica)
- Aktivni dokumentacijski guard: append-only zaštita
  `dokumentacija/DNEVNIK_RADA.md`
- Sljedeći zadatak po redu: postupno zatvaranje sljedecih potpuno
  validiranih granskih natuknica po istom deterministicnom pravilu.

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
