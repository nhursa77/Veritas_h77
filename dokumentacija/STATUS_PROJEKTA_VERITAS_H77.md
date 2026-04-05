# STATUS_PROJEKTA_VERITAS_H77

Datum: 05.04.2026.

## Snapshot repozitorija

- Polazni HEAD prije zadatka: `16628b1` - docs: popis referenci na
  wrappere prekrsajni json validatori v1 nakon preusmjerenja ci smoke
- Repo čist pri pre-checku: DA
- Poravnanje grane pri pre-checku: poravnat s `origin/main`
- Zadnji dovršeni zadatak: ZADATAK 167

## Operativno stanje skupine PREKRSAJNI_JSON_VALIDATORI_V1

- Pet wrapper validatora uklonjeno je nakon dokazne repo-pretrage
  removal spremnosti.
- Schema-driven validacija ostaje centralizirana u
  `alati/validiraj_json_po_shemi_v1.ps1`, a `alati/ci_smoke.ps1`
  ostaje kompatibilan jer je vec preusmjeren na genericki alat.
- Aktivnih operativnih referenci na stara imena vise nema.

## Pregled dovršenih zadataka

- ZADATAK 89: plansko uskladjenje nakon zatvaranja rjecnickog toka
- ZADATAK 90: definiran prioritetni redoslijed konverzije zakona u JSON
- ZADATAK 92: za `zakon_o_opcem_upravnom_postupku` utvrdjen rezim
  konverzije prema kanonskom dokumentu
  `dokumentacija/REZIM_KONVERZIJE_ZUP_U_JSON.md`
- ZADATAK 93: pripremljen je manifest ingest-a
  `paketi/PAKET_ZUP_V1.json` (core + amandman + kontrolni izvor)
- ZADATAK 94: proveden je stvarni ingest paketa
  `paketi/PAKET_ZUP_V1.json` za core i amandman (`EXIT=0`), uz minimalnu
  korekciju manifesta (`tip_teksta` za core: `procisceni`)
- ZADATAK 95: proveden je kontrolni dohvat sa zakon.hr i usporedba
  `baza_zakona/norme/zakon_o_opcem_upravnom_postupku_procisceni/`
  naspram kontrolnog teksta
  `izvori/kontrolno/zakon_hr/zakon_o_opcem_upravnom_postupku/`
  kroz postojeći validator `alati/validiraj_nn_vs_kontrolno.py`
  (CONTROL_COUNT=171, NN_COUNT=171, MISSING_COUNT=0)
  uz heuristicki signal `CONTROL_TRUNCATION_SUSPECTED=True`.
- ZADATAK 96: ciljano su sanirani članci iz SHORT_LIST (15 datoteka)
  uklanjanjem artefakata ingest-a (`". "` prefiks i prijelazni naslovi
  sljedećih cjelina) uz preračun integritetnih hash polja.
  Ponovljena validacija je potvrdila
  `CONTROL_COUNT=171`, `NN_COUNT=171`, `MISSING_COUNT=0` i
  `SHORT_COUNT=15` (članci ostaju kratki po sadržaju, bez truncation
  artefakta).
- ZADATAK 98: revidirana je heuristika u
  `alati/validiraj_nn_vs_kontrolno.py` za detekciju truncation signala
  kontrolnog izvora. Potvrdeno je da `SHORT_COUNT=15` predstavlja legitimno
  kratke članke, a ne truncation artefakt. Ponovljena validacija daje:
  `CONTROL_COUNT=171`, `NN_COUNT=171`, `MISSING_COUNT=0`,
  `SHORT_COUNT=15`, `CONTROL_TRUNCATION_SUSPECTED=False`.
- ZADATAK 99: utvrdjen je kanonski rezim konverzije za
  `zakon_o_upravnim_sporovima` u dokumentu
  `dokumentacija/REZIM_KONVERZIJE_ZUS_U_JSON.md`.
  Kako na NN pretrazi nije dokazan valjan procisceni signal,
  operativna odluka je:
  `REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL`.
- ZADATAK 100: rezim konverzije za
  `zakon_o_upravnim_sporovima` je ispravljen.
  ZUS se vodi po obrascu tipa `ustav_rh_procisceni`,
  kao jedan vazeci cjeloviti akt (`NN 36/2024`),
  bez koristenja starog niza izmjena i bez modela
  `prekrsajni_zakon` za vazeci ZUS.
- ZADATAK 101: pripremljen je manifest ingest-a
  `paketi/PAKET_ZUS_V1.json` za važeći
  `zakon_o_upravnim_sporovima` (`NN 36/2024`) kao jedan važeći
  cjeloviti akt po obrascu `ustav_rh_procisceni` s `zakon.hr` kao
  kontrolnim izvorom za validaciju.
  Ažurirana dokumentacija: `STATUS_PROJEKTA_VERITAS_H77.md`,
  `MAPA_DOKUMENTACIJE_VERITAS_H77.md`, `DNEVNIK_RADA.md`.
- ZADATAK 102: proveden je stvarni ingest po
  `paketi/PAKET_ZUS_V1.json` za važeći
  `zakon_o_upravnim_sporovima` kao jedan važeći akt (`NN 36/2024`).
  Manifest nije zahtijevao nikakav patch. Generirani su NN snapshot i
  parsirani izlazi pod
  `izvori/dokazno/narodne_novine/zakon_o_upravnim_sporovima/`,
  selection report
  `izvori/dokazno/narodne_novine/
  ZAKON_O_UPRAVNIM_SPOROVIMA_SELECTION_REPORT.md`,
  kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  te operativni NORMA set pod
  `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/`.
  Paketni ingest i zasebni `acceptance_preflight` završili su s
  `exit=0`; preflight je potvrdio `NN_COUNT=172`, `MISSING_COUNT=0`,
  `EXTRA_LIST=[]`, `TIP_ACTUAL=procisceni`.
