# Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA

Datum: 31.03.2026.
Status: dokazna priprema scoped commita
Opseg: izdvajanje stvarnog Z138 skupa iz trenutačno miješanog lokalnog stanja,
bez commita, bez pusha i bez diranja zakona, sidara, normi, parsera,
validatora i ZPD završnog izvještaja.

---

Polazni dokaz pri izradi ovog dokumenta:

- `git status --short` pokazuje da su lokalno miješani
  `DNEVNIK_RADA.md`, `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md` i stariji diff u
  `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `git status --short` pokazuje da je
  `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md` i dalje
  nepracena nova datoteka iz Z138
- `git diff -- dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md` pokazuje da je
  u mapi Z138 trag pomiješan s kasnijim Z139-Z143 unosima
- `git diff -- dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` pokazuje da je u
  statusu Z138 trag pomiješan s kasnijim Z137-Z143 zapisima
- `git diff -- dokumentacija/DNEVNIK_RADA.md` pokazuje da dnevnik nije čisti
  jednokratni Z138 diff, nego kumulativni lokalni trag više zadataka
- `git ls-remote --heads origin main` potvrđuje da je `origin/main` i dalje na
  `8666f89`

## ŠTO JE STVARNI SADRŽAJ Z138

Stvarni sadržaj Z138 je inventurni korak, a ne glavni kanonski obrazac.

Njegova jezgra je dokazno utvrditi:

- što za zakone s amandmanima već postoji u repou
- što još nedostaje kao objedinjeni kanonski dokument
- koje sekcije taj budući objedinjeni dokument mora sadržavati

Zato je stvarni primarni artefakt Z138 isključivo inventurni dokument, a ne
kasniji objedinjeni obrazac, analize dovoljnosti ili dokument razdvajanja
scopea.

## KOJE DATOTEKE ULAZE U Z138

U stvarni Z138 scope ulaze:

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- samo Z138 hunk iz `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- samo Z138 hunk iz `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- samo Z138 append-only blok iz `dokumentacija/DNEVNIK_RADA.md`

Ni jedna druga nova Z138-Z143 datoteka ne ulazi u uski Z138 commit.

## KOJI DIJELOVI MAPE PRIPADAJU Z138

Mapi čisto pripada samo unos za inventurni dokument:

- naslov `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- njegov opis da dokument definira analitičku inventuru postojećeg obrasca
- pripadna rečenica da uređuje što je već pokriveno, što nedostaje i koje
  sekcije treba dodati budućem jedinstvenom kanonskom dokumentu

Svi sljedeći unosi u mapi pripadaju kasnijim zadacima i ne smiju u Z138:

- `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`

## KOJI DIJELOVI STATUSA PRIPADAJU Z138

Statusu čisto pripada samo Z138 zapis u pregledu dovršenih zadataka:

- `ZADATAK 138: izrađena je analitička inventura postojećeg obrasca...`

Trenutačni snapshot blok na vrhu statusa ne pripada budućem čistom Z138
commitu jer već odražava kasnije lokalno stanje:

- `Repo čist pri pre-checku: NE`
- `Zadnji dovršeni zadatak: ZADATAK 143`

Ni trenutačni operativni sažetak ne pripada čisto Z138, jer već sadrži
zaključke iz Z140, Z142 i Z143.

## KOJI DNEVNIČKI BLOK PRIPADA Z138

Dnevniku čisto pripada append-only blok:

- `## Datum: 31.03.2026. (ZADATAK 138)`
- `### ZADATAK 138 - inventura obrasca zakoni s amandmanima`

Taj blok sadrži upravo Z138 zaključak da repou ne nedostaju pojedinačni
mehanizmi, nego jedan objedinjeni kanonski dokument koji ih mora povezati.

Kasniji dnevnički blokovi za Z139, Z140, Z141, Z142 i Z143 ne smiju se
uključivati u Z138 commit.

## ŠTO IZ TRENUTAČNOG DIFFA NE SMIJE U Z138

U Z138 ne smije ući ništa od sljedećeg:

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- svi kasniji Z139-Z143 hunkovi iz mape, statusa i dnevnika
- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `.vscode/`

Razlog je isti u svim slučajevima: to nisu stvarni inventurni tragovi Z138,
nego kasniji ili izvan-scope lokalni artefakti.

## TOČAN STAGED POPIS ZA BUDUĆI Z138 COMMIT

Točan budući Z138 staged skup treba biti:

- puna nova datoteka
  `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- samo map hunk koji uvodi unos za
  `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- samo status hunk koji uvodi zapis `ZADATAK 138`
- samo append-only dnevnički blok za `ZADATAK 138`

To znači da se Z138 iz trenutačnog radnog stabla ne smije zatvarati preko
punih datoteka `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
`STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md`, nego isključivo preko
parcijalno izdvojenih Z138 hunka.