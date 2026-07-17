#requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [string] $PredmetId = "OGLEDNI_PREDMET_0001",

    [Parameter(Mandatory = $false)]
    [string] $Tok = "TOK_PN_PRIGOVOR",

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string] $DataRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

. (Join-Path $PSScriptRoot "p8_dokazni_paket_core.ps1")

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$cleanupPaths = [System.Collections.Generic.List[string]]::new()
$pathContext = $null

function Add-P8CleanupPath {
    param([string] $Path)

    if (-not [string]::IsNullOrWhiteSpace($Path) -and
        -not $cleanupPaths.Contains($Path)) {
        $cleanupPaths.Add($Path)
    }
}

try {
    if ($PredmetId -notmatch "^[A-Z0-9_]+$") {
        throw "PREDMET_ID_FORMAT_INVALID"
    }

    $pathContext = New-VeritasPathContext `
        -RepoRoot $repoRoot `
        -PredmetId $PredmetId `
        -DataRoot $DataRoot
    $fallbackManifest = Resolve-P8Reference `
        -PathRef "predmeti/sud/prekrsajni/{PREDMET_ID}/manifest.json" `
        -Context $pathContext `
        -ExpectedScope Subject
    $fallbackChain = Resolve-P8Reference `
        -PathRef (
            "predmeti/sud/prekrsajni/{PREDMET_ID}/" +
            "lanac_skrbnistva.json"
        ) `
        -Context $pathContext `
        -ExpectedScope Subject
    Add-P8CleanupPath -Path $fallbackManifest.Path
    Add-P8CleanupPath -Path $fallbackChain.Path
    Add-P8CleanupPath -Path ($fallbackManifest.Path + ".tmp")
    Add-P8CleanupPath -Path ($fallbackChain.Path + ".tmp")
    Remove-P8PackageFiles -Paths @($cleanupPaths)

    if ($Tok -ne "TOK_PN_PRIGOVOR" -or $Verzija -ne "v1") {
        throw "P8_TOK_NOT_SUPPORTED"
    }

    $procedureRef = "postupci/sud/prekrsajni/$Tok/$Verzija/postupak.json"
    $procedureResolved = Resolve-P8Reference `
        -PathRef $procedureRef `
        -Context $pathContext `
        -ExpectedScope Repository
    $procedure = Read-P8Json `
        -Path $procedureResolved.Path `
        -Name "postupak" `
        -Reference $procedureResolved.Ref

    if ([string]$procedure.meta.id -ne "${Tok}_${Verzija}" -or
        [string]$procedure.meta.verzija -ne $Verzija) {
        throw "POSTUPAK_IDENTITY_MISMATCH"
    }
    foreach ($outputName in @("manifest_ref", "lanac_skrbnistva_ref")) {
        if ($null -eq $procedure.izlazi.PSObject.Properties[$outputName]) {
            throw "POSTUPAK_OUTPUT_REF_MISSING=$outputName"
        }
    }

    $manifestResolved = Resolve-P8Reference `
        -PathRef ([string]$procedure.izlazi.manifest_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    $chainResolved = Resolve-P8Reference `
        -PathRef ([string]$procedure.izlazi.lanac_skrbnistva_ref) `
        -Context $pathContext `
        -ExpectedScope Subject
    if ($manifestResolved.Ref -ne $fallbackManifest.Ref -or
        $chainResolved.Ref -ne $fallbackChain.Ref) {
        throw "P8_OUTPUT_REF_NOT_CANONICAL"
    }

    $expected = Get-P8ExpectedArtifacts `
        -Procedure $procedure `
        -ProcedureRef $procedureResolved.Ref `
        -Context $pathContext
    if ($expected.Count -ne 10) {
        throw "P8_ARTIFACT_COUNT_INVALID=$($expected.Count)"
    }
    foreach ($spec in $expected) {
        if (-not (Test-Path -LiteralPath $spec.Path -PathType Leaf)) {
            throw "P8_ARTIFACT_MISSING=$($spec.Ref)"
        }
        if ((Get-Item -LiteralPath $spec.Path).Length -le 0) {
            throw "P8_ARTIFACT_EMPTY=$($spec.Ref)"
        }
    }

    $byId = @{}
    foreach ($spec in $expected) {
        $byId[$spec.Id] = $spec
    }
    $predmet = Read-P8Json `
        -Path $byId.predmet.Path -Name "predmet" `
        -Reference $byId.predmet.Ref
    $intake = Read-P8Json `
        -Path $byId.intake.Path -Name "intake" `
        -Reference $byId.intake.Ref
    $subsumcija = Read-P8Json `
        -Path $byId.subsumcija.Path -Name "subsumcija" `
        -Reference $byId.subsumcija.Ref
    $audit = Read-P8Json `
        -Path $byId.audit_generated.Path -Name "audit" `
        -Reference $byId.audit_generated.Ref
    $predlozak = Read-P8Json `
        -Path $byId.predlozak.Path -Name "predložak" `
        -Reference $byId.predlozak.Ref

    Assert-P8DocumentIdentity `
        -Document $predmet -Name "predmet" -PredmetId $PredmetId `
        -Tok $Tok -Verzija $Verzija
    Assert-P8DocumentIdentity `
        -Document $intake -Name "intake" -PredmetId $PredmetId `
        -Tok $Tok -Verzija $Verzija
    Assert-P8DocumentIdentity `
        -Document $subsumcija -Name "subsumcija" -PredmetId $PredmetId `
        -Tok $Tok -Verzija $Verzija
    Assert-P8DocumentIdentity `
        -Document $audit -Name "audit" -PredmetId $PredmetId `
        -Tok $Tok -Verzija $Verzija

    $predmetProfile = Test-VeritasSubjectPrivacyEnvelope `
        -Document $predmet `
        -Context $pathContext
    if (-not $predmetProfile.Valid) {
        throw (
            "P8_SUBJECT_PRIVACY_PROFILE_INVALID=" +
            ($predmetProfile.Errors -join ',')
        )
    }
    if ([string]$predmet.meta.verzija -ne "v1") {
        throw "P8_REQUIRES_SUBJECT_VERSION_V1"
    }
    if ([bool]$audit.gate_stanje.blocked) {
        throw "P8_AUDIT_BLOCKED"
    }
    if ([string]$predlozak.meta.id_predloska -ne "prigovor_pn_v1") {
        throw "P8_TEMPLATE_IDENTITY_MISMATCH"
    }

    $auditNormRefs = @(
        $audit.nalazi |
            Where-Object { [string]$_.kod -eq "NORMA-SIDRO" } |
            ForEach-Object { [string]$_.norma_ref }
    )
    foreach ($normaSpec in @($expected | Where-Object { $_.Role -eq "NORMA" })) {
        $norma = Read-P8Json `
            -Path $normaSpec.Path `
            -Name "norma" `
            -Reference $normaSpec.Ref
        if ([string]$norma.izvori.status_sidra -ne "puno") {
            throw "P8_NORMA_SIDRO_NOT_FULL=$($normaSpec.Ref)"
        }
        if ($auditNormRefs -notcontains $normaSpec.Ref) {
            throw "P8_AUDIT_NORMA_REF_MISSING=$($normaSpec.Ref)"
        }
    }

    $draftValidator = Join-Path $PSScriptRoot (
        "validiraj_izlaz_tok_pn_prigovor_v1.ps1"
    )
    $draftOutput = @(
        pwsh -NoProfile -ExecutionPolicy Bypass -File $draftValidator `
            -OutputPath $byId.nacrt.Path 2>&1
    )
    if ($LASTEXITCODE -ne 0) {
        throw "P8_P7_DRAFT_VALIDATION_FAILED"
    }

    $draftRaw = Get-Content -LiteralPath $byId.nacrt.Path -Raw -Encoding UTF8
    $draftChecks = [ordered]@{
        "TOK" = $Tok
        "PREDMET_ID" = $PredmetId
        "PREDMET_REF" = $byId.predmet.Ref
        "AUDIT_REF" = $byId.audit_generated.Ref
        "PREDLOZAK_REF" = $byId.predlozak.Ref
    }
    foreach ($entry in $draftChecks.GetEnumerator()) {
        $match = [regex]::Match(
            $draftRaw,
            "(?m)^" + [regex]::Escape($entry.Key) + "=(.+)$"
        )
        if (-not $match.Success -or
            $match.Groups[1].Value.Trim() -ne [string]$entry.Value) {
            throw "P8_DRAFT_IDENTITY_MISMATCH=$($entry.Key)"
        }
    }

    $artifacts = [System.Collections.Generic.List[object]]::new()
    $redniBroj = 0
    foreach ($spec in $expected) {
        $redniBroj++
        $artifacts.Add([ordered]@{
                redni_broj = $redniBroj
                id = $spec.Id
                uloga = $spec.Role
                putanja = $spec.Ref
                sha256 = Get-P8Sha256File -Path $spec.Path
                velicina_bajtova = [int64](Get-Item -LiteralPath $spec.Path).Length
            })
    }

    $timestamp = Get-P8Timestamp
    $rootHash = Get-P8Sha256Text -Text (
        Get-P8ArtifactCanonicalText -Artifacts @($artifacts)
    )
    $manifest = [ordered]@{
        meta = [ordered]@{
            standard_id = "MANIFEST_PREKRSAJI_V1"
            id_predmeta = $PredmetId
            tok = $Tok
            verzija_toka = $Verzija
            vrsta_predmeta = [string]$predmet.meta.vrsta
            datum_vrijeme_izrade = $timestamp
            algoritam_sazetka = "SHA-256"
            status = "P8_PROLAZ"
        }
        artefakti = @($artifacts)
        korijenski_sazetak = [ordered]@{
            algoritam = "SHA-256"
            kanonski_format = "P8_ARTEFAKTI_TSV_LF_V1"
            sha256 = $rootHash
        }
    }

    $manifestTemp = $manifestResolved.Path + ".tmp"
    $chainTemp = $chainResolved.Path + ".tmp"
    Write-P8JsonAtomic `
        -Document $manifest `
        -TargetPath $manifestResolved.Path `
        -TemporaryPath $manifestTemp
    $manifestHash = Get-P8Sha256File -Path $manifestResolved.Path

    $zeroHash = "0" * 64
    $event1 = [ordered]@{
        redni_broj = 1
        id = "P8-001"
        datum_vrijeme = $timestamp
        izvrsitelj = "veritas_h77"
        radnja = "ULAZI_PROVJERENI"
        detalj = "Provjereno 10 artefakata P7 lanca."
        dokaz_sha256 = $rootHash
        prethodni_dogadaj_sha256 = $zeroHash
        dogadaj_sha256 = ""
    }
    $event1.dogadaj_sha256 = Get-P8Sha256Text -Text (
        Get-P8EventCanonicalText -Event $event1
    )
    $event2 = [ordered]@{
        redni_broj = 2
        id = "P8-002"
        datum_vrijeme = $timestamp
        izvrsitelj = "veritas_h77"
        radnja = "MANIFEST_ZAPISAN"
        detalj = "Manifest zapisan i vezan uz lanac skrbništva."
        dokaz_sha256 = $manifestHash
        prethodni_dogadaj_sha256 = $event1.dogadaj_sha256
        dogadaj_sha256 = ""
    }
    $event2.dogadaj_sha256 = Get-P8Sha256Text -Text (
        Get-P8EventCanonicalText -Event $event2
    )

    $chain = [ordered]@{
        meta = [ordered]@{
            standard_id = "LANAC_SKRBNISTVA_PREKRSAJI_V1"
            id_predmeta = $PredmetId
            tok = $Tok
            verzija_toka = $Verzija
            datum_vrijeme_izrade = $timestamp
            algoritam_sazetka = "SHA-256"
            status = "P8_PROLAZ"
        }
        manifest = [ordered]@{
            putanja = $manifestResolved.Ref
            sha256 = $manifestHash
            broj_artefakata = $artifacts.Count
            korijenski_sha256 = $rootHash
        }
        dogadaji = @($event1, $event2)
        zavrsni_dogadaj_sha256 = $event2.dogadaj_sha256
    }
    Write-P8JsonAtomic `
        -Document $chain `
        -TargetPath $chainResolved.Path `
        -TemporaryPath $chainTemp

    $validator = Join-Path $PSScriptRoot (
        "validiraj_p8_manifest_i_lanac_v1.ps1"
    )
    $validatorArgs = @(
        "-PredmetId", $PredmetId,
        "-Tok", $Tok,
        "-Verzija", $Verzija
    )
    if ($pathContext.Mode -eq 'local') {
        $validatorArgs += @("-DataRoot", $DataRoot)
    }
    $validatorOutput = @(
        pwsh -NoProfile -ExecutionPolicy Bypass -File $validator `
            @validatorArgs 2>&1
    )
    foreach ($line in $validatorOutput) {
        Write-Host ([string]$line)
    }
    if ($LASTEXITCODE -ne 0) {
        throw "P8_FINAL_VALIDATION_FAILED"
    }

    Write-Host "P8_GENERATOR_ARTIFACTS=$($artifacts.Count)"
    Write-Host "P8_MANIFEST_REF=$($manifestResolved.Ref)"
    Write-Host "P8_CHAIN_REF=$($chainResolved.Ref)"
    if ($pathContext.Mode -eq 'public') {
        Write-Host "P8_MANIFEST_PATH=$($manifestResolved.Path)"
        Write-Host "P8_CHAIN_PATH=$($chainResolved.Path)"
    }
    else {
        Write-Host "P8_LOCAL_PATHS_REDACTED=True"
    }
    Write-Host "P8_GENERATOR_RESULT=OK"
    exit 0
}
catch {
    Remove-P8PackageFiles -Paths @($cleanupPaths)
    Write-Host "P8_GENERATOR_RESULT=STOP"
    Write-Host "STOP_REASON=$(Get-P8SafeErrorDetail `
        -Message $_.Exception.Message `
        -Context $pathContext)"
    exit 1
}
