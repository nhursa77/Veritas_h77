# MAPA_DOKUMENTACIJE_VERITAS_H77

Datum: 17.02.2026.
Status: kanonski
Opseg: navigacija kroz postojeću dokumentaciju Veritas H.77.

---

## 1) Kanon u 10 točaka

1) Jezik dokumentacije i zapisa je hrvatski.
2) Datumi se zapisuju u formatu `DD.MM.YYYY.`.
3) Ograničenje retka je MD013, najviše 80 znakova po retku.
4) Dokumenti imaju opisna imena datoteka.
5) Veritas generira isključivo na upit.
6) Veritas ne potpisuje i ne šalje.
7) Čovjek odlučuje o potpisu i slanju.
8) zakon.hr je operativni izvor, Narodne novine su dokazna sidra.
9) NORMA JSON i POSTUPAK JSON su obavezni standardi.
10) Svaki značajan korak evidentira se u `DNEVNIK_RADA.md`.

---

## 2) Kanonski dokumenti

### `METODOLOGIJA_RADA_VERITAS_H77.md`
Definira što je Veritas H.77, kako radi i gdje su granice odgovornosti.
Sadrži hijerarhiju normi, pravilo izvora i gate pravila statusa izlaza.

### `RJEČNIK_POJMOVA_VERITAS_H77.md`
Definira pojmove koji se koriste u dokumentima, JSON zapisima i obradi.
Osigurava jednoznačno značenje ključnih termina.

### `TEHNIČKI_OKVIR_VERITAS_H77.md`
Definira tehnički okvir rada repozitorija i reprodukcije okruženja.
Sadrži pravila artefakata, izvora, snapshota i kontrole kvalitete.

### `STANDARD_JSON_NORMA.md`
Definira standard zapisa norme u JSON formatu s člankom kao jedinicom.
Uređuje strukturu, izvore, sidra i uvjete valjanosti normativnog zapisa.

### `STANDARD_JSON_POSTUPAK.md`
Definira standard proceduralnih koraka u JSON formatu.
Uređuje gate uvjete, ulaze, radnje i izlaze postupanja.

### `RAZVOJNI_PLAN_VERITAS_H77.md`
Definira faze razvoja sustava, redoslijed rada i operativne gate uvjete.
Služi kao plan izvođenja od MVP-a do prvog živog predmeta.

### `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
Definira kanonske faze, artefakte, putanje i gate kriterije prekršajnog
modula kao pilot domenu.

### `DNEVNIK_RADA.md`
Evidentira značajne korake rada kronološki.
Služi kao dokazni trag promjena i odluka kroz vrijeme.

### `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
Zamrzava trenutno stanje repozitorija za nastavak rada bez
kopanja po povijesti.
Sadrži stanje grane, zadnje commitove, čistoću repoa i aktivne gate markere.

---

## 3) Redoslijed čitanja

1) `METODOLOGIJA_RADA_VERITAS_H77.md`
2) `RJEČNIK_POJMOVA_VERITAS_H77.md`
3) `TEHNIČKI_OKVIR_VERITAS_H77.md`
4) `STANDARD_JSON_NORMA.md`
5) `STANDARD_JSON_POSTUPAK.md`
6) `RAZVOJNI_PLAN_VERITAS_H77.md`
7) `DNEVNIK_RADA.md`
8) `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`

---

## 4) Pravilo održavanja indexa

Kad se doda novi dokument ili izmijeni postojeći, mora se ažurirati i ovaj
index.
Svako ažuriranje indexa evidentira se u `DNEVNIK_RADA.md`.

---

## 5) Gdje što pripada

- Norme pripadaju standardu `STANDARD_JSON_NORMA.md` i zapisima NORMA JSON.
- Postupci pripadaju standardu `STANDARD_JSON_POSTUPAK.md` i PROCEDURA JSON.
- Pojmovi i definicije pripadaju `RJEČNIK_POJMOVA_VERITAS_H77.md`.
- Tehničke odluke pripadaju `TEHNIČKI_OKVIR_VERITAS_H77.md`.
- Opća metodologija i gate logika pripadaju
  `METODOLOGIJA_RADA_VERITAS_H77.md`.
- Razvojne faze i redoslijed rada pripadaju `RAZVOJNI_PLAN_VERITAS_H77.md`.
- Kronologija stvarnog rada pripada `DNEVNIK_RADA.md`.
