param(
    [Parameter(Mandatory = $false)]
    [switch] $SkipPrekrsajniPreflight
)

#requires -Version 7.0

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$preflightScript = Join-Path $PSScriptRoot "acceptance_preflight.ps1"
$paketScript = Join-Path $PSScriptRoot "acceptance_paket.ps1"
$deltaOpsValidatorScript = Join-Path $PSScriptRoot "validiraj_delta_ops.ps1"
$markdownLintScript = Join-Path $PSScriptRoot "lint_markdown.ps1"
$genericSchemaValidatorScript = Join-Path $PSScriptRoot "validiraj_json_po_shemi_v1.ps1"
$auditGeneratorScript = Join-Path $PSScriptRoot "generiraj_audit_prekrsaji_v1.ps1"
$auditGeneratedValidatorScript = Join-Path $PSScriptRoot "validiraj_audit_generated_v1.ps1"
$auditFixturesTestScript = Join-Path $PSScriptRoot "test_fixtures_audit_prekrsaji_v1.ps1"
$p7RunnerTestScript = Join-Path $PSScriptRoot "test_run_tok_p7_v1.ps1"
$tokRunnerScript = Join-Path $PSScriptRoot "run_tok_v1.ps1"
$tokOutputValidatorScript = Join-Path $PSScriptRoot "validiraj_izlaz_tok_pn_prigovor_v1.ps1"
$p8TestScript = Join-Path $PSScriptRoot "test_p8_manifest_lanac_v1.ps1"
$privacyRepoGateScript = Join-Path $PSScriptRoot "provjeri_privatnost_repozitorija_v1.ps1"
$predmetValidatorScript = Join-Path $PSScriptRoot "validiraj_predmet_prekrsaji_v1.ps1"
$p9PrivacyTestScript = Join-Path $PSScriptRoot "test_p9_privatnost_v1.ps1"
$p9InitTestScript = Join-Path $PSScriptRoot "test_p9_inicijalizacija_v1.ps1"
$p9LocalE2ETestScript = Join-Path $PSScriptRoot "test_p9_lokalni_e2e_v1.ps1"
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

function Invoke-GenericSchemaValidationSet {
    param(
        [Parameter(Mandatory = $true)][string] $TargetRoot,
        [Parameter(Mandatory = $true)][string] $Filter,
        [Parameter(Mandatory = $true)][string] $SchemaRelativePath,
        [Parameter(Mandatory = $true)][string] $Marker,
        [Parameter(Mandatory = $true)][string] $Description,
        [string] $PathRegex,
        [switch] $NormalizeAuditModuleIo
    )

    if (-not (Test-Path -LiteralPath $genericSchemaValidatorScript)) {
        Write-Host "ERROR: NEDOSTAJE_VALIDATOR=$genericSchemaValidatorScript"
        Write-Host "$Marker`_EXIT=4"
        $global:LASTEXITCODE = 4
        return
    }

    $schemaPath = Join-Path $root $SchemaRelativePath
    if (-not (Test-Path -LiteralPath $schemaPath)) {
        Write-Host "ERROR: NEDOSTAJE_SHEMA=$schemaPath"
        Write-Host "$Marker`_EXIT=3"
        $global:LASTEXITCODE = 3
        return
    }

    if (-not (Test-Path -LiteralPath $TargetRoot)) {
        Write-Host "NEMA_DATOTEKA=1"
        Write-Host "$Marker`_EXIT=0"
        $global:LASTEXITCODE = 0
        return
    }

    $files = @(Get-ChildItem -Path $TargetRoot -Recurse -File -Filter $Filter)
    if (-not [string]::IsNullOrWhiteSpace($PathRegex)) {
        $files = @($files | Where-Object { $_.FullName -match $PathRegex })
    }

    if ($files.Count -eq 0) {
        Write-Host "NEMA_DATOTEKA=1"
        Write-Host "$Marker`_EXIT=0"
        $global:LASTEXITCODE = 0
        return
    }

    $finalExit = 0
    foreach ($file in $files) {
        $jsonPathForValidation = $file.FullName
        $tempJsonPath = $null

        try {
            if ($NormalizeAuditModuleIo) {
                $doc = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
                $requiresNormalization = $false

                foreach ($modul in @($doc.moduli)) {
                    if ($null -eq $modul) {
                        continue
                    }

                    if ($null -ne $modul.ulazi -and $modul.ulazi -isnot [System.Array]) {
                        $modul.ulazi = @($modul.ulazi)
                        $requiresNormalization = $true
                    }

                    if ($null -ne $modul.izlazi -and $modul.izlazi -isnot [System.Array]) {
                        $modul.izlazi = @($modul.izlazi)
                        $requiresNormalization = $true
                    }
                }

                if ($requiresNormalization) {
                    $tempJsonPath = Join-Path $env:TEMP (
                        "veritas_ci_smoke_audit_{0}.json" -f [Guid]::NewGuid().ToString("N")
                    )
                    $doc | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $tempJsonPath -Encoding UTF8
                    $jsonPathForValidation = $tempJsonPath
                }
            }

            & pwsh -NoProfile -ExecutionPolicy Bypass -File $genericSchemaValidatorScript `
                -JsonPutanja $jsonPathForValidation `
                -ShemaPutanja $schemaPath `
                -OpisValidatora $Description `
                -OznakaIzlaza ("{0}_FILE" -f $Marker)
            $validatorExit = $LASTEXITCODE
        }
        finally {
            if ($null -ne $tempJsonPath -and (Test-Path -LiteralPath $tempJsonPath)) {
                Remove-Item -LiteralPath $tempJsonPath -Force -ErrorAction SilentlyContinue
            }
        }

        if ($validatorExit -ne 0 -and $finalExit -eq 0) {
            $finalExit = $validatorExit
        }
    }

    Write-Host "$Marker`_EXIT=$finalExit"
    $global:LASTEXITCODE = $finalExit
}

