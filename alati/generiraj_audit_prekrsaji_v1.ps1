#requires -Version 7.0

param(
    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $true)]
    [string] $Tok,

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string] $DataRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'putanje_predmeta_core.ps1')

if ($PredmetId -notmatch "^[A-Za-z0-9_-]+$") {
    Write-Host "ERROR: PREDMET_ID_INVALID=$PredmetId"
    exit 1
}
if ($Tok -notmatch "^TOK_[A-Z0-9_]+$") {
    Write-Host "ERROR: TOK_INVALID=$Tok"
    exit 1
}
if ($Verzija -notmatch "^v[0-9]+$") {
    Write-Host "ERROR: VERZIJA_INVALID=$Verzija"
    exit 1
}

$postupakRef = "postupci/sud/prekrsajni/$Tok/$Verzija/postupak.json"
try {
    $pathContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId $PredmetId `
        -DataRoot $DataRoot
    $postupakSpec = Resolve-VeritasReference `
        -PathRef $postupakRef `
        -Context $pathContext `
        -ExpectedScope Repository
    $postupakPath = $postupakSpec.Path
}
catch {
    Write-Host "ERROR: PATH_CONTEXT_INVALID=$($_.Exception.Message)"
    exit 1
}

if (-not (Test-Path -LiteralPath $postupakPath)) {
    Write-Host "ERROR: POSTUPAK_NOT_FOUND=$postupakRef"
    exit 1
}

try {
    $postupak = Get-Content -LiteralPath $postupakPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: POSTUPAK_JSON_PARSE_FAIL=$postupakRef"
    exit 1
}

try {
    $predmetSpec = Resolve-VeritasReference `
        -PathRef ([string]$postupak.ulazi.predmet_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $intakeSpec = Resolve-VeritasReference `
        -PathRef ([string]$postupak.ulazi.intake_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $subsumcijaSpec = Resolve-VeritasReference `
        -PathRef ([string]$postupak.ulazi.subsumcija_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $existingAuditSpec = Resolve-VeritasReference `
        -PathRef "predmeti/sud/prekrsajni/{PREDMET_ID}/audit/audit_v1.json" `
        -Context $pathContext `
        -ExpectedScope Subject
    $outputSpec = Resolve-VeritasReference `
        -PathRef ([string]$postupak.ulazi.audit_ref) `
        -Context $pathContext `
        -ExpectedScope Subject

    $predmetRef = $predmetSpec.Ref
    $intakeRef = $intakeSpec.Ref
    $subsumcijaRef = $subsumcijaSpec.Ref
    $existingAuditRef = $existingAuditSpec.Ref
    $outputRef = $outputSpec.Ref
    $predmetPath = $predmetSpec.Path
    $intakePath = $intakeSpec.Path
    $subsumcijaPath = $subsumcijaSpec.Path
    $existingAuditPath = $existingAuditSpec.Path
    $outputPath = $outputSpec.Path
}
catch {
    Write-Host "ERROR: PROCEDURE_PATH_INVALID=$($_.Exception.Message)"
    exit 1
}

if (-not (Test-Path -LiteralPath $predmetPath)) {
    Write-Host "ERROR: PREDMET_NOT_FOUND=$predmetRef"
    exit 1
}
if (-not (Test-Path -LiteralPath $intakePath)) {
    Write-Host "ERROR: INTAKE_NOT_FOUND=$intakeRef"
    exit 1
}
if (-not (Test-Path -LiteralPath $subsumcijaPath)) {
    Write-Host "ERROR: SUBSUMCIJA_NOT_FOUND=$subsumcijaRef"
    exit 1
}

$normaSidra = @()
if ($null -ne $postupak.ulazi.PSObject.Properties["norma_refs"] -and $null -ne $postupak.ulazi.norma_refs) {
    foreach ($normaRefValue in @($postupak.ulazi.norma_refs)) {
        $normaRef = [string]$normaRefValue
        if ([string]::IsNullOrWhiteSpace($normaRef)) {
            continue
        }

        try {
            $normaSpec = Resolve-VeritasReference `
                -PathRef $normaRef `
                -Context $pathContext `
                -ExpectedScope Repository
            $normaPath = $normaSpec.Path
        }
        catch {
            Write-Host "ERROR: NORMA_REF_PATH_INVALID=$normaRef"
            exit 1
        }

        if (-not (Test-Path -LiteralPath $normaPath)) {
            Write-Host "ERROR: NORMA_REF_NOT_FOUND=$normaRef"
            exit 1
        }

        try {
            $norma = Get-Content -LiteralPath $normaPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        catch {
            Write-Host "ERROR: NORMA_REF_JSON_PARSE_FAIL=$normaRef"
            exit 1
        }

        $sidroStatus = ""
        if ($null -ne $norma.PSObject.Properties["izvori"] -and $null -ne $norma.izvori -and $null -ne $norma.izvori.PSObject.Properties["status_sidra"]) {
            $sidroStatus = [string]$norma.izvori.status_sidra
        }

        if ($sidroStatus -ne "puno") {
            Write-Host "ERROR: NORMA_REF_SIDRO_NOT_FULL=$normaRef"
            exit 1
        }

        $normaSidra += ($normaRef -replace "\\", "/")
    }
}

