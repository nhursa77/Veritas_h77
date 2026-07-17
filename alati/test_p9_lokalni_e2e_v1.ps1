#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')

$subjectSuffix = [Guid]::NewGuid().ToString('N').Substring(0, 8).ToUpperInvariant()
$predmetId = "STVARNI_P9_E2E_$subjectSuffix"
$tok = 'TOK_PN_PRIGOVOR'
$verzija = 'v1'
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase (
    'veritas_local_e2e_' + [Guid]::NewGuid().ToString('N')
)
$subjectRoot = Join-Path $tempRoot (
    "predmeti\sud\prekrsajni\$predmetId"
)
$publicRoot = Join-Path $repoRoot (
    'predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001'
)
$repoSubjectRoot = Join-Path $repoRoot (
    "predmeti\sud\prekrsajni\$predmetId"
)

$predmetPath = Join-Path $subjectRoot 'predmet.json'
$intakePath = Join-Path $subjectRoot 'intake\intake_v1.json'
$subsumcijaPath = Join-Path $subjectRoot 'audit\subsumcija_v1.json'
$auditSeedPath = Join-Path $subjectRoot 'audit\audit_v1.json'
$auditGeneratedPath = Join-Path $subjectRoot (
    'audit\audit_generated_v1.json'
)
$draftPath = Join-Path $subjectRoot (
    'izlazi\nacrt_prigovor_pn_v1.txt'
)
$manifestPath = Join-Path $subjectRoot 'manifest.json'
$chainPath = Join-Path $subjectRoot 'lanac_skrbnistva.json'

$predmetValidator = Join-Path $PSScriptRoot (
    'validiraj_predmet_prekrsaji_v1.ps1'
)
$auditGenerator = Join-Path $PSScriptRoot (
    'generiraj_audit_prekrsaji_v1.ps1'
)
$p7Runner = Join-Path $PSScriptRoot 'run_tok_v1.ps1'
$p8Generator = Join-Path $PSScriptRoot (
    'generiraj_p8_manifest_i_lanac_v1.ps1'
)
$p8Validator = Join-Path $PSScriptRoot (
    'validiraj_p8_manifest_i_lanac_v1.ps1'
)

function Assert-LocalE2E {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Write-LocalE2EJson {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Document
    )

    $json = $Document | ConvertTo-Json -Depth 100
    Set-Content -LiteralPath $Path -Value $json -Encoding utf8NoBOM
}

