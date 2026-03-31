param(
    [string]$StatusPath = ".\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md",
    [string]$ZadnjiZadatak,
    [string]$PolazniHead,
    [string]$PolazniSubject,
    [string]$RepoCistPriPrecheck,
    [string]$PoravnanjeGranePriPrecheck
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Format-HeadBlock {
    param(
        [Parameter(Mandatory = $true)][string]$ShortHash,
        [Parameter(Mandatory = $true)][string]$Subject
    )

    $prefix = "- Polazni HEAD prije zadatka: ``$ShortHash`` - "
    $words = $Subject -split '\s+' | Where-Object { $_ -ne '' }
    $lines = New-Object System.Collections.Generic.List[string]
    $currentPrefix = $prefix
    $currentText = ''

    foreach ($word in $words) {
        $candidate = if ([string]::IsNullOrEmpty($currentText)) { $word } else { "$currentText $word" }
        $candidateLine = $currentPrefix + $candidate

        if ($candidateLine.Length -le 80 -or [string]::IsNullOrEmpty($currentText)) {
            $currentText = $candidate
            continue
        }

        $lines.Add($currentPrefix + $currentText)
        $currentPrefix = '  '
        $currentText = $word
    }

    if (-not [string]::IsNullOrEmpty($currentText)) {
        $lines.Add($currentPrefix + $currentText)
    }

    return $lines
}

function Replace-BlockLines {
    param(
        [Parameter(Mandatory = $true)][System.Collections.ArrayList]$Lines,
        [Parameter(Mandatory = $true)][string]$Prefix,
        [Parameter(Mandatory = $true)][string[]]$NewLines
    )

    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].StartsWith($Prefix)) {
            $removeCount = 1
            while (($index + $removeCount) -lt $Lines.Count -and $Lines[$index + $removeCount].StartsWith('  ')) {
                $removeCount++
            }

            $Lines.RemoveRange($index, $removeCount)
            for ($insert = $NewLines.Length - 1; $insert -ge 0; $insert--) {
                $Lines.Insert($index, $NewLines[$insert])
            }
            return $true
        }
    }

    return $false
}

function Replace-BlockLinesAll {
    param(
        [Parameter(Mandatory = $true)][System.Collections.ArrayList]$Lines,
        [Parameter(Mandatory = $true)][string]$Prefix,
        [Parameter(Mandatory = $true)][string[]]$NewLines
    )

    $replaceCount = 0
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].StartsWith($Prefix)) {
            $removeCount = 1
            while (($index + $removeCount) -lt $Lines.Count -and $Lines[$index + $removeCount].StartsWith('  ')) {
                $removeCount++
            }

            $Lines.RemoveRange($index, $removeCount)
            for ($insert = $NewLines.Length - 1; $insert -ge 0; $insert--) {
                $Lines.Insert($index, $NewLines[$insert])
            }

            $index += $NewLines.Length - 1
            $replaceCount++
        }
    }

    return $replaceCount
}

function Get-RequiredPrecheckValue {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [AllowEmptyString()][string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Nedostaje obavezni pre-check parametar: $Name"
    }

    return $Value.Trim()
}

function Get-RepoCleanValue {
    param([Parameter(Mandatory = $true)][string]$Value)

    switch ($Value.Trim().ToUpperInvariant()) {
        'DA' { return 'DA' }
        'NE' { return 'NE' }
        default { throw 'Parametar RepoCistPriPrecheck mora biti DA ili NE.' }
    }
}

Write-Host "STATUS_SYNC_BEGIN=True"

Push-Location $root
try {
    $statusFile = if ([System.IO.Path]::IsPathRooted($StatusPath)) {
        $StatusPath
    }
    else {
        Join-Path $root $StatusPath
    }

    if (!(Test-Path -LiteralPath $statusFile)) {
        Write-Host "STATUS_SYNC_ERROR=nedostaje_status_datoteka"
        Write-Host "STATUS_SYNC_EXIT=2"
        exit 2
    }

    $headShort = Get-RequiredPrecheckValue -Name 'PolazniHead' -Value $PolazniHead
    $headSubject = Get-RequiredPrecheckValue -Name 'PolazniSubject' -Value $PolazniSubject
    $alignment = Get-RequiredPrecheckValue -Name 'PoravnanjeGranePriPrecheck' -Value $PoravnanjeGranePriPrecheck
    $repoClean = Get-RepoCleanValue -Value (Get-RequiredPrecheckValue -Name 'RepoCistPriPrecheck' -Value $RepoCistPriPrecheck)

    $lines = New-Object System.Collections.ArrayList
    foreach ($line in (Get-Content -LiteralPath $statusFile -Encoding UTF8)) {
        [void]$lines.Add([string]$line)
    }

    $updated = $false
    $updated = ((Replace-BlockLinesAll -Lines $lines -Prefix '- Polazni HEAD prije zadatka:' -NewLines (Format-HeadBlock -ShortHash $headShort -Subject $headSubject)) -gt 0) -or $updated
    $updated = ((Replace-BlockLinesAll -Lines $lines -Prefix '- Repo čist pri pre-checku:' -NewLines @("- Repo čist pri pre-checku: $repoClean")) -gt 0) -or $updated
    $updated = ((Replace-BlockLinesAll -Lines $lines -Prefix '- Poravnanje grane pri pre-checku:' -NewLines @("- Poravnanje grane pri pre-checku: $alignment")) -gt 0) -or $updated

    if ($PSBoundParameters.ContainsKey('ZadnjiZadatak') -and -not [string]::IsNullOrWhiteSpace($ZadnjiZadatak)) {
        $updated = (Replace-BlockLines -Lines $lines -Prefix '- Zadnji dovršeni zadatak:' -NewLines @("- Zadnji dovršeni zadatak: $ZadnjiZadatak")) -or $updated
    }

    $content = ($lines -join "`n") + "`n"
    Write-Utf8NoBom -Path $statusFile -Content $content

    Write-Host "STATUS_SYNC_PRECHECK_HEAD=$headShort"
    Write-Host "STATUS_SYNC_PRECHECK_SUBJECT=$headSubject"
    Write-Host "STATUS_SYNC_PRECHECK_ALIGNMENT=$alignment"
    Write-Host "STATUS_SYNC_PRECHECK_CLEAN=$repoClean"
    Write-Host "STATUS_SYNC_UPDATED=$([string]$updated)"
    Write-Host "STATUS_SYNC_END=True"
    Write-Host "STATUS_SYNC_EXIT=0"
    exit 0
}
finally {
    Pop-Location
}