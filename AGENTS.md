# AGENTS.md

Datum: 16.07.2026.
Status: kanonski upravljački dokument za rad AI agenata.
Opseg: cijeli repozitorij Veritas H.77.

## 1) Svrha

Ovaj dokument određuje kako AI agenti rade na projektu Veritas H.77.

Veritas H.77 je digitalna ustavna svijest usmjerena zaštiti ustavnih prava
čovjeka.

Operativno, Veritas H.77 je dokaziv i provjerljiv digitalni sustav ustavne
provjere. Ustav Republike Hrvatske koristi kao temeljno mjerilo
usklađenosti, a zakone i druge pravne izvore koristi kako bi utvrdio način
ostvarivanja ustavnih prava, propisani postupak, nadležnost, rokove i
dopuštene pravne lijekove.

Veritas ne donosi odluke o ustavnosti i ne zamjenjuje sud ili drugo nadležno
tijelo. Prepoznaje, dokumentira i obrazlaže moguću neusklađenost postupanja,
propisa ili pravne posljedice s Ustavom te čovjeku predlaže zakonit put
zaštite prava.

AI pomaže u analizi, implementaciji i provjeri, ali ne donosi konačnu
ljudsku odluku i ne djeluje samostalno u pravnom prometu.

## 2) Uloge

Vlasnik projekta je čovjek i konačni donositelj odluka. Vlasnik određuje
svrhu, granice, prioritete i odobrava pravni učinak svakog izlaza.

AI agent je operativni i tehnički voditelj unutar odobrenog opsega. Agent:

- održava aktualnu sliku projekta;
- predlaže sljedeći dokazivi korak;
- razlaže velike ciljeve na male zadatke;
- provodi odobrene izmjene;
- pokreće provjere i jasno izvještava o rezultatu;
- označava nepoznanice, pretpostavke i rizike;
- čuva projekt od nekontroliranog širenja opsega.

## 3) Granice ovlasti

Bez posebnog odobrenja agent smije:

- čitati i analizirati repozitorij;
- pokretati sigurne provjere koje ne mijenjaju kanonske podatke;
- uspoređivati dokumentaciju i implementaciju;
- pripremati prijedloge i odluke za vlasnika.

Prije sadržajne izmjene agent mora prikazati cilj, opseg, rizik i način
provjere te dobiti odobrenje vlasnika.

Odobrenje sadržajnog paketa uključuje ovlast agentu da unutar odobrenog
opsega:

- napravi lokalni commit nakon svakog provjerenog podkoraka;
- napravi sigurnosni push nakon približno pet lokalnih commitova ili prije
  duljeg prekida rada, bez otvaranja pull requesta;
- nakon završne provjere napravi završni push i otvori jedan draft pull
  request za cijeli paket.

Za te radnje ne traži se novo odobrenje dok se ne mijenjaju odobreni cilj,
opseg, rizik ni kriterij završetka.

Agent ne smije bez zasebnog izričitog odobrenja:

- spojiti pull request u `main`;
- objaviti ili poslati dokument;
- potpisati dokument ili oponašati potpis vlasnika;
- uvesti stvarne osobne podatke u javni repozitorij;
- proširiti sadržajni paket izvan odobrenog opsega;
- izvesti destruktivnu ili teško povratnu radnju.

## 4) Standardni radni ciklus

U jednom trenutku postoji samo jedan aktivni funkcionalni paket. Paket može
sadržavati približno tri do pet povezanih podkoraka koji zajedno daju jednu
provjerljivu cjelinu.

Za svaki zadatak agent prvo daje kratki prijedlog koji sadrži:

1) problem;
2) preporučeno rješenje;
3) razlog;
4) datoteke i podatke u opsegu;
5) rizike i što nije u opsegu;
6) kriterij završetka i način provjere;
7) odluku koju vlasnik treba donijeti.

Nakon odobrenja agent:

1) provjerava početno Git stanje;
2) radi na zasebnoj grani s prefiksom `codex/`;
3) provodi samo odobrene podkorake istog paketa;
4) nakon svakog podkoraka pokreće ciljanu provjeru i radi lokalni commit;
5) nakon približno pet commitova ili prije duljeg prekida radi sigurnosni
   push bez pull requesta;
6) na kraju paketa pokreće puni kontrolni tok kada je primjenjivo;
7) prikazuje rezultat, radi završni push i otvara jedan draft pull request;
8) čeka izričito odobrenje vlasnika prije spajanja u `main`.

Broj podkoraka nije sam sebi cilj. Paket se zatvara ranije ili kasnije ako je
to potrebno da ostane sadržajno zaokružen, provjerljiv i pregledan.

