# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_151_2022
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_151_2022
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 23
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T17:57:06+02:00
- NN_JSON_SHA256:
  2fc47b0b4c781b14711bc8b9013e68b6712cd20a0c226952f6a7d5ca0bd48027
- KONTROLNO_TXT_SHA256:
  0a4acd82dfd18037e6959fcddf1af26b2750e8a314560313ea51c89e84c9fd64

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_151_2022_procisceni,
  zakon_o_porezu_na_dohodak_nn_151_2022_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_151_2022_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 8182
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 23
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 23
- NN_COUNT: 23
- MISSING_COUNT: 0
- SHORT_COUNT: 11
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 23
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

- Članak 2 (len=183) -> clanak_0002.json
- Članak 3 (len=177) -> clanak_0003.json
- Članak 4 (len=188) -> clanak_0004.json
- Članak 6 (len=136) -> clanak_0006.json
- Članak 8 (len=178) -> clanak_0008.json
- Članak 9 (len=188) -> clanak_0009.json
- Članak 12 (len=91) -> clanak_0012.json
- Članak 13 (len=92) -> clanak_0013.json
- Članak 14 (len=141) -> clanak_0014.json
- Članak 16 (len=90) -> clanak_0016.json
- Članak 21 (len=122) -> clanak_0021.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
