#requires -Version 7.0

param(
    [Parameter(Mandatory = $true)]
    [string] $Tok,

    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$repoRootFull = [System.IO.Path]::GetFullPath($repoRoot).TrimEnd("\")
$repoRootPrefix = $repoRootFull + "\"

function Stop-Runner {
    param(
        [Parameter(Mandatory = $true)][string] $Reason,
        [Parameter(Mandatory = $false)][string] $Detail = ""
    )

    Write-Host "RUNNER_RESULT=STOP"
    Write-Host "STOP_REASON=$Reason"
    if (-not [string]::IsNullOrWhiteSpace($Detail)) {
        Write-Host "STOP_DETAIL=$Detail"
    }
    exit 0
}

function Fail-Runner {
    param(
        [Parameter(Mandatory = $true)][string] $Reason,
        [Parameter(Mandatory = $false)][string] $Detail = ""
    )

    Write-Host "ERROR: $Reason"
    if (-not [string]::IsNullOrWhiteSpace($Detail)) {
        Write-Host "ERROR_DETAIL=$Detail"
    }
    exit 1
}

function Expand-ProcedureReference {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef
    )

    $expanded = $PathRef.Replace("{PREDMET_ID}", $PredmetId)
    if ($expanded -match "\{[A-Z0-9_]+\}") {
        throw "Nerazriješena oznaka u putanji: $PathRef"
    }

    return ($expanded -replace "\\", "/")
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef
    )

    $normalizedPath = $PathRef -replace "/", "\"
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
        [System.IO.Path]::GetFullPath($normalizedPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $normalizedPath))
    }

    if ($resolvedPath -ne $repoRootFull -and -not $resolvedPath.StartsWith(
            $repoRootPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        throw "Putanja izlazi iz repozitorija: $PathRef"
    }

    return $resolvedPath
}

function Resolve-ProcedurePath {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef
    )

    $expanded = Expand-ProcedureReference -PathRef $PathRef
    return Resolve-RepoPath -PathRef $expanded
}

function Read-JsonDocument {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Name
    )

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        Fail-Runner -Reason "$Name JSON nije valjan" -Detail $Path
    }
}

function Assert-Identity {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][string] $Name
    )

    if ($null -eq $Document.PSObject.Properties["meta"] -or $null -eq $Document.meta) {
        Stop-Runner -Reason "identity.meta_missing" -Detail $Name
    }

    $actualPredmetId = ""
    if ($null -ne $Document.meta.PSObject.Properties["id_predmeta"]) {
        $actualPredmetId = [string]$Document.meta.id_predmeta
    }
    if ($actualPredmetId -ne $PredmetId) {
        Stop-Runner `
            -Reason "identity.predmet_mismatch" `
            -Detail "$Name expected=$PredmetId actual=$actualPredmetId"
    }

    if ($Name -eq "predmet") {
        return
    }

    $actualTok = ""
    if ($null -ne $Document.meta.PSObject.Properties["tok"]) {
        $actualTok = [string]$Document.meta.tok
    }
    if ($actualTok -ne $Tok) {
        Stop-Runner `
            -Reason "identity.tok_mismatch" `
            -Detail "$Name expected=$Tok actual=$actualTok"
    }

    $actualVerzija = ""
    if ($null -ne $Document.meta.PSObject.Properties["verzija_toka"]) {
        $actualVerzija = [string]$Document.meta.verzija_toka
    }
    if ($actualVerzija -ne $Verzija) {
        Stop-Runner `
            -Reason "identity.verzija_mismatch" `
            -Detail "$Name expected=$Verzija actual=$actualVerzija"
    }
}

