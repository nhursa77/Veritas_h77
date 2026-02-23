param(
    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $true)]
    [string] $Tok,

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent

$postupakPath = Join-Path $repoRoot ("postupci\sud\prekrsajni\{0}\{1}\postupak.json" -f $Tok, $Verzija)
$intakePath = Join-Path $repoRoot ("predmeti\sud\prekrsajni\{0}\intake\intake_v1.json" -f $PredmetId)
$subsumcijaPath = Join-Path $repoRoot ("predmeti\sud\prekrsajni\{0}\audit\subsumcija_v1.json" -f $PredmetId)
$existingAuditPath = Join-Path $repoRoot ("predmeti\sud\prekrsajni\{0}\audit\audit_v1.json" -f $PredmetId)
$outputPath = Join-Path $repoRoot ("predmeti\sud\prekrsajni\{0}\audit\audit_generated_v1.json" -f $PredmetId)

if (-not (Test-Path -LiteralPath $postupakPath)) {
    Write-Host "ERROR: POSTUPAK_NOT_FOUND=$postupakPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $intakePath)) {
    Write-Host "ERROR: INTAKE_NOT_FOUND=$intakePath"
    exit 1
}

if (-not (Test-Path -LiteralPath $subsumcijaPath)) {
    Write-Host "ERROR: SUBSUMCIJA_NOT_FOUND=$subsumcijaPath"
    exit 1
}

try {
    $postupak = Get-Content -LiteralPath $postupakPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: POSTUPAK_JSON_PARSE_FAIL=$postupakPath"
    exit 1
}

try {
    $intake = Get-Content -LiteralPath $intakePath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: INTAKE_JSON_PARSE_FAIL=$intakePath"
    exit 1
}

try {
    $subsumcija = Get-Content -LiteralPath $subsumcijaPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: SUBSUMCIJA_JSON_PARSE_FAIL=$subsumcijaPath"
    exit 1
}

$existingAudit = $null
if (Test-Path -LiteralPath $existingAuditPath) {
    try {
        $existingAudit = Get-Content -LiteralPath $existingAuditPath -Raw | ConvertFrom-Json
    }
    catch {
        $existingAudit = $null
    }
}

function Try-ParseVeritasDate {
    param(
        [Parameter(Mandatory = $false)]
        [string] $Raw
    )

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return $null
    }

    $formats = @("dd.MM.yyyy.", "dd.MM.yyyy")
    $parsed = [datetime]::MinValue
    $ok = [datetime]::TryParseExact(
        $Raw.Trim(),
        $formats,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$parsed
    )

    if ($ok) {
        return $parsed.Date
    }

    return $null
}

$hasKOL01 = $false
if ($null -ne $existingAudit -and $null -ne $existingAudit.nalazi) {
    foreach ($nalaz in @($existingAudit.nalazi)) {
        if ([string]$nalaz.kod -eq "KOL-01") {
            $hasKOL01 = $true
            break
        }
    }
}

$hasSubsumcijaProlaz = $false
$subsumcijaElementi = @()
if ($null -ne $subsumcija.PSObject.Properties["elementi_bica"] -and $null -ne $subsumcija.elementi_bica) {
    $subsumcijaElementi = @($subsumcija.elementi_bica)
}

foreach ($element in $subsumcijaElementi) {
    $rezultat = ""
    if ($null -ne $element.PSObject.Properties["rezultat"]) {
        $rezultat = [string]$element.rezultat
    }

    if ($rezultat -eq "PROLAZ") {
        $hasSubsumcijaProlaz = $true
        break
    }
}

$g1Pass = $true
$g1StatusText = "G1_STATUS=OK"
$g1WarningReason = ""

$intakeDatum = $null
if ($null -ne $intake.PSObject.Properties["meta"] -and $null -ne $intake.meta -and $null -ne $intake.meta.PSObject.Properties["datum_izrade"]) {
    $intakeDatum = Try-ParseVeritasDate -Raw ([string]$intake.meta.datum_izrade)
}

