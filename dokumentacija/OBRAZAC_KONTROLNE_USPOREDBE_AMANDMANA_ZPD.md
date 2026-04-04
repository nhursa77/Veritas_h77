# OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD

Datum: 31.03.2026.
Status: kanonski
Opseg: izvedeni obrazac za kontrolne usporedbe zasebnih ZPD amandmana
sa `zakon.hr` na temelju stvarnih rezultata Z120 i Z121.

---

## 1) Empirijska baza obrasca

Obrazac je izveden iz stvarno dovrsenih usporedbi za:

- `zakon_o_porezu_na_dohodak_nn_106_2018` (Z120)
- `zakon_o_porezu_na_dohodak_nn_121_2019` (Z121)

U oba slucaja kontrolni izvor je zaseban amandmanski zapis na `zakon.hr`,
a ne konsolidirani zapis `/z/85`.

U oba izvjestaja vrijedi isti temeljni obrazac:

- `MISSING_COUNT=0`
- `CONTROL_TRUNCATION_SUSPECTED=False`
- `GUARDRAIL_FAIL=False`
- `ANOMALY_FLAG=False`

To je jezgra kanonskog prolaza za amandmansku kontrolnu usporedbu.

## 2) Sto validator stvarno provjerava

Validator amandmanski prolaz ne temelji na tvrdnji da je tekst NN izvora
bitno-identican tekstu `zakon.hr` zapisa.

Relevantni tvrdi signali su:

- da nijedan clanak iz kontrolnog zapisa ne nedostaje u NN setu
- da kontrolni zapis ne pokazuje truncation signal
- da odabrani NN izvor ne pada na source-selection guardrailu
- da HTML anomaly provjera ne signalizira strukturni problem

`SHORT_COUNT` je informativan signal o kratkim clancima, a ne samostalan
razlog pada. `EXTRA_LIST` je popis clanaka koji postoje u NN setu, a ne u
kontrolnom zapisu, ali sam po sebi ne aktivira `GUARDRAIL_FAIL`.

## 3) Strukturni odnos NN i zakon.hr kod amandmana

Kod Z120 i Z121 stvarni NN amandmanski izvor parsira se kao jedan dokument
`*_procisceni`, dok kontrolni parser pronalazi dva dokumenta
(`*_procisceni` i `*_amandmani`), ali s `PROCISCENI_CUTOFF_MARKER: NONE` i
`CONTROL_COUNT_AMANDMANI: 0`.

Operativna posljedica je jasna: usporedba se u praksi vodi nad skupom
brojeva clanaka i njihovim tekstovima unutar glavnog clankovnog toka, a ne
nad formalnom podjelom kontrolnog zapisa na posebni amandmanski blok.

Za zasebne ZPD amandmane zato nije potrebno forsirati tekstualnu identicnost
oblika zapisa izmedu NN i `zakon.hr`, nego dokazati da je normativna pokrivenost
stabilna i bez tvrdih signala kvara.

## 4) Tumačenje Z120 (`NN 106/2018`)

Z120 daje cisti obrazac prolaza:

- `CONTROL_COUNT=33`
- `NN_COUNT=33`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[]`
- `SHORT_COUNT=9`

Zakljucak je da je prolaz moguc i kad postoji veci broj kratkih clanaka,
ako su to stvarno kratke amandmanske norme i nema missing/truncation/anomaly
signala.

Z120 je ujedno dokaz da je prvi stabilni obrazac za ZPD amandmane zahtijevao
minimalan patch parsera i validatora, ali je nakon toga dobiven kanonski
izvjestaj bez guardrail pada.

## 5) Tumačenje Z121 (`NN 121/2019`)

Z121 pokazuje da potpuni brojcani identitet nije obvezan uvjet prolaza:

- `CONTROL_COUNT=21`
- `NN_COUNT=22`
- `MISSING_COUNT=0`
- `EXTRA_LIST=[27]`
- `SHORT_COUNT=6`

Ključni signal nije razlika `21` naspram `22`, nego cinjenica da kontrolni
zapis nije izgubio nijedan clanak koji NN sadrzi kao obvezni minimum, te da
`EXTRA_LIST=[27]` nije pracen truncation, anomaly ili guardrail signalom.

Operativno tumacenje je da zakon.hr amandmanski zapis moze biti urednicki ili
strukturno drugacije slozen od NN zapisa, pa izolirani `EXTRA_LIST` nalaz nije
automatski dokaz parser greske ni razlog za patch.

## 6) Kanonski kriterij prolaza

Za zasebni ZPD amandman usporedba se vodi kao uspjesna bez dodatnog patcha kad
vrijedi sve ispod:

1. dokazan je zaseban `zakon.hr` amandmanski URL za taj NN akt
2. `MISSING_COUNT=0`
3. `CONTROL_TRUNCATION_SUSPECTED=False`
4. `GUARDRAIL_FAIL=False`
5. `ANOMALY_FLAG=False`

Pri tome su dopusteni sljedeci nalazi bez automatskog faila:

- nenulti `SHORT_COUNT`
- `NN_COUNT` razlicit od `CONTROL_COUNT`
- nenulti `EXTRA_LIST`, ali samo ako ne prati tvrdi signal kvara iz gornjih
  tocaka

## 7) Kada patch nije opravdan

Patch parsera ili validatora nije opravdan samo zato sto:

- amandman ima kratke clanke
- zakon.hr ne reproducira potpuno isti urednicki raspored kao NN
- postoji izolirani `EXTRA_LIST`, a `MISSING_COUNT` ostaje nula

Patch je opravdan tek ako stvarni dokaz pokaze da parser gubi clanak,
krivo broji clanke, pogresno bira izvor ili validator podize guardrail/
anomaly signal.

## 8) Operativna uporaba obrasca

Ovaj dokument sluzi kao kanonski obrazac za sve daljnje usporedbe zasebnih
ZPD amandmana nakon Z120 i Z121.

Ako novi amandman zavrsi s `MISSING_COUNT=0` i bez tvrdih fail signala,
rezultat se vodi kao stabilan cak i kad izvjestaj zadrzi `SHORT_COUNT` ili
izolirani `EXTRA_LIST`.