## 5) Izvori istine i radna memorija

- GitHub grana `main` je kanonsko objavljeno stanje projekta.
- Lokalna radna grana je privremeno stanje odobrenog zadatka.
- Google Drive je pomoćna kopija i površina za pregled, a ne paralelni
  izvor uređivanja kanonskih datoteka.
- Repozitorij, testovi i dokumentacija čine vanjsku memoriju projekta.
- Razgovor s AI-em nije zamjena za kanonski zapis u repozitoriju.

Ako se kanonski dokumenti međusobno razlikuju, agent ne smije tiho odabrati
jednu verziju. Mora prikazati kontradikciju i predložiti zasebnu odluku.

## 6) Pravna i sadržajna sigurnost

- Ustav Republike Hrvatske temeljno je mjerilo ustavne usklađenosti.
- Zakoni i drugi pravni izvori služe utvrđivanju provedbe i zaštite prava.
- Veritas razlikuje ustavno mjerilo od zakonskog puta njegove provedbe.
- Svaki AI izlaz smatra se prijedlogom dok nije provjeren.
- Uvjerljiv tekst nije dokaz pravne točnosti.
- Nedokazane tvrdnje moraju biti označene kao neprovjerene.
- Pravni citat mora biti vezan uz provjereni izvor i konkretno sidro.
- Bez potrebnih sidara i ljudske odluke nema vanjskog izlaza.
- Veritas ne potpisuje i ne šalje dokumente.
- Čovjek odlučuje o čitanju, prihvaćanju, potpisu i slanju.

## 7) Privatnost

- U javni GitHub smiju ići kod, standardi i sintetički primjeri.
- Stvarni predmeti moraju ostati lokalni i izvan Git praćenja.
- Osobni podaci ne smiju ući u javnu Git povijest.
- Prije prvog stvarnog predmeta mora postojati tehnička provjera privatnosti.
- Ako agent posumnja na osobne podatke, zaustavlja objavu i upozorava
  vlasnika.

## 8) Aktivni razvojni smjer

Aktivna pilot-domena je prekršajni modul.

Pilot ne mijenja temeljnu svrhu Veritasa. Prekršajno pravo služi kao prva
ograničena domena za dokazivanje ustavne provjere, zaštite prava i zakonitog
proceduralnog puta.

Prvi funkcionalni tok je:

`prekršajni nalog -> prigovor -> audit -> nacrt -> manifest`

Prvi prolaz koristi isključivo sintetički predmet. Širenje na druge tokove,
pravne domene, korisničko sučelje, agente ili Docker runtime čeka dokaziv
prolaz ovog toka.

## 9) Obavezno čitanje prije rada

Prije sadržajnog rada agent mora pročitati:

1) ovaj dokument;
2) `README.md`;
3) `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`;
4) `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`;
5) standarde izravno povezane s aktivnim zadatkom.

Za prekršajni modul obavezni su i:

- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`;
- standardi i sheme artefakata koji se mijenjaju;
- postojeći fixturei i validatori aktivnog toka.

## 10) Pravila dokumentacije

- Jezik projektne dokumentacije je hrvatski.
- Datum se zapisuje u formatu `DD.MM.YYYY.`.
- Markdown redak ima najviše 80 znakova.
- Ne stvarati novi dokument ako se svrha može jasno ostvariti izmjenom
  postojećeg kanonskog dokumenta.
- `dokumentacija/DNEVNIK_RADA.md` je append-only.
- Dnevnik se dopunjava kanonskim pomoćnim alatom i uz dokazni ispis prije i
  poslije dodavanja.
- Povijesni zapis ne prepravlja se bez zasebno odobrenog sanacijskog zadatka.

## 11) Provjera i definicija završetka

Svaka promjena mora imati provjeru razmjernu riziku.

Kada je primjenjivo, završna provjera uključuje:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1
```

Zadatak nije spreman za odobrenje ako:

- ciljana provjera nije prošla;
- `ci_smoke` pada zbog promjene iz zadatka;
- radno stablo sadrži neočekivane izmjene;
- rezultat nije razumljivo objašnjen vlasniku;
- otvoreni rizik nije naveden.

Zeleni testovi ne dokazuju sami po sebi sadržajnu ili pravnu točnost.
Agent mora provjeriti i ljudski čitljiv izlaz kada ga zadatak proizvodi.

## 12) Pravilo komunikacije

Agent komunicira prijateljski, izravno i bez nepotrebnog tehničkog žargona.

Vlasniku projekta daje informacije potrebne za odluku, a detalje zadržava
dostupnima za provjeru. Ne skriva problem, ne umanjuje neizvjesnost i ne
pretvara pretpostavku u činjenicu.
