# STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77

Datum: 25.03.2026.
Status: kanonski
Opseg: sinkronizacija lokalnog repoa, GitHub repozitorija i Google Disk kopije.

---

## 1) Kanonske uloge izvora

- GitHub repozitorij `nhursa77/Veritas_h77` je kanonski izvor istine.
- Lokalna mapa `C:\Veritas_H77` je jedina radna kopija za razvoj i Copilot
  zadatke.
- Google Disk kopija projekta je sinkronizirana kopija, backup i pregled,
  nije paralelni izvor uredjivanja istih datoteka.

---

## 2) Zabranjena paralelna uredjivanja

Zabranjeno je paralelno rucno uredjivati iste datoteke tipa `.md`, `.py` i
`.json` i u lokalnom repou i u Google Disk kopiji.

Ako je potrebna izmjena, radi se iskljucivo u lokalnoj radnoj kopiji.

---

## 3) Obavezni redoslijed rada

Obavezan redoslijed je:

1. lokalna izmjena,
2. gate provjere,
3. commit,
4. push na GitHub,
5. tek nakon toga osvjezavanje Google Disk kopije.

Ako lokalni `main` nije poravnat s `origin/main`, Google Disk kopija se ne
smije smatrati azurnom.

---

## 4) Pravilo prednosti kod razlika

Ako postoje razlike izmedju lokalnog repoa, GitHuba i Drive kopije,
prednost ima GitHub nakon uspjesnog push-a.

Lokalna kopija se smatra valjanom radnom osnovom samo kada je lokalni `main`
uskladjen s `origin/main` ili kada je razlika svjesno i privremeno stanje
prije push-a u aktivnom zadatku.

---

## 5) Obavezna provjera sinkronizacije

Minimalna provjera sinkronizacije mora ukljucivati:

- zadnji commit hash,
- `git status --short`,
- `git branch -vv`,
- provjeru da kljucne datoteke postoje i odgovaraju kanonskom stanju.

---

## 6) Razlika izmedju pre-check snapshota i zavrsnog git dokaza

Potrebno je strogo razlikovati dvije vrste dokaza:

- pre-check snapshot prije zadatka
- zavrsni git dokaz nakon commita i push-a

Pre-check snapshot sluzi za stabilan opis pocetnog stanja zadatka i smije
evidentirati samo:

- polazni HEAD prije zadatka,
- cistocu repoa pri pre-checku,
- poravnanje grane pri pre-checku.

Zavrsni git dokaz sluzi za potvrdu da je zadatak zaista zakljucen i mora
ostati odvojen od statusnog snapshot zapisa. Zavrsni dokaz obuhvaca:

- `git status --short`,
- `git --no-pager log -1 --oneline`,
- `git branch -vv`.

Minimalni skup kljucnih datoteka za provjeru:

- `README.md`,
- `dokumentacija/METODOLOGIJA_RADA_VERITAS_H77.md`,
- `dokumentacija/TEHNIČKI_OKVIR_VERITAS_H77.md`,
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
- `dokumentacija/DNEVNIK_RADA.md`.

---

## 7) Operativna napomena za Google Disk

Google Disk kopija sluzi za:

- sinkronizirani pregled,
- dodatni backup,
- dijeljenje read-only stanja kada je potrebno.

Google Disk kopija ne sluzi za paralelni development i ne zamjenjuje Git
workflow.
