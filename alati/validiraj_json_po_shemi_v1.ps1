#requires -Version 5.1
<#
.SYNOPSIS
Generički schema-driven validator za JSON izlaze u Veritas H.77.

.DESCRIPTION
Učitava ciljnu JSON datoteku i JSON shemu, provodi osnovnu schema-driven
validaciju bez nuspojava i vraća standardizirani izlaz te exit code.

.NOTES
SIGURNOSNA NAPOMENA:
- Ovo je novi generički schema-driven validator v1 za jezgru skupine
  PREKRSAJNI_JSON_VALIDATORI_V1.
- Postojećih 5 validatora u ovom koraku nisu dirani niti preusmjereni.
- Wrapper migracija nije dio ovog zadatka.

.PARAMETER JsonPutanja
Putanja do ciljne JSON datoteke koja se validira.

.PARAMETER ShemaPutanja
Putanja do JSON sheme prema kojoj se provodi validacija.

.PARAMETER OznakaIzlaza
Opcionalna oznaka završnog izlaza. Zadana vrijednost je
VALIDATOR_JSON_PO_SHEMI_V1.

.PARAMETER OpisValidatora
Opcionalni opis validatora ili provjere koji se ispisuje u izlazu.

.PARAMETER Pomoc
Ispisuje detaljni help/usage blok bez pokretanja validacije.

