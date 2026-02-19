# SOURCE SELECTION REPORT

- Akt slug: prekrsajni_zakon
- Timestamp: 2026-02-18T18:07:51+01:00
- Selected slug: prekrsajni_zakon
- Selected tip_teksta: procisceni
- Selected preferenca: 100
- Selected ocekivani_broj_clanaka: 0
- Selected input:
  C:\Veritas_H77\izvori\dokazno\narodne_novine\
  prekrsajni_zakon\struktura_nn_dokumenti.json

## Ranking

- [1] slug=prekrsajni_zakon | tip_teksta=procisceni | preferenca=100 |
  ocekivani_broj_clanaka=0 | input_exists=True
- [2] slug=prekrsajni_zakon_nn_107_2007 | tip_teksta=procisceni |
  preferenca=60 | ocekivani_broj_clanaka=258 | input_exists=True
- [3] slug=prekrsajni_zakon_nn_110_2015 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True
- [4] slug=prekrsajni_zakon_nn_114_2022 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True
- [5] slug=prekrsajni_zakon_nn_118_2018 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True
- [6] slug=prekrsajni_zakon_nn_157_2013 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True
- [7] slug=prekrsajni_zakon_nn_39_2013 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True
- [8] slug=prekrsajni_zakon_nn_70_2017 | tip_teksta=amandmani |
  preferenca=40 | ocekivani_broj_clanaka=0 | input_exists=True

## Guardrail

- Pravilo odabira: input_exists DESC, tip_teksta(procisceni) DESC,
  preferenca DESC, ocekivani_broj_clanaka DESC, slug ASC.
- Operativni izvor mora biti procisceni NN tekst kada je dostupan.
