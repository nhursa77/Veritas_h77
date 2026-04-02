# Usporedba preostalih dviju unstaged datoteka

Datum: 2026-04-02
Grana: main | HEAD: 25efa2a [origin/main]
Zadatak: dokazna usporedba lokalnog viška s GitHub stanjem

---

## A) Polazni git dokaz

```
git status --short  (relevantni redovi):
 M dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md
 M dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md

git branch -vv:
* main 25efa2a [origin/main] feat: full-repo markdown gate uz scoped lint

git ls-remote --heads origin main:
25efa2ae6cda7721928d280f5e997bd95339348b  refs/heads/main
```

Zaključak pre-checka: lokalna grana identična s origin/main osim
navedna dva unstaged tracked filea. Nema staged promjena.

---

## B) Diff sažetak: MAPA_DOKUMENTACIJE_VERITAS_H77.md

Veličina diffa: +46 redaka (pure insertions, 0 brisanja).

### Što je dodano

Pet novih `###` sekcija ispred postojeće `### DNEVNIK_RADA.md` sekcije.
Svaka sekcija opisuje jedan od novih meta-dokumenata koji već postoje
kao untracked (`??`) u radnom stablu:

1. `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
2. `ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
3. `ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
4. `RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
5. `Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`

Svaki unos standardno završava rečenicom:
> Privremeni je radni trag i neoperativni pomoćni dokument;
> nije glavni tok `zakon -> ingest -> JSON`.

### Što NIJE promijenjeno

Sve izvorne sekcije (redovi 1–136) nepromijenjene.
Sekcija `### DNEVNIK_RADA.md` i sve iza nje nepromijenjene.

### Karakter promjene

Čisti indeksni dodatak — MAPA je registar dokumenata.
Promjena ne unosi operativni sadržaj ni izmjene zakona/JSON-a.
Nema prepisivanja — samo append novih index-zapisa.

---

## C) Diff sažetak: ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md

Veličina diffa: +21 redaka, -5 redaka (insertions + renumeracija).

### Dodane izmjene

1. Nova sekcija `## 1) Sažetak` (15 novih redaka) ispred ranijeg §1.
   Sadrži bullet-listu 5 točaka koje sažimaju zaključke koji ionako
   postoje u ostatku dokumenta.

2. Kratki intro redak dodan u §4 (Amandmani):
   > Amandmani su prikazani istim redoslijedom kojim su evidentirani
   > u manifestu `paketi/PAKET_ZPD_V1.json`.

3. Dodan newline na kraju datoteke (riješen `no-newline-at-EOF`).

### Što je promijenjeno

Renumeracija naslova: stari §1→§2, §2→§3, §3→§4, §4→§5.
Sadržaj sekcija NIJE mijenjan (jedino dodan intro u §4).

### Priroda promjene

Sadržajni dokument vezan uz pravni/operativni rad (ZPD final report).
Promjena strukturno proširuje dokument novim sažetkom.
Nije meta-indeks — direktno se tiče zakonskog projekta.

---

## D) Procjena karaktera i rizika

| # | Datoteka | Karakter | Rizik |
|---|----------|----------|-------|
| 1 | MAPA_DOKUMENTACIJE_VERITAS_H77.md | lokalni meta-trag | NIZAK |
| 2 | ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md | stariji radni trag | SREDNJI |

### MAPA_DOKUMENTACIJE_VERITAS_H77.md — lokalni meta-trag

- Sadrži isključivo indeksne zapise za 5 datoteka koje već postoje
  lokalno kao `??` untracked.
- Promjena je append-only (nema brisanja ni prepisivanja).
- Ne tiče se nijednog zakonskog dokumenta ni JSON-a.
- Nakon commita tih 5 untracked datoteka MAPA bi bila konzistentna
  s radnim stablom.
- Veza s origin/main: jedina razlika je 5 novih indeksnih zapisa.
- RIZIK: nizak — greška u commitu lako reverzibilna bez operativnih
  posljedica.

### ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md — radni trag

- Nova sekcija Sažetak i renumeracija §§ nastala su kao stariji
  lokalni radni korak (vjerojatno before-Z138/Z139 niz).
- Trag potječe iz stasha `veritas-pre-rebase-z147` (stash@{0}).
- Stash je nastao PRIJE rebasa Z147 — promjene su dakle starije od
  trenutnog HEAD-a.
- Nije čist append: dodana strukturna sekcija + promijenjena
  numeracija što zahtijeva pažljivo scope-iranje.
- Nije vezana uz tekući zadatak; nije dio Z147 ni Z148 scopea.
- RIZIK: srednji — scope-iranje ovog commita zahtijeva provjeru
  zašto je promjena nastala i je li konzistentna s ostatkom.

---

## E) Zaključak: koja je jedna sljedeća sanacija najmanje rizična

**Preporučeni sljedeći korak: MAPA_DOKUMENTACIJE_VERITAS_H77.md**

Razlozi:

1. Promjena je čisto indeksna — ne unosi operativni sadržaj.
2. Append-only — nema rizika kolateralnih izmjena.
3. Lako se zatvara u jedan scoped commit zajedno s 5 untracked
   meta-dokumenata koje ona opisuje.
4. Ne zahtijeva provjeru starijih radnih tragova ni analizu
   zašto je promjena nastala.
5. Nakon commita MAPA + 5 pratećih untracked dokumenata repo
   postaje znatno čišći bez dodirivanja operativnih datoteka.

**ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md — odgoditi.**

Razlog odgode: promjena potječe iz stasha (stariji radni trag),
zahtijeva zasebnu scope-analizu zašto je novi Sažetak dodan i
je li renumeracija konzistentna s pravilima projekta. Treba
zasebni zadatak (npr. Z149) s dokumentiranim razlogom izmjene.

---

*Dokument je read-only evidencijski trag.*
*Sanacije, commiti i pushovi nisu dio ovog dokumenta.*
