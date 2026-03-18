# STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE

Datum: 18.03.2026.
Status: kanonski
Opseg: izdvajanje pilot-skupa rječničkih natuknica za prvo NN sidrenje.

---

## 1) Svrha

Ovaj standard definira deterministički odabir malog pilot-skupa iz
početnih rječničkih natuknica radi prvog stvarnog NN sidrenja.

Pilot-sloj je pripremni i ne uvodi pravni učinak.

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice.json`
- `baza_terminologije/rjecnik/pocetne_rjecnicke_natuknice_manifest.json`

Izlaz:

- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json`

---

## 3) Pravila izdvajanja

Dozvoljeni kriteriji su isključivo deterministički vidljivi podaci:

- `kanonski_naziv`
- `vrsta_pojma`
- postojeća tehnička polja natuknice

Nije dopušteno:

- uvoditi ručne pravne zaključke
- dodavati NN sidra
- pisati nove definicije

Pilot-skup cilja raspon 20-30 natuknica.
Ako rezultat odstupa od raspona, manifest mora imati izričitu napomenu.

---

## 4) Prioritetni procesni pojmovi

Prednost imaju natuknice čiji `kanonski_naziv` pokriva procesno jake
pojmove, uključivo varijante i složene izraze:

- žalba
- prigovor
- rješenje
- presuda
- tužba
- zahtjev
- rok
- dostava
- dokaz
- nadležnost
- zapisnik
- punomoć
- stranka
- okrivljenik
- trošak postupka
- pristojba
- izvršenje
- pravomoćnost
- izvršnost
- postupak

---

## 5) Obavezna pilot-polja

Svaka izdvojena natuknica mora zadržati puni izvorni sadržaj i dodatno
sadržavati:

- `pilot_skup` = `true`
- `osnova_ulaska_u_pilot`
- `redoslijed_pilota`

Dopuštene oznake `osnova_ulaska_u_pilot`:

- `PROCESNO_CENTRALAN_POJAM`
- `TEMELJNI_AKT`
- `TEMELJNA_PRAVNA_RADNJA`
- `TEMELJNI_STATUS_ILI_SVOJSTVO`
- `POSTUPOVNI_OKVIR`

---

## 6) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj ulaznih natuknica
- ukupan broj izdvojenih pilot-natuknica
- broj po `vrsta_pojma`
- broj po `osnova_ulaska_u_pilot`
- popis svih pilot `kanonski_naziv`
- broj natuknica s praznim `nn_sidra`
- broj natuknica sa `status_validacije = CEKA_NN_SIDRO`

---

## 7) Statusna pravila

Pilot-skup zadržava postojeća statusna polja iz ulaza.
U ovom koraku posebno vrijedi:

- `nn_sidra` ostaje prazna struktura spremna za sidrenje
- `status_validacije` ostaje `CEKA_NN_SIDRO`
- ne uvode se normativne definicije ni pravni zaključci
