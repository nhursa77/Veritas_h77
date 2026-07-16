#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string] $PredmetPath,
    [string] $LocalDataRoot = $env:VERITAS_LOCAL_DATA_ROOT
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')

function Stop-Validation {
    param(
        [Parameter(Mandatory = $true)][string] $Code,
        [int] $ExitCode = 1
    )

    Write-Host "ERROR: $Code"
    Write-Host 'P9_PREDMET_VALIDATOR_STATUS=NEVALIDNO'
    Write-Host "P9_PREDMET_VALIDATOR_EXIT=$ExitCode"
    exit $ExitCode
}

Write-Host 'P9_PREDMET_VALIDATOR_BEGIN=True'

try {
    $resolvedPath = [System.IO.Path]::GetFullPath($PredmetPath)
}
catch {
    Stop-Validation -Code 'PREDMET_PATH_INVALID' -ExitCode 2
}

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
    Stop-Validation -Code 'PREDMET_FILE_MISSING' -ExitCode 2
}

try {
    $raw = Get-Content -LiteralPath $resolvedPath -Raw -Encoding UTF8
    $document = $raw | ConvertFrom-Json
}
catch {
    Stop-Validation -Code 'PREDMET_JSON_PARSE_FAIL' -ExitCode 3
}

$mode = [string](Get-VeritasNestedValue $document @('meta', 'rezim_podataka'))
$subjectRoot = Split-Path -Path $resolvedPath -Parent
$subjectId = Split-Path -Path $subjectRoot -Leaf

if ($mode -eq 'javni_sinteticki') {
    $expectedRoot = Join-Path $repoRoot 'predmeti\sud\prekrsajni'
    if (-not (Test-VeritasPathInsideRoot -Candidate $resolvedPath -Root $expectedRoot)) {
        Stop-Validation -Code 'PUBLIC_SUBJECT_OUTSIDE_REPOSITORY_LAYOUT'
    }

    $relativePath = [System.IO.Path]::GetRelativePath(
        $expectedRoot,
        $resolvedPath
    ).Replace('\', '/')
    if ($relativePath -ne "$subjectId/predmet.json") {
        Stop-Validation -Code 'PUBLIC_SUBJECT_LAYOUT_INVALID'
    }

    $expectedMode = 'public'
}
elseif ($mode -eq 'lokalni_povjerljivi') {
    $rootResult = Test-VeritasLocalDataRoot `
        -LocalDataRoot $LocalDataRoot `
        -RepoRoot $repoRoot
    if (-not $rootResult.Valid) {
        foreach ($errorCode in $rootResult.Errors) {
            Write-Host "ERROR: $errorCode"
        }
        Write-Host 'P9_PREDMET_VALIDATOR_STATUS=NEVALIDNO'
        Write-Host 'P9_PREDMET_VALIDATOR_EXIT=1'
        exit 1
    }

    if (-not (
        Test-VeritasPathInsideRoot -Candidate $resolvedPath -Root $rootResult.FullPath
    )) {
        Stop-Validation -Code 'LOCAL_SUBJECT_OUTSIDE_LOCAL_ROOT'
    }

    $relativePath = [System.IO.Path]::GetRelativePath(
        $rootResult.FullPath,
        $resolvedPath
    ).Replace('\', '/')
    $expectedRelative = "predmeti/sud/prekrsajni/$subjectId/predmet.json"
    if ($relativePath -ne $expectedRelative) {
        Stop-Validation -Code 'LOCAL_SUBJECT_LAYOUT_INVALID'
    }

    $expectedMode = 'local'
}
else {
    Stop-Validation -Code 'DATA_MODE_INVALID'
}

$semanticResult = Test-VeritasPredmetDocument `
    -Document $document `
    -ExpectedMode $expectedMode `
    -ExpectedSubjectId $subjectId

if (-not $semanticResult.Valid) {
    foreach ($errorCode in $semanticResult.Errors) {
        Write-Host "ERROR: $errorCode"
    }
    Write-Host 'P9_PREDMET_VALIDATOR_STATUS=NEVALIDNO'
    Write-Host 'P9_PREDMET_VALIDATOR_EXIT=1'
    exit 1
}

if ($expectedMode -eq 'public') {
    $riskCodes = @(Get-VeritasHighRiskFindingCodes -Text $raw)
    if ($riskCodes.Count -gt 0) {
        foreach ($riskCode in $riskCodes) {
            Write-Host "ERROR: HIGH_RISK_IDENTIFIER_$riskCode"
        }
        Write-Host 'P9_PREDMET_VALIDATOR_STATUS=NEVALIDNO'
        Write-Host 'P9_PREDMET_VALIDATOR_EXIT=1'
        exit 1
    }
}

Write-Host "P9_PREDMET_MODE=$expectedMode"
Write-Host 'P9_PREDMET_VALIDATOR_STATUS=VALIDNO'
Write-Host 'P9_PREDMET_VALIDATOR_EXIT=0'
exit 0