function Invoke-LocalE2EScript {
    param(
        [Parameter(Mandatory = $true)][string] $ScriptPath,
        [Parameter(Mandatory = $false)][string[]] $Arguments = @()
    )

    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath `
            @Arguments 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function Assert-LocalE2EResult {
    param(
        [Parameter(Mandatory = $true)] $Result,
        [Parameter(Mandatory = $true)][string] $Marker,
        [Parameter(Mandatory = $true)][string] $Name
    )

    Assert-LocalE2E `
        -Condition ($Result.ExitCode -eq 0) `
        -Reason "$Name nije završio uspješno"
    Assert-LocalE2E `
        -Condition $Result.Text.Contains($Marker) `
        -Reason "$Name nema očekivani marker"

    foreach ($forbidden in @($tempRoot, $tempRoot.Replace('\', '/'))) {
        Assert-LocalE2E `
            -Condition (-not $Result.Text.Contains($forbidden)) `
            -Reason "$Name je otkrio fizičku lokalnu putanju"
    }
}

function Remove-LocalE2ETempRoot {
    $tempFull = [System.IO.Path]::GetFullPath($tempRoot).TrimEnd('\', '/')
    $baseFull = $tempBase.TrimEnd('\', '/')
    $leaf = Split-Path -Path $tempFull -Leaf
    if (-not (
        Test-VeritasPathInsideRoot -Candidate $tempFull -Root $baseFull
    )) {
        throw 'LOCAL_E2E_CLEANUP_OUTSIDE_TEMP'
    }
    if ($leaf -notmatch '^veritas_local_e2e_[a-f0-9]{32}$') {
        throw 'LOCAL_E2E_CLEANUP_NAME_INVALID'
    }
    if (Test-Path -LiteralPath $tempFull) {
        Remove-Item -LiteralPath $tempFull -Recurse -Force
    }
}

$gitBefore = @(git status --porcelain=v1 --untracked-files=all)
$testSucceeded = $false
$failureMessage = ''
$cleanupSucceeded = $false

try {
    Assert-LocalE2E `
        -Condition (-not (
            Test-VeritasPathInsideRoot -Candidate $tempRoot -Root $repoRoot
        )) `
        -Reason 'Privremeni lokalni korijen nalazi se unutar repozitorija'
    Assert-LocalE2E `
        -Condition (-not (Test-Path -LiteralPath $repoSubjectRoot)) `
        -Reason 'Testni lokalni predmet već postoji u repozitoriju'

    foreach ($directory in @(
            $subjectRoot,
            (Join-Path $subjectRoot 'intake'),
            (Join-Path $subjectRoot 'audit'),
            (Join-Path $subjectRoot 'dokazi'),
            (Join-Path $subjectRoot 'izlazi')
        )) {
        [void](New-Item -ItemType Directory -Path $directory -Force)
    }

    $copies = @(
        [pscustomobject]@{
            Source = Join-Path $publicRoot 'predmet.json'
            Target = $predmetPath
        },
        [pscustomobject]@{
            Source = Join-Path $publicRoot 'intake\intake_v1.json'
            Target = $intakePath
        },
        [pscustomobject]@{
            Source = Join-Path $publicRoot 'audit\subsumcija_v1.json'
            Target = $subsumcijaPath
        },
        [pscustomobject]@{
            Source = Join-Path $publicRoot 'audit\audit_v1.json'
            Target = $auditSeedPath
        }
    )
    foreach ($copy in $copies) {
        Copy-Item -LiteralPath $copy.Source -Destination $copy.Target
    }

    $predmet = Get-Content -LiteralPath $predmetPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    $predmet.meta.id_predmeta = $predmetId
    $predmet.meta.vrsta = 'stvarni'
    $predmet.meta.rezim_podataka = 'lokalni_povjerljivi'
    $predmet.privatnost.klasifikacija = 'LOKALNO_POVJERLJIVO'
    $predmet.privatnost.sadrzi_osobne_podatke = $true
    $predmet.privatnost.dopusteno_git_pracenje = $false
    Write-LocalE2EJson -Path $predmetPath -Document $predmet

    foreach ($path in @($intakePath, $subsumcijaPath, $auditSeedPath)) {
        $document = Get-Content -LiteralPath $path -Raw -Encoding UTF8 |
            ConvertFrom-Json
        $document.meta.id_predmeta = $predmetId
        Write-LocalE2EJson -Path $path -Document $document
    }

    $subjectValidation = Invoke-LocalE2EScript `
        -ScriptPath $predmetValidator `
        -Arguments @(
            '-PredmetPath', $predmetPath,
            '-LocalDataRoot', $tempRoot
        )
    Assert-LocalE2EResult `
        -Result $subjectValidation `
        -Marker 'P9_PREDMET_VALIDATOR_STATUS=VALIDNO' `
        -Name 'Strogi validator lokalnog predmeta'

    $commonArgs = @(
        '-PredmetId', $predmetId,
        '-Tok', $tok,
        '-Verzija', $verzija,
        '-DataRoot', $tempRoot
    )
    $auditResult = Invoke-LocalE2EScript `
        -ScriptPath $auditGenerator `
        -Arguments $commonArgs
    Assert-LocalE2EResult `
        -Result $auditResult `
        -Marker 'AUDIT_GENERATED_PATH_REDACTED=True' `
        -Name 'Lokalni audit generator'

    $p7Result = Invoke-LocalE2EScript `
        -ScriptPath $p7Runner `
        -Arguments $commonArgs
    Assert-LocalE2EResult `
        -Result $p7Result `
        -Marker 'OUTPUT_PATH_REDACTED=True' `
        -Name 'Lokalni P7 runner'

    $p8Result = Invoke-LocalE2EScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-LocalE2EResult `
        -Result $p8Result `
        -Marker 'P8_LOCAL_PATHS_REDACTED=True' `
        -Name 'Lokalni P8 generator'

    $p8Validation = Invoke-LocalE2EScript `
        -ScriptPath $p8Validator `
        -Arguments $commonArgs
    Assert-LocalE2EResult `
        -Result $p8Validation `
        -Marker 'P8_VALIDATOR_RESULT=OK' `
        -Name 'Lokalni P8 validator'

    foreach ($outputPath in @(
            $auditGeneratedPath,
            $draftPath,
            $manifestPath,
            $chainPath
        )) {
        Assert-LocalE2E `
            -Condition (Test-Path -LiteralPath $outputPath -PathType Leaf) `
            -Reason 'Nedostaje očekivani lokalni izlaz'
        Assert-LocalE2E `
            -Condition (
                Test-VeritasPathInsideRoot `
                    -Candidate $outputPath `
                    -Root $subjectRoot
            ) `
            -Reason 'Lokalni izlaz nije ostao unutar predmeta'
    }
    Assert-LocalE2E `
        -Condition (-not (Test-Path -LiteralPath $repoSubjectRoot)) `
        -Reason 'Lokalni tok stvorio je predmet unutar repozitorija'

    $manifestRaw = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
    $chainRaw = Get-Content -LiteralPath $chainPath -Raw -Encoding UTF8
    $manifest = $manifestRaw | ConvertFrom-Json
    Assert-LocalE2E `
        -Condition ([string]$manifest.meta.vrsta_predmeta -eq 'stvarni') `
        -Reason 'Manifest nema lokalnu vrstu predmeta'
    foreach ($artifact in @($manifest.artefakti)) {
        $reference = [string]$artifact.putanja
        Assert-LocalE2E `
            -Condition (-not [System.IO.Path]::IsPathRooted(
                $reference.Replace('/', '\')
            )) `
            -Reason 'Manifest sadrži apsolutnu putanju'
        Assert-LocalE2E `
            -Condition (-not $reference.Contains('..')) `
            -Reason 'Manifest sadrži izlazak iz korijena'
    }
    foreach ($rawPackage in @($manifestRaw, $chainRaw)) {
        Assert-LocalE2E `
            -Condition (-not $rawPackage.Contains($tempRoot)) `
            -Reason 'Dokazni paket otkriva fizički lokalni korijen'
    }

    Write-Host 'P9_LOCAL_E2E_SUBJECT_VALID=OK'
    Write-Host 'P9_LOCAL_E2E_OUTPUTS_EXTERNAL=4'
    Write-Host 'P9_LOCAL_E2E_PATH_DISCLOSURE=0'
    Write-Host 'P9_LOCAL_E2E_CANONICAL_REFS=OK'
    $testSucceeded = $true
}
catch {
    $failureMessage = $_.Exception.Message
}
finally {
    try {
        Remove-LocalE2ETempRoot
        $cleanupSucceeded = $true
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($failureMessage)) {
            $failureMessage = $_.Exception.Message
        }
        $testSucceeded = $false
    }
}

$gitAfter = @(git status --porcelain=v1 --untracked-files=all)
$gitBeforeText = ($gitBefore | ForEach-Object { [string]$_ }) -join "`n"
$gitAfterText = ($gitAfter | ForEach-Object { [string]$_ }) -join "`n"
if ($gitBeforeText -ne $gitAfterText) {
    $testSucceeded = $false
    $failureMessage = 'LOCAL_E2E_GIT_STATE_CHANGED'
}

if ($cleanupSucceeded) {
    Write-Host 'P9_LOCAL_E2E_CLEANUP=OK'
}
if (-not $testSucceeded) {
    Write-Host "ERROR: P9_LOCAL_E2E_FAIL=$failureMessage"
    Write-Host 'P9_LOCAL_E2E_EXIT=1'
    exit 1
}

Write-Host 'P9_LOCAL_E2E_GIT_STATE=UNCHANGED'
Write-Host 'P9_LOCAL_E2E_RESULT=OK'
Write-Host 'P9_LOCAL_E2E_EXIT=0'
exit 0