function Resolve-MappedValue {
    param(
        [Parameter(Mandatory = $true)][string] $Source,
        [Parameter(Mandatory = $true)] $Audit,
        [Parameter(Mandatory = $true)] $Predmet,
        [Parameter(Mandatory = $true)] $Intake
    )

    $segments = @($Source -split "\.")
    if ($segments.Count -lt 2) {
        return [pscustomobject]@{ Found = $false; Value = $null }
    }

    $current = switch ($segments[0]) {
        "audit" { $Audit }
        "predmet" { $Predmet }
        "intake" { $Intake }
        default { $null }
    }

    if ($null -eq $current) {
        return [pscustomobject]@{ Found = $false; Value = $null }
    }

    for ($index = 1; $index -lt $segments.Count; $index++) {
        $segment = $segments[$index]
        if ($null -eq $current) {
            return [pscustomobject]@{ Found = $false; Value = $null }
        }

        $property = $current.PSObject.Properties[$segment]
        if ($null -eq $property) {
            return [pscustomobject]@{ Found = $false; Value = $null }
        }

        $current = $property.Value
    }

    return [pscustomobject]@{ Found = $true; Value = $current }
}

function Test-MappedValueMissing {
    param(
        [Parameter(Mandatory = $false)] $Value
    )

    if ($null -eq $Value) {
        return $true
    }
    if ($Value -is [string]) {
        return [string]::IsNullOrWhiteSpace([string]$Value)
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        return @($Value).Count -eq 0
    }

    return $false
}

function Format-MappedValue {
    param(
        [Parameter(Mandatory = $false)] $Value
    )

    if ($null -eq $Value) {
        return ""
    }
    if ($Value -is [string] -or $Value -is [ValueType]) {
        return [string]$Value
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @($Value)
        $allScalar = $true
        foreach ($item in $items) {
            if ($null -ne $item -and $item -isnot [string] -and $item -isnot [ValueType]) {
                $allScalar = $false
                break
            }
        }

        if ($allScalar) {
            return ($items | ForEach-Object { [string]$_ }) -join ", "
        }
    }

    return ($Value | ConvertTo-Json -Depth 20 -Compress)
}

if ($PredmetId -notmatch "^[A-Za-z0-9_-]+$") {
    Fail-Runner -Reason "PREDMET_ID_INVALID" -Detail $PredmetId
}
if ($Tok -notmatch "^TOK_[A-Z0-9_]+$") {
    Fail-Runner -Reason "TOK_INVALID" -Detail $Tok
}
if ($Verzija -notmatch "^v[0-9]+$") {
    Fail-Runner -Reason "VERZIJA_INVALID" -Detail $Verzija
}

$postupakPath = Join-Path $repoRoot (
    "postupci\sud\prekrsajni\{0}\{1}\postupak.json" -f $Tok, $Verzija
)
if (-not (Test-Path -LiteralPath $postupakPath)) {
    Fail-Runner -Reason "POSTUPAK_NOT_FOUND" -Detail $postupakPath
}

$postupak = Read-JsonDocument -Path $postupakPath -Name "postupak"

try {
    $predmetRef = Expand-ProcedureReference -PathRef ([string]$postupak.ulazi.predmet_ref)
    $auditRef = Expand-ProcedureReference -PathRef ([string]$postupak.ulazi.audit_ref)
    $intakeRef = Expand-ProcedureReference -PathRef ([string]$postupak.ulazi.intake_ref)
    $subsumcijaRef = Expand-ProcedureReference -PathRef ([string]$postupak.ulazi.subsumcija_ref)
    $predlozakRef = Expand-ProcedureReference -PathRef ([string]$postupak.ulazi.predlozak_ref)
    $outputRef = Expand-ProcedureReference -PathRef ([string]$postupak.izlazi.nacrt_ref)

    $predmetPath = Resolve-RepoPath -PathRef $predmetRef
    $auditPath = Resolve-RepoPath -PathRef $auditRef
    $intakePath = Resolve-RepoPath -PathRef $intakeRef
    $subsumcijaPath = Resolve-RepoPath -PathRef $subsumcijaRef
    $predlozakPath = Resolve-RepoPath -PathRef $predlozakRef
    $outputPath = Resolve-RepoPath -PathRef $outputRef
}
catch {
    Fail-Runner -Reason "PROCEDURE_PATH_INVALID" -Detail $_.Exception.Message
}

