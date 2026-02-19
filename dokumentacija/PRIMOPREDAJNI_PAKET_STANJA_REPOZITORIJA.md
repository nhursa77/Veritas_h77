# PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA

## 1) Osnovni podaci

- Datum i vrijeme: 19.02.2026. 18:33:16
- Repo putanja: C:\Veritas_H77
- Grana: main
- HEAD commit: 6f5b647

## 2) Zadnjih 10 commitova (izlaz komande)

Komanda:

Set-Location -LiteralPath "C:\Veritas_H77"; git --no-pager log -10 --oneline

Izlaz:

- 6f5b647 chore: dodaj soft status za nedostajuce delta_ops
  (kontrola)
- d7ddac3 chore: zabrani non-_procisceni u norme (gate)
- fbfe1bc chore: dodaj lint za markdown (scoped gate)
- a24b72a docs: dodaj upute za Copilot (kanon)
- d930297 chore: validiraj delta_ops po shemi (gate)
- 2a45dd4 chore: validiraj delta_ops po shemi (gate)
- 5dbae55 docs: dodaj shemu delta_ops (kanon)
- 4527ba8 docs: clarify 'baza postupaka' concept vs postupci path
- 427ec6a docs: align TEHNIČKI_OKVIR with canon (paths + terminology)
- fbe9c46 chore: add delta_ops control + deterministic checks
  (UTF-8, paket wiring)

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
