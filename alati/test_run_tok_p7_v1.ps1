#requires -Version 7.0

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$predmetId = "OGLEDNI_PREDMET_0001"
$tok = "TOK_PN_PRIGOVOR"
$predmetRoot = Join-Path $repoRoot (
    "predmeti\sud\prekrsajni\{0}" -f $predmetId
)
$predmetPath = Join-Path $predmetRoot "predmet.json"
$auditPath = Join-Path $predmetRoot "audit\audit_generated_v1.json"
$outputPath = Join-Path $predmetRoot "izlazi\nacrt_prigovor_pn_v1.txt"
$generatorScript = Join-Path $PSScriptRoot "generiraj_audit_prekrsaji_v1.ps1"
$runnerScript = Join-Path $PSScriptRoot "run_tok_v1.ps1"
$validatorScript = Join-Path $PSScriptRoot (
    "validiraj_izlaz_tok_pn_prigovor_v1.ps1"
)

function Backup-File {
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    if (Test-Path -LiteralPath $Path) {
        return [pscustomobject]@{
            Exists = $true
            Bytes = [System.IO.File]::ReadAllBytes($Path)
        }
    }

    return [pscustomobject]@{ Exists = $false; Bytes = [byte[]]@() }
}

function Set-BytesFileWithRetry {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][byte[]] $Bytes
    )

    $parent = Split-Path -Path $Path -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            [System.IO.File]::WriteAllBytes($Path, $Bytes)
            return
        }
        catch {
            if ($attempt -eq 5) {
                throw
            }
            Start-Sleep -Milliseconds (100 * $attempt)
        }
    }
}

function Set-JsonFileWithRetry {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Document
    )

    $json = $Document | ConvertTo-Json -Depth 30
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            Set-Content `
                -LiteralPath $Path `
                -Value $json `
                -Encoding utf8NoBOM `
                -ErrorAction Stop
            return
        }
        catch {
            if ($attempt -eq 5) {
                throw
            }
            Start-Sleep -Milliseconds (100 * $attempt)
        }
    }
}

function Remove-FileWithRetry {
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
            return
        }
        catch {
            if ($attempt -eq 5) {
                throw
            }
            Start-Sleep -Milliseconds (100 * $attempt)
        }
    }
}