- ZADATAK 103: najprije je uskladjen statusni trag nakon Z102 na
  stvarni git commit `7dd0cb3` i potvrđeno poravnanje grane `main`.
  Zatim je za `zakon_o_upravnim_sporovima` izgrađen stvarni kontrolni
  sloj sa `zakon.hr` pod
  `izvori/kontrolno/zakon_hr/zakon_o_upravnim_sporovima/`
  i provedena puna usporedba NORMA seta
  `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/`
  naspram stvarnog kontrolnog teksta.
  Rezultat usporedbe: `CONTROL_COUNT=172`, `NN_COUNT=172`,
  `MISSING_COUNT=0`, `EXTRA_LIST=[]`, `SHORT_COUNT=11`,
  `CONTROL_TRUNCATION_SUSPECTED=False`.
  Generiran je trajni izvještaj:
  `baza_zakona/norme/zakon_o_upravnim_sporovima_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 105: uveden je kanonski servisni sloj za dokumentaciju.
  Dodane su skripte `alati/uskladi_status_projekta.ps1` za usklađenje
  statusnog dokumenta sa stvarnim git stanjem i
  `alati/provjeri_markdown_scope.ps1` za scoped markdown preflight nad
  ciljanim `.md` datotekama.
  Dodan je novi standard
  `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md` koji propisuje
  heading disciplinu, pravila za MD024/MD026/MD013 i obvezni servisni
  redoslijed: pre-check -> before-tail -> izmjena -> markdown scope
  provjera -> puni gateovi -> commit.
- ZADATAK 106: pripremljen je manifest ingest-a
  `paketi/PAKET_OPZ_V1.json` za `opci_porezni_zakon`.
  Na temelju prioritetnog reda i vanjske potvrde sa `zakon.hr`, OPZ se vodi
  kao model `core + amandmani` nad nizom `NN 115/16`, `106/18`, `121/19`,
  `32/20`, `42/20`, `114/22`, `152/24` i `151/25`, uz `zakon.hr` samo kao
  kontrolni izvor.
- ZADATAK 109: proveden je stvarni ingest paketa
  `paketi/PAKET_OPZ_V1.json` za `opci_porezni_zakon`.
  Ingest je prosao iz prvog pokusaja (`INGEST_FIRST_RUN_EXIT=0`) bez patcha
  manifesta. Nastali su NN dokazni snapshoti pod
  `izvori/dokazno/narodne_novine/opci_porezni_zakon/`, operativni NORMA set
  pod `baza_zakona/norme/opci_porezni_zakon_procisceni/` i sidrisni setovi
  za svih sedam amandmanskih NN akata pod `baza_zakona/sidra/`, uz selection
  reportove i kontrolne direktorije koje je ingest workflow stvarno generirao.
- ZADATAK 110: izvrsena je servisna sanacija workspace problema nakon Z109.
  Dokazni audit prije patcha pokazao je da obje PowerShell skripte
  `alati/generiraj_dnevnicki_unos.ps1` i
  `alati/zatvori_dokumentacijski_korak.ps1` trenutno nemaju prijavljenih
  workspace problema, dok je u
  `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md` saniran jedan
  preostali `MD010` problem (hard tab). Nakon patcha provjere su ciste.
- ZADATAK 111: provedena je stvarna kontrolna usporedba OPZ JSON seta sa
  `zakon.hr` za `opci_porezni_zakon`.
  Kontrolni sloj pod `izvori/kontrolno/zakon_hr/opci_porezni_zakon/`
  osvjezen je stvarnim `zakon.hr` sadrzajem, validator
  `alati/validiraj_nn_vs_kontrolno.py` proveden je nad
  `baza_zakona/norme/opci_porezni_zakon_procisceni/`, a rezultat je:
  `CONTROL_COUNT=199`, `NN_COUNT=199`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `SHORT_COUNT=19`, `CONTROL_TRUNCATION_SUSPECTED=False`.
- ZADATAK 112: pregled dovrsenih zadataka u statusu kronoloski je uredjen
  od starijeg prema novijem, a kanonsko pravilo sada eksplicitno razlikuje
  snapshot stanja na vrhu od pregleda dovrsenih zadataka ispod. `Zadnji
  dovrseni zadatak` vodi se u snapshot bloku na vrhu i kao zadnja stavka
  ovog pregleda; `alati/uskladi_status_projekta.ps1` nije trebalo mijenjati.
- ZADATAK 113: pregled dovrsenih zadataka u statusu stvarno je normaliziran
  tako da cijeli blok sadrzi samo stavke zadataka poredane uzlazno po broju,
  bez manjeg broja ispod veceg. `alati/uskladi_status_projekta.ps1` nije
  trebalo mijenjati jer ne dira pregled zadataka.
- ZADATAK 114: za `zakon_o_porezu_na_dohodak` utvrdjen je kanonski rezim
  konverzije u dokumentu
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Primarna NN provjera potvrdila je izvorni zakon `NN 115/2016` i zasebne
  izmjene/dopune `NN 106/2018`, `121/2019`, `32/2020`, `138/2020`,
  `151/2022`, `114/2023` i `152/2024`, bez dokaza jednog zasebnog važeceg
  prociscenog NN akta, pa je odabran
  `REZIM_ODABRAN = PREKRSAJNI_ZAKON_MODEL`.
- ZADATAK 116: pripremljen je manifest ingest-a
  `paketi/PAKET_ZPD_V1.json` za `zakon_o_porezu_na_dohodak` po vec utvrdjenom
  modelu `core + amandmani`, s primarnim dokaznim izvorom u Narodnim
  novinama i `zakon.hr` samo kao kontrolnim izvorom za kasniju validaciju.
- ZADATAK 118: proveden je stvarni ingest paketa
  `paketi/PAKET_ZPD_V1.json` za `zakon_o_porezu_na_dohodak` bez izmjene
  manifesta i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Paketni ingest zavrsio je s `INGEST_PAKET_EXIT=0` i `status OK` za core akt
  te svih sedam amandmana. Generirani su NN dokazni snapshoti pod
  `izvori/dokazno/narodne_novine/zakon_o_porezu_na_dohodak*/`, kontrolni
  direktoriji pod `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak*/`,
  core NORMA set od 99 clanaka pod
  `baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/`, sidrisni setovi
  za svih sedam amandmanskih akata pod `baza_zakona/sidra/` i osam selection
  reportova, uz osvjezen
  `izvori/dokazno/narodne_novine/IZVJESTAJ_KONTROLE_ARHIVE.md` kao stvarni
  nusartefakt ingest-a.
- ZADATAK 119: provedena je stvarna kontrolna usporedba ZPD JSON seta sa
  `zakon.hr` za `zakon_o_porezu_na_dohodak` bez novog ingest-a i bez izmjene
  manifesta `paketi/PAKET_ZPD_V1.json`.
  Osvjezen je kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak/`, pri cemu su
  potvrdeni `meta.json`,
  `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_kontrolni.txt` i novi
  `zakon_o_porezu_na_dohodak_zakon_hr.html`.
  Validacija nad
  `baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/` dala je
  `CONTROL_COUNT=99`, `NN_COUNT=99`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `SHORT_COUNT=2` (`28`, `98`) i
  `CONTROL_TRUNCATION_SUSPECTED=False`, uz trajni izvjestaj
  `baza_zakona/norme/zakon_o_porezu_na_dohodak_procisceni/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 120: provedena je stvarna kontrolna usporedba prvog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_106_2018` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Osvjezen je kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_106_2018/`, pri
  cemu su potvrdeni `meta.json`,
  `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_106_2018_kontrolni.txt` i novi
  `zakon_o_porezu_na_dohodak_nn_106_2018_zakon_hr.html` iz stvarnog izvora
  `https://www.zakon.hr/cms.htm?id=35597`.
  Nakon minimalnog patcha u alatima `alati/parsiraj_nn_html.py` i
  `alati/validiraj_nn_vs_kontrolno.py`, te reparsiranja postojeceg lokalnog NN
  HTML snapshota za isti amandman, validacija nad
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/` dala je
  `CONTROL_COUNT=33`, `NN_COUNT=33`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `SHORT_COUNT=9` i `CONTROL_TRUNCATION_SUSPECTED=False`; trajni izvjestaj
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_106_2018/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 121: provedena je stvarna kontrolna usporedba drugog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_121_2019` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Osvjezen je kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_121_2019/`, pri
  cemu su potvrdeni `meta.json`,
  `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_121_2019_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_121_2019_zakon_hr.html` iz stvarnog izvora
  `https://www.zakon.hr/cms.htm?id=42193`.
  Validacija nad
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/` dala je
  `CONTROL_COUNT=21`, `NN_COUNT=22`, `MISSING_COUNT=0`, `EXTRA_LIST=[27]`,
  `SHORT_COUNT=6` i `CONTROL_TRUNCATION_SUSPECTED=False`; trajni izvjestaj
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_121_2019/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 123: provedena je stvarna kontrolna usporedba treceg ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_32_2020` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Osvjezen je kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_32_2020/`, pri cemu
  su potvrdeni `meta.json`, `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_32_2020_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_32_2020_zakon_hr.html` iz stvarnog izvora
  `https://www.zakon.hr/cms.htm?id=43421`.
  Validacija nad
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020/` dala je
  `CONTROL_COUNT=4`, `NN_COUNT=4`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `SHORT_COUNT=1`, `CONTROL_TRUNCATION_SUSPECTED=False`,
  `GUARDRAIL_FAIL=False` i `ANOMALY_FLAG=False`; validator je prosao bez
  patcha, uz trajni izvjestaj
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_32_2020/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 124: provedena je stvarna kontrolna usporedba cetvrtog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_138_2020` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Dokazno je potvrden zaseban zakon.hr zapis
  `https://www.zakon.hr/cms.htm?id=46522`, a osvjezen kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_138_2020/`, pri cemu
  su potvrdeni `meta.json`, `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_138_2020_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_138_2020_zakon_hr.html` uz
  `KONTROLNI_CLANCI=21`.
  Validacija nad
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020/` dala je
  `CONTROL_COUNT=21`, `NN_COUNT=21`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`,
  `SHORT_COUNT=8`, `CONTROL_TRUNCATION_SUSPECTED=False`,
  `GUARDRAIL_FAIL=False` i `ANOMALY_FLAG=False`; validator je prosao bez
  patcha, uz trajni izvjestaj
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_138_2020/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 126: provedena je stvarna kontrolna usporedba petog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_151_2022` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Dokazno je potvrden zaseban zakon.hr zapis
  `https://www.zakon.hr/cms.htm?id=55111`, a osvjezen kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_151_2022/`, pri cemu
  su potvrdeni `meta.json`, `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_151_2022_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_151_2022_zakon_hr.html` uz
  `KONTROLNI_CLANCI=23`.
  Validacija je pokrenuta nad slugom
  `zakon_o_porezu_na_dohodak_nn_151_2022` kroz
  `alati/validiraj_nn_vs_kontrolno.py`, s rezultatom `CONTROL_COUNT=23`,
  `NN_COUNT=23`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`, `SHORT_COUNT=11`,
  `CONTROL_TRUNCATION_SUSPECTED=False`, `GUARDRAIL_FAIL=False` i
  `ANOMALY_FLAG=False`; trajni izvjestaj upisan je u
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_151_2022/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 127: servisno je ispravljen dokumentacijski trag za Z126.
  Potvrdeno je da je raniji status-sync unutar Z126 dokaznog traga bio
  pokrenut s krivim parametrom `-ZadnjiZadatak "ZADATAK 125"`, nakon cega je
  statusni snapshot kanonski ponovno uskladjen s tocnim parametrima za Z126.
  Ispravljena je i formulacija validacije tako da eksplicitno navodi pokretanje
  nad slugom `zakon_o_porezu_na_dohodak_nn_151_2022`, bez izmjene zakona,
  manifesta, parsera ili validatora.
