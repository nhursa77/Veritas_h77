# REVIZIJA_DOKUMENTACIJE_VERITAS_H77

Povijesna oznaka:

- status: povijesni dokazni trag
- operativni status: neaktivan
- supersedira ga:
  `dokumentacija/REVIZIJA_STRUKTURE_DOKUMENTACIJE_I_PREPORUKE_CISCENJA.md`
- napomena: ostaje u repou kao stariji read-only revizijski trag

Datum: 03.04.2026.
Status: read-only revizijska analiza
Opseg: klasifikacija svih postojecih `.md` dokumenata unutar
`dokumentacija/` u 5 trazenih kategorija.

---

## A) Metoda i ulazni kriteriji

Obavezno procitani upravljacki dokumenti:

- `dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`

Inventar za reviziju:

- Ukupno pronadjenih `.md` dokumenata u `dokumentacija/`: 58
- Klasifikacija je radena nad stvarnim stanjem datoteka u radnom stablu.

Kriteriji razvrstavanja:

- `AKTIVNI_KANONSKI_DOKUMENT`:
  dokument ima trajnu normativnu ili operativnu ulogu.
- `AKTIVNI_RADNI_TRAG`:
  dokument je ziv radni artefakt, ali nije glavni normativni standard.
- `ARHIVSKI_POVIJESNI_TRAG`:
  dokument ima dokaznu vrijednost, ali nije aktivni operativni tok.
- `ZASTARJELI_NEAKTIVNI_DOKUMENT`:
  dokument je vremenski vezan i vise nema aktivnu ulogu.
- `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`:
  dokument je potrosen proceduralni trag i moze se izdvojiti iz
  aktivnog sloja nakon dodatne potvrde.

---

## B) AKTIVNI_KANONSKI_DOKUMENT

1. `METODOLOGIJA_RADA_VERITAS_H77.md`
2. `RJEČNIK_POJMOVA_VERITAS_H77.md`
3. `TEHNIČKI_OKVIR_VERITAS_H77.md`
4. `MAPA_DOKUMENTACIJE_VERITAS_H77.md`
5. `STATUS_PROJEKTA_VERITAS_H77.md`
6. `DNEVNIK_RADA.md`
7. `RAZVOJNI_PLAN_VERITAS_H77.md`
8. `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
9. `PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`
10. `REZIM_KONVERZIJE_ZUP_U_JSON.md`
11. `REZIM_KONVERZIJE_ZUS_U_JSON.md`
12. `REZIM_KONVERZIJE_ZPD_U_JSON.md`
13. `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
14. `OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
15. `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
16. `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
17. `STANDARD_JSON_NORMA.md`
18. `STANDARD_JSON_POSTUPAK.md`
19. `STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
20. `STANDARD_JSON_AUDIT_PRIMJENE.md`
21. `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
22. `STANDARD_JSON_SUBSUMPCIJA.md`
23. `STANDARD_JSON_HIJERARHIJA.md`
24. `STANDARD_JSON_PREDLOZAK.md`
25. `STANDARD_FER_NAPLATA_PREKRSAJI.md`
26. `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
27. `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
28. `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
29. `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
30. `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
31. `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
32. `STANDARD_JSON_RJECNICKA_NATUKNICA.md`
33. `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
34. `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
35. `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
36. `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
37. `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
38. `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
39. `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
40. `STANDARD_GRANSKE_PODNATUKNICE_NN.md`
41. `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
42. `STANDARD_RIZIK_I_KOLIZIJE.md`
43. `STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
44. `STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
45. `STANDARD_ZASTITA_DNEVNIKA_RADA.md`

Kratko obrazlozenje:

- dokumenti definiraju kanonska pravila, tokove i statusne gateove,
- ili predstavljaju aktivne temeljne registre (`MAPA`, `STATUS`, `DNEVNIK`).

---

## C) AKTIVNI_RADNI_TRAG

1. `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`

Kratko obrazlozenje:

- dokument sluzi kao operativni snapshot za primopredaju i nastavak rada,
- nije temeljni normativni standard, ali je aktivno upotrebljiv radni trag.

---

## D) ARHIVSKI_POVIJESNI_TRAG

1. `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
2. `ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
3. `ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
4. `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
5. `ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`

Kratko obrazlozenje:

- dokumenti su dokazni i korisni za audit,
- ali nisu glavni aktivni operativni standardi.

---

## E) ZASTARJELI_NEAKTIVNI_DOKUMENT

1. `BASELINE_MARKDOWN_STANJA_REPOA.md`
2. `USPOREDBA_PREOSTALE_DVIJE_UNSTAGED_DATOTEKE.md`
3. `ANALIZA_ZPD_ZAVRSNOG_IZVJESTAJA_LOKALNI_DIFF.md`

Kratko obrazlozenje:

- dokumenti su vezani uz konkretne prolazne lokalne diff/snapshot situacije,
- nemaju trajnu kanonsku operativnu funkciju nakon zatvaranja tih koraka.

---

## F) KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA

1. `PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
2. `PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
3. `PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`

Kratko obrazlozenje:

- sva tri dokumenta su proceduralni medjukoraci jednog zatvorenog niza,
- glavni cilj im je bio priprema i odluka za arhiviranje/uklanjanje,
- nakon provedenih koraka imaju ogranicenu preostalu operativnu vrijednost.

Napomena rizika prije eventualnog uklanjanja:

- preporucuje se prvo arhivski indeksni zapis u `MAPA`/`STATUS`,
- tek zatim zaseban scoped korak uklanjanja,
- bez diranja aktivnih kanonskih standarda.

---

## Zavrsni sazetak

Raspodjela 58 dokumenata:

- `AKTIVNI_KANONSKI_DOKUMENT`: 45
- `AKTIVNI_RADNI_TRAG`: 1
- `ARHIVSKI_POVIJESNI_TRAG`: 5
- `ZASTARJELI_NEAKTIVNI_DOKUMENT`: 3
- `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`: 3

Zakljucak:

- aktivni kanonski sloj je opsezan i stabilan,
- povijesni i proceduralni tragovi su prepoznati i odvojeni,
- za daljnje ciscenje preporucen je strogo sekvencijalan scoped pristup.
