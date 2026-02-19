param(
    [Parameter(Mandatory = $true)]
    [string] $AktSlug,

    [Parameter(Mandatory = $false)]
    [int] $ExpectedCountOverride,

    [Parameter(Mandatory = $false)]
    [ValidateSet("procisceni", "amandmani")]
    [string] $ExpectedTipTeksta,

    [Parameter(Mandatory = $false)]
    [switch] $PaketMode
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$validator = Join-Path $PSScriptRoot "validiraj_nn_vs_kontrolno.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"
$controlJsonRel = "izvori/kontrolno/zakon_hr/$AktSlug/struktura_kontrolno_dokumenti.json"
$isSidroSlug = $AktSlug.ToLowerInvariant().Contains("_nn_")
$dataBaseRel = if ($isSidroSlug) { "baza_zakona/sidra" } else { "baza_zakona/norme" }
$dataBaseAbs = if ($isSidroSlug) { "baza_zakona\sidra" } else { "baza_zakona\norme" }
$operativniSlug = if (
    -not $isSidroSlug -and
    -not $AktSlug.ToLowerInvariant().EndsWith("_procisceni")
) {
    "${AktSlug}_procisceni"
}
else {
    $AktSlug
}
$reportPathRel = "$dataBaseRel/$operativniSlug/IZVJESTAJ_VALIDACIJE_KONTROLNO.md"
$normeDir = Join-Path $root "$dataBaseAbs\$operativniSlug"

function Get-OutputValue {
    param(
        [string[]] $Lines,
        [string] $Key
    )

    $prefix = "$($Key):"
    foreach ($line in $Lines) {
        $text = [string]$line
        if ($text.StartsWith($prefix)) {
            return $text.Substring($prefix.Length).Trim()
        }
    }
    return ""
}

function Get-BoolFromOutput {
    param(
        [string[]] $Lines,
        [string] $Key
    )

    $raw = Get-OutputValue -Lines $Lines -Key $Key
    if ($raw -match '^(true|false)$') {
        return [bool]::Parse($raw)
    }
    return $false
}

function Get-IntFromOutput {
    param(
        [string[]] $Lines,
        [string] $Key
    )

    $raw = Get-OutputValue -Lines $Lines -Key $Key
    if ($raw -match '^\d+$') {
        return [int]$raw
    }
    return 0
}

function Get-SlugEnvKey {
    param([string] $Value)
    $token = ($Value.ToUpperInvariant() -replace '[^A-Z0-9]+', '_').Trim('_')
    return "VERITAS_${token}_EXPECTED_COUNT_OVERRIDE"
}

function Restore-GitPathSafe {
    param([Parameter(Mandatory = $true)][string] $RelativePath)

    $trackedEntries = @(git ls-files --cached -- $RelativePath 2>$null)
    $hasTrackedEntry = $trackedEntries.Count -gt 0

    if ($hasTrackedEntry) {
        git restore --quiet -- $RelativePath 1>$null 2>$null
    }

    $global:LASTEXITCODE = 0
}

function Remove-UntrackedPathIfExists {
    param(
        [Parameter(Mandatory = $true)][string] $RelativePath,
        [Parameter(Mandatory = $true)][string] $AbsolutePath
    )

    if (!(Test-Path -LiteralPath $AbsolutePath)) {
        return
    }

    $trackedEntries = @(git ls-files --cached -- $RelativePath 2>$null)
    if ($trackedEntries.Count -eq 0) {
        Remove-Item -LiteralPath $AbsolutePath -Force -ErrorAction SilentlyContinue
    }

    $global:LASTEXITCODE = 0
}

$overrideEnvName = Get-SlugEnvKey -Value $AktSlug
$overrideWasSet = $false
$pythonIoEncodingName = "PYTHONIOENCODING"
$pythonIoEncodingBackup = $null
$pythonIoEncodingHadValue = $false
$effectiveExpectedTip = "procisceni"
if ($PSBoundParameters.ContainsKey('ExpectedTipTeksta')) {
    $effectiveExpectedTip = [string]$ExpectedTipTeksta
}
elseif ($PaketMode.IsPresent) {
    $effectiveExpectedTip = "procisceni"
}

$effectiveExpectedTip = $effectiveExpectedTip.ToLowerInvariant()

Push-Location $root
try {
    if ($PSBoundParameters.ContainsKey('ExpectedCountOverride')) {
        Set-Item -Path "Env:$overrideEnvName" -Value ([string]$ExpectedCountOverride)
        $overrideWasSet = $true
    }

    if (Test-Path "Env:$pythonIoEncodingName") {
        $pythonIoEncodingBackup = (Get-Item "Env:$pythonIoEncodingName").Value
        $pythonIoEncodingHadValue = $true
    }
    Set-Item -Path "Env:$pythonIoEncodingName" -Value "utf-8"

    $pythonExe = if (Test-Path -LiteralPath $venvPython) { $venvPython } else { "python" }
    $stdoutPath = [System.IO.Path]::GetTempFileName()
    $stderrPath = [System.IO.Path]::GetTempFileName()

    $validatorOutput = @()
    $validatorExitCode = 1
    if (Test-Path -LiteralPath $venvPython) {
        $process = Start-Process -FilePath $pythonExe -ArgumentList @($validator, "-AktSlug", $AktSlug) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $validatorExitCode = [int]$process.ExitCode
    }
    else {
        $process = Start-Process -FilePath $pythonExe -ArgumentList @($validator, "-AktSlug", $AktSlug) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $validatorExitCode = [int]$process.ExitCode
    }

    if (Test-Path -LiteralPath $stdoutPath) {
        $validatorOutput += @(Get-Content -LiteralPath $stdoutPath -Encoding UTF8 -ErrorAction SilentlyContinue)
    }
    if (Test-Path -LiteralPath $stderrPath) {
        $validatorOutput += @(Get-Content -LiteralPath $stderrPath -Encoding UTF8 -ErrorAction SilentlyContinue)
    }

    foreach ($line in $validatorOutput) {
        Write-Host ([string]$line)
    }

    $selectedTip = (Get-OutputValue -Lines $validatorOutput -Key "SELECTED_NN_TIP_TEKSTA").ToLowerInvariant()
    $selectedExpectedCountRaw = Get-OutputValue -Lines $validatorOutput -Key "SELECTED_NN_EXPECTED_COUNT"
    $sourceSelectionMismatch = Get-BoolFromOutput -Lines $validatorOutput -Key "SOURCE_SELECTION_MISMATCH"
    $guardrailFail = Get-BoolFromOutput -Lines $validatorOutput -Key "GUARDRAIL_FAIL"
    $nnCount = Get-IntFromOutput -Lines $validatorOutput -Key "NN_COUNT"

    $effectiveExitCode = $validatorExitCode

    if ($effectiveExpectedTip -eq "amandmani") {
        if ($selectedTip -ne "amandmani") {
            $effectiveExitCode = 2
        }
        elseif ($selectedExpectedCountRaw -ne "" -and $selectedExpectedCountRaw -ne "NONE" -and $sourceSelectionMismatch) {
            $effectiveExitCode = 3
        }
        else {
            $clanak0001 = Join-Path $normeDir "clanak_0001.json"
            $clanakAny = @()
            if (Test-Path -LiteralPath $normeDir) {
                $clanakAny = @(Get-ChildItem -LiteralPath $normeDir -Filter "clanak_*.json" -File -ErrorAction SilentlyContinue)
            }

            if ($nnCount -lt 1) {
                $effectiveExitCode = 4
            }
            elseif (!(Test-Path -LiteralPath $clanak0001) -and $clanakAny.Count -lt 1) {
                $effectiveExitCode = 4
            }
            else {
                if ($validatorExitCode -eq 2 -and $guardrailFail) {
                    $effectiveExitCode = 0
                }
            }
        }
    }

    Write-Host "TIP_EXPECTED: $effectiveExpectedTip"
    Write-Host "TIP_ACTUAL: $selectedTip"

    if ($effectiveExitCode -eq 0) {
        Write-Host "OK"
    }
    else {
        Write-Host "FAIL (exit code $effectiveExitCode)"
    }

    # Repo hygiene: rollback generated artifacts for this akt.
    Restore-GitPathSafe -RelativePath $reportPathRel
    Restore-GitPathSafe -RelativePath $controlJsonRel
    Remove-UntrackedPathIfExists -RelativePath $reportPathRel -AbsolutePath (Join-Path $root ($reportPathRel -replace '/', '\'))
    git status --short

    exit $effectiveExitCode
}
finally {
    if ($stdoutPath -and (Test-Path -LiteralPath $stdoutPath)) {
        Remove-Item -LiteralPath $stdoutPath -Force -ErrorAction SilentlyContinue
    }
    if ($stderrPath -and (Test-Path -LiteralPath $stderrPath)) {
        Remove-Item -LiteralPath $stderrPath -Force -ErrorAction SilentlyContinue
    }

    if ($overrideWasSet) {
        Remove-Item -Path "Env:$overrideEnvName" -ErrorAction SilentlyContinue
    }

    if ($pythonIoEncodingHadValue) {
        Set-Item -Path "Env:$pythonIoEncodingName" -Value $pythonIoEncodingBackup
    }
    else {
        Remove-Item -Path "Env:$pythonIoEncodingName" -ErrorAction SilentlyContinue
    }

    Pop-Location
}
