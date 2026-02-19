# STANDARD_RIZIK_I_KOLIZIJE

Datum: 17.02.2026.
Status: kanonski

---

## 0) Svrha i opseg

Ovaj standard određuje pravila za procjenu procesnog rizika, detekciju
kolizija i evidentiranje odluka nositelja kada odstupa od preporuke.
Standard se primjenjuje na sve korake koji mogu proizvesti vanjski izlaz.

---

## 1) Definicije

- `risk_score`: brojčana procjena ukupnog rizika u rasponu 0-100.
- `risk_flags`: popis aktivnih oznaka rizika koje su utjecale na rezultat.
- `conflict_flag`: oznaka da je otkrivena kolizija ili bitna nejasnoća.
- `override_log`: zapis odluke nositelja kojom preuzima svjesno odstupanje.

---

## 2) Risk scoring (kriteriji i bodovi)

Ukupni `risk_score` je zbroj kriterija, ograničen na 100.

| Kriterij | 0 bodova | 5-10 bodova | 15-20 bodova |
| --- | --- | --- | --- |
| Rokovi | rok jasan i unutar roka | rok blizu isteka | rok istekao ili sporan |
| Nadležnost | potpuno jasna | djelomično jasna | nejasna ili osporena |
| Dok. pokriv. | ključni dokazi su tu | dio dokaza fali | ključni dokaz fali |
| Sidra | status puno | status djelomično | status bez |
| Kolizije | nema kolizije | manja nejasnoća | kolizija normi potvrđena |
| Šteta posljedica | niska posljedica | srednja posljedica | visoka posljedica |
| Reverzibilnost | lako reverzibilna | djelomice reverz. | teško reverzibilna |

Tumačenje razine rizika:
- 0-30: nisko
- 31-60: srednje
- 61-80: visoko
- 81-100: kritično

---

## 3) Detektor kolizija

`conflict_flag` postaje aktivan i izlaz je blokiran kada je ispunjeno barem
jedno od sljedećeg:

- postoji kolizija normi bez razriješenog pravila nadređenosti,
- nadležnost je nejasna i nije potvrđen zakonit put postupanja,
- rok je sporan ili nije moguće dokazati pravodobnost,
- status sidra je `bez`,
- dokazi nisu dostatni za izvršenje konkretnog koraka,
- operativni i dokazni izvor su neusuglašeni bez jasne napomene.

Ako je `conflict_flag` aktivan, status izlaza ne može prijeći u
`SPREMNO ZA POTPIS` dok se konflikt ne riješi ili ne evidentira override.

---

## 4) Evidencija odluke nositelja (override)

`override_log` se upisuje kada nositelj svjesno nastavlja unatoč riziku ili
aktivnom konfliktu.

Minimalna polja zapisa:
- datum odluke (`DD.MM.YYYY.`),
- identifikator predmeta,
- sažetak konflikta i rizika,
- obrazloženje nositelja,
- potvrda da nositelj preuzima odluku,
- hash zapisa (`SHA-256`) i hash povezanog izlaza.

Hashiranje se radi nad kanoniziranim sadržajem `override_log` zapisa.
Zapis se čuva uz predmet i mora biti provjerljiv u lancu skrbništva.

---

## 5) Veza na statuse izlaza i gate pravila

Primjena prema kanonskim statusima:

- `NACRT`: dopušten uz aktivne rizike, uz jasno označene zastavice.
- `PROVJERENO`: zahtijeva riješene ključne nejasnoće i potvrđene osnove.
- `SPREMNO ZA POTPIS`: nije dopušteno kada je `conflict_flag` aktivan.
- `POTPISANO`: moguće tek nakon potpisa nositelja i evidentirane odluke.
- `FORENZIČKI ZAKLJUČANO`: uključuje manifest, hash i zaključan trag.

Ako postoji override, mora biti vidljiv prije potpisa i prije vanjske uporabe.

---

## 6) Minimalni JSON primjer

```json
{
  "risk_score": 74,
  "risk_flags": [
    "rok_sporan",
    "sidro_djelomicno",
    "dokazi_nepotpuni"
  ],
  "conflict_flag": true,
  "conflict_razlog": "nadleznost_nejasna",
  "override_log": {
    "datum": "17.02.2026.",
    "predmet_id": "PILOT-USTAV-001",
    "odluka_nositelja": "nastavak_unatoc_riziku",
    "obrazlozenje": "Nastavlja se radi zastite roka uz oznaku rizika.",
    "potvrda": true,
    "sha256_override": null
  }
}
```

---

## Zaključna norma

Svako odstupanje je nekanonsko i mora se ispraviti prije vanjske uporabe.
