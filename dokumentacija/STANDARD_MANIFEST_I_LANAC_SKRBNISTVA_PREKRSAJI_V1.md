# STANDARD — MANIFEST I LANAC SKRBNIŠTVA PREKRŠAJI (v1)

Datum: 17.07.2026.
Oznaka: STANDARD_MANIFEST_I_LANAC_SKRBNISTVA_PREKRSAJI_V1
Status: KANON za P8 prvog toka u javnom i lokalnom režimu

## 1. Svrha

Ovaj standard određuje dokazni paket P8 za prekršajni tok. Paket povezuje
ulaze, referencirane dokaze, pravna sidra, postupak, predložak, generirani
audit i P7 nacrt pomoću SHA-256 sažetaka.

P8 dokazuje identitet i integritet uključenih bajtova. Ne dokazuje pravnu
točnost, ne zamjenjuje ljudski pregled, ne potpisuje dokument i ne odobrava
vanjsko slanje.

U razvojnom planu oznaka P8 označava ovu fazu dokaznog paketa. Ona nije isto
što i modul M8, koji ostaje gate vanjskog izlaza.

## 2. Opseg v1

V1 je funkcionalan samo za:

- tok `TOK_PN_PRIGOVOR`;
- verziju toka `v1`;
- javni sintetički ili lokalni povjerljivi predmet;
- tekstualni P7 nacrt bez potpisa.

Lokalni režim tehnički je dokazan isključivo sintetičkim sadržajem. Ovaj
standard sam po sebi ne odobrava početak rada na stvarnom predmetu.

Ostali prekršajni tokovi mogu imati strukturne reference, ali ne smiju dobiti
P8 artefakte dok nemaju vlastiti dokazani P7 prolaz.

## 3. Kanonske putanje

Postupak koji podržava P8 deklarira ove izlaze:

- `manifest_ref`:
  `predmeti/sud/prekrsajni/{PREDMET_ID}/manifest.json`;
- `lanac_skrbnistva_ref`:
  `predmeti/sud/prekrsajni/{PREDMET_ID}/lanac_skrbnistva.json`.

Oznaka `{PREDMET_ID}` razrješava se istim sigurnosnim pravilima kao P7
reference. Postupak, predložak i pravne norme uvijek se razrješavaju unutar
repozitorija. Predmetni ulazi i izlazi razrješavaju se:

- unutar repozitorija za javni sintetički režim;
- pod odobrenim `VERITAS_LOCAL_DATA_ROOT` izvan repozitorija za lokalni
  povjerljivi režim.

Apsolutne reference, `..`, prelazak u drugi predmet i izlazak iz pripadnog
korijena nisu dopušteni. Manifest i lanac spremaju samo kanonske relativne
reference. Fizička lokalna putanja ne smije se spremiti u paket ni ispisati
u izvršnom rezultatu.

## 4. Obavezni artefakti manifesta

Manifest ih navodi ovim redom:

1. `predmet` — `predmet_ref`;
2. `intake` — `intake_ref`;
3. `subsumcija` — `subsumcija_ref`;
4. `dokaz_001`, `dokaz_002`, ... — svaka jedinstvena neprazna referenca iz
   `elementi_bica[].dokaz_ref`, redom prvog pojavljivanja;
5. `audit_generated` — `audit_ref`;
6. `postupak` — aktivni `postupak.json`;
7. `predlozak` — `predlozak_ref`;
8. `norma_001`, `norma_002`, ... — svaki član `norma_refs` istim redom;
9. `nacrt` — `nacrt_ref`.

Prvi tok ima deset osnovnih artefakata i po jedan dodatni artefakt za svaku
jedinstvenu referenciranu dokaznu datoteku. Ogledni predmet zato ima ukupno
jedanaest artefakata. Direktorij nije artefakt i ne hashira se kao zamjena
za pojedinačnu datoteku.

Dokazna referenca mora biti kanonska relativna putanja unutar mape
`predmeti/sud/prekrsajni/<PREDMET_ID>/dokazi/` aktivnog predmeta. Fixture
referenca dopuštena u testnoj subsumpciji nije dopuštena kao P8 artefakt.

Svaki zapis sadrži:

- `redni_broj`;
- stabilni `id`;
- `uloga`;
- kanonsku relativnu `putanja` s kosom crtom `/`;
- `sha256` kao 64 velika heksadecimalna znaka;
- `velicina_bajtova` stvarnog sadržaja datoteke.

