# STANDARD — PREDMET I PRIVATNOST PREKRŠAJI (v1)

Datum: 17.07.2026.
Oznaka: STANDARD_JSON_PREDMET_I_PRIVATNOST_PREKRSAJI_V1
Status: KANON za pripremu P9

## 1. Svrha

Ovaj standard određuje puni JSON ugovor prekršajnog predmeta i tehničke
granice između javnog sintetičkog primjera i stvarnog povjerljivog predmeta.

Cilj je spriječiti ulazak osobnih podataka i stvarnih dokaza u Git povijest.
Shema uređuje strukturu, a zasebni validator privatnosti provjerava sadržaj,
putanju i stanje Git indeksa.

## 2. Dva strogo odvojena režima

### Javni sintetički režim

Javni sintetički predmeti smiju biti Gitom praćeni samo pod:

`predmeti/sud/prekrsajni/OGLEDNI_<ID>/`

Obavezne oznake su:

- `meta.vrsta=sinteticki`;
- `meta.rezim_podataka=javni_sinteticki`;
- `privatnost.klasifikacija=JAVNO_SINTETICKI`;
- `privatnost.sadrzi_osobne_podatke=false`;
- `privatnost.dopusteno_git_pracenje=true`.

Vrijednosti nositelja koje bi mogle biti osobni podatak moraju biti `null`.
Interna oznaka mora počinjati s `SINTETICKI_`.

### Lokalni povjerljivi režim

Stvarni predmeti smiju postojati samo u lokalnom korijenu koji određuje
varijabla okruženja `VERITAS_LOCAL_DATA_ROOT`.

Korijen mora biti:

- apsolutna lokalna putanja;
- izvan korijena Git repozitorija;
- izvan mape koja se automatski javno sinkronizira;
- dostupan samo ovlaštenom vlasniku sustava.

Preporučeni raspored je:

```text
<VERITAS_LOCAL_DATA_ROOT>/predmeti/sud/prekrsajni/STVARNI_<ID>/
```

Obavezne oznake su:

- `meta.vrsta=stvarni`;
- `meta.rezim_podataka=lokalni_povjerljivi`;
- `privatnost.klasifikacija=LOKALNO_POVJERLJIVO`;
- `privatnost.sadrzi_osobne_podatke=true`;
- `privatnost.dopusteno_git_pracenje=false`.

Stvarni predmet, njegov manifest, hashovi, dokazi i izlazi ne smiju se
kopirati u repozitorij. Njihov sadržaj ne smije se ispisivati u CI log.

## 3. Karantenske Git zabrane

`.gitignore` mora blokirati najmanje:

- `.veritas_lokalno/`;
- `predmeti/sud/prekrsajni/STVARNI_*/`;
- `predmeti/sud/prekrsajni/PRIVATNI_*/`.

Te putanje nisu dopušteni radni korijen stvarnog predmeta. One su samo
obrana ako se povjerljivi sadržaj pogrešno smjesti unutar repozitorija.

Git ignoriranje nije dovoljno jer ga je moguće zaobići prisilnim dodavanjem.
Zato pre-commit i CI moraju provjeravati stvarni sadržaj Git indeksa.

## 4. Korijenski ključevi predmeta

`predmet.json` ima ove obavezne cjeline:

- `meta`;
- `nositelj`;
- `akt`;
- `obrada`;
- `privatnost`;
- `sud_naziv`;
- `napomena_nacrt`.

## 5. Meta

`meta` sadrži:

- `id_predmeta`;
- `vrsta`: `sinteticki` ili `stvarni`;
- `verzija`;
- `domena`, u v1 uvijek `prekrsajni`;
- `tok`;
- `datum_otvaranja` u formatu `DD.MM.YYYY.`;
- `status`: `nacrt`, `aktivan` ili `zatvoren`;
- `rezim_podataka`.

Identitet u JSON-u mora odgovarati nazivu mape predmeta.

## 6. Nositelj

`nositelj` sadrži:

- `oznaka` kao interni identifikator;
- `ime_prezime`;
- `oib`;
- `adresa`;
- `kontakt` s opcionalnim poljima `email` i `telefon`.

U javnom sintetičkom režimu sva polja osim `oznaka` moraju biti `null`.
Stvarne vrijednosti dopuštene su samo u lokalnom povjerljivom režimu.

## 7. Akt i obrada

`akt` sadrži:

- `vrsta`;
- `tijelo`;
- `broj`;
- `datum`;
- `datum_dostave`.

`obrada` sadrži:

- `cilj`;
- `pravni_lijek`;
- `rok`.

Prazna ili nepoznata vrijednost označava se s `null`; ne smije se izmišljati.
`sud_naziv` privremeno ostaje korijensko polje radi P7 kompatibilnosti i mora
biti jednak `akt.tijelo`.

## 8. Detekcija visokog rizika

Repozitorijski gate traži visokopouzdane obrasce u praćenim datotekama mape
`predmeti/`:

