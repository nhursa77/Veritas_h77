# STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA

Datum: 18.03.2026.
Status: kanonski
Opseg: prvo stvarno NN sidrenje rječničkih natuknica.

---

## 1) Svrha

Ovaj standard definira kako rječnička natuknica dobiva dokazivo mjesto u
izvorima Narodnih novina bez izmišljanja članaka i bez prisilnog pravnog
zaključivanja kod višeznačnih pojmova.

---

## 2) Primarni izvor

Narodne novine su jedini primarni dokazni izvor za normativna sidra.

- `zakon.hr` se smije koristiti samo pomoćno za orijentaciju ili kontrolu.
- `zakon.hr` se ne smije koristiti kao primarno sidro.
- bez valjanog NN izvora nema upisa potvrđenog normativnog sidra.

---

## 3) Razlika ključnih pojmova

### Normativno sidro

Normativno sidro je dokaziva referenca na NN članak (i po potrebi stavak/točku)
koja povezuje natuknicu s tekstom propisa.

### Normativna definicija

Normativna definicija je izričita definicija pojma iz samog NN teksta.
Ako takva definicija nije dokazivo prisutna, `definicija_normativna` ostaje
`null`.

### Više mogućih sidara

Više mogućih sidara znači da postoji više relevantnih NN uporišta za isti
pojam i da se u prvom sloju ne smije proizvoljno odabrati samo jedno.
Status je `VISE_MOGUCIH_SIDARA`.

### Nejasno sidro

Nejasno sidro znači da postoji djelomično relevantan trag, ali pojam nije
jednoznačno potvrđen kao normativna fraza u dostupnom NN tekstu.
Status je `NEJASNO`.

---

## 4) Pravilo za višeznačne pojmove

Višeznačni pojmovi (npr. žalba, prigovor, rješenje, presuda) ne smiju se
nasilno svoditi na jedno sidro bez jasnog dokaza.

U takvim slučajevima:

- upisuju se sva relevantna sidra u listu,
- status ostaje `VISE_MOGUCIH_SIDARA`,
- `status_validacije` se postavlja na `CEKA_RUCNU_PROVJERU_NN`.

---

## 5) Obavezna struktura `nn_sidra`

Svaka sidrena natuknica mora imati:

- `status_sidra`
- `sidra` (lista)

Svako sidro u listi mora imati najmanje:

- `naziv_akta`
- `akt_slug`
- `broj_nn`
- `clanak`
- `stavak`
- `tocka`
- `izvor_putanja`
- `napomena`

Ako stavak ili točka ne postoje, vrijednost je `null`.

---

## 6) Statusna pravila

Dopuštene vrijednosti `status_sidra`:

- `OK`
- `VISE_MOGUCIH_SIDARA`
- `NEJASNO`
- `NEDOSTAJE`

Mapiranje u `status_validacije`:

- `OK` -> `NN_SIDRENO`
- `VISE_MOGUCIH_SIDARA` -> `CEKA_RUCNU_PROVJERU_NN`
- `NEJASNO` -> `CEKA_RUCNU_PROVJERU_NN`
- `NEDOSTAJE` -> `CEKA_NN_SIDRO`

---

## 7) Operativna zabrana izmišljanja

U prvom stvarnom NN sidrenju nije dopušteno:

- izmišljati članak, stavak ili točku,
- izmišljati normativnu definiciju,
- svoditi višeznačnost na jedno sidro bez dokaza,
- upisivati sidro bez valjanog NN izvora u repozitoriju.
