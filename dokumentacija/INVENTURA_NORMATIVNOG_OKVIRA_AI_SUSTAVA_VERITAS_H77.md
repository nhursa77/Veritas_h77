# INVENTURA NORMATIVNOG OKVIRA AI SUSTAVA VERITAS H.77

Datum provjere: 18.07.2026.
Status: radna dokazna inventura
Opseg: interne norme projekta te primjenjivi propisi Republike Hrvatske i
Europske unije za razvoj, provjeru, stavljanje u uporabu i uporabu sustava.

---

## 1) Svrha i granica zaključka

Ovaj dokument uspostavlja početni registar normativnih područja koja treba
provjeriti prije tvrdnje da je AI sustav Veritas H.77 sukladan za rad.

Dokument ne potvrđuje potpunu sukladnost sustava. Potpuna sukladnost smije se
utvrditi tek kada je za svaku primjenjivu tvrdu normu evidentirano:

1. službeno pravno ili kanonsko sidro;
2. razlog primjenjivosti na Veritas H.77;
3. konkretna obveza ili zabrana;
4. provedbeni mehanizam u dokumentaciji ili kodu;
5. pozitivni i negativni test, kada je strojna provjera moguća;
6. ljudska odluka, kada norma zahtijeva ljudsku procjenu;
7. dokazni zapis rezultata provjere.

Zeleni tehnički testovi nisu sami po sebi dokaz pravne ili sadržajne
točnosti. Nepostojanje testa nije dokaz da se norma ne primjenjuje.

---

## 2) Kanon izvora za ovu inventuru

Za propise Republike Hrvatske dokazni izvor je objava u Narodnim novinama.
Za pravo Europske unije dokazni izvor je EUR-Lex i autentični tekst objavljen
u Službenom listu Europske unije.

Konsolidirani prikazi služe za operativnu provjeru aktualnog teksta. Kada
službeni izvor ne sadrži službeni pročišćeni tekst, operativni tekst mora se
izvesti iz izvornog akta i svih izmjena te usporediti s kontrolnim izvorom.

`zakon.hr` može biti kontrolni izvor pročišćenog teksta. Ne može zamijeniti
Narodne novine kao dokaz objave, sadržaja izmjene ili stupanja na snagu.

---

## 3) Klasifikacija primjenjivosti

Svaki vanjski propis dobiva jedan od sljedećih statusa:

- `IZRAVNO`: obveza se primjenjuje na potvrđeni način rada sustava;
- `UVJETNO`: primjenjivost ovisi o načinu uporabe, korisniku ili distribuciji;
- `BUDUĆE`: propis je donesen, ali relevantna obveza još se ne primjenjuje;
- `NEPRIMJENJIVO`: postoji dokumentiran razlog isključenja iz opsega;
- `NEUTVRĐENO`: nedostaje činjenica potrebna za pravnu kvalifikaciju.

Status `NEPRIMJENJIVO` ne smije se dodijeliti prešutno. Mora sadržavati
službeno sidro i obrazloženje isključenja.

---

## 4) Klasifikacija snage i dokaza norme

Snaga interne ili izvedene norme označava se ovako:

- `TVRDI_GATE`: bez ispunjenja nema daljnje obrade ili vanjskog izlaza;
- `OBVEZNO`: norma mora biti ispunjena, ali ne mora biti strojni gate;
- `PREPORUKA`: kontrola dobre prakse koja nije proglašena obveznom;
- `INFORMATIVNO`: opis ili kontekst bez samostalne obveze.

Razina dokaza provedbe označava se ovako:

- `D0`: norma nije zapisana;
- `D1`: norma je zapisana u dokumentaciji;
- `D2`: postoji shema, validator ili drugi provedbeni mehanizam;
- `D3`: postoje pozitivni i negativni testovi;
- `D4`: provedba je uključena u CI ili drugi obvezni gate;
- `D5`: postoji dokaz ljudske provjere za konkretnu uporabu.

Razina `D4` ne zamjenjuje `D5` kada norma zahtijeva ljudsku odluku.

---

## 5) Područja koja moraju biti obuhvaćena

Normativna provjera dijeli se na pet odvojenih slojeva:

1. upravljanje AI sustavom i podjela odgovornosti;
2. osobni podaci, povjerljivost i kibernetička sigurnost;
3. izvori prava, dokazivost, dokumenti, potpisi i evidencije;
4. stavljanje sustava na tržište ili pružanje usluge korisnicima;
5. materijalni i postupovni propisi pojedinog pravnog modula.

