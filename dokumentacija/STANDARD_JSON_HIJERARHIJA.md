# STANDARD JSON — HIJERARHIJA (v1)

Datum: 20.02.2026.

Ovaj standard definira pravila hijerarhije izvora i pravila rješavanja
konflikta normi koja se koriste u prekršajnom modulu.

Napomena: ovo nisu “pravna mišljenja”, nego deterministička pravila izbora
izvora u slučaju kolizije.

## 1. Hijerarhija izvora (od jačeg prema slabijem)

1. Ratificirani međunarodni ugovori i temeljna prava (npr. UN/ICCPR/ICESCR),
   u dijelu u kojem se mogu neposredno primijeniti u interpretaciji prava.
2. Ustav Republike Hrvatske.
3. Zakoni (npr. Prekršajni zakon, ZKP gdje je relevantno).
4. Podzakonski akti (pravilnici, uredbe, odluke) — samo ako su u skladu s
   višim izvorima.
5. Sudska praksa i stručna literatura — pomoćni izvor tumačenja, nikada izvor
   “istine” ako je u suprotnosti s višim izvorom.

Pravilo: norma (NN izvor) uvijek ima prednost nad praksom i literaturom.

## 2. Lex specialis i lex generalis

Ako postoje dvije norme iste pravne snage:
- Primjenjuje se posebna norma (lex specialis) u odnosu na opću
  (lex generalis), u okviru konkretne situacije.

## 3. Lex posterior

Ako postoje dvije norme iste pravne snage i iste razine specijalnosti:
- Primjenjuje se novija norma (lex posterior) u odnosu na stariju, uz
  obaveznu provjeru važenja verzije (NN sidro).

## 4. Kolizija i bilježenje odluke

Svaka odluka o koliziji mora se zabilježiti u audit zapisu (M1 ili M2) kroz:
- referencu na oba izvora (sidra/norme)
- korišteno pravilo (lex specialis / lex posterior / hijerarhija)
- kratko obrazloženje

## 5. Minimalni JSON primjer (struktura zapisa)

Ovaj standard definira strukturu zapisa koji se može ugraditi u audit
(npr. kao dio `nalazi` ili posebnog polja unutar modula M1/M2).

```json
{
  "kolizija": {
    "izvor_a_ref": "",
    "izvor_b_ref": "",
    "pravilo": "lex_specialis",
    "odluka": "izvor_a",
    "obrazlozenje": ""
  }
}

Do uvođenja formalne sheme audita, ovaj primjer služi samo kao kanonska
struktura.
