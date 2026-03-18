# STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE

Datum: 18.03.2026.
Status: kanonski
Opseg: tehničko izdvajanje prioritetnog uzorka pojmova za prvo NN sidrenje.

---

## 1) Svrha

Ovaj standard definira pravila za izdvajanje užeg, operativno korisnog
uzorka iz postojećih EU -> NN prijedloga mapiranja.

Uzorak služi pripremi sljedećeg koraka sidrenja, bez dohvaćanja ili potvrde
članaka Narodnih novina u ovom koraku.

---

## 2) Dopuštene osnove prioriteta

- `POUZDANOST_SREDNJA`
- `UCESTALI_KANDIDAT`
- `PROCESNI_NAZIV`

Svaki izdvojeni zapis mora imati jednu od navedenih osnova i
`redoslijed_prioriteta` kao deterministički broj.

---

## 3) Ograničenja

Nije dopušteno:

- uvoditi nove pravne tvrdnje
- upisivati članke, stavke ili zakone
- tretirati prijedlog kao potvrđeno NN sidro

Prioritetni uzorak je tehnički radni podskup, a ne normativna istina.

---

## 4) Izlazni artefakti

- `baza_terminologije/mape/eu_prema_nn/prioritetni_uzorak_za_nn_sidrenje.json`
- `baza_terminologije/mape/eu_prema_nn/prioritetni_uzorak_za_nn_sidrenje_manifest.json`

Manifest mora sadržavati broj ulaznih zapisa, broj izdvojenih zapisa,
raspodjelu po osnovi prioriteta, broj jedinstvenih kandidata i top 20
najčešćih kandidata.