- ZADATAK 128: provedena je stvarna kontrolna usporedba sestog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_114_2023` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Dokazno je potvrden zaseban zakon.hr zapis
  `https://www.zakon.hr/cms.htm?id=58270`, a osvjezen kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_114_2023/`, pri cemu
  su potvrdeni `meta.json`, `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_114_2023_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_114_2023_zakon_hr.html` uz
  `KONTROLNI_CLANCI=42`.
  Validacija je pokrenuta nad slugom
  `zakon_o_porezu_na_dohodak_nn_114_2023` kroz
  `alati/validiraj_nn_vs_kontrolno.py`, s rezultatom `CONTROL_COUNT=42`,
  `NN_COUNT=44`, `MISSING_COUNT=0`, `EXTRA_LIST=[76, 78]`, `SHORT_COUNT=20`,
  `CONTROL_TRUNCATION_SUSPECTED=False`, `GUARDRAIL_FAIL=False` i
  `ANOMALY_FLAG=False`; trajni izvjestaj upisan je u
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_114_2023/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 129: provedena je stvarna kontrolna usporedba sedmog ZPD amandmana
  `zakon_o_porezu_na_dohodak_nn_152_2024` sa `zakon.hr`, bez novog ingest-a,
  bez izmjene manifesta `paketi/PAKET_ZPD_V1.json` i bez promjene rezima iz
  `dokumentacija/REZIM_KONVERZIJE_ZPD_U_JSON.md`.
  Dokazno je potvrden zaseban zakon.hr zapis
  `https://www.zakon.hr/cms.htm?id=540193`, a osvjezen kontrolni sloj pod
  `izvori/kontrolno/zakon_hr/zakon_o_porezu_na_dohodak_nn_152_2024/`, pri cemu
  su potvrdeni `meta.json`, `struktura_kontrolno_dokumenti.json`,
  `zakon_o_porezu_na_dohodak_nn_152_2024_kontrolni.txt` i
  `zakon_o_porezu_na_dohodak_nn_152_2024_zakon_hr.html` uz
  `KONTROLNI_CLANCI=19`.
  Validacija je pokrenuta nad slugom
  `zakon_o_porezu_na_dohodak_nn_152_2024` kroz
  `alati/validiraj_nn_vs_kontrolno.py`, s rezultatom `CONTROL_COUNT=19`,
  `NN_COUNT=19`, `MISSING_COUNT=0`, `EXTRA_LIST=[]`, `SHORT_COUNT=6`,
  `CONTROL_TRUNCATION_SUSPECTED=False`, `GUARDRAIL_FAIL=False` i
  `ANOMALY_FLAG=False`; trajni izvjestaj upisan je u
  `baza_zakona/sidra/zakon_o_porezu_na_dohodak_nn_152_2024/
  IZVJESTAJ_VALIDACIJE_KONTROLNO.md`.
