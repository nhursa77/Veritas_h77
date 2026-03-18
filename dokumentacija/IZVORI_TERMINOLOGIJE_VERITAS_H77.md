# IZVORI_TERMINOLOGIJE_VERITAS_H77

Datum: 18.03.2026.
Status: kanonski
Opseg: dokazni izvori terminoloških podataka za Veritas H.77.

---

## CURIA VJM/IATE XLSX (svi jezici)

CURIA XLSX je uveden kao dokazni terminološki izvor za višestruke jezične
varijante pravnih termina.

Svrha:
- višejezični terminološki ekvivalenti
- pomoć pri dosljednom nazivlju kroz jezike

Ograničenje:
- nije zamjena za procesne institute RH
- ne definira pravni učinak postupanja u RH

Odnos prema NN:
- Narodne novine ostaju primarno sidro za pravni učinak i primjenu
- CURIA/IATE služi kao pomoćni terminološki sloj

Dokazni artefakti u repozitoriju:
- `izvori/dokazno/eu/curia/vjm_iate/iate_popis_svih_jezika/izvor.xlsx`
- `izvori/dokazno/eu/curia/vjm_iate/iate_popis_svih_jezika/meta.json`
- `izvori/dokazno/eu/curia/vjm_iate/iate_popis_svih_jezika/status.txt`

## Sirovi JSON izvoz (tehnički međusloj)

Iz dokaznog XLSX izvora postoji i sirovi strojni izvoz u JSON formatu:
- `izvori/operativno/eu/curia/vjm_iate/iate_popis_svih_jezika_raw.json`
- `izvori/operativno/eu/curia/vjm_iate/iate_popis_svih_jezika_struktura.json`

Ovaj izvoz je tehnički međusloj između dokaznog izvora i kasnijih obrada.
Sirovi JSON nije normirani rječnik Veritasa i ne predstavlja pravno
tumačenje pojmova.

## Normalizirani operativni sloj

Iz sirovog izvoza generira se normalizirani skup zapisa:
- `baza_terminologije/eu/curia/terminoloski_zapisi.json`

Normalizacija se izvodi skriptom:
- `alati/normaliziraj_curia_terminologiju.py`

Ovaj sloj je kanonski operativni terminološki međusloj EU izvora i nije
korisnički rječnik Veritasa.