.EXAMPLE
pwsh -NoProfile -ExecutionPolicy Bypass -File .\alati\validiraj_json_po_shemi_v1.ps1 `
  -JsonPutanja .\predlosci\sud\prekrsajni\osnovni_prigovor\predlozak.json `
  -ShemaPutanja .\dokumentacija\sheme\SCHEMA_PREDLOZAK_V1.json `
  -OpisValidatora "predlozak probe"
#>

[CmdletBinding()]
param(
    [string]$JsonPutanja,
    [string]$ShemaPutanja,
    [string]$OznakaIzlaza = "VALIDATOR_JSON_PO_SHEMI_V1",
    [string]$OpisValidatora = "genericki schema-driven validator v1",
    [switch]$Pomoc
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Get-NormalizedMarker {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $candidate = $Value.Trim()
    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = "VALIDATOR_JSON_PO_SHEMI_V1"
    }

    $candidate = $candidate.ToUpperInvariant()
    $candidate = [regex]::Replace($candidate, "[^A-Z0-9]+", "_").Trim("_")

    if ([string]::IsNullOrWhiteSpace($candidate)) {
        $candidate = "VALIDATOR_JSON_PO_SHEMI_V1"
    }

    return $candidate
}

function Resolve-InputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path -Path (Get-Location) -ChildPath $PathValue))
}

function Get-ActualTypeName {
    param($Value)

    if ($null -eq $Value) {
        return "null"
    }

    if ($Value -is [string]) {
        return "string"
    }

    if ($Value -is [bool]) {
        return "boolean"
    }

    if ($Value -is [System.Array]) {
        return "array"
    }

    if ($Value -is [pscustomobject] -or $Value -is [hashtable]) {
        return "object"
    }

    if (
        $Value -is [byte] -or
        $Value -is [sbyte] -or
        $Value -is [int16] -or
        $Value -is [int32] -or
        $Value -is [int64] -or
        $Value -is [uint16] -or
        $Value -is [uint32] -or
        $Value -is [uint64]
    ) {
        return "integer"
    }

    if (
        $Value -is [single] -or
        $Value -is [double] -or
        $Value -is [decimal]
    ) {
        return "number"
    }

    return $Value.GetType().Name
}

function Test-ExpectedType {
    param(
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedType
    )

    switch ($ExpectedType) {
        "object" {
            return ($Value -is [pscustomobject] -or $Value -is [hashtable])
        }
        "array" {
            return ($Value -is [System.Array])
        }
        "string" {
            return ($Value -is [string])
        }
        "boolean" {
            return ($Value -is [bool])
        }
        "integer" {
            return (
                $Value -is [byte] -or
                $Value -is [sbyte] -or
                $Value -is [int16] -or
                $Value -is [int32] -or
                $Value -is [int64] -or
                $Value -is [uint16] -or
                $Value -is [uint32] -or
                $Value -is [uint64]
            )
        }
        "number" {
            return (
                $Value -is [byte] -or
                $Value -is [sbyte] -or
                $Value -is [int16] -or
                $Value -is [int32] -or
                $Value -is [int64] -or
                $Value -is [uint16] -or
                $Value -is [uint32] -or
                $Value -is [uint64] -or
                $Value -is [single] -or
                $Value -is [double] -or
                $Value -is [decimal]
            )
        }
        "null" {
            return ($null -eq $Value)
        }
        default {
            return $true
        }
    }
}

function Add-ValidationError {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Errors,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    [void]$Errors.Add($Message)
}

function Test-JsonNodeAgainstSchema {
    param(
        $Value,
        $SchemaNode,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Errors
    )

    if ($null -eq $SchemaNode) {
        return
    }

    $schemaTypeProp = $SchemaNode.PSObject.Properties["type"]
    $schemaType = $null
    if ($null -ne $schemaTypeProp) {
        $schemaType = [string]$schemaTypeProp.Value
        if (-not (Test-ExpectedType -Value $Value -ExpectedType $schemaType)) {
            Add-ValidationError -Errors $Errors -Message (
                "ERROR: TYPE_MISMATCH {0} expected={1} actual={2}" -f
                $Path,
                $schemaType,
                (Get-ActualTypeName -Value $Value)
            )
            return
        }
    }

    $enumProp = $SchemaNode.PSObject.Properties["enum"]
    if ($null -ne $enumProp) {
        $matchesEnum = $false
        foreach ($allowedValue in @($enumProp.Value)) {
            if ($allowedValue -eq $Value -or [string]$allowedValue -eq [string]$Value) {
                $matchesEnum = $true
                break
            }
        }

        if (-not $matchesEnum) {
            Add-ValidationError -Errors $Errors -Message (
                "ERROR: ENUM_FAIL {0} value={1}" -f $Path, [string]$Value
            )
        }
    }

    $patternProp = $SchemaNode.PSObject.Properties["pattern"]
    if ($null -ne $patternProp -and $Value -is [string]) {
        $pattern = [string]$patternProp.Value
        if ([string]$Value -notmatch $pattern) {
            Add-ValidationError -Errors $Errors -Message (
                "ERROR: PATTERN_FAIL {0} value={1} pattern={2}" -f
                $Path,
                [string]$Value,
                $pattern
            )
        }
    }

    $requiredProp = $SchemaNode.PSObject.Properties["required"]
    $propertiesProp = $SchemaNode.PSObject.Properties["properties"]
    if ($null -ne $requiredProp -or $null -ne $propertiesProp -or $schemaType -eq "object") {
        if (-not (Test-ExpectedType -Value $Value -ExpectedType "object")) {
            return
        }

        if ($null -ne $requiredProp) {
            foreach ($requiredName in @($requiredProp.Value)) {
                if ($null -eq $Value.PSObject.Properties[[string]$requiredName]) {
                    Add-ValidationError -Errors $Errors -Message (
                        "ERROR: MISSING_REQUIRED {0}.{1}" -f $Path, [string]$requiredName
                    )
                }
            }
        }

        if ($null -ne $propertiesProp) {
            foreach ($propertySchema in $propertiesProp.Value.PSObject.Properties) {
                $currentProperty = $Value.PSObject.Properties[$propertySchema.Name]
                if ($null -ne $currentProperty) {
                    Test-JsonNodeAgainstSchema `
                        -Value $currentProperty.Value `
                        -SchemaNode $propertySchema.Value `
                        -Path ("{0}.{1}" -f $Path, $propertySchema.Name) `
                        -Errors $Errors
                }
            }
        }
    }

    $itemsProp = $SchemaNode.PSObject.Properties["items"]
    if ($null -ne $itemsProp -or $schemaType -eq "array") {
        if (-not (Test-ExpectedType -Value $Value -ExpectedType "array")) {
            return
        }

        $itemSchema = $null
        if ($null -ne $itemsProp) {
            $itemSchema = $itemsProp.Value
        }

        $index = 0
        foreach ($item in @($Value)) {
            Test-JsonNodeAgainstSchema `
                -Value $item `
                -SchemaNode $itemSchema `
                -Path ("{0}[{1}]" -f $Path, $index) `
                -Errors $Errors
            $index++
        }
    }
}

function Write-StandardizedExit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Marker,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [int]$ExitCode
    )

    Write-Host "VALIDATOR_OPIS=$OpisValidatora"
    if (-not [string]::IsNullOrWhiteSpace($script:ResolvedJsonPutanja)) {
        Write-Host "VALIDATOR_JSON=$script:ResolvedJsonPutanja"
    }

    if (-not [string]::IsNullOrWhiteSpace($script:ResolvedShemaPutanja)) {
        Write-Host "VALIDATOR_SHEMA=$script:ResolvedShemaPutanja"
    }

    Write-Host "VALIDATOR_STATUS=$Status"
    Write-Host "$Marker`_EXIT=$ExitCode"
    exit $ExitCode
}

