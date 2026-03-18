# STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE

Datum: 18.03.2026.
Status: kanonski
Opseg: izdvajanje jezgrenih rječničkih natuknica iz pilot-skupa.

---

## 1) Svrha

Ovaj standard definira kako se iz pilot-skupa odvajaju jezgrene natuknice
prikladne za prvo stvarno NN sidrenje.

Cilj je odvojiti osnovne pojmove/institute od složenih procesnih fraza i
izvedenih izraza.

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/pilot_natuknice_za_nn_sidrenje_manifest.json`

Izlaz:

- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje.json`
- `baza_terminologije/rjecnik/jezgrene_natuknice_za_nn_sidrenje_manifest.json`

---

## 3) Pravila izdvajanja

Zadržavaju se samo natuknice koje predstavljaju jezgreni pojam za rječničku
obradu i buduće NN sidrenje.

Složene natuknice ne ulaze u jezgreni skup ako predstavljaju:

- posebnu situaciju
- uži slučaj
- opis radnje u posebnom kontekstu
- kombinirani izraz s više pojmova

Dopušteni kriteriji su isključivo:

- tekst `kanonski_naziv`
- postojeća tehnička polja natuknice

Nije dopušteno:

- nagađanje izvan teksta i tehničkih polja
- dodavanje NN sidara
- pisanje definicija

---

## 4) Tipični jezgreni i složeni izrazi

Tipično jezgreni izrazi:

- žalba
- prigovor
- rješenje
- presuda
- dokaz
- dostava
- izvršenje
- postupak
- nadležnost
- stranka
- punomoć
- zapisnik
- rok
- pristojba
- trošak postupka
- pravomoćnost
- izvršnost
- okrivljenik
- tužba
- zahtjev

Tipično složeni/izvedeni izrazi (ne ulaze):

- dostava tužbe tuženiku
- dokaz o protivnom
- rješenje kojim se završava postupak
- dostava po službenoj dužnosti
- dokaz saslušanjem svjedoka
- prigovor nenadležnosti

---

## 5) Obavezna jezgrena polja

Svaka jezgrena natuknica zadržava puni sadržaj pilot-zapisa i dodatno ima:

- `jezgrena_natuknica` = `true`
- `osnova_jezgrenosti`
- `redoslijed_jezgrenog_skupa`

Dopuštene oznake `osnova_jezgrenosti`:

- `OSNOVNI_PROCESNI_POJAM`
- `OSNOVNI_PRAVNI_AKT`
- `OSNOVNA_PRAVNA_RADNJA`
- `OSNOVNI_STATUS_ILI_SVOJSTVO`
- `OSNOVNI_POSTUPOVNI_OKVIR`

---

## 6) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj ulaznih pilot-natuknica
- ukupan broj izdvojenih jezgrenih natuknica
- broj po `osnova_jezgrenosti`
- popis svih jezgrenih `kanonski_naziv`
- popis odbačenih složenih natuknica
- broj natuknica s praznim `nn_sidra`
- broj natuknica sa `status_validacije = CEKA_NN_SIDRO`

---

## 7) Statusna pravila

Jezgreni skup zadržava statusna i sidrena polja iz pilot-sloja.
U ovom koraku vrijedi:

- `nn_sidra` ostaje prazna struktura
- `status_validacije` ostaje `CEKA_NN_SIDRO`
- ne uvode se normativne definicije ni pravni zaključci
