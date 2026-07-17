#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $DataRoot,

    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $false)]
    [string] $Tok = 'TOK_PN_PRIGOVOR',

    [Parameter(Mandatory = $false)]
    [string] $Verzija = 'v1'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'putanje_predmeta_core.ps1')

function Stop-P9Initialization {
    param(
        [Parameter(Mandatory = $true)][string] $Reason,
        [int] $ExitCode = 1
    )

    Write-Host 'P9_INIT_RESULT=STOP'
    Write-Host "P9_INIT_REASON=$Reason"
    Write-Host 'P9_INIT_PATHS_REDACTED=True'
    Write-Host "P9_INIT_EXIT=$ExitCode"
    exit $ExitCode
}

function Remove-P9PartialSubject {
    param(
        [Parameter(Mandatory = $true)] $Context,
        [Parameter(Mandatory = $true)][bool] $Created
    )

    if (-not $Created -or -not (Test-Path -LiteralPath $Context.SubjectRoot)) {
        return
    }

    $leaf = Split-Path -Path $Context.SubjectRoot -Leaf
    if ($leaf -ne $Context.PredmetId) {
        throw 'PARTIAL_CLEANUP_SUBJECT_ID_MISMATCH'
    }
    if (-not (
        Test-VeritasPathInsideRoot `
            -Candidate $Context.SubjectRoot `
            -Root $Context.DataRoot
    )) {
        throw 'PARTIAL_CLEANUP_OUTSIDE_DATA_ROOT'
    }

    Remove-Item -LiteralPath $Context.SubjectRoot -Recurse -Force
}

if ($Tok -ne 'TOK_PN_PRIGOVOR' -or $Verzija -ne 'v1') {
    Stop-P9Initialization -Reason 'TOK_ILI_VERZIJA_NISU_PODRZANI'
}

try {
    $pathContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId $PredmetId `
        -DataRoot $DataRoot
}
catch {
    Stop-P9Initialization -Reason 'LOKALNI_KORIJEN_ILI_PREDMET_NISU_SIGURNI'
}

if ($pathContext.Mode -ne 'local') {
    Stop-P9Initialization -Reason 'LOKALNI_REZIM_JE_OBAVEZAN'
}
if (Test-Path -LiteralPath $pathContext.SubjectRoot) {
    Stop-P9Initialization -Reason 'SUBJECT_ALREADY_EXISTS'
}

$createdSubject = $false
$predmetRef = "$($pathContext.SubjectRef)/predmet.json"
$intakeRef = "$($pathContext.SubjectRef)/intake/intake_v1.json"
$subsumcijaRef = "$($pathContext.SubjectRef)/audit/subsumcija_v1.json"
$auditSeedRef = "$($pathContext.SubjectRef)/audit/audit_v1.json"

try {
    [void](New-Item `
        -ItemType Directory `
        -Path $pathContext.SubjectRoot `
        -ErrorAction Stop)
    $createdSubject = $true

    foreach ($directoryName in @('dokazi', 'intake', 'audit', 'izlazi')) {
        [void](New-Item `
            -ItemType Directory `
            -Path (Join-Path $pathContext.SubjectRoot $directoryName) `
            -ErrorAction Stop)
    }

    $predmet = [ordered]@{
        meta = [ordered]@{
            id_predmeta = $PredmetId
            vrsta = 'stvarni'
            verzija = $Verzija
            domena = 'prekrsajni'
            tok = $Tok
            datum_otvaranja = (Get-Date).ToString('dd.MM.yyyy.')
            status = 'nacrt'
            rezim_podataka = 'lokalni_povjerljivi'
        }
        nositelj = [ordered]@{
            oznaka = 'LOKALNI_NOSITELJ_NEUNESEN'
            ime_prezime = $null
            oib = $null
            adresa = $null
            kontakt = $null
        }
        akt = [ordered]@{
            vrsta = ''
            tijelo = ''
            broj = ''
            datum = $null
            datum_dostave = $null
        }
        obrada = [ordered]@{
            cilj = ''
            pravni_lijek = ''
            rok = $null
        }
        privatnost = [ordered]@{
            klasifikacija = 'LOKALNO_POVJERLJIVO'
            sadrzi_osobne_podatke = $true
            dopusteno_git_pracenje = $false
        }
        sud_naziv = ''
        napomena_nacrt = (
            'RADNI NACRT: podaci nisu uneseni ni provjereni; ' +
            'pokretanje toka mora ostati blokirano.'
        )
    }

    $predmetPath = Join-Path $pathContext.SubjectRoot 'predmet.json'
    $temporaryPath = $predmetPath + '.tmp'
    $json = ($predmet | ConvertTo-Json -Depth 20) + "`n"
    [System.IO.File]::WriteAllText(
        $temporaryPath,
        $json,
        [System.Text.UTF8Encoding]::new($false)
    )
    Move-Item `
        -LiteralPath $temporaryPath `
        -Destination $predmetPath `
        -ErrorAction Stop
}
catch {
    try {
        Remove-P9PartialSubject `
            -Context $pathContext `
            -Created $createdSubject
    }
    catch {
        Stop-P9Initialization -Reason 'INIT_WRITE_AND_CLEANUP_FAILED'
    }
    Stop-P9Initialization -Reason 'INIT_WRITE_FAILED'
}

Write-Host 'P9_INIT_RESULT=OK'
Write-Host 'P9_INIT_STATE=NEPOPUNJEN'
Write-Host "P9_INIT_SUBJECT_REF=$($pathContext.SubjectRef)"
Write-Host "P9_INIT_PREDMET_REF=$predmetRef"
Write-Host "P9_INIT_REQUIRED_INTAKE_REF=$intakeRef"
Write-Host "P9_INIT_REQUIRED_SUBSUMPCIJA_REF=$subsumcijaRef"
Write-Host "P9_INIT_REQUIRED_AUDIT_SEED_REF=$auditSeedRef"
Write-Host 'P9_INIT_PATHS_REDACTED=True'
Write-Host 'P9_INIT_HUMAN_REVIEW_REQUIRED=True'
Write-Host 'P9_INIT_EXIT=0'
exit 0
