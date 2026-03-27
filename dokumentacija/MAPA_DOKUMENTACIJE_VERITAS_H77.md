# MAPA_DOKUMENTACIJE_VERITAS_H77

Datum: 17.02.2026.
Status: kanonski
Opseg: navigacija kroz postojeću dokumentaciju Veritas H.77.

---

## 1) Kanon u 11 točaka

1) Jezik dokumentacije i zapisa je hrvatski.
2) Datumi se zapisuju u formatu `DD.MM.YYYY.`.
3) Ograničenje retka je MD013, najviše 80 znakova po retku.
4) Dokumenti imaju opisna imena datoteka.
5) Veritas generira isključivo na upit.
6) Veritas ne potpisuje i ne šalje.
7) Čovjek odlučuje o potpisu i slanju.
8) zakon.hr je operativni izvor, Narodne novine su dokazna sidra.
9) NORMA JSON i POSTUPAK JSON su obavezni standardi.
10) Svaki značajan korak evidentira se u `DNEVNIK_RADA.md`.
11) `DNEVNIK_RADA.md` je append-only i ne smije se prepisivati.

---

## 2) Kanonski dokumenti

### `METODOLOGIJA_RADA_VERITAS_H77.md`
Definira što je Veritas H.77, kako radi i gdje su granice odgovornosti.
Sadrži hijerarhiju normi, pravilo izvora i gate pravila statusa izlaza.

### `RJEČNIK_POJMOVA_VERITAS_H77.md`
Definira pojmove koji se koriste u dokumentima, JSON zapisima i obradi.
Osigurava jednoznačno značenje ključnih termina.

### `TEHNIČKI_OKVIR_VERITAS_H77.md`
Definira tehnički okvir rada repozitorija i reprodukcije okruženja.
Sadrži pravila artefakata, izvora, snapshota i kontrole kvalitete.

### `STANDARD_JSON_NORMA.md`
Definira standard zapisa norme u JSON formatu s člankom kao jedinicom.
Uređuje strukturu, izvore, sidra i uvjete valjanosti normativnog zapisa.

### `STANDARD_JSON_POSTUPAK.md`
Definira standard proceduralnih koraka u JSON formatu.
Uređuje gate uvjete, ulaze, radnje i izlaze postupanja.

### `STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
Definira standard ulaza (INTAKE) za prekršajne tokove v1.
Uređuje cilj, osporavanja, događaj i obavezna polja za validaciju.

### `STANDARD_JSON_AUDIT_PRIMJENE.md`
Definira kanonski audit primjene i statusne ishode po modulima.
Uređuje nalaze, gate stanje i mapiranje u izlazne nacrte.

### `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
Definira determinističko generiranje runtime audita za P6.
Uređuje NAP-MIN klase, semafor i G1 soft pravilo.

### `STANDARD_JSON_SUBSUMPCIJA.md`
Definira standard subsumpcije činjenica na norme i pravila.
Uređuje argumentaciju i poveznice na normativna sidra.

### `STANDARD_JSON_HIJERARHIJA.md`
Definira hijerarhiju normativnih izvora i pravila prvenstva.
Uređuje razrješenje kolizija i prioritet izvora.

### `STANDARD_JSON_PREDLOZAK.md`
Definira standard predložaka i mapiranja izvora u nacrt.
Uređuje dopuštene izvore, uključujući intake.* u mapiranjima.

### `STANDARD_FER_NAPLATA_PREKRSAJI.md`
Definira standard fer naplate u prekršajnom modulu.
Uređuje pravila obračuna i kontrolne uvjete naplate.

### `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
Definira obavezne markere i format izlaznog nacrta v1.
Uređuje minimalni sadržaj nacrta za validator izlaza.

### `RAZVOJNI_PLAN_VERITAS_H77.md`
Definira faze razvoja sustava, redoslijed rada i operativne gate uvjete.
Služi kao plan izvođenja od MVP-a do prvog živog predmeta.

### `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
Definira kanonske faze, artefakte, putanje i gate kriterije prekršajnog
modula kao pilot domenu.

### `DNEVNIK_RADA.md`
Evidentira značajne korake rada kronološki.
Služi kao dokazni trag promjena i odluka kroz vrijeme.

### `STANDARD_ZASTITA_DNEVNIKA_RADA.md`
Definira tvrdu zaštitu datoteke dnevnika rada.
Uređuje append-only unos, zabranu prepisivanja i dokazne ispise prije/poslije.

### `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`
Zamrzava trenutno stanje repozitorija za nastavak rada bez
kopanja po povijesti.
Sadrži stanje grane, zadnje commitove, čistoću repoa i aktivne gate markere.

### `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
Definira dokazne terminološke izvore za višejezične ekvivalente.
Uređuje ulogu CURIA/IATE izvora i ograničenja prema pravnom učinku.

### `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
Definira kanonski format normaliziranog terminološkog zapisa.
Uređuje sljedivost prema raw izvozu bez pravnog tumačenja.