- ZADATAK 130: izveden je kanonski obrazac kontrolne usporedbe zasebnih ZPD
  amandmana u dokumentu
  `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md` na temelju
  stvarnih rezultata Z120 (`NN 106/2018`) i Z121 (`NN 121/2019`).
  Dokument formalizira da su `MISSING_COUNT=0`,
  `CONTROL_TRUNCATION_SUSPECTED=False`, `GUARDRAIL_FAIL=False` i
  `ANOMALY_FLAG=False` tvrda jezgra prolaza, dok `SHORT_COUNT` i izolirani
  `EXTRA_LIST` ostaju tolerirani nalazi bez automatskog patcha.
- ZADATAK 132: izrađen je završni kanonski pregled za cijeli ZPD u dokumentu
  `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`, isključivo na
  temelju postojećih repo artefakata. Dokument objedinjeno pokriva core akt i
  svih sedam amandmana iz manifesta, sa zajednickim prikazom `CONTROL_COUNT`,
  `NN_COUNT`, `MISSING_COUNT`, `EXTRA_LIST`, `SHORT_COUNT` i
  `CONTROL_TRUNCATION_SUSPECTED`, te zavrsnim zakljuckom da je ZPD kao cjelina
  stabilno zatvoren po modelu `core + amandmani`, bez otvorenog zahtjeva za
  novi ingest ili patch alata.
- ZADATAK 133: sanirana su točno 2 stvarna workspace problema nakon Z132,
  oba po pravilu `MD047/single-trailing-newline`: jedan u
  `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md`, drugi u
  `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`.
  Sanacija je zadrzana na normalizaciji završnog newline zapisa bez drugih
  sadržajnih izmjena, uz ažuriran dokumentacijski trag u statusu i dnevniku.
- ZADATAK 134: dokazno je potvrđeno da Z133 pri pre-checku nije bio zatvoren na
  `origin/main`, jer je lokalni `main` bio `ahead 1`, dok je remote još bio na
  `008cdbc`. Istodobno je potvrđeno da
  `dokumentacija/OBRAZAC_KONTROLNE_USPOREDBE_AMANDMANA_ZPD.md` nema stvarni
  radni diff nakon Z133 i zato nije dio stvarnog Z134 commit scopea. Z134 je
  zadržan isključivo na dokumentacijskom tragu (`STATUS_PROJEKTA_VERITAS_H77.md`
  i `DNEVNIK_RADA.md`) te na dokaznom zatvaranju lokalno/remote nesklada.
- ZADATAK 135: servisno je uklonjen izvan-scope lokalni editor artefakt
  `.vscode/settings.json` iz radnog stabla. Dokazno je potvrđeno da je
  `.vscode/` sadržavao samo lokalnu VS Code konfiguraciju i da artefakt nije
  kanonski potreban u repou, pa je uklonjen bez ikakvih promjena u zakonima,
  parserima, validatorima ili ZPD dokumentima. Dokumentacijski trag zadržan je
  isključivo na `STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md`.
- ZADATAK 136: trajno je ispravljena skripta
  `alati/uskladi_status_projekta.ps1` tako da pri eksplicitno zadanom
  parametru `-ZadnjiZadatak` deterministicki i bez rucne intervencije mijenja
  redak `- Zadnji dovršeni zadatak: ...` u
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md`.
  Ispravak je dokazno potvrden stvarnim pokretanjem skripte nad statusom
  najprije s testnom vrijednoscu `ZADATAK TEST 136`, a zatim s realnom
  vrijednoscu `ZADATAK 136`, bez naknadnog rucnog patchanja tog retka.
- ZADATAK 137: `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md`
  redakcijski je preuređen u konačni kanonski raspored za objavu u repou,
  sa sazetkom na vrhu, zatim core ZPD dijelom, pa amandmanima redom i
  zavrsnim zakljuckom. Sadržajni navodi, metrike, URL-ovi i postojeći
  zaključci pritom nisu mijenjani.
- ZADATAK 138: izrađena je analitička inventura postojećeg obrasca za
  pretvaranje zakona s amandmanima u JSON u dokumentu
  `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Na temelju postojećih kanonskih dokumenata i alata utvrđeno je da repou ne
  nedostaju pojedinačni mehanizmi, nego objedinjeni opći kanonski dokument
  koji bi na jednom mjestu povezao odluku o režimu, manifest, NN dokazni sloj,
  sidra, kontrolni `zakon.hr` sloj, validaciju i završni izvještaj.
