#requires -Version 7.0

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'putanje_predmeta_core.ps1')

function Assert-PathTest {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Assert-PathTestThrows {
    param(
        [Parameter(Mandatory = $true)][scriptblock] $Action,
        [Parameter(Mandatory = $true)][string] $ExpectedCode
    )

    $thrown = ''
    try {
        & $Action
    }
    catch {
        $thrown = $_.Exception.Message
    }

    Assert-PathTest `
        -Condition ($thrown -like "*$ExpectedCode*") `
        -Reason "Očekivana blokada nije dobivena: $ExpectedCode"
}

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase (
    'veritas_path_test_' + [Guid]::NewGuid().ToString('N')
)
$testSucceeded = $false
$failureMessage = ''

try {
    [void](New-Item -ItemType Directory -Path $tempRoot -Force)

    $publicContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId 'OGLEDNI_PREDMET_0001'
    $publicSubject = Resolve-VeritasReference `
        -PathRef 'predmeti/sud/prekrsajni/{PREDMET_ID}/predmet.json' `
        -Context $publicContext `
        -ExpectedScope Subject
    Assert-PathTest `
        -Condition (
            $publicContext.Mode -eq 'public' -and
            $publicSubject.Scope -eq 'Subject' -and
            (Test-VeritasPathInsideRoot `
                -Candidate $publicSubject.Path `
                -Root $repoRoot)
        ) `
        -Reason 'Javna predmetna referenca nije razriješena u repo.'
    Write-Host 'PATH_TEST_CASE=public_subject RESULT=OK'

    $localContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId 'STVARNI_P9_E2E_TEST' `
        -DataRoot $tempRoot
    $localSubject = Resolve-VeritasReference `
        -PathRef 'predmeti/sud/prekrsajni/{PREDMET_ID}/predmet.json' `
        -Context $localContext `
        -ExpectedScope Subject
    $repositoryNorm = Resolve-VeritasReference `
        -PathRef (
            'baza_zakona/norme/prekrsajni_zakon_procisceni/' +
            'clanak_0235.json'
        ) `
        -Context $localContext `
        -ExpectedScope Repository
    Assert-PathTest `
        -Condition (
            $localContext.Mode -eq 'local' -and
            (Test-VeritasPathInsideRoot `
                -Candidate $localSubject.Path `
                -Root $tempRoot) -and
            -not (Test-VeritasPathInsideRoot `
                -Candidate $localSubject.Path `
                -Root $repoRoot) -and
            (Test-VeritasPathInsideRoot `
                -Candidate $repositoryNorm.Path `
                -Root $repoRoot)
        ) `
        -Reason 'Lokalni predmet i repo norma nisu strogo razdvojeni.'
    Write-Host 'PATH_TEST_CASE=local_subject_repo_norm RESULT=OK'

    Assert-PathTestThrows `
        -ExpectedCode 'LOCAL_ROOT_OVERLAPS_REPOSITORY' `
        -Action {
            New-VeritasPathContext `
                -RepoRoot $repoRoot `
                -PredmetId 'STVARNI_P9_E2E_TEST' `
                -DataRoot (Join-Path $repoRoot '.veritas_lokalno')
        }
    Assert-PathTestThrows `
        -ExpectedCode 'CROSS_SUBJECT_REFERENCE_FORBIDDEN' `
        -Action {
            Resolve-VeritasReference `
                -PathRef (
                    'predmeti/sud/prekrsajni/STVARNI_DRUGI/predmet.json'
                ) `
                -Context $localContext
        }
    Assert-PathTestThrows `
        -ExpectedCode 'REFERENCE_TRAVERSAL_FORBIDDEN' `
        -Action {
            Resolve-VeritasReference `
                -PathRef (
                    'predmeti/sud/prekrsajni/{PREDMET_ID}/../drugi.json'
                ) `
                -Context $localContext
        }
    Assert-PathTestThrows `
        -ExpectedCode 'ABSOLUTE_REFERENCE_FORBIDDEN' `
        -Action {
            Resolve-VeritasReference `
                -PathRef (Join-Path $tempRoot 'predmet.json') `
                -Context $localContext
        }
    Write-Host 'PATH_TEST_CASE=unsafe_references_blocked RESULT=OK'

    $testSucceeded = $true
}
catch {
    $failureMessage = $_.Exception.Message
}
finally {
    if (
        (Test-Path -LiteralPath $tempRoot) -and
        (Test-VeritasPathInsideRoot -Candidate $tempRoot -Root $tempBase) -and
        [System.IO.Path]::GetFullPath($tempRoot) -ne $tempBase
    ) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if (-not $testSucceeded) {
    Write-Host "ERROR: PATH_TEST_FAIL=$failureMessage"
    Write-Host 'PATH_TEST_EXIT=1'
    exit 1
}

Write-Host 'PATH_TEST_CLEANUP=OK'
Write-Host 'PATH_TEST_EXIT=0'
exit 0