function Set-StaleOutput {
    Set-Content `
        -LiteralPath $outputPath `
        -Value "STARI_NACRT_NE_SMIJE_PREZIVJETI_BLOKADU" `
        -Encoding utf8NoBOM
}

function Restore-File {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)] $Backup
    )

    if ($Backup.Exists) {
        Set-BytesFileWithRetry -Path $Path -Bytes ([byte[]]$Backup.Bytes)
    }
    else {
        Remove-FileWithRetry -Path $Path
    }
}

function Get-BytesHash {
    param(
        [Parameter(Mandatory = $true)][byte[]] $Bytes
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return [System.BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace("-", "")
    }
    finally {
        $sha.Dispose()
    }
}

function Invoke-ChildScript {
    param(
        [Parameter(Mandatory = $true)][string] $Script,
        [Parameter(Mandatory = $false)][string[]] $Arguments = @()
    )

    $output = @(
        & pwsh `
            -NoProfile `
            -ExecutionPolicy Bypass `
            -File $Script `
            @Arguments `
            2>&1
    )
    $exitCode = $LASTEXITCODE
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = $output
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function Assert-Test {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Assert-StopWithoutOutput {
    param(
        [Parameter(Mandatory = $true)] $Result,
        [Parameter(Mandatory = $true)][string] $ExpectedReason
    )

    Assert-Test `
        -Condition ($Result.ExitCode -eq 0) `
        -Reason "Runner exit nije 0 za $ExpectedReason"
    Assert-Test `
        -Condition ($Result.Text -match "RUNNER_RESULT=STOP") `
        -Reason "Nedostaje RUNNER_RESULT=STOP za $ExpectedReason"
    Assert-Test `
        -Condition ($Result.Text -match [regex]::Escape("STOP_REASON=$ExpectedReason")) `
        -Reason "Pogrešan STOP_REASON za $ExpectedReason"
    Assert-Test `
        -Condition (-not (Test-Path -LiteralPath $outputPath)) `
        -Reason "Blokirani scenarij proizveo je nacrt: $ExpectedReason"
}

$backupPredmet = Backup-File -Path $predmetPath
$backupAudit = Backup-File -Path $auditPath
$backupOutput = Backup-File -Path $outputPath
$originalPredmetHash = Get-BytesHash -Bytes ([byte[]]$backupPredmet.Bytes)
$testSucceeded = $false
$failureMessage = ""

try {
    $generatorResult = Invoke-ChildScript `
        -Script $generatorScript `
        -Arguments @(
            "-PredmetId", $predmetId,
            "-Tok", $tok,
            "-Verzija", "v1"
        )
    Assert-Test `
        -Condition ($generatorResult.ExitCode -eq 0) `
        -Reason "Pozitivni generator nije prošao: $($generatorResult.Text)"

    $positiveAuditBytes = [System.IO.File]::ReadAllBytes($auditPath)
    Remove-FileWithRetry -Path $outputPath

    $positiveRunner = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @(
            "-Tok", $tok,
            "-PredmetId", $predmetId,
            "-Verzija", "v1"
        )
    Assert-Test `
        -Condition ($positiveRunner.ExitCode -eq 0) `
        -Reason "Pozitivni runner nije prošao: $($positiveRunner.Text)"
    Assert-Test `
        -Condition ($positiveRunner.Text -match "RUNNER_RESULT=OK") `
        -Reason "Pozitivni runner nema RUNNER_RESULT=OK"
    Assert-Test `
        -Condition ($positiveRunner.Text -match "TEMPLATE_MAPPING_RESULT=OK") `
        -Reason "Pozitivni runner nije dokazao mapiranje predloška"

    $validatorResult = Invoke-ChildScript `
        -Script $validatorScript `
        -Arguments @("-OutputPath", $outputPath)
    Assert-Test `
        -Condition ($validatorResult.ExitCode -eq 0) `
        -Reason "Pozitivni izlaz nije prošao validator: $($validatorResult.Text)"

    $positiveOutput = Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8
    $positiveMarkers = @(
        "PREDLOZAK_ID=prigovor_pn_v1",
        "AUDIT_REF=predmeti/sud/prekrsajni/OGLEDNI_PREDMET_0001/" +
            "audit/audit_generated_v1.json",
        "IZVOR=predmet.sud_naziv",
        "VRIJEDNOST=Ogledni prekršajni sud",
        "IZVOR=predmet.akt.vrsta",
        "VRIJEDNOST=prekrsajni_nalog",
        "IZVOR=predmet.akt.broj",
        "VRIJEDNOST=SINTETICKI_PN_0001",
        "IZVOR=predmet.akt.datum",
        "IZVOR=predmet.akt.datum_dostave",
        "VRIJEDNOST=20.02.2026.",
        "IZVOR=intake.opis_dogadaja",
        "traži uvid u dokaz",
        "clanak_0235.json",
        "clanak_0236.json",
        "clanak_0237.json"
    )
    foreach ($marker in $positiveMarkers) {
        Assert-Test `
            -Condition $positiveOutput.Contains($marker) `
            -Reason "Pozitivni nacrt nema marker: $marker"
    }
    Write-Host "P7_TEST_CASE=positive_mapping RESULT=OK"

    $blockedAudit = (
        [System.Text.Encoding]::UTF8.GetString($positiveAuditBytes) |
            ConvertFrom-Json
    )
    $blockedAudit.gate_stanje.blocked = $true
    $blockedAudit.gate_stanje.blocked_razlog = "P7 test blokade"
    Set-JsonFileWithRetry -Path $auditPath -Document $blockedAudit
    Set-StaleOutput
    $blockedResult = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @("-Tok", $tok, "-PredmetId", $predmetId, "-Verzija", "v1")
    Assert-StopWithoutOutput `
        -Result $blockedResult `
        -ExpectedReason "audit.blocked"
    Write-Host "P7_TEST_CASE=blocked_audit_no_output RESULT=OK"

    $noAnchorAudit = (
        [System.Text.Encoding]::UTF8.GetString($positiveAuditBytes) |
            ConvertFrom-Json
    )
    foreach ($finding in @($noAnchorAudit.nalazi)) {
        $finding.norma_ref = ""
    }
    Set-JsonFileWithRetry -Path $auditPath -Document $noAnchorAudit
    Set-StaleOutput
    $noAnchorResult = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @("-Tok", $tok, "-PredmetId", $predmetId, "-Verzija", "v1")
    Assert-StopWithoutOutput `
        -Result $noAnchorResult `
        -ExpectedReason "audit.nn_sidro_missing"
    Write-Host "P7_TEST_CASE=missing_nn_anchor_no_output RESULT=OK"

    Set-BytesFileWithRetry -Path $auditPath -Bytes $positiveAuditBytes
    $missingFieldPredmet = Get-Content -LiteralPath $predmetPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    $missingFieldPredmet.sud_naziv = ""
    Set-JsonFileWithRetry -Path $predmetPath -Document $missingFieldPredmet
    Set-StaleOutput
    $missingFieldResult = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @("-Tok", $tok, "-PredmetId", $predmetId, "-Verzija", "v1")
    Assert-StopWithoutOutput `
        -Result $missingFieldResult `
        -ExpectedReason "template.required_missing"
    Write-Host "P7_TEST_CASE=required_field_no_output RESULT=OK"

    Set-BytesFileWithRetry -Path $predmetPath -Bytes ([byte[]]$backupPredmet.Bytes)
    $missingActPredmet = Get-Content `
        -LiteralPath $predmetPath `
        -Raw `
        -Encoding UTF8 | ConvertFrom-Json
    $missingActPredmet.akt.broj = $null
    Set-JsonFileWithRetry -Path $predmetPath -Document $missingActPredmet
    Set-StaleOutput
    $missingActResult = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @("-Tok", $tok, "-PredmetId", $predmetId, "-Verzija", "v1")
    Assert-StopWithoutOutput `
        -Result $missingActResult `
        -ExpectedReason "template.required_missing"
    Write-Host "P7_TEST_CASE=missing_act_identity_no_output RESULT=OK"

    Set-BytesFileWithRetry -Path $predmetPath -Bytes ([byte[]]$backupPredmet.Bytes)
    $mismatchAudit = (
        [System.Text.Encoding]::UTF8.GetString($positiveAuditBytes) |
            ConvertFrom-Json
    )
    $mismatchAudit.meta.tok = "TOK_OBUSTAVA"
    Set-JsonFileWithRetry -Path $auditPath -Document $mismatchAudit
    Set-StaleOutput
    $mismatchResult = Invoke-ChildScript `
        -Script $runnerScript `
        -Arguments @("-Tok", $tok, "-PredmetId", $predmetId, "-Verzija", "v1")
    Assert-StopWithoutOutput `
        -Result $mismatchResult `
        -ExpectedReason "identity.tok_mismatch"
    Write-Host "P7_TEST_CASE=identity_mismatch_no_output RESULT=OK"

    $testSucceeded = $true
}
catch {
    $failureMessage = $_.Exception.Message
}
finally {
    Restore-File -Path $predmetPath -Backup $backupPredmet
    Restore-File -Path $auditPath -Backup $backupAudit
    Restore-File -Path $outputPath -Backup $backupOutput
}

if ($backupPredmet.Exists) {
    $restoredPredmetBytes = [System.IO.File]::ReadAllBytes($predmetPath)
    $restoredPredmetHash = Get-BytesHash -Bytes $restoredPredmetBytes
    if ($restoredPredmetHash -ne $originalPredmetHash) {
        Write-Host "ERROR: P7_TEST_PREDMET_RESTORE_HASH_MISMATCH"
        Write-Host "P7_RUNNER_TEST_EXIT=1"
        exit 1
    }
}

Write-Host "P7_TEST_INPUT_RESTORED=OK"
if (-not $testSucceeded) {
    Write-Host "ERROR: P7_TEST_FAIL=$failureMessage"
    Write-Host "P7_RUNNER_TEST_EXIT=1"
    exit 1
}

Write-Host "P7_RUNNER_TEST_EXIT=0"
exit 0
