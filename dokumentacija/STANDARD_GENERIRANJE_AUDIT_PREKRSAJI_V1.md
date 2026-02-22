# STANDARD — GENERIRANJE AUDIT (PREKRŠAJI) v1

Datum: 22.02.2026.  
Oznaka: STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1  
Status: KANON (obavezno za P6)

## 1. Svrha

Ovaj standard definira determinističko generiranje audita za prekršajni modul.
Generator ne procjenjuje "ishod", nego proizvodi strukturirani audit trag
za gateove i naplatu.

Generator u v1 ne prepisuje postojeći `audit_v1.json`. Umjesto toga generira
novi artefakt `audit_generated_v1.json`.

## 2. Ulazi (obavezno)

Generator čita sljedeće ulaze:

1) `intake_v1.json` (Gate 2 ulaz)
2) `subsumcija_v1.json` (elementi bića / provjere)
3) `postupak.json` (tok + meta)
4) postojeći `audit_v1.json` (ako postoji; služi kao kontekst i provjera
   postojeće kolizije; generator ga ne mijenja)

Ako neki obavezni ulaz nedostaje, generator mora STOP-ati (vidi točku 7).

## 3. Izlaz (obavezno)

Generator zapisuje:

- `predmeti/.../audit/audit_generated_v1.json`

Datoteka sadrži `meta`, `gate_stanje` i `nalazi[]` u formatu kompatibilnom s
`SCHEMA_AUDIT_V1.json`.

`audit_generated_v1.json` je runtime-artefakt, ali mora biti deterministički
i validabilan.

## 4. Deterministički datum i identitet

`meta.datum_izrade` mora biti deterministički:
- koristi lokalni datum generiranja u formatu `DD.MM.YYYY.`

`meta.id_predmeta` i `meta.tok` se preuzimaju iz `postupak.json` i/ili putanje
predmeta, bez heuristike.

## 5. Minimalni obavezni nalazi (nalazi[])

Generator mora uvijek emitirati minimalno sljedeće nalaze:

- `NAP-G1` (proceduralna dopuštenost) — u v1 može biti `PASS` ako je tok već
  definiran i `gate_stanje.blocked=false`, inače `FAIL`.
- `NAP-G2` (činjenični prag) — temelji se na `intake`:
  - ako `kontradikcije.ima_kontradikcija=true` → `FAIL`
  - ako je `osporavanja[]` prazno → `FAIL`
  - ako je `cilj` prazan ili nije u enumu → `FAIL`
  - inače `PASS`
- `NAP-G3` (dokaz/strategija/proceduralna greška) — u v1:
  - `PASS` ako `subsumcija` ima barem jedan element s rezultatom `PROLAZ`
    ili postoji `KOL-01` u postojećem auditu
  - inače `FAIL`
- `NAP-SEM` (semafor) — `preflight=ZELENO|ZUTO|CRVENO`:
  - CRVENO ako je bilo koji od G1/G2/G3 FAIL
  - ZELENO ako su G1/G2/G3 PASS i rizik je nizak
  - ŽUTO ako su G1/G2/G3 PASS, ali postoji rizik (npr. oslonac samo na
    subsumpciju bez dokaza ili postoje kolizije)
- `NAP-ODL` (odluka naplate) — `naplata=DOPUSTENO|ZABRANJENO`:
  - ZABRANJENO ako je `preflight=CRVENO`
  - DOPUSTENO ako je `preflight=ZELENO`
  - DOPUSTENO ako je `preflight=ZUTO` uz obaveznu napomenu da je potreban
    "Risk Disclosure" u izlazu

Svaki nalaz mora imati: `kod`, `opis`, `tezina`, `posljedica`, `norma_ref`
(ako nije primjenjivo u v1, `norma_ref` je prazan string).

## 6. Gate stanje (gate_stanje)

Generator mora postaviti:

- `gate_stanje.blocked`:
  - `true` ako je `preflight=CRVENO`
  - `false` inače
- `gate_stanje.blocked_razlog`:
  - prazan string ako nije blocked
  - kratki razlog ako jest blocked (npr. `preflight=CRVENO`)

## 7. Hard-fail (STOP uvjeti)

Generator mora STOP-ati (exit != 0 u alatu) u sljedećim slučajevima:

- nedostaje `intake_v1.json`
- nedostaje `subsumcija_v1.json`
- nedostaje `postupak.json`
- `intake_v1.json` nije validan JSON ili ne prolazi `SCHEMA_INTAKE...`
- `subsumcija_v1.json` nije validan JSON ili ne prolazi `SCHEMA_SUBSUMPCIJA...`
- izlaz se ne može zapisati na predviđenu putanju

## 8. Neizmjenjivost ulaza i reproducibilnost

Generator ne smije mijenjati ulazne datoteke.
Za isti skup ulaza mora proizvoditi isti audit izlaz, osim `datum_izrade`
(koji je deterministički po danu).

## 9. Testni kriteriji (DoD)

Standard je ispunjen kada:
- postoji ovaj dokument u `dokumentacija/`
- dokument je u MAPA_DOKUMENTACIJE (u zasebnom zadatku, ne ovdje)
- implementacija (kasniji zadatak) može proizvesti `audit_generated_v1.json`
  koji prolazi `SCHEMA_AUDIT_V1.json`