- valjani OIB;
- hrvatski IBAN;
- adresu e-pošte;
- međunarodni hrvatski telefonski broj.

Nalaz blokira commit i CI bez ispisa pronađene vrijednosti. Ovaj gate nije
potpuna klasifikacija osobnih podataka i ne zamjenjuje ljudski pregled.

## 9. Lokalni pre-commit gate

Repozitorij koristi `.githooks/pre-commit`. Instalacijski alat postavlja:

```text
git config --local core.hooksPath .githooks
```

Hook provjerava Git indeks, a ne samo radnu kopiju. Time staged povjerljivi
sadržaj ne može biti skriven kasnijom izmjenom datoteke u radnoj kopiji.

## 10. CI gate

Puni `ci_smoke` mora:

1. validirati svaki praćeni `predmet.json` shemom;
2. potvrditi da su svi praćeni predmeti javni i sintetički;
3. potvrditi karantenska `.gitignore` pravila;
4. odbiti zabranjenu putanju ili visokorizični osobni identifikator;
5. provesti pozitivne i negativne testove bez stvarnih osobnih podataka.

## 11. Tvrde blokade P9

Prvi stvarni predmet ostaje blokiran ako nije ispunjeno bilo što od ovoga:

- lokalni korijen nije izričito određen i izvan repozitorija;
- pre-commit gate nije aktivan;
- CI gate privatnosti nije zelen;
- predmet ne prolazi punu shemu i strogi validator;
- postoji sumnja da su osobni podaci staged, praćeni ili javno sinkronizirani;
- vlasnik nije odobrio početak rada na konkretnom stvarnom predmetu.

## 12. Granica dokaza

Zeleni gate dokazuje da su poznate tehničke zabrane aktivne i da javni
primjeri zadovoljavaju ugovor. Ne dokazuje da nepoznati osobni podatak ne može
postojati. Kod sumnje objava se zaustavlja i odluku donosi čovjek.

## 13. Sigurna inicijalizacija lokalnog predmeta

Kanonski inicijalizator je:

`alati/inicijaliziraj_lokalni_predmet_prekrsaji_v1.ps1`

Obavezna pravila su:

- lokalni korijen i `STVARNI_<ID>` zadaju se izričito;
- podržani su samo `TOK_PN_PRIGOVOR` i `v1`;
- postojeći predmet nikada se ne prepisuje;
- stvara se predmetni kostur s mapama `dokazi`, `intake`, `audit` i
  `izlazi`;
- `predmet.json` nastaje kao nepopunjeni nacrt bez izmišljenih činjenica;
- rezultat nosi `P9_INIT_STATE=NEPOPUNJEN` i obavezu ljudskog pregleda;
- fizička putanja lokalnog korijena ne ispisuje se.

Inicijalizirani predmet nije odobren za obradu. Njegov status `nacrt`, prazna
sadržajna polja i nedostajući ulazi moraju blokirati P9 pokretač.

## 14. Jednonaredbeni lokalni tok

Kanonski lokalni pokretač je:

`alati/pokreni_lokalni_tok_p9_v1.ps1`

Pokretač za v1 zahtijeva ovaj dokazani ulazni skup unutar istog predmeta:

1. `predmet.json`;
2. `intake/intake_v1.json`;
3. `audit/subsumcija_v1.json`;
4. `audit/audit_v1.json` kao postojeći kontekst.

Prije obrade mora potvrditi aktivan `.githooks` privatnosni čuvar, zeleni
repo privatnosni gate, valjane sheme, usklađen identitet i popunjena obavezna
polja. Zatim izvodi:

`validator predmeta -> audit -> P7 nacrt -> P8 paket -> P8 validator`

Prije provjera uklanja samo poznate runtime izlaze aktivnog predmeta. Svaki
`STOP` ili tehnička pogreška završava s nula runtime izlaza, tako da stari
audit, nacrt, manifest ili lanac ne mogu izgledati kao rezultat trenutačnih
ulaza.

Uspješan rezultat mora potvrditi:

- točno četiri artefakta unutar lokalnog predmeta;
- samo kanonske reference u ispisu;
- `P9_RUN_PATHS_REDACTED=True`;
- `P9_RUN_HUMAN_REVIEW_REQUIRED=True`;
- `P9_RUN_SIGNED=False` i `P9_RUN_SENT=False`.

## 15. Otvoreni ugovorni nesklad

`SCHEMA_SUBSUMPCIJA_V1.json` koristi polje `status`, dok auditni standard i
generator u jednoj G3 provjeri traže polje `rezultat`. Postojeći dokazani v1
tok prolaz ostvaruje i preko nalaza `KOL-01` iz `audit_v1.json`.

Ovaj standard ne razrješava taj nesklad i ne bira tiho jednu varijantu.
Zato jednonaredbeni pokretač u ovoj verziji zahtijeva postojeći
`audit_v1.json`. Usklađenje `status` i `rezultat` mora biti zaseban odobreni
sadržajni paket s vlastitim fixtureima i provjerom auditne semantike.
