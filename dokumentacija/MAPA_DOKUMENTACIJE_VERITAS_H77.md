# MAPA_DOKUMENTACIJE_VERITAS_H77

Datum: 16.07.2026.
Status: kanonski
Opseg: navigacija kroz postojeću dokumentaciju Veritas H.77.

---

## 1) Kanon u 11 točaka

1) Jezik dokumentacije i zapisa je hrvatski.
2) Datumi se zapisuju u formatu `DD.MM.YYYY.`.
3) Ograničenje retka je MD013, najviše 80 znakova po retku.
4) Dokumenti imaju opisna imena datoteka.
5) Veritas generira isključivo na upit.
6) Veritas ne potpisuje i ne šalje.
7) Čovjek odlučuje o potpisu i slanju.
8) zakon.hr je operativni izvor, Narodne novine su dokazna sidra.
9) NORMA JSON i POSTUPAK JSON su obavezni standardi.
10) Svaki značajan korak evidentira se u `DNEVNIK_RADA.md`.
11) `DNEVNIK_RADA.md` je append-only i ne smije se prepisivati.

---

## 2) Kanonski dokumenti

### `AGENTS.md`
Korijenski upravljački dokument za rad AI agenata na projektu.
Definira uloge, granice ovlasti, odobravanje, privatnost i provjere.

### `METODOLOGIJA_RADA_VERITAS_H77.md`
Definira što je Veritas H.77, kako radi i gdje su granice odgovornosti.
Sadrži hijerarhiju normi, pravilo izvora i gate pravila statusa izlaza.

### `RJEČNIK_POJMOVA_VERITAS_H77.md`
Definira pojmove koji se koriste u dokumentima, JSON zapisima i obradi.
Osigurava jednoznačno značenje ključnih termina.

### `TEHNIČKI_OKVIR_VERITAS_H77.md`
Definira tehnički okvir rada repozitorija i reprodukcije okruženja.
Sadrži pravila artefakata, izvora, snapshota i kontrole kvalitete.

### `STANDARD_JSON_NORMA.md`
Definira standard zapisa norme u JSON formatu s člankom kao jedinicom.
Uređuje strukturu, izvore, sidra i uvjete valjanosti normativnog zapisa.

### `STANDARD_JSON_POSTUPAK.md`
Definira standard proceduralnih koraka u JSON formatu.
Uređuje gate uvjete, ulaze, radnje i izlaze postupanja.

### `STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
Definira standard ulaza (INTAKE) za prekršajne tokove v1.
Uređuje cilj, osporavanja, događaj i obavezna polja za validaciju.

### `STANDARD_JSON_AUDIT_PRIMJENE.md`
Definira kanonski audit primjene i statusne ishode po modulima.
Uređuje nalaze, gate stanje i mapiranje u izlazne nacrte.

### `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
Definira determinističko generiranje runtime audita za P6.
Uređuje NAP-MIN klase, semafor i G1 soft pravilo.

### `STANDARD_JSON_SUBSUMPCIJA.md`
Definira standard subsumpcije činjenica na norme i pravila.
Uređuje argumentaciju i poveznice na normativna sidra.

### `STANDARD_JSON_HIJERARHIJA.md`
Definira hijerarhiju normativnih izvora i pravila prvenstva.
Uređuje razrješenje kolizija i prioritet izvora.

### `STANDARD_JSON_PREDLOZAK.md`
Definira standard predložaka i mapiranja izvora u nacrt.
Uređuje dopuštene izvore, uključujući intake.* u mapiranjima.

### `STANDARD_FER_NAPLATA_PREKRSAJI.md`
Definira standard fer naplate u prekršajnom modulu.
Uređuje pravila obračuna i kontrolne uvjete naplate.

### `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
Definira obavezne markere i format izlaznog nacrta v1.
Uređuje minimalni sadržaj nacrta za validator izlaza.

### `RAZVOJNI_PLAN_VERITAS_H77.md`
Definira faze razvoja sustava, redoslijed rada i operativne gate uvjete.
Služi kao plan izvođenja od MVP-a do prvog živog predmeta.

### `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
Definira kanonske faze, artefakte, putanje i gate kriterije prekršajnog
modula kao pilot domenu.

### `PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`
Definira prioritetni redoslijed daljnje konverzije zakona u NORMA JSON.
Potvrduje da su `ustav_rh_procisceni` i `prekrsajni_zakon_procisceni`
postojeci uzorak te da se daljnji ingest i normiranje vode istim obrascem.

