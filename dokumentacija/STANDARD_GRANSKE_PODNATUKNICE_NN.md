# STANDARD_GRANSKE_PODNATUKNICE_NN

Datum: 25.03.2026.
Status: kanonski
Opseg: konsolidacija djelomično validiranih NN sidara u granske rječničke
podnatuknice.

---

## 1) Svrha

Ovaj standard definira tehničko razdvajanje općih pojmova na granske
podnatuknice prema dokazivom normativnom kontekstu.

Ako postoje različiti dokazivi konteksti, opći pojam ne smije ostati
"koš za sve".

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/osnovni_postupovni_skup_nn_validiran.json`
- `baza_terminologije/rjecnik/
 osnovni_postupovni_skup_nn_validiran_manifest.json`

Izlaz:

- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json`
- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json`

Skripta:

- `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`

---

## 3) Obavezna pravila konsolidacije

Podnatuknice se grade po pravnoj grani i/ili po aktu.

Konsolidacija nije slobodno pravno tumačenje, nego tehničko razdvajanje po
postojećem dokazivom kontekstu iz ulaza.

Nije dopušteno:

- izmišljati nove članke,
- izmišljati definicije,
- spajati prekršajni i ustavni kontekst u isti konačni zapis,
- zadržati opći pojam kao jedini spremnik ako postoje različiti dokazivi
  konteksti.

Nije dopušteno automatsko sažimanje `5 -> 1` ako ulazna sidra ne dijele
isti akt i isti normativni kontekst (`broj_nn`, `clanak`, `stavak`, `tocka`).

---

## 4) Obavezna polja podnatuknice

Svaka granska podnatuknica mora sadržavati najmanje:

- `nadredeni_pojam_id`
- `nadredeni_kanonski_naziv`
- `podnatuknica_id`
- `kanonski_naziv_podnatuknice`
- `pravna_grana_ili_kontekst`
- `naziv_akta`
- `akt_slug`
- `broj_nn`
- `nn_sidra`
- `status_podnatuknice`
- `osnova_konsolidacije`
- `zahtijeva_rucnu_potvrdu`

---

## 5) Pravila polja

- `kanonski_naziv_podnatuknice` je deterministički oblik:
  `<pojam> — <kontekst/akt>`.
- `status_podnatuknice` je uvijek `GRANSKI_KONSOLIDIRANO`.
- `osnova_konsolidacije` je jedna od vrijednosti:
  `RAZLICIT_AKT`, `RAZLICITA_PRAVNA_GRANA`,
  `RAZLICIT_NORMATIVNI_KONTEKST`.
- `zahtijeva_rucnu_potvrdu` je uvijek `true`.

---

## 6) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj ulaznih općih pojmova,
- ukupan broj izlaznih granskih podnatuknica,
- broj podnatuknica po nadređenom pojmu,
- broj podnatuknica po aktu,
- broj podnatuknica po pravnoj grani ili kontekstu,
- popis svih podnatuknica,
- popis pojmova koji su ostali u samo jednom kontekstu,
- popis pojmova koji su razlomljeni na više konteksta,
- detalj po pojmu: broj ulaznih sidara, broj izlaznih podnatuknica,
  razloge grupiranja,
- popis pojmova koji su ostali `1 -> 1` i obrazloženje zašto.

---

## 7) Odnos prema korisničkoj natuknici

Konačna korisnička natuknica u kasnijem koraku može prikazivati više granskih
podnatuknica istog nadređenog pojma.

Pilot-zatvaranje prve potpuno validirane podnatuknice iz ovog sloja vodi se
prema `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`.
