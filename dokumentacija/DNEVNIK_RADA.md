# DNEVNIK_RADA

## Pravilo evidentiranja
Svaki novi značajan korak rada evidentira se kao novi dnevnički unos.
Unosi idu kronološki: najstariji na vrhu, najnoviji na dnu.

---

## Datum: 16.02.2026

### Sažetak
Napravljen je inicijalni setup repozitorija i postavljeni su temeljni kanonski
artefakti projekta. Uvedeni su tehnički standardi, osnovna struktura i ključni
kanonski dokumenti za metodologiju, normu, postupak i razvojni plan.

### Commitovi (najstariji -> najnoviji)
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

### Napomena
Standard JSON NORMA je u povijesti uveden kroz dvije uzastopne revizije
(dva odvojena commita). Obje revizije su kanonske u smislu traga, a važeći
sadržaj je onaj iz zadnje verzije datoteke u grani `main`.

### Status
Repozitorij čist: da (`git status --short` bez izlaza).
