# STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE

Datum: 31.03.2026.
Status: kanonski
Opseg: pravila za pisanje i servisnu kontrolu projektne markdown
dokumentacije.

---

## 1) Svrha

Ovaj standard uvodi obaveznu disciplinu za markdown dokumentaciju kako bi
se spriječili tipični kvarovi u pratećim dokumentima:

- samoreferencijalni commit/hash trag koji zaostaje prema stvarnom git stanju
- dupli headingi (`MD024`)
- interpunkcija na kraju headinga (`MD026`)
- predugi redci (`MD013`)

---

## 2) Pravilo headinga

Headingi se pišu kratko, jednoznačno i bez završne interpunkcije.

Obavezna pravila:

- heading ne završava s `.`, `:`, `;`, `!` ili `?`
- heading mora biti jedinstven unutar iste markdown datoteke
- ako postoje više unosa istog datuma ili istog zadatka, heading mora imati
  razlikovni dodatak, npr. `(ZADATAK 104)`
- datum se može pisati u headingu samo bez završne točke ako je dio samog
  heading retka

Primjeri ispravno:

- `## Datum: 31.03.2026 (ZADATAK 104)`
- `### ZADATAK 104 - servisno zatvaranje z103 i sanacija dnevnika`

Primjeri neispravno:

- `## Datum: 31.03.2026.`
- `### Sažetak.`
- dva headinga `### Sažetak` u istoj datoteci

---

## 3) Pravilo retka

Za markdown dokumentaciju vrijedi ograničenje `MD013`.

Obavezna pravila:

- redak ne smije prelaziti 80 znakova kad god je sadržaj moguće razlomiti
- duge naredbe, putanje i popise treba lomiti u više redaka
- kod blokovi i dokazne naredbe smiju se lomiti u više stavki umjesto u
  jednu predugu liniju

---

## 4) Pravilo dnevnika

`dokumentacija/DNEVNIK_RADA.md` je append-only evidencijska datoteka.

Obavezna pravila:

- novi unos generira se isključivo preko
  `alati/generiraj_dnevnicki_unos.ps1`
- novi unos dodaje se u dnevnik isključivo preko
  `alati/dodaj_dnevnicki_unos_na_kraj.ps1`
- goli URL-ovi ne smiju se pojaviti u dnevniku; ako su dio dokaznog traga,
  moraju biti zapisani u markdown-safe obliku, preferirano kao inline code
- generator `alati/generiraj_dnevnicki_unos.ps1` mora prije upisa automatski
  sanitizirati gole URL-ove iz sazetka u markdown-safe oblik
- prije izmjene obavezan je before-tail ispis
- nakon dodavanja obavezan je after-tail ispis
- postojeći sadržaj smije se sanirati samo minimalno i samo kad je to
  nužno za uklanjanje dokazive markdown greške ili servisne nekonzistentnosti

---

## 5) Pravilo statusa

`dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` smije se dirati samo kad je
potrebno uskladiti stvarno stanje projekta.

Obavezna pravila:

- prije izmjene statusa mora se dokazati stvarni git HEAD
- `dokumentacija/DNEVNIK_RADA.md` ostaje jedini strogo kronološki
  append-only dnevnik rada
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` nije dnevnik nego snapshot
  i sazet pregled dovrsenih zadataka
- status mora imati snapshot blok na vrhu, a pregled dovrsenih zadataka
  ispod njega
- pregled dovrsenih zadataka u statusu mora ici strogo od starijeg prema
  novijem
- zadnji dovrseni zadatak mora biti upisan na dva mjesta: u snapshot bloku
  na vrhu i kao zadnja stavka pregleda dovrsenih zadataka
- status više ne vodi samoreferencijalni finalni commit/hash kao opis
  zadatka koji tek treba biti commitan
- skripta `alati/uskladi_status_projekta.ps1` usklađuje samo stabilna
  pre-check polja: `Polazni HEAD prije zadatka`,
  `Repo čist pri pre-checku`, `Poravnanje grane pri pre-checku`
  i, kad je eksplicitno zadan, `Zadnji dovršeni zadatak`
- sva pre-check polja u statusu pune se isključivo iz dokazno uhvaćenih
  ulaza s početnog pre-checka; nikad se ne smiju inferirati nakon izmjena
- `Repo čist pri pre-checku` smije imati samo vrijednost `DA` ili `NE`
- ako bilo koji obavezni pre-check ulaz nije eksplicitno predan,
  `alati/uskladi_status_projekta.ps1` i
  `alati/zatvori_dokumentacijski_korak.ps1` moraju pasti fail-fast
- skripta smije opcionalno uskladiti i oznaku zadnjeg dovršenog zadatka,
  ali samo ako je eksplicitno zadana; taj upis mora biti pouzdan i ne smije
  zahtijevati naknadni ručni patch statusa; skripta ne smije preuređivati
  pregled dovrsenih zadataka
- opisni sadržaj zadatka u statusu dopunjava se samo u scoped patchu

---

## 6) Pravilo mape dokumentacije

`dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` mijenja se samo kad nastane
novi kanonski dokument, nova trajna skripta koju mapa mora voditi ili novi
trajni artefakt koji je važno indeksirati.

Ne mijenja se rutinski pri svakom zadatku.

---

## 7) Obavezni servisni redoslijed

Za svaki dokumentacijski zadatak vrijedi ovaj redoslijed:

1. pre-check repozitorija
2. before-tail dnevnika ako je dnevnik u scopeu
3. scoped izmjena datoteka
4. `alati/uskladi_status_projekta.ps1` nad stabilnim pre-check poljima
  iz eksplicitno uhvaćenih ulaza
5. `alati/generiraj_dnevnicki_unos.ps1` za lint-safe entry file
6. `alati/dodaj_dnevnicki_unos_na_kraj.ps1` za append-only dnevnik
7. `alati/provjeri_markdown_scope.ps1` nad ciljanim `.md` datotekama
8. `alati/zatvori_dokumentacijski_korak.ps1` kao kanonski wrapper
9. puni gateovi (`alati/lint_markdown.ps1`, `alati/ci_smoke.ps1`)
10. commit

---

## 8) Servisne skripte

Kanonske servisne skripte za ovaj standard su:

- `alati/uskladi_status_projekta.ps1`
- `alati/generiraj_dnevnicki_unos.ps1`
- `alati/dodaj_dnevnicki_unos_na_kraj.ps1`
- `alati/zatvori_dokumentacijski_korak.ps1`
- `alati/provjeri_markdown_scope.ps1`

Njihova je svrha smanjiti ručne greške u statusnom tragu i markdown
disciplini, bez širenja opsega na druge dijelove sustava.
