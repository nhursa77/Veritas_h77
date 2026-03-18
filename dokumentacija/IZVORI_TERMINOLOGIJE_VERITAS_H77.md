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

## Segmentirani operativni format

Normalizirani puni izvoz ostaje:
- `baza_terminologije/eu/curia/terminoloski_zapisi.json`

Za operativni rad zapisi su dodatno segmentirani po worksheetu u:
- `baza_terminologije/eu/curia/segmenti/*.json`
- `baza_terminologije/eu/curia/segmenti_manifest.json`

Segmentacija se izvodi skriptom:
- `alati/segmentiraj_curia_terminoloske_zapise.py`

Segmenti su tehnički format rada; puni JSON ostaje cjeloviti izvoz.

## Hrvatski relevantan operativni sloj

Iz segmentiranih zapisa izdvojen je poseban skup hrvatski relevantnih
termina:
- `baza_terminologije/eu/curia/hrvatski_relevantni_termini.json`
- `baza_terminologije/eu/curia/hrvatski_relevantni_termini_manifest.json`

Izdvajanje se izvodi skriptom:
- `alati/izdvoji_hrvatski_relevantne_curia_termini.py`

Ovaj sloj nije rječnik instituta RH, nego tehnički pripremni most prema
budućem NN sidrenju.

## Tehnički most EU -> potencijalni NN pojmovi

Iz hrvatski relevantnog sloja generira se prijedlog mapiranja prema
potencijalnim NN pojmovima:
- `baza_terminologije/mape/eu_prema_nn/curia_prema_nn_potencijalni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/
	curia_prema_nn_potencijalni_pojmovi_manifest.json`

Mapiranje se izvodi skriptom:
- `alati/mapiraj_curia_na_potencijalne_nn_pojmove.py`

Ovaj sloj ne predstavlja normativno sidrenje ni zaključak o istom
pravnom institutu, nego tehnički prijedlog za ručnu provjeru.
