# BASELINE_MARKDOWN_STANJA_REPOA

Datum: 02.04.2026.
Status: dokazni baseline izvjestaj
Opseg: stvarno markdown stanje cijelog repoa, bez sanacije i bez diranja
postojećih kanonskih datoteka.

---

## A. Polazni git dokaz

Obvezni pre-check pokrenut je iz `C:\Veritas_H77` naredbom:

```powershell
Set-Location -LiteralPath "C:\Veritas_H77"
git status --short
git --no-pager log -1 --oneline
git branch -vv
git ls-remote --heads origin main
```

Polazni dokaz:

```text
git status --short
 M dokumentacija/DNEVNIK_RADA.md
 M dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
 M dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
 M dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
?? .vscode/
?? dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
?? dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
?? dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md
?? dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
?? dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md
?? dokumentacija/USPOREDBA_LOKALNO_VS_GITHUB_DOKUMENTACIJA.md
?? dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md

git --no-pager log -1 --oneline
eb7a13f (HEAD -> main) docs: inventura obrasca zakoni s amandmanima (Z138)

git branch -vv
* main eb7a13f [origin/main: behind 1] docs: inventura obrasca zakoni s
  amandmanima (Z138)

git ls-remote --heads origin main
17a0d0393b9d559ad777003bdbd04cffeca67c04        refs/heads/main
```

Zakljucani polazni sazetak:

- lokalni HEAD: `eb7a13f`
- `origin/main`: `17a0d0393b9d559ad777003bdbd04cffeca67c04`
- lokalni `main` nije poravnat; `behind 1`
- radno stablo nije cisto prije baselinea

## B. Što je stvarno na GitHubu

Remote je osvjezen naredbom:

```powershell
Set-Location -LiteralPath "C:\Veritas_H77"
git fetch origin
git ls-tree -r --name-only origin/main | Select-String '\.md$'
```

Stvarni GitHub `.md` popis na `origin/main`:

```text
.github/copilot-instructions.md
baza_zakona/arhiva/prekrsajni_zakon/
  narodne_novine_nn_107_2007/IZVJESTAJ_NORMIRANJA.md
baza_zakona/arhiva/ustav_rh/nn_56_1990_1092_142/IZVJESTAJ_NORMIRANJA.md
baza_zakona/arhiva/prekrsajni_zakon/
  narodne_novine_nn_107_2007/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/arhiva/ustav_rh/
  nn_56_1990_1092_142/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/opci_porezni_zakon_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  opci_porezni_zakon_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/prekrsajni_zakon_procisceni/USPoredba_zakon_hr.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_DIFF_142_VS_152.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/
  zakon_o_opcem_upravnom_postupku_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_opcem_upravnom_postupku_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_porezu_na_dohodak_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_upravnim_sporovima_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/README.md
baza_zakona/sidra/opci_porezni_zakon_nn_106_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_114_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_121_2019/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_151_2025/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_152_2024/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_32_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_42_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_107_2007/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_110_2015/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_114_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_118_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_157_2013/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_39_2013/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_70_2017/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/ustav_rh_nn_85_2010/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_opcem_upravnom_postupku_nn_110_2021/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md
dokumentacija/DNEVNIK_RADA.md
dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md
dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md
dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md
dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md
dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md
dokumentacija/PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md
dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md
dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md
dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md
dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md
dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md
dokumentacija/RJE─îNIK_POJMOVA_VERITAS_H77.md
dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md
dokumentacija/STANDARD_FER_NAPLATA_PREKRSAJI.md
dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md
dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md
dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md
dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md
dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md
dokumentacija/STANDARD_JSON_HIJERARHIJA.md
dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md
dokumentacija/STANDARD_JSON_NORMA.md
dokumentacija/STANDARD_JSON_POSTUPAK.md
dokumentacija/STANDARD_JSON_PREDLOZAK.md
dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md
dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md
dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md
dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md
dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md
dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md
dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md
dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md
dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_RIZIK_I_KOLIZIJE.md
dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md
dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md
dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md
dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
dokumentacija/TEHNI─îKI_OKVIR_VERITAS_H77.md
dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_106_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_114_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_121_2019_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_151_2025_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_152_2024_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_32_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_42_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_110_2015_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_114_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_118_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_157_2013_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_39_2013_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_70_2017_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/USTAV_RH_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_NN_110_2021_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_106_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_114_2023_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_121_2019_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_138_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_151_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_152_2024_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_32_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/ZAKON_O_POREZU_NA_DOHODAK_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/opci_porezni_zakon/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_106_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_114_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_121_2019/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_151_2025/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_152_2024/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_32_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_42_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/prekrsajni_zakon/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_107_2007/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_110_2015/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_114_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_118_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_157_2013/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_39_2013/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_70_2017/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/ustav_rh/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/ustav_rh_nn_85_2010/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_opcem_upravnom_postupku/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_opcem_upravnom_postupku_nn_110_2021/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_upravnim_sporovima/IZVJESTAJ_PARSIRANJA_NN.md
README.md
```