$predmetRoot = Resolve-RepoPath -PathRef (
    "predmeti/sud/prekrsajni/{0}" -f $PredmetId
)
$predmetPrefix = $predmetRoot.TrimEnd("\") + "\"
foreach ($subjectPath in @($predmetPath, $auditPath, $intakePath, $subsumcijaPath, $outputPath)) {
    if (-not $subjectPath.StartsWith(
            $predmetPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        Fail-Runner -Reason "SUBJECT_PATH_OUTSIDE_PREDMET" -Detail $subjectPath
    }
}

# Tvrdo pravilo "STOP bez izlaza" uključuje uklanjanje mogućeg zastarjelog
# nacrta iz ranijeg uspješnog prolaza. Inače bi blokirani novi pokušaj mogao
# ostaviti dojam da je stari nacrt rezultat trenutačnih ulaza.
if (Test-Path -LiteralPath $outputPath) {
    $outputRemoved = $false
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            Remove-Item -LiteralPath $outputPath -Force -ErrorAction Stop
            $outputRemoved = $true
            break
        }
        catch {
            if ($attempt -lt 5) {
                Start-Sleep -Milliseconds (100 * $attempt)
            }
        }
    }
    if (-not $outputRemoved) {
        Fail-Runner -Reason "STALE_OUTPUT_REMOVE_FAIL" -Detail $outputPath
    }
}

$requiredFiles = @(
    [pscustomobject]@{ Name = "predmet"; Path = $predmetPath },
    [pscustomobject]@{ Name = "audit"; Path = $auditPath },
    [pscustomobject]@{ Name = "intake"; Path = $intakePath },
    [pscustomobject]@{ Name = "subsumcija"; Path = $subsumcijaPath },
    [pscustomobject]@{ Name = "predlozak"; Path = $predlozakPath }
)
foreach ($requiredFile in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $requiredFile.Path)) {
        Stop-Runner `
            -Reason "missing.$($requiredFile.Name)" `
            -Detail $requiredFile.Path
    }
}

$predmet = Read-JsonDocument -Path $predmetPath -Name "predmet"
$audit = Read-JsonDocument -Path $auditPath -Name "audit"
$intake = Read-JsonDocument -Path $intakePath -Name "intake"
$subsumcija = Read-JsonDocument -Path $subsumcijaPath -Name "subsumcija"
$predlozak = Read-JsonDocument -Path $predlozakPath -Name "predlozak"

Assert-Identity -Document $predmet -Name "predmet"
Assert-Identity -Document $audit -Name "audit"
Assert-Identity -Document $intake -Name "intake"
Assert-Identity -Document $subsumcija -Name "subsumcija"

if ($audit.gate_stanje.blocked -eq $true) {
    Stop-Runner -Reason "audit.blocked" -Detail ([string]$audit.gate_stanje.blocked_razlog)
}

$napSem = @(
    $audit.nalazi |
        Where-Object { [string]$_.kod -eq "NAP-SEM" } |
        Select-Object -First 1
)
if ($napSem.Count -eq 0) {
    Fail-Runner -Reason "NAP_SEM_NOT_FOUND"
}

$preflightMatch = [regex]::Match(
    [string]$napSem[0].opis,
    "preflight=(ZELENO|ZUTO|CRVENO)"
)
if (-not $preflightMatch.Success) {
    Fail-Runner -Reason "PREFLIGHT_MARKER_NOT_FOUND"
}
if ($preflightMatch.Groups[1].Value -eq "CRVENO") {
    Stop-Runner -Reason "preflight.CRVENO"
}

$requiredNormaRefs = @()
if ($null -ne $postupak.ulazi.PSObject.Properties["norma_refs"] -and $null -ne $postupak.ulazi.norma_refs) {
    $requiredNormaRefs = @(
        $postupak.ulazi.norma_refs |
            ForEach-Object { ([string]$_ -replace "\\", "/") } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
}
if ($requiredNormaRefs.Count -eq 0) {
    Stop-Runner -Reason "audit.nn_sidro_missing" -Detail "postupak.ulazi.norma_refs"
}

$auditNormaRefs = @(
    $audit.nalazi |
        ForEach-Object { [string]$_.norma_ref } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_ -replace "\\", "/" } |
        Sort-Object -Unique
)

