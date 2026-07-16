#requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent

function Fail-Validation {
    param(
        [Parameter(Mandatory = $true)][string] $Reason
    )

    Write-Host "ERROR: $Reason"
    Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=1"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $outputPath = Join-Path $repoRoot (
        "predmeti\sud\prekrsajni\OGLEDNI_PREDMET_0001\izlazi\" +
        "nacrt_prigovor_pn_v1.txt"
    )
}
else {
    $normalizedPath = $OutputPath -replace "/", "\"
    $outputPath = if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
        [System.IO.Path]::GetFullPath($normalizedPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $normalizedPath))
    }
}

if (-not (Test-Path -LiteralPath $outputPath)) {
    Fail-Validation -Reason "OUTPUT_NOT_FOUND=$outputPath"
}

$fileInfo = Get-Item -LiteralPath $outputPath
if ($fileInfo.Length -le 0) {
    Fail-Validation -Reason "OUTPUT_EMPTY=$outputPath"
}

$content = Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8
$lines = @(Get-Content -LiteralPath $outputPath -Encoding UTF8)

$requiredMarkers = @(
    "NACRT - bez potpisa",
    "Vrijedi tek nakon potpisa nositelja.",
    "TOK=",
    "PREDMET_ID=",
    "DATUM=",
    "PREDLOZAK_ID=",
    "PREDLOZAK_REF=",
    "AUDIT_REF=",
    "PREDMET_REF=",
    "NN_SIDRA_BEGIN",
    "NN_SIDRA_END",
    "PREDLOZAK_POLJA_BEGIN",
    "PREDLOZAK_POLJA_END",
    "AUDIT_NALAZI_BEGIN",
    "AUDIT_NALAZI_END",
    "INTAKE_BEGIN",
    "INTAKE_END"
)
foreach ($marker in $requiredMarkers) {
    if ($content -notmatch [regex]::Escape($marker)) {
        Fail-Validation -Reason "OUTPUT_MISSING_MARKER=$marker"
    }
}

if ($content -match "\{PREDMET_ID\}") {
    Fail-Validation -Reason "OUTPUT_UNRESOLVED_PREDMET_TOKEN"
}
if ($content -match "Ã|Ä|Å|Â|â|�") {
    Fail-Validation -Reason "OUTPUT_MOJIBAKE"
}

$auditRefMatch = [regex]::Match($content, "(?m)^AUDIT_REF=(.+)$")
if (-not $auditRefMatch.Success -or $auditRefMatch.Groups[1].Value.Trim() -notmatch "audit_generated_v1[.]json$") {
    Fail-Validation -Reason "OUTPUT_AUDIT_REF_NOT_GENERATED"
}

$predlozakIdMatch = [regex]::Match($content, "(?m)^PREDLOZAK_ID=(.+)$")
if (-not $predlozakIdMatch.Success -or [string]::IsNullOrWhiteSpace($predlozakIdMatch.Groups[1].Value)) {
    Fail-Validation -Reason "OUTPUT_PREDLOZAK_ID_EMPTY"
}

$predmetIdMatch = [regex]::Match($content, "(?m)^PREDMET_ID=(.+)$")
if (-not $predmetIdMatch.Success -or [string]::IsNullOrWhiteSpace($predmetIdMatch.Groups[1].Value)) {
    Fail-Validation -Reason "OUTPUT_PREDMET_ID_EMPTY"
}

$sectionBeginCount = ([regex]::Matches($content, "(?m)^SEKCIJA_BEGIN=")).Count
$sectionEndCount = ([regex]::Matches($content, "(?m)^SEKCIJA_END=")).Count
if ($sectionBeginCount -eq 0 -or $sectionBeginCount -ne $sectionEndCount) {
    Fail-Validation -Reason "OUTPUT_SECTION_BALANCE_INVALID"
}

$fieldBeginCount = ([regex]::Matches($content, "(?m)^POLJE_BEGIN=")).Count
$fieldEndCount = ([regex]::Matches($content, "(?m)^POLJE_END=")).Count
if ($fieldBeginCount -eq 0 -or $fieldBeginCount -ne $fieldEndCount) {
    Fail-Validation -Reason "OUTPUT_FIELD_BALANCE_INVALID"
}

$activeField = ""
$activeFieldHasLabel = $false
$activeFieldHasSource = $false
$activeFieldHasValue = $false
$mappedSources = [System.Collections.Generic.List[string]]::new()

foreach ($line in $lines) {
    if ($line -match "^POLJE_BEGIN=(.+)$") {
        if (-not [string]::IsNullOrWhiteSpace($activeField)) {
            Fail-Validation -Reason "OUTPUT_FIELD_NESTED=$line"
        }
        $activeField = $Matches[1]
        $activeFieldHasLabel = $false
        $activeFieldHasSource = $false
        $activeFieldHasValue = $false
        continue
    }

    if ([string]::IsNullOrWhiteSpace($activeField)) {
        continue
    }

    if ($line -match "^LABEL=") {
        $activeFieldHasLabel = $true
        continue
    }
    if ($line -match "^IZVOR=(.+)$") {
        $activeFieldHasSource = $true
        $mappedSources.Add($Matches[1])
        continue
    }
    if ($line -match "^VRIJEDNOST=" -or $line -eq "AUDIT_NALAZI_BEGIN") {
        $activeFieldHasValue = $true
        continue
    }
    if ($line -match "^POLJE_END=(.+)$") {
        if ($Matches[1] -ne $activeField) {
            Fail-Validation -Reason "OUTPUT_FIELD_END_MISMATCH=$line"
        }
        if (-not $activeFieldHasLabel -or -not $activeFieldHasSource -or -not $activeFieldHasValue) {
            Fail-Validation -Reason "OUTPUT_FIELD_PROVENANCE_INCOMPLETE=$activeField"
        }
        $activeField = ""
    }
}

if (-not [string]::IsNullOrWhiteSpace($activeField)) {
    Fail-Validation -Reason "OUTPUT_FIELD_NOT_CLOSED=$activeField"
}

$requiredSources = @(
    "predmet.sud_naziv",
    "audit.nalazi",
    "intake.cilj",
    "intake.osporavanja",
    "intake.opis_dogadaja"
)
foreach ($requiredSource in $requiredSources) {
    if ($mappedSources -notcontains $requiredSource) {
        Fail-Validation -Reason "OUTPUT_REQUIRED_SOURCE_MISSING=$requiredSource"
    }
}

$nnSidroLines = @(
    $lines |
        Where-Object { $_ -match "^- baza_zakona/norme/.+[.]json$" }
)
if ($nnSidroLines.Count -eq 0) {
    Fail-Validation -Reason "OUTPUT_NN_SIDRO_LIST_EMPTY"
}

Write-Host "VALIDATOR_P7_SECTIONS=$sectionBeginCount"
Write-Host "VALIDATOR_P7_FIELDS=$fieldBeginCount"
Write-Host "VALIDATOR_P7_NN_SIDRA=$($nnSidroLines.Count)"
Write-Host "VALIDATOR_IZLAZ_TOK_EXIT=0"
exit 0
