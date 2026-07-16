#requires -Version 7.0

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
        return [pscustomobject]@{
            Exists = $true
            Bytes = [System.IO.File]::ReadAllBytes($Path)
        }
    }

    return [pscustomobject]@{ Exists = $false; Bytes = [byte[]]@() }
}

function Set-Utf8FileWithRetry {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Content
    )

    $maxAttempts = 5
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        try {
            Set-Content -LiteralPath $Path -Value $Content -Encoding utf8NoBOM -ErrorAction Stop
            return
        }
        catch {
            if ($attempt -eq $maxAttempts) {
                throw
            }

            Start-Sleep -Milliseconds (100 * $attempt)
        }
    }
}

function Set-BytesFileWithRetry {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][byte[]] $Bytes
    )

    $maxAttempts = 5
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        try {
            [System.IO.File]::WriteAllBytes($Path, $Bytes)
            return
        }
        catch {
            if ($attempt -eq $maxAttempts) {
                throw
            }

            Start-Sleep -Milliseconds (100 * $attempt)
        }
    }
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
        Set-BytesFileWithRetry -Path $Path -Bytes ([byte[]]$Backup.Bytes)
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

        Set-Utf8FileWithRetry -Path $runtimeIntakePath -Content $intakeJson
        Set-Utf8FileWithRetry -Path $runtimeSubsumcijaPath -Content $subsumcijaJson

        if ($null -ne $scenario.PSObject.Properties["audit_v1"] -and $null -ne $scenario.audit_v1) {
            $auditV1Json = $scenario.audit_v1 | ConvertTo-Json -Depth 20
            Set-Utf8FileWithRetry -Path $runtimeAuditV1Path -Content $auditV1Json
        }
        elseif (Test-Path -LiteralPath $runtimeAuditV1Path) {
            Remove-Item -LiteralPath $runtimeAuditV1Path -Force
        }

        & pwsh -NoProfile -ExecutionPolicy Bypass -File $generatorScript -PredmetId $predmetId -Tok $tok -Verzija "v1"
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

        $generatedRaw = Get-Content -LiteralPath $runtimeGeneratedPath -Raw -Encoding UTF8
        if ($generatedRaw -match "Ã|Ä|Å|Â|â|�") {
            Write-Host "ERROR: UTF8_AUDIT_MOJIBAKE scenario=$scenarioId"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        if (-not $generatedRaw.Contains("Činjenični")) {
            Write-Host "ERROR: UTF8_AUDIT_CROATIAN_TEXT_MISSING scenario=$scenarioId"
            Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
            exit 1
        }

        Write-Host "UTF8_AUDIT_RESULT=OK scenario=$scenarioId"

        $generated = $generatedRaw | ConvertFrom-Json
        $generatedCodes = @($generated.nalazi | ForEach-Object { [string]$_.kod })

        $expectedG1Status = ""
        if ($null -ne $scenario.expected.PSObject.Properties["g1"] -and $null -ne $scenario.expected.g1 -and $null -ne $scenario.expected.g1.PSObject.Properties["status"]) {
            $expectedG1Status = [string]$scenario.expected.g1.status
        }

        if (-not [string]::IsNullOrWhiteSpace($expectedG1Status)) {
            if ($null -eq $generated.PSObject.Properties["g1"] -or $null -eq $generated.g1 -or $null -eq $generated.g1.PSObject.Properties["status"]) {
                Write-Host "ERROR: G1_STATUS_MISSING scenario=$scenarioId expected=$expectedG1Status"
                Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
                exit 1
            }

            $actualG1Status = [string]$generated.g1.status
            if ($actualG1Status -ne $expectedG1Status) {
                Write-Host "ERROR: G1_STATUS_MISMATCH scenario=$scenarioId expected=$expectedG1Status actual=$actualG1Status"
                Write-Host "FIXTURES_AUDIT_V1_EXIT=1"
                exit 1
            }
        }

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

        $requiredNapCodes = @()
        if ($null -ne $scenario.expected.PSObject.Properties["nap"] -and $null -ne $scenario.expected.nap -and $null -ne $scenario.expected.nap.PSObject.Properties["must_include"]) {
            $requiredNapCodes = @($scenario.expected.nap.must_include)
        }
        elseif ($null -ne $scenario.expected.PSObject.Properties["required_nap"]) {
            $requiredNapCodes = @($scenario.expected.required_nap)
        }

        foreach ($requiredCode in $requiredNapCodes) {
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

        $forbiddenNapCodes = @()
        if ($null -ne $scenario.expected.PSObject.Properties["nap"] -and $null -ne $scenario.expected.nap -and $null -ne $scenario.expected.nap.PSObject.Properties["must_not_include"]) {
            $forbiddenNapCodes = @($scenario.expected.nap.must_not_include)
        }
        elseif ($null -ne $scenario.expected.PSObject.Properties["forbidden_nap"]) {
            $forbiddenNapCodes = @($scenario.expected.forbidden_nap)
        }

        foreach ($forbiddenCode in $forbiddenNapCodes) {
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
}
