# POPIS_AKTIVNIH_MARKDOWN_PROBLEMA

Datum: 04.04.2026.
Status: read-only dokazna inventura
Opseg: zaključavanje stvarnog trenutnog full-repo markdown backloga
bez sanacije, commita i pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrđeno stanje prije izrade ovog dokumenta:

- lokalni HEAD: `b3d495c`
- zadnji commit:
  `fix: full-repo markdown lint radi na windowsu`
- grana: `main`
- stanje grane: `main` je poravnat s `origin/main`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git status --short`: prazno
- `git stash list`:
  `stash@{0}: On main: veritas-pre-rebase-z147`

Zaključak pre-checka:

- nema tracked ni staged diffa
- repo je čist prije ovog read-only koraka
- stash nije diran

---

## B) Full-repo markdown izlaz

Stvarni lint capture spremljen je u:

- `C:\Users\User\AppData\Local\Temp\`
  `veritas_active_md_issues.txt`

Zaključani marker izlazi iz capturea:

- engine: `markdownlint-cli@0.48.0`
- broj chunkova: `2`
- ukupan broj problema: `45`
- ukupan broj pogođenih datoteka: `25`
- exit kod: `1`

Zaključak:

- full-repo lint sada radi na Windowsu i daje stvarne
  `MDLINT_VIOLATION:` retke
- trenutni backlog je dokazno aktivan i može se planirati bez nagađanja

---

## C) Aktivni problemi po datoteci

### C1) Skup `dokumentacija/`

- Datoteka:
  `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_`
  `ZAKONI_S_AMANDMANIMA.md`
  - Broj problema: `1`
  - Redci: `148`
  - Pravila: `MD047`
  - Napomena: tehnički trivijalno; nedostaje jedan završni newline.

- Datoteka:
  `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_`
  `JSON.md`
  - Broj problema: `1`
  - Redci: `204`
  - Pravila: `MD047`
  - Napomena: tehnički trivijalno; nedostaje jedan završni newline.

- Datoteka:
  `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_`
  `ZPD.md`
  - Broj problema: `1`
  - Redci: `133`
  - Pravila: `MD047`
  - Napomena: tehnički trivijalno; nedostaje jedan završni newline.

- Datoteka:
  `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_`
  `SIDRENJE.md`
  - Broj problema: `1`
  - Redci: `46`
  - Pravila: `MD010`
  - Napomena: tehnički trivijalno; jedan hard tab na početku retka.

- Datoteka:
  `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  - Broj problema: `1`
  - Redci: `149`
  - Pravila: `MD047`
  - Napomena: tehnički trivijalno; nedostaje jedan završni newline.

### C2) Skup `izvori/dokazno/narodne_novine/`

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `IZVJESTAJ_KONTROLE_ARHIVE.md`
  - Broj problema: `1`
  - Redci: `36`
  - Pravila: `MD010`
  - Napomena: tehnički trivijalno; jedan hard tab na početku retka.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_106_2018_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_114_2022_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_121_2019_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_151_2025_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_152_2024_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_32_2020_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_NN_42_2020_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `OPCI_POREZNI_ZAKON_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_NN_110_2021_`
  `SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_SELECTION_REPORT.md`
  - Broj problema: `3`
  - Redci: `13`, `14`, `18`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; tri preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_106_2018_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_114_2023_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_121_2019_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_138_2020_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_151_2022_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_152_2024_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_NN_32_2020_SELECTION_`
  `REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_POREZU_NA_DOHODAK_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

- Datoteka:
  `izvori/dokazno/narodne_novine/`
  `ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md`
  - Broj problema: `2`
  - Redci: `13`, `17`
  - Pravila: `MD013`
  - Napomena: mehanički srednje; dva preduga retka u selection reportu.

---

## D) Razdioba po pravilima

| Pravilo | Broj problema |
|---|---:|
| `MD010` | 2 |
| `MD013` | 39 |
| `MD036` | 0 |
| `MD040` | 0 |
| `MD047` | 4 |
| `MD060` | 0 |
| Ostala | 0 |

Sažetak procjene tipa problema:

- tehnički trivijalno: `6` problema (`MD047` + `MD010`)
- mehanički srednje: `39` problema (`MD013`)
- rizično za sadržajni raspad: `0` aktivno prijavljenih nalaza

---

## E) Preporučeni prvi sanacijski rez

Najmanje rizičan prvi stvarni sanacijski korak je:

1. prvo zatvoriti četiri `dokumentacija/` datoteke s čistim `MD047`
   newline problemom:
   - `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
   - `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
   - `OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
   - `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
2. zatim zatvoriti dva pojedinačna `MD010` tab problema
3. tek nakon toga otvarati bulk `MD013` selection report sanaciju

Razlog preporuke:

- `MD047` rez je najčišći i najmanje rizičan jer je potpuno mehanički
- `MD010` je također nizak rizik, ali zahvaća i jedan dokument u
  `izvori/`
- `MD013` backlog je najveći i traži grupni, dosljedni mehanički pristup

Zaključak:

Ovaj dokument zaključava stvarni aktivni markdown backlog na dan
`04.04.2026.` i služi kao forenzička osnova za sljedeći scoped sanacijski
zadatak.