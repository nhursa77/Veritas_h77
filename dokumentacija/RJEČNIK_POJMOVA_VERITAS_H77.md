# RJEČNIK_POJMOVA_VERITAS_H77

Datum: 17.02.2026.
Status: kanonski

---

## 1) Rječnik pojmova

### Čovjek / potpisnik
Čovjek je nositelj prava i odluka u predmetu. Potpisnik je osoba koja potpisuje
za sebe i time preuzima odluku o korištenju izlaza.
Primjer: nositelj predmeta potpisuje nacrt podneska prije predaje.

### Upit
Upit je izričit zahtjev čovjeka da Veritas obradi predmet ili dio predmeta.
Bez upita nema aktivnog generiranja izlaza.

### Predmet
Predmet je formalna jedinica rada. Sadrži činjenice, dokaze, rokove, radnje i
izlaze.

### Scenario
Scenario je početni opis situacije i cilja postupanja. Služi za usmjeravanje
izbora normi i procedure.

### Činjenice
Činjenice su sažete, provjerljive tvrdnje o događaju. Pišu se jasno i
numerirano radi praćenja.

### Dokaz
Dokaz je provjerljiv podatak koji potvrđuje ili pobija činjenicu. Mora biti
povezan s predmetom i evidentiran.

### Prilog
Prilog je datoteka ili zapis priložen predmetu. Prilog može biti dokaz ili
pomoćni materijal.

### Izvor (općenito)
Izvor je mjesto iz kojeg potječe tekst norme ili dokaz. Izvor mora biti
naveden radi provjerljivosti.

### Operativni izvor
Operativni izvor je radni tekst za strukturiranje i obradu. Primjer je
pročišćeni tekst na zakon.hr.

### Pročišćeni tekst
Pročišćeni tekst je konsolidirana verzija zakona/akta koja uključuje važeće
izmjene i dopune do „stanja na dan”.
U Veritasu je to operativni set i njegova mapa se obavezno imenuje
`<akt_slug>_procisceni`.
NN objave (uključivo amandmane) čine dokazni sloj (`sidra`), a stariji
snapshotovi se spremaju u `arhiva/<akt_slug>/<source_set_slug>/`.

### Dokazni izvor
Dokazni izvor je službena objava koja potvrđuje valjanost norme. U RH su to
Narodne novine kada je primjenjivo.

### Sidro
Sidro je konkretna službena referenca objave norme ili izmjene. Sidro se
bilježi radi dokazivosti citata.

### Kandidatska podnatuknica (NN)
Kandidatska podnatuknica je privremeni, nekonačni zapis koji razlaže
višeznačan ili nejasan pojam na razinu akta/konteksta. Ne predstavlja konačno
sidrenu natuknicu i obavezno zahtijeva ručnu validaciju.

### Potpuno validirana natuknica (NN)
Potpuno validirana natuknica je zakljucani rjecnicki zapis nastao iz granske
podnatuknice koja ima jednoznacan kontekst i dokaziva, nekontradiktorna
NN sidra. U pilot-koraku zatvara se tocno jedna takva natuknica.

### Delta control (`*_delta_ops.json`)
Delta control je kanonski kontrolni artefakt za amandmanski set
`*_nn_<broj>_<godina>`. Sprema se isključivo na putanju
`izvori/kontrolno/zakon_hr/<akt_slug>/<akt_slug>_delta_ops.json` i služi kao
deterministički dokaz da amandman dira određene članke.

### Stanje na dan
Stanje na dan označava datum važenja sadržaja koji se koristi u obradi.
Format datuma je `DD.MM.YYYY.`.

### Norma
Norma je pravilo iz važećeg pravnog izvora. U Veritasu se norma citira
precizno po članku, stavku i točki.

### NORMA JSON
NORMA JSON je strukturirani zapis norme gdje je osnovna jedinica članak.
Sadrži tekst, strukturu, izvore, sidra i verziju.

### Postupak / procedura
Postupak je uređeni redoslijed pravnih i operativnih koraka. Procedura
određuje što, kada i pod kojim uvjetima se radi.

### PROCEDURA JSON
PROCEDURA JSON je strukturirani zapis postupanja po koracima. Svaki korak ima
ulaze, uvjete, radnju i izlaz.

### Korak
Korak je najmanja izvršna jedinica postupka. Korak ima jasan ulaz i jasan
rezultat.

### Okidač
Okidač je događaj ili uvjet koji pokreće korak. Može biti rok, događaj ili
zahtjev nositelja.

### Preduvjet
Preduvjet je uvjet koji mora biti ispunjen prije izvršenja koraka. Bez
preduvjeta korak se ne smije provesti.

### Nadležnost
Nadležnost određuje koje tijelo ili razina vlasti smije postupati. Provjera
nadležnosti je obavezna prije izlaza.

### Rok
Rok je krajnji datum ili vrijeme za valjano postupanje. Rok se vodi i provjerava
u svakom relevantnom koraku.

### Pravni lijek
Pravni lijek je propisani način osporavanja odluke ili radnje. Birа se prema
normama i procesnoj fazi.

### Gate
Gate je skup minimalnih uvjeta za prelazak u sljedeći status ili korak.
Ako gate nije zadovoljen, izlaz se ograničava ili zaustavlja.

### Izlaz
Izlaz je rezultat obrade predmeta. Može biti nacrt dokumenta, lista dopuna ili
interna odluka.

### Nacrt
Nacrt je pripremljeni dokument bez pravnog učinka dok nije potpisan. Nacrt je
namijenjen pregledu i doradi.

### Manifest
Manifest je popis datoteka i metapodataka u predmetu. Uključuje putanje,
vremena i hash vrijednosti.

### Hash (SHA-256)
Hash (SHA-256) je sažetak sadržaja za provjeru integriteta. Promjena sadržaja
mijenja hash vrijednost.

### Lanac skrbništva
Lanac skrbništva je evidencija tko je, kada i kako rukovao prilogom ili
izlazom. Služi očuvanju autentičnosti traga.

### Revizija / verzija
Revizija je izmjena sadržaja kroz vrijeme. Verzija označava konkretno stanje
zapisa u određenom trenutku.

### Nesklad (razlika zakon.hr vs NN)
Nesklad je razlika između operativnog i dokaznog izvora. U slučaju nesklada,
prednost ima službena objava i zapis se označava.

### Rizik (kad sidro nije puno)
Rizik je jasno označena pravna ili dokazna nesigurnost. Označava se kada sidro
nije puno i mora biti vidljivo prije potpisa.

---

## 2) Statusi izlaza

- NACRT: struktura i činjenice postoje, ali provjera nije zaključana.
- PROVJERENO: potvrđeni su izvori, sidra, nadležnost i rokovi.
- SPREMNO ZA POTPIS: finalni format i prilozi su pripremljeni za potpis.
- POTPISANO: potpisnik je potpisao za sebe.
- FORENZIČKI ZAKLJUČANO: manifest, hash i trag predaje su zaključani.

---

## 3) Pravilo potpisivanja i slanja

Potpisuje isključivo čovjek, odnosno potpisnik koji potpisuje za sebe.
Veritas generira na upit, ali ne potpisuje i ne šalje samostalno.
Slanje je odluka čovjeka nakon pregleda i potpisa.