$marker = Get-NormalizedMarker -Value $OznakaIzlaza

if ($Pomoc) {
    Get-Help -Detailed $PSCommandPath
    exit 0
}

if ([string]::IsNullOrWhiteSpace($JsonPutanja) -or [string]::IsNullOrWhiteSpace($ShemaPutanja)) {
    Get-Help -Detailed $PSCommandPath
    Write-Host "VALIDATOR_STATUS=USAGE"
    Write-Host "$marker`_EXIT=64"
    exit 64
}

$script:ResolvedJsonPutanja = Resolve-InputPath -PathValue $JsonPutanja
$script:ResolvedShemaPutanja = Resolve-InputPath -PathValue $ShemaPutanja

if (-not (Test-Path -LiteralPath $script:ResolvedJsonPutanja)) {
    Write-Host "ERROR: NEDOSTAJE_JSON=$script:ResolvedJsonPutanja"
    Write-StandardizedExit -Marker $marker -Status "MISSING_INPUT" -ExitCode 2
}

if (-not (Test-Path -LiteralPath $script:ResolvedShemaPutanja)) {
    Write-Host "ERROR: NEDOSTAJE_SHEMA=$script:ResolvedShemaPutanja"
    Write-StandardizedExit -Marker $marker -Status "MISSING_SCHEMA" -ExitCode 3
}

try {
    $schema = Get-Content -LiteralPath $script:ResolvedShemaPutanja -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: SCHEMA_PARSE_FAIL $script:ResolvedShemaPutanja"
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-StandardizedExit -Marker $marker -Status "TECHNICKA_GRESKA" -ExitCode 4
}

try {
    $jsonDocument = Get-Content -LiteralPath $script:ResolvedJsonPutanja -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: JSON_PARSE_FAIL $script:ResolvedJsonPutanja"
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-StandardizedExit -Marker $marker -Status "TECHNICKA_GRESKA" -ExitCode 4
}

$validationErrors = [System.Collections.Generic.List[string]]::new()
Test-JsonNodeAgainstSchema -Value $jsonDocument -SchemaNode $schema -Path "root" -Errors $validationErrors

if ($validationErrors.Count -gt 0) {
    foreach ($validationError in $validationErrors) {
        Write-Host $validationError
    }

    Write-StandardizedExit -Marker $marker -Status "NEVALIDNO" -ExitCode 1
}

Write-StandardizedExit -Marker $marker -Status "VALIDNO" -ExitCode 0
