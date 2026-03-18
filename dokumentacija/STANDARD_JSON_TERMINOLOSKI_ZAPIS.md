# STANDARD_JSON_TERMINOLOSKI_ZAPIS

Datum: 18.03.2026.
Status: kanonski
Opseg: operativni JSON zapis terminoloških podataka iz EU izvora.

---

## 1) Svrha

Standard definira kanonski format jednog normaliziranog terminološkog
zapisa u Veritas repozitoriju.

Cilj je tehnička sljedivost izvora i dosljedna strojna obrada bez pravnog
zaključivanja.

---

## 2) Obavezna polja zapisa

Svaki zapis mora imati najmanje ova polja:

- `izvor_sustav`
- `izvor_datoteka`
- `worksheet`
- `redni_broj_izvora`
- `pojam_izvornik`
- `jezik_izvornika`
- `ekvivalenti`
- `napomena`
- `pravna_referenca`
- `oznaka_zapisa`
- `status_normalizacije`

---

## 3) Svrha polja

- `izvor_sustav`: identifikator izvornog sustava (npr. CURIA/IATE).
- `izvor_datoteka`: putanja ili naziv izvornog artefakta.
- `worksheet`: naziv izvornog worksheeta za sljedivost.
- `redni_broj_izvora`: redni broj retka iz izvornog skupa.
- `pojam_izvornik`: izvorni termin, bez pravnog tumačenja.
- `jezik_izvornika`: jezik izvornog termina ako je dostupan.
- `ekvivalenti`: sirovi ekvivalenti iz izvora, bez deduplikacije.
- `napomena`: dodatna napomena iz izvora, ako postoji.
- `pravna_referenca`: referenca iz izvora, ako postoji.
- `oznaka_zapisa`: deterministički identifikator zapisa.
- `status_normalizacije`: status obrade zapisa.

---

## 4) Raw izvoz vs normalizirani zapis

Raw izvoz (`*_raw.json`) predstavlja tehničko preslikavanje izvornog
rasporeda worksheetova i redaka.

Normalizirani zapis (`terminoloski_zapisi.json`) predstavlja operativni
kanonski sloj sa standardiziranim poljima i sljedivošću prema izvornom retku.

Normalizacija ne uvodi pravna tumačenja, ne deduplicira pojmove i ne spaja
jezike "pametno".

---

## 5) Odnos prema NN i pravnim institutima RH

EU terminološki zapis nije isto što i institut po Narodnim novinama.

Narodne novine ostaju primarno pravno sidro za učinak i primjenu u RH,
dok EU terminološki sloj služi kao pomoćni jezično-terminološki međusloj.
