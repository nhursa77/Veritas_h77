# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_114_2023
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_114_2023
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 44
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T18:13:26+02:00
- NN_JSON_SHA256:
  2f80ef21c02140988512e48433689341085650cbea021fee5a7a44315c3ac5aa
- KONTROLNO_TXT_SHA256:
  a44536aa145ea487f61a2ce01d8659ecc7e984589b331cd72ea5bbc44b32ad7b

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_114_2023_procisceni,
  zakon_o_porezu_na_dohodak_nn_114_2023_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_114_2023_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 17324
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 42
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 42
- NN_COUNT: 44
- MISSING_COUNT: 0
- SHORT_COUNT: 20
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 42
- CONTROL_TYPO_HEADERS: (none)
- CONTROL_SUSPECTED_TRUNCATED_HEADERS: (none)

## Control source anomaly (zakon.hr truncation suspected)

- CONTROL_TRUNCATION_SUSPECTED: False
- (none)

## Missing in NN (present in zakon.hr, absent in NN)

- (none)

## Extra in NN (present in NN, absent in zakon.hr)

- 76
- 78

## Short texts in NN (len < 200)

- Članak 3 (len=147) -> clanak_0003.json
- Članak 6 (len=150) -> clanak_0006.json
- Članak 8 (len=1) -> clanak_0008.json
- Članak 10 (len=106) -> clanak_0010.json
- Članak 12 (len=111) -> clanak_0012.json
- Članak 14 (len=84) -> clanak_0014.json
- Članak 15 (len=101) -> clanak_0015.json
- Članak 21 (len=72) -> clanak_0021.json
- Članak 22 (len=193) -> clanak_0022.json
- Članak 23 (len=100) -> clanak_0023.json
- Članak 29 (len=144) -> clanak_0029.json
- Članak 30 (len=67) -> clanak_0030.json
- Članak 31 (len=77) -> clanak_0031.json
- Članak 32 (len=178) -> clanak_0032.json
- Članak 33 (len=133) -> clanak_0033.json
- Članak 34 (len=84) -> clanak_0034.json
- Članak 36 (len=156) -> clanak_0036.json
- Članak 37 (len=106) -> clanak_0037.json
- Članak 40 (len=165) -> clanak_0040.json
- Članak 41 (len=138) -> clanak_0041.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
