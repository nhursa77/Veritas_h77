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
- `predmeti/` – isključivo javni sintetički predmeti i fixturei
- `primjeri/` – demonstracijski scenariji  

---

## Prekršajni modul (kanonska specifikacija)

Prekršajni modul je deterministički pipeline koji radi isključivo ovim redom:

NORMA → POSTUPAK → AUDIT → PREDLOŽAK → NACRT → GATE.

### Fizičke putanje (kanon)

- Postupci (trenutna fizička putanja): `postupci/sud/prekrsajni/`
- Predlošci akata: `predlosci/sud/prekrsajni/`
- Javni sintetički predmeti:
  `predmeti/sud/prekrsajni/OGLEDNI_<ID>/`
- Stvarni predmeti: izvan repozitorija, pod lokalnim korijenom određenim
  varijablom `VERITAS_LOCAL_DATA_ROOT`
- Norme: `baza_zakona/norme/<akt_slug>/clanak_XXXX.json`
- Sidra (NN): `baza_zakona/sidra/<akt_slug>/...`

Napomena: `baza_postupaka/` je planirana migracija; do migracije je kanonska
fizička putanja `postupci/`.

### Obavezni tokovi (v1)

Svaki tok je verzioniran (`v1`, `v2`, ...) i ima proceduralne korake u JSON-u.

- `postupci/sud/prekrsajni/TOK_PN_PRIGOVOR/v1/`
- `postupci/sud/prekrsajni/TOK_PRESUDA_ZALBA/v1/`
- `postupci/sud/prekrsajni/TOK_RJESENJE_ZALBA/v1/`
- `postupci/sud/prekrsajni/TOK_OBUSTAVA/v1/`

### Predmet (layout)

Predmet je jedina jedinica rada. Audit se ne prepisuje nego verzionira.
Putanje niže vrijede unutar korijena odabranog režima podataka:

- javni sintetički režim koristi korijen repozitorija;
- lokalni povjerljivi režim koristi `VERITAS_LOCAL_DATA_ROOT` izvan repoa.

- `predmeti/sud/prekrsajni/<ID>/predmet.json`
- `predmeti/sud/prekrsajni/<ID>/dokazi/` (akti, dostava, prilozi)
- `predmeti/sud/prekrsajni/<ID>/lanac_skrbnistva.json`
- `predmeti/sud/prekrsajni/<ID>/audit/audit_v1.json`
- `predmeti/sud/prekrsajni/<ID>/audit/audit_v2.json` (ako dopuna)
- `predmeti/sud/prekrsajni/<ID>/izlazi/nacrt_v1.md` (ili docx)
- `predmeti/sud/prekrsajni/<ID>/manifest.json` (hash + popis)

Stvarni predmet, dokazi i izlazi ne smiju se kopirati u Git repozitorij.
Prije prvog stvarnog predmeta mora biti aktivan P9 pre-commit čuvar, a puni
CI gate privatnosti mora prolaziti.

Audit, P7 runner te P8 generator i validator primaju lokalni korijen samo
izričitim parametrom `-DataRoot`. Kanonske reference ostaju iste u oba
režima. Lokalna fizička putanja ne zapisuje se u manifest, lanac ni izvršni
ispis. Test `alati/test_p9_lokalni_e2e_v1.ps1` to dokazuje sintetičkim
sadržajem izvan repozitorija; ne pokreće stvarni predmet.

### Lokalna P9 operativa

Novi lokalni predmet otvara se samo izričitim lokalnim korijenom i internom
oznakom koja počinje s `STVARNI_`. Inicijalizator ne prepisuje postojeći
predmet i ne unosi činjenice umjesto čovjeka:

```powershell
$root = '<ODOBRENI_LOKALNI_KORIJEN>'
$predmetId = 'STVARNI_<INTERNA_OZNAKA>'

pwsh -NoProfile -ExecutionPolicy Bypass -File `
  .\alati\inicijaliziraj_lokalni_predmet_prekrsaji_v1.ps1 `
  -DataRoot $root `
  -PredmetId $predmetId
