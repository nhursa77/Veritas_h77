param(
    [Parameter(Mandatory = $true)]
    [int]$BrojZadatka,

    [Parameter(Mandatory = $true)]
    [string]$Naslov,

    [Parameter(Mandatory = $true)]
    [string[]]$Sazetak,

    [Parameter(Mandatory = $true)]
    [string[]]$AzuriraneDatoteke,

    [Parameter(Mandatory = $true)]
    [string[]]$DokazneNaredbe,

    [string]$Datum = (Get-Date).ToString('dd.MM.yyyy.'),
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Remove-HeadingPunctuation {
    param([Parameter(Mandatory = $true)][string]$Text)

    return $Text.Trim().TrimEnd('.', ':', ';', '!', '?')
}

function Wrap-TextBlock {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$FirstPrefix,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$NextPrefix,
        [int]$Limit = 80
    )

    $words = $Text -split '\s+' | Where-Object { $_ -ne '' }
    if ($words.Count -eq 0) {
        return @($FirstPrefix.TrimEnd())
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $currentPrefix = $FirstPrefix
    $currentText = ''

    foreach ($word in $words) {
        $candidate = if ([string]::IsNullOrEmpty($currentText)) { $word } else { "$currentText $word" }
        $candidateLine = $currentPrefix + $candidate

        if ($candidateLine.Length -le $Limit -or [string]::IsNullOrEmpty($currentText)) {
            $currentText = $candidate
            continue
        }

        $lines.Add($currentPrefix + $currentText)
        $currentPrefix = $NextPrefix
        $currentText = $word
    }

    if (-not [string]::IsNullOrEmpty($currentText)) {
        $lines.Add($currentPrefix + $currentText)
    }

    return $lines
}

function Wrap-CodeBlock {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$FirstPrefix,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$NextPrefix,
        [int]$Limit = 80
    )

    $words = $Text -split '\s+' | Where-Object { $_ -ne '' }
    $segments = New-Object System.Collections.Generic.List[string]
    $current = ''

    foreach ($word in $words) {
        $candidate = if ([string]::IsNullOrEmpty($current)) { $word } else { "$current $word" }
        $candidateLine = '`' + $candidate + '`'
        $prefix = if ($segments.Count -eq 0) { $FirstPrefix } else { $NextPrefix }

        if (($prefix + $candidateLine).Length -le $Limit -or [string]::IsNullOrEmpty($current)) {
            $current = $candidate
            continue
        }

        $segments.Add($current)
        $current = $word
    }

    if (-not [string]::IsNullOrEmpty($current)) {
        $segments.Add($current)
    }

    $lines = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $segments.Count; $i++) {
        $prefix = if ($i -eq 0) { $FirstPrefix } else { $NextPrefix }
        $lines.Add($prefix + '`' + $segments[$i] + '`')
    }

    return $lines
}

$cleanTitle = Remove-HeadingPunctuation -Text $Naslov
$entryHeading = "### ZADATAK $BrojZadatka - $cleanTitle"
$dateHeading = "## Datum: $($Datum.TrimEnd('.')) (ZADATAK $BrojZadatka)"
$resolvedOutputPath = if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Join-Path $env:TEMP "veritas_z$BrojZadatka`_dnevnik.md"
}
else {
    $OutputPath
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add($dateHeading)
$lines.Add('')
$lines.Add($entryHeading)
$lines.Add('')

foreach ($paragraph in $Sazetak) {
    foreach ($wrappedLine in (Wrap-TextBlock -Text $paragraph -FirstPrefix '' -NextPrefix '')) {
        $lines.Add($wrappedLine)
    }
    $lines.Add('')
}

$lines.Add('Mijenjane datoteke:')
$lines.Add('')
foreach ($path in $AzuriraneDatoteke) {
    foreach ($wrappedLine in (Wrap-CodeBlock -Text $path -FirstPrefix '- ' -NextPrefix '  ')) {
        $lines.Add($wrappedLine)
    }
}
$lines.Add('')

$lines.Add('Dokazne naredbe:')
$lines.Add('')
foreach ($command in $DokazneNaredbe) {
    foreach ($wrappedLine in (Wrap-CodeBlock -Text $command -FirstPrefix '- ' -NextPrefix '  ')) {
        $lines.Add($wrappedLine)
    }
}

$content = ($lines -join "`n") + "`n"
Write-Utf8NoBom -Path $resolvedOutputPath -Content $content

Write-Host "DNEVNIK_GENERATOR_BEGIN=True"
Write-Host "DNEVNIK_GENERATOR_OUTPUT=$resolvedOutputPath"
Write-Host "DNEVNIK_GENERATOR_DATE_HEADING=$dateHeading"
Write-Host "DNEVNIK_GENERATOR_ENTRY_HEADING=$entryHeading"
Write-Host "DNEVNIK_GENERATOR_UPDATED_FILES=$($AzuriraneDatoteke.Count)"
Write-Host "DNEVNIK_GENERATOR_COMMANDS=$($DokazneNaredbe.Count)"
Write-Host "DNEVNIK_GENERATOR_END=True"
Write-Host "DNEVNIK_GENERATOR_EXIT=0"