### `REZIM_KONVERZIJE_ZUP_U_JSON.md`
Definira utvrdjeni rezim ingest-a i konverzije za
`zakon_o_opcem_upravnom_postupku`.
Dokumentira provjeru dostupnosti prociscenog teksta na NN i obvezu odabira
kanonskog modela konverzije bez paralelnih ad-hoc postupaka.

### `REZIM_KONVERZIJE_ZUS_U_JSON.md`
Definira utvrdjeni rezim ingest-a i konverzije za
`zakon_o_upravnim_sporovima`.
Dokumentira da se vazeci ZUS vodi kao jedan vazeci cjeloviti akt
(`NN 36/2024`) po obrascu tipa `ustav_rh_procisceni`,
uz `zakon.hr` kao kontrolni izvor validacije.

### `REZIM_KONVERZIJE_ZPD_U_JSON.md`
Definira utvrdjeni rezim ingest-a i konverzije za
`zakon_o_porezu_na_dohodak`.
Dokumentira da je na primarnoj NN provjeri potvrden izvorni zakon
`NN 115/2016` i zaseban niz izmjena/dopuna, bez dokaza jednog samostalnog
vazeceg prociscenog NN akta, pa se odabire model
`PREKRSAJNI_ZAKON_MODEL`.

### `OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`
Definira kanonsko tumacenje prolaza za zasebne ZPD amandmane u kontrolnoj
usporedbi s `zakon.hr`.
Uređuje odnos `CONTROL_COUNT`, `NN_COUNT`, `EXTRA_LIST` i `SHORT_COUNT`
na temelju stvarnih rezultata Z120 i Z121, uz razliku između toleriranih
naleza i tvrdih validator fail signala.

### `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
Definira objedinjeni zavrsni pregled za cijeli ZPD set.
Uređuje jedinstveni pregled core akta i svih amandmana iz manifesta,
sa zavrsnim zakljuckom o potpunosti obrade, toleriranim odstupanjima i
preostalim tehnickim ili interpretativnim napomenama.

### `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
Definira analitičku inventuru postojećeg obrasca za zakone s amandmanima.
Uređuje što je već kanonski pokriveno kroz postojeće dokumente i alate,
što još nedostaje te koje sekcije treba dodati budućem jedinstvenom
kanonskom dokumentu obrasca.

### `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`
Definira objedinjeni kanonski postupak za pretvaranje zakona s amandmanima
u JSON.
Uređuje režim `core + amandmani`, NN dokazni sloj, kontrolni `zakon.hr`
sloj, pravila za sidra i norme, validaciju, tolerirana odstupanja,
završni izvještaj i uvjete kada se zakon smije označiti kao kanonski
obrađen.

### `REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`
POVIJESNI_DOKAZNI_TRAGOVI. Starija read-only revizija dokumentacije,
supersedana dokumentom
`REVIZIJA_STRUKTURE_DOKUMENTACIJE_I_PREPORUKE_CISCENJA.md`.
Ostaje u repou radi audita, ali nije aktivni operativni sloj.

### `POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md`
POVIJESNI_DOKAZNI_TRAGOVI. Bilježi stari markdown backlog koji je kasnije
zatvoren na nulu.
Supersediran je dokumentom
`PREOSTALI_MARKDOWN_BACKLOG_NAKON_SELECTION_REPORT_SANACIJE.md`
i kasnijim čistim lint rezultatima; ostaje samo kao dokazni trag.

### `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
POVIJESNI_DOKAZNI_TRAGOVI. Dokazuje tadašnje lokalno i GitHub stanje nakon
nezatvorenih Z138 i Z139.
Supersediraju ga `KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`,
`ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
i kasnije zatvaranje tog niza; nije aktivni operativni standard ni glavni
`zakon -> ingest -> JSON` tok.

### `ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
Definira dokaznu procjenu je li postojeci kanonski obrazac za zakone s
amandmanima vec dovoljan kao glavni dokument.
Uređuje razliku između onoga što već imamo kao stvarni kanonski skup,
onoga što je još raspršeno među specijaliziranim i dokaznim dokumentima,
te minimalnog urednickog koraka potrebnog da glavni obrazac bude
dovoljno jasan za operativnu uporabu.
Privremeni je radni trag i neoperativni pomoćni dokument; nije glavni tok
`zakon -> ingest -> JSON`.

