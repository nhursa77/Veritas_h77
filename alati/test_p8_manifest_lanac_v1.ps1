#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$predmetId = "OGLEDNI_PREDMET_0001"
$tok = "TOK_PN_PRIGOVOR"
$verzija = "v1"
$subjectRoot = Join-Path $repoRoot (
    "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001"
)
$auditPath = Join-Path $subjectRoot "audit\audit_generated_v1.json"
$draftPath = Join-Path $subjectRoot "izlazi\nacrt_prigovor_pn_v1.txt"
$manifestPath = Join-Path $subjectRoot "manifest.json"
$chainPath = Join-Path $subjectRoot "lanac_skrbnistva.json"
$runtimePaths = @($auditPath, $draftPath, $manifestPath, $chainPath)

$auditGenerator = Join-Path $PSScriptRoot "generiraj_audit_prekrsaji_v1.ps1"
$p7Runner = Join-Path $PSScriptRoot "run_tok_v1.ps1"
$p8Generator = Join-Path $PSScriptRoot (
    "generiraj_p8_manifest_i_lanac_v1.ps1"
)
$p8Validator = Join-Path $PSScriptRoot (
    "validiraj_p8_manifest_i_lanac_v1.ps1"
)

function Capture-P8RuntimeState {
    param([Parameter(Mandatory = $true)][string] $Path)

    $exists = Test-Path -LiteralPath $Path -PathType Leaf
    return [pscustomobject]@{
        Path = $Path
        Exists = $exists
        Bytes = if ($exists) {
            [System.IO.File]::ReadAllBytes($Path)
        }
        else {
            $null
        }
    }
}

function Restore-P8RuntimeState {
    param([Parameter(Mandatory = $true)] $State)

    if (Test-Path -LiteralPath $State.Path) {
        Remove-Item -LiteralPath $State.Path -Force
    }
    if ($State.Exists) {
        $parent = Split-Path -Path $State.Path -Parent
        if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        [System.IO.File]::WriteAllBytes($State.Path, $State.Bytes)
    }
}

