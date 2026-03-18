# STATUS_PROJEKTA_VERITAS_H77

Datum: 18.03.2026.

## Snapshot repozitorija

- Trenutni commit: `e0e5b9f` - EU: očišćen prioritetni uzorak za NN sidrenje
- Repo čist: DA (pre-check `git status --short` bez izlaza)
- Zadnji dovršeni terminološki zadatak: ZADATAK 60
  (kanonski model rječničke natuknice i početni operativni skup)
- Sljedeći zadatak po redu: ručno NN sidrenje natuknica
  (sidra, članci, stavci i točke)

## Aktivni gateovi

- `alati/ci_smoke.ps1`
- `alati/lint_markdown.ps1`
- `alati/test_fixtures_audit_prekrsaji_v1.ps1`

## Ključni standardi na snazi

- `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`
- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/STANDARD_JSON_POSTUPAK.md`
- `dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md`
- `dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md`
- `dokumentacija/STANDARD_JSON_HIJERARHIJA.md`
- `dokumentacija/STANDARD_JSON_PREDLOZAK.md`
- `dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
- `dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
- `dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
- `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`

## Faza po planovima i standardima

### RAZVOJNI_PLAN_VERITAS_H77.md

- Definira globalne faze 0-9 i gate logiku za cijeli sustav.
- Trenutni modul rada pripada prekršajnoj pilot domeni unutar tog okvira.
- CI i validacijski gateovi su obavezni za prolaz između faza.

### RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md

- P2 je dovršen za sva 4 toka (`TOK_PN_PRIGOVOR`,
  `TOK_PRESUDA_ZALBA`, `TOK_RJESENJE_ZALBA`, `TOK_OBUSTAVA`).
- P6 acceptance i fixture matrica su dovedeni do pokrivenosti kroz ZAD 50.
- Sljedeće po redu je P7 (E2E veza audit -> nacrt -> manifest).

### MAPA_DOKUMENTACIJE_VERITAS_H77.md

- Definira kanonske dokumente i redoslijed čitanja.
- Potvrđuje da su planovi i standardi prekršajnog modula aktivni.
- Upućuje na obavezne validatore i `ci_smoke` kao operativne gateove.

### DNEVNIK_RADA.md (zadnji pregledani blok)

- U završnom bloku su unosi za terminološke korake 52-60.
- Dnevnik sadrži dokazne naredbe po zadacima i commit tragu.
- Kronologija unosa je dokumentirana uz commit listu kao dokaz reda.
