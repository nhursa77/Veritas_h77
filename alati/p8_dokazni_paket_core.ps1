#requires -Version 7.0

Set-StrictMode -Version Latest

if ($null -eq (Get-Command Resolve-VeritasReference -ErrorAction SilentlyContinue)) {
    . (Join-Path $PSScriptRoot 'putanje_predmeta_core.ps1')
}

function Get-P8Sha256Text {
    param(
        [Parameter(Mandatory = $true)][string] $Text
    )

    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $bytes = $utf8.GetBytes($Text)
    $hashBytes = [System.Security.Cryptography.SHA256]::HashData($bytes)
    return [Convert]::ToHexString($hashBytes)
}

function Get-P8Sha256File {
    param(
        [Parameter(Mandatory = $true)][string] $Path
    )

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Assert-P8SafeText {
    param(
        [Parameter(Mandatory = $true)][string] $Value,
        [Parameter(Mandatory = $true)][string] $Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name je prazno"
    }
    if ($Value -match "[\t\r\n]") {
        throw "$Name sadrži nedopušteni kontrolni znak"
    }
}

function Resolve-P8Reference {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef,
        [Parameter(Mandatory = $true)] $Context,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Repository', 'Subject')]
        [string] $ExpectedScope
    )

    Assert-P8SafeText -Value $PathRef -Name "putanja"
    return Resolve-VeritasReference `
        -PathRef $PathRef `
        -Context $Context `
        -ExpectedScope $ExpectedScope
}

function Read-P8Json {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $Reference
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Nedostaje ${Name}: $Reference"
    }
    if ((Get-Item -LiteralPath $Path).Length -le 0) {
        throw "$Name je prazan: $Reference"
    }

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 |
            ConvertFrom-Json
    }
    catch {
        throw "$Name nije valjan JSON: $Reference"
    }
}

function Get-P8SafeErrorDetail {
    param(
        [Parameter(Mandatory = $true)][string] $Message,
        [Parameter(Mandatory = $false)] $Context
    )

    if ($null -eq $Context -or $Context.Mode -ne 'local') {
        return $Message
    }

    $safe = $Message
    foreach ($sensitivePath in @(
            [string]$Context.SubjectRoot,
            [string]$Context.DataRoot
        )) {
        if (-not [string]::IsNullOrWhiteSpace($sensitivePath)) {
            $safe = [regex]::Replace(
                $safe,
                [regex]::Escape($sensitivePath),
                '[LOCAL_PATH_REDACTED]',
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            )
        }
    }

    return $safe
}

function Write-P8JsonAtomic {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][string] $TargetPath,
        [Parameter(Mandatory = $true)][string] $TemporaryPath
    )

    $targetDirectory = Split-Path -Path $TargetPath -Parent
    if (-not (Test-Path -LiteralPath $targetDirectory -PathType Container)) {
        throw "Nedostaje ciljna mapa: $targetDirectory"
    }

    if (Test-Path -LiteralPath $TemporaryPath) {
        Remove-Item -LiteralPath $TemporaryPath -Force
    }

    $json = $Document | ConvertTo-Json -Depth 100
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($TemporaryPath, $json + "`n", $utf8)
    Move-Item -LiteralPath $TemporaryPath -Destination $TargetPath -Force
}

