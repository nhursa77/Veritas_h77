# REVIZIJA STRUKTURE DOKUMENTACIJE I PREPORUKE CISCENJA

Datum: 04.04.2026.
Status: read-only dokazna revizija.
Opseg: potpuna analiza mape `dokumentacija/` bez izmjena postojećih
 datoteka, bez commita i bez pusha.

---

## A) Polazni git dokaz

Polazni pre-check pokrenut je iz `C:\Veritas_H77`.

Utvrđeno stanje prije izrade ovog izvještaja:

- lokalni HEAD: `734c52d`
- zadnji commit:
  `docs: dokaz zatvorenog markdown backloga`
- grana: `main`
- stanje grane: `main` je poravnat s `origin/main`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git status --short`: prazno
- `git stash list`:
  `stash@{0}: On main: veritas-pre-rebase-z147`

Zaključak pre-checka:

- repo je čist prije read-only revizije
- nema tracked ni staged diffa
- `main` je poravnat s `origin/main`
- stash nije diran

---

## B) Inventar dokumentacije

Ukupan broj pregledanih postojećih `.md` dokumenata u `dokumentacija/`
prije izrade ovog izvještaja: `58`.

Obvezno pročitani upravljački i kanonski dokumenti:

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`
- `dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md`
- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`

Popis svih stvarno pregledanih datoteka:

1. `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_`
   `ZAKONI_S_AMANDMANIMA.md`
2. `dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`
3. `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_`
   `AMANDMANIMA.md`
4. `dokumentacija/DNEVNIK_RADA.md`
5. `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
6. `dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
7. `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
8. `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
9. `dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md`
10. `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
11. `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_`
    `S_AMANDMANIMA.md`
12. `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
13. `dokumentacija/PREOSTALI_MARKDOWN_BACKLOG_NAKON_SELECTION_`
    `REPORT_SANACIJE.md`
14. `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_`
    `Z138_DO_Z142.md`
15. `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
16. `dokumentacija/PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`
17. `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_`
    `Z138_DO_Z142.md`
18. `dokumentacija/PROCJENA_SKUPINE_ZASTARJELI_NEAKTIVNI_`
    `DOKUMENTI.md`
19. `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
20. `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
21. `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`
22. `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
23. `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
24. `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`
25. `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`
26. `dokumentacija/RJEČNIK_POJMOVA_VERITAS_H77.md`
27. `dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
28. `dokumentacija/STANDARD_FER_NAPLATA_PREKRSAJI.md`
29. `dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
30. `dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md`
31. `dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_`
    `TERMINA.md`
32. `dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
33. `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_`
    `SIDRENJE.md`
34. `dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md`
35. `dokumentacija/STANDARD_JSON_HIJERARHIJA.md`
36. `dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
37. `dokumentacija/STANDARD_JSON_NORMA.md`
38. `dokumentacija/STANDARD_JSON_POSTUPAK.md`
39. `dokumentacija/STANDARD_JSON_PREDLOZAK.md`
40. `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`
41. `dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md`
42. `dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
43. `dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
44. `dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
45. `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_`
    `NATUKNICA.md`
46. `dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_`
    `SIDRENJE.md`
47. `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
48. `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
49. `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
50. `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
51. `dokumentacija/STANDARD_RIZIK_I_KOLIZIJE.md`
52. `dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_`
    `SIDARA.md`
53. `dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
54. `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
55. `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`
56. `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
57. `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
58. `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`

---

## C) Klasifikacija po datotekama

### C1) `AKTIVNI_KANONSKI_DOKUMENT`

- `dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: temeljni metodološki dokument projekta.
  - preporuka: `OSTAVITI`

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonska navigacija kroz cijelu dokumentaciju.
  - preporuka: `OSTAVITI`

- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: glavni statusni snapshot i pregled dovršenih zadataka.
  - preporuka: `OSTAVITI`

- `dokumentacija/DNEVNIK_RADA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: append-only evidencijski trag svih značajnih koraka.
  - preporuka: `OSTAVITI`

- `dokumentacija/RJEČNIK_POJMOVA_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira ključne pojmove i terminološki kanon.
  - preporuka: `OSTAVITI`

- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira tehnički okvir, artefakte i reprodukciju rada.
  - preporuka: `OSTAVITI`

- `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: nosi kanonski redoslijed razvoja sustava.
  - preporuka: `OSTAVITI`

- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: vodi pilot domenu i gate kriterije modula.
  - preporuka: `OSTAVITI`

- `dokumentacija/PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira aktivni prioritet ingest i JSON konverzije.
  - preporuka: `OSTAVITI`

- `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: aktivni rezim konverzije za ZPD.
  - preporuka: `OSTAVITI`

- `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: aktivni rezim konverzije za ZUP.
  - preporuka: `OSTAVITI`

