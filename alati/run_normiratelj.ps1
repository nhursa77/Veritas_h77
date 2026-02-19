param(
    [Parameter(Mandatory = $true)]
    [string] $AktSlug
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$scriptPath = Join-Path $PSScriptRoot "normiratelj_iz_strukture_nn.py"
$parserRunner = Join-Path $PSScriptRoot "parsiraj_nn_html.ps1"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"
$sourcesRoot = Join-Path $root "izvori\dokazno\narodne_novine"
$selectionReportName = ($AktSlug.ToUpperInvariant() -replace '[^A-Z0-9]+', '_') + "_SELECTION_REPORT.md"
$selectionReportPath = Join-Path $sourcesRoot $selectionReportName
$isAktSlugSidro = $AktSlug.ToLowerInvariant().Contains("_nn_")

function Resolve-OperativniSlug {
    param([Parameter(Mandatory = $true)][string] $Slug)

    if ($Slug -eq "ustav_rh") {
        return "ustav_rh_procisceni"
    }

    return $Slug
}

function Get-StringValue {
    param(
        [Parameter(Mandatory = $false)] $Object,
        [Parameter(Mandatory = $true)][string] $PropertyName
    )

    if ($null -eq $Object) { return "" }
    $prop = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $prop -or $null -eq $prop.Value) { return "" }
    return [string]$prop.Value
}

function Get-IntValue {
    param(
        [Parameter(Mandatory = $false)] $Object,
        [Parameter(Mandatory = $true)][string] $PropertyName,
        [Parameter(Mandatory = $false)][int] $Default = 0
    )

    if ($null -eq $Object) { return $Default }
    $prop = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $prop -or $null -eq $prop.Value) { return $Default }

    $raw = [string]$prop.Value
    if ($raw -match '^-?[0-9]+$') {
        return [int]$raw
    }

    return $Default
}

function Resolve-SourceSelection {
    param(
        [Parameter(Mandatory = $true)][string] $RootPath,
        [Parameter(Mandatory = $true)][string] $AktSlug
    )

    $metaFiles = Get-ChildItem -Path $RootPath -Filter "meta.json" -Recurse -File
    $candidates = @()
    $aktToken = (($AktSlug.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_'))

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

        $slugToken = (($slug.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_'))
        $isCandidate = $slugToken -eq $aktToken -or $slugToken.StartsWith("$aktToken`_")
        if (-not $isCandidate) { continue }

        $tipTeksta = (Get-StringValue -Object $meta -PropertyName "tip_teksta").ToLowerInvariant()
        $preferenca = Get-IntValue -Object $meta -PropertyName "preferenca" -Default 0
        $ocekivaniBrojClanaka = Get-IntValue -Object $meta -PropertyName "ocekivani_broj_clanaka" -Default 0
        $inputPath = Join-Path $metaFile.DirectoryName "struktura_nn_dokumenti.json"
        $inputExists = Test-Path -LiteralPath $inputPath

        $candidates += [pscustomobject]@{
            slug = $slug
            metaPath = $metaFile.FullName
            tipTeksta = $tipTeksta
            preferenca = $preferenca
            ocekivaniBrojClanaka = $ocekivaniBrojClanaka
            inputPath = $inputPath
            inputExists = $inputExists
            kategorijaScore = if ($tipTeksta -eq "procisceni") { 1 } else { 0 }
        }
    }

    if ($candidates.Count -eq 0) {
        throw "Nije pronađen nijedan kandidat izvora za akt_slug='$AktSlug' u: $RootPath"
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
        [Parameter(Mandatory = $true)][string] $ReportPath,
        [Parameter(Mandatory = $true)][string] $AktSlug
    )

    $selected = $Selection.selected
    $ordered = $Selection.ordered
    $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")

    $lines = @()
    $lines += "# SOURCE SELECTION REPORT"
    $lines += ""
    $lines += "- Akt slug: $AktSlug"
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

Push-Location $root
try {
    & $parserRunner -AktSlug $AktSlug
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    $selection = Resolve-SourceSelection -RootPath $sourcesRoot -AktSlug $AktSlug
    Write-SelectionReport -Selection $selection -ReportPath $selectionReportPath -AktSlug $AktSlug

    $sourceSlug = $selection.selected.slug
    $inputPath = $selection.selected.inputPath
    $metaPath = $selection.selected.metaPath
    $sourceOutBase = if ($sourceSlug.ToLowerInvariant().Contains("_nn_")) { "sidra" } else { "norme" }
    $operativniSlug = Resolve-OperativniSlug -Slug $AktSlug
    $sourceOutDir = Join-Path $root "baza_zakona\$sourceOutBase\$sourceSlug"
    $operativniOutDir = Join-Path $root "baza_zakona\norme\$operativniSlug"

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

    if ($isAktSlugSidro) {
        Write-Host "Sidrišni set ažuriran: $sourceOutDir"
    }
    elseif ([string]::Equals($sourceOutDir, $operativniOutDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "Operativni set ažuriran: $operativniOutDir (izvor=isti akt slug)"
    }
    else {
        New-Item -ItemType Directory -Force -Path $operativniOutDir | Out-Null
        Get-ChildItem -LiteralPath $operativniOutDir -Filter "clanak_*.json" -File -ErrorAction SilentlyContinue | Remove-Item -Force
        Remove-Item -LiteralPath (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -ErrorAction SilentlyContinue

        Copy-Item -Path (Join-Path $sourceOutDir "clanak_*.json") -Destination $operativniOutDir -Force
        Copy-Item -LiteralPath (Join-Path $sourceOutDir "IZVJESTAJ_NORMIRANJA.md") -Destination (Join-Path $operativniOutDir "IZVJESTAJ_NORMIRANJA.md") -Force

        Write-Host "Operativni set ažuriran: $operativniOutDir (izvor: $sourceOutDir)"
    }

    Write-Host "Selection report: $selectionReportPath"
}
finally {
    Pop-Location
}
