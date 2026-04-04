# SOURCE SELECTION REPORT

- Akt slug: opci_porezni_zakon
- Timestamp: 2026-03-31T12:25:56+02:00
- Selected slug: opci_porezni_zakon
- Selected tip_teksta: procisceni
- Selected preferenca: 100
- Selected ocekivani_broj_clanaka: 0
- Selected input:
  `C:\Veritas_H77\izvori\dokazno\narodne_novine\opci_porezni_zakon\`
  `struktura_nn_dokumenti.json`

## Ranking

- [1] slug=opci_porezni_zakon | tip_teksta=procisceni |
  preferenca=100 | ocekivani_broj_clanaka=0 | input_exists=True

## Guardrail

- Pravilo odabira: input_exists DESC, tip_teksta(procisceni) DESC,
  preferenca DESC, ocekivani_broj_clanaka DESC, slug ASC.
- Operativni izvor mora biti procisceni NN tekst kada je dostupan.