- ZADATAK 139: izrađen je objedinjeni kanonski dokument
  `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` koji na
  jednom mjestu definira postupak pretvaranja zakona s amandmanima u JSON.
  Dokument objedinjeno pokriva režim `core + amandmani`, minimalni obvezni
  skup ulaznih artefakata, NN dokazni sloj, kontrolni `zakon.hr` sloj,
  pravila za `norme/` i `sidra/`, kriterije prolaza, tolerirana odstupanja,
  završni izvještaj i uvjete pod kojima se smije reći da je zakon kanonski
  obrađen.
- ZADATAK 140: izrađena je dokazna analiza stanja dokumentacije nakon
  nezatvorenih Z138 i Z139 u dokumentu
  `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Potvrđeno je da na GitHubu još nema Z138/Z139 dokumentacijskog zatvaranja,
  da lokalno već postoje inventura i objedinjeni kanonski obrazac, te da je
  minimalni sljedeći korak strogo scoped commit i push tog već postojećeg
  lokalnog dokumentacijskog skupa.
- ZADATAK 141: izrađena je dokazna analiza dovoljnosti postojećeg kanonskog
  obrasca za zakone s amandmanima u dokumentu
  `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Utvrđeno je da je
  `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` već dovoljno
  jak da ostane glavni opći standard, dok inventura ostaje prijelazni trag,
  obrazac amandmanske kontrole specijalizirani dodatak, a završni ZPD
  izvještaj dokazni primjer primjene.
- ZADATAK 142: izrađen je završni dokazni odgovor na pitanje je li postojeći
  `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md` već dostatan
  kao glavni kanonski dokument za zakone s amandmanima, u dokumentu
  `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Zaključak je potvrđen kao `DA`: glavni kanonski obrazac već sadrži obvezni
  operativni sadržaj, dok inventura, analize, specijalizirani obrazac
  amandmanske kontrole i završni ZPD izvještaj ostaju pomoćni dokumenti sa
  zasebnim ulogama.
- ZADATAK 143: izrađeno je dokazno razdvajanje scopea Z138-Z142 u dokumentu
  `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`.
  Potvrđeno je da je svaki od zadataka Z138-Z142 čist na razini svoje glavne
  nove datoteke, ali da su `MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `STATUS_PROJEKTA_VERITAS_H77.md` i `DNEVNIK_RADA.md` trenutno kumulativno
  mijesani trag tih zadataka i zato ne smiju nekriticki u isti commit.
  Istodobno je potvrđeno da `.vscode/` ostaje izvan-scope lokalni editor
  artefakt, a `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` stariji lokalni
  dokumentacijski diff koji ne pripada buducem commit nizu Z138-Z142.
- ZADATAK 144: izrađen je dokazni dokument
  `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`.
  Potvrđeno je da je stvarni Z138 scope inventurni dokument
  `INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md` uz samo Z138 hunkove iz mape,
  statusa i append-only dnevnika, dok svi Z139-Z143 tragovi, `.vscode/` i
  `ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` moraju ostati izvan budućeg
  Z138 commita.
- ZADATAK 145: izdvojen je stvarni staged skup za Z138.
  U index su uneseni `dokumentacija/INVENTURA_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
  samo Z138 hunk u `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`, samo
  Z138 hunk u `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i samo append-only
  Z138 blok u `dokumentacija/DNEVNIK_RADA.md`.
  Izvan stagea ostali su
  `dokumentacija/KANONSKI_OBRAZAC_ZAKONI_S_AMANDMANIMA_JSON.md`,
  `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
  `dokumentacija/ANALIZA_DOVOLJNOSTI_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
  `dokumentacija/ODGOVOR_DOVOLJNOST_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`,
  `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md`,
  `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`, `.vscode/`,
  `dokumentacija/ZAVRSNI_IZVJESTAJ_ZPD_CORE_I_AMANDMANI.md` i svi kasniji
  lokalni tragovi Z139-Z144 u mapi, statusu i dnevniku.
- ZADATAK 146: provedeno je zamrzavanje meta-dokumentacije za Z138-Z145 kroz
  klasifikaciju u mapi dokumentacije.
  Analize, odgovori i scope-razdvajanja iz tog niza oznaceni su kao
  privremeni radni trag i neoperativni pomocni sloj, dok operativni minimum
  ostaje `zakon -> manifest -> ingest -> JSON -> validacija`.
  Sljedeci logicki korak je repo stabilizacija baseline bez otvaranja novih
  meta-dokumenata.
- ZADATAK 147: uveden je odvojeni full-repo markdown lint signal uz
  zadržavanje postojećeg scoped moda.
  `alati/lint_markdown.ps1` sada jasno razlikuje
  `MDLINT_MODE=SCOPED` i `MDLINT_MODE=FULL_REPO`, dok `alati/ci_smoke.ps1`
  scoped lint zadržava kao hard-gate, a full-repo lint vodi kao evidencijski
  signal ukupnog markdown stanja repozitorija.
