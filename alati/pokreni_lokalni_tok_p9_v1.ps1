#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $DataRoot,

    [Parameter(Mandatory = $true)]
    [string] $PredmetId,

    [Parameter(Mandatory = $false)]
    [string] $Tok = 'TOK_PN_PRIGOVOR',

    [Parameter(Mandatory = $false)]
    [string] $Verzija = 'v1'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'putanje_predmeta_core.ps1')

$runtimePaths = [System.Collections.Generic.List[string]]::new()

function Add-P9RuntimePath {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not $runtimePaths.Contains($Path)) {
        [void]$runtimePaths.Add($Path)
    }
}

function Clear-P9RuntimeOutputs {
    foreach ($path in @($runtimePaths)) {
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        $removed = $false
        for ($attempt = 1; $attempt -le 5; $attempt++) {
            try {
                Remove-Item `
                    -LiteralPath $path `
                    -Force `
                    -ErrorAction Stop
                $removed = $true
                break
            }
            catch {
                if ($attempt -lt 5) {
                    Start-Sleep -Milliseconds (100 * $attempt)
                }
            }
        }
        if (-not $removed) {
            throw 'RUNTIME_OUTPUT_CLEANUP_FAILED'
        }
    }
}

function Stop-P9Run {
    param(
        [Parameter(Mandatory = $true)][string] $Stage,
        [Parameter(Mandatory = $true)][string] $Reason,
        [string] $DetailRef = ''
    )

    try {
        Clear-P9RuntimeOutputs
    }
    catch {
        Write-Host 'P9_RUN_RESULT=ERROR'
        Write-Host 'P9_RUN_STAGE=CISCENJE'
        Write-Host 'P9_RUN_REASON=RUNTIME_OUTPUT_CLEANUP_FAILED'
        Write-Host 'P9_RUN_PATHS_REDACTED=True'
        Write-Host 'P9_RUN_EXIT=1'
        exit 1
    }

    Write-Host 'P9_RUN_RESULT=STOP'
    Write-Host "P9_RUN_STAGE=$Stage"
    Write-Host "P9_RUN_REASON=$Reason"
    if (-not [string]::IsNullOrWhiteSpace($DetailRef)) {
        Write-Host "P9_RUN_DETAIL_REF=$DetailRef"
    }
    Write-Host 'P9_RUN_ARTIFACT_COUNT=0'
    Write-Host 'P9_RUN_PATHS_REDACTED=True'
    Write-Host 'P9_RUN_HUMAN_REVIEW_REQUIRED=True'
    Write-Host 'P9_RUN_EXIT=0'
    exit 0
}

function Fail-P9Run {
    param(
        [Parameter(Mandatory = $true)][string] $Stage,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    try {
        Clear-P9RuntimeOutputs
    }
    catch {
        $Stage = 'CISCENJE'
        $Reason = 'RUNTIME_OUTPUT_CLEANUP_FAILED'
    }

    Write-Host 'P9_RUN_RESULT=ERROR'
    Write-Host "P9_RUN_STAGE=$Stage"
    Write-Host "P9_RUN_REASON=$Reason"
    Write-Host 'P9_RUN_ARTIFACT_COUNT=0'
    Write-Host 'P9_RUN_PATHS_REDACTED=True'
    Write-Host 'P9_RUN_EXIT=1'
    exit 1
}

function Invoke-P9ChildScript {
    param(
        [Parameter(Mandatory = $true)][string] $ScriptPath,
        [string[]] $Arguments = @()
    )

    $output = @(
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath `
            @Arguments 2>&1
    )
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    }
}

function Read-P9Json {
    param([Parameter(Mandatory = $true)][string] $Path)

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Test-P9Identity {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][bool] $IsSubject
    )

    if ($null -eq $Document) {
        return $false
    }
    $metaProperty = $Document.PSObject.Properties['meta']
    if ($null -eq $metaProperty -or $null -eq $metaProperty.Value) {
        return $false
    }
    if ([string]$Document.meta.id_predmeta -ne $PredmetId) {
        return $false
    }

    if ($IsSubject) {
        return (
            [string]$Document.meta.tok -eq $Tok -and
            [string]$Document.meta.verzija -eq $Verzija
        )
    }

    return (
        [string]$Document.meta.tok -eq $Tok -and
        [string]$Document.meta.verzija_toka -eq $Verzija
    )
}