```

Rezultat `P9_INIT_STATE=NEPOPUNJEN` namjerno nije spreman za obradu. Prije
pokretanja moraju biti ljudski uneseni i provjereni najmanje:

- `predmet.json` sa statusom `aktivan`;
- `intake/intake_v1.json`;
- `audit/subsumcija_v1.json` s kanonskim poljem `status`.

`audit/audit_v1.json` nije obavezan ulaz. Ako postoji, služi samo kao
provjereni kontekst za `KOL-01` i referentni datum G1. Ako ga nema, valjani
`status=PROLAZ` može dokazati G3, dok G1 ostaje vidljivo označen kao
`INDETERMINATE` i samostalno ne blokira obradu.

Tek nakon zasebnog odobrenja konkretnog predmeta cijeli dokazani tok pokreće
se jednom naredbom:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File `
  .\alati\pokreni_lokalni_tok_p9_v1.ps1 `
  -DataRoot $root `
  -PredmetId $predmetId
```

Pokretač najprije provjerava privatnosni Git čuvar, sheme, identitet i
spremnost ulaza. Na blokadi uklanja stare runtime izlaze i vraća `STOP` bez
artefakata. Uspjeh proizvodi točno četiri lokalna artefakta: generirani
audit, nepotpisani nacrt, manifest i lanac skrbništva. Fizičke putanje nisu
dio ispisa, a potpisivanje i slanje ostaju isključivo ljudska odluka.

Tehnički uspjeh tog lanca nije dokaz pravne spremnosti izlaza. Lokalna
sintetička generalna proba ZADATKA 180 potvrdila je privatnost i stvaranje
četiri artefakta, ali je ujedno dokazala da v1 još ne veže referencirani
dokaz u manifest, može ostaviti pravni lijek praznim i stvara samo tehnički
nacrt bez potpunog identiteta akta. Stvarni predmet ostaje blokiran dok se
te praznine zasebno ne zatvore i ljudski provjere.

### Pipeline modula M0–M9 (bez preskakanja)

Svaki modul mora završiti sa statusom `PROLAZ`, `NEPROLAZ` ili `N/A`
uz kratko obrazloženje u AUDIT zapisu.

- M0 Identifikacija akta i procesne faze
- M1 Valjanost izvora (NN sidra + važenje verzije)
- M2 Postupovne pretpostavke (rokovi, dostava, dopuštenost lijeka,
  nadležnost)
- M3 Subsumcija (elementi bića prekršaja: činjenica + dokaz + obrazloženje)
- M4 Obrazloženje odluke (činjenice/pravo, ocjena dokaza, izreka, pouka)
- M5 Klasifikacija grešaka (matrica pogrešaka: kod/težina/posljedica)
- M6 Odabir pravnog lijeka (što, kome, do kada, učinak)
- M7 Generiranje nacrta (predložak JSON punjen iz AUDIT-a)
- M8 Gate vanjskog izlaza (blokade i uvjeti potpisa)
- M9 Izvoz paketa (manifest + artefakti spremni za ljudski potpis)

### Gate pravila (blokade)

- Bez NN sidra (status OK) nema normiranja i nema vanjskog izlaza.
- Bez potpisa nositelja nema slanja/vanjskog izlaza (Veritas generira nacrt).
- Ako je bilo koji modul `NEPROLAZ`:
  izlaz je "nalaz nepravilnosti" (audit) + preporučeni pravni lijek,
  bez generiranja “konačnog” podneska.

Ova sekcija mora poštovati postojeći README kanon o putanjama i NN izvoru.

---

## Status

Osnova sustava (kanonska dokumentacija, struktura repoa i gate pravila) je
postavljena. Prekršajni modul se uvodi kao prvi end-to-end pilot kroz tokove
u `postupci/sud/prekrsajni/`, uz predmet + audit + predložak + gate.
Vanjski izlaz ostaje blokiran bez NN sidra i potpisa nositelja.
