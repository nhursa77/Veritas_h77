# STANDARD — IZLAZNI NACRT PREKRŠAJI (v1)

Datum: 22.02.2026.  
Oznaka: STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1  
Status: KANON (obavezno za sve izlazne nacrte koje generira runner)

## 1. Svrha

Ovaj standard definira minimalne obavezne markere koje mora sadržavati svaki
izlazni nacrt (.txt) generiran u prekršajnom modulu. Standard ne definira
pravnu argumentaciju, već determinističku strukturu i dokazivost.

## 2. Obavezni markeri

Izlazni nacrt mora sadržavati sljedeće tekstualne markere (case sensitive):

1) `NACRT - bez potpisa`
2) `Vrijedi tek nakon potpisa nositelja.`
3) `TOK=` (linija koja sadrži oznaku toka)
4) `PREDMET_ID=` (linija koja sadrži identifikator predmeta)
5) `DATUM=` (linija koja sadrži datum izrade nacrta, format DD.MM.YYYY.)
6) `PREDLOZAK_ID=` i `PREDLOZAK_REF=`
7) `AUDIT_REF=` (mora završavati s `audit_generated_v1.json`)
8) `PREDMET_REF=`
9) `NN_SIDRA_BEGIN` i `NN_SIDRA_END`
10) `PREDLOZAK_POLJA_BEGIN` i `PREDLOZAK_POLJA_END`
11) `AUDIT_NALAZI_BEGIN` i `AUDIT_NALAZI_END`
12) `INTAKE_BEGIN` i `INTAKE_END`

## 3. Minimalna struktura (preporučeni raspored)

Minimalni raspored je:

- naslovna linija: `NACRT - bez potpisa`
- oznaka da nacrt vrijedi tek nakon potpisa nositelja
- meta blok s tokom, predmetom, datumom i predloškom
- dokazni blok s referencama na predmet, audit i puna NN sidra
- blok mapiranih polja predloška
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

Svaka sekcija predloška mora imati `SEKCIJA_BEGIN=<id>` i
`SEKCIJA_END=<id>`. Svako polje mora imati:

- `POLJE_BEGIN=<id>`
- `LABEL=<label>`
- `IZVOR=<referenca>`
- `VRIJEDNOST=<vrijednost>` ili strukturirani audit blok
- `POLJE_END=<id>`

Ti markeri nisu pravna argumentacija. Oni su dokaz da vrijednost nije
slobodno dopisana, nego je preuzeta iz deklariranog izvora predloška.

## 4. Pravilo validacije

Validator izlaza mora provjeriti:

- prisutnost svih markera iz točke 2
- uravnotežen broj početnih i završnih markera sekcija i polja
- dokaz izvora i vrijednosti za svako polje
- obavezne izvore predmeta, audita i intakea
- da `AUDIT_REF` pokazuje na generirani audit
- da nema nerazriješene oznake `{PREDMET_ID}`
- da postoji barem jedno navedeno NN sidro
- da nema znakova tipičnih za oštećen UTF-8 tekst

Ako bilo koji uvjet nije zadovoljen, izlaz se smatra nevaljanim.

## 5. Tvrde blokade P7

Runner ne smije proizvesti novu izlaznu datoteku ako vrijedi bilo što od
sljedećeg:

- `audit.gate_stanje.blocked=true`
- auditni semafor je `CRVENO`
- identitet toka, verzije ili predmeta nije usklađen
- obavezno mapirano polje nedostaje ili je prazno
- predložak nema potpuno i jednoznačno mapiranje
- audit ne prenosi sva NORMA sidra koja postupak zahtijeva
- referencirani NORMA zapis nema `izvori.status_sidra=puno`

Blokirani rezultat mora vratiti `RUNNER_RESULT=STOP` i dokazni
`STOP_REASON`, bez stvaranja nacrta. Ako na ciljnoj putanji postoji nacrt iz
ranijeg prolaza, runner ga mora ukloniti prije provjere trenutačnih ulaza kako
zastarjeli izlaz ne bi preživio blokadu.
