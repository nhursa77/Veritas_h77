# PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142

Datum: 03.04.2026.
Status: read-only prijedlog
Opseg: prijedlog buduceg arhivskog preoznacavanja i izdvajanja kandidata
za uklanjanje iz kanonskog sloja, bez brisanja, bez preimenovanja,
bez commita i bez pusha.

---

## A. Polazni git dokaz

Polazni dokaz iz repoa:

- Lokalni HEAD: `c3141b5`
- Zadnji commit: `docs: procjena statusa paketa z138 do z142`
- Grana: `main`
- Stanje grane: `main` je poravnat s `origin/main`
- Remote hash: `c3141b56f41b15ad0f6de63544f13b92b1fa0e3d`
- `git diff --name-only`: prazno
- `git diff --cached --name-only`: prazno
- `git stash list`: `stash@{0}: On main: veritas-pre-rebase-z147`

Potvrda statusa 3 ciljane datoteke:

- sve su `EXISTS=True`
- sve su `TRACKED=True`
- sve su bez lokalne izmjene (`STATUS=` prazno)

Ciljani skup:

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`
- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`
- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`

Temelj procjene:

- `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`

---

## B. Datoteka za arhivsko preoznacavanje

Naziv:

- `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`

Razlog:

- Dokument je nastao kao Z140 presjek stanja u trenutku kada lokalni
  kanonski niz jos nije bio zatvoren i objavljen.
- Danas je taj operativni kontekst zatvoren kasnijim scoped commitima,
  pa je dokument prvenstveno povijesni auditni trag.

Minimalni buduci zahvat:

- Bez izmjene sadrzaja same datoteke, u zasebnom scoped koraku
  dodati arhivsku oznaku u kanonskoj mapi/statusu dokumentacije
  (npr. "povijesni trag - neodrzavan").
- Ne dirati tehnicki sadrzaj ni povijesni tekst dokumenta.

Procjena rizika buduceg zahvata:

- NIZAK.
- Arhivsko preoznacavanje je metapromjena nad evidencijom, ne dira
  pravila ingest/JSON toka niti brise dokazni sadrzaj.

---

## C. Datoteke kandidati za uklanjanje

### 1) RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md

Naziv:

- `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`

Razlog:

- Dokument je proceduralni planer za tada mjesovito lokalno stanje,
  s konkretnim preporukama commit redoslijeda prije zatvaranja niza.
- Nakon sto su kljucni koraci vec zatvoreni i objavljeni, vecina
  operativnih uputa je sadrzajno potrosena.

Minimalni buduci zahvat:

- U zasebnom scoped koraku oznaciti dokument kao kandidat za
  uklanjanje iz kanonskog sloja i, nakon finalne potvrde,
  ukloniti ga iz aktivnog kanonskog popisa.
- Samo uklanjanje iz repoa izvoditi tek u odvojenom koraku,
  ne zajedno s arhivskim preoznacavanjem.

Procjena rizika buduceg zahvata:

- SREDNJI.
- Rizik je gubitak lokalnog konteksta o povijesnom redoslijedu;
  prije uklanjanja treba potvrditi da je isti kontekst vec pokriven
  novijim dokaznim dokumentima i git povijescu.

### 2) Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md

Naziv:

- `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`

Razlog:

- Dokument je uski proceduralni vodič za parcijalno izdvajanje Z138
  hunka iz tada kumulativno mijesanog stanja.
- Nakon provedenog zatvaranja i stabilizacije grane, taj vodič vise
  nema aktivnu kanonsku funkciju.

Minimalni buduci zahvat:

- U zasebnom scoped koraku oznaciti datoteku kao kandidat za
  uklanjanje iz kanonskog sloja.
- U iducem, odvojenom koraku izvrsiti eventualno uklanjanje,
  tek nakon potvrde da nema preostalih operativnih ovisnosti.

Procjena rizika buduceg zahvata:

- NIZAK do SREDNJI.
- Rizik je mali jer je dokument proceduralan i vremenski vezan,
  ali treba provjeriti da svi relevantni dokazi vec postoje u
  commit povijesti i novijim pregledima.

---

## D. Preporuceni redoslijed buducih koraka

Predlozeni redoslijed (read-only prijedlog, bez izvrsenja sada):

1. Prvo napraviti zaseban scoped korak za arhivsko preoznacavanje
   dokumenta
   `ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
2. Zatim napraviti drugi, zaseban scoped korak koji samo priprema
   uklanjanje proceduralnih datoteka iz kanonskog sloja
   (`RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md` i
   `Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`).
3. Tek nakon potvrde tog koraka, napraviti treci scoped korak za
   eventualno stvarno uklanjanje navedene dvije datoteke.

Napomena:

- Ovaj dokument je iskljucivo read-only prijedlog.
- U ovom zadatku nije izvrseno nijedno brisanje, preimenovanje,
  commit ni push.
