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
$deltaOpsValidatorScript = Join-Path $PSScriptRoot "validiraj_delta_ops.ps1"
$markdownLintScript = Join-Path $PSScriptRoot "lint_markdown.ps1"
$auditValidatorScript = Join-Path $PSScriptRoot "validiraj_audit_v1.ps1"
$intakeValidatorScript = Join-Path $PSScriptRoot "validiraj_intake_prekrsaji_v1.ps1"
$subsumcijaValidatorScript = Join-Path $PSScriptRoot "validiraj_subsumciju_v1.ps1"
$predlozakValidatorScript = Join-Path $PSScriptRoot "validiraj_predlozak_v1.ps1"
$postupakValidatorScript = Join-Path $PSScriptRoot "validiraj_postupak_v1.ps1"
$tokRunnerScript = Join-Path $PSScriptRoot "run_tok_v1.ps1"
$tokOutputValidatorScript = Join-Path $PSScriptRoot "validiraj_izlaz_tok_pn_prigovor_v1.ps1"
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
            Name = "lint_markdown"
            Action = { & $markdownLintScript }
            Enabled = $true
        },
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
            Name = "validate_delta_ops_schema"
            Action = { & $deltaOpsValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_audit_v1"
            Action = { & $auditValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_intake_prekrsaji_v1"
            Action = { & $intakeValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_subsumcija_v1"
            Action = { & $subsumcijaValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_predlozak_v1"
            Action = { & $predlozakValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_postupak_v1"
            Action = { & $postupakValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "preflight_prekrsajni_zakon"
            Action = { & $preflightScript -AktSlug "prekrsajni_zakon" }
            Enabled = (-not $SkipPrekrsajniPreflight)
        },
        [pscustomobject]@{
            Name = "run_tokovi_v1"
            Action = {
                $tokovi = @(
                    "TOK_PN_PRIGOVOR",
                    "TOK_PRESUDA_ZALBA",
                    "TOK_RJESENJE_ZALBA",
                    "TOK_OBUSTAVA"
                )

                foreach ($tok in $tokovi) {
                    Write-Host "TOK_RUN_BEGIN=$tok"

                    $postupakPath = Join-Path $root ("postupci\sud\prekrsajni\{0}\v1\postupak.json" -f $tok)
                    $postupakDoc = Get-Content -LiteralPath $postupakPath -Raw | ConvertFrom-Json
                    $outputRef = [string]$postupakDoc.izlazi.nacrt_ref
                    $outputPath = Join-Path $root ($outputRef -replace "/", "\")
                    $outputExistedBefore = Test-Path -LiteralPath $outputPath

                    $runnerOutput = @(
                        powershell -NoProfile -ExecutionPolicy Bypass -File $tokRunnerScript -Tok $tok -PredmetId "OGLEDNI_PREDMET_0001" -Verzija "v1" 2>&1
                    )
                    $runnerExit = $LASTEXITCODE

                    foreach ($line in $runnerOutput) {
                        Write-Host ([string]$line)
                    }

                    if ($runnerExit -ne 0) {
                        $global:LASTEXITCODE = $runnerExit
                        return
                    }

                    $runnerText = ($runnerOutput | ForEach-Object { [string]$_ }) -join "`n"

                    if ($runnerText -match "RUNNER_RESULT=OK") {
                        $pathMatch = [regex]::Match($runnerText, "(?m)^OUTPUT_PATH=(.+)$")
                        if (-not $pathMatch.Success) {
                            Write-Host "ERROR: OUTPUT_PATH marker missing"
                            $global:LASTEXITCODE = 1
                            return
                        }

                        $resolvedOutputPath = $pathMatch.Groups[1].Value.Trim()
                        & $tokOutputValidatorScript -OutputPath $resolvedOutputPath
                        $validatorExit = $LASTEXITCODE

                        if (-not $outputExistedBefore -and (Test-Path -LiteralPath $resolvedOutputPath)) {
                            Remove-Item -LiteralPath $resolvedOutputPath -Force
                        }

                        if ($validatorExit -ne 0) {
                            $global:LASTEXITCODE = $validatorExit
                            return
                        }

                        Write-Host "TOK_RUN_END=$tok RESULT=OK"
                        continue
                    }

                    if ($runnerText -match "RUNNER_RESULT=STOP") {
                        Write-Host "RUNNER_OUTPUT_VALIDATION=SKIPPED_STOP"

                        if (-not $outputExistedBefore -and (Test-Path -LiteralPath $outputPath)) {
                            Remove-Item -LiteralPath $outputPath -Force
                        }

                        Write-Host "TOK_RUN_END=$tok RESULT=STOP"
                        continue
                    }

                    Write-Host "ERROR: RUNNER_RESULT marker missing"
                    $global:LASTEXITCODE = 1
                    return
                }

                $global:LASTEXITCODE = 0
            }
            Enabled = $true
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
