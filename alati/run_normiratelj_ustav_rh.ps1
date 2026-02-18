param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$scriptPath = Join-Path $PSScriptRoot "normiratelj_iz_strukture_nn.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

$operativniSlug = "ustav_rh"
$sourcesRoot = Join-Path $root "izvori\dokazno\narodne_novine"
$selectionReportPath = Join-Path $sourcesRoot "USTAV_RH_SELECTION_REPORT.md"

function Get-StringValue {
    param(
        [Parameter(Mandatory = $false)] $Object,
        [Parameter(Mandatory = $true)][string] $PropertyName
    )

    if ($null -eq $Object) {
        return ""
    }

    $prop = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $prop -or $null -eq $prop.Value) {
        return ""
    }

    return [string]$prop.Value
}

function Get-IntValue {
    param(
        [Parameter(Mandatory = $false)] $Object,
        [Parameter(Mandatory = $true)][string] $PropertyName,
        [Parameter(Mandatory = $false)][int] $Default = 0
    )

    if ($null -eq $Object) {
        return $Default
    }

    $prop = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $prop -or $null -eq $prop.Value) {
        return $Default
    }

    $raw = [string]$prop.Value
    if ($raw -match '^-?[0-9]+$') {
        return [int]$raw
    }

    return $Default
}

function Resolve-UstavRhSourceSelection {
    param(
        [Parameter(Mandatory = $true)][string] $RootPath
    )

    $metaFiles = Get-ChildItem -Path $RootPath -Filter "meta.json" -Recurse -File
    $candidates = @()

    foreach ($metaFile in $metaFiles) {
        try {
            $rawMeta = Get-Content -LiteralPath $metaFile.FullName -Raw -Encoding UTF8
            $meta = $rawMeta | ConvertFrom-Json
        }
        catch {
            continue
        }

        $slug = Get-StringValue -Object $meta -PropertyName "slug"
        if ([string]::IsNullOrWhiteSpace($slug)) {
            $slug = Split-Path -Path $metaFile.DirectoryName -Leaf
        }

        $vrstaAkta = (Get-StringValue -Object $meta -PropertyName "vrsta_akta").ToLowerInvariant()
        $nazivAkta = (Get-StringValue -Object $meta -PropertyName "naziv_akta").ToLowerInvariant()
        $slugLower = $slug.ToLowerInvariant()

        $isUstavRhCandidate = $false
        if ($vrstaAkta -eq "ustav") { $isUstavRhCandidate = $true }
        if ($nazivAkta -like "*ustav republike hrvatske*") { $isUstavRhCandidate = $true }
        if ($slugLower.StartsWith("ustav_rh")) { $isUstavRhCandidate = $true }
        if (-not $isUstavRhCandidate) { continue }

        $tipTeksta = Get-StringValue -Object $meta -PropertyName "tip_teksta"
        $preferenca = Get-IntValue -Object $meta -PropertyName "preferenca" -Default 0
        $ocekivaniBrojClanaka = Get-IntValue -Object $meta -PropertyName "ocekivani_broj_clanaka" -Default 0
        $inputPath = Join-Path $metaFile.DirectoryName "struktura_nn_dokumenti.json"

        $kategorijaScore = if ($tipTeksta -eq "procisceni") { 1 } else { 0 }
        $imaInput = Test-Path -LiteralPath $inputPath

        $candidates += [pscustomobject]@{
            slug = $slug
            metaPath = $metaFile.FullName
            tipTeksta = $tipTeksta
            preferenca = $preferenca
            ocekivaniBrojClanaka = $ocekivaniBrojClanaka
            inputPath = $inputPath
            inputExists = $imaInput
            kategorijaScore = $kategorijaScore
        }
    }

    if ($candidates.Count -eq 0) {
        throw "Nije pronađen nijedan kandidat izvora za ustav_rh u: $RootPath"
    }

    $ordered = $candidates | Sort-Object -Property @{Expression = { $_.inputExists }; Descending = $true }, @{Expression = { $_.kategorijaScore }; Descending = $true }, @{Expression = { $_.preferenca }; Descending = $true }, @{Expression = { $_.ocekivaniBrojClanaka }; Descending = $true }, @{Expression = { $_.slug }; Descending = $false }
    $selected = $ordered | Select-Object -First 1

    if (-not $selected.inputExists) {
        throw "Odabrani kandidat '$($selected.slug)' nema struktura_nn_dokumenti.json: $($selected.inputPath)"
    }

    return [pscustomobject]@{
        selected = $selected
        ordered = $ordered
    }
}

