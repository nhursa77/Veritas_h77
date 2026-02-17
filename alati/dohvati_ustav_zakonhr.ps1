param(
    [Parameter(Mandatory = $true)]
    [string]$Url
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$izlazMapa = Join-Path $repoRoot "izvori/operativno/zakon_hr/ustav_rh"
$htmlPutanja = Join-Path $izlazMapa "ustav_rh.html"
$metaPutanja = Join-Path $izlazMapa "meta.json"

New-Item -ItemType Directory -Path $izlazMapa -Force | Out-Null

$odgovor = Invoke-WebRequest -Uri $Url -UseBasicParsing
[System.IO.File]::WriteAllText(
    $htmlPutanja,
    $odgovor.Content,
    [System.Text.UTF8Encoding]::new($false)
)

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $htmlPutanja).Hash
$datum = Get-Date -Format "dd.MM.yyyy."

$meta = [ordered]@{
    url = $Url
    datum_pristupa = $datum
    sha256_datoteke = $hash
}

$metaJson = $meta | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText(
    $metaPutanja,
    $metaJson,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "HTML: $htmlPutanja"
Write-Host "META: $metaPutanja"
Write-Host "SHA256: $hash"