function Test-P9SubjectReady {
    param([Parameter(Mandatory = $true)] $Subject)

    if ([string]$Subject.meta.status -ne 'aktivan') {
        return $false
    }
    if ([string]$Subject.nositelj.oznaka -eq 'LOKALNI_NOSITELJ_NEUNESEN') {
        return $false
    }

    $requiredValues = @(
        [string]$Subject.nositelj.oznaka,
        [string]$Subject.akt.vrsta,
        [string]$Subject.akt.tijelo,
        [string]$Subject.akt.broj,
        [string]$Subject.obrada.cilj,
        [string]$Subject.obrada.pravni_lijek,
        [string]$Subject.sud_naziv
    )
    foreach ($value in $requiredValues) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            return $false
        }
    }

    return $true
}

function Test-P9IntakeReady {
    param([Parameter(Mandatory = $true)] $Intake)

    return (
        -not [string]::IsNullOrWhiteSpace([string]$Intake.cilj) -and
        -not [string]::IsNullOrWhiteSpace([string]$Intake.opis_dogadaja) -and
        @($Intake.osporavanja).Count -gt 0
    )
}

if ($Tok -ne 'TOK_PN_PRIGOVOR' -or $Verzija -ne 'v1') {
    Stop-P9Run `
        -Stage 'ULAZ' `
        -Reason 'TOK_ILI_VERZIJA_NISU_PODRZANI'
}

try {
    $pathContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId $PredmetId `
        -DataRoot $DataRoot
}
catch {
    Stop-P9Run `
        -Stage 'PUTANJA' `
        -Reason 'LOKALNI_KORIJEN_ILI_PREDMET_NISU_SIGURNI'
}
if ($pathContext.Mode -ne 'local') {
    Stop-P9Run -Stage 'PUTANJA' -Reason 'LOKALNI_REZIM_JE_OBAVEZAN'
}

$procedureRef = "postupci/sud/prekrsajni/$Tok/$Verzija/postupak.json"
try {
    $procedureSpec = Resolve-VeritasReference `
        -PathRef $procedureRef `
        -Context $pathContext `
        -ExpectedScope Repository
    $procedure = Read-P9Json -Path $procedureSpec.Path
    if ($null -eq $procedure) {
        throw 'PROCEDURE_INVALID'
    }

    $predmetSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.ulazi.predmet_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $intakeSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.ulazi.intake_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $subsumcijaSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.ulazi.subsumcija_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $auditContextSpec = Resolve-VeritasReference `
        -PathRef (
            'predmeti/sud/prekrsajni/{PREDMET_ID}/audit/audit_v1.json'
        ) `
        -Context $pathContext `
        -ExpectedScope Subject
    $auditSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.ulazi.audit_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $draftSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.izlazi.nacrt_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $manifestSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.izlazi.manifest_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $chainSpec = Resolve-VeritasReference `
        -PathRef ([string]$procedure.izlazi.lanac_skrbnistva_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
}
catch {
    Fail-P9Run -Stage 'PUTANJA' -Reason 'KANONSKE_REFERENCE_NISU_VALJANE'
}

foreach ($spec in @($auditSpec, $draftSpec, $manifestSpec, $chainSpec)) {
    Add-P9RuntimePath -Path $spec.Path
    Add-P9RuntimePath -Path ($spec.Path + '.tmp')
}
try {
    Clear-P9RuntimeOutputs
}
catch {
    Fail-P9Run -Stage 'CISCENJE' -Reason 'RUNTIME_OUTPUT_CLEANUP_FAILED'
}

$hookOutput = @(
    & git -C $repoRoot config --local --get core.hooksPath 2>$null
)
$hookExit = $LASTEXITCODE
$hookPath = ($hookOutput | ForEach-Object { [string]$_ }) -join ''
if ($hookExit -ne 0 -or $hookPath.Replace('\', '/') -ne '.githooks') {
    Stop-P9Run `
        -Stage 'PRIVATNOST' `
        -Reason 'GIT_PRIVACY_HOOK_NIJE_AKTIVAN'
}

$privacyGate = Invoke-P9ChildScript `
    -ScriptPath (Join-Path $PSScriptRoot 'provjeri_privatnost_repozitorija_v1.ps1')
if ($privacyGate.ExitCode -ne 0 -or
    -not $privacyGate.Text.Contains('P9_PRIVACY_GATE_STATUS=OK')) {
    Stop-P9Run `
        -Stage 'PRIVATNOST' `
        -Reason 'REPO_PRIVACY_GATE_NIJE_ZELEN'
}

$requiredInputs = @(
    [pscustomobject]@{
        Name = 'predmet'
        Spec = $predmetSpec
        Schema = 'SCHEMA_PREDMET_PREKRSAJI_V1.json'
    },
    [pscustomobject]@{
        Name = 'intake'
        Spec = $intakeSpec
        Schema = 'SCHEMA_INTAKE_PREKRSAJI_V1.json'
    },
    [pscustomobject]@{
        Name = 'subsumcija'
        Spec = $subsumcijaSpec
        Schema = 'SCHEMA_SUBSUMPCIJA_V1.json'
    }
)

foreach ($inputSpec in $requiredInputs) {
    if (-not (Test-Path -LiteralPath $inputSpec.Spec.Path -PathType Leaf)) {
        Stop-P9Run `
            -Stage 'ULAZI' `
            -Reason 'OBAVEZNI_ULAZ_NEDOSTAJE' `
            -DetailRef $inputSpec.Spec.Ref
    }
}

