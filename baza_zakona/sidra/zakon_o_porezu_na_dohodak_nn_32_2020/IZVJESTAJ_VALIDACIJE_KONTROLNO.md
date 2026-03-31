# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: zakon_o_porezu_na_dohodak_nn_32_2020
- SELECTED_SOURCE_TIP_TEKSTA: amandmani
- SELECTED_SOURCE_EXPECTED_COUNT: (none)
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: zakon_o_porezu_na_dohodak_nn_32_2020
- Selected tip_teksta: amandmani
- Expected count: NONE
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 4
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-03-31T16:11:24+02:00
- NN_JSON_SHA256:
  514b7c3c439ae5200852cb2abca857d7fcf675ffa288b9070bdfa826cc28d9e7
- KONTROLNO_TXT_SHA256:
  926727cdd212c432a307ed1b1031a73045e9416a156cb08b622850e156cbaf22

## Document split summary

- CONTROL_DOCS_FOUND: 2 | zakon_o_porezu_na_dohodak_nn_32_2020_procisceni,
  zakon_o_porezu_na_dohodak_nn_32_2020_amandmani
- NN_DOCS_FOUND: 1 | zakon_o_porezu_na_dohodak_nn_32_2020_procisceni
- PROCISCENI_CUTOFF_MARKER: NONE
- PROCISCENI_CHAR_LEN: 2393
- AMANDMANI_CHAR_LEN: 0

## SUMMARY

- CONTROL_COUNT: 4
- CONTROL_COUNT_AMANDMANI: 0
- CONTROL_HEADERS_COUNT: 4
- NN_COUNT: 4
- MISSING_COUNT: 0
- SHORT_COUNT: 1
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4]
- CONTROL_HAS_10: False
- CONTROL_HAS_11: False
- CONTROL_HAS_12: False
- CONTROL_TRUNCATION_SUSPECTED: False
- CONTROL_MIN: 1
- CONTROL_MAX: 4
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

- Članak 3 (len=192) -> clanak_0003.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: (none)
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: Anomaly check (10-12) nije primjenjiv za ovaj akt.