try {
    $predmet = Get-Content -LiteralPath $predmetPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
}
catch {
    Write-Host "ERROR: PREDMET_JSON_PARSE_FAIL=$predmetRef"
    exit 1
}

$predmetProfile = Test-VeritasSubjectPrivacyEnvelope `
    -Document $predmet `
    -Context $pathContext
if (-not $predmetProfile.Valid) {
    Write-Host (
        "ERROR: PREDMET_PRIVACY_PROFILE_INVALID=" +
        ($predmetProfile.Errors -join ',')
    )
    exit 1
}

try {
    $intake = Get-Content -LiteralPath $intakePath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: INTAKE_JSON_PARSE_FAIL=$intakeRef"
    exit 1
}

try {
    $subsumcija = Get-Content -LiteralPath $subsumcijaPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: SUBSUMCIJA_JSON_PARSE_FAIL=$subsumcijaRef"
    exit 1
}

$existingAudit = $null
if (Test-Path -LiteralPath $existingAuditPath) {
    try {
        $existingAudit = Get-Content -LiteralPath $existingAuditPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        $existingAudit = $null
    }
}

function ConvertTo-VeritasDate {
    param(
        [Parameter(Mandatory = $false)]
        [string] $Raw
    )

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return $null
    }

    $match = [regex]::Match($Raw.Trim(), '^(\d{2})\.(\d{2})\.(\d{4})\.?$')
    if (-not $match.Success) {
        return $null
    }

    $day = [int]$match.Groups[1].Value
    $month = [int]$match.Groups[2].Value
    $year = [int]$match.Groups[3].Value

    try {
        return (Get-Date -Year $year -Month $month -Day $day).Date
    }
    catch {
        return $null
    }
}

function ConvertTo-VeritasDateString {
    param(
        [Parameter(Mandatory = $false)]
        [object] $Value
    )

    if ($null -eq $Value) {
        return ""
    }

    try {
        $parsed = [datetime]$Value
        return $parsed.ToString("dd.MM.yyyy.")
    }
    catch {
        return ""
    }
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

$g1Days = 8
$g1StartDate = $null
if ($null -ne $intake.PSObject.Properties["meta"] -and $null -ne $intake.meta -and $null -ne $intake.meta.PSObject.Properties["datum_izrade"]) {
    $g1StartDate = ConvertTo-VeritasDate -Raw ([string]$intake.meta.datum_izrade)
}

$g1ReferenceDate = $null
$g1ReferenceSource = ""
if ($null -ne $existingAudit -and $null -ne $existingAudit.PSObject.Properties["meta"] -and $null -ne $existingAudit.meta -and $null -ne $existingAudit.meta.PSObject.Properties["datum_izrade"]) {
    $g1ReferenceDate = ConvertTo-VeritasDate -Raw ([string]$existingAudit.meta.datum_izrade)
    if ($null -ne $g1ReferenceDate) {
        $g1ReferenceSource = "audit.meta.datum_izrade"
    }
}

$g1UsedSystemReference = $false
if ($null -eq $g1ReferenceDate) {
    $g1ReferenceDate = (Get-Date).Date
    $g1ReferenceSource = "sistemski_datum"
    $g1UsedSystemReference = $true
}

$g1Status = "OK"
$g1DueDate = $null
$g1Note = ""

if ($null -eq $g1StartDate) {
    $g1Status = "MISSING"
    $g1Note = "Nedostaje trigger datum intake.meta.datum_izrade; rok nije izračunljiv."
}
else {
    $g1DueDate = $g1StartDate.AddDays($g1Days)

    if ($g1UsedSystemReference) {
        $g1Status = "INDETERMINATE"
        $g1Note = "Referentni datum iz predmeta/audita nedostaje; korišten je sistemski datum."
    }
    elseif ($g1ReferenceDate -gt $g1DueDate) {
        $g1Status = "LATE"
        $g1Note = "Rok je propušten prema referentnom datumu iz audita."
    }
    else {
        $g1Status = "OK"
        $g1Note = "Rok je u granici prema referentnom datumu iz audita."
    }
}

$g1StatusText = "G1_STATUS=$g1Status"
$g1WarningReason = ""
if ($g1Status -eq "MISSING") {
    $g1WarningReason = "Nedovoljno podataka za izračun roka (nedostaje trigger datum)."
}
elseif ($g1Status -eq "LATE") {
    $g1WarningReason = "Rok je propušten prema dostupnim datumima."
}
elseif ($g1Status -eq "INDETERMINATE") {
    $g1WarningReason = "Rok je izračunat uz sistemski referentni datum; status je informativan."
}

$g1 = [ordered]@{
    status = $g1Status
    start_date = (ConvertTo-VeritasDateString -Value $g1StartDate)
    due_date = (ConvertTo-VeritasDateString -Value $g1DueDate)
    days = $g1Days
    note = $g1Note
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

$hasBlocker = (-not $g2Pass) -or (-not $g3Pass)
$hasWarning = $g1Status -ne "OK"

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
        [Parameter(Mandatory = $true)][string] $Posljedica,
        [Parameter(Mandatory = $false)][string] $NormaRef = ""
    )

    return [ordered]@{
        kod = $Kod
        opis = $Opis
        norma_ref = $NormaRef
        tezina = $Tezina
        posljedica = $Posljedica
    }
}