### `ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
Definira završni dokazni odgovor je li postojeći glavni kanonski obrazac za
zakone s amandmanima već dostatan.
Uređuje razliku između sadržaja koji glavni kanon već nosi, onoga što ostaje
u pomoćnim dokumentima i pitanja postoji li još ikakav stvarni obvezni
nedostatak glavnog obrasca.
Privremeni je radni trag i neoperativni pomoćni dokument; nije glavni tok
`zakon -> ingest -> JSON`.

### `RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
Datoteka je uklonjena iz aktivnog kanonskog sloja u ZADATAK 149.
Bila je proceduralni, vremenski vezani radni trag i nije aktivni
operativni standard.

### `Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
Datoteka je uklonjena iz aktivnog kanonskog sloja u ZADATAK 149.
Bila je proceduralni, vremenski vezani radni trag i nije aktivni
operativni standard.

### `BASELINE_MARKDOWN_STANJA_REPOA.md`
Datoteka je uklonjena iz aktivnog kanonskog sloja u ZADATAK 150.
Bila je dokazni snapshot prolaznog markdown stanja repoa i nije
aktivni operativni standard.

### `USPOREDBA_PREOSTALE_DVIJE_UNSTAGED_DATOTEKE.md`
Datoteka je uklonjena iz aktivnog kanonskog sloja u ZADATAK 150.
Bila je dokazna analiza prolaznih unstaged datoteka i nije aktivni
operativni standard.

### `ANALIZA_ZPD_ZAVRSNOG_IZVJESTAJA_LOKALNI_DIFF.md`
Datoteka je uklonjena iz aktivnog kanonskog sloja u ZADATAK 150.
Bila je dokazna analiza prolaznog unstaged diffa i nije aktivni
operativni standard.

### `DNEVNIK_RADA.md`
Evidentira značajne korake rada kronološki.
Služi kao dokazni trag promjena i odluka kroz vrijeme.

### `STANDARD_ZASTITA_DNEVNIKA_RADA.md`
Definira tvrdu zaštitu datoteke dnevnika rada.
Uređuje append-only unos, zabranu prepisivanja i dokazne ispise prije/poslije.
Kanonska append-only metoda je skripta
`alati/dodaj_dnevnicki_unos_na_kraj.ps1`.

### `STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
Definira kanonska pravila za headinge, duljinu redaka i scoped provjeru
markdown dokumentacije.
Uređuje izbjegavanje `MD024`, `MD026` i `MD013`, pravila diranja dnevnika,
statusa i mape, generator dnevnickog unosa i kanonski wrapper za zatvaranje
dokumentacijskog koraka.

### `ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`
Definira dokaznu analizu neuzastopnog skoka u nizu potpuno validiranih
natuknica (`103 -> 122`) u istom normativnom nizu.
Uređuje popis clanaka u ulazu, preskoceni raspon i zakljucak ispravnosti
skoka.
U paketnom zatvaranju koristi se kao dokazna podloga da raspon `104-121`
nije bio dostupan u ulazu tog homogenog niza.

### `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
Dokument je bio obuhvaćen prvim skupinskim rezom u ZADATAK 155, ali je
commit `c6519e9` pogrešno ostavio arhivski stub istog imena.
Korektivnim rezom u ZADATAK 156 stub je stvarno uklonjen iz kanonskog i
radnog sloja; trag ostaje samo u `MAPA`, `STATUS`, `DNEVNIK` i git
povijesti.

### `PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
Dokument je bio obuhvaćen prvim skupinskim rezom u ZADATAK 155, ali je
commit `c6519e9` pogrešno ostavio arhivski stub istog imena.
Korektivnim rezom u ZADATAK 156 stub je stvarno uklonjen iz kanonskog i
radnog sloja; trag ostaje samo u `MAPA`, `STATUS`, `DNEVNIK` i git
povijesti.

### `PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
Dokument je bio obuhvaćen prvim skupinskim rezom u ZADATAK 155, ali je
commit `c6519e9` pogrešno ostavio arhivski stub istog imena.
Korektivnim rezom u ZADATAK 156 stub je stvarno uklonjen iz kanonskog i
radnog sloja; trag ostaje samo u `MAPA`, `STATUS`, `DNEVNIK` i git
povijesti.

