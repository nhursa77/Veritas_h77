# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak
- Selected tip_teksta: procisceni
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 99
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T15:11:30+02:00
- NN_JSON_SHA256:
  da0a867adbc9e4deb1ae3cdbab09209f270c377e5bacb331db1a2785351d3bbc
- KONTROLNO_TXT_SHA256:
  3562c3b0dd8be512f08ab9e3b3b538251e8396ab3b5d2b12e97f3b74c48702d2

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_procisceni,
  zakon_o_porezu_na_dohodak_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 177993
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 99
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 99
- NN_COUNT: 99
- MISSING_COUNT: 0
- SHORT_COUNT: 2
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 99
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

- Članak 28 (len=194) -> clanak_0028.json
- Članak 98 (len=138) -> clanak_0098.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