$auditDatum = $null
if ($null -ne $existingAudit -and $null -ne $existingAudit.PSObject.Properties["meta"] -and $null -ne $existingAudit.meta -and $null -ne $existingAudit.meta.PSObject.Properties["datum_izrade"]) {
    $auditDatum = Try-ParseVeritasDate -Raw ([string]$existingAudit.meta.datum_izrade)
}

if ($null -eq $intakeDatum -or $null -eq $auditDatum) {
    $g1StatusText = "G1_STATUS=MISSING"
    $g1WarningReason = "Nedovoljno podataka za izračun roka (intake/audit datum)."
}
else {
    $daysDelta = [int](($auditDatum - $intakeDatum).TotalDays)
    if ($daysDelta -gt 8) {
        $g1StatusText = "G1_STATUS=LATE"
        $g1WarningReason = "Rok je propušten prema dostupnim datumima (delta_dani=$daysDelta)."
    }
}

$hasKontradikcije = $false
$intakeKontradikcije = $null
if ($null -ne $intake.PSObject.Properties["kontradikcije"]) {
    $intakeKontradikcije = $intake.kontradikcije
}
if ($null -ne $intakeKontradikcije -and $null -ne $intakeKontradikcije.PSObject.Properties["ima_kontradikcija"]) {
    $hasKontradikcije = [bool]$intakeKontradikcije.ima_kontradikcija
}

$hasOsporavanja = $false
if ($null -ne $intake.PSObject.Properties["osporavanja"] -and $null -ne $intake.osporavanja -and @($intake.osporavanja).Count -gt 0) {
    $hasOsporavanja = $true
}

$ciljRaw = ""
if ($null -ne $intake.PSObject.Properties["cilj"]) {
    $ciljRaw = [string]$intake.cilj
}
$hasCilj = -not [string]::IsNullOrWhiteSpace($ciljRaw)
$g2Pass = (-not $hasKontradikcije) -and $hasOsporavanja -and $hasCilj
$g3Pass = $hasSubsumcijaProlaz -or $hasKOL01

$hasBlocker = (-not $g1Pass) -or (-not $g2Pass) -or (-not $g3Pass)
$hasWarning = -not [string]::IsNullOrWhiteSpace($g1WarningReason)

$preflight = "ZELENO"
if ($hasBlocker) {
    $preflight = "CRVENO"
}
elseif ($hasWarning) {
    $preflight = "ZUTO"
}

$blocked = $preflight -eq "CRVENO"
$blockedReason = if ($blocked) { "preflight=CRVENO" } else { "" }

function New-Nalaz {
    param(
        [Parameter(Mandatory = $true)][string] $Kod,
        [Parameter(Mandatory = $true)][string] $Opis,
        [Parameter(Mandatory = $true)][bool] $Pass,
        [Parameter(Mandatory = $true)][string] $Posljedica
    )

    return [ordered]@{
        kod = $Kod
        opis = $Opis
        norma_ref = ""
        tezina = if ($Pass) { "NISKA" } else { "VISOKA" }
        posljedica = $Posljedica
    }
}

function New-NalazRaw {
    param(
        [Parameter(Mandatory = $true)][string] $Kod,
        [Parameter(Mandatory = $true)][string] $Opis,
        [Parameter(Mandatory = $true)][string] $Tezina,
        [Parameter(Mandatory = $true)][string] $Posljedica
    )

    return [ordered]@{
        kod = $Kod
        opis = $Opis
        norma_ref = ""
        tezina = $Tezina
        posljedica = $Posljedica
    }
}

$g1Result = if ($g1Pass) { "PASS" } else { "FAIL" }
$g2Result = if ($g2Pass) { "PASS" } else { "FAIL" }
$g3Result = if ($g3Pass) { "PASS" } else { "FAIL" }
$naplata = if ($preflight -eq "CRVENO") { "ZABRANJENO" } else { "DOPUSTENO" }

$classDetails = @()
if (-not $g2Pass) {
    $classDetails += "G2=FAIL"
}
if (-not $g3Pass) {
    $classDetails += "G3=FAIL"
}
$classDetailText = if ($classDetails.Count -gt 0) { ($classDetails -join ", ") } else { "nema" }

