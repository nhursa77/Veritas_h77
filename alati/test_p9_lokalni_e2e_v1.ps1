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
$auditContextPath = Join-Path $subjectRoot 'audit\audit_v1.json'
$auditGeneratedPath = Join-Path $subjectRoot (
    'audit\audit_generated_v1.json'
)
$draftPath = Join-Path $subjectRoot (
    'izlazi\nacrt_prigovor_pn_v1.txt'
)
$manifestPath = Join-Path $subjectRoot 'manifest.json'
$chainPath = Join-Path $subjectRoot 'lanac_skrbnistva.json'

$initializer = Join-Path $PSScriptRoot (
    'inicijaliziraj_lokalni_predmet_prekrsaji_v1.ps1'
)
$localRunner = Join-Path $PSScriptRoot (
    'pokreni_lokalni_tok_p9_v1.ps1'
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
$hookBeforeOutput = @(git config --local --get core.hooksPath 2>$null)
$hookBeforeExit = $LASTEXITCODE
$hookBefore = ($hookBeforeOutput | ForEach-Object { [string]$_ }) -join ''
$hookChanged = $false
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

    if ($hookBefore -ne '.githooks') {
        & git config --local core.hooksPath .githooks
        Assert-LocalE2E `
            -Condition ($LASTEXITCODE -eq 0) `
            -Reason 'Test nije uspio privremeno aktivirati privatnosni hook'
        $hookChanged = $true
    }

    $initResult = Invoke-LocalE2EScript `
        -ScriptPath $initializer `
        -Arguments @(
            '-DataRoot', $tempRoot,
            '-PredmetId', $predmetId,
            '-Tok', $tok,
            '-Verzija', $verzija
        )
    Assert-LocalE2EResult `
        -Result $initResult `
        -Marker 'P9_INIT_STATE=NEPOPUNJEN' `
        -Name 'Sigurni inicijalizator lokalnog predmeta'

    foreach ($stalePath in @(
            $auditGeneratedPath,
            $draftPath,
            $manifestPath,
            $chainPath
        )) {
        Set-Content `
            -LiteralPath $stalePath `
            -Value 'STALE_P9_OUTPUT' `
            -Encoding utf8NoBOM
    }
    $incompleteResult = Invoke-LocalE2EScript `
        -ScriptPath $localRunner `
        -Arguments @(
            '-DataRoot', $tempRoot,
            '-PredmetId', $predmetId,
            '-Tok', $tok,
            '-Verzija', $verzija
        )
    Assert-LocalE2EResult `
        -Result $incompleteResult `
        -Marker 'P9_RUN_RESULT=STOP' `
        -Name 'Blokada nepopunjenog lokalnog predmeta'
    Assert-LocalE2E `
        -Condition $incompleteResult.Text.Contains(
            'P9_RUN_ARTIFACT_COUNT=0'
        ) `
        -Reason 'Blokirani lokalni tok nema nulti broj artefakata'
    foreach ($stalePath in @(
            $auditGeneratedPath,
            $draftPath,
            $manifestPath,
            $chainPath
        )) {
        Assert-LocalE2E `
            -Condition (-not (Test-Path -LiteralPath $stalePath)) `
            -Reason 'Blokirani tok nije uklonio zastarjeli izlaz'
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
        }
    )
    foreach ($copy in $copies) {
        Copy-Item `
            -LiteralPath $copy.Source `
            -Destination $copy.Target `
            -Force
    }

    $predmet = Get-Content -LiteralPath $predmetPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    $predmet.meta.id_predmeta = $predmetId
    $predmet.meta.vrsta = 'stvarni'
    $predmet.meta.rezim_podataka = 'lokalni_povjerljivi'
    $predmet.privatnost.klasifikacija = 'LOKALNO_POVJERLJIVO'
    $predmet.privatnost.sadrzi_osobne_podatke = $true
    $predmet.privatnost.dopusteno_git_pracenje = $false
    $predmet.nositelj.oznaka = 'LOKALNI_SINTETICKI_E2E'
    Write-LocalE2EJson -Path $predmetPath -Document $predmet

    foreach ($path in @($intakePath, $subsumcijaPath)) {
        $document = Get-Content -LiteralPath $path -Raw -Encoding UTF8 |
            ConvertFrom-Json
        $document.meta.id_predmeta = $predmetId
        Write-LocalE2EJson -Path $path -Document $document
    }

    $subsumcija = Get-Content `
        -LiteralPath $subsumcijaPath `
        -Raw `
        -Encoding UTF8 | ConvertFrom-Json
    foreach ($element in @($subsumcija.elementi_bica)) {
        $element.cinjenica_ref = 'fixture/P9_LOCAL_E2E/cinjenica'
        $element.dokaz_ref = 'fixture/P9_LOCAL_E2E/dokaz'
        $element.obrazlozenje = (
            'Sintetički lokalni E2E ima potpunu činjenicu i dokaz.'
        )
        $element.status = 'PROLAZ'
    }
    Write-LocalE2EJson -Path $subsumcijaPath -Document $subsumcija
    Assert-LocalE2E `
        -Condition (-not (Test-Path -LiteralPath $auditContextPath)) `
        -Reason 'Seedless P9 test neočekivano ima audit kontekst'

    $commonArgs = @(
        '-PredmetId', $predmetId,
        '-Tok', $tok,
        '-Verzija', $verzija,
        '-DataRoot', $tempRoot
    )
    $runResult = Invoke-LocalE2EScript `
        -ScriptPath $localRunner `
        -Arguments $commonArgs
    foreach ($line in @($runResult.Text -split "`n")) {
        if ($line -match '^P9_RUN_') {
            Write-Host $line
        }
    }
    if ($runResult.ExitCode -ne 0 -and
        -not $runResult.Text.Contains('P9_RUN_RESULT=')) {
        $safeTrace = $runResult.Text.Replace($tempRoot, '<LOCAL_ROOT>')
        $safeTrace = $safeTrace.Replace(
            $tempRoot.Replace('\', '/'),
            '<LOCAL_ROOT>'
        )
        Write-Host "P9_LOCAL_E2E_SAFE_FAILURE_TRACE=$safeTrace"
    }
    Assert-LocalE2EResult `
        -Result $runResult `
        -Marker 'P9_RUN_RESULT=OK' `
        -Name 'Jednonaredbeni lokalni P9 tok'
    foreach ($marker in @(
            'P9_RUN_ARTIFACT_COUNT=4',
            'P9_RUN_PATHS_REDACTED=True',
            'P9_RUN_HUMAN_REVIEW_REQUIRED=True',
            'P9_RUN_SIGNED=False',
            'P9_RUN_SENT=False'
        )) {
        Assert-LocalE2E `
            -Condition $runResult.Text.Contains($marker) `
            -Reason "Jednonaredbeni P9 tok nema marker: $marker"
    }

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
    $generatedAudit = Get-Content `
        -LiteralPath $auditGeneratedPath `
        -Raw `
        -Encoding UTF8 | ConvertFrom-Json
    $generatedCodes = @(
        $generatedAudit.nalazi | ForEach-Object { [string]$_.kod }
    )
    Assert-LocalE2E `
        -Condition ([string]$generatedAudit.g1.status -eq 'INDETERMINATE') `
        -Reason 'Seedless P9 tok nema očekivani G1 INDETERMINATE signal'
    Assert-LocalE2E `
        -Condition (-not [bool]$generatedAudit.gate_stanje.blocked) `
        -Reason 'Seedless P9 tok pogrešno je blokiran'
    Assert-LocalE2E `
        -Condition ($generatedCodes -contains 'NAP-G1-INDETERMINATE') `
        -Reason 'Seedless P9 audit nema očekivani G1 warning nalaz'
    Assert-LocalE2E `
        -Condition ($generatedCodes -contains 'NAP-YEL-WARNING') `
        -Reason 'Seedless P9 audit nema očekivani žuti signal'
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
    Write-Host 'P9_LOCAL_E2E_INCOMPLETE_STOP=OK'
    Write-Host 'P9_LOCAL_E2E_AUDIT_CONTEXT=ABSENT'
    Write-Host 'P9_LOCAL_E2E_G1=INDETERMINATE'
    Write-Host 'P9_LOCAL_E2E_ONE_COMMAND=OK'
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

    if ($hookChanged) {
        try {
            if ($hookBeforeExit -eq 0) {
                & git config --local core.hooksPath $hookBefore
            }
            else {
                & git config --local --unset core.hooksPath
                if ($LASTEXITCODE -eq 5) {
                    $global:LASTEXITCODE = 0
                }
            }
            if ($LASTEXITCODE -ne 0) {
                throw 'P9_LOCAL_E2E_HOOK_RESTORE_FAILED'
            }
        }
        catch {
            if ([string]::IsNullOrWhiteSpace($failureMessage)) {
                $failureMessage = $_.Exception.Message
            }
            $testSucceeded = $false
        }
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
