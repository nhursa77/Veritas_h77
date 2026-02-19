param(
    [Parameter(Mandatory = $true)]
    [string] $PaketPath,

    [Parameter(Mandatory = $false)]
    [switch] $StopOnFirstFail
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$preflightScript = Join-Path $PSScriptRoot "acceptance_preflight.ps1"

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

function Get-OptionalFailReason {
    param(
        [bool] $Required,
        [int] $ExitCode,
        [string] $JoinedOutput
    )

    if ($Required -or $ExitCode -eq 0) {
        return ""
    }

    if ($JoinedOutput -match "Nedostaje ulazna datoteka:\s*.*_kontrolni\.txt|_kontrolni\.txt") {
        return "MISSING_CONTROL_TEXT"
    }

    return ""
}

function Resolve-ControlMode {
    param(
        [string] $ExpectedTip
    )

    if ([string]::IsNullOrWhiteSpace($ExpectedTip)) {
        return "standard"
    }

    if ($ExpectedTip.ToLowerInvariant() -eq "amandmani") {
        return "delta"
    }

    return "standard"
}

function Assert-Manifest {
    param([Parameter(Mandatory = $true)] $Manifest)

    if ($null -eq $Manifest -or $null -eq $Manifest.akti) {
        throw "manifest_invalid: nedostaje 'akti'"
    }

    $items = @($Manifest.akti)
    if ($items.Count -eq 0) {
        throw "manifest_invalid: 'akti' je prazno"
    }

    $slugSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($item in $items) {
        $slug = [string]$item.akt_slug
        if ([string]::IsNullOrWhiteSpace($slug)) {
            throw "manifest_invalid: akt bez akt_slug"
        }

        if (-not $slugSet.Add($slug.ToLowerInvariant())) {
            throw "manifest_invalid: dupli akt_slug '$slug'"
        }
    }
}

Push-Location $root
try {
    if (!(Test-Path -LiteralPath $PaketPath)) {
        Write-Host "ERROR: Nedostaje paket manifest: $PaketPath"
        exit 22
    }

    try {
        $manifestRaw = Get-Content -LiteralPath $PaketPath -Raw -Encoding UTF8
        $manifest = $manifestRaw | ConvertFrom-Json
        Assert-Manifest -Manifest $manifest
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)"
        exit 22
    }

    $stopOnFail = $true
    if ($PSBoundParameters.ContainsKey('StopOnFirstFail')) {
        $stopOnFail = $StopOnFirstFail.IsPresent
    }

    $results = @()

    foreach ($item in $manifest.akti) {
        $aktSlug = [string]$item.akt_slug
        $required = [bool]$item.required
        $expectedTip = [string]$item.tip_teksta
        if ([string]::IsNullOrWhiteSpace($expectedTip)) {
            $expectedTip = if ($required) { "procisceni" } else { "amandmani" }
        }
        $expectedTip = $expectedTip.ToLowerInvariant()

        if ([string]::IsNullOrWhiteSpace($aktSlug)) {
            continue
        }

        Write-Host "=== AKT: $aktSlug (required=$required) ==="
        $outputLines = @()
        $exitCode = 0
        $controlMode = Resolve-ControlMode -ExpectedTip $expectedTip
        Write-Host "CONTROL_MODE: $controlMode"

        $controlTxtPath = Join-Path $root "izvori\kontrolno\zakon_hr\$aktSlug\${aktSlug}_kontrolni.txt"
        $deltaOpsPath = Join-Path $root "izvori\kontrolno\zakon_hr\$aktSlug\${aktSlug}_delta_ops.json"

        $hasControlTxt = Test-Path -LiteralPath $controlTxtPath
        $hasDeltaOps = Test-Path -LiteralPath $deltaOpsPath
        $hasControl = $hasControlTxt
        if ($controlMode -eq "delta") {
            $hasControl = $hasControlTxt -or $hasDeltaOps
        }

        if (-not $required -and -not $hasControl) {
            $exitCode = 2
            if ($controlMode -eq "delta") {
                $outputLines += "OPTIONAL_FAIL_REASON: MISSING_DELTA_CONTROL"
                $outputLines += "WARNING: optional akt '$aktSlug' nema ni kontrolni TXT ni delta_ops.json; preflight preskočen u CI smoke modu."
            }
            else {
                $outputLines += "OPTIONAL_FAIL_REASON: MISSING_CONTROL_TEXT"
                $outputLines += "WARNING: optional akt '$aktSlug' nema kontrolni TXT; preflight preskočen u CI smoke modu."
            }
        }
        elseif ($required -and -not $hasControl) {
            $exitCode = 2
            if ($controlMode -eq "delta") {
                $outputLines += "REQUIRED_FAIL_REASON: MISSING_DELTA_CONTROL"
                $outputLines += "ERROR: required akt '$aktSlug' nema ni kontrolni TXT ni delta_ops.json."
            }
            else {
                $outputLines += "REQUIRED_FAIL_REASON: MISSING_CONTROL_TEXT"
                $outputLines += "ERROR: required akt '$aktSlug' nema kontrolni TXT."
            }
        }
        else {
            try {
                $outputLines = & $preflightScript -AktSlug $aktSlug -PaketMode -ExpectedTipTeksta $expectedTip 2>&1
                $exitCode = $LASTEXITCODE
            }
            catch {
                $outputLines += [string]$_.Exception.Message
                if ($LASTEXITCODE -gt 0) {
                    $exitCode = $LASTEXITCODE
                }
                else {
                    $exitCode = 1
                }
            }
        }

        foreach ($line in $outputLines) {
            Write-Host ([string]$line)
        }

        $selectedSlug = Get-OutputValue -Lines $outputLines -Key "SELECTED_NN_SLUG"
        $tipTeksta = Get-OutputValue -Lines $outputLines -Key "TIP_ACTUAL"
        if ([string]::IsNullOrWhiteSpace($tipTeksta)) {
            $tipTeksta = Get-OutputValue -Lines $outputLines -Key "SELECTED_NN_TIP_TEKSTA"
        }
        $tipExpectedOut = Get-OutputValue -Lines $outputLines -Key "TIP_EXPECTED"
        if ([string]::IsNullOrWhiteSpace($tipExpectedOut)) {
            $tipExpectedOut = $expectedTip
        }
        $nnCount = Get-OutputValue -Lines $outputLines -Key "NN_COUNT"
        $expectedCount = Get-OutputValue -Lines $outputLines -Key "SELECTED_NN_EXPECTED_COUNT"
        $guardrailFail = Get-BoolFromOutput -Lines $outputLines -Key "GUARDRAIL_FAIL"

        $missingSource = $false
        $joined = ($outputLines | ForEach-Object { [string]$_ }) -join "`n"
        if ($joined -match "Nema kandidata izvora|Nedostaje ulazna datoteka|Nedostaje meta\.json|Nedostaje HTML izvor|FileNotFoundError") {
            $missingSource = $true
        }
        if (-not $missingSource -and $exitCode -ne 0 -and [string]::IsNullOrWhiteSpace($selectedSlug)) {
            $missingSource = $true
        }

        $optionalFailReason = Get-OutputValue -Lines $outputLines -Key "OPTIONAL_FAIL_REASON"
        if ([string]::IsNullOrWhiteSpace($optionalFailReason)) {
            $optionalFailReason = Get-OptionalFailReason -Required $required -ExitCode $exitCode -JoinedOutput $joined
        }

        Write-Host "MISSING_SOURCE: $missingSource"

        $results += [pscustomobject]@{
            akt_slug = $aktSlug
            required = $required
            control_mode = $controlMode
            exit = $exitCode
            selected_source = $selectedSlug
            tip_expected = $tipExpectedOut
            tip_teksta = $tipTeksta
            nn_count = $nnCount
            expected = $expectedCount
            guardrail_fail = $guardrailFail
            missing_source = $missingSource
            optional_fail_reason = $optionalFailReason
        }

        if ($stopOnFail -and $required -and $exitCode -ne 0) {
            break
        }
    }

    $requiredFails = @($results | Where-Object { $_.required -and $_.exit -ne 0 }).Count
    $optionalHardFails = @(
        $results | Where-Object {
            (
                -not $_.required -and
                $_.exit -ne 0 -and
                $_.optional_fail_reason -ne "MISSING_CONTROL_TEXT" -and
                $_.optional_fail_reason -ne "MISSING_DELTA_CONTROL"
            )
        }
    ).Count
    $optionalSoftMissingControl = @(
        $results | Where-Object {
            -not $_.required -and $_.exit -ne 0 -and (
                $_.optional_fail_reason -eq "MISSING_CONTROL_TEXT" -or
                $_.optional_fail_reason -eq "MISSING_DELTA_CONTROL"
            )
        }
    ).Count

    $packageExit = 0
    if ($requiredFails -gt 0) {
        $packageExit = 20
    }
    elseif ($optionalHardFails -gt 0) {
        $packageExit = 21
    }

    $paketOk = ($packageExit -eq 0)

    Write-Host ""
    Write-Host "=== PAKET SUMMARY ==="
    Write-Host "PAKET_OK: $paketOk"
    if (@($results | Where-Object { $_.control_mode -eq "delta" }).Count -gt 0) {
        Write-Host "CONTROL_MODE=delta"
    }
    Write-Host "OPTIONAL_SOFT_MISSING_CONTROL: $optionalSoftMissingControl"
    $results |
        Select-Object akt_slug, control_mode, exit, selected_source, tip_expected, tip_teksta, nn_count, expected, optional_fail_reason |
        Format-Table -AutoSize

    # Repo hygiene: restore generated artifacts for all acts in manifest.
    foreach ($item in $manifest.akti) {
        $slug = [string]$item.akt_slug
        if ([string]::IsNullOrWhiteSpace($slug)) {
            continue
        }

        $isSidroSlug = $slug.ToLowerInvariant().Contains("_nn_")
        $reportBaseRel = if ($isSidroSlug) { "baza_zakona/sidra" } else { "baza_zakona/norme" }
        $reportPathRel = "$reportBaseRel/$slug/IZVJESTAJ_VALIDACIJE_KONTROLNO.md"
        $controlJsonRel = "izvori/kontrolno/zakon_hr/$slug/struktura_kontrolno_dokumenti.json"
        try {
            git restore -- $reportPathRel $controlJsonRel 2>$null | Out-Null
        }
        catch {
            # Ignore restore errors for non-tracked or non-existing paths.
        }
    }

    git status --short
    exit $packageExit
}
finally {
    Pop-Location
}
