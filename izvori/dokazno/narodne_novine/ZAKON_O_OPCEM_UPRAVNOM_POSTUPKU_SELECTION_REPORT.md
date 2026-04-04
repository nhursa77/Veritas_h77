# SOURCE SELECTION REPORT

- Akt slug: zakon_o_opcem_upravnom_postupku
- Timestamp: 2026-03-27T18:24:45+01:00
- Selected slug: zakon_o_opcem_upravnom_postupku
- Selected tip_teksta: procisceni
- Selected preferenca: 100
- Selected ocekivani_broj_clanaka: 0
- Selected input:
  `C:\Veritas_H77\izvori\dokazno\`
  `narodne_novine\zakon_o_opcem_upravnom_postupku\`
  `struktura_nn_dokumenti.json`

## Ranking

- [1] slug=zakon_o_opcem_upravnom_postupku | tip_teksta=procisceni |
  preferenca=100 | ocekivani_broj_clanaka=0 | input_exists=True
- [2] slug=zakon_o_opcem_upravnom_postupku_nn_110_2021 |
  tip_teksta=amandmani | preferenca=40 | ocekivani_broj_clanaka=0 |
  input_exists=True

## Guardrail

- Pravilo odabira: input_exists DESC, tip_teksta(procisceni) DESC,
  preferenca DESC, ocekivani_broj_clanaka DESC, slug ASC.
- Operativni izvor mora biti procisceni NN tekst kada je dostupan.
