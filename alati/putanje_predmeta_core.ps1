#requires -Version 7.0

Set-StrictMode -Version Latest

if ($null -eq (Get-Command Test-VeritasLocalDataRoot -ErrorAction SilentlyContinue)) {
    . (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')
}

function New-VeritasPathContext {
    param(
        [Parameter(Mandatory = $true)][string] $RepoRoot,
        [Parameter(Mandatory = $true)][string] $PredmetId,
        [AllowNull()][string] $DataRoot
    )

    if ($PredmetId -notmatch '^[A-Z0-9_]+$') {
        throw 'PREDMET_ID_FORMAT_INVALID'
    }

    $repoFull = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd('\', '/')
    $isLocal = -not [string]::IsNullOrWhiteSpace($DataRoot)

    if ($isLocal) {
        $rootResult = Test-VeritasLocalDataRoot `
            -LocalDataRoot $DataRoot `
            -RepoRoot $repoFull
        if (-not $rootResult.Valid) {
            throw ($rootResult.Errors -join ',')
        }
        if ($PredmetId -notmatch '^STVARNI_[A-Z0-9_]+$') {
            throw 'LOCAL_SUBJECT_ID_INVALID'
        }

        $dataFull = $rootResult.FullPath.TrimEnd('\', '/')
        $mode = 'local'
    }
    else {
        if ($PredmetId -notmatch '^OGLEDNI_[A-Z0-9_]+$') {
            throw 'PUBLIC_SUBJECT_ID_INVALID'
        }

        $dataFull = $repoFull
        $mode = 'public'
    }

    $subjectRef = "predmeti/sud/prekrsajni/$PredmetId"
    $subjectPath = [System.IO.Path]::GetFullPath(
        (Join-Path $dataFull $subjectRef.Replace('/', '\'))
    )
    if (-not (Test-VeritasPathInsideRoot -Candidate $subjectPath -Root $dataFull)) {
        throw 'SUBJECT_ROOT_OUTSIDE_DATA_ROOT'
    }

    return [pscustomobject]@{
        RepoRoot = $repoFull
        DataRoot = $dataFull
        PredmetId = $PredmetId
        Mode = $mode
        SubjectRef = $subjectRef
        SubjectRoot = $subjectPath
    }
}

function Expand-VeritasSubjectReference {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef,
        [Parameter(Mandatory = $true)] $Context
    )

    if ([string]::IsNullOrWhiteSpace($PathRef) -or $PathRef -match '[\t\r\n]') {
        throw 'REFERENCE_TEXT_INVALID'
    }

    $windowsCandidate = $PathRef.Replace('/', '\')
    if (
        [System.IO.Path]::IsPathRooted($windowsCandidate) -or
        $PathRef.StartsWith('/') -or
        $PathRef.StartsWith('\')
    ) {
        throw 'ABSOLUTE_REFERENCE_FORBIDDEN'
    }

    $expanded = $PathRef.Replace('{PREDMET_ID}', [string]$Context.PredmetId)
    if ($expanded -match '\{[^}]+\}') {
        throw 'UNRESOLVED_REFERENCE_MARKER'
    }

    $normalized = $expanded.Replace('\', '/').Trim()
    if ($normalized.Contains('//')) {
        throw 'REFERENCE_DOUBLE_SEPARATOR'
    }

    $segments = @($normalized -split '/')
    if ($segments.Count -eq 0 -or $segments -contains '' -or
        $segments -contains '.' -or $segments -contains '..') {
        throw 'REFERENCE_TRAVERSAL_FORBIDDEN'
    }

    return $normalized
}

function Resolve-VeritasReference {
    param(
        [Parameter(Mandatory = $true)][string] $PathRef,
        [Parameter(Mandatory = $true)] $Context,
        [ValidateSet('Auto', 'Repository', 'Subject')]
        [string] $ExpectedScope = 'Auto'
    )

    $normalized = Expand-VeritasSubjectReference `
        -PathRef $PathRef `
        -Context $Context
    $subjectPrefix = "$($Context.SubjectRef)/"
    $isSubjectReference = $normalized.StartsWith(
        $subjectPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )

    if (
        $normalized.StartsWith(
            'predmeti/',
            [System.StringComparison]::OrdinalIgnoreCase
        ) -and
        -not $isSubjectReference
    ) {
        throw 'CROSS_SUBJECT_REFERENCE_FORBIDDEN'
    }

    $actualScope = if ($isSubjectReference) { 'Subject' } else { 'Repository' }
    if ($ExpectedScope -ne 'Auto' -and $ExpectedScope -ne $actualScope) {
        throw "REFERENCE_SCOPE_MISMATCH_$ExpectedScope"
    }

    $physicalRoot = if ($actualScope -eq 'Subject') {
        [string]$Context.DataRoot
    }
    else {
        [string]$Context.RepoRoot
    }
    $resolvedPath = [System.IO.Path]::GetFullPath(
        (Join-Path $physicalRoot $normalized.Replace('/', '\'))
    )
    if (-not (
        Test-VeritasPathInsideRoot -Candidate $resolvedPath -Root $physicalRoot
    )) {
        throw "REFERENCE_OUTSIDE_$($actualScope.ToUpperInvariant())_ROOT"
    }

    if ($actualScope -eq 'Subject' -and -not (
        Test-VeritasPathInsideRoot `
            -Candidate $resolvedPath `
            -Root ([string]$Context.SubjectRoot)
    )) {
        throw 'REFERENCE_OUTSIDE_SUBJECT_ROOT'
    }

    return [pscustomobject]@{
        Ref = $normalized
        Path = $resolvedPath
        Scope = $actualScope
        Mode = [string]$Context.Mode
    }
}

function Test-VeritasSubjectPrivacyEnvelope {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)] $Context
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $actualId = [string](
        Get-VeritasNestedValue $Document @('meta', 'id_predmeta')
    )
    if ($actualId -ne [string]$Context.PredmetId) {
        [void]$errors.Add('SUBJECT_ID_MISMATCH')
    }

    $actualType = [string](
        Get-VeritasNestedValue $Document @('meta', 'vrsta')
    )
    $actualMode = [string](
        Get-VeritasNestedValue $Document @('meta', 'rezim_podataka')
    )
    $classification = [string](
        Get-VeritasNestedValue $Document @('privatnost', 'klasifikacija')
    )
    $containsPersonal = Get-VeritasNestedValue `
        $Document `
        @('privatnost', 'sadrzi_osobne_podatke')
    $gitAllowed = Get-VeritasNestedValue `
        $Document `
        @('privatnost', 'dopusteno_git_pracenje')

    $expected = if ($Context.Mode -eq 'local') {
        [pscustomobject]@{
            Type = 'stvarni'
            DataMode = 'lokalni_povjerljivi'
            Classification = 'LOKALNO_POVJERLJIVO'
            ContainsPersonal = $true
            GitAllowed = $false
        }
    }
    else {
        [pscustomobject]@{
            Type = 'sinteticki'
            DataMode = 'javni_sinteticki'
            Classification = 'JAVNO_SINTETICKI'
            ContainsPersonal = $false
            GitAllowed = $true
        }
    }

    if ($actualType -ne $expected.Type) {
        [void]$errors.Add('SUBJECT_TYPE_MODE_MISMATCH')
    }
    if ($actualMode -ne $expected.DataMode) {
        [void]$errors.Add('SUBJECT_DATA_MODE_MISMATCH')
    }
    if ($classification -ne $expected.Classification) {
        [void]$errors.Add('SUBJECT_CLASSIFICATION_MISMATCH')
    }
    if ($containsPersonal -isnot [bool] -or
        [bool]$containsPersonal -ne $expected.ContainsPersonal) {
        [void]$errors.Add('SUBJECT_PERSONAL_DATA_FLAG_MISMATCH')
    }
    if ($gitAllowed -isnot [bool] -or
        [bool]$gitAllowed -ne $expected.GitAllowed) {
        [void]$errors.Add('SUBJECT_GIT_FLAG_MISMATCH')
    }

    return [pscustomobject]@{
        Valid = $errors.Count -eq 0
        Errors = [string[]]$errors.ToArray()
    }
}
