# STANDARD_JSON_RJECNICKA_NATUKNICA

Datum: 18.03.2026.
Status: kanonski
Opseg: JSON model jedne rječničke natuknice Veritas H.77.

---

## 1) Svrha

Ovaj standard definira kanonski model digitalne rječničke natuknice.
Model je operativni i pripremni: ne uvodi pravne učinke i ne zamjenjuje
normativno sidrenje na Narodne novine.

---

## 2) Obavezna polja natuknice

Svaka natuknica mora imati sljedeća polja:

- `pojam_id`
- `kanonski_naziv`
- `sinonimi`
- `varijante_pisanja`
- `strani_ekvivalenti`
- `kratice`
- `vrsta_pojma`
- `definicija_jezicna`
- `definicija_procesna`
- `definicija_normativna`
- `napomena_veritas`
- `nn_sidra`
- `povezani_pojmovi`
- `tipicne_pogreske`
- `status_validacije`
- `razina_pouzdanosti`

---

## 3) Pravila popunjavanja (faza bez NN sidra)

Za početni operativni skup vrijede ova pravila:

- ne izmišljati pravne definicije
- ne izmišljati NN sidra
- ne izmišljati tipične pogreške bez dokazive osnove
- popuniti samo tehnički dokaziva polja iz ulaza
- nepokrivena polja postaviti na dosljedne prazne vrijednosti

U ovoj fazi preporučene prazne vrijednosti su:

- tekstualna polja bez dokaza: `null`
- kolekcije bez dokaza: `[]`
- `nn_sidra`: prazna struktura `{}`

---

## 4) Kontrolirani skup `vrsta_pojma`

Dopuštene vrijednosti polja `vrsta_pojma` su:

- `PROCESNI_POJAM`
- `PRAVNI_INSTITUT`
- `PRAVNA_RADNJA`
- `PRAVNI_AKT`
- `TIJELO_ILI_NADLEZNOST`
- `ROK`
- `DOKAZNO_SREDSTVO`
- `STATUS_ILI_SVOJSTVO`
- `SANKCIJA`
- `TROSAK_ILI_PRISTOJBA`
- `NEKLASIFICIRANO`

Ako klasifikacija nije deterministički jasna iz naziva i postojećih
tehničkih oznaka, mora se koristiti `NEKLASIFICIRANO`.

---

## 5) Razlika između definicija i napomene

### Jezična definicija (`definicija_jezicna`)

Jezična definicija opisuje značenje pojma na razini terminologije i jezika.
Ne uvodi pravni učinak i ne navodi pravila postupanja.

### Procesna definicija (`definicija_procesna`)

Procesna definicija opisuje funkciju pojma u tijeku postupka
(redoslijed, uloga, preduvjeti, rokovi), ali bez normativnog sidra.

### Normativna definicija (`definicija_normativna`)

Normativna definicija postoji tek kada je pojam sidren u dokazni izvor
(NN članak, stavak, točka ili drugi formalno dokaziv izvor).
Bez sidra mora ostati `null`.

### Veritas napomena (`napomena_veritas`)

Veritas napomena je tehnička ili metodološka bilješka o kvaliteti,
ograničenjima ili potrebi ručne provjere.
Nije pravna definicija i ne smije glumiti normativni zaključak.

---

## 6) Pravila validacije

U fazi početne izgradnje vrijedi:

- `status_validacije` mora biti `CEKA_NN_SIDRO`
- `razina_pouzdanosti` preuzima se iz ulaza kada postoji
- ako u ulazu nema valjane vrijednosti, postavlja se `NISKA`

`nn_sidra` mora postojati kao prazna struktura spremna za buduće sidrenje.

---

## 7) Minimalni primjer natuknice

```json
{
  "pojam_id": "VH77-RJ-1234567890ab",
  "kanonski_naziv": "primjer pojma",
  "sinonimi": [],
  "varijante_pisanja": [],
  "strani_ekvivalenti": [],
  "kratice": [],
  "vrsta_pojma": "NEKLASIFICIRANO",
  "definicija_jezicna": null,
  "definicija_procesna": null,
  "definicija_normativna": null,
  "napomena_veritas": null,
  "nn_sidra": {},
  "povezani_pojmovi": [],
  "tipicne_pogreske": [],
  "status_validacije": "CEKA_NN_SIDRO",
  "razina_pouzdanosti": "NISKA"
}
```

---

## 8) Veza s pilot-sidrenjem

Nakon početne izgradnje natuknica, pilot-odabir za prvo NN sidrenje izvodi
se prema dokumentu `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`.

Taj korak ne mijenja pravilo da se definicije i NN sidra ne izmišljaju,
nego samo deterministički prioritizira natuknice za ručni pregled.

Sljedeći korak su jezgrene natuknice prema
`STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`, gdje se iz pilot-skupa
izdvajaju osnovni pojmovi, a složene fraze ostaju izvan jezgre.

Nakon jezgre slijedi proširenje na osnovni postupovni skup prema
`STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`, bez dodavanja
definicija i bez dodavanja NN sidara.
