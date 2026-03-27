# PRIORITETI KONVERZIJE ZAKONA U JSON

Datum: 27.03.2026.
Status: kanonski
Opseg: prioritetni redoslijed daljnje konverzije zakona u NORMA JSON.

---

## A) Polazno stanje

Vec pretvoreni operativni setovi u JSON NORMA sloju:

- `ustav_rh_procisceni`
- `prekrsajni_zakon_procisceni`

Daljnja konverzija zakona mora se voditi po istom kanonskom obrascu:

- primarni izvor je Narodne novine (NN)
- koristi se postojeci ingest -> parser -> normiranje -> validacija workflow
- koriste se i prilagodavaju postojece skripte
- ne uvodi se novi paralelni postupak ako vec postoji skriptni obrazac

---

## B) Prioritetni redoslijed zakona za daljnju konverziju

### Paket A — odmah

- `zakon_o_opcem_upravnom_postupku`
- `zakon_o_upravnim_sporovima`
- `opci_porezni_zakon`

### Paket B — odmah nakon toga

- `zakon_o_porezu_na_dohodak`
- `zakon_o_lokalnim_porezima`

### Paket C — nakon osnovnog poreznog sloja

- `zakon_o_fiskalizaciji`
- `zakon_o_porezu_na_dodanu_vrijednost`
- `zakon_o_porezu_na_dobit`

### Paket D — širenje prekršajnog modula

- `zakon_o_sigurnosti_prometa_na_cestama`
- `zakon_o_zastiti_od_nasilja_u_obitelji`

---

## C) Obrazlozenje redoslijeda

- Procesni zakoni idu prvi jer cine opci postupovni okvir i stabiliziraju
  osnovu za daljnju normativnu obradu.
- Nakon njih se zatvara osnovni porezni sloj kako bi jezgra poreznih
  postupaka i obveza bila pokrivena standardiziranim NORMA zapisima.
- Posebni preksajni zakoni dolaze nakon opceg jezgra kako bi se sirenje
  preksajnog modula naslonilo na vec stabilnu bazu normi i workflow.

---

## D) Operativna napomena

- Ne treba izmisljati nove skripte ako vec postoji postojeci obrazac.
- Novi ingest se radi po modelu koji je vec koristen za
  `ustav_rh_procisceni` i `prekrsajni_zakon_procisceni`.
- Cilj je standardizirani JSON NORMA sloj, a ne ad-hoc parsiranje.