Propis iz petog sloja ne smije se proglasiti općom normom cijelog sustava.
Njegova primjenjivost veže se uz konkretni modul, vrstu predmeta i datum.

---

## 6) Početni registar vanjskih izvora

### 6.1 Umjetna inteligencija i temeljna prava

1. Uredba (EU) 2024/1689 o umjetnoj inteligenciji.
   Status: `IZRAVNO` za opće odredbe i AI pismenost; ostale obveze ovise o
   ulozi pružatelja ili subjekta koji uvodi sustav te o klasifikaciji rizika.
   Posebno se provjeravaju članci 4., 5., 16., 26., 27., 50. i 113. te
   Prilog III. točka 8.
   Izvor: <https://eur-lex.europa.eu/eli/reg/2024/1689/oj>

2. Povelja Europske unije o temeljnim pravima.
   Status: `UVJETNO`, kada je rad Veritasa u području primjene prava Unije.
   Posebno se provjeravaju zaštita podataka, zabrana diskriminacije,
   djelotvoran pravni lijek, pošteno suđenje i prava obrane.
   Izvor: <https://eur-lex.europa.eu/eli/treaty/char_2012/oj>

3. Europska konvencija za zaštitu ljudskih prava i temeljnih sloboda.
   Status: `UVJETNO` kao obveza javne vlasti i normativni okvir pravnih
   postupaka u kojima se Veritasov izlaz upotrebljava. Posebno se
   provjeravaju članci 6., 8., 13. i 14.
   Izvor: <https://www.echr.coe.int/european-convention-on-human-rights>

4. Ustav Republike Hrvatske.
   Status: `UVJETNO` prema nositelju, funkciji i pravnom učinku uporabe te
   `OBVEZNO` kao najviši domaći kontrolni okvir Veritasovih pravnih modula.
   Operativni paket mora sadržavati izvorni tekst i sve relevantne izmjene,
   a dokazna sidra moraju voditi na Narodne novine.
   Službeni pročišćeni tekst NN 85/2010:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2010_07_85_2422.html>
   Naknadna promjena potvrđena odlukom NN 5/2014:
   <https://narodne-novine.nn.hr/eli/sluzbeni/2014/5/93>

5. Zakon o suzbijanju diskriminacije.
   Status: `UVJETNO`, a primjenjuje se kada izlaz, funkcija ili pružanje
   usluge može osobu staviti u nepovoljniji položaj u području iz Zakona.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2008_07_85_2728.html>

### 6.2 Osobni podaci i povjerljivost

1. Uredba (EU) 2016/679, Opća uredba o zaštiti podataka.
   Status: `IZRAVNO` kada Veritas obrađuje osobne podatke.
   Posebno se provjeravaju članci 5., 6., 9., 13. do 15., 22., 25., 30.,
   32., 35. i 44. do 49.
   Izvor: <https://eur-lex.europa.eu/eli/reg/2016/679/oj>

2. Zakon o provedbi Opće uredbe o zaštiti podataka.
   Status: `IZRAVNO` za obradu osobnih podataka u Republici Hrvatskoj.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2018_05_42_805.html>

3. Direktiva (EU) 2016/680 i hrvatski provedbeni zakon.
   Status: `UVJETNO`, ako Veritas upotrebljava nadležno tijelo radi
   sprečavanja, istrage, otkrivanja ili progona kaznenih djela.
   Izvor: <https://eur-lex.europa.eu/eli/dir/2016/680/oj>
   Hrvatski izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2018_07_68_1391.html>

### 6.3 Kibernetička sigurnost i sigurnost proizvoda

1. Zakon o kibernetičkoj sigurnosti, NN 14/2024.
   Status: `NEUTVRĐENO`; ovisi o kategorizaciji vlasnika ili korisnika kao
   ključnog ili važnog subjekta i o uslugama koje pruža.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2024_02_14_254.html>

2. Uredba (EU) 2024/2847 o kibernetičkoj otpornosti.
   Status: `BUDUĆE` i `UVJETNO`; relevantna je ako se Veritas kao proizvod s
   digitalnim elementima stavlja na tržište. Pojedine odredbe primjenjuju se
   prije općeg datuma 11.12.2027.
   Izvor: <https://eur-lex.europa.eu/eli/reg/2024/2847/oj>

3. Direktiva (EU) 2024/2853 o odgovornosti za neispravne proizvode.
   Status: `BUDUĆE` i `UVJETNO`; softver i AI sustavi obuhvaćeni su pojmom
   proizvoda, a nacionalni prijenos i datum primjene treba pratiti.
   Izvor: <https://eur-lex.europa.eu/eli/dir/2024/2853/oj>