- ZADATAK 148: arhivski je preoznacena samo datoteka
  `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Prateci trag je azuriran samo u
  `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`, bez diranja drugih dokumenata iz paketa
  Z138-Z142.
- ZADATAK 149: uklonjene su samo proceduralne datoteke
  `dokumentacija/RAZDVAJANJE_SCOPEA_Z138_DO_Z142.md` i
  `dokumentacija/Z138_SCOPE_DOKAZ_I_PRIPREMA_COMMITA.md`.
  Nuzni prateci trag azuriran je samo u
  `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`.
- ZADATAK 155: proveden je prvi skupinski rez ciscenja suma u
  dokumentaciji nad homogenom skupinom snapshot / primopredaja /
  stanje-repozitorija tragova, ali je commit `c6519e9` pogrešno ostavio
  arhivske stubove istih imena u radnom sloju.
- ZADATAK 156: korektivnim rezom ti su stubovi stvarno uklonjeni iz
  kanonskog i radnog sloja za dokumente
  `dokumentacija/PRIMOPREDAJNI_PAKET_STANJA_REPOZITORIJA.md`,
  `dokumentacija/PROCJENA_STATUSA_PAKETA_Z138_DO_Z142.md`,
  `dokumentacija/PRIJEDLOG_ARHIVIRANJA_I_UKLANJANJA_PAKETA_Z138_DO_Z142.md`
  i `dokumentacija/PRIPREMA_UKLANJANJA_PROCEDURALNIH_DATOTEKA_Z138_DO_Z142.md`.
  Prateći trag ostaje samo u
  `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`,
  `dokumentacija/STATUS_PROJEKTA_VERITAS_H77.md` i
  `dokumentacija/DNEVNIK_RADA.md`.
- ZADATAK 157: preoznacena je homogena skupina povijesnih dokaznih
  tragova koju čine
  `dokumentacija/REVIZIJA_DOKUMENTACIJE_VERITAS_H77.md`,
  `dokumentacija/POPIS_AKTIVNIH_MARKDOWN_PROBLEMA.md` i
  `dokumentacija/ANALIZA_STANJA_KANONSKOG_OBRASCA_ZAKONI_S_AMANDMANIMA.md`.
  Dokumenti ostaju u repou, ali su u `MAPA`, `STATUS` i vlastitom zaglavlju
  jasno razdvojeni kao `POVIJESNI_DOKAZNI_TRAGOVI`, izvan aktivnog
  kanonskog sloja.
- ZADATAK 160: dovrsen je planned removal 4 wrapper skripte skupine
  `zatvori_*_validiranu_gransku_natuknicu.py`, na temelju dokaznih
  dokumenata
  `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
  `WRAPPERA_GRANSKIH_NATUKNICA.md`
  i
  `dokumentacija/POPIS_REFERENCI_NA_WRAPPERE_`
  `GRANSKIH_NATUKNICA.md`.
  Genericki alat `alati/zatvori_validiranu_gransku_natuknicu.py` nije
  diran i ostaje jedina aktivna implementacija; konsolidacija skupine je
  zavrsena.
- ZADATAK 163: dovrsen je planned removal 8 wrapper skripti skupine
  `zatvori_paket_*_prekrsajni_zakon.py`, na temelju dokaznih dokumenata
  `dokumentacija/ANALIZA_ZADRZAVANJA_ILI_UKLANJANJA_`
  `WRAPPERA_PAKETA_PREKRSAJNOG_ZAKONA.md`
  i
  `dokumentacija/POPIS_REFERENCI_NA_WRAPPERE_PAKETA_PREKRSAJNOG_`
  `ZAKONA.md`.
  Genericki alat `alati/zatvori_paket_prekrsajni_zakon.py` nije diran i
  ostaje jedina aktivna implementacija; konsolidacija skupine je
  zavrsena.

## Operativni sazetak

- Zadnji operativni paketni rjecnicki korak ostaje: ZADATAK 87
- Potpuno validiranih natuknica: 40
- Preostali homogeni nizovi za paketno zatvaranje: nema
- Postojeci uzorak rada za konverziju zakona u JSON ostaju:
  `ustav_rh_procisceni` i `prekrsajni_zakon_procisceni`
- Aktivni dokumentacijski guard: append-only zaštita
  `dokumentacija/DNEVNIK_RADA.md`
- Rezultat kontrolne usporedbe: STABILNO
  (Z140 je dokazno razdvojio lokalno postojeće kanonske dijelove obrasca od
  onoga što još nije zatvoreno na GitHubu, bez novih izmjena zakona ili
  alata.)
- Dovoljnost glavnog obrasca: POTVRDJENA
  (Z142 je završno potvrdio odgovor `DA`: postojeći objedinjeni kanonski
  obrazac već je dostatan kao glavni standard, bez dodatnog obveznog
  sadržajnog proširenja.)
- Razdvajanje scopea Z138-Z142: POTVRDJENO
  (Z143 je dokazno razdvojio koji je primarni dokument svakog zadatka,
  koje su zajednicke datoteke trenutno mijesane i da prvi cisti GitHub
  commit mora biti Z138 uz parcijalno izdvojene hunkove iz mape, statusa i
  dnevnika.)
- Z138 scoped priprema commita: POTVRĐENA
  (Z144 je dokazno suzio budući prvi commit na inventurni dokument i samo
  stvarne Z138 tragove u zajedničkim dokumentacijskim datotekama.)
- Zavrsni ZPD dokument: preuređen u konačni kanonski raspored za repozitorij,
  bez promjene dokaznih činjenica i metrika.
- Servisna korekcija traga: Z127 je ispravio dokumentacijski trag Z126 i
  kanonski uskladio statusni snapshot na `ZADATAK 126`.
- Sljedeci logicki korak: po zasebnom zadatku nastaviti strogo
  zatvoriti Z138 kao prvi scoped commit, i to samo nad inventurnom
  datotekom te parcijalno izdvojenim Z138 hunkovima iz zajednickih
  dokumentacijskih tragova, pa tek potom redom Z139-Z142.
  bez novog sadržajnog širenja i bez diranja zakona, sidara, normi i alata.

## Pravilo sinkronizacije

- Kanonski izvor istine: GitHub (`nhursa77/Veritas_h77`)
- Jedina radna kopija: `C:\Veritas_H77`
- Google Disk: sinkronizirana kopija/backup/pregled, nije paralelni izvor
  uređivanja istih datoteka

Pre-check snapshot sinkronizacije:

- Polazni HEAD prije zadatka: `eb7a13f` - docs: inventura obrasca zakoni s
  amandmanima (Z138)
- Repo čist pri pre-checku: DA
- Poravnanje grane pri pre-checku: poravnat
- lokalna detekcija tipičnih Drive putanja: nije potvrđena

## Aktivni gateovi

- `alati/ci_smoke.ps1`
- `alati/lint_markdown.ps1`
- `alati/provjeri_markdown_scope.ps1`
- `alati/test_fixtures_audit_prekrsaji_v1.ps1`

## Ključni standardi na snazi

