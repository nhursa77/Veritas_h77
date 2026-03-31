# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_121_2019
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_121_2019
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 22
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T15:53:06+02:00
- NN_JSON_SHA256:
  a371f23fdb498b29e82a22634acafcc01c0e1f0f91780e2410b5219c55b3581a
- KONTROLNO_TXT_SHA256:
  6b6b6a46142ffb6fed0577c2bc98f351ea83662da37c21b9bb16bf79778b147a

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_121_2019_procisceni,
  zakon_o_porezu_na_dohodak_nn_121_2019_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_121_2019_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 12498
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 21
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 21
- NN_COUNT: 22
- MISSING_COUNT: 0
- SHORT_COUNT: 6
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

- 27

## Short texts in NN (len < 200)

- Članak 8 (len=87) -> clanak_0008.json
- Članak 10 (len=102) -> clanak_0010.json
- Članak 17 (len=180) -> clanak_0017.json
- Članak 18 (len=122) -> clanak_0018.json
- Članak 19 (len=198) -> clanak_0019.json
- Članak 20 (len=138) -> clanak_0020.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
