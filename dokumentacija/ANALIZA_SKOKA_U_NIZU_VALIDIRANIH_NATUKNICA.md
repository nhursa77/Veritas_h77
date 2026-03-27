# ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA

Datum: 27.03.2026.
Status: dokazno
Opseg: objasnjenje skoka u nizu potpuno validiranih natuknica
`apsolutna nenadležnost — prekršajni zakon` s čl. 103 na čl. 122.

---

## 1) Ulazni skupovi koristenja

Analiza je radena iskljucivo nad datotekama:

- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2.json`
- `baza_terminologije/rjecnik/granske_podnatuknice_nn_v2_manifest.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice.json`
- `baza_terminologije/rjecnik/potpuno_validirane_natuknice_manifest.json`

---

## 2) Pocetno stanje niza

Za ciljani niz (`nadredeni_kanonski_naziv=apsolutna nenadležnost`,
`akt_slug=prekrsajni_zakon`) u ulazu `granske_podnatuknice_nn_v2.json`
postoje clanci:

- `101`
- `102`
- `103`
- `122`
- `161`

U potpuno validiranom izlazu su zatvoreni:

- `101`
- `102`
- `103`
- `122`

---

## 3) Raspon 104-121

Raspon koji je provjeren: `104` do `121`.

U ulaznom nizu (`granske_podnatuknice_nn_v2.json`) u tom rasponu postoji:

- nijedan clanak (`ULAZ_104_121_COUNT=0`)

U zatvorenom nizu (`potpuno_validirane_natuknice.json`) u tom rasponu postoji:

- nijedan clanak (`ZATVORENI_104_121_COUNT=0`)

Preskoceni brojevi u rasponu:

- `104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117,
  118, 119, 120, 121`

Razlog preskakanja za cijelu skupinu `104-121`:

- ne postoje kandidatske granske podnatuknice tog niza u ulazu,
- zato ih nije moguce zatvoriti,
- algoritam deterministickog odabira ispravno bira sljedeci postojeci clanak,
  a to je `122` nakon `103`.

---

## 4) Zakljucak

Skok `103 -> 122` je ispravan.

Nije doslo do greske odabira niti do preskakanja postojecih kandidata.
Skok je posljedica stvarnog sastava ulaznog skupa, koji u ciljnom nizu nema
clanke `104-121`.

---

## 5) Dokazne naredbe

- `git status --short`
- `git --no-pager log -1 --oneline`
- `git branch -vv`
- `Get-Content`
    `.\baza_terminologije\rjecnik\granske_podnatuknice_nn_v2.json -Raw`
- `Get-Content`
    `.\baza_terminologije\rjecnik\granske_podnatuknice_nn_v2_manifest.json -Raw`
- `Get-Content`
    `.\baza_terminologije\rjecnik\potpuno_validirane_natuknice.json -Raw`
- `Get-Content`
    `.\baza_terminologije\rjecnik\potpuno_validirane_natuknice_manifest.json`
    `-Raw`
