# STANDARD — IZLAZNI NACRT PREKRŠAJI (v1)

Datum: 22.02.2026.  
Oznaka: STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1  
Status: KANON (obavezno za sve izlazne nacrte koje generira runner)

## 1. Svrha

Ovaj standard definira minimalne obavezne markere koje mora sadržavati svaki
izlazni nacrt (.txt) generiran u prekršajnom modulu. Standard ne definira
pravnu argumentaciju, već determinističku strukturu i dokazivost.

## 2. Obavezni markeri (minimalni)

Izlazni nacrt mora sadržavati sljedeće tekstualne markere (case sensitive):

1) `NACRT - bez potpisa`
2) `TOK=` (linija koja sadrži oznaku toka)
3) `PREDMET_ID=` (linija koja sadrži identifikator predmeta)
4) `DATUM=` (linija koja sadrži datum izrade nacrta, format DD.MM.YYYY.)
5) `AUDIT_NALAZI_BEGIN` i `AUDIT_NALAZI_END` (blok audita)
6) `INTAKE_BEGIN` i `INTAKE_END` (blok intake podataka)

## 3. Minimalna struktura (preporučeni raspored)

Minimalni raspored je:

- naslovna linija: `NACRT - bez potpisa`
- meta blok s `TOK=`, `PREDMET_ID=`, `DATUM=`
- audit blok:
  - `AUDIT_NALAZI_BEGIN`
  - lista nalaza (npr. `KOD: OPIS`)
  - `AUDIT_NALAZI_END`
- intake blok:
  - `INTAKE_BEGIN`
  - `CILJ=...`
  - `OSPORAVANJA=...`
  - `OPIS_DOGADAJA=...`
  - `INTAKE_END`

## 4. Pravilo validacije

Validator izlaza mora provjeriti prisutnost svih markera iz točke 2.
Ako bilo koji marker nedostaje, izlaz se smatra nevaljanim.
