# Veritas H.77

Veritas H.77 je ustavno-pravni digitalni sustav za obranu prava pojedinca
kroz strogo strukturiranu obradu činjenica, normi i postupaka.

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

1. Hijerarhija normi: prirodno pravo → međunarodni akti → ustav → zakoni
   → podzakonski akti.  
2. Službeni izvor ima prednost nad agregiranim tekstom.  
3. Svaka norma mora imati dokazno sidro.  
4. Svaka obrada mora biti ponovljiva i provjerljiva.  
5. Sustav djeluje obrambeno i proporcionalno.  

---

## Pravilo izvora

- Pročišćeni tekst zakona koristi se kao radna osnova.  
- Službena objava u Narodnim novinama predstavlja dokazni izvor.  
- U slučaju razlike, prednost ima službeni tekst objavljen
  u Narodnim novinama.  
- Svaki citirani članak mora sadržavati oznaku članka, stavka
  i podatke o objavi.  

---

## Struktura projekta

Napomena: kanonske putanje se uzimaju iz ovog README-a i
`dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`; tehnički okvir je usklađen s tim
izvorima.

- `dokumentacija/` – normativna pravila sustava  
- `baza_zakona/` – strukturirani zapisi zakona  
- `baza_zakona/norme/` – samo operativni setovi (`*_procisceni`)  
- `baza_zakona/sidra/` – NN sidra i amandmanski `*_nn_<broj>_<godina>` setovi  
- `baza_zakona/arhiva/` – arhivski snapshotovi u formatu  
  `<akt_slug>/<source_set_slug>/`  
- `predlosci/` – kanonski predlošci pravnih akata  
- `postupci/` – proceduralni sadržaji (trenutna fizička putanja;  
  “baza postupaka” je logički naziv u dokumentaciji)  
- `baza_postupaka/` – planirani naziv nakon migracije proceduralne mape  
- `predmeti/` – konkretni slučajevi (lokalno)  
- `primjeri/` – demonstracijski scenariji  

---

## Status

Projekt je u fazi definicije normativnih pravila i arhitekture sustava.
