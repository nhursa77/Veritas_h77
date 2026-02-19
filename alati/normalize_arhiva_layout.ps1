param()

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$arhivaRoot = Join-Path $root "baza_zakona\arhiva"

function Test-SourceSetSlug {
    param([Parameter(Mandatory = $true)][string] $Name)

    if ($Name -match "_nn_[0-9]{1,3}_[0-9]{4}") { return $true }
    if ($Name -match "^nn_[0-9]{1,3}_[0-9]{4}(?:_[0-9]+)*$") { return $true }
    return $false
}

function Get-AktSlugFromMeta {
    param([Parameter(Mandatory = $true)][string] $SetDir)

    $metaPath = Join-Path $SetDir "META.json"
    if (!(Test-Path -LiteralPath $metaPath)) {
        $metaPath = Join-Path $SetDir "meta.json"
    }

    if (!(Test-Path -LiteralPath $metaPath)) {
        return $null
    }

    try {
        $meta = Get-Content -LiteralPath $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        return $null
    }

    $slug = [string]$meta.akt_slug
    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = [string]$meta.slug
    }

    if ([string]::IsNullOrWhiteSpace($slug)) {
        return $null
    }

    return $slug.Trim()
}

Push-Location $root
try {
    if (!(Test-Path -LiteralPath $arhivaRoot)) {
        throw "Nedostaje arhiva root: $arhivaRoot"
    }

    $moves = New-Object System.Collections.Generic.List[object]

    $topDirs = Get-ChildItem -LiteralPath $arhivaRoot -Directory
    foreach ($topDir in $topDirs) {
        $topName = $topDir.Name
        $childDirs = @(Get-ChildItem -LiteralPath $topDir.FullName -Directory -ErrorAction SilentlyContinue)
        $childFiles = @(Get-ChildItem -LiteralPath $topDir.FullName -File -ErrorAction SilentlyContinue)

        if (Test-SourceSetSlug -Name $topName) {
            if ($childDirs.Count -gt 0) {
                foreach ($child in $childDirs) {
                    $aktSlug = $child.Name
                    if ([string]::IsNullOrWhiteSpace($aktSlug)) {
                        continue
                    }

                    $destination = Join-Path $arhivaRoot (Join-Path $aktSlug $topName)
                    $moves.Add([pscustomobject]@{
                        Old = $child.FullName
                        New = $destination
                    })
                }
            }
            elseif ($childFiles.Count -gt 0) {
                $aktSlugFromMeta = Get-AktSlugFromMeta -SetDir $topDir.FullName
                if ($aktSlugFromMeta) {
                    $destination = Join-Path $arhivaRoot (Join-Path $aktSlugFromMeta $topName)
                    $moves.Add([pscustomobject]@{
                        Old = $topDir.FullName
                        New = $destination
                    })
                }
                else {
                    Write-Host "SKIP: $($topDir.FullName) (nije moguće odrediti akt_slug iz meta)"
                }
            }
        }
    }

    if ($moves.Count -eq 0) {
        Write-Host "Nema nekanaonskih arhiva putanja za premještanje."
        exit 0
    }

    foreach ($move in $moves) {
        $destParent = Split-Path -Path $move.New -Parent
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null

        Write-Host "MOVE: $($move.Old) -> $($move.New)"
        Move-Item -LiteralPath $move.Old -Destination $move.New -Force
    }

    foreach ($topDir in (Get-ChildItem -LiteralPath $arhivaRoot -Directory)) {
        $hasChildren = @(Get-ChildItem -LiteralPath $topDir.FullName -Force -ErrorAction SilentlyContinue).Count -gt 0
        if (-not $hasChildren) {
            Remove-Item -LiteralPath $topDir.FullName -Force
        }
    }
}
finally {
    Pop-Location
}
