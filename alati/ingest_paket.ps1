param(
    [Parameter(Mandatory = $true)]
    [string] $PaketPath
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$parserScript = Join-Path $PSScriptRoot "parsiraj_nn_html.ps1"
$normScript = Join-Path $PSScriptRoot "run_normiratelj.ps1"
$preflightScript = Join-Path $PSScriptRoot "acceptance_preflight.ps1"
$deltaOpsScript = Join-Path $PSScriptRoot "generiraj_delta_ops.py"
$sourcesRoot = Join-Path $root "izvori\dokazno\narodne_novine"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Assert-Manifest {
    param([Parameter(Mandatory = $true)] $Manifest)

    if ($null -eq $Manifest -or $null -eq $Manifest.akti) {
        throw "manifest_invalid: nedostaje 'akti'"
    }

    $items = @($Manifest.akti)
    if ($items.Count -eq 0) {
        throw "manifest_invalid: 'akti' je prazno"
    }

    $slugSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($item in $items) {
        $slug = [string]$item.akt_slug
        if ([string]::IsNullOrWhiteSpace($slug)) {
            throw "manifest_invalid: akt bez akt_slug"
        }

        if (-not $slugSet.Add($slug.ToLowerInvariant())) {
            throw "manifest_invalid: dupli akt_slug '$slug'"
        }

        $url = [string]$item.url
        if ([string]::IsNullOrWhiteSpace($url)) {
            throw "manifest_invalid: '$slug' nema url"
        }

        $oznaka = [string]$item.oznaka_akta
        if ([string]::IsNullOrWhiteSpace($oznaka)) {
            throw "manifest_invalid: '$slug' nema oznaka_akta"
        }
    }
}

function New-SourceSnapshot {
    param(
        [Parameter(Mandatory = $true)] $Item,
        [Parameter(Mandatory = $true)][string] $AktDir
    )

    $slug = [string]$Item.akt_slug
    $url = [string]$Item.url
    $eliPdfUrl = [string]$Item.eli_pdf_url
    $pdfTitleAnchor = [string]$Item.pdf_title_anchor
    $tipTeksta = [string]$Item.tip_teksta
    if ([string]::IsNullOrWhiteSpace($tipTeksta)) {
        $tipTeksta = "izvorni"
    }

    New-Item -ItemType Directory -Force -Path $AktDir | Out-Null

    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 120
    $contentType = [string]$response.Headers.'Content-Type'
    if ([string]::IsNullOrWhiteSpace($contentType)) {
        $contentType = "text/html; charset=utf-8"
    }

    $htmlPath = Join-Path $AktDir "izvor_nn.html"
    $pdfPath = Join-Path $AktDir "izvor_nn_issue.pdf"

    $isPdf = $false
    if ($contentType.ToLowerInvariant().Contains("application/pdf") -or $url.ToLowerInvariant().EndsWith(".pdf")) {
        $isPdf = $true
    }

    if ($isPdf) {
        Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $pdfPath -TimeoutSec 120
        Write-Utf8NoBom -Path $htmlPath -Content "<html><body><div class='message'>Sadržaj je nedostupan.</div></body></html>`n"
    }
    else {
        $html = [string]$response.Content
        Write-Utf8NoBom -Path $htmlPath -Content $html
    }

    $htmlBytes = [System.IO.File]::ReadAllBytes($htmlPath)
    $sha = (Get-FileHash -LiteralPath $htmlPath -Algorithm SHA256).Hash

    $meta = [ordered]@{
        naziv_akta = [string]$Item.naziv_akta
        vrsta_akta = "zakon"
        slug = $slug
        izvor = "Narodne novine"
        naziv_izvora = "Narodne novine"
        url = $url
        akt_url = $url
        eli_pdf_url = $eliPdfUrl
        pdf_title_anchor = $pdfTitleAnchor
        tip_sadrzaja = $contentType
        velicina_bajta = $htmlBytes.Length
        oznaka_akta = [string]$Item.oznaka_akta
        datum_pristupa = (Get-Date).ToString("dd.MM.yyyy.")
        sha256_datoteke = $sha
        format = "html"
        napomena = "Dokazni NN izvor (HTML; ELI PDF fallback ako sadržaj nedostupan)."
        tip_teksta = $tipTeksta
        ocekivani_broj_clanaka = 0
        preferenca = if ($tipTeksta -eq "procisceni") { 100 } else { 40 }
    }

    if ([string]::IsNullOrWhiteSpace($meta.naziv_akta)) {
        $meta.naziv_akta = "$slug"
    }

    $metaJson = ($meta | ConvertTo-Json -Depth 4)
    Write-Utf8NoBom -Path (Join-Path $AktDir "meta.json") -Content ($metaJson + "`n")
}

function Set-ControlFromParsed {
    param(
        [Parameter(Mandatory = $true)][string] $AktSlug,
        [Parameter(Mandatory = $true)] $Item
    )

    $docsPath = Join-Path $sourcesRoot "$AktSlug\struktura_nn_dokumenti.json"
    if (!(Test-Path -LiteralPath $docsPath)) {
        throw "nedostaje_parsed_docs: $docsPath"
    }

    $docs = (Get-Content -LiteralPath $docsPath -Raw -Encoding UTF8 | ConvertFrom-Json).dokumenti
    $procDocId = "${AktSlug}_procisceni"
    $proc = $docs | Where-Object { $_.doc_id -eq $procDocId } | Select-Object -First 1
    if ($null -eq $proc) {
        $proc = $docs | Select-Object -First 1
    }

    $controlDir = Join-Path $root "izvori\kontrolno\zakon_hr\$AktSlug"
    New-Item -ItemType Directory -Force -Path $controlDir | Out-Null

    $lines = @()
    foreach ($c in ($proc.clanci | Sort-Object {[int]$_.broj})) {
        $lines += ("Članak " + [string]$c.broj + ".")
        $lines += ([string]$c.tekst)
        $lines += ""
    }

    Write-Utf8NoBom -Path (Join-Path $controlDir "${AktSlug}_kontrolni.txt") -Content (($lines -join "`n") + "`n")

    $controlMeta = [ordered]@{
        izvor = "nn_snapshot_generated"
        akt_slug = $AktSlug
        url = [string]$Item.url
        preuzeto_lokalno = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
        napomena = "Kontrolni TXT generiran iz NN parsiranog snapshota radi paketnog preflighta."
    }
    $controlMetaJson = ($controlMeta | ConvertTo-Json -Depth 3)
    Write-Utf8NoBom -Path (Join-Path $controlDir "meta.json") -Content ($controlMetaJson + "`n")
}

function New-DeltaOpsFromParsed {
    param(
        [Parameter(Mandatory = $true)][string] $AktSlug
    )

    if (!(Test-Path -LiteralPath $deltaOpsScript)) {
        throw "nedostaje_delta_generator: $deltaOpsScript"
    }

    $sourceJsonPath = Join-Path $sourcesRoot "$AktSlug\struktura_nn_dokumenti.json"
    if (!(Test-Path -LiteralPath $sourceJsonPath)) {
        throw "nedostaje_parsed_docs: $sourceJsonPath"
    }

    $controlDir = Join-Path $root "izvori\kontrolno\zakon_hr\$AktSlug"
    New-Item -ItemType Directory -Force -Path $controlDir | Out-Null
    $outPath = Join-Path $controlDir "${AktSlug}_delta_ops.json"

    $venvPython = Join-Path $root ".venv\Scripts\python.exe"
    $pythonCmd = $null
    if (Test-Path -LiteralPath $venvPython) {
        $pythonCmd = $venvPython
    }
    else {
        $python = Get-Command python -ErrorAction SilentlyContinue
        if ($null -eq $python) {
            throw "python_not_found: nije pronađen python ni .venv interpreter"
        }
        $pythonCmd = $python.Source
    }

    & $pythonCmd $deltaOpsScript --akt-slug $AktSlug --source-json $sourceJsonPath --out $outPath
    $deltaExit = $LASTEXITCODE
    if ($deltaExit -ne 0) {
        throw "delta_ops_exit_$deltaExit"
    }
}

Push-Location $root
try {
    if (!(Test-Path -LiteralPath $PaketPath)) {
        Write-Host "ERROR: Nedostaje paket manifest: $PaketPath"
        exit 22
    }

    try {
        $manifest = (Get-Content -LiteralPath $PaketPath -Raw -Encoding UTF8) | ConvertFrom-Json
        Assert-Manifest -Manifest $manifest
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)"
        exit 22
    }

    $results = @()

    foreach ($item in $manifest.akti) {
        $slug = [string]$item.akt_slug
        $required = [bool]$item.required
        $status = "OK"
        $exitCode = 0

        Write-Host "=== INGEST AKT: $slug (required=$required) ==="

        try {
            $aktDir = Join-Path $sourcesRoot $slug
            $expectedTipTeksta = [string]$item.tip_teksta
            if ([string]::IsNullOrWhiteSpace($expectedTipTeksta)) {
                $expectedTipTeksta = if ($required) { "procisceni" } else { "amandmani" }
            }

            New-SourceSnapshot -Item $item -AktDir $aktDir

            & $parserScript -AktSlug $slug
            $exitCode = $LASTEXITCODE
            if ($exitCode -ne 0) { throw "parser_exit_$exitCode" }

            Set-ControlFromParsed -AktSlug $slug -Item $item

            if ($expectedTipTeksta -eq "amandmani") {
                New-DeltaOpsFromParsed -AktSlug $slug
            }

            & $normScript -AktSlug $slug
            $exitCode = $LASTEXITCODE
            if ($exitCode -ne 0) { throw "norm_exit_$exitCode" }

            & $preflightScript -AktSlug $slug -PaketMode -ExpectedTipTeksta $expectedTipTeksta
            $exitCode = $LASTEXITCODE
            if ($exitCode -ne 0) { throw "preflight_exit_$exitCode" }
        }
        catch {
            if ($exitCode -eq 0) {
                $exitCode = 1
            }
            $status = "FAIL"
            Write-Host "AKT_FAIL: $slug | $($_.Exception.Message)"
        }

        $results += [pscustomobject]@{
            slug = $slug
            required = $required
            exit = $exitCode
            status = $status
        }
    }

    $requiredFails = @($results | Where-Object { $_.required -and $_.exit -ne 0 }).Count
    $optionalFails = @($results | Where-Object { -not $_.required -and $_.exit -ne 0 }).Count

    $packageExit = 0
    if ($requiredFails -gt 0) {
        $packageExit = 20
    }
    elseif ($optionalFails -gt 0) {
        $packageExit = 21
    }

    Write-Host ""
    Write-Host "=== INGEST SUMMARY ==="
    $results | Select-Object slug, required, exit, status | Format-Table -AutoSize

    exit $packageExit
}
finally {
    Pop-Location
}