### `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
Definira tehnički kriterij izdvajanja hrvatski relevantnih zapisa.
Uređuje granicu prema pravnim institutima i pripremu za NN sidrenje.

### `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
Definira tehničko mapiranje EU termina prema potencijalnim NN pojmovima.
Uređuje status prijedloga bez normativnog sidrenja i ručnu provjeru.

### `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
Definira izdvajanje prioritetnog radnog uzorka iz EU -> NN prijedloga.
Uređuje operativni redoslijed za sljedeći korak NN sidrenja.

### `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
Definira čišćenje prioritetnog uzorka na NN-sidrenju podobne kandidate.
Uređuje uklanjanje tehničkog šuma prije ručnog NN pregleda.

### `STANDARD_JSON_RJECNICKA_NATUKNICA.md`
Definira kanonski JSON model jedne rječničke natuknice Veritas H.77.
Uređuje početni operativni skup bez NN sidra i prazna polja za sidrenje.

### `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
Definira izdvajanje pilot-skupa rječničkih natuknica za prvo NN sidrenje.
Uređuje determinističke kriterije prioriteta i obavezna pilot-polja.

### `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
Definira izdvajanje jezgrenih natuknica iz pilot-skupa za prvo NN sidrenje.
Uređuje odvajanje osnovnih pojmova od složenih procesnih fraza.

### `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
Definira proširenje jezgre na osnovni postupovni skup za prvo NN sidrenje.
Uređuje balans između uskog jezgrenog i općeg postupovnog obuhvata.

### `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
Definira prvo stvarno NN sidrenje rječničkih natuknica.
Uređuje status sidra, višeznačnost i zabranu prisilnog sužavanja na jedno sidro.

### `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
Definira razlaganje višeznačnih i nejasnih NN sidara u kandidatske podnatuknice.
Uređuje razdvajanje po aktu/kontekstu bez konačnog ručnog presuđivanja.

### `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
Definira sužavanje v2 kandidata u konačne podnatuknice za ručnu validaciju.
Uređuje granicu između grupiranja istog konteksta i zadržavanja različitog
akta ili različitog normativnog konteksta.

### `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
Definira ručnu validaciju konačnih NN kandidata i upis potvrđenih sidara u
validirani sloj rječničkih natuknica.
Uređuje statuse konačne validacije i pravilo da bez ljudske potvrde nema
konačnog odabira sidra.

### `STANDARD_GRANSKE_PODNATUKNICE_NN.md`
Definira konsolidaciju validiranih sidara u granske rječničke podnatuknice.
Uređuje tehničko razdvajanje po dokazivom kontekstu (grana/akt) bez
slobodnog pravnog tumačenja.
U korekciji v2 precizira razdvajanje po stvarnom normativnom kontekstu,
bez lažnog sažimanja više sidara u jedan zapis.

### `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
Definira pilot-zatvaranje prve potpuno validirane granske natuknice.
Uređuje uvjete jednoznačnog konteksta i dokazivih NN sidara,
uz pravilo da se u jednom zadatku zatvara točno jedna natuknica.
Operativno zatvaranje izvode skripte
`alati/zatvori_prvu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_drugu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py` i
`alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`.

### `STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
Definira kanonski model sinkronizacije lokalnog repoa, GitHuba i
Google Disk kopije.
Uređuje da je GitHub izvor istine, lokalna mapa jedina radna kopija,
a Drive samo sinkronizirana kopija/backup.

---

## 3) Redoslijed čitanja

1) `METODOLOGIJA_RADA_VERITAS_H77.md`
2) `RJEČNIK_POJMOVA_VERITAS_H77.md`
3) `TEHNIČKI_OKVIR_VERITAS_H77.md`
4) `STANDARD_JSON_NORMA.md`
5) `STANDARD_JSON_POSTUPAK.md`
6) `RAZVOJNI_PLAN_VERITAS_H77.md`
7) `DNEVNIK_RADA.md`
8) `STANDARD_ZASTITA_DNEVNIKA_RADA.md`
9) `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`
10) `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
11) `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
12) `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
13) `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
14) `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
15) `STANDARD_JSON_RJECNICKA_NATUKNICA.md`
16) `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
17) `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
18) `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
19) `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
20) `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
21) `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
22) `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
23) `STANDARD_GRANSKE_PODNATUKNICE_NN.md`
24) `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
25) `STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
26) `PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`

### Redoslijed čitanja — prekršajni modul

1) `RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
2) `STANDARD_FER_NAPLATA_PREKRSAJI.md`
3) `STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
4) `STANDARD_JSON_AUDIT_PRIMJENE.md`
5) `STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
6) `STANDARD_JSON_SUBSUMPCIJA.md`
7) `STANDARD_JSON_HIJERARHIJA.md`
8) `STANDARD_JSON_PREDLOZAK.md`
9) `STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
10) `dokumentacija/sheme/SCHEMA_INTAKE_PREKRSAJI_V1.json`
11) `dokumentacija/sheme/SCHEMA_AUDIT_V1.json`
12) `dokumentacija/sheme/SCHEMA_SUBSUMPCIJA_V1.json`
13) `dokumentacija/sheme/SCHEMA_PREDLOZAK_V1.json`
14) `alati/validiraj_intake_prekrsaji_v1.ps1`
15) `alati/validiraj_audit_v1.ps1`
16) `alati/validiraj_subsumciju_v1.ps1`
17) `alati/validiraj_predlozak_v1.ps1`
18) `alati/generiraj_audit_prekrsaji_v1.ps1`
19) `alati/validiraj_audit_generated_v1.ps1`
20) `alati/run_tok_v1.ps1`
21) `alati/ci_smoke.ps1`

