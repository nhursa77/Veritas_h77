# PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA

## 1) Osnovni podaci

- Datum i vrijeme: 22.02.2026.
- Repo putanja: C:\Veritas_H77
- Grana: main
- HEAD commit: 966c5ad
- Upstream: origin/main
- Divergencija (HEAD...@{u}): 0 0

## 2) Zadnjih 10 commitova (izlaz komande)

Komanda:

Set-Location -LiteralPath "C:\Veritas_H77"; git --no-pager log -10 --oneline

Izlaz:

- 966c5ad docs: align prekrsajni plan with implemented state
- 5a2acfe docs: update dokumentacijska mapa (prekrsajni kanon)
- be3bc66 docs: zapis stabilizacije VS Code PSES (pwsh)
- 00c7a2a chore: fix analyzer warnings + md047
- 644edff chore: fix unused outputPath in ci_smoke
- 7e801a9 fix: add required output markers in run_tok_v1
- 0743e43 docs: standard izlaznog nacrta + stricter izlaz validator
- cdbeebe chore: standardize runner usage (generic only)
- 8aebea9 fix: require predlozak in run_tok_v1
- 8e1c43d chore: align zalba predlozak v1 with intake mapping

## 3) Čistoća repoa (izlaz komande)

Komanda:

Set-Location -LiteralPath "C:\Veritas_H77"; git status --short

Izlaz:

(bez izlaza)

## 4) Tree baze (izlaz kanonske komande)

Komanda:

Set-Location -LiteralPath "C:\Veritas_H77";
Get-ChildItem .\baza_zakona -Directory | Select-Object Name;
'--- NORME ---';
Get-ChildItem .\baza_zakona\norme -Directory |
Select-Object -ExpandProperty Name;
'--- SIDRA ---';
Get-ChildItem .\baza_zakona\sidra -Directory |
Select-Object -ExpandProperty Name;
'--- ARHIVA ---';
Get-ChildItem .\baza_zakona\arhiva -Directory |
Select-Object -ExpandProperty Name

Izlaz:

- baza_zakona/
  - arhiva
  - norme
  - sheme
  - sidra
- --- NORME ---
  - prekrsajni_zakon_procisceni
  - ustav_rh_procisceni
- --- SIDRA ---
  - prekrsajni_zakon_nn_107_2007
  - prekrsajni_zakon_nn_110_2015
  - prekrsajni_zakon_nn_114_2022
  - prekrsajni_zakon_nn_118_2018
  - prekrsajni_zakon_nn_157_2013
  - prekrsajni_zakon_nn_39_2013
  - prekrsajni_zakon_nn_70_2017
  - ustav_rh_nn_85_2010
- --- ARHIVA ---
  - prekrsajni_zakon
  - ustav_rh

## 5) Aktivni gate markeri

- `NORME_LAYOUT_CHECK`
- `DELTA_OPS_CONTROL`
- `MDLINT_BEGIN`
- `MDLINT_END`
- `MDLINT_EXIT`
- `CI_SMOKE_EXIT`

## 6) Napomena

Push se radi na kraju dana, ručno.
