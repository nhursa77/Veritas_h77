# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_106_2018
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_106_2018
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 33
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T15:38:19+02:00
- NN_JSON_SHA256:
  5b6296d70d50285d6888ce508d1402ec475ca776f8129d9d0c57e4560d576e87
- KONTROLNO_TXT_SHA256:
  258f321a657bc3d37c8dc54d7413ca37f09576cd8a871c87c4d1af26526a125b

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_106_2018_procisceni,
  zakon_o_porezu_na_dohodak_nn_106_2018_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_106_2018_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 16167
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 33
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 33
- NN_COUNT: 33
- MISSING_COUNT: 0
- SHORT_COUNT: 9
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 33
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

- Članak 8 (len=188) -> clanak_0008.json
- Članak 10 (len=190) -> clanak_0010.json
- Članak 12 (len=114) -> clanak_0012.json
- Članak 16 (len=55) -> clanak_0016.json
- Članak 19 (len=129) -> clanak_0019.json
- Članak 20 (len=20) -> clanak_0020.json
- Članak 21 (len=20) -> clanak_0021.json
- Članak 22 (len=20) -> clanak_0022.json
- Članak 32 (len=136) -> clanak_0032.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