Push-Location $root
$finalExitCode = 0
$fullRepoLintExit = $null
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
    Write-Host "CI_SMOKE_MDLINT_ENGINE=markdownlint-cli"
    Write-Host "CI_SMOKE_MDLINT_RULESET=MD010,MD013,MD036,MD040,MD047,MD060"

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
            Name = "privacy_repository_gate_p9"
            Action = { & $privacyRepoGateScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_predmet_prekrsaji_v1_schema"
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "predmeti\sud\prekrsajni") `
                    -Filter "predmet.json" `
                    -SchemaRelativePath (
                        "dokumentacija\sheme\SCHEMA_PREDMET_PREKRSAJI_V1.json"
                    ) `
                    -Marker "VALIDATE_PREDMET_PREKRSAJI_V1_SCHEMA" `
                    -Description "P9 predmet prekršaji v1"
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_predmet_prekrsaji_v1_privacy"
            Action = {
                $predmetRoot = Join-Path $root "predmeti\sud\prekrsajni"
                $predmetFiles = @(
                    Get-ChildItem `
                        -Path $predmetRoot `
                        -Recurse `
                        -File `
                        -Filter "predmet.json"
                )
                foreach ($predmetFile in $predmetFiles) {
                    & $predmetValidatorScript -PredmetPath $predmetFile.FullName
                    if ($LASTEXITCODE -ne 0) {
                        $global:LASTEXITCODE = $LASTEXITCODE
                        return
                    }
                }
                $global:LASTEXITCODE = 0
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_p9_privacy_v1"
            Action = { & $p9PrivacyTestScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_p9_inicijalizacija_v1"
            Action = { & $p9InitTestScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_p9_lokalni_e2e_v1"
            Action = { & $p9LocalE2ETestScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "lint_markdown_scoped"
            Action = { & $markdownLintScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "lint_markdown_full_repo_signal"
            Action = {
                Write-Host "CI_SMOKE_FULL_REPO_MDLINT_BEGIN=True"
                & $markdownLintScript -FullRepo
                $script:fullRepoLintExit = $LASTEXITCODE
                Write-Host "CI_SMOKE_FULL_REPO_MDLINT_EXIT=$script:fullRepoLintExit"
                Write-Host "CI_SMOKE_FULL_REPO_MDLINT_END=True"
                $global:LASTEXITCODE = 0
            }
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
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "predmeti\sud\prekrsajni") `
                    -Filter "audit_v*.json" `
                    -PathRegex "\\audit\\" `
                    -SchemaRelativePath "dokumentacija\sheme\SCHEMA_AUDIT_V1.json" `
                    -Marker "VALIDATOR_AUDIT_V1" `
                    -Description "ci smoke audit v1 izravno preko generickog schema-driven validatora" `
                    -NormalizeAuditModuleIo
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_intake_prekrsaji_v1"
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "predmeti\sud\prekrsajni") `
                    -Filter "intake_v*.json" `
                    -PathRegex "\\intake\\" `
                    -SchemaRelativePath "dokumentacija\sheme\SCHEMA_INTAKE_PREKRSAJI_V1.json" `
                    -Marker "VALIDATOR_INTAKE_PREKRSAJI_V1" `
                    -Description "ci smoke intake v1 izravno preko generickog schema-driven validatora"
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_subsumcija_v1"
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "predmeti\sud\prekrsajni") `
                    -Filter "subsumcija_v*.json" `
                    -PathRegex "\\audit\\" `
                    -SchemaRelativePath "dokumentacija\sheme\SCHEMA_SUBSUMPCIJA_V1.json" `
                    -Marker "VALIDATOR_SUBSUMPCIJA_V1" `
                    -Description "ci smoke subsumcija v1 izravno preko generickog schema-driven validatora"
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_predlozak_v1"
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "predlosci\sud\prekrsajni") `
                    -Filter "predlozak.json" `
                    -SchemaRelativePath "dokumentacija\sheme\SCHEMA_PREDLOZAK_V1.json" `
                    -Marker "VALIDATOR_PREDLOZAK_V1" `
                    -Description "ci smoke predlozak v1 izravno preko generickog schema-driven validatora"
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_postupak_v1"
            Action = {
                Invoke-GenericSchemaValidationSet `
                    -TargetRoot (Join-Path $root "postupci\sud\prekrsajni") `
                    -Filter "postupak.json" `
                    -SchemaRelativePath "dokumentacija\sheme\SCHEMA_POSTUPAK_V1.json" `
                    -Marker "VALIDATOR_POSTUPAK_V1" `
                    -Description "ci smoke postupak v1 izravno preko generickog schema-driven validatora"
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "preflight_prekrsajni_zakon"
            Action = { & $preflightScript -AktSlug "prekrsajni_zakon" }
            Enabled = (-not $SkipPrekrsajniPreflight)
        },
        [pscustomobject]@{
            Name = "generate_audit_prekrsaji_v1"
            Action = {
                $tokovi = @(
                    "TOK_PN_PRIGOVOR",
                    "TOK_PRESUDA_ZALBA",
                    "TOK_RJESENJE_ZALBA",
                    "TOK_OBUSTAVA"
                )

                foreach ($tok in $tokovi) {
                    Write-Host "GEN_AUDIT_BEGIN=$tok"

                    $generatorOutput = @(
                        pwsh -NoProfile -ExecutionPolicy Bypass -File $auditGeneratorScript -PredmetId "OGLEDNI_PREDMET_0001" -Tok $tok -Verzija "v1" 2>&1
                    )
                    $generatorExit = $LASTEXITCODE

                    foreach ($line in $generatorOutput) {
                        Write-Host ([string]$line)
                    }

                    if ($generatorExit -ne 0) {
                        $global:LASTEXITCODE = $generatorExit
                        return
                    }

                    Write-Host "GEN_AUDIT_END=$tok EXIT=$generatorExit"
                }

                $global:LASTEXITCODE = 0
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "validate_audit_generated_v1"
            Action = { & $auditGeneratedValidatorScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_fixtures_audit_prekrsaji_v1"
            Action = { & $auditFixturesTestScript }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_run_tok_p7_v1"
            Action = { & $p7RunnerTestScript }
            Enabled = $true
        },
        # KANON: CI koristi isključivo generički runner run_tok_v1.ps1
        [pscustomobject]@{
            Name = "run_tok_p7_v1"
            Action = {
                $tokovi = @(
                    "TOK_PN_PRIGOVOR"
                )

                foreach ($tok in $tokovi) {
                    Write-Host "TOK_RUN_BEGIN=$tok"

                    $generatorOutput = @(
                        pwsh -NoProfile -ExecutionPolicy Bypass -File $auditGeneratorScript -PredmetId "OGLEDNI_PREDMET_0001" -Tok $tok -Verzija "v1" 2>&1
                    )
                    $generatorExit = $LASTEXITCODE
                    foreach ($line in $generatorOutput) {
                        Write-Host ([string]$line)
                    }
                    if ($generatorExit -ne 0) {
                        $global:LASTEXITCODE = $generatorExit
                        return
                    }

                    & $auditGeneratedValidatorScript
                    if ($LASTEXITCODE -ne 0) {
                        $global:LASTEXITCODE = $LASTEXITCODE
                        return
                    }

                    $runnerOutput = @(
                        pwsh -NoProfile -ExecutionPolicy Bypass -File $tokRunnerScript -Tok $tok -PredmetId "OGLEDNI_PREDMET_0001" -Verzija "v1" 2>&1
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

                        if ($validatorExit -ne 0) {
                            $global:LASTEXITCODE = $validatorExit
                            return
                        }

                        $outputRaw = Get-Content -LiteralPath $resolvedOutputPath -Raw -Encoding UTF8
                        if ($outputRaw -match "Ã|Ä|Å|Â|â|�") {
                            Write-Host "ERROR: UTF8_DRAFT_MOJIBAKE=$resolvedOutputPath"
                            $global:LASTEXITCODE = 1
                            return
                        }

                        if (-not $outputRaw.Contains("traži")) {
                            Write-Host "ERROR: UTF8_DRAFT_CROATIAN_TEXT_MISSING=$resolvedOutputPath"
                            $global:LASTEXITCODE = 1
                            return
                        }

                        $p7Markers = @(
                            "PREDLOZAK_ID=prigovor_pn_v1",
                            "AUDIT_REF=predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/audit/audit_generated_v1.json",
                            "IZVOR=predmet.sud_naziv",
                            "IZVOR=audit.nalazi",
                            "IZVOR=intake.opis_dogadaja",
                            "clanak_0235.json",
                            "clanak_0236.json",
                            "clanak_0237.json"
                        )
                        foreach ($p7Marker in $p7Markers) {
                            if (-not $outputRaw.Contains($p7Marker)) {
                                Write-Host "ERROR: P7_DRAFT_MARKER_MISSING=$p7Marker"
                                $global:LASTEXITCODE = 1
                                return
                            }
                        }

                        Write-Host "UTF8_DRAFT_RESULT=OK TOK=$tok"
                        Write-Host "P7_E2E_RESULT=OK TOK=$tok"

                        Write-Host "TOK_RUN_END=$tok RESULT=OK"
                        continue
                    }

                    if ($runnerText -match "RUNNER_RESULT=STOP") {
                        Write-Host "ERROR: P7_E2E_UNEXPECTED_STOP TOK=$tok"
                        $global:LASTEXITCODE = 1
                        return
                    }

                    Write-Host "ERROR: RUNNER_RESULT marker missing"
                    $global:LASTEXITCODE = 1
                    return
                }

                $global:LASTEXITCODE = 0
            }
            Enabled = $true
        },
        [pscustomobject]@{
            Name = "test_p8_manifest_lanac_v1"
            Action = { & $p8TestScript }
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

if ($null -eq $fullRepoLintExit) {
    Write-Host "CI_SMOKE_FULL_REPO_MDLINT_SIGNAL=NOT_RUN"
}
else {
    Write-Host "CI_SMOKE_FULL_REPO_MDLINT_SIGNAL=RUN"
    Write-Host "CI_SMOKE_FULL_REPO_MDLINT_RESULT_EXIT=$fullRepoLintExit"
}

Write-Host "CI_SMOKE_END=True"
Write-Host "CI_SMOKE_EXIT=$finalExitCode"
exit $finalExitCode