$nalazi = @(
    (New-Nalaz -Kod "NAP-G1" -Opis "Provjera gate=G1; rezultat=$g1Result; $g1StatusText." -Pass:$g1Pass -Posljedica "G1 je soft pravilo u v1 i ne blokira samostalno."),
    (New-Nalaz -Kod "NAP-G2" -Opis "Provjera gate=G2; rezultat=$g2Result." -Pass:$g2Pass -Posljedica "Činjenični prag iz intake ulaza obrađen."),
    (New-Nalaz -Kod "NAP-G3" -Opis "Provjera gate=G3; rezultat=$g3Result." -Pass:$g3Pass -Posljedica "Subsumcija/kolizija provjera izvršena."),
    (New-Nalaz -Kod "NAP-SEM" -Opis "Preflight naplate: preflight=$preflight." -Pass:($preflight -eq "ZELENO") -Posljedica "Semafor određuje blocked stanje po blocker/warning pravilima."),
    (New-Nalaz -Kod "NAP-ODL" -Opis "naplata=$naplata" -Pass:($naplata -eq "DOPUSTENO") -Posljedica "Odluka naplate izvedena iz preflight semafora.")
)

if ($hasBlocker) {
    $nalazi += (New-NalazRaw -Kod "NAP-RED-BLOCKER" -Opis "Blocker klasa aktivna: $classDetailText." -Tezina "VISOKA" -Posljedica "Semafor je CRVENO.")
}

if ($hasWarning) {
    if ($g1StatusText -eq "G1_STATUS=MISSING") {
        $nalazi += (New-NalazRaw -Kod "NAP-G1-MISSING" -Opis $g1WarningReason -Tezina "SREDNJA" -Posljedica "G1 soft warning; ne blokira samostalno.")
    }
    elseif ($g1StatusText -eq "G1_STATUS=LATE") {
        $nalazi += (New-NalazRaw -Kod "NAP-G1-LATE" -Opis $g1WarningReason -Tezina "SREDNJA" -Posljedica "G1 soft warning; ne blokira samostalno.")
    }

    if (-not $hasBlocker) {
        $nalazi += (New-NalazRaw -Kod "NAP-YEL-WARNING" -Opis "Warning klasa aktivna bez blockera." -Tezina "SREDNJA" -Posljedica "Semafor je ZUTO.")
    }
}

if ((-not $hasBlocker) -and (-not $hasWarning)) {
    $nalazi += (New-NalazRaw -Kod "NAP-GRN-OK" -Opis "Nema blocker ni warning nalaza." -Tezina "NISKA" -Posljedica "Semafor je ZELENO.")
}

$datumIzrade = (Get-Date).ToString("dd.MM.yyyy.")

$doc = [ordered]@{
    meta = [ordered]@{
        id_predmeta = $PredmetId
        tok = $Tok
        verzija_toka = "v1"
        datum_izrade = $datumIzrade
        izvor_audita = "generiraj_audit_prekrsaji_v1"
    }
    moduli = @(
        [ordered]@{
            id = "P6"
            status = if ($blocked) { "NEPROLAZ" } else { "PROLAZ" }
            razlog = "Deterministicki audit generator v1"
            ulazi = @("intake_v1.json", "subsumcija_v1.json", "postupak.json")
            izlazi = @("audit_generated_v1.json")
        }
    )
    nalazi = $nalazi
    rokovi = @()
    preporuceni_pravni_lijek = [ordered]@{
        naziv = ""
        kome = ""
        rok = ""
        ucinak = ""
    }
    gate_stanje = [ordered]@{
        blocked = $blocked
        blocked_razlog = $blockedReason
    }
}

$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir)) {
    try {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    catch {
        Write-Host "ERROR: OUTPUT_DIR_CREATE_FAIL=$outputDir"
        exit 1
    }
}

try {
    $json = $doc | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $outputPath -Value $json -Encoding UTF8
}
catch {
    Write-Host "ERROR: OUTPUT_WRITE_FAIL=$outputPath"
    exit 1
}

Write-Host "GEN_AUDIT_EXIT=0"
Write-Host "AUDIT_GENERATED_PATH=$outputPath"
exit 0