Broj `.md` datoteka na `origin/main`: `154`.

Napomena:

- sirovi `git ls-tree` izlaz na Windowsu escapea dvije Unicode putanje u
  `dokumentacija/`
- te dvije putanje su dodatno provjerene direktnim blob hashom i nisu stvarni
  remote-only nalazi

## C. Što je stvarno lokalno

Lokalna markdown inventura pokrenuta je naredbom:

```powershell
Set-Location -LiteralPath "C:\Veritas_H77"
Get-ChildItem -Recurse -File -Include *.md |
ForEach-Object {
  $_.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/'
} |
Sort-Object
```

Stvarni lokalni `.md` popis:

```text
.github/copilot-instructions.md
.venv/Lib/site-packages/pip-26.0.1.dist-info/licenses/src/pip/_vendor/
  idna/LICENSE.md
.venv/Lib/site-packages/pip/_vendor/idna/LICENSE.md
baza_zakona/arhiva/prekrsajni_zakon/
  narodne_novine_nn_107_2007/IZVJESTAJ_NORMIRANJA.md
baza_zakona/arhiva/ustav_rh/nn_56_1990_1092_142/IZVJESTAJ_NORMIRANJA.md
baza_zakona/arhiva/prekrsajni_zakon/
  narodne_novine_nn_107_2007/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/arhiva/ustav_rh/
  nn_56_1990_1092_142/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/opci_porezni_zakon_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  opci_porezni_zakon_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/prekrsajni_zakon_procisceni/USPoredba_zakon_hr.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_DIFF_142_VS_152.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/ustav_rh_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/
  zakon_o_opcem_upravnom_postupku_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_opcem_upravnom_postupku_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_porezu_na_dohodak_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/IZVJESTAJ_NORMIRANJA.md
baza_zakona/norme/
  zakon_o_upravnim_sporovima_procisceni/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/README.md
baza_zakona/sidra/opci_porezni_zakon_nn_106_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_114_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_121_2019/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_151_2025/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_152_2024/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_32_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/opci_porezni_zakon_nn_42_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_107_2007/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_110_2015/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_114_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_118_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_157_2013/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_39_2013/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/prekrsajni_zakon_nn_70_2017/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/ustav_rh_nn_85_2010/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_opcem_upravnom_postupku_nn_110_2021/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_NORMIRANJA.md
baza_zakona/sidra/
  zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_VALIDACIJE_KONTROLNO.md
dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md
dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/DNEVNIK_RADA.md
dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md
dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md
dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md
dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md
dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md
dokumentacija/PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md
dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md
dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md
dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md
dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md
dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md
dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md
dokumentacija/RJEČNIK_POJMOVA_VERITAS_H77.md
dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md
dokumentacija/STANDARD_FER_NAPLATA_PREKRSAJI.md
dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md
dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md
dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md
dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md
dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md
dokumentacija/STANDARD_JSON_HIJERARHIJA.md
dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md
dokumentacija/STANDARD_JSON_NORMA.md
dokumentacija/STANDARD_JSON_POSTUPAK.md
dokumentacija/STANDARD_JSON_PREDLOZAK.md
dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md
dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md
dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md
dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md
dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md
dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md
dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md
dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md
dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md
dokumentacija/STANDARD_RIZIK_I_KOLIZIJE.md
dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md
dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md
dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md
dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md
dokumentacija/USPOREDBA_LOKALNO_VS_GITHUB_DOKUMENTACIJA.md
dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md
dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_106_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_114_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_121_2019_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_151_2025_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_152_2024_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_32_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_NN_42_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/OPCI_POREZNI_ZAKON_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_110_2015_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_114_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_118_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_157_2013_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_39_2013_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_NN_70_2017_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/PREKRSAJNI_ZAKON_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/USTAV_RH_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_NN_110_2021_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_OPCEM_UPRAVNOM_POSTUPKU_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_106_2018_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_114_2023_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_121_2019_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_138_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_151_2022_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_152_2024_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/
  ZAKON_O_POREZU_NA_DOHODAK_NN_32_2020_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/ZAKON_O_POREZU_NA_DOHODAK_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md
izvori/dokazno/narodne_novine/opci_porezni_zakon/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_106_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_114_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_121_2019/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_151_2025/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_152_2024/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_32_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  opci_porezni_zakon_nn_42_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/prekrsajni_zakon/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_107_2007/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_110_2015/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_114_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_118_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_157_2013/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_39_2013/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  prekrsajni_zakon_nn_70_2017/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/ustav_rh/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/ustav_rh_nn_85_2010/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_opcem_upravnom_postupku/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_opcem_upravnom_postupku_nn_110_2021/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_106_2018/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_114_2023/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_121_2019/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_138_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_151_2022/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_152_2024/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_porezu_na_dohodak_nn_32_2020/IZVJESTAJ_PARSIRANJA_NN.md
izvori/dokazno/narodne_novine/
  zakon_o_upravnim_sporovima/IZVJESTAJ_PARSIRANJA_NN.md
README.md
```

