# RAZDVAJANJE_SCOPEA_Z138_DO_Z142

Datum: 31.03.2026.
Status: dokazni analiticki presjek
Opseg: razdvajanje trenutnog lokalnog dokumentacijskog stanja na scopeove
Z138, Z139, Z140, Z141 i Z142, bez commita, bez pusha i bez diranja zakona,
sidara, normi, parsera, validatora i ingest toka.

---

Polazni dokaz pri izradi ovog dokumenta:

- `git status --short` pokazuje cetiri modificirane pracene datoteke:
  `DNEVNIK_RADA.md`, `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md` i
  `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `git status --short` pokazuje pet nepracenih Z138-Z142 analitickih
  dokumenata i jedan izvan-scope `.vscode/` artefakt
- `git diff --name-only` ne pokazuje nijednu od pet novih Z138-Z142 datoteka,
  nego samo vec pracene mijesane datoteke i stariji lokalni diff u
  `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `git ls-remote --heads origin main` pokazuje da je `origin/main` i dalje na
  `8666f89`
- `git --no-pager log -5 --oneline` potvrduje da je zadnje stvarno zatvoreno
  GitHub stanje i dalje Z136

## DATOTEKE KOJE PRIPADAJU Z138

Primarni Z138 artefakt je:

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

Z138 je po svojoj naravi inventurni korak. Njegova jezgra je dokument koji
utvrdjuje sto vec postoji, sto nedostaje i zasto je potreban objedinjeni
kanonski obrazac.

Z138 nema vlastitu cistu samostalnu verziju u zajednickim datotekama
`MAPA_DOKUMENTACIJE_VERITAS_H77.md`, `STATUS_PROJEKTA_VERITAS_H77.md` i
`DNEVNIK_RADA.md`, jer su te datoteke lokalno vec nadogradjene i kasnijim
tragovima Z139-Z142.

## DATOTEKE KOJE PRIPADAJU Z139

Primarni Z139 artefakt je:

- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`

Z139 je glavni sadrzajni korak jer uvodi objedinjeni opci standard za zakone s
amandmanima.

Kao i kod Z138, zajednicke datoteke `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
`STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md` u trenutasnom lokalnom
stanju vise nisu cisti Z139 trag, nego kumulativni trag Z138-Z142.

## DATOTEKE KOJE PRIPADAJU Z140

Primarni Z140 artefakt je:

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

Z140 pripada dokaznom razdvajanju lokalnog i GitHub stanja. Njegova svrha nije
uvodjenje novog kanona, nego dokumentiranje da lokalno vec postoji inventura i
glavni kanonski obrazac koji jos nisu zatvoreni na GitHubu.

Zbog toga je Z140 sadrzajno odvojen od Z139, ali je u zajednickim datotekama
trag vec pomijesan s kasnijim Z141 i Z142 zapisima.

## DATOTEKE KOJE PRIPADAJU Z141

Primarni Z141 artefakt je:

- `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

Z141 je zaseban analiticki korak koji ne dodaje novi glavni standard, nego
procjenjuje je li Z139 vec dovoljno jak kao glavni dokument.

U trenutasnom lokalnom stanju Z141 je cist samo na razini vlastite nove
datoteke; svi zajednicki tragovi u mapi, statusu i dnevniku vec su pomijesani
s ostalim koracima Z138-Z142.

## DATOTEKE KOJE PRIPADAJU Z142

Primarni Z142 artefakt je:

- `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

To je jedina trenutna lokalna datoteka koja pripada uskom zavrsnom odgovoru
`DA/NE` na pitanje dovoljnosti glavnog kanonskog obrasca.

Ako se trazilo pitanje sto je od trenutnog lokalnog stanja stvarni uski Z142
scope, odgovor je:

- cisti Z142 scope je nova datoteka
  `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- zajednicki tragovi u `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md` nisu vise cisti Z142,
  nego kumulativni trag vise lokalno nezatvorenih zadataka

## DATOTEKE KOJE SU TRENUTNO MIJEŠANE I NE SMIJU U ISTI COMMIT

Trenutno mijesane datoteke su:

- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- `dokumentacija/DNEVNIK_RADA.md`

Razlog je dokazno jasan: te tri datoteke vec sadrze lokalne tragove Z138,
Z139, Z140, Z141 i Z142. Zato ih nije dopusteno nekriticki ubaciti u bilo koji
pojedinacni commit bez prethodnog parcijalnog izdvajanja odgovarajucih hunka
ili bez privremenog urednickog razdvajanja po zadatku.

Datoteke koje ne pripadaju buducim commitima Z138-Z142 su:

- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  jer je to stariji lokalni diff vezan uz raniji ZPD dokumentacijski niz,
  odnosno uz Z137/Z132 trag, a ne uz analiticki niz Z138-Z142
- `.vscode/`
  jer je to izvan-scope lokalni editor artefakt i ne smije ulaziti ni u jedan
  dokumentacijski commit Z138-Z142

## PREDLOŽENI REDOSLIJED ZATVARANJA NA GITHUB

Predlozeni redoslijed je:

1. Najprije dokazno iskljuciti `.vscode/` i
   `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` iz buduceg niza Z138-Z142.
2. Zatim zatvoriti Z138 kao inventurni korak.
3. Nakon toga zatvoriti Z139 kao glavni kanonski obrazac.
4. Zatim zatvoriti Z140 kao analizu lokalno/remote stanja.
5. Potom zatvoriti Z141 kao analizu dovoljnosti.
6. Na kraju zatvoriti Z142 kao uski zavrsni odgovor `DA`.

Taj redoslijed prati stvarnu logiku sadrzaja: inventura prethodi glavnom
obrascu, analiza stanja prethodi procjeni dovoljnosti, a zavrsni odgovor dolazi
na samom kraju.

## TOČAN PRVI SCOPED COMMIT KOJI TREBA NAPRAVITI

Točan prvi scoped commit koji treba napraviti nije Z142, nego Z138.

Njegov cisti scope treba biti:

- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- samo Z138 hunkovi iz `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- samo Z138 hunkovi iz `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`
- samo Z138 append-only unos iz `dokumentacija/DNEVNIK_RADA.md`

Predlozena commit poruka je:

- `docs: inventura obrasca zakoni s amandmanima (Z138)`

Ako se taj commit radi iz trenutasnog radnog stabla, prije commita je nuzno
parcijalno izdvojiti samo Z138 tragove iz zajednickih datoteka, jer su one sada
vec lokalno pomijesane sa Z139-Z142.