foreach ($requiredNormaRef in $requiredNormaRefs) {
    if ($auditNormaRefs -notcontains $requiredNormaRef) {
        Stop-Runner -Reason "audit.nn_sidro_missing" -Detail $requiredNormaRef
    }

    try {
        $normaPath = Resolve-RepoPath -PathRef $requiredNormaRef
    }
    catch {
        Stop-Runner -Reason "audit.nn_sidro_invalid" -Detail $requiredNormaRef
    }
    if (-not (Test-Path -LiteralPath $normaPath)) {
        Stop-Runner -Reason "audit.nn_sidro_invalid" -Detail $requiredNormaRef
    }

    $norma = Read-JsonDocument -Path $normaPath -Name "norma"
    $sidroStatus = ""
    if ($null -ne $norma.PSObject.Properties["izvori"] -and $null -ne $norma.izvori -and $null -ne $norma.izvori.PSObject.Properties["status_sidra"]) {
        $sidroStatus = [string]$norma.izvori.status_sidra
    }
    if ($sidroStatus -ne "puno") {
        Stop-Runner -Reason "audit.nn_sidro_not_full" -Detail $requiredNormaRef
    }
}

$fieldById = @{}
$ruleByFieldId = @{}
$mappedFieldCount = 0
$declaredSources = @($predlozak.mapiranje.izvori | ForEach-Object { [string]$_ })

foreach ($section in @($predlozak.sekcije)) {
    foreach ($field in @($section.polja)) {
        $fieldId = [string]$field.id
        if ([string]::IsNullOrWhiteSpace($fieldId) -or $fieldById.ContainsKey($fieldId)) {
            Fail-Runner -Reason "TEMPLATE_FIELD_ID_INVALID_OR_DUPLICATE" -Detail $fieldId
        }

        $source = [string]$field.izvor
        $sourceRoot = ($source -split "\.")[0]
        if ($declaredSources -notcontains $sourceRoot) {
            Fail-Runner -Reason "TEMPLATE_SOURCE_NOT_DECLARED" -Detail $source
        }

        $fieldById[$fieldId] = $field
    }
}

foreach ($rule in @($predlozak.mapiranje.pravila)) {
    $fieldId = [string]$rule.polje_id
    if (-not $fieldById.ContainsKey($fieldId) -or $ruleByFieldId.ContainsKey($fieldId)) {
        Fail-Runner -Reason "TEMPLATE_RULE_FIELD_INVALID_OR_DUPLICATE" -Detail $fieldId
    }
    if ([string]$rule.transformacija -ne "none") {
        Fail-Runner -Reason "TEMPLATE_TRANSFORMATION_NOT_ALLOWED" -Detail $fieldId
    }
    if ([string]$rule.izvor -ne [string]$fieldById[$fieldId].izvor) {
        Fail-Runner -Reason "TEMPLATE_RULE_SOURCE_MISMATCH" -Detail $fieldId
    }

    $ruleByFieldId[$fieldId] = $rule
}

foreach ($fieldId in $fieldById.Keys) {
    if (-not $ruleByFieldId.ContainsKey($fieldId)) {
        Fail-Runner -Reason "TEMPLATE_RULE_MISSING" -Detail $fieldId
    }
}

$requiredContractSources = @(
    "predmet.sud_naziv",
    "audit.nalazi",
    "intake.cilj",
    "intake.osporavanja",
    "intake.opis_dogadaja"
)
$actualContractSources = @(
    $ruleByFieldId.Values |
        ForEach-Object { [string]$_.izvor } |
        Sort-Object -Unique
)
foreach ($requiredSource in $requiredContractSources) {
    if ($actualContractSources -notcontains $requiredSource) {
        Stop-Runner -Reason "template.contract_missing" -Detail $requiredSource
    }
}

