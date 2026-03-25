# STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA

Datum: 25.03.2026.
Status: kanonski
Opseg: sužavanje NN kandidata u konačne podnatuknice spremne za ručnu
validaciju.

---

## 1) Svrha

Ovaj standard definira prijelaz iz sloja v2 kandidata u konačni skup
kandidata za ručnu pravnu validaciju, bez automatskog donošenja konačne
normativne odluke.

Konačne podnatuknice iz ovog koraka služe isključivo kao priprema za ručni
odabir i potvrdu sidra.

---

## 2) Ulaz i izlaz

Ulaz:

- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2.json`
- `baza_terminologije/rjecnik/kandidatske_podnatuknice_nn_v2_manifest.json`

Izlaz:

- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju.json`
- `baza_terminologije/rjecnik/konacni_nn_kandidati_za_validaciju_manifest.json`

Skripta:

- `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`

---

## 3) Pravila sužavanja

Kandidati se sužavaju unutar istog nadređenog pojma.

Jedan konačni zapis nastaje kada kandidati dijele isti normativni kontekst:

- `naziv_akta`
- `broj_nn`
- `clanak`
- `stavak`
- `tocka`

Takav zapis dobiva oznaku:

- `GRUPIRAN_ISTI_KONTEKST`

Ako kandidat predstavlja drugačiji akt ili drugačiji normativni kontekst,
zapis ostaje odvojen i dobiva oznaku:

- `ZADRŽAN_RAZLIČIT_AKT` ili
- `ZADRŽAN_RAZLIČIT_KONTEKST`

---

## 4) Obavezna statusna polja

Svaki konačni kandidat mora imati:

- `status_kandidata = "SPREMAN_ZA_RUČNU_VALIDACIJU"`
- `zahtijeva_rucnu_validaciju = true`

Nije dopušteno:

- automatski odabrati "glavno" sidro,
- unositi nove članke, stavke ili točke,
- unositi novu normativnu definiciju pojma.

---

## 5) Pravilo protiv nasilnog spajanja

Kandidati se ne smiju nasilno spajati ako predstavljaju različit normativni
kontekst.

Različit normativni kontekst znači barem jednu razliku u poljima:
`naziv_akta`, `broj_nn`, `clanak`, `stavak`, `tocka`.

---

## 6) Obavezna sadržina manifesta

Manifest mora sadržavati najmanje:

- ukupan broj v2 kandidata,
- ukupan broj konačnih kandidata,
- broj kandidata po nadređenom pojmu (prije i poslije),
- broj grupiranih kandidata,
- broj zadržanih kandidata,
- popis grupiranih kandidata,
- popis zadržanih kandidata,
- usporedbu brojeva prije/poslije po nadređenom pojmu.

---

## 7) Izvještaj na stdout

Skripta mora ispisati deterministički izvještaj s brojem kandidata po
nadređenom pojmu prije i poslije sužavanja, te ukupne brojeve prije/poslije.