$schemaValidator = Join-Path $PSScriptRoot 'validiraj_json_po_shemi_v1.ps1'
foreach ($inputSpec in $requiredInputs) {
    if ([string]::IsNullOrWhiteSpace($inputSpec.Schema)) {
        continue
    }
    $schemaPath = Join-Path `
        $repoRoot `
        ('dokumentacija\sheme\' + $inputSpec.Schema)
    $schemaResult = Invoke-P9ChildScript `
        -ScriptPath $schemaValidator `
        -Arguments @(
            '-JsonPutanja', $inputSpec.Spec.Path,
            '-ShemaPutanja', $schemaPath,
            '-OznakaIzlaza', 'P9_LOCAL_INPUT_SCHEMA'
        )
    if ($schemaResult.ExitCode -ne 0) {
        Stop-P9Run `
            -Stage 'ULAZI' `
            -Reason 'OBAVEZNI_ULAZ_NE_PROLAZI_SHEMU' `
            -DetailRef $inputSpec.Spec.Ref
    }
}

$subjectValidation = Invoke-P9ChildScript `
    -ScriptPath (Join-Path $PSScriptRoot 'validiraj_predmet_prekrsaji_v1.ps1') `
    -Arguments @(
        '-PredmetPath', $predmetSpec.Path,
        '-LocalDataRoot', $DataRoot
    )
if ($subjectValidation.ExitCode -ne 0 -or
    -not $subjectValidation.Text.Contains(
        'P9_PREDMET_VALIDATOR_STATUS=VALIDNO'
    )) {
    Stop-P9Run `
        -Stage 'PREDMET' `
        -Reason 'PREDMET_NEPOPUNJEN_ILI_NEVALIDAN'
}

$predmet = Read-P9Json -Path $predmetSpec.Path
$intake = Read-P9Json -Path $intakeSpec.Path
$subsumcija = Read-P9Json -Path $subsumcijaSpec.Path
$auditContext = $null
if (Test-Path -LiteralPath $auditContextSpec.Path -PathType Leaf) {
    $auditContext = Read-P9Json -Path $auditContextSpec.Path
    if ($null -eq $auditContext) {
        Stop-P9Run `
            -Stage 'ULAZI' `
            -Reason 'OPCIONALNI_AUDIT_KONTEKST_NIJE_VALJAN_JSON' `
            -DetailRef $auditContextSpec.Ref
    }
}
if (
    -not (Test-P9Identity -Document $predmet -IsSubject $true) -or
    -not (Test-P9Identity -Document $intake -IsSubject $false) -or
    -not (Test-P9Identity -Document $subsumcija -IsSubject $false)
) {
    Stop-P9Run -Stage 'ULAZI' -Reason 'IDENTITET_ULAZA_NIJE_USKLADEN'
}
if ($null -ne $auditContext -and
    -not (Test-P9Identity -Document $auditContext -IsSubject $false)) {
    Stop-P9Run `
        -Stage 'ULAZI' `
        -Reason 'IDENTITET_AUDIT_KONTEKSTA_NIJE_USKLADEN'
}
if (-not (Test-P9SubjectReady -Subject $predmet) -or
    -not (Test-P9IntakeReady -Intake $intake) -or
    @($subsumcija.elementi_bica).Count -eq 0) {
    Stop-P9Run -Stage 'ULAZI' -Reason 'ULAZI_NISU_SPREMNI_ZA_OBRADU'
}

$commonArguments = @(
    '-PredmetId', $PredmetId,
    '-Tok', $Tok,
    '-Verzija', $Verzija,
    '-DataRoot', $DataRoot
)
$auditResult = Invoke-P9ChildScript `
    -ScriptPath (Join-Path $PSScriptRoot 'generiraj_audit_prekrsaji_v1.ps1') `
    -Arguments $commonArguments
if ($auditResult.ExitCode -ne 0 -or
    -not $auditResult.Text.Contains('GEN_AUDIT_EXIT=0')) {
    Fail-P9Run -Stage 'AUDIT' -Reason 'AUDIT_GENERATOR_NIJE_USPIO'
}

$generatedAudit = Read-P9Json -Path $auditSpec.Path
if ($null -eq $generatedAudit) {
    Fail-P9Run -Stage 'AUDIT' -Reason 'GENERIRANI_AUDIT_NIJE_VALJAN_JSON'
}
if ([bool]$generatedAudit.gate_stanje.blocked) {
    Stop-P9Run -Stage 'AUDIT' -Reason 'AUDIT_JE_BLOKIRAN'
}

$draftResult = Invoke-P9ChildScript `
    -ScriptPath (Join-Path $PSScriptRoot 'run_tok_v1.ps1') `
    -Arguments $commonArguments
if ($draftResult.ExitCode -ne 0) {
    Fail-P9Run -Stage 'NACRT' -Reason 'P7_RUNNER_NIJE_USPIO'
}
if ($draftResult.Text.Contains('RUNNER_RESULT=STOP')) {
    Stop-P9Run -Stage 'NACRT' -Reason 'P7_RUNNER_JE_BLOKIRAN'
}
if (-not $draftResult.Text.Contains('RUNNER_RESULT=OK')) {
    Fail-P9Run -Stage 'NACRT' -Reason 'P7_REZULTAT_NIJE_JEDNOZNACAN'
}

$p8Result = Invoke-P9ChildScript `
    -ScriptPath (
        Join-Path $PSScriptRoot 'generiraj_p8_manifest_i_lanac_v1.ps1'
    ) `
    -Arguments $commonArguments
if ($p8Result.ExitCode -ne 0 -or
    -not $p8Result.Text.Contains('P8_GENERATOR_RESULT=OK')) {
    Fail-P9Run -Stage 'DOKAZNI_PAKET' -Reason 'P8_GENERATOR_NIJE_USPIO'
}

$p8Validation = Invoke-P9ChildScript `
    -ScriptPath (
        Join-Path $PSScriptRoot 'validiraj_p8_manifest_i_lanac_v1.ps1'
    ) `
    -Arguments $commonArguments
if ($p8Validation.ExitCode -ne 0 -or
    -not $p8Validation.Text.Contains('P8_VALIDATOR_RESULT=OK')) {
    Fail-P9Run -Stage 'DOKAZNI_PAKET' -Reason 'P8_VALIDATOR_NIJE_USPIO'
}

foreach ($spec in @($auditSpec, $draftSpec, $manifestSpec, $chainSpec)) {
    if (-not (Test-Path -LiteralPath $spec.Path -PathType Leaf) -or
        (Get-Item -LiteralPath $spec.Path).Length -le 0) {
        Fail-P9Run -Stage 'ZAVRSNA_PROVJERA' -Reason 'IZLAZ_NEDOSTAJE'
    }
    if (-not (
        Test-VeritasPathInsideRoot `
            -Candidate $spec.Path `
            -Root $pathContext.SubjectRoot
    )) {
        Fail-P9Run `
            -Stage 'ZAVRSNA_PROVJERA' `
            -Reason 'IZLAZ_JE_IZVAN_PREDMETA'
    }
}

Write-Host 'P9_RUN_RESULT=OK'
Write-Host 'P9_RUN_STAGE=ZAVRSENO'
Write-Host 'P9_RUN_ARTIFACT_COUNT=4'
Write-Host "P9_RUN_AUDIT_REF=$($auditSpec.Ref)"
Write-Host "P9_RUN_DRAFT_REF=$($draftSpec.Ref)"
Write-Host "P9_RUN_MANIFEST_REF=$($manifestSpec.Ref)"
Write-Host "P9_RUN_CHAIN_REF=$($chainSpec.Ref)"
Write-Host 'P9_RUN_PATHS_REDACTED=True'
Write-Host 'P9_RUN_HUMAN_REVIEW_REQUIRED=True'
Write-Host 'P9_RUN_SIGNED=False'
Write-Host 'P9_RUN_SENT=False'
Write-Host 'P9_RUN_EXIT=0'
exit 0