$resolvedFields = @{}
foreach ($fieldId in $fieldById.Keys) {
    $field = $fieldById[$fieldId]
    $rule = $ruleByFieldId[$fieldId]
    $resolved = Resolve-MappedValue `
        -Source ([string]$rule.izvor) `
        -Audit $audit `
        -Predmet $predmet `
        -Intake $intake

    $isRequired = [bool]$field.obavezno
    if ($isRequired -and (
            -not $resolved.Found -or
            (Test-MappedValueMissing -Value $resolved.Value)
        )) {
        Stop-Runner `
            -Reason "template.required_missing" `
            -Detail "$fieldId source=$([string]$rule.izvor)"
    }

    $resolvedFields[$fieldId] = $resolved.Value
    $mappedFieldCount++
}

$content = [System.Collections.Generic.List[string]]::new()
$content.Add("NACRT - bez potpisa")
$content.Add("Vrijedi tek nakon potpisa nositelja.")
$content.Add("")
$content.Add("TOK=$Tok")
$content.Add("PREDMET_ID=$PredmetId")
$content.Add("DATUM=$((Get-Date).ToString('dd.MM.yyyy.'))")
$content.Add("PREDLOZAK_ID=$([string]$predlozak.meta.id_predloska)")
$content.Add("PREDLOZAK_REF=$predlozakRef")
$content.Add("AUDIT_REF=$auditRef")
$content.Add("PREDMET_REF=$predmetRef")
$content.Add("")
$content.Add("NN_SIDRA_BEGIN")
foreach ($requiredNormaRef in $requiredNormaRefs) {
    $content.Add("- $requiredNormaRef")
}
$content.Add("NN_SIDRA_END")
$content.Add("")
$content.Add("PREDLOZAK_POLJA_BEGIN")

foreach ($section in @($predlozak.sekcije)) {
    $sectionId = [string]$section.id
    $content.Add("SEKCIJA_BEGIN=$sectionId")
    $content.Add("SEKCIJA_NASLOV=$([string]$section.naslov)")

    $sectionFields = @($section.polja)
    $sectionHasIntake = @(
        $sectionFields |
            Where-Object { [string]$_.izvor -like "intake.*" }
    ).Count -gt 0
    if ($sectionHasIntake) {
        $content.Add("INTAKE_BEGIN")
    }

    foreach ($field in $sectionFields) {
        $fieldId = [string]$field.id
        $source = [string]$ruleByFieldId[$fieldId].izvor
        $value = $resolvedFields[$fieldId]

        $content.Add("POLJE_BEGIN=$fieldId")
        $content.Add("LABEL=$([string]$field.label)")
        $content.Add("IZVOR=$source")

        if ($source -eq "audit.nalazi") {
            $content.Add("AUDIT_NALAZI_BEGIN")
            foreach ($nalaz in @($value)) {
                $normaSuffix = ""
                if (-not [string]::IsNullOrWhiteSpace([string]$nalaz.norma_ref)) {
                    $normaSuffix = " | NORMA_REF=$([string]$nalaz.norma_ref)"
                }
                $content.Add("- $([string]$nalaz.kod): $([string]$nalaz.opis)$normaSuffix")
            }
            $content.Add("AUDIT_NALAZI_END")
        }
        else {
            $content.Add("VRIJEDNOST=$(Format-MappedValue -Value $value)")
        }

        $content.Add("POLJE_END=$fieldId")
    }

    if ($sectionHasIntake) {
        $content.Add("INTAKE_END")
    }
    $content.Add("SEKCIJA_END=$sectionId")
}

$content.Add("PREDLOZAK_POLJA_END")

$outputDir = Split-Path -Path $outputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Set-Content -LiteralPath $outputPath -Value $content -Encoding utf8NoBOM

Write-Host "NN_SIDRA_RESULT=OK COUNT=$($requiredNormaRefs.Count)"
Write-Host "TEMPLATE_MAPPING_RESULT=OK FIELDS=$mappedFieldCount"
Write-Host "RUNNER_RESULT=OK"
Write-Host "OUTPUT_PATH=$outputPath"
Write-Host "OUTPUT_PREDLOZAK_ID=$([string]$predlozak.meta.id_predloska)"
Write-Host "OUTPUT_AUDIT_REF=$auditRef"
exit 0
