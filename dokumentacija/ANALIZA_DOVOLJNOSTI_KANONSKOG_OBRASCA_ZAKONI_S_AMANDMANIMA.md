# ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA

Datum: 31.03.2026.
Status: radni analiticki presjek
Opseg: dokazna procjena je li postojeci kanonski obrazac za zakone s
amandmanima vec operativno dovoljan kao glavni dokument, bez commita,
bez pusha i bez diranja zakona, sidara, normi i alata.

---

## 1) Sto stvarno vec postoji kao kanonski skup

Kao stvarno postojeci kanonski dijelovi obrasca vec postoje:

- `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`
- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
- `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
- `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
- `alati/ingest_paket.ps1`
- `alati/parsiraj_nn_html.py`
- `alati/validiraj_nn_vs_kontrolno.py`

To znaci da vec postoji cijeli funkcionalni lanac:

- odluka kada zakon ide po modelu `core + amandmani`
- minimalna logika manifesta i tipa teksta u ingest toku
- NN dokazni sloj i ELI PDF fallback
- odvajanje `norme/` i `sidra/`
- validator s tvrdim fail signalima i toleriranim odstupanjima
- zavrsni primjer za jedan stvarno dovrsen zakon

Drugim rijecima, ne nedostaje mehanizam rada. Nedostaje samo potpuna
jasnoca hijerarhije medu dokumentima.

## 2) Sto je jos uvijek rasprseno

Rasprsene nisu osnovne cinjenice, nego njihova raspodjela po dokumentima.

Glavni dokument
`dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
vec pokriva operativni tijek od ulaza do zavrsnog izvjestaja, ali tri
bitne cjeline jos zive izvan njega:

- odluka o konkretnom rezimu jos je dokazno pokazana kroz zasebni rezim
  dokument
- tumacenje amandmanske validacije i toleriranih odstupanja ostaje u
  specijaliziranom obrascu za ZPD amandmane
- dokaz da je obrazac stvarno izvediv i zatvoren ostaje u zavrsnom ZPD
  izvjestaju kao konkretnom primjeru

Uz to je inventura i dalje prisutna kao prijelazni analiticki dokument koji
objasnjava zasto je objedinjeni obrazac uopce bio potreban.

## 3) Sto jos nedostaje za operativnu dovoljnost

Za operativnu dovoljnost ne nedostaju novi alati, nova pravila ni novi
repo artefakti.

Nedostaje samo eksplicitna urednicka razdioba uloga:

1. da je `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` glavni opci
   standard
2. da `OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md` ostaje uski
   specijalizirani dodatak za tumacenje validacijskih ishoda amandmana
3. da `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` ostaje dokazni primjer,
   a ne opci standard
4. da `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md` ostaje prijelazni
   analiticki trag, a ne trajna jezgra kanona

Bez te razdiobe glavni obrazac je sadrzajno jak, ali jos nije do kraja
samodostatan kao jedino mjesto za tumacenje cijelog obrasca.

## 4) Je li postojeci kanonski obrazac dovoljan kao glavni dokument

Odgovor je: da, ali uz jedan mali urednicki uvjet.

Sadrzajno je
`dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
vec dovoljno jak da bude glavni kanonski dokument jer vec sadrzi:

- svrhu i opseg
- kriterij izbora modela `core + amandmani`
- minimalni skup ulaznih artefakata
- pravila za NN i `zakon.hr` sloj
- razdvajanje `norme/` i `sidra/`
- redoslijed rada
- kriterije prolaza i tolerirana odstupanja
- zavrsne izlaze i zabrane

Medutim, nije jos sasvim dovoljan kao potpuno samostalan dokument ako se
od njega ocekuje da sam objasni i vlastiti odnos prema inventuri,
specijaliziranom obrascu amandmanske validacije i konkretnom ZPD primjeru.

Zato je ispravan zakljucak:

- kao glavni kanonski dokument: da, dovoljan je
- kao jedini dokument koji bi sam nosio sve nijanse tumacenja: jos ne,
  bez kratkog urednickog pojasnjenja odnosa prema preostalim dokumentima

## 5) Sto treba ostati odvojeno, a sto treba skratiti

Dokumente ne treba mehanicki spajati u jedan veliki tekst.

Treba zadrzati ovu podjelu:

- `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` ostaje glavni opci
  standard
- `OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md` ostaje specijalizirani
  dodatak za validacijska tumacenja amandmana
- `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` ostaje konkretni dokazni
  primjer primjene obrasca
- `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md` treba ostati kraci prijelazni
  analiticki trag i ne treba ga dalje siriti

To znaci da ne treba spajati zavrsni ZPD izvjestaj ni amandmanski obrazac u
glavni kanon. Treba samo skratiti tezinu inventure na ulogu prijelaznog
objasnjenja i jasno reci da je glavni standard vec u novom kanonskom
obrascu.

## 6) Minimalni sljedeci korak

Minimalni sljedeci korak nije novi sadrzajni refaktor obrasca, nego jedna
uska urednicka dopuna glavnog kanonskog dokumenta ili njegove okolne mape.

Najmanji dovoljan korak je:

- eksplicitno upisati da je
  `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` glavni opci standard
- uz njega zadrzati inventuru kao prijelazni trag, amandmanski obrazac kao
  specijalizirani dodatak i ZPD izvjestaj kao dokazni primjer

Nakon te male razdiobe moze se reci da obrazac nije samo napisan, nego i
urednicki dovoljno jasno postavljen za operativnu uporabu.

## 7) Zakljucak

### VEĆ IMAMO

Imamo stvarni funkcionalni obrazac rada: rezim `core + amandmani`, ingest,
NN dokazni sloj, kontrolni `zakon.hr` sloj, pravila za `norme/` i `sidra`,
validator i konkretan dokazni primjer na ZPD-u.

### JOŠ NEDOSTAJE

Jos nedostaje samo potpuno eksplicitna hijerarhija medu dokumentima, tako da
se bez dvojbe vidi sto je glavni standard, sto je specijalizirani dodatak,
a sto prijelazna ili dokazna dokumentacija.

### JE LI POSTOJEĆI KANONSKI OBRAZAC DOVOLJAN

Da. Postojeci
`KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` je vec dovoljan kao glavni
kanonski dokument. Nije ga potrebno pretvarati u veci tekst niti u njega
mehanicki ugurati inventuru, ZPD primjer i specijalizirani amandmanski
obrazac.

### PREDLOŽENI MINIMALNI SLJEDEĆI KORAK

Napraviti samo usku urednicku potvrdu hijerarhije: glavni kanon ostaje
`KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`, inventura ostaje
prijelazni trag, amandmanski obrazac ostaje specijalizirani dodatak, a
zavrsni ZPD izvjestaj ostaje dokazni primjer.
