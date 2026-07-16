#requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [string] $PredmetId = "OGLEDNI_PREDMET_0001",

    [Parameter(Mandatory = $false)]
    [string] $Tok = "TOK_PN_PRIGOVOR",

    [Parameter(Mandatory = $false)]
    [string] $Verzija = "v1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

. (Join-Path $PSScriptRoot "p8_dokazni_paket_core.ps1")

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$cleanupPaths = [System.Collections.Generic.List[string]]::new()

function Add-P8ValidationCleanupPath {
    param([string] $Path)

    if (-not [string]::IsNullOrWhiteSpace($Path) -and
        -not $cleanupPaths.Contains($Path)) {
        $cleanupPaths.Add($Path)
    }
}

function Assert-P8Equal {
    param(
        [Parameter(Mandatory = $false)] $Actual,
        [Parameter(Mandatory = $false)] $Expected,
        [Parameter(Mandatory = $true)][string] $Reason
    )

    if ([string]$Actual -cne [string]$Expected) {
        throw $Reason
    }
}

try {
    if ($PredmetId -notmatch "^[A-Z0-9_]+$") {
        throw "PREDMET_ID_FORMAT_INVALID"
    }

    $manifestResolved = Resolve-P8RepoReference `
        -RepoRoot $repoRoot `
        -PathRef "predmeti/sud/prekrsajni/{PREDMET_ID}/manifest.json" `
        -PredmetId $PredmetId
    $chainResolved = Resolve-P8RepoReference `
        -RepoRoot $repoRoot `
        -PathRef (
            "predmeti/sud/prekrsajni/{PREDMET_ID}/" +
            "lanac_skrbnistva.json"
        ) `
        -PredmetId $PredmetId
    Add-P8ValidationCleanupPath -Path $manifestResolved.Path
    Add-P8ValidationCleanupPath -Path $chainResolved.Path
    Add-P8ValidationCleanupPath -Path ($manifestResolved.Path + ".tmp")
    Add-P8ValidationCleanupPath -Path ($chainResolved.Path + ".tmp")

    if ($Tok -ne "TOK_PN_PRIGOVOR" -or $Verzija -ne "v1") {
        throw "P8_TOK_NOT_SUPPORTED"
    }

    $procedureRef = "postupci/sud/prekrsajni/$Tok/$Verzija/postupak.json"
    $procedureResolved = Resolve-P8RepoReference `
        -RepoRoot $repoRoot `
        -PathRef $procedureRef `
        -PredmetId $PredmetId
    $procedure = Read-P8Json -Path $procedureResolved.Path -Name "postupak"
    $expected = Get-P8ExpectedArtifacts `
        -Procedure $procedure `
        -ProcedureRef $procedureResolved.Ref `
        -RepoRoot $repoRoot `
        -PredmetId $PredmetId
    if ($expected.Count -ne 10) {
        throw "P8_ARTIFACT_COUNT_INVALID"
    }

    $manifest = Read-P8Json -Path $manifestResolved.Path -Name "manifest"
    $chain = Read-P8Json -Path $chainResolved.Path -Name "lanac skrbništva"

    $schemaValidator = Join-Path $PSScriptRoot "validiraj_json_po_shemi_v1.ps1"
    $schemaChecks = @(
        [pscustomobject]@{
            Json = $manifestResolved.Path
            Schema = Join-Path $repoRoot (
                "dokumentacija\sheme\SCHEMA_MANIFEST_PREKRSAJI_V1.json"
            )
            Marker = "P8_MANIFEST_SCHEMA"
        },
        [pscustomobject]@{
            Json = $chainResolved.Path
            Schema = Join-Path $repoRoot (
                "dokumentacija\sheme\" +
                "SCHEMA_LANAC_SKRBNISTVA_PREKRSAJI_V1.json"
            )
            Marker = "P8_CHAIN_SCHEMA"
        }
    )
    foreach ($check in $schemaChecks) {
        $schemaOutput = @(
            pwsh -NoProfile -ExecutionPolicy Bypass -File $schemaValidator `
                -JsonPutanja $check.Json `
                -ShemaPutanja $check.Schema `
                -OznakaIzlaza $check.Marker 2>&1
        )
        if ($LASTEXITCODE -ne 0) {
            throw "$($check.Marker)_FAILED"
        }
    }

    $timestampPattern = (
        "^[0-9]{2}[.][0-9]{2}[.][0-9]{4}[.] " +
        "[0-9]{2}:[0-9]{2}:[0-9]{2} [+-][0-9]{2}:[0-9]{2}$"
    )
    Assert-P8Equal $manifest.meta.standard_id "MANIFEST_PREKRSAJI_V1" (
        "P8_MANIFEST_STANDARD_ID_MISMATCH"
    )
    Assert-P8Equal $manifest.meta.id_predmeta $PredmetId (
        "P8_MANIFEST_SUBJECT_MISMATCH"
    )
    Assert-P8Equal $manifest.meta.tok $Tok "P8_MANIFEST_TOK_MISMATCH"
    Assert-P8Equal $manifest.meta.verzija_toka $Verzija (
        "P8_MANIFEST_VERSION_MISMATCH"
    )
    Assert-P8Equal $manifest.meta.vrsta_predmeta "sinteticki" (
        "P8_MANIFEST_SUBJECT_TYPE_MISMATCH"
    )
    Assert-P8Equal $manifest.meta.algoritam_sazetka "SHA-256" (
        "P8_MANIFEST_HASH_ALGORITHM_MISMATCH"
    )
    Assert-P8Equal $manifest.meta.status "P8_PROLAZ" (
        "P8_MANIFEST_STATUS_MISMATCH"
    )
    if ([string]$manifest.meta.datum_vrijeme_izrade -notmatch $timestampPattern) {
        throw "P8_MANIFEST_TIMESTAMP_INVALID"
    }

    $actualArtifacts = @($manifest.artefakti)
    if ($actualArtifacts.Count -ne $expected.Count) {
        throw "P8_MANIFEST_ARTIFACT_COUNT_MISMATCH"
    }
    for ($index = 0; $index -lt $expected.Count; $index++) {
        $actual = $actualArtifacts[$index]
        $spec = $expected[$index]
        Assert-P8Equal $actual.redni_broj ($index + 1) (
            "P8_ARTIFACT_ORDER_MISMATCH=$($spec.Id)"
        )
        Assert-P8Equal $actual.id $spec.Id "P8_ARTIFACT_ID_MISMATCH=$($spec.Id)"
        Assert-P8Equal $actual.uloga $spec.Role (
            "P8_ARTIFACT_ROLE_MISMATCH=$($spec.Id)"
        )
        Assert-P8Equal $actual.putanja $spec.Ref (
            "P8_ARTIFACT_REF_MISMATCH=$($spec.Id)"
        )
        if (-not (Test-Path -LiteralPath $spec.Path -PathType Leaf)) {
            throw "P8_ARTIFACT_MISSING=$($spec.Ref)"
        }
        $expectedSize = [int64](Get-Item -LiteralPath $spec.Path).Length
        Assert-P8Equal $actual.velicina_bajtova $expectedSize (
            "P8_ARTIFACT_SIZE_MISMATCH=$($spec.Id)"
        )
        $expectedHash = Get-P8Sha256File -Path $spec.Path
        Assert-P8Equal $actual.sha256 $expectedHash (
            "P8_ARTIFACT_HASH_MISMATCH=$($spec.Id)"
        )
        if ([string]$actual.sha256 -notmatch "^[A-F0-9]{64}$") {
            throw "P8_ARTIFACT_HASH_FORMAT_INVALID=$($spec.Id)"
        }
    }

    Assert-P8Equal $manifest.korijenski_sazetak.algoritam "SHA-256" (
        "P8_ROOT_HASH_ALGORITHM_MISMATCH"
    )
    Assert-P8Equal `
        $manifest.korijenski_sazetak.kanonski_format `
        "P8_ARTEFAKTI_TSV_LF_V1" `
        "P8_ROOT_CANONICAL_FORMAT_MISMATCH"
    $rootHash = Get-P8Sha256Text -Text (
        Get-P8ArtifactCanonicalText -Artifacts $actualArtifacts
    )
    Assert-P8Equal $manifest.korijenski_sazetak.sha256 $rootHash (
        "P8_ROOT_HASH_MISMATCH"
    )

    Assert-P8Equal `
        $chain.meta.standard_id `
        "LANAC_SKRBNISTVA_PREKRSAJI_V1" `
        "P8_CHAIN_STANDARD_ID_MISMATCH"
    Assert-P8Equal $chain.meta.id_predmeta $PredmetId (
        "P8_CHAIN_SUBJECT_MISMATCH"
    )
    Assert-P8Equal $chain.meta.tok $Tok "P8_CHAIN_TOK_MISMATCH"
    Assert-P8Equal $chain.meta.verzija_toka $Verzija (
        "P8_CHAIN_VERSION_MISMATCH"
    )
    Assert-P8Equal $chain.meta.algoritam_sazetka "SHA-256" (
        "P8_CHAIN_HASH_ALGORITHM_MISMATCH"
    )
    Assert-P8Equal $chain.meta.status "P8_PROLAZ" (
        "P8_CHAIN_STATUS_MISMATCH"
    )
    Assert-P8Equal `
        $chain.meta.datum_vrijeme_izrade `
        $manifest.meta.datum_vrijeme_izrade `
        "P8_PACKAGE_TIMESTAMP_MISMATCH"

    $manifestHash = Get-P8Sha256File -Path $manifestResolved.Path
    Assert-P8Equal $chain.manifest.putanja $manifestResolved.Ref (
        "P8_CHAIN_MANIFEST_REF_MISMATCH"
    )
    Assert-P8Equal $chain.manifest.sha256 $manifestHash (
        "P8_CHAIN_MANIFEST_HASH_MISMATCH"
    )
    Assert-P8Equal $chain.manifest.broj_artefakata $expected.Count (
        "P8_CHAIN_ARTIFACT_COUNT_MISMATCH"
    )
    Assert-P8Equal $chain.manifest.korijenski_sha256 $rootHash (
        "P8_CHAIN_ROOT_HASH_MISMATCH"
    )

    $events = @($chain.dogadaji)
    if ($events.Count -ne 2) {
        throw "P8_CHAIN_EVENT_COUNT_MISMATCH"
    }
    $expectedActions = @("ULAZI_PROVJERENI", "MANIFEST_ZAPISAN")
    $expectedProofs = @($rootHash, $manifestHash)
    $expectedDetails = @(
        "Provjereno 10 artefakata P7 lanca.",
        "Manifest zapisan i vezan uz lanac skrbništva."
    )
    $previousHash = "0" * 64
    for ($index = 0; $index -lt $events.Count; $index++) {
        $event = $events[$index]
        Assert-P8Equal $event.redni_broj ($index + 1) (
            "P8_EVENT_ORDER_MISMATCH"
        )
        Assert-P8Equal $event.id ("P8-{0:D3}" -f ($index + 1)) (
            "P8_EVENT_ID_MISMATCH"
        )
        Assert-P8Equal `
            $event.datum_vrijeme `
            $chain.meta.datum_vrijeme_izrade `
            "P8_EVENT_TIMESTAMP_MISMATCH"
        Assert-P8Equal $event.izvrsitelj "veritas_h77" (
            "P8_EVENT_ACTOR_MISMATCH"
        )
        Assert-P8Equal $event.radnja $expectedActions[$index] (
            "P8_EVENT_ACTION_MISMATCH"
        )
        Assert-P8Equal $event.detalj $expectedDetails[$index] (
            "P8_EVENT_DETAIL_MISMATCH"
        )
        Assert-P8Equal $event.dokaz_sha256 $expectedProofs[$index] (
            "P8_EVENT_PROOF_MISMATCH"
        )
        Assert-P8Equal $event.prethodni_dogadaj_sha256 $previousHash (
            "P8_EVENT_PREVIOUS_HASH_MISMATCH"
        )
        $eventHash = Get-P8Sha256Text -Text (
            Get-P8EventCanonicalText -Event $event
        )
        Assert-P8Equal $event.dogadaj_sha256 $eventHash (
            "P8_EVENT_HASH_MISMATCH"
        )
        $previousHash = $eventHash
    }
    Assert-P8Equal $chain.zavrsni_dogadaj_sha256 $previousHash (
        "P8_CHAIN_FINAL_HASH_MISMATCH"
    )

    Write-Host "P8_VALIDATOR_ARTIFACTS=$($actualArtifacts.Count)"
    Write-Host "P8_VALIDATOR_EVENTS=$($events.Count)"
    Write-Host "P8_VALIDATOR_RESULT=OK"
    exit 0
}
catch {
    Remove-P8PackageFiles -Paths @($cleanupPaths)
    Write-Host "P8_VALIDATOR_RESULT=STOP"
    Write-Host "STOP_REASON=$($_.Exception.Message)"
    exit 1
}

