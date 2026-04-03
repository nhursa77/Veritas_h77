# PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142

Datum: 03.04.2026.
Status: read-only dokazna priprema
Opseg: priprema buduceg uklanjajuceg scoped koraka za dvije proceduralne
 datoteke iz kanonskog sloja, bez brisanja, bez preimenovanja,
bez commita i bez pusha.

---

## A. Polazni git dokaz

Polazno stanje repozitorija:

- Lokalni HEAD: `878f193`
- Zadnji commit: `docs: arhivsko preoznacen dokument analiza stanja obrasca`
- Grana: `main`
- Stanje grane: `main` je poravnat s `origin/main`
- Remote hash: `878f1931faa20b21ffcc3e9fa5a7c4e55a44475b`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git status --short`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`

Potvrda statusa dviju ciljanih datoteka:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`:
  `EXISTS=True`, `TRACKED=True`, bez lokalne izmjene (`STATUS=`)
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`:
  `EXISTS=True`, `TRACKED=True`, bez lokalne izmjene (`STATUS=`)

Referentni dokazni dokumenti za ovu pripremu:

- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`
- `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`

---

## B. Datoteka 1 - RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md

Izvorna svrha:

- Dokument je nastao kao operativni razdjelnik tada mjesovitog lokalnog
  stanja po zadacima Z138-Z142.
- Njegova svrha bila je odrediti koji artefakt pripada kojem zadatku i
  kojim redom zatvarati commitove.

Sadasnja vrijednost:

- Vrijedan je kao povijesni zapis nacina razdvajanja scopea u jednom
  konkretnom periodu.
- Za trenutni operativni rad vise nije glavni kanonski standard,
  jer su kljucni koraci iz tog niza vec zatvoreni i potvrdeni.

Razlog za kandidaturu za uklanjanje:

- Sadrzaj je proceduralan i vremenski vezan uz stanje koje je u meduvremenu
  zatvoreno commitima i pushom.
- Normativna pravila projekta nisu u toj datoteci, nego u aktivnim
  standardima i glavnim kanonskim dokumentima.

Minimalni buduci zahvat:

- U zasebnom uklanjajucem scoped koraku ukloniti datoteku iz repozitorija.
- U istom koraku dopuniti samo nuzne kanonske tragove koji upucuju na
  uklanjanje (ako budu potrebni), bez sirenja scopea.

Procjena rizika uklanjanja:

- SREDNJI.
- Rizik je gubitak detaljnog konteksta o povijesnom redoslijedu zatvaranja;
  mitigacija je da taj kontekst ostaje pokriven kroz commit povijest i
  kasnije procjenske/prijedlozne dokumente.

---

## C. Datoteka 2 - Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md

Izvorna svrha:

- Dokument je nastao kao uska proceduralna priprema za cisto izdvajanje
  Z138 hunkova iz tada kumulativno mijesanih datoteka.
- Bio je alat za pripremu jednog konkretnog povijesnog commita.

Sadasnja vrijednost:

- Vrijednost je pretezno auditna i povijesna.
- Za aktivni kanonski sloj ne nosi operativna pravila, nego
  proceduralni kontekst koji je vec operativno potrosen.

Razlog za kandidaturu za uklanjanje:

- Funkcija dokumenta je vezana uz vec zavrsen trenutak pripreme commita,
  ne uz trajni standard rada.
- Sadrzajno se preklapa s kasnijim dokaznim dokumentima koji su vec
  formalizirali status paketa i prijedloge sljedecih koraka.

Minimalni buduci zahvat:

- U istom zasebnom uklanjajucem scoped koraku ukloniti datoteku iz repoa.
- Ako bude nuzno, dopuniti samo nuzne pratece kanonske tragove o
  uklanjanju, bez otvaranja novih meta-slojeva.

Procjena rizika uklanjanja:

- NIZAK do SREDNJI.
- Rizik je ogranicen jer je dokument proceduralan i vremenski vezan;
  mitigacija je potvrda da su sve operativne odluke koje su bitne vec
  u aktivnim standardima i commit povijesti.

---

## D. Točan budući uklanjajući scope

Buduci stvarni uklanjajuci korak smije dirati samo:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
- nuzne pratece kanonske tragove, ako budu potrebni za evidenciju
  uklanjanja (i to samo minimalno)

Buduci korak ne smije:

- siriti scope na druge dokumente iz paketa Z138-Z142
- dirati stash
- uvoditi dodatne refaktore ili sadrzajna prosirenja

---

## E. Zakljucak

Dokazna procjena potvrduje da su obje ciljane datoteke proceduralni,
vremenski vezani tragovi koji vise ne nose aktivni kanonski standard,
nego povijesni kontekst vec zatvorenih koraka.

Jasna preporuka:

U sljedecem zadatku izvesti stvarno uklanjanje
`RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md` i
`Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`
u zasebnom, uskom scoped koraku.