function Write-SelectionReport {
    param(
        [Parameter(Mandatory = $true)] $Selection,
        [Parameter(Mandatory = $true)][string] $ReportPath
    )

    $selected = $Selection.selected
    $ordered = $Selection.ordered
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")

    $lines = @()
    $lines += "# USTAV RH SOURCE SELECTION REPORT"
    $lines += ""
    $lines += "- Timestamp: $timestamp"
    $lines += "- Selected slug: $($selected.slug)"
    $lines += "- Selected tip_teksta: $($selected.tipTeksta)"
    $lines += "- Selected preferenca: $($selected.preferenca)"
    $lines += "- Selected ocekivani_broj_clanaka: $($selected.ocekivaniBrojClanaka)"
    $lines += "- Selected input: $($selected.inputPath)"
    $lines += ""
    $lines += "## Ranking"
    $lines += ""

    $index = 1
    foreach ($item in $ordered) {
        $lines += "- [$index] slug=$($item.slug) | tip_teksta=$($item.tipTeksta) | preferenca=$($item.preferenca) | ocekivani_broj_clanaka=$($item.ocekivaniBrojClanaka) | input_exists=$($item.inputExists)"
        $index++
    }

    $lines += ""
    $lines += "## Guardrail"
    $lines += ""
    $lines += "- Pravilo odabira: input_exists DESC, tip_teksta(procisceni) DESC, preferenca DESC, ocekivani_broj_clanaka DESC, slug ASC."
    $lines += "- Operativni izvor mora biti procisceni NN tekst kada je dostupan."

    New-Item -ItemType Directory -Force -Path (Split-Path -Path $ReportPath -Parent) | Out-Null
    Set-Content -LiteralPath $ReportPath -Value ($lines -join "`n") -Encoding UTF8
}

$selection = Resolve-UstavRhSourceSelection -RootPath $sourcesRoot
$sourceSlug = $selection.selected.slug
$selectedMetaPath = $selection.selected.metaPath
$inputPath = $selection.selected.inputPath
$metaPath = $selectedMetaPath
$sourceOutDir = Join-Path $root "baza_zakona\norme\$sourceSlug"

$operativniOutDir = Join-Path $root "baza_zakona\norme\$operativniSlug"
$arhivaDir = Join-Path $root "baza_zakona\arhiva\ustav_rh_nn_56_1990_1092_142"

Push-Location $root
try {
    Write-SelectionReport -Selection $selection -ReportPath $selectionReportPath

    if (!(Test-Path -LiteralPath $inputPath)) {
        throw "Nedostaje ulazna dokument-split struktura: $inputPath"
    }

    if (Test-Path -LiteralPath $venvPython) {
        & $venvPython $scriptPath --akt-slug $sourceSlug --input $inputPath --meta $metaPath --out-dir $sourceOutDir
    }
    else {
        python $scriptPath --akt-slug $sourceSlug --input $inputPath --meta $metaPath --out-dir $sourceOutDir
    }

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    if ((Test-Path -LiteralPath $operativniOutDir) -and !(Test-Path -LiteralPath $arhivaDir)) {
        New-Item -ItemType Directory -Force -Path $arhivaDir | Out-Null
        Copy-Item -Path (Join-Path $operativniOutDir "*") -Destination $arhivaDir -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $operativniOutDir | Out-Null
    Get-ChildItem -LiteralPath $operativniOutDir -Filter "clanak_*.json" -File | Remove-Item -Force
    Remove-Item -LiteralPath (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -ErrorAction SilentlyContinue

    Copy-Item -Path (Join-Path $sourceOutDir "clanak_*.json") -Destination $operativniOutDir -Force
    Copy-Item -LiteralPath (Join-Path $sourceOutDir "IZVJESTAJ_NORMIRANJA.md") -Destination (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -Force

    Write-Host "Operativni set ažuriran: $operativniOutDir (izvor: $sourceOutDir)"
    Write-Host "Selection report: $selectionReportPath"
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
