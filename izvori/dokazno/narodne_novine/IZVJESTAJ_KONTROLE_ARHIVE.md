# Izvještaj kontrole arhive NN

- Datum: 31.03.2026.
- Ukupno aktova u NORMA bazi: 6
- OK: 0
- NEDOSTAJE: 6
- HASH_NEDOSTAJE: 0
- NEVALJAN_IZVOR: 0

## Statusi

### OK

- Nema aktova sa statusom OK.

### NEDOSTAJE

- opci_porezni_zakon_procisceni | nedostaje mapa akta u NN arhivi
- prekrsajni_zakon_procisceni | nedostaje mapa akta u NN arhivi
- ustav_rh_procisceni | nedostaje mapa akta u NN arhivi
- zakon_o_opcem_upravnom_postupku_procisceni | nedostaje mapa akta u NN arhivi
- zakon_o_porezu_na_dohodak_procisceni | nedostaje mapa akta u NN arhivi
- zakon_o_upravnim_sporovima_procisceni | nedostaje mapa akta u NN arhivi

### HASH_NEDOSTAJE

- Nema aktova sa statusom HASH_NEDOSTAJE.

### NEVALJAN_IZVOR

- Nema aktova sa statusom NEVALJAN_IZVOR.

## Gate pravilo

- Ako postoji NEDOSTAJE, HASH_NEDOSTAJE ili NEVALJAN_IZVOR za akt koji se
  koristi u predmetu, vanjski izlaz je zabranjen.
