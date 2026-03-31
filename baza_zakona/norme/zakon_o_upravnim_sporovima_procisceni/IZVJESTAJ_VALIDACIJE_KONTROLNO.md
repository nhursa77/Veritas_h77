# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_upravnim_sporovima
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_upravnim_sporovima
- Selected tip_teksta: procisceni
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 172
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T10:06:44+02:00
- NN_JSON_SHA256:
  ba59e73f62fcbe961c87096aae4c3583e7a5039c0afae082a7eaec629415c28f
- KONTROLNO_TXT_SHA256:
  f670773d59c7ef22a4f79b544c55bc7c7fcf6eff100c83d58c013773707f47f3

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_upravnim_sporovima_procisceni,
  zakon_o_upravnim_sporovima_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_upravnim_sporovima_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 121209
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 172
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 172
- NN_COUNT: 172
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
- CONTROL_MAX: 172
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

- Članak 5 (len=172) -> clanak_0005.json
- Članak 9 (len=172) -> clanak_0009.json
- Članak 17 (len=71) -> clanak_0017.json
- Članak 19 (len=190) -> clanak_0019.json
- Članak 29 (len=174) -> clanak_0029.json
- Članak 43 (len=158) -> clanak_0043.json
- Članak 67 (len=179) -> clanak_0067.json
- Članak 84 (len=98) -> clanak_0084.json
- Članak 88 (len=187) -> clanak_0088.json
- Članak 122 (len=187) -> clanak_0122.json
- Članak 170 (len=193) -> clanak_0170.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
