# STANDARD_ZASTITA_DNEVNIKA_RADA

Datum: 18.03.2026.
Status: kanonski
Opseg: zaštita i režim izmjena datoteke `dokumentacija/DNEVNIK_RADA.md`.

---

## 1) Svrha

Ovaj standard uvodi tvrdu zaštitu dnevnika rada kao ključne evidencijske
kanonske datoteke projekta Veritas H.77.

---

## 2) Obvezna pravila

1) `dokumentacija/DNEVNIK_RADA.md` je zaštićena evidencijska datoteka.
2) Dopušten je samo append novog unosa na kraj datoteke.
3) Potpuno prepisivanje sadržaja dnevnika je zabranjeno.
4) Sanacija postojećeg sadržaja dopuštena je isključivo po posebnom,
   eksplicitno zadanom zadatku.
5) Prije i poslije svake izmjene dnevnika obavezni su dokazni ispisi završnog
   dijela datoteke (`Get-Content -Tail`).

---

## 3) Obvezni dokazni koraci

Za svaku izmjenu dnevnika rada obavezno je izvršiti i arhivirati sljedeće
ispise:

1) Prije izmjene:
   - `DNEVNIK_TAIL_BEFORE_BEGIN`
   - ispis `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail <N>`
   - `DNEVNIK_TAIL_BEFORE_END`
2) Poslije izmjene:
   - `DNEVNIK_TAIL_AFTER_BEGIN`
   - ispis `Get-Content .\dokumentacija\DNEVNIK_RADA.md -Tail <N>`
   - `DNEVNIK_TAIL_AFTER_END`

`<N>` mora biti dovoljno velik da obuhvati novi završni unos.

---

## 4) Zabranjene radnje

- Trunciranje sadržaja dnevnika.
- Prepisivanje cijele datoteke iz vanjskog izvora bez posebnog zadatka.
- Retroaktivno uređivanje starih unosa bez eksplicitnog sanacijskog naloga.

---

## 5) Odnos prema gateovima

Ovaj standard ne zamjenjuje postojeće gateove.
Nakon svake izmjene dnevnika i dalje su obavezni:

- `alati/lint_markdown.ps1` (ako je diran `.md`),
- `alati/ci_smoke.ps1`,
- završni dokaz čistoće (`git status --short`).
