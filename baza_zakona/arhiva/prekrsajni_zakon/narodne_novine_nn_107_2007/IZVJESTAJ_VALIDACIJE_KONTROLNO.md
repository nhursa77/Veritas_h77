# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: prekrsajni_zakon_nn_107_2007
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: 258
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: prekrsajni_zakon_nn_107_2007
- Selected tip_teksta: procisceni
- Expected count: 258
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 258
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-02-18T17:53:35+01:00
- NN_JSON_SHA256: 8c7e8532d5cd97733eaba87148188aac7c9933834f7cfe601e9ec0e900507893
- KONTROLNO_TXT_SHA256: 5d92054daae5411f4373867d2f9b503591ce9b124e49bd28533602d62efd4234

## Document split summary

- CONTROL_DOCS_FOUND: 2 | prekrsajni_zakon_procisceni,
  prekrsajni_zakon_amandmani
- NN_DOCS_FOUND: 1 | prekrsajni_zakon_nn_107_2007_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 293951
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 258
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 300
- NN_COUNT: 258
- MISSING_COUNT: 0
- SHORT_COUNT: 13
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 13, 13,
  14, 14, 14, 14, 15]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: True
- CONTROL_MIN: 1
- CONTROL_MAX: 258
- CONTROL_TYPO_HEADERS: (none)
- CONTROL_SUSPECTED_TRUNCATED_HEADERS: (none)
- WARNING: CONTROL_HEADERS_COUNT != len(control_nums): 300 vs 258

## Control source anomaly (zakon.hr truncation suspected)

- CONTROL_TRUNCATION_SUSPECTED: True
- found small numbers (12/13/14) in same control set with high range >=120

## Missing in NN (present in zakon.hr, absent in NN)

- (none)

## Extra in NN (present in NN, absent in zakon.hr)

- UNTRUSTWORTHY_CONTROL_EXTRA_LIST: kontrolni izvor je označen kao nepouzdan
  (truncation suspected).
- Kandidati (nepouzdano): (none)

## Short texts in NN (len < 200)

- Članak 4 (len=167) -> clanak_0004.json
- Članak 16 (len=167) -> clanak_0016.json
- Članak 21 (len=122) -> clanak_0021.json
- Članak 41 (len=103) -> clanak_0041.json
- Članak 51 (len=172) -> clanak_0051.json
- Članak 63 (len=170) -> clanak_0063.json
- Članak 83 (len=139) -> clanak_0083.json
- Članak 84 (len=143) -> clanak_0084.json
- Članak 97 (len=191) -> clanak_0097.json
- Članak 163 (len=176) -> clanak_0163.json
- Članak 188 (len=145) -> clanak_0188.json
- Članak 205 (len=191) -> clanak_0205.json
- Članak 252 (len=182) -> clanak_0252.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