4. Kazneni zakon, članak 215.a uveden izmjenama NN 136/2025.
   Status: `IZRAVNO` kao opća granica razvoja, testiranja, nadzora,
   upravljanja i uporabe AI sustava kada se izazove propisana opasnost.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2025_11_136_2018.html>

### 6.4 Elektronički dokumenti, identitet i evidencije

1. Uredba (EU) br. 910/2014, eIDAS, s važećim izmjenama.
   Status: `UVJETNO`; primjenjuje se na elektroničku identifikaciju, potpise,
   pečate, vremenske žigove i usluge povjerenja koje Veritas koristi.
   Konsolidirani službeni prikaz:
   <https://eur-lex.europa.eu/eli/reg/2014/910/2024-10-18>

2. Zakon o provedbi Uredbe (EU) br. 910/2014, NN 62/2017.
   Status: `UVJETNO` uz uporabu potpisa ili elektroničke identifikacije.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2017_06_62_1430.html>

3. Zakon o elektroničkoj ispravi, NN 150/2005.
   Status: `UVJETNO`; primjenjivost ovisi o pravnoj ulozi generiranog zapisa.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2005_12_150_2898.html>

4. Zakon o arhivskom gradivu i arhivima s važećim izmjenama.
   Status: `UVJETNO`, osobito za javno dokumentarno gradivo i javna tijela.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2018_07_61_1265.html>

5. Zakon o pravu na pristup informacijama s važećim izmjenama.
   Status: `UVJETNO`, ako je vlasnik ili korisnik tijelo javne vlasti.
   Primjenjivost uključuje ponovnu uporabu informacija javnog sektora.

### 6.5 Autorsko pravo, podaci i izvori

1. Zakon o autorskom pravu i srodnim pravima, NN 111/2021.
   Status: `IZRAVNO` za korištenje zaštićenih tekstova, računalnih programa i
   baza podataka. Za rudarenje teksta i podataka posebno se provjeravaju
   članci 187. i 188., zakonit pristup i pridržaj prava.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2021_10_111_1941.html>

2. Direktiva (EU) 2019/790 o autorskom pravu na jedinstvenom digitalnom
   tržištu.
   Status: `IZRAVNO` kroz hrvatski provedbeni zakon i `UVJETNO` za dodatne
   prekogranične odnose.
   Izvor: <https://eur-lex.europa.eu/eli/dir/2019/790/oj>

3. Uredba (EU) 2023/2854 o podacima.
   Status: `NEUTVRĐENO`; treba dokazati ulazi li konkretna funkcija Veritasa
   u područje povezanih proizvoda, povezanih usluga ili usluga obrade
   podataka.
   Izvor: <https://eur-lex.europa.eu/eli/reg/2023/2854/oj>

### 6.6 Pristupačnost, tržište i pružanje usluge

1. Zakon o zahtjevima za pristupačnost proizvoda i usluga, NN 89/2025.
   Status: `UVJETNO`; ovisi o vrsti proizvoda ili usluge, tržišnom modelu i
   mogućoj iznimci za mikro subjekt koji pruža usluge.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2025_06_89_1231.html>

2. Zakon o zaštiti potrošača s važećim izmjenama.
   Status: `UVJETNO`, ako se Veritas nudi potrošačima kao naplatna usluga.
   Temeljni izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2022_02_19_203.html>
   Posljednja utvrđena izmjena u ovoj inventuri, NN 59/2026:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2026_06_59_728.html>

3. Zakon o elektroničkoj trgovini s važećim izmjenama.
   Status: `UVJETNO`, ako se pruža usluga informacijskog društva.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2003_10_173_2504.html>

4. Zakon o odvjetništvu s važećim izmjenama i pravila pružanja pravne pomoći.
   Status: `UVJETNO`; planirana javna uporaba zahtijeva razgraničenje opće
   pravne informacije, individualiziranog pravnog savjeta, zastupanja i
   drugih rezerviranih ili uređenih oblika pravne pomoći.
   Izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/1994_02_9_157.html>

5. Zakon o besplatnoj pravnoj pomoći s važećim izmjenama.
   Status: `UVJETNO`; aktivira se ako planirani nositelj kao udruga pruža
   primarnu pravnu pomoć. Prije takve uporabe moraju se provjeriti status
   ovlaštene udruge, upis u registar, stručna suradnja, osiguranje od
   odgovornosti i ostale važeće pretpostavke.
   Temeljni izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2013_12_143_3064.html>
   Utvrđena izmjena NN 98/2019:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/full/2019_10_98_1920.html>
   Službeni pregled Ministarstva:
   <https://mpudt.gov.hr/besplatna-pravna-pomoc-6184/6184?big=1>

