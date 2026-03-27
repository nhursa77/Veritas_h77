param(
    [Parameter(Mandatory = $true)]
    [string]$DiaryPath,

    [Parameter(Mandatory = $true)]
    [string]$EntryPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $DiaryPath -PathType Leaf)) {
    throw "Diary datoteka ne postoji: $DiaryPath"
}

if (-not (Test-Path -LiteralPath $EntryPath -PathType Leaf)) {
    throw "Entry datoteka ne postoji: $EntryPath"
}

$diaryText = Get-Content -LiteralPath $DiaryPath -Raw -Encoding UTF8
$entryText = Get-Content -LiteralPath $EntryPath -Raw -Encoding UTF8

if ([string]::IsNullOrWhiteSpace($entryText)) {
    throw "Entry je prazan i ne moze se dodati u dnevnik."
}

$entryNormalized = $entryText.Trim("`r", "`n")

$prefix = ""
if ([string]::IsNullOrEmpty($diaryText)) {
    $prefix = ""
}
elseif (
    $diaryText.EndsWith("`r`n`r`n") -or
    $diaryText.EndsWith("`n`n")
) {
    $prefix = ""
}
elseif (
    $diaryText.EndsWith("`r`n") -or
    $diaryText.EndsWith("`n")
) {
    $prefix = "`r`n"
}
else {
    $prefix = "`r`n`r`n"
}

$payload = $prefix + $entryNormalized + "`r`n"

# Append-only: koristi iskljucivo dodavanje na EOF bez izmjene postojecih redaka.
Add-Content -LiteralPath $DiaryPath -Value $payload -NoNewline -Encoding UTF8

$lineCount = (Get-Content -LiteralPath $DiaryPath -Encoding UTF8).Count
Write-Host "DNEVNIK_APPEND_ONLY_APPLIED=True"
Write-Host "DNEVNIK_APPEND_ONLY_PATH=$DiaryPath"
Write-Host "DNEVNIK_APPEND_ONLY_ENTRY=$EntryPath"
Write-Host "DNEVNIK_LINE_COUNT_AFTER=$lineCount"
