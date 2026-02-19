param(
    [Parameter(Mandatory = $false)]
    [switch] $SkipPrekrsajniPreflight
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$preflightScript = Join-Path $PSScriptRoot "acceptance_preflight.ps1"
$paketScript = Join-Path $PSScriptRoot "acceptance_paket.ps1"
$paketPath = "paketi\PAKET_PREKRSAJNI_V1.json"

function Invoke-SmokeStep {
    param(
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][scriptblock] $Action
    )

    Write-Host "CI_SMOKE_STEP=$Name"
    & $Action
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Write-Host "CI_SMOKE_EXIT=$exitCode"
        exit $exitCode
    }
}

Push-Location $root
$finalExitCode = 0
try {
    $hasGit = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    $gitAvailableText = if ($hasGit) { "True" } else { "False" }
    $timestampIso = (Get-Date).ToString("o")
    $psVersion = $PSVersionTable.PSVersion
    $patchValue = 0
    if ($null -ne $psVersion.Patch -and [string]$psVersion.Patch -ne "") {
        $patchValue = [int]$psVersion.Patch
    }
    elseif ($null -ne $psVersion.Build -and [int]$psVersion.Build -ge 0) {
        $patchValue = [int]$psVersion.Build
    }
    $psVersionText = "{0}.{1}.{2}" -f $psVersion.Major, $psVersion.Minor, $patchValue

    Write-Host "CI_SMOKE_BEGIN=True"
    Write-Host "CI_SMOKE_TIMESTAMP=$timestampIso"
    Write-Host "CI_SMOKE_PWSH_VERSION=$psVersionText"
    Write-Host "CI_SMOKE_GIT_AVAILABLE=$gitAvailableText"

    $beforeStatus = @()
    if ($hasGit) {
        Write-Host "CI_SMOKE_HYGIENE=ENFORCED"
        $beforeStatus = @(git status --short)
    }
    else {
        Write-Host "CI_SMOKE_HYGIENE=SKIP_NO_GIT"
    }

    $steps = @(
        [pscustomobject]@{
            Name = "preflight_ustav_rh"
            Action = { & $preflightScript -AktSlug "ustav_rh" }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "paket_prekrsajni_v1"
            Action = { & $paketScript -PaketPath $paketPath }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "preflight_prekrsajni_zakon"
            Action = { & $preflightScript -AktSlug "prekrsajni_zakon" }
            Enabled = (-not $SkipPrekrsajniPreflight)
        }
    )

    foreach ($step in $steps) {
        if (-not $step.Enabled) {
            continue
        }

        Write-Host "CI_SMOKE_STEP_BEGIN=$($step.Name)"
        & $step.Action
        $stepExit = $LASTEXITCODE
        Write-Host "CI_SMOKE_STEP_END=$($step.Name) EXIT=$stepExit"

        if ($stepExit -ne 0 -and $finalExitCode -eq 0) {
            $finalExitCode = $stepExit
            break
        }
    }

    if ($hasGit -and $finalExitCode -eq 0) {
        $afterStatus = @(git status --short)
        $beforeText = ($beforeStatus | ForEach-Object { [string]$_ }) -join "`n"
        $afterText = ($afterStatus | ForEach-Object { [string]$_ }) -join "`n"

        if ($beforeText -ne $afterText) {
            Write-Host "CI_SMOKE_STEP=repo_hygiene_check"
            Write-Host "ERROR: git status changed during CI smoke run."
            Write-Host "--- BEFORE ---"
            Write-Host $beforeText
            Write-Host "--- AFTER ---"
            Write-Host $afterText
            $finalExitCode = 90
        }
    }
}
finally {
    Pop-Location
}

Write-Host "CI_SMOKE_END=True"
Write-Host "CI_SMOKE_EXIT=$finalExitCode"
exit $finalExitCode
