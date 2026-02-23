$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$fixturesRoot = Join-Path $repoRoot "predmeti\_fixtures\prekrsajni\audit_v1"
$generatorScript = Join-Path $PSScriptRoot "generiraj_audit_prekrsaji_v1.ps1"

$predmetId = "OGLEDNI_PREDMET_0001"
$runtimeRoot = Join-Path $repoRoot ("predmeti\sud\prekrsajni\{0}" -f $predmetId)
$runtimeIntakePath = Join-Path $runtimeRoot "intake\intake_v1.json"
$runtimeSubsumcijaPath = Join-Path $runtimeRoot "audit\subsumcija_v1.json"
$runtimeAuditV1Path = Join-Path $runtimeRoot "audit\audit_v1.json"
$runtimeGeneratedPath = Join-Path $runtimeRoot "audit\audit_generated_v1.json"

if (-not (Test-Path -LiteralPath $fixturesRoot)) {
    Write-Host "ERROR: FIXTURES_ROOT_NOT_FOUND=$fixturesRoot"
    Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
    exit 1
}

$scenarioFiles = @(Get-ChildItem -LiteralPath $fixturesRoot -Recurse -File -Filter "scenario.json" | Sort-Object FullName)
if ($scenarioFiles.Count -lt 10) {
    Write-Host "ERROR: FIXTURES_MINIMUM_NOT_MET count=$($scenarioFiles.Count)"
    Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
    exit 1
}

function Backup-File {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (Test-Path -LiteralPath $Path) {
        return [pscustomobject]@{ Exists = $true; Content = (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) }
    }

    return [pscustomobject]@{ Exists = $false; Content = "" }
}

function Restore-File {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Backup
    )

    $parent = Split-Path -Path $Path -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ($Backup.Exists) {
        Set-Content -LiteralPath $Path -Value ([string]$Backup.Content) -Encoding UTF8
    }
    elseif (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Force
    }
}

$backupIntake = Backup-File -Path $runtimeIntakePath
$backupSubsumcija = Backup-File -Path $runtimeSubsumcijaPath
$backupAuditV1 = Backup-File -Path $runtimeAuditV1Path

