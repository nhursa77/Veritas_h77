# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_opcem_upravnom_postupku
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_opcem_upravnom_postupku
- Selected tip_teksta: procisceni
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 171
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-27T19:03:57+01:00
- NN_JSON_SHA256:
  10d1c9557ad05d3f737f75694780d131b1aa96b65b8211218b30782be84f1472
- KONTROLNO_TXT_SHA256:
  6809caf279f76433da90ce29e5ddef777c9ac3ff8ff4db2faf5a107029ad0079

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_opcem_upravnom_postupku_procisceni,
  zakon_o_opcem_upravnom_postupku_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_opcem_upravnom_postupku_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 114751
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 171
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 171
- NN_COUNT: 171
- MISSING_COUNT: 0
- SHORT_COUNT: 15
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 171
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

- Članak 70 (len=148) -> clanak_0070.json
- Članak 96 (len=131) -> clanak_0096.json
- Članak 107 (len=178) -> clanak_0107.json
- Članak 109 (len=91) -> clanak_0109.json
- Članak 125 (len=124) -> clanak_0125.json
- Članak 132 (len=146) -> clanak_0132.json
- Članak 134 (len=114) -> clanak_0134.json
- Članak 136 (len=79) -> clanak_0136.json
- Članak 145 (len=112) -> clanak_0145.json
- Članak 149 (len=125) -> clanak_0149.json
- Članak 163 (len=113) -> clanak_0163.json
- Članak 164 (len=179) -> clanak_0164.json
- Članak 165 (len=179) -> clanak_0165.json
- Članak 168 (len=168) -> clanak_0168.json
- Članak 170 (len=126) -> clanak_0170.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
