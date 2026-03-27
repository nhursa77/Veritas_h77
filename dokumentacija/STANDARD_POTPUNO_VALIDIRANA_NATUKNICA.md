# STANDARD_POTPUNO_VALIDIRANA_NATUKNICA

Datum: 25.03.2026.
Status: kanonski
Opseg: pilot-zatvaranje prve potpuno validirane granske rjecnicke natuknice.

---

## 1) Svrha

Ovaj standard definira prvi zakljucani rjecnicki zapis u sloju potpuno
validiranih natuknica.

Radi se o pilot-obliku konacne validacije koji uspostavlja pravilo rada za
sljedeca zatvaranja.

---

## 2) Uvjeti zatvaranja

Potpuno validirana natuknica moze biti zatvorena samo ako ima:

- jednoznacan kontekst,
- dokaziva NN sidra,
- nekontradiktorna sidra unutar odabrane podnatuknice,
- jasan akt (`akt_slug`) i opis bez izmisljene definicije.

Nije dopusteno:

- izmisljati nova sidra,
- izmisljati definiciju ako nije dokaziva iz NN,
- zatvarati podnatuknicu koja i dalje trazi dodatno razbijanje.

---

## 3) Opseg po zadatku

U jednom zadatku zatvara se tocno jedna natuknica.

Sve ostale podnatuknice ostaju nepromijenjene i ne diraju se dok ne dodu na
red prema istom pravilu odabira.

Napomena o neuzastopnim clancima:

- redoslijed zatvaranja prati stvarno postojanje kandidata u ulazu,
- nije obavezno da clanci budu uzastopni,
- ako postoji skok u nizu (primjer `103 -> 122`), obavezna je zasebna
	dokazna analiza raspona koji nedostaje.

---

## 4) Obavezna polja potpuno validirane natuknice

- `nadredeni_pojam_id`
- `nadredeni_kanonski_naziv`
- `podnatuknica_id`
- `kanonski_naziv_podnatuknice`
- `pravna_grana_ili_kontekst`
- `naziv_akta`
- `akt_slug`
- `broj_nn`
- `nn_sidra`
- `status_podnatuknice = POTPUNO_VALIDIRANO`
- `datum_validacije`
- `izvor_validacije = "rucna_validacija"`
- `napomena_veritas`

---

## 5) Manifest i dokaznost

Manifest mora sadrzavati najmanje:

- ukupan broj granskih podnatuknica u ulazu,
- naziv odabrane podnatuknice,
- razlog odabira,
- broj potvrdenih sidara u odabranoj natuknici,
- popis svih sidara u odabranoj natuknici,
- potvrdu da je zatvorena samo jedna natuknica.

---

## 6) Odnos prema prethodnim slojevima

Sloj potpuno validirane natuknice nadovezuje se na granske podnatuknice i
ne mijenja njihove ulazne dokaze.

Pilot-zatvaranje ne ukida potrebu za buducim rucnim validacijama ostalih
podnatuknica.