$g1Result = if ($g1Status -eq "OK") { "PASS" } else { "WARN" }
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
    (New-Nalaz -Kod "NAP-G1" -Opis "Provjera gate=G1; rezultat=$g1Result; $g1StatusText." -Pass:$true -Posljedica "G1 je soft pravilo u v1 i ne blokira samostalno."),
    (New-Nalaz -Kod "NAP-G2" -Opis "Provjera gate=G2; rezultat=$g2Result." -Pass:$g2Pass -Posljedica "Činjenični prag iz intake ulaza obrađen."),
    (New-Nalaz -Kod "NAP-G3" -Opis "Provjera gate=G3; rezultat=$g3Result." -Pass:$g3Pass -Posljedica "Subsumcija/kolizija provjera izvršena."),
    (New-Nalaz -Kod "NAP-SEM" -Opis "Preflight naplate: preflight=$preflight." -Pass:($preflight -eq "ZELENO") -Posljedica "Semafor određuje blocked stanje po blocker/warning pravilima."),
    (New-Nalaz -Kod "NAP-ODL" -Opis "naplata=$naplata" -Pass:($naplata -eq "DOPUSTENO") -Posljedica "Odluka naplate izvedena iz preflight semafora.")
)

if ($hasBlocker) {
    $nalazi += (New-NalazRaw -Kod "NAP-RED-BLOCKER" -Opis "Blocker klasa aktivna: $classDetailText." -Tezina "VISOKA" -Posljedica "Semafor je CRVENO.")
}

if ($hasWarning) {
    if ($g1Status -eq "MISSING") {
        $nalazi += (New-NalazRaw -Kod "NAP-G1-MISSING" -Opis $g1WarningReason -Tezina "SREDNJA" -Posljedica "G1 soft warning; ne blokira samostalno.")
    }
    elseif ($g1Status -eq "LATE") {
        $nalazi += (New-NalazRaw -Kod "NAP-G1-LATE" -Opis $g1WarningReason -Tezina "SREDNJA" -Posljedica "G1 soft warning; ne blokira samostalno.")
    }
    elseif ($g1Status -eq "INDETERMINATE") {
        $nalazi += (New-NalazRaw -Kod "NAP-G1-INDETERMINATE" -Opis $g1WarningReason -Tezina "SREDNJA" -Posljedica "G1 soft warning; ne blokira samostalno.")
    }

    if (-not $hasBlocker) {
        $nalazi += (New-NalazRaw -Kod "NAP-YEL-WARNING" -Opis "Warning klasa aktivna bez blockera." -Tezina "SREDNJA" -Posljedica "Semafor je ZUTO.")
    }
}

if ((-not $hasBlocker) -and (-not $hasWarning)) {
    $nalazi += (New-NalazRaw -Kod "NAP-GRN-OK" -Opis "Nema blocker ni warning nalaza." -Tezina "NISKA" -Posljedica "Semafor je ZELENO.")
}

foreach ($normaSidro in $normaSidra) {
    $nalazi += (New-NalazRaw `
        -Kod "NORMA-SIDRO" `
        -Opis "Provjereno puno NN sidro za P7 nacrt." `
        -Tezina "NISKA" `
        -Posljedica "Sidro je dostupno za strogu provjeru prije nacrta." `
        -NormaRef $normaSidro)
}

$datumIzrade = (Get-Date).ToString("dd.MM.yyyy.")

$doc = [ordered]@{
    meta = [ordered]@{
        id_predmeta = $PredmetId
        tok = $Tok
        verzija_toka = $Verzija
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
    g1 = $g1
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
        Write-Host "ERROR: OUTPUT_DIR_CREATE_FAIL=$outputRef"
        exit 1
    }
}

try {
    $json = $doc | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8NoBOM
}
catch {
    Write-Host "ERROR: OUTPUT_WRITE_FAIL=$outputRef"
    exit 1
}

Write-Host "GEN_AUDIT_EXIT=0"
Write-Host "AUDIT_GENERATED_REF=$outputRef"
if ($pathContext.Mode -eq 'public') {
    Write-Host "AUDIT_GENERATED_PATH=$outputPath"
}
else {
    Write-Host "AUDIT_GENERATED_PATH_REDACTED=True"
}
exit 0
