$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$targetRoot = Join-Path $repoRoot "predmeti\sud\prekrsajni"

if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

$files = Get-ChildItem -Path $targetRoot -Recurse -File -Filter "audit_generated_v1.json" |
    Where-Object { $_.FullName -match "\\audit\\" }

if ($null -eq $files -or $files.Count -eq 0) {
    Write-Host "NEMA_DATOTEKA=1"
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

$requiredCodes = @("NAP-G1", "NAP-G2", "NAP-G3", "NAP-SEM", "NAP-ODL")
$ok = $true

foreach ($file in $files) {
    try {
        $doc = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: JSON_PARSE_FAIL $($file.FullName)"
        $ok = $false
        continue
    }

    if ($null -eq $doc.meta) {
        Write-Host "ERROR: MISSING_META $($file.FullName)"
        $ok = $false
    }

    if ($null -eq $doc.gate_stanje) {
        Write-Host "ERROR: MISSING_GATE_STANJE $($file.FullName)"
        $ok = $false
    }

    if ($null -ne $doc.PSObject.Properties["g1"]) {
        if ($null -eq $doc.g1) {
            Write-Host "ERROR: G1_BLOCK_NULL FILE=$($file.FullName)"
            $ok = $false
        }
        elseif ($doc.g1 -isnot [psobject]) {
            Write-Host "ERROR: G1_BLOCK_TYPE_INVALID FILE=$($file.FullName)"
            $ok = $false
        }
        else {
            $g1Required = @("status", "start_date", "due_date", "days", "note")
            foreach ($g1Key in $g1Required) {
                if ($null -eq $doc.g1.PSObject.Properties[$g1Key]) {
                    Write-Host "ERROR: G1_FIELD_MISSING=$g1Key FILE=$($file.FullName)"
                    $ok = $false
                }
            }

            if ($null -ne $doc.g1.PSObject.Properties["status"]) {
                $g1Status = [string]$doc.g1.status
                $allowedG1Statuses = @("OK", "MISSING", "LATE", "INDETERMINATE")
                if ($allowedG1Statuses -notcontains $g1Status) {
                    Write-Host "ERROR: G1_STATUS_INVALID=$g1Status FILE=$($file.FullName)"
                    $ok = $false
                }
            }

            if ($null -ne $doc.g1.PSObject.Properties["days"]) {
                try {
                    $g1Days = [int]$doc.g1.days
                    if ($g1Days -lt 0) {
                        Write-Host "ERROR: G1_DAYS_NEGATIVE FILE=$($file.FullName)"
                        $ok = $false
                    }
                }
                catch {
                    Write-Host "ERROR: G1_DAYS_NOT_INT FILE=$($file.FullName)"
                    $ok = $false
                }
            }

            if ($null -ne $doc.g1.PSObject.Properties["start_date"] -and $doc.g1.start_date -isnot [string]) {
                Write-Host "ERROR: G1_START_DATE_NOT_STRING FILE=$($file.FullName)"
                $ok = $false
            }

            if ($null -ne $doc.g1.PSObject.Properties["due_date"] -and $doc.g1.due_date -isnot [string]) {
                Write-Host "ERROR: G1_DUE_DATE_NOT_STRING FILE=$($file.FullName)"
                $ok = $false
            }

            if ($null -ne $doc.g1.PSObject.Properties["note"] -and $doc.g1.note -isnot [string]) {
                Write-Host "ERROR: G1_NOTE_NOT_STRING FILE=$($file.FullName)"
                $ok = $false
            }
        }
    }

    if ($null -eq $doc.nalazi -or $doc.nalazi -isnot [System.Array]) {
        Write-Host "ERROR: MISSING_NALAZI_ARRAY $($file.FullName)"
        $ok = $false
        continue
    }

    foreach ($nalaz in @($doc.nalazi)) {
        if ($null -eq $nalaz.PSObject.Properties["kod"] -or $null -eq $nalaz.PSObject.Properties["opis"] -or $null -eq $nalaz.PSObject.Properties["tezina"] -or $null -eq $nalaz.PSObject.Properties["posljedica"] -or $null -eq $nalaz.PSObject.Properties["norma_ref"]) {
            Write-Host "ERROR: NALAZ_STRUKTURA_FAIL $($file.FullName)"
            $ok = $false
            break
        }
    }

    $codes = @($doc.nalazi | ForEach-Object { [string]$_.kod })
    foreach ($requiredCode in $requiredCodes) {
        if ($codes -notcontains $requiredCode) {
            Write-Host "ERROR: MISSING_NALAZ_KOD=$requiredCode FILE=$($file.FullName)"
            $ok = $false
        }
    }

    $semNalaz = @($doc.nalazi | Where-Object { [string]$_.kod -eq "NAP-SEM" } | Select-Object -First 1)
    if ($semNalaz.Count -eq 0) {
        Write-Host "ERROR: MISSING_NAP_SEM FILE=$($file.FullName)"
        $ok = $false
        continue
    }

    $semOpis = [string]$semNalaz[0].opis
    $semMatch = [regex]::Match($semOpis, "preflight=(ZELENO|ZUTO|CRVENO)")
    if (-not $semMatch.Success) {
        Write-Host "ERROR: NAP_SEM_PREFLIGHT_INVALID FILE=$($file.FullName)"
        $ok = $false
        continue
    }

    $preflight = $semMatch.Groups[1].Value
    $hasRed = $codes -contains "NAP-RED-BLOCKER"
    $hasYellow = $codes -contains "NAP-YEL-WARNING"
    $hasGreen = $codes -contains "NAP-GRN-OK"

    if ($preflight -eq "CRVENO" -and -not $hasRed) {
        Write-Host "ERROR: PREFLIGHT_RED_WITHOUT_BLOCKER FILE=$($file.FullName)"
        $ok = $false
    }

    if ($preflight -eq "ZUTO" -and (-not $hasYellow -or $hasRed)) {
        Write-Host "ERROR: PREFLIGHT_YELLOW_CLASS_MISMATCH FILE=$($file.FullName)"
        $ok = $false
    }

    if ($preflight -eq "ZELENO" -and (-not $hasGreen -or $hasRed -or $hasYellow)) {
        Write-Host "ERROR: PREFLIGHT_GREEN_CLASS_MISMATCH FILE=$($file.FullName)"
        $ok = $false
    }

    $blocked = $false
    if ($null -ne $doc.gate_stanje.PSObject.Properties["blocked"]) {
        $blocked = [bool]$doc.gate_stanje.blocked
    }

    if ($null -ne $doc.PSObject.Properties["g1"] -and $null -ne $doc.g1 -and $null -ne $doc.g1.PSObject.Properties["status"]) {
        $g1Status = [string]$doc.g1.status
        $hasG1Missing = $codes -contains "NAP-G1-MISSING"
        $hasG1Late = $codes -contains "NAP-G1-LATE"
        $hasG1Indeterminate = $codes -contains "NAP-G1-INDETERMINATE"

        if ($g1Status -eq "OK" -and ($hasG1Missing -or $hasG1Late -or $hasG1Indeterminate)) {
            Write-Host "ERROR: G1_OK_WITH_WARNING_CODE FILE=$($file.FullName)"
            $ok = $false
        }

        if ($g1Status -eq "MISSING" -and -not $hasG1Missing) {
            Write-Host "ERROR: G1_MISSING_WITHOUT_NAP FILE=$($file.FullName)"
            $ok = $false
        }

        if ($g1Status -eq "LATE" -and -not $hasG1Late) {
            Write-Host "ERROR: G1_LATE_WITHOUT_NAP FILE=$($file.FullName)"
            $ok = $false
        }

        if ($g1Status -eq "INDETERMINATE" -and -not $hasG1Indeterminate) {
            Write-Host "ERROR: G1_INDETERMINATE_WITHOUT_NAP FILE=$($file.FullName)"
            $ok = $false
        }
    }

    if ($preflight -eq "CRVENO" -and -not $blocked) {
        Write-Host "ERROR: GATE_BLOCKED_MISMATCH_RED FILE=$($file.FullName)"
        $ok = $false
    }

    if (($preflight -eq "ZELENO" -or $preflight -eq "ZUTO") -and $blocked) {
        Write-Host "ERROR: GATE_BLOCKED_MISMATCH_NON_RED FILE=$($file.FullName)"
        $ok = $false
    }
}

if ($ok) {
    Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=0"
    exit 0
}

Write-Host "VALIDATOR_AUDIT_GENERATED_V1_EXIT=1"
exit 1
