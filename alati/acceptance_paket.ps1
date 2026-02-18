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

        if ([string]::IsNullOrWhiteSpace($aktSlug)) {
            continue
        }

        Write-Host "=== AKT: $aktSlug (required=$required) ==="
        $outputLines = @()
        $exitCode = 0
        try {
            $outputLines = & $preflightScript -AktSlug $aktSlug 2>&1
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

        foreach ($line in $outputLines) {
            Write-Host ([string]$line)
        }

        $selectedSlug = Get-OutputValue -Lines $outputLines -Key "SELECTED_NN_SLUG"
        $tipTeksta = Get-OutputValue -Lines $outputLines -Key "SELECTED_NN_TIP_TEKSTA"
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

        Write-Host "MISSING_SOURCE: $missingSource"

        $results += [pscustomobject]@{
            akt_slug = $aktSlug
            required = $required
            exit = $exitCode
            selected_source = $selectedSlug
            tip_teksta = $tipTeksta
            nn_count = $nnCount
            expected = $expectedCount
            guardrail_fail = $guardrailFail
            missing_source = $missingSource
        }

        if ($stopOnFail -and $required -and $exitCode -ne 0) {
            break
        }
    }

    $requiredFails = @($results | Where-Object { $_.required -and $_.exit -ne 0 }).Count
    $optionalFails = @($results | Where-Object { -not $_.required -and $_.exit -ne 0 }).Count

    $packageExit = 0
    if ($requiredFails -gt 0) {
        $packageExit = 20
    }
    elseif ($optionalFails -gt 0) {
        $packageExit = 21
    }

    $paketOk = ($packageExit -eq 0)

    Write-Host ""
    Write-Host "=== PAKET SUMMARY ==="
    Write-Host "PAKET_OK: $paketOk"
    $results |
        Select-Object akt_slug, exit, selected_source, tip_teksta, nn_count, expected |
        Format-Table -AutoSize

    # Repo hygiene: restore generated artifacts for all acts in manifest.
    foreach ($item in $manifest.akti) {
        $slug = [string]$item.akt_slug
        if ([string]::IsNullOrWhiteSpace($slug)) {
            continue
        }

        $reportPathRel = "baza_zakona/norme/$slug/IZVJESTAJ_VALIDACIJE_KONTROLNO.md"
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
