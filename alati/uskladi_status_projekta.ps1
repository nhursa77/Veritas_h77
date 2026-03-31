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

function Get-BranchAlignment {
    param([Parameter(Mandatory = $true)][string]$BranchLine)

    if ($BranchLine -match '\[(?<tracking>[^\]]+)\]') {
        $tracking = $Matches['tracking']
        if ($tracking -match ':') {
            return ($tracking.Split(':', 2)[1]).Trim()
        }
        return 'poravnat'
    }

    return 'bez upstreama'
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

function Get-FlagText {
    param([Parameter(Mandatory = $true)][string]$Value)

    switch ($Value.Trim().ToUpperInvariant()) {
        'TRUE' { return 'DA' }
        'DA' { return 'DA' }
        'YES' { return 'DA' }
        '1' { return 'DA' }
        default { return 'NE' }
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

    $gitStatus = @(git status --short)
    $headShort = if ($PSBoundParameters.ContainsKey('PolazniHead') -and -not [string]::IsNullOrWhiteSpace($PolazniHead)) {
        $PolazniHead.Trim()
    }
    else {
        (git --no-pager log -1 --pretty=format:%h).Trim()
    }

    $headSubject = if ($PSBoundParameters.ContainsKey('PolazniSubject') -and -not [string]::IsNullOrWhiteSpace($PolazniSubject)) {
        $PolazniSubject.Trim()
    }
    else {
        (git --no-pager log -1 --pretty=format:%s).Trim()
    }

    $branchLine = (git branch -vv | Where-Object { $_.StartsWith('*') } | Select-Object -First 1)
    $alignment = if ($PSBoundParameters.ContainsKey('PoravnanjeGranePriPrecheck') -and -not [string]::IsNullOrWhiteSpace($PoravnanjeGranePriPrecheck)) {
        $PoravnanjeGranePriPrecheck.Trim()
    }
    else {
        Get-BranchAlignment -BranchLine $branchLine
    }

    $repoClean = if ($PSBoundParameters.ContainsKey('RepoCistPriPrecheck') -and -not [string]::IsNullOrWhiteSpace($RepoCistPriPrecheck)) {
        Get-FlagText -Value $RepoCistPriPrecheck
    }
    else {
        Get-FlagText -Value ([string]($gitStatus.Count -eq 0))
    }

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