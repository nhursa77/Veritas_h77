# REZIM KONVERZIJE ZPD U JSON

Datum: 31.03.2026.
Status: kanonski
Opseg: utvrdjivanje izvora i rezima ingest-a za
`zakon_o_porezu_na_dohodak`.

---

## A) Ciljani zakon

- `zakon_o_porezu_na_dohodak`

---

## B) Prioritet i provjera izvora

Prioritetni redoslijed projekta potvrđuje da je
`zakon_o_porezu_na_dohodak` sljedeci zakon u Paket B, odmah nakon vec
obradenog `opci_porezni_zakon`.

Primarna dokazna provjera odradjena je na Narodnim novinama po stvarnim
brojevima koji cine vazeci niz tog zakona:

- `NN 115/2016`: na izdanju je pronadjen naslov `Zakon o porezu na dohodak`
- `NN 106/2018`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`
- `NN 121/2019`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`
- `NN 32/2020`: na izdanju je pronadjen naslov
  `Zakon o izmjeni i dopunama Zakona o porezu na dohodak`
- `NN 138/2020`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`
- `NN 151/2022`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`
- `NN 114/2023`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`
- `NN 152/2024`: na izdanju je pronadjen naslov
  `Zakon o izmjenama i dopunama Zakona o porezu na dohodak`

Rezultat NN provjere:

- dokazani su izvorni zakon i zasebne kasnije izmjene/dopune kroz vise NN
  objava
- nije dokazan jedan zasebni vazeci NN akt tipa prociscenog ili drugog
  cjelovitog samostalnog ulaza po obrascu `ustav_rh_procisceni`
- zato se vazeci tekst ne moze kanonski tretirati kao `PROCISCENI_FIRST`
  samo na temelju NN dokaza

Kontrolni izvor `zakon.hr` prikazuje vazeci procisceni tekst sastavljen iz
istog niza objava (`115/16`, `106/18`, `121/19`, `32/20`, `138/20`,
`151/22`, `114/23`, `152/24`), ali taj trag ostaje kontrolni i nije
primarni dokazni temelj odluke.

---

## C) Pravilo odluke

Obavezno pravilo odluke bez alternative:

- ako je zakon na Narodnim novinama dostupan kao jedan vazeci cjeloviti akt
  ili kao jasan procisceni ulaz, ide se po obrascu prociscenog akta
- ako je na Narodnim novinama dokaziv samo izvorni zakon plus niz zasebnih
  izmjena i dopuna, mora se odabrati model kao `prekrsajni_zakon`

---

## D) Operativni zakljucak za ZPD

REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL

Operativna posljedica:

- za `zakon_o_porezu_na_dohodak` treba pripremiti manifest tipa
  `core + amandmani`
- primarni dokazni izvor ostaju Narodne novine
- `zakon.hr` ostaje samo kontrolni izvor za kasniju validaciju

---

## E) Veza s postojecim projektom

- `ustav_rh_procisceni` predstavlja postojeci uzorak rada za procisceni akt
- `prekrsajni_zakon` predstavlja postojeci uzorak rada za zakon koji se vodi
  kroz izvorni akt i zasebne izmjene/dopune

Za ZPD je na temelju primarne NN provjere potvrden drugi obrazac rada.