### `PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`
Dokument je bio obuhvaćen prvim skupinskim rezom u ZADATAK 155, ali je
commit `c6519e9` pogrešno ostavio arhivski stub istog imena.
Korektivnim rezom u ZADATAK 156 stub je stvarno uklonjen iz kanonskog i
radnog sloja; trag ostaje samo u `MAPA`, `STATUS`, `DNEVNIK` i git
povijesti.

### `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
Definira dokazne terminološke izvore za višejezične ekvivalente.
Uređuje ulogu CURIA/IATE izvora i ograničenja prema pravnom učinku.

### `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
Definira kanonski format normaliziranog terminološkog zapisa.
Uređuje sljedivost prema raw izvozu bez pravnog tumačenja.

### `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
Definira tehnički kriterij izdvajanja hrvatski relevantnih zapisa.
Uređuje granicu prema pravnim institutima i pripremu za NN sidrenje.

### `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
Definira tehničko mapiranje EU termina prema potencijalnim NN pojmovima.
Uređuje status prijedloga bez normativnog sidrenja i ručnu provjeru.

### `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
Definira izdvajanje prioritetnog radnog uzorka iz EU -> NN prijedloga.
Uređuje operativni redoslijed za sljedeći korak NN sidrenja.

### `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
Definira čišćenje prioritetnog uzorka na NN-sidrenju podobne kandidate.
Uređuje uklanjanje tehničkog šuma prije ručnog NN pregleda.

### `STANDARD_JSON_RJECNICKA_NATUKNICA.md`
Definira kanonski JSON model jedne rječničke natuknice Veritas H.77.
Uređuje početni operativni skup bez NN sidra i prazna polja za sidrenje.

### `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
Definira izdvajanje pilot-skupa rječničkih natuknica za prvo NN sidrenje.
Uređuje determinističke kriterije prioriteta i obavezna pilot-polja.

### `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
Definira izdvajanje jezgrenih natuknica iz pilot-skupa za prvo NN sidrenje.
Uređuje odvajanje osnovnih pojmova od složenih procesnih fraza.

### `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
Definira proširenje jezgre na osnovni postupovni skup za prvo NN sidrenje.
Uređuje balans između uskog jezgrenog i općeg postupovnog obuhvata.

### `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
Definira prvo stvarno NN sidrenje rječničkih natuknica.
Uređuje status sidra, višeznačnost i zabranu prisilnog sužavanja na jedno sidro.

### `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
Definira razlaganje višeznačnih i nejasnih NN sidara u kandidatske podnatuknice.
Uređuje razdvajanje po aktu/kontekstu bez konačnog ručnog presuđivanja.

### `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
Definira sužavanje v2 kandidata u konačne podnatuknice za ručnu validaciju.
Uređuje granicu između grupiranja istog konteksta i zadržavanja različitog
akta ili različitog normativnog konteksta.

### `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
Definira ručnu validaciju konačnih NN kandidata i upis potvrđenih sidara u
validirani sloj rječničkih natuknica.
Uređuje statuse konačne validacije i pravilo da bez ljudske potvrde nema
konačnog odabira sidra.

### `STANDARD_GRANSKE_PODNATUKNICE_NN.md`
Definira konsolidaciju validiranih sidara u granske rječničke podnatuknice.
Uređuje tehničko razdvajanje po dokazivom kontekstu (grana/akt) bez
slobodnog pravnog tumačenja.
U korekciji v2 precizira razdvajanje po stvarnom normativnom kontekstu,
bez lažnog sažimanja više sidara u jedan zapis.

### `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
Definira pilot-zatvaranje prve potpuno validirane granske natuknice.
Uređuje uvjete jednoznačnog konteksta i dokazivih NN sidara,
uz pravilo da se u jednom zadatku zatvara točno jedna natuknica.
Operativno zatvaranje izvode skripte
`alati/zatvori_prvu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_drugu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py` i
`alati/zatvori_paket_dokaz_prekrsajni_zakon.py` i
`alati/zatvori_paket_dostava_prekrsajni_zakon.py` i
`alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py` i
`alati/zatvori_paket_presuda_prekrsajni_zakon.py` i
`alati/zatvori_paket_prigovor_prekrsajni_zakon.py` i
`alati/zatvori_paket_rjesenje_prekrsajni_zakon.py` i
`alati/zatvori_paket_zalba_prekrsajni_zakon.py`.
Za analiza-only odabir sljedeceg paketa koristi se skripta
`alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`, koja generira
`baza_terminologije/rjecnik/rang_lista_homogenih_nizova_za_paket.json`
i pripadni manifest bez zatvaranja novih natuknica.