Broj lokalnih `.md` datoteka: `162`.

## D. Usporedna klasifikacija lokalno vs GitHub

Dokazna osnova:

- puni GitHub `.md` popis iz sekcije B
- puni lokalni `.md` popis iz sekcije C
- `git diff --name-status origin/main -- *.md dokumentacija README.md .github`
- direktna blob provjera za dvije Unicode putanje u `dokumentacija/`

Tracked markdown diff prema `origin/main`:

```text
M       dokumentacija/DNEVNIK_RADA.md
D       dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md
M       dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
M       dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
M       dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
```

Napomena o `D` za `KANONSKI_OBRAZAC...`:

- lokalno postoji neobjavljena datoteka iste putanje
- `git diff` je vidi kao `D` jer lokalno tracked stanje ne sadrzi remote blob
- operativno to znaci: ista putanja postoji i na GitHubu i lokalno, ali je
  lokalna varijanta izvan objavljenog tracked stanja

Napomena o Unicode putanjama:

- `dokumentacija/RJEČNIK_POJMOVA_VERITAS_H77.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`

Za obje putanje lokalni i remote blob hash su jednaki. Sirovi remote ispis ih
na Windowsu prikazuje escapeano, pa ih baseline vodi kao stvarno poravnate, a
ne kao remote-only ili local-only.

Zakljucana klasifikacija nakon Unicode provjere:

- `ISTO_NA_GITHUBU_I_LOKALNO`: `149`
- `LOKALNO_IZMIJENJENO_PREMA_GITHUBU`: `5`
- `LOKALNO_NOVO_NEOBJAVLJENO`: `8`
- `NA_GITHUBU_POSTOJI_A_LOKALNO_NEDOSTAJE`: `0`

### ISTO_NA_GITHUBU_I_LOKALNO

Ovaj skup cini presjek sekcija B i C nakon izuzimanja pet lokalno
izmijenjenih putanja i osam lokalno-novih putanja iz sljedecih skupina.
To ukljucuje i dvije Unicode putanje potvrđene blob hashom:

- `dokumentacija/RJEČNIK_POJMOVA_VERITAS_H77.md`
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`

### LOKALNO_IZMIJENJENO_PREMA_GITHUBU

```text
dokumentacija/DNEVNIK_RADA.md
dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md
dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
```

### LOKALNO_NOVO_NEOBJAVLJENO

```text
.venv/Lib/site-packages/pip-26.0.1.dist-info/licenses/src/pip/_vendor/
  idna/LICENSE.md
.venv/Lib/site-packages/pip/_vendor/idna/LICENSE.md
dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md
dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md
dokumentacija/USPOREDBA_LOKALNO_VS_GITHUB_DOKUMENTACIJA.md
dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md
```

### NA_GITHUBU_POSTOJI_A_LOKALNO_NEDOSTAJE

```text
(nema)
```

## E. Puni markdown backlog

Trazeni puni lint poziv bio je:

```powershell
Set-Location -LiteralPath "C:\Veritas_H77"
pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\lint_markdown.ps1
```

Stvarni izlaz alata:

```text
MDLINT_TARGET_COUNT=4
MDLINT_TARGET=dokumentacija/DNEVNIK_RADA.md
MDLINT_TARGET=dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
MDLINT_TARGET=dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md
MDLINT_TARGET=dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md
MDLINT_BEGIN=True
MDLINT_CONFIG=C:\Veritas_H77\.markdownlint.json
MDLINT_MD013_MAX=80
MDLINT_FILES=4
MDLINT_VIOLATIONS=0
MDLINT_END=True
MDLINT_EXIT=0
```

Zakljucak za backlog:

- puni repo markdown backlog nije stvarno dobiven
- alat je obradio samo `4` tracked datoteke
- zato se `MDLINT_EXIT=0` ne smije tumaciti kao puni hard-gate nad svim
  `.md` datotekama u repou
- stvarni baseline markdown duga zato mora ukljucivati i ogranicenje alata,
  a ne samo broj `VIOLATIONS=0`

Dodatni vidljivi signali, ali ne i lint violations:

- Git warning za `dokumentacija/DNEVNIK_RADA.md`
- Git warning za `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`

Ti warningi ukazuju na CRLF/LF drift u radnom stablu, ali nisu prijavljeni kao
markdownlint pravila.

## F. Razdioba nalaza

### BLOCKER

- `lint_markdown.ps1` trenutno ne daje puni repo backlog. To je blocker za
  pouzdani hard-gate jer stvara lažan dojam da je repo markdown-zelen, iako
  je stvarno pregledano samo `4` datoteke.
- Lokalni `main` je `behind 1` prema `origin/main`. To je commit-blocker za
  normalno cisto zatvaranje sljedeceg scoped koraka jer svako zatvaranje mora
  prvo racunati s remote razlikom.
- Postoji `5` lokalno izmijenjenih markdown putanja koje su zajednicke s
  GitHubom: `DNEVNIK`, `MAPA`, `STATUS`, `KANONSKI_OBRAZAC...` i
  `ZAVRSNI_IZVJESTAJ_ZPD...`. To je stvarni commit-blocker jer miješa vec
  postojece lokalne repove sa svakim novim dokumentacijskim scopeom.
- Postoji `8` lokalno-novih markdown putanja. Posebno su commit-blocker
  lokalni meta-dokumenti u `dokumentacija/` jer ostaju kao lokalni visak i
  oneciscuju cisto zatvaranje bilo kojeg novog zadatka.
- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` je posebno
  osjetljiv blocker: ista putanja vec postoji na GitHubu, ali lokalno zivi kao
  neobjavljena varijanta izvan tracked stanja, sto remeti citanje name-status
  razlike prema remoteu.

