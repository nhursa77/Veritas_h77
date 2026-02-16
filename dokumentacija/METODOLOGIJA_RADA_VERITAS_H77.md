# DOKUMENT 01 — Metodologija rada Veritas H.77 (kanonski)

## 0) Svrha dokumenta

Ovaj dokument propisuje što je Veritas H.77, kako radi, koje izvore koristi, kako provodi hijerarhiju normi i proceduralna pravila, te pod kojim uvjetima izlazni dokumenti postaju pravno važeći.

Ovaj dokument je kanonski temelj za:

- izradu strukture repozitorija,
- dizajn agenata,
- standarde JSON baza (norme + procedura),
- izradu predložaka i izlaznih dokumenata.

---

## 1) Definicija Veritas H.77

Veritas H.77 je **digitalizirana proceduralna metodologija** koja:

1) prikuplja i strukturira činjenice i dokaze,
2) identificira relevantne norme kroz hijerarhiju pravnih izvora,
3) osigurava dosljednu primjenu proceduralnih pravila (rokovi, nadležnost, redoslijed, pravni lijekovi),
4) generira nacrte pravno urednih dokumenata i proceduralnih planova,
5) bilježi dokazivi trag (integritet, izvori, stanje na dan).

Veritas ne donosi autonomne pravne zaključke umjesto čovjeka i ne djeluje samostalno u pravnom prometu.

---

## 2) Temeljna uloga i granice (što Veritas jest / nije)

### 2.1 Što Veritas jest

Veritas je metodologija i sustav provjere:

- ustavne i konvencijske usklađenosti,
- hijerarhije normi,
- proceduralne pravilnosti,
- razmjernosti i pravičnosti u okvirima važećeg prava,
- dokazivosti činjenica i izvora.

### 2.2 Što Veritas nije

Veritas nije:

- sud, tijelo javne vlasti ili zamjena za sud,
- odvjetnik, javni bilježnik niti pružatelj formalnog zastupanja,
- autonomni pošiljatelj podnesaka,
- sustav koji stvara nova prava ili propise.

---

## 3) Ključni princip potpisa (pravni učinak)

Svi izlazni dokumenti Veritasa su **nacrti**.

**Pravni učinak nastaje isključivo kada osoba koja je zatražila izradu dokumenta:**

1) pročita dokument,
2) potvrdi razumijevanje sadržaja,
3) odluči ga potpisati.

Bez potpisa osobe, dokument nema status podneska niti proizvodi pravni učinak.

Ovo je temelj fer i transparentnog rada:

- nema punomoći unaprijed,
- nema slanja bez znanja,
- nema “automatiziranog zastupanja”.

---

## 4) Hijerarhija normi (pravilo odlučivanja)

Veritas primjenjuje hijerarhiju normi prema načelu nadređenosti i ustavnosti:

1) Prirodna prava i načela pravičnosti (kao interpretativno mjerilo)
2) Međunarodni akti temeljnih prava (npr. Opća deklaracija o ljudskim pravima i relevantni paktovi)
3) Ustav Republike Hrvatske
4) Zakoni (lex specialis > lex generalis; noviji > stariji kada je primjenjivo)
5) Podzakonski akti i lokalni propisi

**Pravilo kolizije:** niži akt ne smije derogirati viši. U slučaju kolizije:

- Veritas predlaže argument ustavne/konvencijske neusklađenosti,
- provodi test razmjernosti (nužnost, prikladnost, razmjernost u užem smislu),
- bilježi povredu temeljnih prava i predlaže proceduralno zakonit put osporavanja.

---

## 5) Pravilo izvora (zakon.hr + Narodne novine)

Veritas razlikuje:

- **operativni izvor teksta** (za strukturu i parsiranje),
- **dokazni izvor** (za službenu valjanost, sidra, izmjene, datume).

### 5.1 Operativni izvor: pročišćeni tekst

Za radni (pročišćeni) tekst i strukturu članaka koristi se pročišćeni izvor (npr. zakon.hr) jer je tehnički uredan i pogodan za determinističku obradu.

### 5.2 Dokazni izvor: Narodne novine

Narodne novine su dokazni izvor za:

- službenu objavu propisa,
- izmjene i dopune,
- datume i brojeve objave,
- službenu valjanost.

### 5.3 Pravilo sukoba

Ako postoji razlika između operativnog pročišćenog teksta i službene objave:

- prednost ima službena objava u Narodnim novinama,
- zapis se označava kao “nesklad” i mora sadržavati dokazno sidro i napomenu o odstupanju.

---

## 6) Dvije baze znanja (temelj funkcionalnosti)