### `STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
Definira kanonski model sinkronizacije lokalnog repoa, GitHuba i
Google Disk kopije.
Uređuje da je GitHub izvor istine, lokalna mapa jedina radna kopija,
a Drive samo sinkronizirana kopija/backup, uz razdvajanje pre-check
snapshota od zavrsnog git dokaza.

---

## 3) Redoslijed čitanja

0) `AGENTS.md`
1) `METODOLOGIJA_RADA_VERITAS_H77.md`
2) `RJEČNIK_POJMOVA_VERITAS_H77.md`
3) `TEHNIČKI_OKVIR_VERITAS_H77.md`
4) `STANDARD_JSON_NORMA.md`
5) `STANDARD_JSON_POSTUPAK.md`
6) `RAZVOJNI_PLAN_VERITAS_H77.md`
7) `DNEVNIK_RADA.md`
8) `STANDARD_ZASTITA_DNEVNIKA_RADA.md`
9) `STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
10) `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
11) `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
12) `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
13) `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
14) `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
15) `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
16) `STANDARD_JSON_RJECNICKA_NATUKNICA.md`
17) `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
18) `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
19) `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
20) `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
21) `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
22) `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
23) `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
24) `STANDARD_GRANSKE_PODNATUKNICE_NN.md`
25) `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
26) `STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
27) `PRIORITETI_KONVERZIJE_ZAKONA_U_JSON.md`
28) `REZIM_KONVERZIJE_ZUP_U_JSON.md`
29) `REZIM_KONVERZIJE_ZUS_U_JSON.md`

### Redoslijed čitanja — prekršajni modul

1) `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
2) `STANDARD_FER_NAPLATA_PREKRSAJI.md`
3) `STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
4) `STANDARD_JSON_AUDIT_PRIMJENE.md`
5) `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
6) `STANDARD_JSON_SUBSUMPCIJA.md`
7) `STANDARD_JSON_HIJERARHIJA.md`
8) `STANDARD_JSON_PREDLOZAK.md`
9) `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
10) `dokumentacija/sheme/SCHEMA_INTAKE_PREKRSAJI_V1.json`
11) `dokumentacija/sheme/SCHEMA_AUDIT_V1.json`
12) `dokumentacija/sheme/SCHEMA_SUBSUMPCIJA_V1.json`
13) `dokumentacija/sheme/SCHEMA_PREDLOZAK_V1.json`
14) `alati/validiraj_intake_prekrsaji_v1.ps1`
15) `alati/validiraj_audit_v1.ps1`
16) `alati/validiraj_subsumciju_v1.ps1`
17) `alati/validiraj_predlozak_v1.ps1`
18) `alati/generiraj_audit_prekrsaji_v1.ps1`
19) `alati/validiraj_audit_generated_v1.ps1`
20) `alati/run_tok_v1.ps1`
21) `alati/ci_smoke.ps1`

---

## 4) Pravilo održavanja indexa

Kad se doda novi dokument ili izmijeni postojeći, mora se ažurirati i ovaj
index.
Svako ažuriranje indexa evidentira se u `DNEVNIK_RADA.md`.

---

## 5) Gdje što pripada

- Norme pripadaju standardu `STANDARD_JSON_NORMA.md` i zapisima NORMA JSON.
- Postupci pripadaju standardu `STANDARD_JSON_POSTUPAK.md` i PROCEDURA JSON.
- Pojmovi i definicije pripadaju `RJEČNIK_POJMOVA_VERITAS_H77.md`.
- Tehničke odluke pripadaju `TEHNIČKI_OKVIR_VERITAS_H77.md`.
- Opća metodologija i gate logika pripadaju
  `METODOLOGIJA_RADA_VERITAS_H77.md`.
- Razvojne faze i redoslijed rada pripadaju `RAZVOJNI_PLAN_VERITAS_H77.md`.
- Operativni paketni manifesti ingest-a pripadaju mapi `paketi/`.
- Aktivni paketni manifesti za ingest su `paketi/PAKET_PREKRSAJNI_V1.json`,
  `paketi/PAKET_ZUP_V1.json`, `paketi/PAKET_ZUS_V1.json` i
  `paketi/PAKET_OPZ_V1.json` i `paketi/PAKET_ZPD_V1.json`.