6. Zakon o udrugama s važećim izmjenama.
   Status: `IZRAVNO` za osnivanje, ustroj i djelovanje planiranog nositelja,
   nakon što se potvrdi odluka o osnivanju udruge `Hrvatski narod`.
   Temeljni izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2014_06_74_1390.html>
   Utvrđena izmjena NN 151/2022:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2022_12_151_2346.html>

### 6.7 Granice pravnih modula i lišenje slobode

1. Prekršajni zakon s važećim izmjenama.
   Status: `IZRAVNO` za prekršajni modul. Budući da prekršajno pravo može
   sadržavati kaznu zatvora i druge oblike lišenja slobode, naziv modula nije
   dovoljan za dopuštanje obrade. Potreban je gate po konkretnom predmetu,
   sankciji i svim mjerodavnim propisima.
   Temeljni izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2007_10_107_3125.html>

2. Zakon o izvršavanju kazne zatvora s važećim izmjenama.
   Status: `UVJETNO` kao kontrolni izvor za prepoznavanje isključenog opsega,
   uključujući zatvor izrečen u prekršajnom postupku i zamjenu novčane kazne.
   Veritas ne vodi postupak uređen tim propisom.
   Temeljni izvor:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2021_02_14_270.html>

3. Ustavni zakon o Ustavnom sudu Republike Hrvatske s važećim izmjenama.
   Status: `IZRAVNO` za određivanje dopuštenog proceduralnog puta ustavne
   kontrole. Veritas smije označiti moguću neusklađenost i pripremiti nacrt,
   ali ne smije preuzeti ovlast Ustavnog suda niti proglasiti propis
   neustavnim.
   Službeni pročišćeni tekst NN 49/2002:
   <https://narodne-novine.nn.hr/clanci/sluzbeni/2002_05_49_967.html>

4. Materijalni i postupovni propisi konkretnog predmeta.
   Status: `TVRDI_GATE`. Prije obrade mora se utvrditi može li bilo koji
   primjenjivi propis dovesti do zatvora, zamjenskog zatvora, uhićenja,
   zadržavanja, pritvora ili druge mjere lišenja slobode. Ako se to ne može
   pouzdano isključiti, Veritas zaustavlja obradu.

---

## 7) Materijalni i postupovni propisi po modulima

Svaki pravni modul mora imati vlastiti registar propisa i vremensku verziju.
Opći AI standard mora propisati način njihove obrade, ali ne smije zamijeniti
njihov sadržaj.

Za prekršajni modul najmanje se provjeravaju propisi koji uređuju:

- materijalno prekršajno pravo;
- prekršajni postupak;
- dostavu, rokove i pravne lijekove;
- dokazivanje i prava obrane;
- elektroničku komunikaciju s nadležnim tijelima;
- izvršenje i troškove postupka;
- posebni propis koji određuje konkretni prekršaj.

Isti obrazac mora se ponoviti za upravni, upravnosudski, građanski i svaki
budući dopušteni modul. Kazneni modul nije u dopuštenom opsegu. Niti jedan
modul nije normativno potpun samo zato što je njegov tehnički tok izvršiv.

Opseg "svi zakoni i propisi" provodi se kao obveza potpunog registra za
svaki konkretni modul i predmet. Ne smije se zamijeniti jednim unaprijed
zatvorenim popisom. Prije vanjskog izlaza registar mora obuhvatiti sve
mjerodavne materijalne, postupovne, izvršne, prijelazne i provedbene norme
te njihove vremenski važeće izmjene.

---

## 8) Početni nalazi u repozitoriju

1. Ljudska odluka, zabrana samostalnog slanja i potpisna kontrola zapisane
   su u više kanonskih dokumenata.
2. NN gate postoji u dokumentaciji i dijelu aktivnog prekršajnog toka.
3. Uloga `zakon.hr` usklađena je 18.07.2026.: NN je dokazni izvor, Veritasov
   izvedeni tekst operativni sloj, a `zakon.hr` kontrolni izvor.
4. Privatnost ima dokument, validator, negativne testove, Git hook i CI gate.
5. Osam od devet korijenskih JSON shema nema izričitu zabranu dodatnih polja.
6. Generički schema-driven validator ne provodi `additionalProperties`.
7. Ne postoji jedinstveni registar norma–provedba–test–CI.
8. Ne postoji automatska kontrola standardnog hrvatskog jezika i odobrene
   terminologije.