function Invoke-P8TestScript {
    param(
        [Parameter(Mandatory = $true)][string] $ScriptPath,
        [Parameter(Mandatory = $false)][string[]] $Arguments = @()
    )

    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath `
            @Arguments 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = @($output | ForEach-Object { [string]$_ })
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function Assert-P8Test {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if (-not $Condition) {
        throw $Reason
    }
}

function Assert-P8OutputsAbsent {
    param([Parameter(Mandatory = $true)][string] $Scenario)

    Assert-P8Test `
        -Condition (-not (Test-Path -LiteralPath $manifestPath)) `
        -Reason "$Scenario je ostavio manifest"
    Assert-P8Test `
        -Condition (-not (Test-Path -LiteralPath $chainPath)) `
        -Reason "$Scenario je ostavio lanac skrbništva"
}

$snapshots = @($runtimePaths | ForEach-Object {
        Capture-P8RuntimeState -Path $_
    })
$finalExit = 1

try {
    $commonArgs = @(
        "-PredmetId", $predmetId,
        "-Tok", $tok,
        "-Verzija", $verzija
    )

    $auditResult = Invoke-P8TestScript `
        -ScriptPath $auditGenerator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition ($auditResult.ExitCode -eq 0) `
        -Reason "P8 setup nije generirao audit"

    $p7Result = Invoke-P8TestScript `
        -ScriptPath $p7Runner `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $p7Result.ExitCode -eq 0 -and
            $p7Result.Text.Contains("RUNNER_RESULT=OK")
        ) `
        -Reason "P8 setup nije generirao P7 nacrt"

    $positiveResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $positiveResult.ExitCode -eq 0 -and
            $positiveResult.Text.Contains("P8_GENERATOR_RESULT=OK")
        ) `
        -Reason "Pozitivni P8 generator nije prošao"
    Assert-P8Test `
        -Condition (
            (Test-Path -LiteralPath $manifestPath -PathType Leaf) -and
            (Test-Path -LiteralPath $chainPath -PathType Leaf)
        ) `
        -Reason "Pozitivni P8 prolaz nije stvorio oba izlaza"

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    $chain = Get-Content -LiteralPath $chainPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    Assert-P8Test `
        -Condition (@($manifest.artefakti).Count -eq 10) `
        -Reason "Manifest nema 10 artefakata"
    Assert-P8Test `
        -Condition (@($chain.dogadaji).Count -eq 2) `
        -Reason "Lanac nema dva obavezna događaja"
    Write-Host "P8_TEST_SCENARIO=positive RESULT=OK"

    $draftBytes = [System.IO.File]::ReadAllBytes($draftPath)
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::AppendAllText(
        $draftPath,
        "`nNEOVLASTENA_IZMJENA=P8_TEST`n",
        $utf8
    )
    $tamperResult = Invoke-P8TestScript `
        -ScriptPath $p8Validator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $tamperResult.ExitCode -ne 0 -and
            $tamperResult.Text.Contains(
                "P8_ARTIFACT_SIZE_MISMATCH=nacrt"
            )
        ) `
        -Reason "Izmijenjeni nacrt nije srušio P8 validator"
    Assert-P8OutputsAbsent -Scenario "Izmijenjeni nacrt"
    [System.IO.File]::WriteAllBytes($draftPath, $draftBytes)
    Write-Host "P8_TEST_SCENARIO=tampered_artifact RESULT=STOP_OK"

    $staleResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition ($staleResult.ExitCode -eq 0) `
        -Reason "P8 se nije obnovio prije testa nestalog artefakta"
    $draftBytes = [System.IO.File]::ReadAllBytes($draftPath)
    Remove-Item -LiteralPath $draftPath -Force
    $missingResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $missingResult.ExitCode -ne 0 -and
            $missingResult.Text.Contains("P8_ARTIFACT_MISSING=")
        ) `
        -Reason "Nestali artefakt nije zaustavio P8 generator"
    Assert-P8OutputsAbsent -Scenario "Nestali artefakt"
    [System.IO.File]::WriteAllBytes($draftPath, $draftBytes)
    Write-Host "P8_TEST_SCENARIO=missing_artifact RESULT=STOP_OK"

    $staleResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition ($staleResult.ExitCode -eq 0) `
        -Reason "P8 se nije obnovio prije testa identiteta"
    $auditBytes = [System.IO.File]::ReadAllBytes($auditPath)
    $audit = Get-Content -LiteralPath $auditPath -Raw -Encoding UTF8 |
        ConvertFrom-Json
    $audit.meta.id_predmeta = "POGRESAN_PREDMET"
    $auditJson = $audit | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText(
        $auditPath,
        $auditJson + "`n",
        $utf8
    )
    $identityResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $identityResult.ExitCode -ne 0 -and
            $identityResult.Text.Contains(
                "audit ima pogrešan id_predmeta"
            )
        ) `
        -Reason "Pogrešan identitet nije zaustavio P8 generator"
    Assert-P8OutputsAbsent -Scenario "Pogrešan identitet"
    [System.IO.File]::WriteAllBytes($auditPath, $auditBytes)
    Write-Host "P8_TEST_SCENARIO=identity_mismatch RESULT=STOP_OK"

    $finalResult = Invoke-P8TestScript `
        -ScriptPath $p8Generator `
        -Arguments $commonArgs
    Assert-P8Test `
        -Condition (
            $finalResult.ExitCode -eq 0 -and
            $finalResult.Text.Contains("P8_GENERATOR_RESULT=OK")
        ) `
        -Reason "P8 završni kontrolni prolaz nije uspio"

    Write-Host "P8_TEST_POSITIVE=1"
    Write-Host "P8_TEST_NEGATIVE=3"
    Write-Host "P8_TEST_RESULT=OK"
    $finalExit = 0
}
catch {
    Write-Host "P8_TEST_RESULT=FAIL"
    Write-Host "STOP_REASON=$($_.Exception.Message)"
    $finalExit = 1
}
finally {
    foreach ($snapshot in $snapshots) {
        Restore-P8RuntimeState -State $snapshot
    }
}

exit $finalExit
