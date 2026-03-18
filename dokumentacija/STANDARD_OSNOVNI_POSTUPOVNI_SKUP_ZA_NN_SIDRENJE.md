# STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE

Datum: 18.03.2026.
Status: kanonski
Opseg: proširenje jezgrene skupine na osnovni postupovni skup natuknica.

---

## 1) Svrha

Ovaj standard definira kako se iz pilot-skupa i jezgrene skupine formira
osnovni postupovni skup za prvo NN sidrenje.

Skup mora biti dovoljno uzak za ručni sidreni rad, ali dovoljno širok da
pokriva kostur postupka.

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json`
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json`

Izlaz:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/
 osnovni_postupovni_skup_za_nn_sidrenje_manifest.json`

---

## 3) Pravila proširenja

- svih 7 jezgrenih natuknica moraju ostati u skupu
- proširenje smije dodati samo opće i rječnički obradive natuknice
- složene fraze s uskim procesnim kontekstom ne ulaze u skup
- ne uvode se definicije
- ne uvode se NN sidra
- ne zaključuje se izvan naziva i postojećih tehničkih polja

---

## 4) Obavezna polja izlazne natuknice

Svaka natuknica zadržava puni postojeći sadržaj i dodatno ima:

- `osnovni_postupovni_skup` = `true`
- `osnova_ulaska_u_osnovni_skup`
- `redoslijed_osnovnog_skupa`

Dopuštene oznake `osnova_ulaska_u_osnovni_skup`:

- `PREUZETO_IZ_JEZGRE`
- `OPCI_POSTUPOVNI_POJAM`
- `TEMELJNI_STATUS_POSTUPKA`
- `TEMELJNI_AKT_ILI_RADNJA`

---

## 5) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj ulaznih pilot-natuknica
- ukupan broj natuknica u osnovnom postupovnom skupu
- broj po `osnova_ulaska_u_osnovni_skup`
- popis svih `kanonski_naziv`
- popis natuknica preuzetih iz jezgre
- popis natuknica dodanih proširenjem
- broj s praznim `nn_sidra`
- broj sa `status_validacije = CEKA_NN_SIDRO`

---

## 6) Ciljni postupovni kostur

Skup ciljano pokriva opće postupovne pojmove, gdje postoje u ulazu:

- žalba
- prigovor
- rješenje
- presuda
- dokaz
- dostava
- izvršenje
- postupak
- nadležnost
- rok
- tužba
- zahtjev
- stranka
- punomoć
- pristojba
- trošak postupka
- pravomoćnost
- izvršnost
- okrivljenik

Ako neki od navedenih pojmova nije prisutan u ulaznom skupu, to se ne
nadomješta ručnim dodavanjem ni nagađanjem.

---

## 7) Statusna pravila

U osnovnom postupovnom skupu i dalje vrijedi:

- `nn_sidra` ostaje prazna struktura
- `status_validacije` ostaje `CEKA_NN_SIDRO`
- nema normativnih definicija ni pravnih zaključaka

---

## 8) Veza s prvim stvarnim NN sidrenjem

Nakon izgradnje osnovnog postupovnog skupa, prvi stvarni sidreni korak izvodi
skripta `alati/sidri_osnovni_postupovni_skup_na_nn.py`.

Taj korak proizvodi:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren.json`
- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_sidren_manifest.json`

Pravila sidrenja definirana su standardom:

- `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