- `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: aktivni rezim konverzije za ZUS.
  - preporuka: `OSTAVITI`

- `dokumentacija/IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira dokazne izvore terminologije.
  - preporuka: `OSTAVITI`

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: objedinjeni glavni obrazac za zakone s amandmanima.
  - preporuka: `OSTAVITI`

- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski obrazac kontrole ZPD amandmana.
  - preporuka: `OSTAVITI`

- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: završni objedinjeni pregled za cijeli ZPD set.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: tvrda pravila append-only zaštite dnevnika.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski standard sinkronizacije repoa i kopija.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: uređuje pravila pisanja i gateove za `.md` dokumente.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_RIZIK_I_KOLIZIJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski standard razrješenja rizika i kolizija.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_NORMA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: glavni standard NORMA JSON zapisa.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_POSTUPAK.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: glavni standard POSTUPAK JSON zapisa.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski intake standard za prekršajne tokove.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard audita primjene norme na činjenice.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: deterministički audit standard za P6.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard subsumpcije i povezivanja činjenica s normom.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_HIJERARHIJA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard hijerarhije izvora i prioritetnih pravila.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_PREDLOZAK.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard predložaka i mapiranja izvora u nacrt.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski JSON model jedne rječničke natuknice.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: kanonski terminološki JSON zapis i sljedivost izvora.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_FER_NAPLATA_PREKRSAJI.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: aktivni standard fer naplate u prekršajnom modulu.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira obvezne markere izlaznog nacrta v1.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_`
  `TERMINA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard izdvajanja hrvatski relevantnih termina.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard tehničkog mapiranja EU termina na NN pojmove.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: vodi prioritetni radni uzorak za NN sidrenje.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard čišćenja uzorka prije ručnog NN pregleda.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard kandidatskih podnatuknica za NN sidrenje.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard izdvajanja pilot-skupa natuknica.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: definira jezgreni skup natuknica za prvo sidrenje.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_`
  `SIDRENJE.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: proširuje jezgru na osnovni postupovni skup.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard prvog NN sidrenja rječničkih natuknica.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard ručne validacije kandidata prije upisa.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard ručne validacije i upisa NN sidara.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard granske konsolidacije podnatuknica.
  - preporuka: `OSTAVITI`

- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
  - kategorija: `AKTIVNI_KANONSKI_DOKUMENT`
  - obrazloženje: standard za potpuno validiranu natuknicu.
  - preporuka: `OSTAVITI`

### C2) `AKTIVNI_RADNI_TRAG`

- `dokumentacija/PREOSTALI_MARKDOWN_BACKLOG_NAKON_SELECTION_`
  `REPORT_SANACIJE.md`
  - kategorija: `AKTIVNI_RADNI_TRAG`
  - obrazloženje: svježi dokaz da je markdown backlog sveden na nulu.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

- `dokumentacija/PROCJENA_SKUPINE_ZASTARJELI_NEAKTIVNI_`
  `DOKUMENTI.md`
  - kategorija: `AKTIVNI_RADNI_TRAG`
  - obrazloženje: još uvijek služi kao dokazna podloga za budući cleanup.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

### C3) `ARHIVSKI_POVIJESNI_TRAG`

- `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_`
  `ZAKONI_S_AMANDMANIMA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: MAPA ga opisuje kao privremeni radni i neoperativni trag.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

- `dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: vrijedi kao audit objašnjenje specifičnog skoka u nizu.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_`
  `AMANDMANIMA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: MAPA ga već označava kao arhivski i neoperativni trag.
  - preporuka: `ARHIVSKI_PREOZNACITI`

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: korisna je kao podloga, ali glavni kanon je već izdvojen.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

- `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_`
  `S_AMANDMANIMA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: završni odgovor na već zatvoreno analitičko pitanje.
  - preporuka: `OSTAVITI_KAO_DOKAZNI_TRAG`

- `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: dokumentira stari backlog koji je kasnije zatvoren.
  - preporuka: `ARHIVSKI_PREOZNACITI`

- `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
  - kategorija: `ARHIVSKI_POVIJESNI_TRAG`
  - obrazloženje: starija read-only revizija, sada djelomično supersedana.
  - preporuka: `ARHIVSKI_PREOZNACITI`

### C4) `ZASTARJELI_NEAKTIVNI_DOKUMENT`

- `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
  - kategorija: `ZASTARJELI_NEAKTIVNI_DOKUMENT`
  - obrazloženje: snapshot iz 22.02.2026. više nije aktualni vodič repoa.
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

