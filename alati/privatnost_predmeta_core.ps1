#requires -Version 7.0

Set-StrictMode -Version Latest

function Test-VeritasPropertyExists {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)][string] $Name
    )

    if ($null -eq $Object) {
        return $false
    }

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Get-VeritasPropertyValue {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)][string] $Name
    )

    if (-not (Test-VeritasPropertyExists -Object $Object -Name $Name)) {
        return $null
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Get-VeritasNestedValue {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)][string[]] $Path
    )

    $current = $Object
    foreach ($name in $Path) {
        if (-not (Test-VeritasPropertyExists -Object $current -Name $name)) {
            return $null
        }

        $current = Get-VeritasPropertyValue -Object $current -Name $name
    }

    return $current
}

function Test-VeritasNestedPropertyExists {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)][string[]] $Path
    )

    $current = $Object
    foreach ($name in $Path) {
        if (-not (Test-VeritasPropertyExists -Object $current -Name $name)) {
            return $false
        }

        $current = Get-VeritasPropertyValue -Object $current -Name $name
    }

    return $true
}

function Test-VeritasValidOib {
    param([AllowNull()][string] $Value)

    if ($Value -notmatch '^[0-9]{11}$') {
        return $false
    }

    $a = 10
    for ($index = 0; $index -lt 10; $index++) {
        $digit = [int]::Parse($Value.Substring($index, 1))
        $a = ($a + $digit) % 10
        if ($a -eq 0) {
            $a = 10
        }

        $a = ($a * 2) % 11
    }

    $control = 11 - $a
    if ($control -eq 10) {
        $control = 0
    }

    return $control -eq [int]::Parse($Value.Substring(10, 1))
}

function Test-VeritasValidHrIban {
    param([AllowNull()][string] $Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    $normalized = [regex]::Replace($Value.ToUpperInvariant(), '[^A-Z0-9]', '')
    if ($normalized -notmatch '^HR[0-9]{19}$') {
        return $false
    }

    $rearranged = $normalized.Substring(4) + $normalized.Substring(0, 4)
    $numeric = ''
    foreach ($character in $rearranged.ToCharArray()) {
        if ([char]::IsLetter($character)) {
            $numeric += ([int][char]$character - [int][char]'A' + 10).ToString()
        }
        else {
            $numeric += $character
        }
    }

    $remainder = 0
    foreach ($digit in $numeric.ToCharArray()) {
        $remainder = (($remainder * 10) + [int]::Parse([string]$digit)) % 97
    }

    return $remainder -eq 1
}

function Get-VeritasHighRiskFindingCodes {
    param([AllowNull()][string] $Text)

    $findings = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return [string[]]@()
    }

    foreach ($match in [regex]::Matches($Text, '(?<![0-9])[0-9]{11}(?![0-9])')) {
        if (Test-VeritasValidOib -Value $match.Value) {
            [void]$findings.Add('VALID_OIB')
        }
    }

    $ibanPattern = '(?i)(?<![A-Z0-9])HR(?:[\s-]*[0-9]){19}(?![A-Z0-9])'
    foreach ($match in [regex]::Matches($Text, $ibanPattern)) {
        if (Test-VeritasValidHrIban -Value $match.Value) {
            [void]$findings.Add('VALID_HR_IBAN')
        }
    }

    $emailPattern = '(?i)(?<![A-Z0-9._%+-])[A-Z0-9._%+-]+@' +
        '[A-Z0-9.-]+[.][A-Z]{2,}(?![A-Z0-9.-])'
    if ([regex]::IsMatch($Text, $emailPattern)) {
        [void]$findings.Add('EMAIL_ADDRESS')
    }

    $phonePattern = '(?<![0-9])[+]385(?:[\s()./-]*[0-9]){8,9}(?![0-9])'
    if ([regex]::IsMatch($Text, $phonePattern)) {
        [void]$findings.Add('HR_INTERNATIONAL_PHONE')
    }

    return [string[]]@($findings | Sort-Object)
}