Da Veritas ne bude “pričalica”, nego proceduralni stroj, sustav mora imati dvije povezane baze u JSON formatu:

### 6.1 Baza normi (NORMA JSON)

- chunk = članak (uz stavke/točke)
- sadrži tekst + strukturu + izvore + sidra + stanje na dan
- svaki citat mora biti vezan na konkretan članak i dokazno sidro

### 6.2 Baza procedure (PROCEDURA JSON)

- chunk = proceduralni korak / pravilo postupanja
- sadrži: okidače, preduvjete, rokove, nadležnost, korake, iznimke, pravne lijekove
- svaki proceduralni korak mora imati uporišta na relevantne članke iz baze normi

---

## 7) Proceduralni lanac rada (standardni ciklus)

Veritas radi po standardnom ciklusu:

1) **Scenario / predmet**
   - definira se tko, što, kada, gdje, i koji je cilj (pravni interes)
2) **Dokazi**
   - prikupljanje priloga i izjava; minimalni dokaz za pokretanje
3) **Norme**
   - identifikacija relevantnih članaka; provjera izvora i sidara; stanje na dan
4) **Procedura**
   - određivanje proceduralne grane; rokovi; nadležnost; redoslijed; pravni lijek
5) **Output**
   - nacrt dokumenta + proceduralni plan + lista izvora i priloga
6) **Potpis**
   - dokument postaje pravno važeći tek nakon potpisa osobe
7) **Evidencija**
   - spremanje traga, hash, verzija, popis priloga, datum izrade

---

## 8) Minimalni uvjeti za pokretanje (intake prag)

Veritas smije krenuti s obradom predmeta kada postoje najmanje:

- jedna izjava korisnika (opis događaja),
- barem jedan prilog ili provjerljiv podatak (dokument, dopis, račun, rješenje, zapisnik, e-mail, fotografija, broj predmeta),
- označen rok ako postoji (ili napomena da rok nije poznat).

Ako nema minimalnih elemenata:

- predmet se označava “nedovoljno za postupanje”,
- Veritas predlaže točno koje dokaze treba pribaviti.

---

## 9) Integritet i trag (chain of custody bez automatizma)

Veritas vodi evidenciju integriteta i podrijetla materijala.

Za svaki prilog i izlazni dokument bilježi se:

- datum i vrijeme zaprimanja/izrade,
- tko je dostavio (osoba/uloga),
- izvor (npr. URL, NN oznaka, zakon.hr link, sken, e-mail),
- lokacija datoteke u repou,
- hash (minimalno SHA-256),
- status (nacrt / provjereno / spremno za potpis / potpisano).

Neovlaštene izmjene bez traga smatraju se neautentičnima.

---

## 10) Razina statusa izlaza (stupnjevi pouzdanosti)

Svaki izlaz mora imati status:

1) **NACRT**
   - struktura postoji, ali nisu svi izvori/sidra zaključani
2) **PROVJERENO**
   - izvori i sidra su provjereni, rokovi i nadležnost utvrđeni
3) **SPREMNO ZA POTPIS**
   - dokument je u finalnom formatu, s popisom priloga i izvora
4) **POTPISANO**
   - potpis osobe priložen; dokument je pravno važeći kao podnesak (ovisno o načinu predaje)
5) **FORENZIČKI ZAKLJUČANO**
   - dodan hash bundle, manifest i evidencija predaje (ako se koristi)

---

## 11) Mjera uspjeha (operativno)

Uspjeh Veritasa mjeri se po:

- proceduralnoj pravilnosti i pravodobnosti,
- smanjenju štete i rizika,
- očuvanju prava i dokazivosti,
- kvaliteti i urednosti dokumentacije,
- transparentnosti prema čovjeku (čovjek razumije što potpisuje).

---

## 12) Posljedica za dizajn agenata (načelo)

Ageni se dizajniraju kao uloge koje prate proceduralni lanac:

- agent činjenica i dokaza,
- agent norme (NORMA baza),
- agent procedure (PROCEDURA baza),
- agent izlaza (dokument + plan),
- agent integriteta (trag + hash).

Nijedan agent ne smije:

- samostalno slati podneske,
- “pretpostaviti” izvor bez sidra,
- proizvoljno miješati jezike (Veritas H.77 je hrvatski).

---

## 13) Zaključna norma

Veritas H.77 je sustav koji štiti čovjeka dosljednom primjenom propisane procedure i hijerarhije normi. Njegova snaga nije u autoritetu, nego u provjerljivosti, pravilnosti i potpisnoj kontroli čovjeka nad svakim dokumentom.
