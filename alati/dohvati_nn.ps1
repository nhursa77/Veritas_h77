param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$AktSlug,

    [Parameter(Mandatory = $true)]
    [string]$NazivAkta,

    [Parameter(Mandatory = $true)]
    [ValidateSet("ustav", "zakon", "pravilnik", "drugo")]
    [string]$VrstaAkta
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Path $PSScriptRoot -Parent
$targetDir = Join-Path $root ("izvori\dokazno\narodne_novine\" + $AktSlug)
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$headers = @{
    "User-Agent" = "Veritas-H77/1.0"
}

$response = Invoke-WebRequest -Uri $Url -Headers $headers -MaximumRedirection 5 -UseBasicParsing

$contentType = [string]$response.Headers["Content-Type"]
$tipSadrzaja = if ([string]::IsNullOrWhiteSpace($contentType)) { "nepoznato" } else { $contentType }
$urlLower = $Url.ToLowerInvariant()
$ext = ".html"
$format = "html"

if ($contentType -match "application/pdf" -or $urlLower.EndsWith(".pdf")) {
    $ext = ".pdf"
    $format = "pdf"
}

$sourcePath = Join-Path $targetDir ("izvor_nn" + $ext)

if ($format -eq "pdf") {
    Invoke-WebRequest -Uri $Url -Headers $headers -OutFile $sourcePath -MaximumRedirection 5 -UseBasicParsing
}
else {
    $response.Content | Set-Content -Path $sourcePath -Encoding UTF8
}

$velicinaBajta = (Get-Item -LiteralPath $sourcePath).Length
$sha256 = (Get-FileHash -Path $sourcePath -Algorithm SHA256).Hash.ToUpperInvariant()
$datumPristupa = Get-Date -Format "dd.MM.yyyy."

$oznakaAkta = $null
$regex = [regex]"/(?<godina>\d{4})_\d{2}_(?<broj>\d+)_"
$m = $regex.Match($Url)
if ($m.Success) {
    $godina = $m.Groups["godina"].Value
    $broj = $m.Groups["broj"].Value
    $oznakaAkta = "NN $broj/$godina"
}

$meta = [ordered]@{
    naziv_akta = $NazivAkta
    vrsta_akta = $VrstaAkta
    slug = $AktSlug
    naziv_izvora = "Narodne novine"
    url = $Url
    akt_url = $Url
    tip_sadrzaja = $tipSadrzaja
    velicina_bajta = $velicinaBajta
    oznaka_akta = $oznakaAkta
    datum_pristupa = $datumPristupa
    sha256_datoteke = $sha256
    format = $format
    napomena = "Primarni izvor arhiviran za Veritas H.77."
}

$metaPath = Join-Path $targetDir "meta.json"
$metaJson = $meta | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($metaPath, $metaJson, [System.Text.UTF8Encoding]::new($false))

Write-Output "Arhivirano: $sourcePath"
Write-Output "Meta: $metaPath"
Write-Output "SHA-256: $sha256"
