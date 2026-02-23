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

Kanonska formula G1 roka (v1):

- trigger datum (`g1.start_date`) je `intake.meta.datum_izrade`
- rok je `8` kalendarskih dana
- `g1.due_date = g1.start_date + 8 dana`
- referentni datum za usporedbu:
  - prvo `audit_v1.meta.datum_izrade` (ako postoji i parsira se)
  - ako ne postoji, koristi se sistemski datum i status je
    `INDETERMINATE` (uz napomenu u `g1.note`)

Statusi G1 u `audit_generated_v1.json`:

- `OK`: rok je izračunljiv i referentni datum nije nakon `g1.due_date`
- `LATE`: rok je izračunljiv i referentni datum je nakon `g1.due_date`
- `MISSING`: nedostaje trigger datum pa rok nije izračunljiv
- `INDETERMINATE`: trigger postoji, ali referentni datum iz predmeta/audita
  nedostaje pa je korišten sistemski datum

Kanonski fixtures acceptance mora sadržavati barem jedan scenarij koji
deterministički proizvodi `g1.status=INDETERMINATE` i `preflight=ZUTO`
(bez blockera), uz očekivani `NAP-G1-INDETERMINATE` warning.

Mapiranje warning nalaza:

- `MISSING` -> `NAP-G1-MISSING`
- `LATE` -> `NAP-G1-LATE`
- `INDETERMINATE` -> `NAP-G1-INDETERMINATE`
- `OK` -> bez G1 warning nalaza

U izlazu je opcionalan `g1` blok sa strukturom:

- `status`, `start_date`, `due_date`, `days`, `note`

G1 warning i dalje postavlja samo ŽUTO kada nema blockera.

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

- `id` (kanonski scenario_id)
- opcionalni `naziv`
- `tok`
- ulaze: `intake`, `subsumcija`, opcionalni `audit_v1`
- `expected.preflight` (`CRVENO|ZUTO|ZELENO`)
- opcionalni `expected.g1.status`
- preferirano:
  - `expected.nap.must_include[]`
  - `expected.nap.must_not_include[]`
- legacy (podržano, ali deprecirano):
  - `expected.required_nap[]`
  - `expected.forbidden_nap[]`

Kanonska naming konvencija scenarija:

- `SCN_<SEMAFOR>_<DOMENA>_<TOK?>_<ID>`

Primjeri:

- `SCN_ZUT_G1_INDET_11`
- `SCN_CRV_G2_CONTRAD_07`

Fixtures runner mora za svaki scenarij provjeriti:

- podudarnost semafora (`NAP-SEM` → `preflight=`)
- podudarnost `g1.status` kada je definiran u expected
- prisutnost svih kodova iz `expected.nap.must_include[]`
- odsutnost svih kodova iz `expected.nap.must_not_include[]`

Ako scenarij koristi legacy expected polja (`required_nap/forbidden_nap`),
runner ih i dalje mora prihvatiti radi kompatibilnosti v1.

### 10.1 Matrica pokrivenosti fixturesa (v1)

Matrica je kanonski pregled pokrivenosti po toku i G1 statusu.
U ćeliji je naveden scenario_id i semafor.

| Tok | OK | MISSING | LATE | INDETERMINATE | — |
| --- | --- | --- | --- | --- | --- |
| TOK_PN_PRIGOVOR | 17/ZEL | - | 13/ZUT | 11/ZUT | 01/ZEL,05/ZUT,09/CRV |
| TOK_PRESUDA_ZALBA | 18/ZEL | 16/ZUT | 21/ZUT | - | 02/ZEL,06/ZUT,12/CRV |
| TOK_RJESENJE_ZALBA | 19/ZEL | 14/ZUT | 20/ZUT | - | 03/ZEL,10/ZUT,07/CRV |
| TOK_OBUSTAVA | - | 15/ZUT | - | - | 04/ZUT,08/CRV |

### 10.2 Praznine matrice (trenutno stanje)

Prazne ćelije po toku i G1 statusu:

- TOK_PN_PRIGOVOR: `MISSING`
- TOK_PRESUDA_ZALBA: `INDETERMINATE`
- TOK_RJESENJE_ZALBA: `INDETERMINATE`
- TOK_OBUSTAVA: `OK`, `LATE`, `INDETERMINATE`

Praznine u stupcu `—` (G1 nije predmet očekivanja):

- nema praznina za CRVENO/blocker coverage po tokovima.

### 10.3 Kanonski prioritet popune (rizik)

Rangiranje vrijedi za sljedeću iteraciju fixturesa:

1) R1 (top): CRVENO/blocker coverage po svakom toku.
2) R2 (visoko): `G1_STATUS=LATE` za prigovor i žalbu.
3) R3 (srednje-visoko): `G1_STATUS=MISSING` po tokovima.
4) R4 (srednje): `G1_STATUS=OK` sanitarni scenariji po tokovima.
5) R5 (niže): dodatni `INDETERMINATE` po drugim tokovima.

### 10.4 Plan popune matrice (roadmap)

Sljedeći fixturesi (bez implementacije u ovom zadatku):

1) `SCN_CRV_G2_CONTRAD_PRESUDA_12`: TOK_PRESUDA_ZALBA,
   preflight `CRVENO`, G1 `—`, obavezno `NAP-RED-BLOCKER` i `NAP-SEM`.
2) `SCN_ZUT_G1_LATE_PRIGOVOR_13`: TOK_PN_PRIGOVOR,
   preflight `ZUTO`, G1 `LATE`, obavezno `NAP-G1-LATE`, `NAP-YEL-WARNING`.
3) `SCN_ZUT_G1_MISSING_PRESUDA_14`: TOK_PRESUDA_ZALBA,
   preflight `ZUTO`, G1 `MISSING`, obavezno `NAP-G1-MISSING`.
4) `SCN_ZUT_G1_MISSING_RJESENJE_15`: TOK_RJESENJE_ZALBA,
   preflight `ZUTO`, G1 `MISSING`, obavezno `NAP-G1-MISSING`.
5) `SCN_ZUT_G1_MISSING_OBUSTAVA_16`: TOK_OBUSTAVA,
   preflight `ZUTO`, G1 `MISSING`, obavezno `NAP-G1-MISSING`.
6) `SCN_ZEL_G1_OK_PRIGOVOR_17`: TOK_PN_PRIGOVOR,
   preflight `ZELENO`, G1 `OK`, bez `NAP-G1-*` warning kodova.
7) `SCN_ZEL_G1_OK_PRESUDA_18`: TOK_PRESUDA_ZALBA,
   preflight `ZELENO`, G1 `OK`, bez `NAP-G1-*` warning kodova.
8) `SCN_ZEL_G1_OK_RJESENJE_19`: TOK_RJESENJE_ZALBA,
   preflight `ZELENO`, G1 `OK`, bez `NAP-G1-*` warning kodova.
9) `SCN_ZEL_G1_OK_OBUSTAVA_20`: TOK_OBUSTAVA,
   preflight `ZELENO`, G1 `OK`, bez `NAP-G1-*` warning kodova.

Ako ijedan scenarij odstupa, acceptance pada (hard fail).
