# DNEVNIK_RADA

## Pravilo evidentiranja
Svaki novi značajan korak rada evidentira se kao novi dnevnički unos.
Unosi idu kronološki: najstariji na vrhu, najnoviji na dnu.

---

## Datum: 16.02.2026

### Sažetak (17.02.2026.)
Napravljen je inicijalni setup repozitorija i postavljeni su temeljni kanonski
artefakti projekta. Uvedeni su tehnički standardi, osnovna struktura i ključni
kanonski dokumenti za metodologiju, normu, postupak i razvojni plan.

### Commitovi (najstariji -> najnoviji) (17.02.2026.)
- 39a19c8 -> chore: inicijalizacija repozitorija
- 275aa3b -> chore: normalizacija završetaka redaka
- 7b3b1f2 -> chore: dodana osnovna struktura mapa
- f4033dc -> chore: docker kostur (mount repozitorija)
- 24e9959 -> chore: markdownlint pravila + editorconfig
- 0ea5b66 -> chore: eol pravila (LF kanon, CRLF samo ps1)
- dafaa25 -> docs: metodologija rada Veritas H.77
- cd613a1 -> docs: standard JSON NORMA (revizija 1)
- 27dcda5 -> docs: standard JSON NORMA (revizija 2)
- 502501c -> docs: standard JSON POSTUPAK (procedura)
- 0681c60 -> docs: razvojni plan Veritas H.77 (kanonski)

### Napomena (17.02.2026.)
Standard JSON NORMA je u povijesti uveden kroz dvije uzastopne revizije
(dva odvojena commita). Obje revizije su kanonske u smislu traga, a važeći
sadržaj je onaj iz zadnje verzije datoteke u grani `main`.

### Status
Repozitorij čist: da (`git status --short` bez izlaza).

---

## Datum: 17.02.2026

### Sažetak
Dopunjena je metodologija s rječnikom i gate pravilima statusa izlaza.
Dodan je zaseban rječnik pojmova, tehnički okvir i mapa dokumentacije.

### Commitovi (najstariji -> najnoviji)
- 1409d45 -> docs: metodologija (rječnik + gate pravila)
- 939d29b -> docs: rječnik pojmova Veritas H.77
- 6d724c2 -> docs: tehnički okvir Veritas H.77
- 978caee -> docs: mapa dokumentacije Veritas H.77

### Napomena
Za datum 17.02.2026. u povijesti repozitorija postoje ova četiri commita.

---

## Datum: 17.02.2026.

### Sažetak
Uveden je primarni ingest iz Narodnih novina za sve akte.
Uvedena je kontrola izvora sa statusima OK/NEDOSTAJE/HASH_NEDOSTAJE/
NEVALJAN_IZVOR.
Uvedeno je parsiranje NN HTML izvora u strukturu (`struktura_nn.json`) uz
izvještaj parsiranja.

### Napomena
zakon.hr je opcionalna kontrola i usporedba, ali nije dokazni temelj.

### Commitovi (najstariji -> najnoviji)
- 1409d45 -> docs: metodologija (rječnik + gate pravila)
- 939d29b -> docs: rječnik pojmova Veritas H.77
- 6d724c2 -> docs: tehnički okvir Veritas H.77
- 978caee -> docs: mapa dokumentacije Veritas H.77
- 94f5609 -> docs: dnevnik rada (unos 17.02.2026.)
- 2f8ecb2 -> docs: razvojni plan (validacija ranije + pilot + gate)
- f724285 -> chore: baza_zakona struktura (NORMA JSON)
- c066382 -> feat: pilot NORMA JSON (Ustav RH čl. 1) + NN sidro
- ca56955 -> feat: NORMA v1 schema + validacija
- d554f33 -> docs: standard rizik i kolizije
- b858a54 -> feat: pilot NORMA JSON (Ustav RH čl. 2-3) + dopuna sidra
- 964063b -> feat: pilot NORMA JSON (Ustav RH čl. 1-3) kanonski
- 540ade6 -> feat: operativni izvor (zakon.hr) ustav RH
- bb21e6e -> feat: parsiranje izvora (zakon.hr) ustav RH u strukturu
- 99beeb6 -> feat: normiranje (NORMA JSON) ustav RH iz strukture
- 1d1d771 -> feat: validacija NORMA JSON (ustav RH) - gate provjera
- 7e97759 -> fix: uskladena provjera hash polja u validaciji norme
- 1ccc527 -> feat: izvještaj rupa teksta (ustav RH) - za dopunu iz NN
- c3b6d46 -> feat: rupe teksta (ustav RH) - nedostajuci + placeholder +
	prazno
- 3a5a0af -> feat: primarni ingest izvor = Narodne novine (opći okvir +
	kontrola arhive)
- af79517 -> fix: kontrola NN izvora (nevaljan URL + validacija meta)
- 38d490b -> feat: parsiranje NN (HTML) u strukturu (generički)

---

## Datum: 18.02.2026.

### Sažetak
Implementiran je Normiratelj iz NN strukture u NORMA JSON.
Pokrenut je pilot za `ustav_rh` preko PS runnera iz repo roota.
Generirani su članci `clanak_XXXX.json` i `IZVJESTAJ_NORMIRANJA.md`.

### Napomena
Ulaz je `struktura_nn.json` uz `meta.json` iz NN arhive kao dokazni izvor.
