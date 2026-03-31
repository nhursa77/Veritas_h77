# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: opci_porezni_zakon
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: opci_porezni_zakon
- Selected tip_teksta: procisceni
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 199
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T12:53:05+02:00
- NN_JSON_SHA256:
  afa8e22eed17c8e313b39de71be6708873714f369fae4e3a2dd38d0b0fa7734a
- KONTROLNO_TXT_SHA256:
  4d50d6bd3833b1cdacc2f1bc3fcc0e16e7abd8755f47a521b8ae4336321c2fb3

## Document split summary

- CONTROL_DOCS_FOUND: 2 | opci_porezni_zakon_procisceni,
  opci_porezni_zakon_amandmani
- NN_DOCS_FOUND: 1 | opci_porezni_zakon_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 186804
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 199
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 199
- NN_COUNT: 199
- MISSING_COUNT: 0
- SHORT_COUNT: 19
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 199
- CONTROL_TYPO_HEADERS: (none)
- CONTROL_SUSPECTED_TRUNCATED_HEADERS: (none)

## Control source anomaly (zakon.hr truncation suspected)

- CONTROL_TRUNCATION_SUSPECTED: False
- (none)

## Missing in NN (present in zakon.hr, absent in NN)

- (none)

## Extra in NN (present in NN, absent in zakon.hr)

- (none)

## Short texts in NN (len < 200)

- Članak 4 (len=146) -> clanak_0004.json
- Članak 5 (len=161) -> clanak_0005.json
- Članak 14 (len=138) -> clanak_0014.json
- Članak 27 (len=176) -> clanak_0027.json
- Članak 33 (len=193) -> clanak_0033.json
- Članak 52 (len=143) -> clanak_0052.json
- Članak 53 (len=193) -> clanak_0053.json
- Članak 78 (len=179) -> clanak_0078.json
- Članak 123 (len=193) -> clanak_0123.json
- Članak 133 (len=197) -> clanak_0133.json
- Članak 136 (len=198) -> clanak_0136.json
- Članak 158 (len=184) -> clanak_0158.json
- Članak 168 (len=152) -> clanak_0168.json
- Članak 179 (len=185) -> clanak_0179.json
- Članak 180 (len=91) -> clanak_0180.json
- Članak 183 (len=172) -> clanak_0183.json
- Članak 184 (len=119) -> clanak_0184.json
- Članak 187 (len=106) -> clanak_0187.json
- Članak 198 (len=151) -> clanak_0198.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
