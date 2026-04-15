# TEHNIČKI_OKVIR_VERITAS_H77

Datum: 25.03.2026.
Status: kanonski
Opseg: lokalni rad Veritas H.77 na Windows okruženju uz kanonski GitHub.

---

## 1) Okruženje

Primarno okruženje je Windows s PowerShell konzolom.
Rad se izvodi lokalno, uz lokalne datoteke i lokalne alate.
Pokretanje koraka mora biti reproducibilno kroz iste naredbe.

Kanonski model sinkronizacije:

- GitHub je izvor istine,
- `C:\Veritas_H77` je jedina radna kopija,
- Google Disk je sinkronizirana kopija/backup, nije paralelna radna kopija.

---

## 2) Repozitorij i mape

### `dokumentacija/`
Postoji u repozitoriju. Sadrži kanonske dokumente i dnevnik rada.

### `baza_zakona/norme/`
Postoji u repozitoriju.
Kanonski sadrži isključivo operativne setove `*_procisceni`.

### Postupci (trenutna fizička putanja)
Trenutna fizička putanja proceduralnih sadržaja je `postupci/`.
`baza_postupaka/` je planirana migracija (TODO) i ne smatra se postojećom
putanjom dok se ne napravi zaseban commit.

### `predlosci/`
Postoji u repozitoriju. Namjena je pohrana predložaka dokumenata.

### `predmeti/`
Postoji u repozitoriju. Namjena je pohrana stvarnih predmeta.

### `alati/`
Postoji u repozitoriju.
Sadrži skripte za ingest, normiranje, validaciju i CI smoke provjere.

