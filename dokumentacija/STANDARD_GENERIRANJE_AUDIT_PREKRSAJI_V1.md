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

- `NAP-G1` (proceduralna dopuštenost; soft u v1)
- `NAP-G2` (činjenični prag)
- `NAP-G3` (dokaz/strategija/proceduralna greška)
- `NAP-SEM` (semafor)
- `NAP-ODL` (odluka naplate)

Uz navedene obavezne nalaze, generator koristi NAP-MIN klase za
determinističko mapiranje semafora:

- blocker klasa: `NAP-RED-BLOCKER`
- warning klasa: `NAP-YEL-WARNING`
- ok klasa: `NAP-GRN-OK`

Pravila G2 i G3:

- `NAP-G2` je `FAIL` ako je `kontradikcije.ima_kontradikcija=true`, ako je
  `osporavanja[]` prazno/ne postoji, ili ako je `cilj` prazan/ne postoji;
  inače je `PASS`.
- `NAP-G3` je `PASS` ako `subsumcija` sadrži barem jedan element s
  `rezultat="PROLAZ"` ili ako postoji `KOL-01` u postojećem `audit_v1.json`;
  inače je `FAIL`.

Pravila G1 (soft u v1):

- G1 u v1 nikad ne postavlja blocker i nikad samostalno ne daje CRVENO.
- ako nema dovoljno datuma za izračun roka, emitira se
  `NAP-G1-MISSING` (warning)
- ako je rok očito propušten prema dostupnim datumima, emitira se
  `NAP-G1-LATE` (warning)
- ako je rok uredan, G1 ostaje bez warning nalaza.

Svaki nalaz mora imati: `kod`, `opis`, `tezina`, `posljedica`, `norma_ref`
(ako nije primjenjivo u v1, `norma_ref` je prazan string).

## 6. Semafor i gate_stanje

Semafor je deterministički i računa se ovim redom:

1) `CRVENO` ako postoji barem jedan blocker (`NAP-RED-BLOCKER`)
2) `ŽUTO` ako nema blockera i postoji barem jedan warning
   (`NAP-YEL-WARNING`, `NAP-G1-MISSING`, `NAP-G1-LATE`)
3) `ZELENO` ako nema ni blockera ni warning nalaza

Generator mora postaviti:

- `gate_stanje.blocked`:
  - `true` ako je `preflight=CRVENO`
  - `false` ako je `preflight=ZUTO` ili `preflight=ZELENO`
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

## 10. Fixtures acceptance (kanonski)

Za acceptance P6 obavezni su fixtures scenariji u putanji:

- `predmeti/_fixtures/prekrsajni/audit_v1/**/scenario.json`

Svaki scenarij mora sadržavati:

- `intake` ulaz
- `subsumcija` ulaz
- opcionalni `audit_v1` ulaz
- `expected.preflight` (`CRVENO|ZUTO|ZELENO`)
- `expected.required_nap[]`
- `expected.forbidden_nap[]`

Fixtures runner mora za svaki scenarij provjeriti:

- podudarnost semafora (`NAP-SEM` → `preflight=`)
- prisutnost svih `required_nap` kodova
- odsutnost svih `forbidden_nap` kodova

Ako ijedan scenarij odstupa, acceptance pada (hard fail).
