# PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA

## 1) Osnovni podaci

- Datum i vrijeme: 20.02.2026.
- Repo putanja: C:\Veritas_H77
- Grana: main
- HEAD commit: e4ec658
- Upstream: origin/main
- Divergencija (HEAD...@{u}): 0 0

## 2) Zadnjih 10 commitova (izlaz komande)

Komanda:

Set-Location -LiteralPath "C:\Veritas_H77"; git --no-pager log -10 --oneline

Izlaz:

- e4ec658 chore: add postupak tok pn prigovor v1 + gate
- 7d405b0 test: add ogledni json v1 za validatore
- 8d9ca89 chore: add json sheme i ps validatori prekrsajni v1
- b07cdea docs: fix json fences + canon kolizija mapping v1
- 015de6f docs: add STANDARD_JSON_PREDLOZAK v1
- b8b8816 docs: add STANDARD_JSON_HIJERARHIJA v1
- 46cbe2a docs: add STANDARD_JSON_SUBSUMPCIJA v1
- f29b199 docs: add STANDARD_JSON_AUDIT_PRIMJENE v1
- d174e1b docs: ispravak MD024 u dnevniku rada
- 9f22503 docs: add kanonski plan prekrsajnog modula v1

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
