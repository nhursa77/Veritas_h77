#requires -Version 7.0

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$validator = Join-Path $PSScriptRoot 'validiraj_registar_ai_normi_v1.ps1'
$registryPath = Join-Path $repoRoot (
    'dokumentacija\REGISTAR_AI_NORMI_V1.json'
)
$schemaPath = Join-Path $repoRoot (
    'dokumentacija\sheme\SCHEMA_REGISTAR_AI_NORMI_V1.json'
)
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase (
    'veritas_ai_norme_' + [Guid]::NewGuid().ToString('N')
)

function Assert-AiNormTest {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )
    if (-not $Condition) {
        throw $Reason
    }
}

function Copy-AiNormRegistry {
    return Get-Content -LiteralPath $registryPath -Raw -Encoding UTF8 |
        ConvertFrom-Json | ConvertTo-Json -Depth 100 | ConvertFrom-Json
}

function Write-AiNormFixture {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][string] $Name
    )
    $path = Join-Path $tempRoot $Name
    [System.IO.File]::WriteAllText(
        $path,
        ($Document | ConvertTo-Json -Depth 100),
        [System.Text.UTF8Encoding]::new($false)
    )
    return $path
}

function Invoke-AiNormValidator {
    param([Parameter(Mandatory = $true)][string] $Path)
    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $validator `
            -RegistarPutanja $Path `
            -ShemaPutanja $schemaPath 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

$testSucceeded = $false
$failureMessage = ''

try {
    [void](New-Item -ItemType Directory -Path $tempRoot)

    $positive = Invoke-AiNormValidator -Path $registryPath
    Assert-AiNormTest `
        -Condition (
            $positive.ExitCode -eq 0 -and
            $positive.Text -match 'AI_NORME_VALIDATOR_STATUS=VALIDNO'
        ) `
        -Reason 'Kanonski radni registar nije prošao validator.'
    Write-Host 'AI_NORM_TEST_CASE=positive RESULT=OK'

    $extraRoot = Copy-AiNormRegistry
    $extraRoot | Add-Member -NotePropertyName 'nedeklarirano' -NotePropertyValue 1
    $extraRootPath = Write-AiNormFixture `
        -Document $extraRoot `
        -Name 'extra_root.json'
    $extraRootResult = Invoke-AiNormValidator -Path $extraRootPath
    Assert-AiNormTest `
        -Condition (
            $extraRootResult.ExitCode -ne 0 -and
            $extraRootResult.Text -match 'SCHEMA_FAIL'
        ) `
        -Reason 'Dodatno korijensko polje nije blokirano.'
    Write-Host 'AI_NORM_TEST_CASE=extra_root_blocked RESULT=OK'

    $extraNorm = Copy-AiNormRegistry
    $extraNorm.norme[0] | Add-Member `
        -NotePropertyName 'nedeklarirano' `
        -NotePropertyValue 1
    $extraNormPath = Write-AiNormFixture `
        -Document $extraNorm `
        -Name 'extra_norm.json'
    $extraNormResult = Invoke-AiNormValidator -Path $extraNormPath
    Assert-AiNormTest `
        -Condition (
            $extraNormResult.ExitCode -ne 0 -and
            $extraNormResult.Text -match 'SCHEMA_FAIL'
        ) `
        -Reason 'Dodatno polje norme nije blokirano.'
    Write-Host 'AI_NORM_TEST_CASE=extra_norm_blocked RESULT=OK'

    $duplicate = Copy-AiNormRegistry
    $duplicate.norme[1].id = $duplicate.norme[0].id
    $duplicatePath = Write-AiNormFixture `
        -Document $duplicate `
        -Name 'duplicate.json'
    $duplicateResult = Invoke-AiNormValidator -Path $duplicatePath
    Assert-AiNormTest `
        -Condition (
            $duplicateResult.ExitCode -ne 0 -and
            $duplicateResult.Text -match 'DUPLIKAT_ID'
        ) `
        -Reason 'Duplicirani identifikator norme nije blokiran.'
    Write-Host 'AI_NORM_TEST_CASE=duplicate_id_blocked RESULT=OK'

    $falseD4 = Copy-AiNormRegistry
    $falseD4.norme[0].razina_dokaza = 'D4'
    $falseD4.norme[0].testovi = @()
    $falseD4.norme[0].ci_koraci = @()
    $falseD4Path = Write-AiNormFixture `
        -Document $falseD4 `
        -Name 'false_d4.json'
    $falseD4Result = Invoke-AiNormValidator -Path $falseD4Path
    Assert-AiNormTest `
        -Condition (
            $falseD4Result.ExitCode -ne 0 -and
            $falseD4Result.Text -match 'D4_BEZ_CI'
        ) `
        -Reason 'Neutemeljena razina D4 nije blokirana.'
    Write-Host 'AI_NORM_TEST_CASE=false_d4_blocked RESULT=OK'

    $testSucceeded = $true
}
catch {
    $failureMessage = $_.Exception.Message
}
finally {
    if (
        (Test-Path -LiteralPath $tempRoot) -and
        [System.IO.Path]::GetFullPath($tempRoot).StartsWith($tempBase) -and
        [System.IO.Path]::GetFullPath($tempRoot) -ne $tempBase
    ) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if (-not $testSucceeded) {
    Write-Host "ERROR: AI_NORM_TEST_FAIL=$failureMessage"
    Write-Host 'AI_NORME_TEST_EXIT=1'
    exit 1
}

Write-Host 'AI_NORM_TEST_CLEANUP=OK'
Write-Host 'AI_NORME_TEST_EXIT=0'
exit 0