Hash se računa nad izvornim bajtovima datoteke. Ne normaliziraju se novi
redci, kodiranje, JSON razmaci ni redoslijed ključeva.

## 5. Korijenski sažetak manifesta

Manifest ima `korijenski_sazetak.sha256`. Računa se nad UTF-8 zapisom bez BOM-a
koji za svaki artefakt sadrži jedan redak:

```text
redni_broj<TAB>id<TAB>uloga<TAB>putanja<TAB>sha256<TAB>velicina_bajtova<LF>
```

Redoslijed je onaj iz točke 4. Završni `<LF>` je obavezan. Tabulator, novi
redak i vodeći ili završni razmaci nisu dopušteni u tekstualnim poljima.

Manifest ne sadrži vlastiti hash ni hash lanca skrbništva. Time se izbjegava
kružna ovisnost.

## 6. Lanac skrbništva

Lanac sadrži:

- identitet predmeta, toka i verzije;
- relativnu putanju manifesta;
- SHA-256 stvarnih bajtova manifesta;
- broj artefakata i korijenski sažetak iz manifesta;
- najmanje dva kronološki zapisana događaja;
- završni sažetak događajnog lanca.

Obavezni događaji v1 su:

1. `ULAZI_PROVJERENI` — dokaz je korijenski sažetak manifesta;
2. `MANIFEST_ZAPISAN` — dokaz je SHA-256 datoteke manifesta.

Svaki događaj navodi tko, što i kada je napravio. Izvršitelj generatora je
`veritas_h77`, a vrijeme je lokalno vrijeme stvaranja s numeričkim pomakom
vremenske zone.

## 7. Hash-lanac događaja

Prvi događaj koristi 64 nule kao `prethodni_dogadaj_sha256`. Svaki sljedeći
događaj koristi `dogadaj_sha256` prethodnog događaja.

`dogadaj_sha256` računa se nad UTF-8 zapisom bez BOM-a:

```text
redni_broj<TAB>id<TAB>datum_vrijeme<TAB>izvrsitelj<TAB>radnja<TAB>
detalj<TAB>dokaz_sha256<TAB>prethodni_dogadaj_sha256<LF>
```

Prijelom u prikazu služi samo čitljivosti; hashira se jedan logički redak.

`zavrsni_dogadaj_sha256` mora biti jednak sažetku zadnjeg događaja.

## 8. Tvrde blokade

Generator prije rada uklanja postojeći manifest i lanac. Ne smije ostaviti
ni jedan P8 izlaz ako vrijedi bilo što od sljedećeg:

- tok, verzija ili vrsta predmeta nisu dopušteni u v1;
- nedostaje bilo koji obavezni artefakt;
- nedostaje ili je izvan predmetne mape bilo koji referencirani dokaz;
- identitet predmeta, intakea, subsumpcije ili audita nije usklađen;
- audit je blokiran ili nema sva puna pravna sidra iz postupka;
- P7 nacrt ne prolazi svoj validator;
- putanja je apsolutna, nerazriješena, prelazi u drugi predmet ili izlazi iz
  pripadnog javnog odnosno lokalnog korijena;
- identitet i privatnosni režim predmeta nisu usklađeni s odabranim
  korijenom;
- manifest ili lanac ne prolaze vlastitu shemu i strogu provjeru.

Validator pri bilo kojoj nepodudarnosti također uklanja oba P8 izlaza. Time
zastarjeli dokazni paket ne može preživjeti izmjenu ranijeg artefakta.

## 9. Atomsko pisanje

Generator najprije potpuno provjerava ulaze. Manifest i lanac pišu se preko
privremenih datoteka u istoj mapi te se tek zatim premještaju na kanonske
putanje. Ako bilo koji korak ne uspije, brišu se obje privremene i obje
kanonske P8 datoteke.

## 10. Uvjet prolaza

P8 je `PROLAZ` samo ako:

- obje JSON sheme prolaze;
- strogi validator ponovno izračuna svaki hash, veličinu, korijenski sažetak
  i događajni hash-lanac;
- identitet i popis artefakata odgovaraju aktivnom postupku;
- javni paket nema stvarnih osobnih podataka, a lokalni paket ostaje izvan
  Git praćenja i ne otkriva fizičku putanju;
- nema potpisa ni samostalnog vanjskog slanja;
- negativni testovi potvrde uklanjanje oba izlaza.

Rezultat `P8_PROLAZ` znači samo da je paket spreman za ljudski pregled.
