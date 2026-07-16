#requires -Version 7.0

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$validatorScript = Join-Path $PSScriptRoot 'validiraj_predmet_prekrsaji_v1.ps1'
$repoGateScript = Join-Path $PSScriptRoot 'provjeri_privatnost_repozitorija_v1.ps1'
. (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')

function Assert-P9Test {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Copy-JsonDocument {
    param([Parameter(Mandatory = $true)] $Document)

    return ($Document | ConvertTo-Json -Depth 100) | ConvertFrom-Json
}

function Invoke-P9ChildScript {
    param(
        [Parameter(Mandatory = $true)][string] $Script,
        [string[]] $Arguments = @()
    )

    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function New-P9ValidOibTestValue {
    $prefix = '0' * 10
    $a = 10
    foreach ($character in $prefix.ToCharArray()) {
        $a = ($a + [int]::Parse([string]$character)) % 10
        if ($a -eq 0) {
            $a = 10
        }
        $a = ($a * 2) % 11
    }

    $control = 11 - $a
    if ($control -eq 10) {
        $control = 0
    }
    return $prefix + [string]$control
}

function New-P9ValidHrIbanTestValue {
    $bban = '0' * 17
    $numeric = $bban + '1727' + '00'
    $remainder = 0
    foreach ($character in $numeric.ToCharArray()) {
        $remainder = (($remainder * 10) + [int]::Parse([string]$character)) % 97
    }

    $checkDigits = (98 - $remainder).ToString('00')
    return 'HR' + $checkDigits + $bban
}

$publicPath = Join-Path $repoRoot (
    'predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\predmet.json'
)
$publicDocument = Get-Content -LiteralPath $publicPath -Raw -Encoding UTF8 |
    ConvertFrom-Json
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ('veritas_p9_test_' + [Guid]::NewGuid().ToString('N'))
$forbiddenIndexPath = (
    'predmeti/sud/prekrsajni/STVARNI_P9_INDEX_TEST/predmet.json'
)
$originalIndexDiff = $null
$indexTestAdded = $false
$testSucceeded = $false
$failureMessage = ''

try {
    $positive = Test-VeritasPredmetDocument `
        -Document $publicDocument `
        -ExpectedMode public `
        -ExpectedSubjectId 'OGLEDNI_PREDMET_0001'
    Assert-P9Test -Condition $positive.Valid -Reason 'Javni sintetički predmet nije validan.'
    Write-Host 'P9_TEST_CASE=public_positive RESULT=OK'

    $badTuple = Copy-JsonDocument $publicDocument
    $badTuple.privatnost.dopusteno_git_pracenje = $false
    $badTupleResult = Test-VeritasPredmetDocument `
        -Document $badTuple `
        -ExpectedMode public `
        -ExpectedSubjectId 'OGLEDNI_PREDMET_0001'
    Assert-P9Test `
        -Condition (
            -not $badTupleResult.Valid -and
            'PUBLIC_PRIVACY_TUPLE_INVALID' -in $badTupleResult.Errors
        ) `
        -Reason 'Nedosljedna javna privatnosna oznaka nije blokirana.'
    Write-Host 'P9_TEST_CASE=public_tuple_blocked RESULT=OK'

    $badPersonalField = Copy-JsonDocument $publicDocument
    $badPersonalField.nositelj.ime_prezime = 'SINTETICKA_NEISPRAVNA_VRIJEDNOST'
    $badPersonalResult = Test-VeritasPredmetDocument `
        -Document $badPersonalField `
        -ExpectedMode public `
        -ExpectedSubjectId 'OGLEDNI_PREDMET_0001'
    Assert-P9Test `
        -Condition (
            -not $badPersonalResult.Valid -and
            'PUBLIC_PERSONAL_FIELD_NOT_NULL' -in $badPersonalResult.Errors
        ) `
        -Reason 'Popunjeno osobno polje javnog predmeta nije blokirano.'
    Write-Host 'P9_TEST_CASE=public_personal_field_blocked RESULT=OK'

    $riskText = @(
        (New-P9ValidOibTestValue),
        (New-P9ValidHrIbanTestValue),
        ('p9.test' + '@' + 'example.invalid'),
        ('+' + '385' + ' 91 000 0000')
    ) -join "`n"
    $riskCodes = @(Get-VeritasHighRiskFindingCodes -Text $riskText)
    foreach ($expectedCode in @(
        'VALID_OIB',
        'VALID_HR_IBAN',
        'EMAIL_ADDRESS',
        'HR_INTERNATIONAL_PHONE'
    )) {
        Assert-P9Test `
            -Condition ($expectedCode -in $riskCodes) `
            -Reason "Visokorizični obrazac nije otkriven: $expectedCode"
    }
    Write-Host 'P9_TEST_CASE=high_risk_patterns_detected RESULT=OK'

    $insideRepoRoot = Test-VeritasLocalDataRoot `
        -LocalDataRoot (Join-Path $repoRoot '.veritas_lokalno') `
        -RepoRoot $repoRoot
    Assert-P9Test `
        -Condition (
            -not $insideRepoRoot.Valid -and
            'LOCAL_ROOT_OVERLAPS_REPOSITORY' -in $insideRepoRoot.Errors
        ) `
        -Reason 'Lokalni korijen unutar repozitorija nije blokiran.'
    Write-Host 'P9_TEST_CASE=local_root_inside_repo_blocked RESULT=OK'

    $localSubjectId = 'STVARNI_P9_TEST'
    $localSubjectRoot = Join-Path $tempRoot (
        "predmeti\sud\prekrsajni\$localSubjectId"
    )
    [void](New-Item -ItemType Directory -Path $localSubjectRoot -Force)
    $localDocument = Copy-JsonDocument $publicDocument
    $localDocument.meta.id_predmeta = $localSubjectId
    $localDocument.meta.vrsta = 'stvarni'
    $localDocument.meta.rezim_podataka = 'lokalni_povjerljivi'
    $localDocument.nositelj.oznaka = 'LOKALNI_NOSITELJ_P9_TEST'
    $localDocument.privatnost.klasifikacija = 'LOKALNO_POVJERLJIVO'
    $localDocument.privatnost.sadrzi_osobne_podatke = $true
    $localDocument.privatnost.dopusteno_git_pracenje = $false
    $localPath = Join-Path $localSubjectRoot 'predmet.json'
    [System.IO.File]::WriteAllText(
        $localPath,
        ($localDocument | ConvertTo-Json -Depth 100),
        [System.Text.UTF8Encoding]::new($false)
    )

    $localValidation = Invoke-P9ChildScript `
        -Script $validatorScript `
        -Arguments @('-PredmetPath', $localPath, '-LocalDataRoot', $tempRoot)
    Assert-P9Test `
        -Condition (
            $localValidation.ExitCode -eq 0 -and
            $localValidation.Text -match 'P9_PREDMET_MODE=local'
        ) `
        -Reason 'Sintetički dokaz lokalnog povjerljivog režima nije prošao.'
    Write-Host 'P9_TEST_CASE=local_mode_outside_repo RESULT=OK'

    Push-Location $repoRoot
    try {
        $trackedProbe = @(& git ls-files --stage -- $forbiddenIndexPath)
        Assert-P9Test `
            -Condition ($trackedProbe.Count -eq 0) `
            -Reason 'Testna zabranjena putanja već postoji u indeksu.'

        $originalIndexDiff = @(& git diff --cached --raw) -join "`n"
        $blobPath = Join-Path $tempRoot 'index_probe.json'
        [System.IO.File]::WriteAllText(
            $blobPath,
            '{}',
            [System.Text.UTF8Encoding]::new($false)
        )
        $blobHash = [string](& git hash-object -w -- $blobPath)
        Assert-P9Test `
            -Condition ($LASTEXITCODE -eq 0 -and $blobHash -match '^[0-9a-f]{40,64}$') `
            -Reason 'Nije moguće pripremiti sintetički indeksni test.'

        & git update-index --add --cacheinfo "100644,$blobHash,$forbiddenIndexPath"
        Assert-P9Test `
            -Condition ($LASTEXITCODE -eq 0) `
            -Reason 'Nije moguće dodati sintetičku zabranjenu putanju u indeks.'
        $indexTestAdded = $true

        $blockedGate = Invoke-P9ChildScript -Script $repoGateScript
        Assert-P9Test `
            -Condition (
                $blockedGate.ExitCode -ne 0 -and
                $blockedGate.Text -match 'FORBIDDEN_TRACKED_PATH'
            ) `
            -Reason 'Git indeks nije blokirao prisilno dodanu zabranjenu putanju.'
        Write-Host 'P9_TEST_CASE=forced_index_path_blocked RESULT=OK'
    }
    finally {
        if ($indexTestAdded) {
            & git update-index --force-remove -- $forbiddenIndexPath
            $indexTestAdded = $false
        }
        Pop-Location
    }

    Push-Location $repoRoot
    try {
        $restoredIndexDiff = @(& git diff --cached --raw) -join "`n"
    }
    finally {
        Pop-Location
    }
    Assert-P9Test `
        -Condition ($restoredIndexDiff -eq $originalIndexDiff) `
        -Reason 'P9 test nije vratio Git indeks u početno stanje.'

    $testSucceeded = $true
}
catch {
    $failureMessage = $_.Exception.Message
}
finally {
    if ($indexTestAdded) {
        Push-Location $repoRoot
        try {
            & git update-index --force-remove -- $forbiddenIndexPath
        }
        finally {
            Pop-Location
        }
    }

    if (
        (Test-Path -LiteralPath $tempRoot) -and
        (Test-VeritasPathInsideRoot -Candidate $tempRoot -Root $tempBase) -and
        [System.IO.Path]::GetFullPath($tempRoot) -ne $tempBase
    ) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if (-not $testSucceeded) {
    Write-Host "ERROR: P9_TEST_FAIL=$failureMessage"
    Write-Host 'P9_PRIVACY_TEST_EXIT=1'
    exit 1
}

Write-Host 'P9_TEST_CLEANUP=OK'
Write-Host 'P9_PRIVACY_TEST_EXIT=0'
exit 0