### C5) `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_`
  `Z138_DO_Z142.md`
  - kategorija: `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`
  - obrazloženje: proceduralni meta-prijedlog za već zatvoren niz koraka.
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_`
  `Z138_DO_Z142.md`
  - kategorija: `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`
  - obrazloženje: uski pripremni dokument za budući removal korak.
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
  - kategorija: `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`
  - obrazloženje: privremena procjena jednog zatvorenog servisnog niza.
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

### C6) Sažetak raspodjele

- `AKTIVNI_KANONSKI_DOKUMENT`: `45`
- `AKTIVNI_RADNI_TRAG`: `2`
- `ARHIVSKI_POVIJESNI_TRAG`: `7`
- `ZASTARJELI_NEAKTIVNI_DOKUMENT`: `1`
- `KANDIDAT_ZA_UKLANJANJE_IZ_KANONSKOG_SLOJA`: `3`

Ukupno: `58`

---

## D) Dokumenti koji stvaraju šum ili maglu

Ovi dokumenti stvaraju najviše meta-sloja, duplikacije ili zastarjelog
konteksta:

- `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
  - zašto stvara šum: zamrzava staro stanje repoa kao da je i dalje aktivno
  - što ga pokriva: `STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md`
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
  - zašto stvara šum: opisuje prolazni servisni niz koji je zatvoren
  - što ga pokriva: git povijest i kasniji revizijski dokumenti
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_`
  `Z138_DO_Z142.md`
  - zašto stvara šum: meta-prijedlog o uklanjanju, ne nosi trajni kanon
  - što ga pokriva: ova revizija i budući uski cleanup korak
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_`
  `Z138_DO_Z142.md`
  - zašto stvara šum: proceduralna priprema već pripremljenog posla
  - što ga pokriva: ova revizija i sam budući scoped cleanup
  - preporuka: `UKLONITI_IZ_KANONSKOG_SLOJA`

- `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
  - zašto stvara šum: govori o backlogu koji je sada zatvoren na nulu
  - što ga pokriva: `PREOSTALI_MARKDOWN_BACKLOG_...` i zadnji commitovi
  - preporuka: `ARHIVSKI_PREOZNACITI`

- `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
  - zašto stvara šum: starija revizija sada se preklapa s ovim izvještajem
  - što ga pokriva: ovaj novi dokument
  - preporuka: `ARHIVSKI_PREOZNACITI`

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_`
  `AMANDMANIMA.md`
  - zašto stvara šum: sama MAPA ga opisuje kao arhivski neoperativni trag
  - što ga pokriva: `KANONSKI_OBRAZAC_...` i kasnije analize/odgovori
  - preporuka: `ARHIVSKI_PREOZNACITI`

---

## E) Minimalni prijedlog čišćenja

Čišćenje dokumentacije treba raditi bez kaosa i u tri mala sloja:

1. Zadržati kao kanon:
   - `METODOLOGIJA`, `MAPA`, `STATUS`, `DNEVNIK`
   - `TEHNIČKI_OKVIR`, `RJEČNIK`, razvojne planove, sve `STANDARD_*`
   - aktivne `REZIM_KONVERZIJE_*` dokumente i ključne završne izvještaje

2. Zadržati samo kao povijesni dokazni sloj:
   - `ANALIZA_*`, `INVENTURA_*`, `ODGOVOR_*`
   - `POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
   - `PREOSTALI_MARKDOWN_BACKLOG_NAKON_SELECTION_REPORT_SANACIJE.md`
   - `REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`

3. Kasnije ukloniti iz aktivnog kanonskog sloja:
   - `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
   - `PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
   - `PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
   - `PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`

Preporučeni redoslijed rada:

1. prvo ažurirati kanonsku mapu dokumentacije tako da jasno razlikuje
   aktivni kanon od povijesnih dokaznih tragova
2. tek nakon toga raditi uski scoped korak za izdvajanje 3-4 najšumnija
   dokumenta iz aktivnog sloja
3. povijesne dokaze ne brisati bez zasebnog naloga i bez evidencijskog
   traga u dokumentaciji

---

## F) Jedan sljedeći smisleni zadatak

Sljedeći uski i provediv zadatak u jednom commit koraku treba biti:

**Ažurirati `MAPA_DOKUMENTACIJE_VERITAS_H77.md` i
`STATUS_PROJEKTA_VERITAS_H77.md` tako da uvedu jasnu razliku između
`AKTIVNI_KANONSKI_DOKUMENTI` i `POVIJESNI_DOKAZNI_TRAGOVI`, uz posebno
preoznačavanje 4 najšumnija dokumenta bez brisanja i bez diranja drugih
slojeva.**

Zašto baš to:

- uzak je i može stati u jedan scoped commit
- smanjuje maglu bez brisanja sadržaja
- prvo sređuje navigaciju i dokumentacijski kanon, pa tek onda otvara
  eventualni kasniji cleanup fizičkih datoteka
- uključuje obvezno ažuriranje dokumentacije, kako je traženo