- `dokumentacija/RAZVOJNI_PLAN_VERITAS_H77.md`
- `dokumentacija/RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md`
- `dokumentacija/MAPA_DOKUMENTACIJE_VERITAS_H77.md`
- `dokumentacija/STANDARD_JSON_NORMA.md`
- `dokumentacija/STANDARD_JSON_POSTUPAK.md`
- `dokumentacija/STANDARD_JSON_INTAKE_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_AUDIT_PRIMJENE.md`
- `dokumentacija/STANDARD_GENERIRANJE_AUDIT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_SUBSUMPCIJA.md`
- `dokumentacija/STANDARD_JSON_HIJERARHIJA.md`
- `dokumentacija/STANDARD_JSON_PREDLOZAK.md`
- `dokumentacija/STANDARD_IZLAZNI_NACRT_PREKRSAJI_V1.md`
- `dokumentacija/STANDARD_JSON_TERMINOLOSKI_ZAPIS.md`
- `dokumentacija/STANDARD_IZDVAJANJE_HRVATSKI_RELEVANTNIH_TERMINA.md`
- `dokumentacija/STANDARD_MAPIRANJE_EU_PREMA_NN_POJMOVIMA.md`
- `dokumentacija/STANDARD_PRIORITETNI_UZORAK_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_CISCENJE_PRIORITETNOG_UZORKA_NN.md`
- `dokumentacija/STANDARD_JSON_RJECNICKA_NATUKNICA.md`
- `dokumentacija/STANDARD_PILOT_NATUKNICE_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_JEZGRENE_NATUKNICE_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_OSNOVNI_POSTUPOVNI_SKUP_ZA_NN_SIDRENJE.md`
- `dokumentacija/STANDARD_NN_SIDRENJE_RJECNICKIH_NATUKNICA.md`
- `dokumentacija/STANDARD_KANDIDATSKE_PODNATUKNICE_NN.md`
- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`
- `dokumentacija/STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`
- `dokumentacija/STANDARD_GRANSKE_PODNATUKNICE_NN.md`
- `dokumentacija/STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`
- `dokumentacija/STANDARD_PISANJE_MARKDOWN_DOKUMENTACIJE.md`
- `dokumentacija/STANDARD_SINKRONIZACIJA_REPOA_VERITAS_H77.md`
- `dokumentacija/STANDARD_ZASTITA_DNEVNIKA_RADA.md`

## Faza po planovima i standardima

### RAZVOJNI_PLAN_VERITAS_H77.md

- Definira globalne faze 0-9 i gate logiku za cijeli sustav.
- Trenutni modul rada pripada prekršajnoj pilot domeni unutar tog okvira.
- CI i validacijski gateovi su obavezni za prolaz između faza.

### RAZVOJNI_PLAN_PREKRSAJNI_MODUL.md

- P2 je dovršen za sva 4 toka (`TOK_PN_PRIGOVOR`,
  `TOK_PRESUDA_ZALBA`, `TOK_RJESENJE_ZALBA`, `TOK_OBUSTAVA`).
- P6 acceptance i fixture matrica su dovedeni do pokrivenosti kroz ZAD 50.
- Sljedeće po redu je P7 (E2E veza audit -> nacrt -> manifest).

### MAPA_DOKUMENTACIJE_VERITAS_H77.md

- Definira kanonske dokumente i redoslijed čitanja.
- Potvrđuje da su planovi i standardi prekršajnog modula aktivni.
- Upućuje na obavezne validatore i `ci_smoke` kao operativne gateove.

### DNEVNIK_RADA.md (zadnji pregledani blok)

- U završnom bloku su unosi za terminološke korake 52-63.
- Dnevnik sadrži dokazne naredbe po zadacima i commit tragu.
- Kronologija unosa je dokumentirana uz commit listu kao dokaz reda.

### Razlaganje višeznačnih sidara (ZADATAK 68)

- Dodana je skripta `alati/razlozi_viseznacna_nn_sidra_po_aktu.py`.
- Generirani su `kandidatske_podnatuknice_nn.json` i pripadni manifest.
- Kandidatske podnatuknice ostaju nekonačne i ručno validirane.

### Ispravak razlaganja kandidata (ZADATAK 69)

- Dodana je skripta `alati/ispravi_razlaganje_nn_kandidata.py`.
- Generirani su `kandidatske_podnatuknice_nn_v2.json` i pripadni v2 manifest.
- V2 kandidati razlažu se po pojedinom sidru, a ne samo po nadređenom pojmu.

### Sužavanje kandidata za ručnu validaciju (ZADATAK 70)

- Dodana je skripta `alati/suzi_nn_kandidate_za_rucnu_validaciju.py`.
- Generirani su `konacni_nn_kandidati_za_validaciju.json` i pripadni
  manifest.
- Uveden je standard `STANDARD_RUCNA_VALIDACIJA_NN_KANDIDATA.md`.
- U ovom skupu nije bilo spajanja istog konteksta (`grupirani=0`), a svi
  kandidati ostaju za ručnu validaciju (`zadrzani=40`).

### Ručna validacija i upis potvrđenih sidara (ZADATAK 71)

- Dodana je skripta `alati/upisi_validirana_nn_sidra_u_natuknice.py`.
- Generirani su `osnovni_postupovni_skup_nn_validiran.json` i pripadni
  manifest.
- Uveden je standard `STANDARD_RUCNA_VALIDACIJA_I_UPIS_NN_SIDARA.md`.
- Statusi validacije za 8 ciljanih pojmova su upisani u validirani sloj:
  `NN_VALIDIRANO=0`, `NN_DJELOMICNO_VALIDIRANO=8`,
  `CEKA_DALJNJU_RUCNU_VALIDACIJU=0`.

### Granska konsolidacija validiranih sidara (ZADATAK 72)

- Dodana je skripta `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`.
- Generirani su `granske_podnatuknice_nn.json` i pripadni manifest.
- Uveden je standard `STANDARD_GRANSKE_PODNATUKNICE_NN.md`.
- Za 8 ciljanih općih pojmova izvedena je deterministička granska podnatuknica
  po dokazivom kontekstu (`ukupno podnatuknica=8`).

### Sanacija i korekcija granske konsolidacije (ZADATAK 72A)

- Ispravljena je skripta `alati/konsolidiraj_nn_validirane_pojmove_po_grani.py`.
- Generirani su `granske_podnatuknice_nn_v2.json` i pripadni v2 manifest.
- Uklonjeno je lažno sažimanje `5 -> 1`; za svih 8 pojmova rezultat je
  `5 -> 5` po dokazivom normativnom kontekstu (`ukupno podnatuknica=40`).
- Pylance provjere za ciljane skripte su bez grešaka prije i poslije izmjene.

### Prva potpuno validirana granska natuknica (ZADATAK 73)

- Dodana je skripta `alati/zatvori_prvu_validiranu_gransku_natuknicu.py`.
- Generirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Uveden je standard `STANDARD_POTPUNO_VALIDIRANA_NATUKNICA.md`.
- Deterministicki je zatvorena jedna natuknica iz v2 granskog sloja:
  `apsolutna nenadležnost — prekršajni zakon — čl. 101`.

### Druga potpuno validirana granska natuknica (ZADATAK 74B)

- Dodana je skripta `alati/zatvori_drugu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Po strogom modelu zatvorena je nova natuknica različita od prve:
  `apsolutna nenadležnost — prekršajni zakon — čl. 102`.

