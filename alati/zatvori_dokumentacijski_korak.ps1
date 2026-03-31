param(
    [Parameter(Mandatory = $true)]
    [int]$BrojZadatka,

    [Parameter(Mandatory = $true)]
    [string]$Naslov,

    [Parameter(Mandatory = $true)]
    [string[]]$Sazetak,

    [Parameter(Mandatory = $true)]
    [string[]]$AzuriraneDatoteke,

    [Parameter(Mandatory = $true)]
    [string[]]$DokazneNaredbe,

    [Parameter(Mandatory = $true)]
    [string[]]$MarkdownDatoteke,

    [string]$StatusPath = '.\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md',
    [string]$DiaryPath = '.\dokumentacija\DNEVNIK_RADA.md',
    [string]$ZadnjiZadatak,
    [string]$PolazniHead,
    [string]$PolazniSubject,
    [string]$RepoCistPriPrecheck,
    [string]$PoravnanjeGranePriPrecheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$generatorPath = Join-Path $PSScriptRoot 'generiraj_dnevnicki_unos.ps1'
$appendPath = Join-Path $PSScriptRoot 'dodaj_dnevnicki_unos_na_kraj.ps1'
$statusSyncPath = Join-Path $PSScriptRoot 'uskladi_status_projekta.ps1'
$scopePath = Join-Path $PSScriptRoot 'provjeri_markdown_scope.ps1'
$lintPath = Join-Path $PSScriptRoot 'lint_markdown.ps1'
$smokePath = Join-Path $PSScriptRoot 'ci_smoke.ps1'

function Get-BranchAlignment {
    param([Parameter(Mandatory = $true)][string]$BranchLine)

    if ($BranchLine -match '\[(?<tracking>[^\]]+)\]') {
        $tracking = $Matches['tracking']
        if ($tracking -match ':') {
            return ($tracking.Split(':', 2)[1]).Trim()
        }
        return 'poravnat'
    }

    return 'bez upstreama'
}

function Invoke-PwshStep {
    param(
        [Parameter(Mandatory = $true)][string]$StepName,
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [AllowEmptyCollection()][string[]]$Arguments = @()
    )

    Write-Host "DOC_CLOSE_STEP_BEGIN=$StepName"
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments
    $stepExit = $LASTEXITCODE
    Write-Host "DOC_CLOSE_STEP_END=$StepName EXIT=$stepExit"
    if ($stepExit -ne 0) {
        throw "Korak $StepName nije uspio (exit=$stepExit)."
    }
}

function Invoke-LocalStep {
    param(
        [Parameter(Mandatory = $true)][string]$StepName,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    Write-Host "DOC_CLOSE_STEP_BEGIN=$StepName"
    & $Action
    Write-Host "DOC_CLOSE_STEP_END=$StepName EXIT=0"
}

Write-Host 'DOC_CLOSE_BEGIN=True'

Push-Location $root
$tempEntryPath = $null
try {
    foreach ($requiredPath in @($generatorPath, $appendPath, $statusSyncPath, $scopePath, $lintPath, $smokePath)) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Nedostaje servisna skripta: $requiredPath"
        }
    }

    $currentStatus = @(git status --short)
    $currentHead = (git --no-pager log -1 --pretty=format:%h).Trim()
    $currentSubject = (git --no-pager log -1 --pretty=format:%s).Trim()
    $branchLine = (git branch -vv | Where-Object { $_.StartsWith('*') } | Select-Object -First 1)
    $currentAlignment = Get-BranchAlignment -BranchLine $branchLine
    $resolvedHead = if ([string]::IsNullOrWhiteSpace($PolazniHead)) { $currentHead } else { $PolazniHead.Trim() }
    $resolvedSubject = if ([string]::IsNullOrWhiteSpace($PolazniSubject)) { $currentSubject } else { $PolazniSubject.Trim() }
    $resolvedClean = if ([string]::IsNullOrWhiteSpace($RepoCistPriPrecheck)) {
        if ($currentStatus.Count -eq 0) { 'DA' } else { 'NE' }
    }
    else {
        $RepoCistPriPrecheck.Trim()
    }
    $resolvedAlignment = if ([string]::IsNullOrWhiteSpace($PoravnanjeGranePriPrecheck)) {
        $currentAlignment
    }
    else {
        $PoravnanjeGranePriPrecheck.Trim()
    }

    Write-Host "DOC_CLOSE_PRECHECK_HEAD=$resolvedHead"
    Write-Host "DOC_CLOSE_PRECHECK_SUBJECT=$resolvedSubject"
    Write-Host "DOC_CLOSE_PRECHECK_CLEAN=$resolvedClean"
    Write-Host "DOC_CLOSE_PRECHECK_ALIGNMENT=$resolvedAlignment"

    $tempEntryPath = Join-Path $env:TEMP "veritas_z$BrojZadatka`_generated_entry.md"

    $statusArgs = @('-StatusPath', $StatusPath, '-PolazniHead', $resolvedHead, '-PolazniSubject', $resolvedSubject, '-RepoCistPriPrecheck', $resolvedClean, '-PoravnanjeGranePriPrecheck', $resolvedAlignment)
    if (-not [string]::IsNullOrWhiteSpace($ZadnjiZadatak)) {
        $statusArgs += @('-ZadnjiZadatak', $ZadnjiZadatak)
    }
    Invoke-PwshStep -StepName 'status_sync' -ScriptPath $statusSyncPath -Arguments $statusArgs

    $generatorArgs = @(
        '-BrojZadatka',
        [string]$BrojZadatka,
        '-Naslov',
        $Naslov,
        '-Datum',
        (Get-Date).ToString('dd.MM.yyyy.'),
        '-OutputPath',
        $tempEntryPath,
        '-Sazetak'
    ) + $Sazetak + @(
        '-AzuriraneDatoteke'
    ) + $AzuriraneDatoteke + @(
        '-DokazneNaredbe'
    ) + $DokazneNaredbe
    Invoke-LocalStep -StepName 'generate_diary_entry' -Action {
        & $generatorPath -BrojZadatka $BrojZadatka -Naslov $Naslov -Datum (Get-Date).ToString('dd.MM.yyyy.') -OutputPath $tempEntryPath -Sazetak $Sazetak -AzuriraneDatoteke $AzuriraneDatoteke -DokazneNaredbe $DokazneNaredbe
    }

    Invoke-LocalStep -StepName 'append_diary_entry' -Action {
        & $appendPath -DiaryPath $DiaryPath -EntryPath $tempEntryPath
    }

    $scopeArgs = @()
    foreach ($filePath in $MarkdownDatoteke) {
        $scopeArgs += $filePath
    }
    Invoke-PwshStep -StepName 'markdown_scope' -ScriptPath $scopePath -Arguments $scopeArgs
    Invoke-PwshStep -StepName 'lint_markdown' -ScriptPath $lintPath -Arguments @()
    Invoke-PwshStep -StepName 'ci_smoke' -ScriptPath $smokePath -Arguments @()

    Write-Host 'DOC_CLOSE_END=True'
    Write-Host 'DOC_CLOSE_EXIT=0'
}
catch {
    Write-Host "DOC_CLOSE_ERROR=$($_.Exception.Message)"
    Write-Host 'DOC_CLOSE_END=True'
    Write-Host 'DOC_CLOSE_EXIT=1'
    throw
}
finally {
    if ($null -ne $tempEntryPath -and (Test-Path -LiteralPath $tempEntryPath)) {
        Remove-Item -LiteralPath $tempEntryPath -Force
    }
    Pop-Location
}