9. Aktivni kanonski i povijesni analitički dokumenti nisu svugdje označeni
   jedinstvenim metapodacima životnog ciklusa.
10. Ne postoji potpuni registar vanjskih propisa s datumom posljednje provjere.

Početna ocjena sustava zato je `DJELOMIČNO SUKLADNO / NEDOVOLJNO DOKAZA`.
Ta oznaka nije završna pravna ocjena.

---

## 9) Utvrđene i otvorene činjenice o uporabi

### 9.1 Utvrđene projektne odluke

1. Planirani nositelj je udruga `Hrvatski narod`.
2. Upis udruge, formalno vlasništvo i svojstvo pružatelja još nisu dokazani.
3. Sustav je planiran za uporabu svih zainteresiranih osoba.
4. Kazneno pravo i kazneni postupci isključeni su iz opsega.
5. Isključen je svaki predmet u kojem je moguća kazna zatvora, zamjenski
   zatvor ili druga mjera lišenja slobode.
6. Veritas ne daje autoritativno tumačenje i ne odlučuje o ustavnosti.
   Provodi izvorno sidrenu analizu moguće neusklađenosti i priprema nacrt za
   ljudsku odluku ili postupanje nadležnog tijela.
7. Stvarni predmeti i osobni podaci zasad ostaju u lokalnom okruženju.
   Vanjskom modelu dopušteni su samo sintetički ili nepovratno anonimizirani
   podaci dok se ne zatvore svi pravni, ugovorni i sigurnosni uvjeti.

### 9.2 Činjenice koje još treba utvrditi

Prije konačne klasifikacije primjenjivosti moraju se dokumentirati:

1. hoće li planirana udruga biti samo nositelj sustava ili i pružatelj
   pravne pomoći;
2. pravni status udruge, statut, ovlaštene osobe i formalno vlasništvo;
3. stavlja li se sustav na tržište i naplaćuje li se;
4. dopuštene kategorije korisnika, uključujući odvjetnike i javna tijela;
5. lokalni, mrežni i oblačni dijelovi obrade;
6. svaki prijenos podataka izvan Europskoga gospodarskog prostora;
7. kategorije osobnih, posebnih i kaznenopravnih podataka;
8. rokovi čuvanja, brisanja i arhiviranja;
9. koristi li se izlaz za odluku koja proizvodi pravni učinak;
10. obučava li se ili prilagođava model na sadržaju trećih osoba;
11. koje su funkcije javno dostupne i komuniciraju izravno s korisnikom;
12. može li sustav ikada biti korišten u ime suda ili drugog javnog tijela.

Dok se ne odluči drukčije, odgovor na točku 12. je operativno `NE`: uporaba
u ime suda ili drugog tijela javne vlasti nije dopuštena.

### 9.3 Tvrdi gate vanjske obrade podataka

Sirovi stvarni predmet, osobni podaci, posebne kategorije podataka i podaci
o kažnjivim djelima ne smiju se poslati ChatGPT-u, Codexu, drugom API-ju ili
drugom vanjskom izvršitelju obrade.

Iznimka se smije razmatrati tek kada su dokumentirani i odobreni najmanje:

1. voditelj i izvršitelj obrade te njihove uloge;
2. svrha, pravna osnova i nužnost svake kategorije podataka;
3. minimizacija, rok čuvanja i provjerljivo brisanje;
4. procjena učinka na zaštitu podataka kada je potrebna;
5. ugovor o obradi i popis podizvršitelja;
6. lokacije obrade i pravna osnova svakog međunarodnog prijenosa;
7. sigurnosne postavke, zabrana obuke na sadržaju i upravljanje incidentima;
8. ljudsko odobrenje i audit zapis konkretnog prijenosa.

Pseudonimizacija sama po sebi nije anonimizacija i ne otvara gate.

Dok te činjenice nisu utvrđene, uvjetni propisi ostaju u registru i ne smiju
se proglasiti neprimjenjivima.

---

## 10) Sljedeći dokazni artefakti

Na temelju ove inventure izrađuju se:

1. strojno čitljiv registar pojedinačnih normi;
2. matrica `norma → dokument → kod → test → CI → ljudska odluka`;
3. izvještaj proturječja i zastarjelih odredbi;
4. odluke o primjenjivosti uvjetnih propisa;
5. kanonski Veritas H.77 AI Standard;
6. validatori i negativni testovi za tvrde gateove;
7. periodični postupak praćenja izmjena propisa.

Potpuna sukladnost smije se proglasiti tek nakon zatvaranja svih tvrdih
gateova i potvrde vlasnika za norme koje zahtijevaju ljudsku odluku.
