param(
    [Parameter(Mandatory = $false)]
    [switch] $SkipPrekrsajniPreflight
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
try {
    $hasGit = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    Write-Host "CI_SMOKE_GIT_AVAILABLE=$hasGit"

    $beforeStatus = @()
    if ($hasGit) {
        Write-Host "CI_SMOKE_HYGIENE=ENFORCED"
        $beforeStatus = @(git status --short)
    }
    else {
        Write-Host "CI_SMOKE_HYGIENE=SKIP_NO_GIT"
    }

    Invoke-SmokeStep -Name "preflight_ustav_rh" -Action {
        & $preflightScript -AktSlug "ustav_rh"
    }

    Invoke-SmokeStep -Name "acceptance_paket_prekrsajni_v1" -Action {
        & $paketScript -PaketPath $paketPath
    }

    if (-not $SkipPrekrsajniPreflight) {
        Invoke-SmokeStep -Name "preflight_prekrsajni_zakon" -Action {
            & $preflightScript -AktSlug "prekrsajni_zakon"
        }
    }

    if ($hasGit) {
        $afterStatus = @(git status --short)
        $beforeText = ($beforeStatus | ForEach-Object { [string]$_ }) -join "`n"
        $afterText = ($afterStatus | ForEach-Object { [string]$_ }) -join "`n"

        if ($beforeText -ne $afterText) {
            Write-Host "CI_SMOKE_STEP=repo_hygiene_check"
            Write-Host "CI_SMOKE_EXIT=90"
            Write-Host "ERROR: git status changed during CI smoke run."
            Write-Host "--- BEFORE ---"
            Write-Host $beforeText
            Write-Host "--- AFTER ---"
            Write-Host $afterText
            exit 90
        }
    }

    Write-Host "CI_SMOKE_EXIT=0"
    exit 0
}
finally {
    Pop-Location
}
