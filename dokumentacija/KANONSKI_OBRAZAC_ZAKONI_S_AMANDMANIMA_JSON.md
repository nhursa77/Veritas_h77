# KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON

Datum: 31.03.2026.
Status: kanonski
Opseg: objedinjeni kanonski postupak za pretvaranje zakona s amandmanima
u JSON na temelju postojećih pravila, dokaza i alata u repou.

---

## 1) Svrha i opseg

Ovaj dokument na jednom mjestu definira kanonski obrazac za zakone kod kojih
je dokazivi NN ulaz sastavljen od izvornog akta i niza zasebnih izmjena i
dopuna, a ne od jednog samostalnog važećeg pročišćenog NN akta.

Obrazac obuhvaća:

- režim `core + amandmani`
- dokazni sloj Narodnih novina
- kontrolni sloj `zakon.hr`
- razdvajanje `norme/` i `sidra/`
- validaciju i kriterije prolaza
- završni izvještaj i obvezni dokumentacijski trag

Dokument se koristi kao opći standard, dok pojedinačni dokumenti poput
ZPD rezima, obrasca amandmanske kontrole i završnog izvještaja ostaju
dokazni primjeri stvarne primjene tog standarda.

## 2) Kada se koristi model core + amandmani

Model `core + amandmani` koristi se kad primarni dokazni sloj u Narodnim
novinama pokazuje sljedeće stanje:

- postoji izvorni zakon kao početni akt
- postoje zasebne kasnije izmjene i dopune istog zakona
- nije dokazan jedan samostalni važeći NN ulaz koji bi se kanonski vodio
  kao jedini `procisceni` ulaz za cijeli zakon

Ako je na NN dokaziv samo izvorni zakon plus niz zasebnih amandmana,
obrada mora ostati na modelu `core + amandmani`.

## 3) Ulazni artefakti

Minimalni obvezni skup datoteka za jedan zakon s amandmanima je:

- jedan paketni manifest pod `paketi/` koji popisuje core akt i sve
  planirane amandmane
- za svaki akt lokalni NN snapshot pod
  `izvori/dokazno/narodne_novine/<akt_slug>/`
- `meta.json` za svaki NN snapshot
- `izvor_nn.html` ili valjani ELI PDF fallback put
- parsirani NN izlaz `struktura_nn_dokumenti.json` ili ekvivalentni
  člankovni rezultat koji alat stvarno koristi
- kontrolni sloj pod `izvori/kontrolno/zakon_hr/<akt_slug>/`
- za core rezultat pod `baza_zakona/norme/<core_slug>_procisceni/`
- za svaki amandman rezultat pod `baza_zakona/sidra/<akt_slug>/`
- trajni validacijski izvještaj za core i za svaki amandman
- završni izvještaj za cijeli zakon i obvezni status/dnevnik trag

Bez tog minimalnog skupa zakon nije spreman za kanonsko zatvaranje.

## 4) Dokazni NN sloj

Narodne novine su primarni dokazni izvor.

Kanonska pravila za NN sloj su:

- odluka o režimu uvijek se temelji na stvarno dokazivom NN nizu
- parser mora izdvojiti stvarni člankovni tok iz NN HTML-a
- ELI PDF fallback dopušten je samo kad NN HTML nije dostupan ili ne daje
  parsabilan člankovni sadržaj
- za svaki akt mora postojati jasan slug i pripadni dokazni snapshot

NN sloj je izvor istine za odluku što je core, a što su amandmani.

## 5) Kontrolni zakon.hr sloj

`zakon.hr` je pomoćni kontrolni sloj, a ne primarni dokazni izvor.

Kanonska pravila za kontrolni sloj su:

- koristi se za usporedbu i validaciju, ne za odluku o režimu
- vodi se odvojeno od NN dokaza pod `izvori/kontrolno/zakon_hr/`
- za core se koristi kontrolni zapis važećeg teksta ako je već evidentiran
- za amandmane se koristi zaseban amandmanski URL kad je takav zapis stvarno
  dokazan u repou
- kontrolni TXT, meta trag i eventualni pomoćni strukturirani izlazi moraju
  ostati odvojeni od operativnog JSON sloja

## 6) Pravila za sidra i norme

Core i amandmani ne vode se u istom izlaznom sloju.

Kanonska pravila su:

- core zakon ide u `baza_zakona/norme/<core_slug>_procisceni/`
- amandmani idu u `baza_zakona/sidra/<amandman_slug>/`
- svaki članak mora imati dokazni status sidra ili jasno označenu
  nepotpunost
- `status_sidra` je obvezan signal vanjske upotrebljivosti
- operativni pročišćeni tekst i dokazna sidra ostaju razdvojeni slojevi

