[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $false)]
    [switch] $Apply
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$normeRoot = Join-Path $root "baza_zakona\norme"
$arhivaRoot = Join-Path $root "baza_zakona\arhiva"
$timestampTag = (Get-Date).ToString("yyyyMMdd")

function Convert-ToSlug {
    param([Parameter(Mandatory = $true)][string] $Value)

    $v = $Value.ToLowerInvariant()
    $v = $v -replace '[^a-z0-9]+', '_'
    $v = $v.Trim('_')
    if ([string]::IsNullOrWhiteSpace($v)) {
        return "unknown"
    }

    return $v
}

function Get-SourceSetSlugFromNorma {
    param([Parameter(Mandatory = $true)][string] $NormeDir)

    $firstClanak = Get-ChildItem -LiteralPath $NormeDir -Filter "clanak_*.json" -File -ErrorAction SilentlyContinue |
        Sort-Object Name |
        Select-Object -First 1

    if ($null -eq $firstClanak) {
        return $null
    }

    try {
        $payload = Get-Content -LiteralPath $firstClanak.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        return $null
    }

    $operativni = $payload.izvori.operativni_izvor
    $dokazni = $payload.izvori.dokazni_izvor

    $sourceName = [string]$operativni.naziv
    if ([string]::IsNullOrWhiteSpace($sourceName)) {
        $sourceName = [string]$dokazni.naziv
    }
    if ([string]::IsNullOrWhiteSpace($sourceName)) {
        $sourceName = "legacy"
    }

    $sourceSlug = Convert-ToSlug -Value $sourceName
    if ($sourceSlug -eq "narodne_novine" -or $sourceSlug -eq "narodne_novine_nn_hr") {
        $sourceSlug = "narodne_novine"
    }

    $nnToken = $null
    $sidra = @($dokazni.sidra)
    foreach ($sidro in $sidra) {
        $nnBroj = [string]$sidro.nn_broj
        if ([string]::IsNullOrWhiteSpace($nnBroj)) {
            continue
        }
        if ($nnBroj -match '(?i)NN\s*([0-9]{1,3})/([0-9]{4})') {
            $nnToken = "nn_$($matches[1])_$($matches[2])"
            break
        }
    }

    if (-not $nnToken) {
        $url = [string]$operativni.url
        if ([string]::IsNullOrWhiteSpace($url)) {
            $url = [string]$dokazni.url
        }

        if ($url -match 'zakon\.hr') {
            return "zakon_hr"
        }

        return $null
    }

    return "${sourceSlug}_${nnToken}"
}

if (!(Test-Path -LiteralPath $normeRoot)) {
    throw "Nedostaje norme root: $normeRoot"
}

New-Item -ItemType Directory -Force -Path $arhivaRoot | Out-Null

$moves = @()
$normeDirs = Get-ChildItem -LiteralPath $normeRoot -Directory
foreach ($dir in $normeDirs) {
    $name = $dir.Name
    if ($name.ToLowerInvariant().EndsWith("_procisceni")) {
        continue
    }

    $aktSlug = $name
    $sourceSetSlug = Get-SourceSetSlugFromNorma -NormeDir $dir.FullName
    if ([string]::IsNullOrWhiteSpace($sourceSetSlug)) {
        $sourceSetSlug = "legacy_norme_snapshot_$timestampTag"
    }

    $destination = Join-Path $arhivaRoot (Join-Path $aktSlug $sourceSetSlug)

    if (Test-Path -LiteralPath $destination) {
        $index = 2
        do {
            $candidate = "${sourceSetSlug}_$index"
            $destination = Join-Path $arhivaRoot (Join-Path $aktSlug $candidate)
            $index++
        } while (Test-Path -LiteralPath $destination)
    }

    $moves += [pscustomobject]@{
        Old = $dir.FullName
        New = $destination
    }
}

if ($moves.Count -eq 0) {
    Write-Host "SUMMARY: 0"
    exit 0
}

if (-not $Apply.IsPresent) {
    Write-Host "INFO: Dry-run mode. Koristi -Apply za stvarne promjene."
    foreach ($move in $moves) {
        Write-Host "MOVE: $($move.Old) -> $($move.New)"
    }
    Write-Host "SUMMARY: $($moves.Count)"
    exit 0
}

$executed = 0
foreach ($move in $moves) {
    $destParent = Split-Path -Path $move.New -Parent
    New-Item -ItemType Directory -Force -Path $destParent | Out-Null

    if ($PSCmdlet.ShouldProcess($move.Old, "Move to $($move.New)")) {
        Move-Item -LiteralPath $move.Old -Destination $move.New -Force
        Write-Host "MOVE: $($move.Old) -> $($move.New)"
        $executed++
    }
}

Write-Host "SUMMARY: $executed"
exit 0