try {
    foreach ($scenarioFile in $scenarioFiles) {
        $scenarioRaw = Get-Content -LiteralPath $scenarioFile.FullName -Raw -Encoding UTF8
        $scenario = $scenarioRaw | ConvertFrom-Json

        $scenarioId = [string]$scenario.id
        if ([string]::IsNullOrWhiteSpace($scenarioId)) {
            Write-Host "ERROR: SCENARIO_ID_MISSING file=$($scenarioFile.FullName)"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        Write-Host "FIXTURE_SCENARIO_BEGIN=$scenarioId"

        if ($null -eq $scenario.intake -or $null -eq $scenario.subsumcija -or $null -eq $scenario.expected) {
            Write-Host "ERROR: SCENARIO_STRUCTURE_INVALID id=$scenarioId"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        $tok = [string]$scenario.tok
        if ([string]::IsNullOrWhiteSpace($tok)) {
            $tok = "TOK_PN_PRIGOVOR"
        }

        $intakeJson = $scenario.intake | ConvertTo-Json -Depth 20
        $subsumcijaJson = $scenario.subsumcija | ConvertTo-Json -Depth 20

        $runtimeIntakeDir = Split-Path -Path $runtimeIntakePath -Parent
        $runtimeAuditDir = Split-Path -Path $runtimeSubsumcijaPath -Parent
        if (-not (Test-Path -LiteralPath $runtimeIntakeDir)) {
            New-Item -ItemType Directory -Path $runtimeIntakeDir -Force | Out-Null
        }
        if (-not (Test-Path -LiteralPath $runtimeAuditDir)) {
            New-Item -ItemType Directory -Path $runtimeAuditDir -Force | Out-Null
        }

        Set-Content -LiteralPath $runtimeIntakePath -Value $intakeJson -Encoding UTF8
        Set-Content -LiteralPath $runtimeSubsumcijaPath -Value $subsumcijaJson -Encoding UTF8

        if ($null -ne $scenario.PSObject.Properties["audit_v1"] -and $null -ne $scenario.audit_v1) {
            $auditV1Json = $scenario.audit_v1 | ConvertTo-Json -Depth 20
            Set-Content -LiteralPath $runtimeAuditV1Path -Value $auditV1Json -Encoding UTF8
        }
        elseif (Test-Path -LiteralPath $runtimeAuditV1Path) {
            Remove-Item -LiteralPath $runtimeAuditV1Path -Force
        }

        & powershell -NoProfile -ExecutionPolicy Bypass -File $generatorScript -PredmetId $predmetId -Tok $tok -Verzija "v1"
        $genExit = $LASTEXITCODE
        if ($genExit -ne 0) {
            Write-Host "ERROR: GENERATOR_FAIL scenario=$scenarioId exit=$genExit"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        if (-not (Test-Path -LiteralPath $runtimeGeneratedPath)) {
            Write-Host "ERROR: GENERATED_NOT_FOUND scenario=$scenarioId path=$runtimeGeneratedPath"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        $generated = Get-Content -LiteralPath $runtimeGeneratedPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $generatedCodes = @($generated.nalazi | ForEach-Object { [string]$_.kod })

        $semNalaz = @($generated.nalazi | Where-Object { [string]$_.kod -eq "NAP-SEM" } | Select-Object -First 1)
        if ($semNalaz.Count -eq 0) {
            Write-Host "ERROR: NAP_SEM_MISSING scenario=$scenarioId"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        $semMatch = [regex]::Match([string]$semNalaz[0].opis, "preflight=(ZELENO|ZUTO|CRVENO)")
        if (-not $semMatch.Success) {
            Write-Host "ERROR: PREFLIGHT_PARSE_FAIL scenario=$scenarioId"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        $actualPreflight = $semMatch.Groups[1].Value
        $expectedPreflight = [string]$scenario.expected.preflight
        if ($actualPreflight -ne $expectedPreflight) {
            Write-Host "ERROR: PREFLIGHT_MISMATCH scenario=$scenarioId expected=$expectedPreflight actual=$actualPreflight"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        foreach ($requiredCode in @($scenario.expected.required_nap)) {
            $requiredCodeText = [string]$requiredCode
            if ([string]::IsNullOrWhiteSpace($requiredCodeText)) {
                continue
            }

            if ($generatedCodes -notcontains $requiredCodeText) {
                Write-Host "ERROR: REQUIRED_NAP_MISSING scenario=$scenarioId code=$requiredCodeText"
                Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
                exit 1
            }
        }

        foreach ($forbiddenCode in @($scenario.expected.forbidden_nap)) {
            $forbiddenCodeText = [string]$forbiddenCode
            if ([string]::IsNullOrWhiteSpace($forbiddenCodeText)) {
                continue
            }

            if ($generatedCodes -contains $forbiddenCodeText) {
                Write-Host "ERROR: FORBIDDEN_NAP_PRESENT scenario=$scenarioId code=$forbiddenCodeText"
                Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
                exit 1
            }
        }

        Write-Host "FIXTURE_SCENARIO_END=$scenarioId RESULT=OK"
    }

    Write-Host "FIXTURES_AUDIT_V1_EXIT=0"
    exit 0
}
finally {
    Restore-File -Path $runtimeIntakePath -Backup $backupIntake
    Restore-File -Path $runtimeSubsumcijaPath -Backup $backupSubsumcija
    Restore-File -Path $runtimeAuditV1Path -Backup $backupAuditV1

    if ($null -ne (Get-Command git -ErrorAction SilentlyContinue)) {
        Push-Location $repoRoot
        try {
            git restore --quiet -- "predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/intake/intake_v1.json" "predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/audit/subsumcija_v1.json" "predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/audit/audit_v1.json" 1>$null 2>$null
            $global:LASTEXITCODE = 0
        }
        finally {
            Pop-Location
        }
    }
}