function Test-VeritasPathInsideRoot {
    param(
        [Parameter(Mandatory = $true)][string] $Candidate,
        [Parameter(Mandatory = $true)][string] $Root
    )

    $candidateFull = [System.IO.Path]::GetFullPath($Candidate).TrimEnd('\', '/')
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $separator = [System.IO.Path]::DirectorySeparatorChar
    $comparison = [System.StringComparison]::OrdinalIgnoreCase

    return (
        $candidateFull.Equals($rootFull, $comparison) -or
        $candidateFull.StartsWith("$rootFull$separator", $comparison)
    )
}

function Test-VeritasLocalDataRoot {
    param(
        [AllowNull()][string] $LocalDataRoot,
        [Parameter(Mandatory = $true)][string] $RepoRoot
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $resolvedRoot = $null

    if ([string]::IsNullOrWhiteSpace($LocalDataRoot)) {
        [void]$errors.Add('LOCAL_ROOT_MISSING')
    }
    elseif (-not [System.IO.Path]::IsPathRooted($LocalDataRoot)) {
        [void]$errors.Add('LOCAL_ROOT_NOT_ABSOLUTE')
    }
    else {
        try {
            $resolvedRoot = [System.IO.Path]::GetFullPath($LocalDataRoot)
            $resolvedRepo = [System.IO.Path]::GetFullPath($RepoRoot)

            $rootsOverlap = (
                (Test-VeritasPathInsideRoot -Candidate $resolvedRoot -Root $resolvedRepo) -or
                (Test-VeritasPathInsideRoot -Candidate $resolvedRepo -Root $resolvedRoot)
            )
            if ($rootsOverlap) {
                [void]$errors.Add('LOCAL_ROOT_OVERLAPS_REPOSITORY')
            }

            $syncPattern = '(?i)(^|[\\/])(OneDrive|Google[ ]Drive|Dropbox)([\\/]|$)'
            if ($resolvedRoot -match $syncPattern) {
                [void]$errors.Add('LOCAL_ROOT_PUBLIC_SYNC_RISK')
            }
        }
        catch {
            [void]$errors.Add('LOCAL_ROOT_INVALID')
        }
    }

    return [pscustomobject]@{
        Valid = $errors.Count -eq 0
        FullPath = $resolvedRoot
        Errors = [string[]]$errors.ToArray()
    }
}

function Test-VeritasPredmetDocument {
    param(
        [Parameter(Mandatory = $true)] $Document,
        [Parameter(Mandatory = $true)][ValidateSet('public', 'local')]
        [string] $ExpectedMode,
        [Parameter(Mandatory = $true)][string] $ExpectedSubjectId
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $requiredPaths = @(
        'meta',
        'meta.id_predmeta',
        'meta.vrsta',
        'meta.verzija',
        'meta.domena',
        'meta.tok',
        'meta.datum_otvaranja',
        'meta.status',
        'meta.rezim_podataka',
        'nositelj',
        'nositelj.oznaka',
        'nositelj.ime_prezime',
        'nositelj.oib',
        'nositelj.adresa',
        'nositelj.kontakt',
        'akt',
        'akt.vrsta',
        'akt.tijelo',
        'akt.broj',
        'akt.datum',
        'akt.datum_dostave',
        'obrada',
        'obrada.cilj',
        'obrada.pravni_lijek',
        'obrada.rok',
        'privatnost',
        'privatnost.klasifikacija',
        'privatnost.sadrzi_osobne_podatke',
        'privatnost.dopusteno_git_pracenje',
        'sud_naziv',
        'napomena_nacrt'
    )

    foreach ($requiredPathText in $requiredPaths) {
        $requiredPath = [string[]]($requiredPathText -split '[.]')
        if (-not (
            Test-VeritasNestedPropertyExists -Object $Document -Path $requiredPath
        )) {
            [void]$errors.Add('MISSING_REQUIRED_' + ($requiredPath -join '_').ToUpperInvariant())
        }
    }

    if ($errors.Count -gt 0) {
        return [pscustomobject]@{
            Valid = $false
            Errors = [string[]]$errors.ToArray()
        }
    }

    $id = [string](Get-VeritasNestedValue $Document @('meta', 'id_predmeta'))
    $type = [string](Get-VeritasNestedValue $Document @('meta', 'vrsta'))
    $version = [string](Get-VeritasNestedValue $Document @('meta', 'verzija'))
    $domain = [string](Get-VeritasNestedValue $Document @('meta', 'domena'))
    $flow = [string](Get-VeritasNestedValue $Document @('meta', 'tok'))
    $opened = [string](Get-VeritasNestedValue $Document @('meta', 'datum_otvaranja'))
    $status = [string](Get-VeritasNestedValue $Document @('meta', 'status'))
    $dataMode = [string](Get-VeritasNestedValue $Document @('meta', 'rezim_podataka'))
    $classification = [string](Get-VeritasNestedValue $Document @('privatnost', 'klasifikacija'))
    $hasPersonalData = Get-VeritasNestedValue $Document @('privatnost', 'sadrzi_osobne_podatke')
    $gitAllowed = Get-VeritasNestedValue $Document @('privatnost', 'dopusteno_git_pracenje')

    if ($id -ne $ExpectedSubjectId) {
        [void]$errors.Add('SUBJECT_ID_PATH_MISMATCH')
    }
    if ($id -notmatch '^[A-Z0-9_]+$') {
        [void]$errors.Add('SUBJECT_ID_FORMAT_INVALID')
    }
    if ($version -notmatch '^v[0-9]+$') {
        [void]$errors.Add('VERSION_FORMAT_INVALID')
    }
    if ($domain -ne 'prekrsajni') {
        [void]$errors.Add('DOMAIN_INVALID')
    }
    if ($flow -notin @(
        'TOK_PN_PRIGOVOR',
        'TOK_PRESUDA_ZALBA',
        'TOK_RJESENJE_ZALBA',
        'TOK_OBUSTAVA'
    )) {
        [void]$errors.Add('FLOW_INVALID')
    }
    if ($opened -notmatch '^[0-9]{2}[.][0-9]{2}[.][0-9]{4}[.]$') {
        [void]$errors.Add('OPEN_DATE_FORMAT_INVALID')
    }
    if ($status -notin @('nacrt', 'aktivan', 'zatvoren')) {
        [void]$errors.Add('STATUS_INVALID')
    }

    foreach ($datePathText in @('akt.datum', 'akt.datum_dostave')) {
        $datePath = [string[]]($datePathText -split '[.]')
        $dateValue = Get-VeritasNestedValue $Document $datePath
        if (
            $null -ne $dateValue -and
            [string]$dateValue -notmatch '^[0-9]{2}[.][0-9]{2}[.][0-9]{4}[.]$'
        ) {
            [void]$errors.Add('ACT_DATE_FORMAT_INVALID')
        }
    }

    $courtName = [string](Get-VeritasPropertyValue $Document 'sud_naziv')
    $authority = [string](Get-VeritasNestedValue $Document @('akt', 'tijelo'))
    if ([string]::IsNullOrWhiteSpace($courtName) -or $courtName -ne $authority) {
        [void]$errors.Add('COURT_NAME_AUTHORITY_MISMATCH')
    }

    if ($ExpectedMode -eq 'public') {
        if ($ExpectedSubjectId -notmatch '^OGLEDNI_[A-Z0-9_]+$') {
            [void]$errors.Add('PUBLIC_SUBJECT_PATH_INVALID')
        }
        if (
            $type -ne 'sinteticki' -or
            $dataMode -ne 'javni_sinteticki' -or
            $classification -ne 'JAVNO_SINTETICKI' -or
            $hasPersonalData -isnot [bool] -or
            $hasPersonalData -ne $false -or
            $gitAllowed -isnot [bool] -or
            $gitAllowed -ne $true
        ) {
            [void]$errors.Add('PUBLIC_PRIVACY_TUPLE_INVALID')
        }

        $holderMarker = [string](Get-VeritasNestedValue $Document @('nositelj', 'oznaka'))
        if ($holderMarker -notmatch '^SINTETICKI_') {
            [void]$errors.Add('PUBLIC_HOLDER_MARKER_INVALID')
        }

        foreach ($piiPathText in @(
            'nositelj.ime_prezime',
            'nositelj.oib',
            'nositelj.adresa',
            'nositelj.kontakt'
        )) {
            $piiPath = [string[]]($piiPathText -split '[.]')
            if ($null -ne (Get-VeritasNestedValue $Document $piiPath)) {
                [void]$errors.Add('PUBLIC_PERSONAL_FIELD_NOT_NULL')
                break
            }
        }
    }
    else {
        if ($ExpectedSubjectId -notmatch '^STVARNI_[A-Z0-9_]+$') {
            [void]$errors.Add('LOCAL_SUBJECT_PATH_INVALID')
        }
        if (
            $type -ne 'stvarni' -or
            $dataMode -ne 'lokalni_povjerljivi' -or
            $classification -ne 'LOKALNO_POVJERLJIVO' -or
            $hasPersonalData -isnot [bool] -or
            $hasPersonalData -ne $true -or
            $gitAllowed -isnot [bool] -or
            $gitAllowed -ne $false
        ) {
            [void]$errors.Add('LOCAL_PRIVACY_TUPLE_INVALID')
        }
    }

    return [pscustomobject]@{
        Valid = $errors.Count -eq 0
        Errors = [string[]]$errors.ToArray()
    }
}
