# REZIM KONVERZIJE ZUS U JSON

Datum: 27.03.2026.
Status: kanonski
Opseg: utvrdjivanje izvora i rezima ingest-a za
`zakon_o_upravnim_sporovima`.

---

## A) Ciljani zakon

- `zakon_o_upravnim_sporovima`

---

## B) Važeći izvor

- `NN 36/2024` - Zakon o upravnim sporovima

Za operativni rad u projektu relevantan je važeći cjeloviti akt.

---

## C) Režim rada

Važeći ZUS vodi se:

- kao jedan važeći cjeloviti akt
- po obrascu istog tipa kao `ustav_rh_procisceni`

To znaci da se radi jedinstveni operativni set važeceg teksta,
uz standardni ingest -> parser -> normiranje -> validacija tok.

---

## D) Što se ne radi

Za važeći ZUS se u ovom režimu:

- ne slaže paket starih izmjena
- ne koristi model `prekrsajni_zakon`
- `zakon.hr` ostaje kontrolni izvor za validaciju, ne primarni izvor

---

## E) Završna oznaka režima

REZIM_ODABRAN = PROCISCENI_FIRST

Obrazlozenje:

- ne zato sto je nuzno pronadjen zasebno naslovljen NN
  "procisceni tekst"
- nego zato sto je važeći ZUS jedan samostalni važeći akt
- i za trenutni rad ne trazi paket povijesnih izmjena