Time je jasno odvojeno što je stabilna norma cijelog zakona, a što je
amandmanski dokazni sloj.

## 7) Redoslijed rada po koracima

Kanonski redoslijed rada je:

1. dokazati režim na NN izvoru
2. pripremiti manifest `core + amandmani`
3. preuzeti i spremiti NN dokazne snapshotove za core i amandmane
4. parsirati NN člankovni tok za svaki akt
5. uspostaviti ili potvrditi kontrolni `zakon.hr` sloj
6. izgraditi core izlaz u `norme/` i amandmanske izlaze u `sidra/`
7. provesti validaciju nad core setom i nad svakim amandmanom zasebno
8. sastaviti završni izvještaj za cijeli zakon
9. dopuniti mapu, status i append-only dnevnik

Preskakanje završnog izvještaja ili dokumentacijskog traga znači da obrada
nije kanonski zatvorena.

## 8) Validacija i kriteriji prolaza

Minimalni kriteriji prolaza su:

- `MISSING_COUNT=0`
- `CONTROL_TRUNCATION_SUSPECTED=False`
- nema `GUARDRAIL_FAIL`
- nema `ANOMALY_FLAG=True`
- odabrani izvor prolazi source-selection guardrail

Obrada jednog zakona je gotova tek kad:

- core i svi manifestom planirani amandmani imaju završene izlaze
- postoje trajni validacijski izvještaji za sve te akte
- postoji završni izvještaj za cijeli zakon
- status, mapa i dnevnik sadrže odgovarajući dokazni trag

Smije se reći da je zakon kanonski obrađen tek kad vrijedi sve gore navedeno
i kad nakon dokumentacijskog zatvaranja nema otvorenog zahtjeva za novi ingest,
refresh ili patch alata na temelju postojećih dokaza.

## 9) Tolerirana odstupanja

Tolerirana odstupanja su nalazi koji ostaju kao napomena, ali sami po sebi
ne ruše prolaz.

To uključuje:

- nenulti `SHORT_COUNT`
- `NN_COUNT` različit od `CONTROL_COUNT`
- izolirani `EXTRA_LIST`, ali samo ako nije praćen hard-fail signalom

Odstupanja koja ruše prolaz su:

- `MISSING_COUNT > 0`
- `CONTROL_TRUNCATION_SUSPECTED=True`
- `GUARDRAIL_FAIL=True`
- `ANOMALY_FLAG=True`
- dokaz da parser gubi članak ili da je odabran pogrešan NN izvor

Drugim riječima, napomena je dopuštena; gubitak normativne pokrivenosti nije.

## 10) Završni izvještaj i obvezni izlazi

Za svaki zakon s amandmanima obvezni završni izlazi su:

- završni pregled cijelog zakona u jednom dokumentu pod `dokumentacija/`
- prikaz core rezultata i svih amandmana redom iz manifesta
- za svaki zapis: slug, kontrolni URL ako postoji u repou, ključne
  validacijske metrike i kratak zaključak o prolazu
- završni zaključak za zakon kao cjelinu
- ažurirani `STATUS_PROJEKTA_VERITAS_H77.md`
- ažurirana `MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- jedan append-only unos u `DNEVNIK_RADA.md`

Bez tih izlaza obrada može biti tehnički izvedena, ali nije kanonski
dokumentirana.

## 11) Što nije dopušteno

Nije dopušteno:

- koristiti `zakon.hr` kao primarni dokazni izvor za odluku o režimu
- tvrditi da je zakon kanonski obrađen bez završnog izvještaja
- miješati core norme i amandmanska sidra u isti izlazni sloj
- otvarati patch parsera ili validatora bez stvarnog dokaznog signala kvara
- preskakati status, mapu ili append-only dnevnik na kraju koraka
- uvoditi novi ingest ili refresh kad postojeći artefakti već daju potreban
  dokazni trag za zaključak

## 12) Kratki operativni checklist

1. Dokazan je režim `core + amandmani` na NN izvoru.
2. Manifest popisuje core i sve planirane amandmane.
3. Za svaki akt postoji NN snapshot i parsirani člankovni rezultat.
4. Za svaki akt postoji kontrolni `zakon.hr` sloj kad je već dokazno utvrđen.
5. Core je upisan u `norme/`, amandmani u `sidra/`.
6. Svi akti imaju trajne validacijske izvještaje.
7. Nema hard-fail signala u validaciji.
8. Završni izvještaj za cijeli zakon je izrađen.
9. Mapa, status i append-only dnevnik su ažurirani.
10. Tek tada zakon smije biti označen kao kanonski obrađen.