# COPILOT UPUTE — Veritas H.77 (kanon)

## 0) Osnovno

Radi deterministički: bez nagađanja, bez “možda”.

Jedan zadatak = jedna operacija = jedan scoped commit.

PowerShell naredbe su jednolinijske i copy/paste za Windows.

## 1) Opseg (scope) je zakon

Ne mijenjaj nijednu datoteku izvan eksplicitno navedenog opsega.

Prije bilo kakvog git add obavezno ispiši:

git diff --name-only

git status --short

Ako je promijenjena datoteka izvan opsega:

vrati je na HEAD (git restore -- <putanja>)

ili prekini i prijavi (bez commita).

## 2) Markdown hard gate

Ako je promijenjen ijedan .md, prije commita obavezno pokreni
markdownlint.

Ako postoji ijedna greška (posebno MD013), nema commita.

Ako se greške ne mogu ukloniti bez prelaska scope-a:

prekini i prijavi točno: datoteka + linije + pravila.

## 3) Fail-fast (bez šminke)

Kad nešto padne, vrati točan dokaz:

naredba koja je izvršena

izlaz/poruka greške

exit code

popis datoteka i linija (za lint/parse greške)

## 4) Bez skrivenih izmjena

Zabranjeno je “usput” formatirati, refaktorirati ili preuređivati
datoteke izvan zadatka.

Preferiraj najmanji mogući patch.

## 5) Idempotencija

Skripte i gate koraci moraju biti idempotentni:
drugi run ne smije stvarati nove nuspojave ili nove promjene u repou.

## 6) Stabilni markeri za CI/gate

Svaki CI/gate korak mora ispisati stabilne, grep-friendly markere:

<NAZIV>_BEGIN

<NAZIV>_END

<NAZIV>_EXIT=<broj>

## 7) Bez prepisivanja povijesti

Bez eksplicitnog naloga je zabranjeno:

git commit --amend

rebase

reset --hard

push --force

## 8) Obvezni završni dokazi (svaki zadatak)

Zadatak završava tek kad su ispisani ovi dokazi:

CI_SMOKE_EXIT=<broj>

git status --short (mora biti prazan)

git --no-pager log -1 --oneline

## 9) Dnevnik rada (audit trail)

Za svaki značajan zadatak dopuniti dokumentacija/DNEVNIK_RADA.md sa:

što je napravljeno

zašto

kako je verificirano (komande)

commit hash

## 10) Definition of Done (DoD)

Zadatak je gotov samo ako vrijedi sve:

scope čist (nema izmjena izvan opsega)

smoke/test prolazi

markdownlint prolazi (ako je diran .md)

commit poruka točna i na hrvatskom

repo čist

## Minimalne PowerShell komande (kanonski “završni blok”)

(uvijek na kraju taska)

Set-Location -LiteralPath "C:\Veritas_H77";
powershell -NoProfile -ExecutionPolicy Bypass -File .\alati\ci_smoke.ps1;
Write-Host "CI_SMOKE_EXIT=$LASTEXITCODE"

Set-Location -LiteralPath "C:\Veritas_H77"; git status --short;
git --no-pager log -1 --oneline
