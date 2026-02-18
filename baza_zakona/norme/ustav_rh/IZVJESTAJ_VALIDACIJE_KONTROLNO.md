# IZVJESTAJ_VALIDACIJE_KONTROLNO

## Source selection

- SELECTED_SOURCE_SLUG: ustav_rh_nn_85_2010
- SELECTED_SOURCE_TIP_TEKSTA: procisceni
- SELECTED_SOURCE_EXPECTED_COUNT: 152
- SOURCE_SELECTION_MISMATCH: False

## Source selection guardrail

- Selected slug: ustav_rh_nn_85_2010
- Selected tip_teksta: procisceni
- Expected count: 152
- EXPECTED_COUNT_OVERRIDE: NONE
- EXPECTED_COUNT_SOURCE: meta
- NN_COUNT: 152
- SOURCE_SELECTION_MISMATCH: False
- GUARDRAIL_FAIL: False

- Timestamp: 2026-02-18T15:41:26+01:00
- NN_JSON_SHA256: 7b100ed17bb09db55d8b0fa50067918e590445ccdb741ea77fb8dddd59a7282c
- KONTROLNO_TXT_SHA256: 2a38e78e9722336813597f74fe4d96526d937e9abaa2b356ce284539b77c6171

## Document split summary

- CONTROL_DOCS_FOUND: 2 | ustav_rh_procisceni, ustav_rh_amandmani
- NN_DOCS_FOUND: 1 | ustav_rh_procisceni
- PROCISCENI_CUTOFF_MARKER: Ustavni zakon o izmjenama i dopunama Ustava
  Republike Hrvatske (NN 135/97.)
- PROCISCENI_CHAR_LEN: 90337
- AMANDMANI_CHAR_LEN: 1771

## SUMMARY

- CONTROL_COUNT: 141
- CONTROL_COUNT_AMANDMANI: 8
- CONTROL_HEADERS_COUNT: 141
- NN_COUNT: 152
- MISSING_COUNT: 0
- SHORT_COUNT: 49
- ANOMALY_FLAG: False

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- CONTROL_TRUNCATION_SUSPECTED: True
- CONTROL_MIN: 1
- CONTROL_MAX: 141
- CONTROL_TYPO_HEADERS: (none)
- CONTROL_SUSPECTED_TRUNCATED_HEADERS: L1684: 'Članak 12.' -> inferred 123
  (prev=122, next=124)

## Control source anomaly (zakon.hr truncation suspected)

- CONTROL_TRUNCATION_SUSPECTED: True
- found small numbers (12/13/14) in same control set with high range >=120

## Missing in NN (present in zakon.hr, absent in NN)

- (none)

## Extra in NN (present in NN, absent in zakon.hr)

- UNTRUSTWORTHY_CONTROL_EXTRA_LIST: kontrolni izvor je označen kao nepouzdan
  (truncation suspected).
- Kandidati (nepouzdano): 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152

## Short texts in NN (len < 200)

- Članak 5 (len=198) -> clanak_0005.json
- Članak 8 (len=78) -> clanak_0008.json
- Članak 13 (len=183) -> clanak_0013.json
- Članak 20 (len=172) -> clanak_0020.json
- Članak 21 (len=81) -> clanak_0021.json
- Članak 22 (len=152) -> clanak_0022.json
- Članak 23 (len=164) -> clanak_0023.json
- Članak 26 (len=130) -> clanak_0026.json
- Članak 27 (len=100) -> clanak_0027.json
- Članak 28 (len=129) -> clanak_0028.json
- Članak 35 (len=111) -> clanak_0035.json
- Članak 36 (len=198) -> clanak_0036.json
- Članak 39 (len=160) -> clanak_0039.json
- Članak 40 (len=101) -> clanak_0040.json
- Članak 42 (len=84) -> clanak_0042.json
- Članak 44 (len=144) -> clanak_0044.json
- Članak 46 (len=125) -> clanak_0046.json
- Članak 51 (len=169) -> clanak_0051.json
- Članak 55 (len=155) -> clanak_0055.json
- Članak 59 (len=67) -> clanak_0059.json
- Članak 61 (len=147) -> clanak_0061.json
- Članak 62 (len=126) -> clanak_0062.json
- Članak 63 (len=165) -> clanak_0063.json
- Članak 66 (len=168) -> clanak_0066.json
- Članak 67 (len=73) -> clanak_0067.json
- Članak 68 (len=119) -> clanak_0068.json
- Članak 71 (len=101) -> clanak_0071.json
- Članak 72 (len=151) -> clanak_0072.json
- Članak 73 (len=148) -> clanak_0073.json
- Članak 75 (len=156) -> clanak_0075.json
- Članak 77 (len=143) -> clanak_0077.json
- Članak 80 (len=197) -> clanak_0080.json
- Članak 82 (len=160) -> clanak_0082.json
- Članak 84 (len=38) -> clanak_0084.json
- Članak 85 (len=127) -> clanak_0085.json
- Članak 102 (len=173) -> clanak_0102.json
- Članak 108 (len=78) -> clanak_0108.json
- Članak 112 (len=195) -> clanak_0112.json
- Članak 114 (len=105) -> clanak_0114.json
- Članak 115 (len=165) -> clanak_0115.json
- Članak 118 (len=164) -> clanak_0118.json
- Članak 121 (len=122) -> clanak_0121.json
- Članak 127 (len=193) -> clanak_0127.json
- Članak 137 (len=194) -> clanak_0137.json
- Članak 147 (len=161) -> clanak_0147.json
- Članak 148 (len=173) -> clanak_0148.json
- Članak 149 (len=90) -> clanak_0149.json
- Članak 150 (len=63) -> clanak_0150.json
- Članak 151 (len=173) -> clanak_0151.json

## Anomaly hints

- ANOMALY_FLAG: False
- FOUND_BETWEEN_10_12: None
- KEYWORDS_FOUND: Grb Republike Hrvatske, Zastava Republike Hrvatske, Himna je
  Republike Hrvatske
- FOUND_TYPO_HEADERS: (none)
- NAPOMENA: U segmentu između 'Članak 10.' i 'Članak 12.' nije pronađen heading
  'Članak 1 I.'.
