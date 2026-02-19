# USTAV RH SOURCE SELECTION REPORT

- Timestamp: 2026-02-18T15:20:14+01:00
- Selected slug: ustav_rh_nn_85_2010
- Selected tip_teksta: procisceni
- Selected preferenca: 100
- Selected ocekivani_broj_clanaka: 152
- Selected input:
  C:\Veritas_H77\izvori\dokazno\narodne_novine\
  ustav_rh_nn_85_2010\struktura_nn_dokumenti.json

## Ranking

- [1] slug=ustav_rh_nn_85_2010 | tip_teksta=procisceni |
  preferenca=100 | ocekivani_broj_clanaka=152 | input_exists=True
- [2] slug=ustav_rh | tip_teksta=izvorni | preferenca=10 |
  ocekivani_broj_clanaka=142 | input_exists=True

## Guardrail

- Pravilo odabira: input_exists DESC, tip_teksta(procisceni) DESC,
  preferenca DESC, ocekivani_broj_clanaka DESC, slug ASC.
- Operativni izvor mora biti procisceni NN tekst kada je dostupan.
