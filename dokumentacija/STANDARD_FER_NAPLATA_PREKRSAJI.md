STANDARD_FER_NAPLATA_PREKRSAJI_v1

Naziv: Standard fer naplate i zabrane naplate bez realne šanse
(Prekršajni modul)
Oznaka: STANDARD_FER_NAPLATA_PREKRSAJI_v1
Status: KANON (obavezno za sve tokove i sve izlazne dokumente u
prekršajnom modulu)
Primjena: Svi tokovi (tokovi/), svi predlošci (predlosci/), svi predmeti
(predmeti/*) koji uključuju naplatu ili isporuku izlaznog dokumenta
korisniku.
Cilj: Eliminirati “prodaju nade”, osigurati uštedu korisniku i zabraniti
naplatu dokumenta koji je proceduralno ili sadržajno bez realne šanse.

Temeljne postavke i hijerarhija ciljeva
1.1. Primarni cilj (ne pregovara se)
Primarni cilj Veritasa u prekršajnom modulu je ušteda ljudi (novac + vrijeme
+ rizik), a ne financijska zarada.

1.2. Aksiom zabrane naplate bez šanse
Nikad se ne smije naplatiti dokument ako:
(A) je pravni lijek proceduralno nedopušten ili rok propušten, ili
(B) ne postoji konkretna osporiva točka (činjenična ili proceduralna), ili
(C) ne postoji minimalni dokazni prag niti strategija pribave dokaza, a akt je
uredan i ne pruža proceduralnu grešku.

1.3. Što Veritas “prodaje”
Veritas ne prodaje “ishod” niti “pobjedu”. Veritas isporučuje:
proceduralno dopušten i formalno ispravan dokument,
sastavljen iz kanona (sidrišta NN + sidrišta primjene norme),
uz AUDIT trag koji objašnjava što je provjereno, kojim pravilom i s kojim
rezultatom.

Terminologija (rječnik pojmova)
Pojmovi se koriste točno ovako. Ako pojam nije ovdje definiran, ne smije ući u
kanon.

2.1. “Preflight”
Obavezna faza prije bilo kakve naplate ili generiranja naplatnog dokumenta.
Preflight daje odluku: ZELENO / ŽUTO / CRVENO.

2.2. “Izlazni dokument”
Dokument koji ide prema tijelu postupka ili kao pravni lijek / podnesak:
prigovor, žalba, očitovanje, dopuna, zahtjev za uvid/dostavu, itd.

2.3. “Naplatni dokument”
Izlazni dokument koji se korisniku isporučuje uz naplatu (mikro-naplatu ili
paket).

2.4. “Realna šansa”
U Veritas smislu znači: postoji racionalna, provjerljiva osnova da dokument
može ostvariti legitimni cilj (npr. poništenje, preinaka, obustava, vraćanje u
prijašnje stanje, izdvajanje dokaza, ublažavanje), jer su zadovoljeni:
proceduralni uvjeti (rok/dopuštenost),
postoji osporiva točka,
postoji dokaz ili strategija do dokaza ili proceduralna greška u samom aktu.

2.5. “Nema šanse”
Nije “sigurno gubiš”, nego: ne postoji provjerljiva osnova za pokretanje
pravnog lijeka bez samoozljeđivanja (gubitak pogodnosti, rizik troškova), jer
jedan od minimalnih pragova nije ispunjen.

2.6. “Strategija pribave dokaza”
Legitimna, izvediva radnja koja prethodi ili prati pravni lijek, npr. zahtjev
za uvid/spis, zahtjev za dostavu dokaza, zahtjev za dostavu
mjerenja/kalibracije, očitovanje o dostavi, itd. Strategija mora biti
konkretna, ne “možda negdje ima nešto”.

2.7. “Audit naplate”
Skup zapisa u AUDIT primjene koji mora sadržavati:
Preflight semafor,
rezultate gateova,
razloge odluke,
odluku o naplati (dopušteno/zabranjeno),
ponuđene alternative.

Obavezna pravila toka (pipeline pravilo)
3.1. Nema naplate bez Preflighta
U svakom toku vrijedi:
Intake → 2) Preflight → 3) Odluka naplate → 4) (Ako dopušteno)
Generiranje → 5) Validacija → 6) Isporuka.
Ako Preflight nije proveden ili nema rezultat → hard fail: tok se smatra
nevaljanim.

3.2. Nema generiranja naplatnog dokumenta bez dopuštenja naplate
Ako odluka naplate nije “dopušteno” → tok smije generirati samo:
besplatne informativne izlaze (rokovi/opcije), i/ili
alternativni nenaplatni / nisko-naplatni dokument koji je usmjeren na
pribavu dokaza (ako je to legitimno).

Gate model (tri vrata koja odlučuju o naplati)
Ovo je srce standarda. Sva tri gatea su obavezna. Svaki gate ima: ulaz,
provjeru, rezultat, audit zapis.

4.1. Gate 1 — Proceduralna dopuštenost
Ulazni minimum:
vrsta akta (npr. prekršajni nalog / obvezni prekršajni nalog / rješenje /
poziv / presuda),
datum uručenja / saznanja (prema režimu),
kanal uručenja (pošta, osobno, e-građani, oglasna ploča, itd.),
namjeravani pravni lijek (prigovor / žalba / drugo).

Provjere (deterministički):
(G1.1) Rok: je li rok unutar dopuštenog (račun prema kanonskim pravilima roka
u primjeni norme).
(G1.2) Dopuštenost: je li pravni lijek dopušten za tu vrstu akta i fazu.
(G1.3) Nadležnost/kanal: je li moguće definirati kamo dokument ide (tijelo /
sud / instanca).

Rezultat Gate 1:
PASS → ide Gate 2
FAIL → CRVENO (naplata zabranjena)

Audit obavezno bilježi:
unesene datume, izračun roka, pravilo izračuna, rezultat (u roku / van roka),
dopuštenost pravnog lijeka i sidrište primjene (koja norma/pravilo to
 definira).

4.2. Gate 2 — Minimalni činjenični prag
Ulazni minimum:
kratak opis događaja (što se dogodilo),
status korisnika u događaju (vozač / vlasnik / odgovorna osoba / prisutnost),
koje tvrdnje iz akta osporava (lista osporavanja).

Provjere:
(G2.1) Konzistentnost: nema unutarnjih kontradikcija u korisnikovim navodima
(npr. “nisam bio tamo” + “bio sam tamo ali…” bez objašnjenja).
(G2.2) Osporiva točka postoji: barem jedna od sljedećih mora biti istinita:
osporava identitet (tko je počinitelj),
osporava radnju (što je učinjeno),
osporava okolnosti (vrijeme/mjesto/uvjeti),
osporava dokaz (valjanost/izvedivost/veza s radnjom),
osporava proceduru (dostava, pouka, forma, proturječje u aktu),
osporava nadležnost (ako je primjenjivo).
(G2.3) Cilj je legitiman: korisnik mora izabrati cilj (npr. poništenje,
obustava, preinaka, izdvajanje dokaza, ublažavanje, vraćanje u prijašnje
stanje). “Žalim se jer mi se može” = FAIL.

Rezultat Gate 2:
PASS → ide Gate 3
FAIL → CRVENO (naplata zabranjena)

Audit obavezno bilježi:
koja osporiva točka je detektirana i na temelju kojih unosa,
detektirane kontradikcije i koje pravilo ih je označilo.

4.3. Gate 3 — Minimalni dokazni prag ili dokazna strategija
Gate 3 ima tri dopuštena puta. Jedan je dovoljan.

Put A: Postoje dokazi/prilozi
Uvjet: korisnik ima barem jedan relevantan dokaz/prilog koji podupire osporivu
točku.

Put B: Postoji izvediva strategija pribave dokaza
Uvjet: korisnik nema dokaz sada, ali postoji konkretna radnja koja može
pribaviti dokaz (npr. uvid/dostava/spis) i to je proceduralno izvedivo u
vremenu i režimu.

Put C: Proceduralna greška iz samog akta
Uvjet: iz samog akta ili njegovih metapodataka postoji uočljiva proceduralna
greška koja se može koristiti bez vanjskih dokaza (npr. formalni nedostaci,
proturječje, pogrešna pouka, nedostatak bitnog elementa).

Provjere:
(G3.1) Relevancija: dokaz/strategija/greška mora biti vezana uz osporivu točku
iz Gate 2 (ne “općenito”).
(G3.2) Izvedivost: strategija pribave dokaza mora imati definiran “sljedeći
korak” koji Veritas može isporučiti kao alternativu ili dio paketa.
(G3.3) Minimalna vrijednost: mora postojati racionalna veza između puta A/B/C i
cilja iz Gate 2.

Rezultat Gate 3:
PASS → Preflight može biti ZELENO ili ŽUTO (ovisno o riziku)
FAIL → CRVENO (naplata zabranjena)

Audit obavezno bilježi:
koji put (A/B/C) je korišten,
što je dokaz/strategija/greška,
zašto je relevantno (kratko, činjenično).

Semafor (ZELENO/ŽUTO/CRVENO) — precizna pravila
5.1. CRVENO (naplata zabranjena)
CRVENO se dodjeljuje ako je bilo koji od sljedećih uvjeta istinit:
CRV-1: Gate 1 FAIL (rok/dopuštenost/nadležnost)
CRV-2: Gate 2 FAIL (nema osporive točke / kontradikcije bez razrješenja /
nelogičan cilj)
CRV-3: Gate 3 FAIL (nema dokaza ni strategije ni proceduralne greške)
CRV-4: Korisnik eksplicitno priznaje ključnu činjenicu koja čini prekršaj, a
ne navodi proceduralnu grešku niti dokazno osporavanje (nema uporišta)
CRV-5: Uporaba “želja” bez činjenica (npr. “žalim se jer mi se može”)
CRV-6: Predmet je takav da bi podnošenje pravnog lijeka vjerojatno uzrokovalo
veću štetu korisniku (gubitak pogodnosti, povećanje ukupnog troška) bez osnove
koja to opravdava.
CRVENO = nema naplate, nema naplatnog dokumenta.

5.2. ZELENO (naplata dopuštena)
ZELENO se dodjeljuje kad su ispunjeni svi uvjeti:
Gate 1 PASS
Gate 2 PASS
Gate 3 PASS
rizik je nizak do umjeren, tj. postoji izvediva osnova i dokaz/strategija.

5.3. ŽUTO (naplata uvjetno dopuštena)
ŽUTO se dodjeljuje kad su gateovi PASS, ali postoji jedan ili više rizika:
ŽUT-1: dokaz postoji, ali je slab/indirektan
ŽUT-2: strategija pribave dokaza je jedina osnova, a rokovi su tijesni
ŽUT-3: postoji značajan rizik gubitka pogodnosti (npr. povoljnija
naplata/zaključenje bez postupka)
ŽUT-4: postoji realan rizik troškova postupka, a korist je mala
ŽUT-5: cilj je legitiman, ali šanse su ograničene bez dodatnih dokaza

Obavezno uz ŽUTO: “Risk Disclosure” izlaz
Ako je ŽUTO, Veritas mora isporučiti:
kratko objašnjenje rizika,
preporuku “prvo A pa onda B” (npr. prvo uvid/dostava),
alternativu (platiti / pribaviti / odustati), bez prodaje nade.

Pravila naplate (operativna zabrana i dopuštenje)
6.1. Stroga zabrana naplate
Naplatni dokument se ne smije isporučiti ako je Preflight CRVENO.

6.2. Dopuštenje naplate
Naplatni dokument se smije isporučiti samo ako je:
Preflight ZELENO, ili
Preflight ŽUTO i isporučen je “Risk Disclosure” te korisnik izričito potvrdi da
razumije rizike (kanonski mehanizam potvrde; ne mora biti “klik”, može biti
potvrda u toku).

6.3. Pravilo “ne prodajemo nadu”
Ako je predmet CRVENO ili ŽUTO s vrlo visokim rizikom, Veritas:
ne smije prodati žalbu/prigovor kao “rješenje”,
smije ponuditi alternativne dokumente fokusirane na pribavu dokaza ili
informaciju.

Obavezni izlazi po semaforu
7.1. ZELENO — obavezni izlazi
naplatni dokument (prigovor/žalba/podnesak)
audit zapis (gateovi PASS, razlozi, sidrišta)
lista priloga / dokaza (checklista)
upute za predaju (kanal, rok, adresat)

7.2. ŽUTO — obavezni izlazi
Sve iz ZELENO + obavezno:
“Risk Disclosure” (jasno, kratko, bez dramatike)
preporučeni slijed koraka (npr. prvo uvid/dostava → zatim podnesak)
alternativa: “zatvori postupak plaćanjem” gdje je primjenjivo

7.3. CRVENO — obavezni izlazi
objašnjenje koji gate je pao (G1/G2/G3) i konkretno zašto
besplatan informativni izlaz (rokovi/opcije)
alternativa: nisko-naplatni ili nenaplatni dokument za pribavu dokaza (ako
postoji strategija) ili checklista “što bi trebalo imati da postane
ŽUTO/ZELENO”

Refund / kredit (sigurnosni ventil)
8.1. Kada se aktivira refund/kredit
Ako se nakon isporuke pokaže da je predmet trebao biti CRVENO prema ovim
pravilima zbog:
pogrešno unešenog podatka koji sustav nije detektirao kao kontradikciju,
sistemske greške u izračunu roka,
pogrešne klasifikacije dopuštenosti.

8.2. Način
automatski kredit ili povrat (ovisno o kanonskoj politici naplate), bez
rasprave.

8.3. Audit
Refund/kredit mora imati audit zapis: razlog, koji gate bi trebao pasti,
korektivna mjera.

Anti-spam i zaštita sustava (bez dizanja cijena)
9.1. Preflight je besplatan, ali “output” je kontroliran
Preflight smije generirati informaciju i preporuku, ali ne smije generirati
naplatni dokument.

9.2. Minimalna cijena za izlazne dokumente (kad je dopušteno)
Mikro-naplata služi kao:
minimalna zaštita od spama,
ali ne smije biti barijera pravdi.

Ovdje se cijene ne kanoniziraju u ovom standardu; kanonizira se načelo i
zabrana naplate bez šanse. Cijene idu u zaseban
STANDARD_CIJENE_PREKRSAJI_v1.

Audit zahtjevi (obavezni zapisi)
Za svaki predmet i svaki pokušaj naplate mora postojati audit trag koji
minimalno sadrži:
identifikator predmeta
Preflight rezultat (Z/Ž/C)
Gate 1: PASS/FAIL + izračun roka + dopuštenost
Gate 2: PASS/FAIL + osporive točke + kontradikcije
Gate 3: PASS/FAIL + put A/B/C + dokaz/strategija/greška
odluka: naplata dopuštena / zabranjena
isporučeni izlazi (koji dokumenti, koje alternative)
(ako ŽUTO) Risk Disclosure isporučen: DA/NE

Test scenariji (kanonski primjeri)
Ovi scenariji služe kao misaoni “unit testovi” standarda. U implementaciji će
postati test-fixtures, ali ovdje ostaju kao kanonski primjeri.

11.1. CRVENO — rok propušten
Gate 1 FAIL → CRVENO → zabrana naplate → ponuditi informaciju i eventualno
alternativu (ako postoji iznimka/obnova, ali samo ako je dokazivo).

11.2. CRVENO — “žalim se jer mi se može”
Gate 2 FAIL (nema osporive točke/cilja) → CRVENO → zabrana naplate.

11.3. CRVENO — nema dokaza i nema puta do dokaza
Gate 3 FAIL → CRVENO → zabrana naplate → ponuditi checklistu što bi trebalo.

11.4. ŽUTO — dokaz slab, ali postoji proceduralna greška
Gateovi PASS, ali rizik visok → ŽUTO → naplata samo uz risk disclosure +
preporuka pribave/koraka.

11.5. ZELENO — jasna osporiva točka + dokaz
Gateovi PASS + dokaz relevantan → ZELENO → naplata dopuštena.

Granice i transparentnost (obavezne izjave sustava)
Veritas u svakom toku mora jasno komunicirati:
da ne jamči ishod,
da odluka o naplati nije “procjena sudca” nego rezultat gate pravila,
da je cilj spriječiti štetu korisniku (gubitak pogodnosti, troškovi, propušten
rok).

Operativni zaključak standarda
Ovaj standard uvodi deterministički mehanizam koji:
sprječava naplatu bez realne šanse,
forsira besplatni Preflight,
uvodi semafor odluke,
i traži audit trag za svaku odluku.

Time Veritas ostaje vjeran prioritetu: ušteda ljudima i proceduralna sigurnost,
bez prodaje nade.