### NE_BLOCKER

- Dvije lokalne `.venv/.../LICENSE.md` datoteke jesu lokalni markdown visak,
  ali nisu kanonski projektni dokumentacijski dug. One opterecuju inventuru,
  no same po sebi ne blokiraju zakon -> ingest -> JSON tok.
- `dokumentacija/USPOREDBA_LOKALNO_VS_GITHUB_DOKUMENTACIJA.md` je lokalni
  servisni dokazni dokument iz prethodnog koraka. On je lokalni visak, ali je
  svrhovit trag, ne kvar markdown toka.
- Velik broj generiranih `IZVJESTAJ_*.md` i `*_SELECTION_REPORT.md` datoteka u
  `baza_zakona/` i `izvori/` nije sam po sebi blocker. To je postojeći repo
  dokumentacijski sloj koji je uglavnom poravnat s GitHubom.

### KOZMETIKA

- Git warning o CRLF/LF driftu na pojedinim dokumentima trenutačno je kozmetika
  dok ne prijeđe u stvarni diff koji ruši scoped zatvaranje.
- Windows escape prikaz Unicode putanja u `git ls-tree` izlazu je kozmetički
  problem prikaza. Nakon blob provjere ne predstavlja stvarnu razliku između
  lokalnog i GitHub stanja.
- U stvarnom dostupnom lint izlazu nema prijavljenih markdownlint violationa;
  zbog toga je trenutna kozmetika vise problem prikaza i higijene nego problem
  pravila poput `MD013`, `MD024` ili `MD026`.

## G. Zaključani baseline

Ovaj baseline zakljucava sljedece stvarno pocetno stanje markdown duga i
repo higijene:

- GitHub nosi `154` `.md` datoteka, lokalni repo `162`
- stvarno poravnato nakon Unicode provjere: `149` putanja
- stvarno lokalno izmijenjeno prema GitHubu: `5` putanja
- stvarno lokalno novo i neobjavljeno: `8` putanja
- stvarno remote-only markdown putanja: `0`
- puni markdown backlog nije dobiven, jer `lint_markdown.ps1` trenutno radi
  nad ogranicenim tracked pogledom od `4` datoteke

Stvarni commit-blockeri za daljnje cisto zatvaranje scoped koraka su:

1. lokalni `main` iza `origin/main`
2. kumulativne tracked markdown razlike u `DNEVNIK`, `MAPA`, `STATUS`,
   `KANONSKI_OBRAZAC...` i `ZAVRSNI_IZVJESTAJ...`
3. lokalni markdown visak u `dokumentacija/`, posebno meta-dokumenti Z138-Z145
   i raniji usporedni izvjestaj
4. lažno-zelen signal jer trenutni markdown lint nije puni repo hard-gate

Sto se mora rijesiti prije normalnog zatvaranja scoped koraka:

- prvo razdvojiti i stabilizirati postojeći lokalni markdown visak
- zatim uskladiti repo s `origin/main`
- tek potom uvesti stvarni puni markdown hard-gate koji obuhvaća cijeli repo,
  a ne samo tracked podskup

Sto je samo lokalni sum:

- `.venv` license markdown datoteke
- lokalni servisni dokazni dokumenti koji nisu dio GitHub kanonskog stanja

Jedan sljedeci logicki servisni korak nakon ovog baselinea je:

- dokazno odvojiti i klasificirati postojeci lokalni markdown visak na
  commit-blockere i lokalni sum, prije bilo kakve daljnje sanacije ili novog
  scoped commita.