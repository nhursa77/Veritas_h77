# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_138_2020
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_138_2020
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 21
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T17:34:20+02:00
- NN_JSON_SHA256:
  7544ce4a4ee22bcb56e575706fd7d8ef13401981ced86729053ba0399e74d7ba
- KONTROLNO_TXT_SHA256:
  6414814db74e24c98d8312b353c8ce46cb566be2866941c9e0ef91763dd25efa

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_138_2020_procisceni,
  zakon_o_porezu_na_dohodak_nn_138_2020_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_138_2020_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 7567
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 21
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 21
- NN_COUNT: 21
- MISSING_COUNT: 0
- SHORT_COUNT: 8
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 21
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

- Članak 1 (len=174) -> clanak_0001.json
- Članak 4 (len=61) -> clanak_0004.json
- Članak 7 (len=54) -> clanak_0007.json
- Članak 9 (len=85) -> clanak_0009.json
- Članak 10 (len=70) -> clanak_0010.json
- Članak 11 (len=60) -> clanak_0011.json
- Članak 13 (len=35) -> clanak_0013.json
- Članak 20 (len=138) -> clanak_0020.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
