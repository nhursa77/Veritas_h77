#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')

$suffix = [Guid]::NewGuid().ToString('N').Substring(0, 8).ToUpperInvariant()
$predmetId = "STVARNI_P9_INIT_$suffix"
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase (
    'veritas_p9_init_' + [Guid]::NewGuid().ToString('N')
)
$subjectRoot = Join-Path $tempRoot (
    "predmeti\sud\prekrsajni\$predmetId"
)
$predmetPath = Join-Path $subjectRoot 'predmet.json'
$unsafeRoot = Join-Path $repoRoot (
    ".veritas_lokalno\p9_init_test_$suffix"
)
$initializer = Join-Path $PSScriptRoot (
    'inicijaliziraj_lokalni_predmet_prekrsaji_v1.ps1'
)

function Assert-P9InitTest {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Invoke-P9Initializer {
    param([Parameter(Mandatory = $true)][string] $Root)

    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $initializer `
            -DataRoot $Root `
            -PredmetId $predmetId 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function Assert-NoLocalPathDisclosure {
    param(
        [Parameter(Mandatory = $true)][string] $Text,
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    foreach ($candidate in @($Root, $Root.Replace('\', '/'))) {
        Assert-P9InitTest `
            -Condition (-not $Text.Contains($candidate)) `
            -Reason $Reason
    }
}

function Remove-P9InitTempRoot {
    if (-not (Test-Path -LiteralPath $tempRoot)) {
        return
    }

    $tempFull = [System.IO.Path]::GetFullPath($tempRoot).TrimEnd('\', '/')
    $baseFull = $tempBase.TrimEnd('\', '/')
    $leaf = Split-Path -Path $tempFull -Leaf
    if (-not (
        Test-VeritasPathInsideRoot -Candidate $tempFull -Root $baseFull
    )) {
        throw 'P9_INIT_TEST_CLEANUP_OUTSIDE_TEMP'
    }
    if ($leaf -notmatch '^veritas_p9_init_[a-f0-9]{32}$') {
        throw 'P9_INIT_TEST_CLEANUP_NAME_INVALID'
    }

    Remove-Item -LiteralPath $tempFull -Recurse -Force
}

$gitBefore = @(git status --porcelain=v1 --untracked-files=all)
$failure = ''
$testSucceeded = $false

try {
    $positive = Invoke-P9Initializer -Root $tempRoot
    Assert-P9InitTest `
        -Condition ($positive.ExitCode -eq 0) `
        -Reason 'P9 initializer nije uspješno otvorio prazni predmet'
    foreach ($marker in @(
            'P9_INIT_RESULT=OK',
            'P9_INIT_STATE=NEPOPUNJEN',
            'P9_INIT_PATHS_REDACTED=True',
            'P9_INIT_HUMAN_REVIEW_REQUIRED=True'
        )) {
        Assert-P9InitTest `
            -Condition $positive.Text.Contains($marker) `
            -Reason "Nedostaje marker inicijalizacije: $marker"
    }
    Assert-NoLocalPathDisclosure `
        -Text $positive.Text `
        -Root $tempRoot `
        -Reason 'Uspješna inicijalizacija otkriva lokalni korijen'

    foreach ($expectedPath in @(
            $predmetPath,
            (Join-Path $subjectRoot 'dokazi'),
            (Join-Path $subjectRoot 'intake'),
            (Join-Path $subjectRoot 'audit'),
            (Join-Path $subjectRoot 'izlazi')
        )) {
        Assert-P9InitTest `
            -Condition (Test-Path -LiteralPath $expectedPath) `
            -Reason 'Inicijalizator nije stvorio očekivani radni kostur'
    }

    $predmet = Get-Content -LiteralPath $predmetPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    Assert-P9InitTest `
        -Condition ([string]$predmet.meta.id_predmeta -eq $predmetId) `
        -Reason 'Inicijalizirani predmet nema očekivani identitet'
    Assert-P9InitTest `
        -Condition ([string]$predmet.meta.status -eq 'nacrt') `
        -Reason 'Inicijalizirani predmet nije označen kao nacrt'
    Assert-P9InitTest `
        -Condition (
            [string]$predmet.privatnost.klasifikacija -eq
            'LOKALNO_POVJERLJIVO'
        ) `
        -Reason 'Inicijalizirani predmet nema lokalnu klasifikaciju'
    Assert-P9InitTest `
        -Condition ([bool]$predmet.privatnost.dopusteno_git_pracenje -eq $false) `
        -Reason 'Inicijalizirani predmet pogrešno dopušta Git praćenje'

    $hashBeforeRepeat = (Get-FileHash -LiteralPath $predmetPath -Algorithm SHA256).Hash
    $repeat = Invoke-P9Initializer -Root $tempRoot
    Assert-P9InitTest `
        -Condition ($repeat.ExitCode -ne 0) `
        -Reason 'Ponovljena inicijalizacija nije blokirana'
    Assert-P9InitTest `
        -Condition $repeat.Text.Contains(
            'P9_INIT_REASON=SUBJECT_ALREADY_EXISTS'
        ) `
        -Reason 'Ponovljena inicijalizacija nema razlog blokade'
    $hashAfterRepeat = (Get-FileHash -LiteralPath $predmetPath -Algorithm SHA256).Hash
    Assert-P9InitTest `
        -Condition ($hashBeforeRepeat -eq $hashAfterRepeat) `
        -Reason 'Ponovljena inicijalizacija promijenila je postojeći predmet'

    $unsafe = Invoke-P9Initializer -Root $unsafeRoot
    Assert-P9InitTest `
        -Condition ($unsafe.ExitCode -ne 0) `
        -Reason 'Korijen unutar repozitorija nije blokiran'
    Assert-P9InitTest `
        -Condition $unsafe.Text.Contains(
            'P9_INIT_REASON=LOKALNI_KORIJEN_ILI_PREDMET_NISU_SIGURNI'
        ) `
        -Reason 'Nesigurni korijen nema očekivani razlog blokade'
    Assert-NoLocalPathDisclosure `
        -Text $unsafe.Text `
        -Root $unsafeRoot `
        -Reason 'Blokada nesigurnog korijena otkriva fizičku putanju'
    Assert-P9InitTest `
        -Condition (-not (Test-Path -LiteralPath $unsafeRoot)) `
        -Reason 'Blokirani nesigurni korijen ipak je stvoren'

    Write-Host 'P9_INIT_TEST_CREATED_OUTSIDE_REPO=OK'
    Write-Host 'P9_INIT_TEST_REPEAT_NO_OVERWRITE=OK'
    Write-Host 'P9_INIT_TEST_UNSAFE_ROOT_BLOCKED=OK'
    Write-Host 'P9_INIT_TEST_PATH_DISCLOSURE=0'
    $testSucceeded = $true
}
catch {
    $failure = $_.Exception.Message
}
finally {
    try {
        Remove-P9InitTempRoot
    }
    catch {
        if ([string]::IsNullOrWhiteSpace($failure)) {
            $failure = $_.Exception.Message
        }
        $testSucceeded = $false
    }
}

$gitAfter = @(git status --porcelain=v1 --untracked-files=all)
$beforeText = ($gitBefore | ForEach-Object { [string]$_ }) -join "`n"
$afterText = ($gitAfter | ForEach-Object { [string]$_ }) -join "`n"
if ($beforeText -ne $afterText) {
    $testSucceeded = $false
    $failure = 'P9_INIT_TEST_GIT_STATE_CHANGED'
}

if (-not $testSucceeded) {
    Write-Host "ERROR: P9_INIT_TEST_FAIL=$failure"
    Write-Host 'P9_INIT_TEST_EXIT=1'
    exit 1
}

Write-Host 'P9_INIT_TEST_CLEANUP=OK'
Write-Host 'P9_INIT_TEST_GIT_STATE=UNCHANGED'
Write-Host 'P9_INIT_TEST_RESULT=OK'
Write-Host 'P9_INIT_TEST_EXIT=0'
exit 0