function Remove-P8PackageFiles {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()]
        [string[]] $Paths
    )

    foreach ($path in @($Paths)) {
        if (-not [string]::IsNullOrWhiteSpace($path) -and
            (Test-Path -LiteralPath $path)) {
            Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-P8Timestamp {
    return [DateTimeOffset]::Now.ToString("dd.MM.yyyy. HH:mm:ss zzz")
}

function Get-P8ArtifactCanonicalText {
    param(
        [Parameter(Mandatory = $true)][array] $Artifacts
    )

    $builder = [System.Text.StringBuilder]::new()
    foreach ($artifact in $Artifacts) {
        Assert-P8SafeText -Value ([string]$artifact.id) -Name "artefakt.id"
        Assert-P8SafeText -Value ([string]$artifact.uloga) -Name "artefakt.uloga"
        Assert-P8SafeText -Value ([string]$artifact.putanja) -Name "artefakt.putanja"
        $line = @(
            [string]$artifact.redni_broj,
            [string]$artifact.id,
            [string]$artifact.uloga,
            [string]$artifact.putanja,
            [string]$artifact.sha256,
            [string]$artifact.velicina_bajtova
        ) -join "`t"
        [void]$builder.Append($line).Append("`n")
    }

    return $builder.ToString()
}

function Get-P8EventCanonicalText {
    param(
        [Parameter(Mandatory = $true)] $Event
    )

    foreach ($field in @(
            "id",
            "datum_vrijeme",
            "izvrsitelj",
            "radnja",
            "detalj",
            "dokaz_sha256",
            "prethodni_dogadaj_sha256"
        )) {
        Assert-P8SafeText -Value ([string]$Event.$field) -Name "dogadaj.$field"
    }

    return (@(
            [string]$Event.redni_broj,
            [string]$Event.id,
            [string]$Event.datum_vrijeme,
            [string]$Event.izvrsitelj,
            [string]$Event.radnja,
            [string]$Event.detalj,
            [string]$Event.dokaz_sha256,
            [string]$Event.prethodni_dogadaj_sha256
        ) -join "`t") + "`n"
}

function Get-P8ExpectedArtifacts {
    param(
        [Parameter(Mandatory = $true)] $Procedure,
        [Parameter(Mandatory = $true)][string] $ProcedureRef,
        [Parameter(Mandatory = $true)] $Subsumcija,
        [Parameter(Mandatory = $true)] $Context
    )

    $requiredInputRefs = @(
        "predmet_ref",
        "intake_ref",
        "subsumcija_ref",
        "audit_ref",
        "predlozak_ref",
        "norma_refs"
    )
    foreach ($name in $requiredInputRefs) {
        if ($null -eq $Procedure.ulazi.PSObject.Properties[$name]) {
            throw "Postupak nema ulaznu referencu: $name"
        }
    }
    if ($null -eq $Procedure.izlazi.PSObject.Properties["nacrt_ref"]) {
        throw "Postupak nema izlaznu referencu: nacrt_ref"
    }

    $specs = [System.Collections.Generic.List[object]]::new()
    $specs.Add([pscustomobject]@{
            Id = "predmet"
            Role = "PREDMET"
            Ref = [string]$Procedure.ulazi.predmet_ref
            Scope = "Subject"
        })
    $specs.Add([pscustomobject]@{
            Id = "intake"
            Role = "INTAKE"
            Ref = [string]$Procedure.ulazi.intake_ref
            Scope = "Subject"
        })
    $specs.Add([pscustomobject]@{
            Id = "subsumcija"
            Role = "SUBSUMPCIJA"
            Ref = [string]$Procedure.ulazi.subsumcija_ref
            Scope = "Subject"
        })

    $seenEvidenceRefs = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    $evidenceIndex = 0
    foreach ($element in @($Subsumcija.elementi_bica)) {
        $evidenceRef = [string]$element.dokaz_ref
        if ([string]::IsNullOrWhiteSpace($evidenceRef)) {
            continue
        }

        $expandedEvidenceRef = Expand-VeritasSubjectReference `
            -PathRef $evidenceRef `
            -Context $Context
        $evidencePrefix = "$($Context.SubjectRef)/dokazi/"
        if (-not $expandedEvidenceRef.StartsWith(
                $evidencePrefix,
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or $expandedEvidenceRef.Length -le $evidencePrefix.Length) {
            throw "P8_DOKAZ_REF_NOT_CANONICAL=$expandedEvidenceRef"
        }
        if (-not $seenEvidenceRefs.Add($expandedEvidenceRef)) {
            continue
        }

        $evidenceIndex++
        $specs.Add([pscustomobject]@{
                Id = "dokaz_{0:D3}" -f $evidenceIndex
                Role = "DOKAZ"
                Ref = $expandedEvidenceRef
                Scope = "Subject"
            })
    }

    $specs.Add([pscustomobject]@{
            Id = "audit_generated"
            Role = "AUDIT_GENERATED"
            Ref = [string]$Procedure.ulazi.audit_ref
            Scope = "Subject"
        })
    $specs.Add([pscustomobject]@{
            Id = "postupak"
            Role = "POSTUPAK"
            Ref = $ProcedureRef
            Scope = "Repository"
        })
    $specs.Add([pscustomobject]@{
            Id = "predlozak"
            Role = "PREDLOZAK"
            Ref = [string]$Procedure.ulazi.predlozak_ref
            Scope = "Repository"
        })

    $normaRefs = @($Procedure.ulazi.norma_refs)
    if ($normaRefs.Count -eq 0) {
        throw "Postupak nema pravna sidra za P8"
    }
    for ($index = 0; $index -lt $normaRefs.Count; $index++) {
        $specs.Add([pscustomobject]@{
                Id = "norma_{0:D3}" -f ($index + 1)
                Role = "NORMA"
                Ref = [string]$normaRefs[$index]
                Scope = "Repository"
            })
    }

    $specs.Add([pscustomobject]@{
            Id = "nacrt"
            Role = "NACRT"
            Ref = [string]$Procedure.izlazi.nacrt_ref
            Scope = "Subject"
        })

    $resolvedSpecs = [System.Collections.Generic.List[object]]::new()
    $seenRefs = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($spec in $specs) {
        $resolved = Resolve-P8Reference `
            -PathRef $spec.Ref `
            -Context $Context `
            -ExpectedScope $spec.Scope
        if (-not $seenRefs.Add($resolved.Ref)) {
            throw "Dvostruka referenca artefakta: $($resolved.Ref)"
        }
        $resolvedSpecs.Add([pscustomobject]@{
                Id = $spec.Id
                Role = $spec.Role
                Ref = $resolved.Ref
                Path = $resolved.Path
            })
    }

    return @($resolvedSpecs)
}

function Assert-P8DocumentIdentity {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $PredmetId,
        [Parameter(Mandatory = $true)][string] $Tok,
        [Parameter(Mandatory = $true)][string] $Verzija
    )

    if ($null -eq $Document.PSObject.Properties["meta"] -or
        $null -eq $Document.meta) {
        throw "$Name nema meta blok"
    }
    if ([string]$Document.meta.id_predmeta -ne $PredmetId) {
        throw "$Name ima pogrešan id_predmeta"
    }
    if ($Name -eq "predmet") {
        return
    }
    if ([string]$Document.meta.tok -ne $Tok) {
        throw "$Name ima pogrešan tok"
    }
    if ([string]$Document.meta.verzija_toka -ne $Verzija) {
        throw "$Name ima pogrešnu verziju toka"
    }
}
