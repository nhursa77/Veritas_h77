# Veritas H.77

Veritas H.77 je ustavno-pravni digitalni sustav za obranu prava pojedinca kroz
strogo strukturiranu obradu činjenica, normi i postupaka.

Sustav omogućuje:

- determinističku obradu zakonskih tekstova
- dokazivo povezivanje normi sa službenim izvorima (Narodne novine)
- kontrolu integriteta svakog članka
- praćenje izmjena i verzija
- izradu pravno urednih i provjerljivih dokumenata

Veritas nije alat za prepisivanje zakona, nego sustav za:

- normativnu preciznost
- forenzičku provjerljivost
- proceduralnu dosljednost
- obrambeno djelovanje u korist pojedinca

---

## Temeljna načela

1. Hijerarhija normi: prirodno pravo → međunarodni akti → ustav → zakoni →
  podzakonski akti.
2. Službeni izvor ima prednost nad agregiranim tekstom.
3. Svaka norma mora imati dokazno sidro.
4. Svaka obrada mora biti ponovljiva i provjerljiva.
5. Sustav djeluje obrambeno i proporcionalno.

---

## Pravilo izvora

- Pročišćeni tekst zakona koristi se kao radna osnova.
- Službena objava u Narodnim novinama predstavlja dokazni izvor.
- U slučaju razlike, prednost ima službeni tekst objavljen u Narodnim
  novinama.  
- Svaki citirani članak mora sadržavati oznaku članka, stavka i podatke o
  objavi.

ELI (European Legislation Identifier) je standardizirani identifikator i URL
shema za službene propise, pa se ELI PDF koristi kao fallback kada NN HTML
nije dostupan ili nema parsabilan sadržaj.

---

## Struktura projekta

- `dokumentacija/` – normativna pravila sustava  
- `baza_zakona/` – strukturirani zapisi zakona  
- `izvori/` – dokazni i kontrolni izvori (NN/zakon.hr)
- `alati/` – ingest, parser, normiratelj, preflight i acceptance skripte
- `paketi/` – manifesti paketnih ingest scenarija
- `predlosci/` – kanonski predlošci pravnih akata  
- `postupci/` – standardizirane proceduralne sheme  
- `predmeti/` – konkretni slučajevi (lokalno)  
- `primjeri/` – demonstracijski scenariji  

---

## Trenutni status

End-to-end pipeline radi za postojeće scenarije:

1. ingest izvora (NN HTML + ELI PDF fallback gdje treba)
2. parse u `struktura_nn*.json`
3. normiranje u `baza_zakona/norme/<akt_slug>/clanak_*.json`
4. preflight guardrail po `-AktSlug`
5. paket acceptance preko manifesta

Za paketni rad vrijedi tip-aware preflight:

- core aktovi: strict `procisceni`
- amandmani: strict `amandmani` (uz minimalni content sanity)

---

## Brzi start (Windows/PowerShell)

1) Preflight za jedan akt (core primjer):

`./alati/acceptance_preflight.ps1 -AktSlug "ustav_rh"`

1) Paket acceptance (manifest):

`./alati/acceptance_paket.ps1 -PaketPath "paketi/PAKET_PREKRSAJNI_V1.json"`

1) Ingest paketa (snapshot + parse + norm + preflight):

`./alati/ingest_paket.ps1 -PaketPath "paketi/PAKET_PREKRSAJNI_V1.json"`

1) Negativni test expected-count override (namjerni mismatch):

`./alati/acceptance_preflight.ps1 -AktSlug "ustav_rh" -ExpectedCountOverride 999`

---

## Exit kodovi

- `0` = uspjeh
- `20` = paket fail na required aktu
- `21` = paket fail samo na optional aktu
- `22` = neispravan paket manifest
- `2` = preflight tip guardrail fail (`tip_teksta` mismatch)
- `3` = preflight expected-count mismatch
- `12` = parser guardrail za nejednoznačan PDF slice (`FOUND_MULTIPLE_ACTS_IN_PDF`)

Napomena: pojedine skripte mogu vratiti i druge generičke non-zero kodove
za sistemske greške (npr. nedostajuće datoteke, mrežni problemi, runtime
iznimke).

---

## Encoding napomena (Windows)

Na Windows konzoli može se pojaviti CP1252/UTF-8 konflikt pri obradi znakova
(`č`, `ć`, `ž`), posebno kada se Python output agresivno preusmjerava i filtrira.
Zato je preporuka pokretati acceptance/ingest skripte direktno (bez nepotrebnog
pipeline filtriranja), a skripte već postavljaju UTF-8 gdje je potrebno.

Ako treba filtriranje, sigurnije je prvo spremiti output pa filtrirati datoteku.