---

## 4) Pravilo održavanja indexa

Kad se doda novi dokument ili izmijeni postojeći, mora se ažurirati i ovaj
index.
Svako ažuriranje indexa evidentira se u `DNEVNIK_RADA.md`.

---

## 5) Gdje što pripada

- Norme pripadaju standardu `STANDARD_JSON_NORMA.md` i zapisima NORMA JSON.
- Postupci pripadaju standardu `STANDARD_JSON_POSTUPAK.md` i PROCEDURA JSON.
- Pojmovi i definicije pripadaju `RJEČNIK_POJMOVA_VERITAS_H77.md`.
- Tehničke odluke pripadaju `TEHNIČKI_OKVIR_VERITAS_H77.md`.
- Opća metodologija i gate logika pripadaju
  `METODOLOGIJA_RADA_VERITAS_H77.md`.
- Razvojne faze i redoslijed rada pripadaju `RAZVOJNI_PLAN_VERITAS_H77.md`.
- Kronologija stvarnog rada pripada `DNEVNIK_RADA.md`.
- Zaštita dnevnika rada pripada
  `STANDARD_ZASTITA_DNEVNIKA_RADA.md`.
- Terminološki dokazni i operativni izvori pripadaju
  `IZVORI_TERMINOLOGIJE_VERITAS_H77.md`, a tehnički izvoz iz CURIA XLSX
  izvodi `alati/pretvori_curia_xlsx_u_json.py`; normalizacija u kanonski
  sloj izvodi `alati/normaliziraj_curia_terminologiju.py` prema
  `STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`, dok segmentaciju operativnog
  formata izvodi `alati/segmentiraj_curia_terminoloske_zapise.py`; izdvajanje
  hrvatski relevantnog sloja izvodi
  `alati/izdvoji_hrvatski_relevantne_curia_termini.py` prema
  `STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`; tehničko mapiranje
  prema potencijalnim NN pojmovima izvodi
  `alati/mapiraj_curia_na_potencijalne_nn_pojmove.py` prema
  `STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`; izdvajanje prioritetnog
  uzorka izvodi `alati/izdvoji_prioritetni_uzorak_za_nn_sidrenje.py` prema
  `STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`; čišćenje uzorka izvodi
  `alati/ocisti_prioritetni_uzorak_za_nn_sidrenje.py` prema
  `STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`; izgradnju početnih
  rječničkih natuknica izvodi
  `alati/izgradi_pocetne_rjecnicke_natuknice.py` prema
  `STANDARD_JSON_RJECNICKA_NATUKNICA.md`; izdvajanje pilot-skupa izvodi
  `alati/izdvoji_pilot_natuknice_za_nn_sidrenje.py` prema
  `STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`; izdvajanje jezgrenih
  natuknica izvodi `alati/izdvoji_jezgrene_natuknice_iz_pilota.py` prema
  `STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`; proširenje na osnovni
  postupovni skup izvodi
  `alati/prosiri_jezgrene_natuknice_na_osnovni_postupovni_skup.py` prema
  `STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`; prvo stvarno
  NN sidrenje osnovnog skupa izvodi
  `alati/sidri_osnovni_postupovni_skup_na_nn.py` prema
  `STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`; razlaganje višeznačnih
  sidara u kandidatske podnatuknice izvodi
  `alati/razlozi_viseznacna_nn_sidra_po_aktu.py` prema
  `STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`; ispravak razlaganja na
  stvarne kandidate po pojedinom sidru izvodi
  `alati/ispravi_razlaganje_nn_kandidata.py` i generira
  `kandidatske_podnatuknice_nn_v2.json` + manifest; sužavanje v2 kandidata
  za ručnu validaciju izvodi
  `alati/suzi_nn_kandidate_za_rucnu_validaciju.py` prema
  `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md` i generira
  `konacni_nn_kandidati_za_validaciju.json` + manifest; ručna validacija i
  upis potvrđenih sidara izvodi
  `alati/upisi_validirana_nn_sidra_u_natuknice.py` prema
  `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md` i generira
  `osnovni_postupovni_skup_nn_validiran.json` + manifest; granska
  konsolidacija validiranih pojmova izvodi
  `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py` prema
  `STANDARD_GRANSKE_PODNATUKNICE_NN.md` i generira
  `granske_podnatuknice_nn.json` + manifest; korekcija konsolidacije
  generira `granske_podnatuknice_nn_v2.json` + v2 manifest.
