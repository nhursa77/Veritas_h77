# TEHNIČKI_OKVIR_VERITAS_H77

Datum: 17.02.2026.
Status: kanonski
Opseg: lokalni rad Veritas H.77 na Windows okruženju, bez cloud-a.

---

## 1) Okruženje

Primarno okruženje je Windows s PowerShell konzolom.
Rad se izvodi lokalno, uz lokalne datoteke i lokalne alate.
Pokretanje koraka mora biti reproducibilno kroz iste naredbe.

---

## 2) Repozitorij i mape

### `dokumentacija/`
Postoji u repozitoriju. Sadrži kanonske dokumente i dnevnik rada.

### `baza_normi/`
Trenutno ne postoji u repozitoriju.
TODO: kreirati u fazi 1.

### `baza_postupaka/`
Trenutno ne postoji u repozitoriju.
TODO: kreirati u fazi 2.

### `predlosci/`
Postoji u repozitoriju. Namjena je pohrana predložaka dokumenata.

### `predmeti/`
Postoji u repozitoriju. Namjena je pohrana stvarnih predmeta.

### `alati/`
Trenutno ne postoji u repozitoriju.
TODO: odluka o opsegu alata i kreiranje u odgovarajućoj fazi.

### `skripte/`
Trenutno ne postoji u repozitoriju.
TODO: odluka hoće li se koristiti zasebna mapa `skripte/`.

### `docker/` ili `docker-compose.yml`
Mapa `docker/` trenutno ne postoji.
U korijenu postoji `docker-compose.yml`.
TODO: odluka treba li uvoditi mapu `docker/`.

Napomena:
U repozitoriju trenutno postoji i `baza_zakona/` te proceduralni sadržaji.
TODO: odluka o kanonskom usklađenju naziva s planiranim mapama
`baza_normi/` i `baza_postupaka/`.

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

Opcionalni backup/kontrolni izvor je zakon.hr:

- `izvori/operativno/zakon_hr/<akt_slug>/`

Ako postoji nesklad između pomoćnog izvora i NN izvora, nesklad se mora
označiti i evidentirati. U slučaju nesklada prednost ima NN izvor.

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

- Odluka o kanonskom usklađenju naziva `baza_zakona/` i `baza_normi/`.
- Odluka o kanonskom usklađenju proceduralnih sadržaja i
	`baza_postupaka/`.
- Odluka o uvođenju mape `skripte/`.
- Odluka o uvođenju mape `docker/` uz postojeći `docker-compose.yml`.
- Odluka o opsegu i vremenu uvođenja mape `alati/`.
- Odluka o konačnom formatu snapshot veze prema predmetu.
