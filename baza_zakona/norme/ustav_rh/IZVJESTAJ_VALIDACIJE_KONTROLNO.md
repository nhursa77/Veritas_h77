# IZVJESTAJ_VALIDACIJE_KONTROLNO

- Timestamp: 2026-02-18T10:02:23+01:00
- NN_JSON: C:/Veritas_H77/izvori/dokazno/narodne_novine/ustav_rh/struktura_nn.json
- KONTROLNO_TXT: C:/Veritas_H77/izvori/kontrolno/zakon_hr/ustav_rh/ustav_rh_kontrolni.txt
- NN_JSON_SHA256: 9ca61c0736f184a646014855af4ea263e54df9ffb65f6f1eac4befc9ce2600ab
- KONTROLNO_TXT_SHA256: 2a38e78e9722336813597f74fe4d96526d937e9abaa2b356ce284539b77c6171

## SUMMARY

- CONTROL_COUNT: 142
- CONTROL_HEADERS_COUNT: 163
- NN_COUNT: 141
- MISSING_COUNT: 2
- SHORT_COUNT: 52
- ANOMALY_FLAG: True

## CONTROL_EXTRACTOR_DEBUG

- CONTROL_FIRST20_HEADERS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
- CONTROL_HAS_10: True
- CONTROL_HAS_11: True
- CONTROL_HAS_12: True
- WARNING: CONTROL_HEADERS_COUNT != len(control_nums): 163 vs 142

## Missing in NN (present in zakon.hr, absent in NN)

- 135
- 146

## Extra in NN (present in NN, absent in zakon.hr)

- 123

## Short texts in NN (len < 200)

- Članak 4 (len=108) -> clanak_0004.json
- Članak 5 (len=190) -> clanak_0005.json
- Članak 7 (len=164) -> clanak_0007.json
- Članak 8 (len=86) -> clanak_0008.json
- Članak 16 (len=140) -> clanak_0016.json
- Članak 20 (len=189) -> clanak_0020.json
- Članak 21 (len=80) -> clanak_0021.json
- Članak 22 (len=152) -> clanak_0022.json
- Članak 23 (len=164) -> clanak_0023.json
- Članak 26 (len=108) -> clanak_0026.json
- Članak 27 (len=102) -> clanak_0027.json
- Članak 28 (len=129) -> clanak_0028.json
- Članak 35 (len=123) -> clanak_0035.json
- Članak 39 (len=160) -> clanak_0039.json
- Članak 40 (len=101) -> clanak_0040.json
- Članak 42 (len=72) -> clanak_0042.json
- Članak 44 (len=132) -> clanak_0044.json
- Članak 46 (len=133) -> clanak_0046.json
- Članak 51 (len=169) -> clanak_0051.json
- Članak 54 (len=155) -> clanak_0054.json
- Članak 58 (len=58) -> clanak_0058.json
- Članak 60 (len=147) -> clanak_0060.json
- Članak 61 (len=129) -> clanak_0061.json
- Članak 62 (len=168) -> clanak_0062.json
- Članak 65 (len=168) -> clanak_0065.json
- Članak 66 (len=78) -> clanak_0066.json
- Članak 67 (len=119) -> clanak_0067.json
- Članak 70 (len=188) -> clanak_0070.json
- Članak 74 (len=155) -> clanak_0074.json
- Članak 76 (len=106) -> clanak_0076.json
- Članak 77 (len=176) -> clanak_0077.json
- Članak 82 (len=178) -> clanak_0082.json
- Članak 84 (len=53) -> clanak_0084.json
- Članak 85 (len=142) -> clanak_0085.json
- Članak 86 (len=167) -> clanak_0086.json
- Članak 89 (len=119) -> clanak_0089.json
- Članak 91 (len=150) -> clanak_0091.json
- Članak 92 (len=184) -> clanak_0092.json
- Članak 96 (len=105) -> clanak_0096.json
- Članak 103 (len=136) -> clanak_0103.json
- Članak 107 (len=78) -> clanak_0107.json
- Članak 108 (len=95) -> clanak_0108.json
- Članak 109 (len=193) -> clanak_0109.json
- Članak 110 (len=158) -> clanak_0110.json
- Članak 114 (len=161) -> clanak_0114.json
- Članak 115 (len=113) -> clanak_0115.json
- Članak 118 (len=60) -> clanak_0118.json
- Članak 126 (len=186) -> clanak_0126.json
- Članak 132 (len=144) -> clanak_0132.json
- Članak 136 (len=188) -> clanak_0136.json
- Članak 138 (len=133) -> clanak_0138.json
- Članak 139 (len=104) -> clanak_0139.json

## Anomaly hints

- ANOMALY_FLAG: True
- FOUND_BETWEEN_10_12: Članak 1 I.
- KEYWORDS_FOUND: Grb Republike Hrvatske, Zastava Republike Hrvatske, Himna je Republike Hrvatske
- NAPOMENA: ANOMALIJA: sadržaj čl. 11 je prisutan u HTML segmentu, ali heading je 'Članak 1 I.' -> NN parsiranje treba ručno/automatski rule. Ključne fraze: Grb Republike Hrvatske, Zastava Republike Hrvatske, Himna je Republike Hrvatske

