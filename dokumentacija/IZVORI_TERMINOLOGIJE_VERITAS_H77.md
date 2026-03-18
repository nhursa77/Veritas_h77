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

## Prioritetni uzorak za NN sidrenje

Iz skupa predloženih mapiranja izdvojen je prioritetni radni uzorak:
- `baza_terminologije/mape/eu_prema_nn/prioritetni_uzorak_za_nn_sidrenje.json`
- `baza_terminologije/mape/eu_prema_nn/
 prioritetni_uzorak_za_nn_sidrenje_manifest.json`

Izdvajanje se izvodi skriptom:
- `alati/izdvoji_prioritetni_uzorak_za_nn_sidrenje.py`

Uzorak je tehnička priprema za buduće NN sidrenje i ne predstavlja
potvrđene članke, stavke ni normativne zaključke.

## NN-sidrenju podobni pojmovi (očišćeni uzorak)

Iz prioritetnog uzorka izdvojen je uži skup tekstualno podobnih kandidata:
- `baza_terminologije/mape/eu_prema_nn/nn_sidrenju_podobni_pojmovi.json`
- `baza_terminologije/mape/eu_prema_nn/
 nn_sidrenju_podobni_pojmovi_manifest.json`

Čišćenje se izvodi skriptom:
- `alati/ocisti_prioritetni_uzorak_za_nn_sidrenje.py`

Ovaj sloj ne uvodi članke, stavke ni pravne učinke; služi kao tehnička
priprema za ručni NN pregled u sljedećem koraku.

## Početne rječničke natuknice (kanonski model)

Iz očišćenog skupa NN-sidrenju podobnih pojmova generira se početni
operativni rječnički skup:
- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice.json`
- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice_manifest.json`

Izgradnja se izvodi skriptom:
- `alati/izgradi_pocetne_rjecnicke_natuknice.py`

Model natuknice definiran je standardom:
- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`

Ovaj sloj je operativna priprema za buduće NN sidrenje i ne predstavlja
normativni zaključak ni pravni učinak.

## Pilot natuknice za prvo NN sidrenje

Iz početnog rječničkog skupa izdvaja se mali pilot-skup za prvi ciklus
stvarnog NN sidrenja:
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json`

Izdvajanje se izvodi skriptom:
- `alati/izdvoji_pilot_natuknice_za_nn_sidrenje.py`

Pravila izdvajanja definirana su standardom:
- `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`

Pilot-sloj ne uvodi NN sidra ni pravne definicije, nego određuje redoslijed
ručne provjere i sidrenja u sljedećem koraku.

## Jezgrene natuknice za NN sidrenje

Iz pilot-skupa izdvaja se uži jezgreni skup osnovnih natuknica za prvi
praktični ciklus sidrenja:
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json`

Izdvajanje se izvodi skriptom:
- `alati/izdvoji_jezgrene_natuknice_iz_pilota.py`

Pravila su definirana standardom:
- `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`

Jezgreni sloj i dalje ne uvodi NN sidra ni definicije; služi za fokusirani
ručni NN pregled osnovnih pojmova.