### Sljedeca potpuno validirana granska natuknica (ZADATAK 75)

- Dodana je skripta `alati/zatvori_sljedecu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Deterministicki je zatvorena tocno jedna nova natuknica nakon 101 i 102:
  `apsolutna nenadležnost — prekršajni zakon — čl. 103`.

### Jos jedna potpuno validirana granska natuknica (ZADATAK 76)

- Dodana je skripta
  `alati/zatvori_jos_jednu_validiranu_gransku_natuknicu.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Deterministicki je zatvorena tocno jedna nova natuknica nakon 101, 102 i
  103:
  `apsolutna nenadležnost — prekršajni zakon — čl. 122`.

### Stabilizacija dnevnika i analiza skoka niza (ZADATAK 77)

- Dodana je skripta `alati/dodaj_dnevnicki_unos_na_kraj.ps1` kao kanonska
  append-only metoda upisa na EOF.
- Dopunjen je `STANDARD_ZASTITA_DNEVNIKA_RADA.md` zabranom kontekstnog
  umetanja dnevnickog unosa po sredini datoteke.
- Izradena je dokumentacija
  `dokumentacija/ANALIZA_SKOKA_U_NIZU_VALIDIRANIH_NATUKNICA.md`.
- Potvrdeno je da je skok `103 -> 122` ispravan jer u ulaznom nizu za taj
  pojam ne postoje clanci `104-121`.

### Paketno zatvaranje homogenog niza (ZADATAK 78)

- Dodana je skripta
  `alati/zatvori_paket_apsolutna_nenadleznost_prekrsajni_zakon.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Paketno je zatvoren preostali jednoznacni clanak iz niza
  `apsolutna nenadležnost — prekršajni zakon`: `čl. 161`.
- Izvan paketa su evidentirane vec zatvorene stavke `101`, `102`, `103`,
  `122` kao preskocene u manifestu s razlogom.

### Rangiranje sljedeceg homogenog niza (ZADATAK 79)

- Dodana je skripta `alati/rangiraj_sljedeci_homogeni_niz_za_paket.py`.
- Generirani su:
  `rang_lista_homogenih_nizova_za_paket.json` i pripadni manifest.
- Korak je analiza-only: broj novih zatvaranja u ovom zadatku je `0`.
- Top preporuka za sljedeci paket je niz:
  `dokaz` + `prekrsajni_zakon` (score `550`).

### Paketno zatvaranje homogenog niza dokaz (ZADATAK 80)

- Dodana je skripta `alati/zatvori_paket_dokaz_prekrsajni_zakon.py`.
- Ažurirani su `potpuno_validirane_natuknice.json` i pripadni manifest.
- Skripta obavezno provjerava rang-manifest i potvrdu preporuke:
  `dokaz` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `78`, `85`, `87`,
  `88`, `89`.
- Broj potpuno validiranih natuknica je povecan s `5` na `10`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 81)

- Dodana je skripta `alati/zatvori_paket_dostava_prekrsajni_zakon.py`.
- Odabrani niz je `dostava` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon` i
  `dokaz` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `114`, `117`,
  `118`, `122`, `87`.
- Broj potpuno validiranih natuknica je povecan s `10` na `15`.

### Paketno zatvaranje novog homogenog niza (ZADATAK 82)

- Dodana je skripta `alati/zatvori_paket_izvrsenje_prekrsajni_zakon.py`.
- Odabrani niz je `izvršenje` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon` i `dostava` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `13`, `14`, `34`,
  `42`, `44`.
- Broj potpuno validiranih natuknica je povecan s `15` na `20`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 83)

- Dodana je skripta `alati/zatvori_paket_presuda_prekrsajni_zakon.py`.
- Odabrani niz je `presuda` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon` i
  `izvršenje` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `33`, `40`, `99`,
  `106`, `109`.
- Broj potpuno validiranih natuknica je povecan s `20` na `25`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 84)

- Dodana je skripta `alati/zatvori_paket_prigovor_prekrsajni_zakon.py`.
- Odabrani niz je `prigovor` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon`,
  `izvršenje` + `prekrsajni_zakon` i `presuda` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `93`, `102`, `120`,
  `121`, `221`.
- Broj potpuno validiranih natuknica je povecan s `25` na `30`.

### Paketno zatvaranje sljedeceg homogenog niza (ZADATAK 85)

- Dodana je skripta `alati/zatvori_paket_rjesenje_prekrsajni_zakon.py`.
- Odabrani niz je `rješenje` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: prvi sljedeci niz po postojecem deterministicnom poretku
  rang-liste nakon iskljucenja vec obradenih nizova
  `apsolutna nenadležnost` + `prekrsajni_zakon`,
  `dokaz` + `prekrsajni_zakon`, `dostava` + `prekrsajni_zakon`,
  `izvršenje` + `prekrsajni_zakon`, `presuda` + `prekrsajni_zakon` i
  `prigovor` + `prekrsajni_zakon`.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `34`, `59`, `89`,
  `92`, `99`.
- Broj potpuno validiranih natuknica je povecan s `30` na `35`.

### Paketno zatvaranje homogenog niza zalba (ZADATAK 87)

- Dodana je skripta `alati/zatvori_paket_zalba_prekrsajni_zakon.py`.
- Odabrani niz je `žalba` + `prekrsajni_zakon` sa score `550`.
- Razlog odabira: zadnji preostali homogeni niz s otvorenim i jednoznacno
  spremnim kandidatima nakon zatvaranja nizova
  `apsolutna nenadležnost`, `dokaz`, `dostava`, `izvršenje`, `presuda`,
  `prigovor` i `rješenje` za isti akt.
- Paketno je zatvoreno 5 jednoznacnih natuknica iz cl. `87`, `89`, `95`,
  `99`, `100`.
- Broj potpuno validiranih natuknica je povecan s `35` na `40`.
- Osvjezena je rang-lista homogenih nizova i potvrdeno je da vise nema
  preostalih preporucenih nizova za paketno zatvaranje.