- Trajni kontrolni izvjestaj usporedbe ZUP JSON seta s kontrolnim slojem
  zakon.hr je
  `baza_zakona/norme/zakon_o_opcem_upravnom_postupku_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- Trajni kontrolni izvjestaj usporedbe ZUS JSON seta s kontrolnim slojem
  zakon.hr je
  `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- Kronologija stvarnog rada pripada `DNEVNIK_RADA.md`.
- Zaštita dnevnika rada pripada
  `STANDARD_ZASTITA_DNEVNIKA_RADA.md`.
- Pravila headinga, scoped markdown provjere i servisne discipline
  pripadaju `STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`; statusni sync
  izvodi `alati/uskladi_status_projekta.ps1`, generator dnevnickog unosa
  izvodi `alati/generiraj_dnevnicki_unos.ps1`, append-only dodavanje izvodi
  `alati/dodaj_dnevnicki_unos_na_kraj.ps1`, kanonsko zatvaranje koraka
  izvodi `alati/zatvori_dokumentacijski_korak.ps1`, a scoped markdown
  preflight izvodi `alati/provjeri_markdown_scope.ps1`.
- Terminološki dokazni i operativni izvori pripadaju
  `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`, a tehnički izvoz iz CURIA XLSX
  izvodi `alati/pretvori_curia_xlsx_u_json.py`; normalizacija u kanonski
  sloj izvodi `alati/normaliziraj_curia_terminologiju.py` prema
  `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`, dok segmentaciju operativnog
  formata izvodi `alati/segmentiraj_curia_terminoloske_zapise.py`; izdvajanje
  hrvatski relevantnog sloja izvodi
  `alati/izdvoji_hrvatski_relevantne_curia_termini.py` prema
  `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`; tehničko mapiranje
  prema potencijalnim NN pojmovima izvodi
  `alati/mapiraj_curia_na_potencijalne_nn_pojmove.py` prema
  `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`; izdvajanje prioritetnog
  uzorka izvodi `alati/izdvoji_prioritetni_uzorak_za_nn_sidrenje.py` prema
  `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`; čišćenje uzorka izvodi
  `alati/ocisti_prioritetni_uzorak_za_nn_sidrenje.py` prema
  `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`; izgradnju početnih
  rječničkih natuknica izvodi
  `alati/izgradi_pocetne_rjecnicke_natuknice.py` prema
  `STANDARD_JSON_RJECNICKA_NATUKNICA.md`; izdvajanje pilot-skupa izvodi
  `alati/izdvoji_pilot_natuknice_za_nn_sidrenje.py` prema
  `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`; izdvajanje jezgrenih
  natuknica izvodi `alati/izdvoji_jezgrene_natuknice_iz_pilota.py` prema
  `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`; proširenje na osnovni
  postupovni skup izvodi
  `alati/prosiri_jezgrene_natuknice_na_osnovni_postupovni_skup.py` prema
  `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`; prvo stvarno
  NN sidrenje osnovnog skupa izvodi
  `alati/sidri_osnovni_postupovni_skup_na_nn.py` prema
  `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`; razlaganje višeznačnih
  sidara u kandidatske podnatuknice izvodi
  `alati/razlozi_viseznacna_nn_sidra_po_aktu.py` prema
  `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`; ispravak razlaganja na
  stvarne kandidate po pojedinom sidru izvodi
  `alati/ispravi_razlaganje_nn_kandidata.py` i generira
  `kandidatske_podnatuknice_nn_v2.json` + manifest; sužavanje v2 kandidata
  za ručnu validaciju izvodi
  `alati/suzi_nn_kandidate_za_rucnu_validaciju.py` prema
  `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md` i generira
  `konacni_nn_kandidati_za_validaciju.json` + manifest; ručna validacija i
  upis potvrđenih sidara izvodi
  `alati/upisi_validirana_nn_sidra_u_natuknice.py` prema
  `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md` i generira
  `osnovni_postupovni_skup_nn_validiran.json` + manifest; granska
  konsolidacija validiranih pojmova izvodi
  `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py` prema
  `STANDARD_GRANSKE_PODNATUKNICE_NN.md` i generira
  `granske_podnatuknice_nn.json` + manifest; korekcija konsolidacije
  generira `granske_podnatuknice_nn_v2.json` + v2 manifest.
