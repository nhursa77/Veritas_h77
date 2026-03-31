# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_152_2024
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_152_2024
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 19
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T18:18:08+02:00
- NN_JSON_SHA256:
  d1769fe377c1907b0177599744022e716dfb4fceac6e4dc8a75c25c03fedac07
- KONTROLNO_TXT_SHA256:
  9648adf6f9ae799af6562aa5c281a02cfa4d637b30ec435bdfbb1c5efdc49734

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_152_2024_procisceni,
  zakon_o_porezu_na_dohodak_nn_152_2024_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_152_2024_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 17529
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 19
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 19
- NN_COUNT: 19
- MISSING_COUNT: 0
- SHORT_COUNT: 6
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 19
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

- Članak 3 (len=81) -> clanak_0003.json
- Članak 5 (len=106) -> clanak_0005.json
- Članak 6 (len=137) -> clanak_0006.json
- Članak 12 (len=113) -> clanak_0012.json
- Članak 16 (len=174) -> clanak_0016.json
- Članak 18 (len=122) -> clanak_0018.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