Napomena:
Uveden je i `alati/zatvori_validiranu_gransku_natuknicu.py` kao novi
genericki alat za objedinjenu jezgru zatvaranja validirane granske
natuknice.
Cetiri stara wrappera skupine uklonjena su nakon dokazne provjere
referenci kroz
`dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
`WRAPPERA_GRANSKIH_NATUKNICA.md` i
`dokumentacija/POPIS_REFERENCI_NA_WRAPPERE_GRANSKIH_NATUKNICA.md`.
`alati/zatvori_validiranu_gransku_natuknicu.py` ostaje jedina aktivna
implementacija ove skupine.

Uveden je i `alati/zatvori_paket_prekrsajni_zakon.py` kao novi
genericki alat za objedinjenu jezgru paketnog zatvaranja homogenih
nizova za `prekrsajni_zakon`.
Starih 8 wrappera skupine `zatvori_paket_*_prekrsajni_zakon.py`
uklonjeno je nakon dokazne provjere referenci kroz
`dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_WRAPPERA_PAKETA_`
`PREKRSAJNOG_ZAKONA.md` i
`dokumentacija/POPIS_REFERENCI_NA_WRAPPERE_PAKETA_PREKRSAJNOG_`
`ZAKONA.md`.
`alati/zatvori_paket_prekrsajni_zakon.py` ostaje jedina aktivna
implementacija ove skupine.

Uveden je i `alati/validiraj_json_po_shemi_v1.ps1` kao novi genericki
schema-driven validator za zajednicku jezgru validacije JSON izlaza po
shemi u skupini `PREKRSAJNI_JSON_VALIDATORI_V1`.
Pet validatora skupine (`validiraj_audit_v1.ps1`,
`validiraj_intake_prekrsaji_v1.ps1`, `validiraj_postupak_v1.ps1`,
`validiraj_predlozak_v1.ps1`, `validiraj_subsumciju_v1.ps1`) bili su
kompatibilni wrapperi koji su delegirali na taj genericki alat.
`alati/ci_smoke.ps1` za jezgru tih 5 schema-driven provjera vise ne
ovisi operativno o wrapperima, nego izravno poziva
`alati/validiraj_json_po_shemi_v1.ps1`.
Nakon konsolidacije i dokazne repo-pretrage removal spremnosti, tih 5
wrapper validatora uklonjeno je iz repoa, dok genericki alat i
preusmjereni `ci_smoke.ps1` ostaju operativna jezgra ove skupine.

Skupina `POMOCNI_POKRETACI_USTAV_RH` uklonjena je nakon konsolidacije i
dokazane removal spremnosti.
`alati/ustav_rh_convenience_core.ps1` ostaje zajednicka jezgra ove
domene, dok `alati/run_normiratelj.ps1` i
`alati/acceptance_preflight.ps1` ostaju netaknuti genericki pokretaci.

### `skripte/`
Nije kanonska mapa; koristi se `alati/`.

### `docker/` ili `docker-compose.yml`
Mapa `docker/` trenutno ne postoji.
U korijenu postoji `docker-compose.yml`.
TODO: odluka treba li uvoditi mapu `docker/`.

Napomena:
Kanonska baza normi je `baza_zakona/` s podmapama `norme/`, `sidra/` i
`arhiva/` prema razvojnom planu.

---

## 3) Pravila artefakata i commita

U Git se commita:
- kanonska dokumentacija (`.md`),
- strukturirani zapisi (`.json`),
- predlošci,
- skripte i pomoćni alati,
- konfiguracije repozitorija i alata.

U Git se ne commita:
- veliki binarni instaleri,
- privremene datoteke,
- logovi,
- lokalni cache,
- tajne iz `.env` datoteka.

Ako postoji dvojba oko artefakta:
- označiti `TODO: odluka`,
- ne commitati dok odluka nije donesena.

---

## 4) Docker/Compose

Docker/Compose služi reproducibilnosti i konzistentnom okruženju.
Ne uvode se dodatni servisi bez kanonske odluke.
Osnovno pravilo je mount repozitorija i provjera vidljivosti sadržaja.

---

## 5) Ollama i gate pravila

Ollama je lokalna pomoć pri strukturiranju i obradi, nije "pričalica".
Izlaz iz obrade mora biti verificiran normom i procedurom.
Nema automatskog slanja i nema automatskog potpisa.
Odluke o slanju i potpisu ostaju na čovjeku.

---

## 6) Ingest i izvori

Primarni izvor je Narodne novine (dokazni i operativni tekst).
Primarna arhiva izvora je:

- `izvori/dokazno/narodne_novine/<akt_slug>/`

Opcionalni kontrolni izvor je zakon.hr:

- `izvori/kontrolno/zakon_hr/<akt_slug>/`

Ako postoji nesklad između pomoćnog izvora i NN izvora, nesklad se mora
označiti i evidentirati. U slučaju nesklada prednost ima NN izvor.

### Logički naziv vs fizička putanja
Logički naziv “baza normi” označava koncept sloja normi.
Fizička putanja na disku je baza_zakona/norme/.
Logički naziv “baza postupaka” označava koncept sloja postupaka.
Fizička putanja proceduralnih sadržaja trenutno je postupci/.
baza_postupaka/ je planirana (TODO) migracija i ne smatra se postojećom
putanjom dok se ne napravi zaseban commit.

---

## 7) Stanje na dan i snapshot

Za svaki zapis bilježi se datum dohvaćanja u formatu `DD.MM.YYYY.`.
Za norme se bilježi status sidra (`puno`, `djelomicno`, `nema`).
Snapshot baze radi se kao kopija stanja uz manifest i hash vrijednosti.
Snapshot se veže uz predmet kroz referencu na verziju i datum snapshota.

TODO: odluka o točnom formatu veze snapshota i predmeta.

---

## 8) Kontrola kvalitete

Dokumentacija mora biti usklađena s kanonskim pravilima i MD013.
Repozitorij mora ostati čist nakon svakog završenog koraka.
Svaki značajan korak obavezno se upisuje u `DNEVNIK_RADA.md`.

---

## 9) TODO odluke

- Odluka o terminu fizičke migracije proceduralne mape na
  `baza_postupaka/`.
- Odluka o uvođenju mape `skripte/`.
- Odluka o uvođenju mape `docker/` uz postojeći `docker-compose.yml`.
- Odluka o konačnom formatu snapshot veze prema predmetu.
