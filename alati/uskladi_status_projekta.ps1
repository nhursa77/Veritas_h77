param(
    [string]$StatusPath = ".\dokumentacija\STATUS_PROJEKTA_VERITAS_H77.md",
    [string]$ZadnjiZadatak
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

function Format-CommitBlock {
    param(
        [Parameter(Mandatory = $true)][string]$ShortHash,
        [Parameter(Mandatory = $true)][string]$Subject
    )

    $prefix = "- Trenutni commit: ``$ShortHash`` - "
    $line = $prefix + $Subject
    if ($line.Length -le 80) {
        return @($line)
    }

    $available = 80 - $prefix.Length
    $splitIndex = $Subject.LastIndexOf(" ", [Math]::Min($available, $Subject.Length - 1))
    if ($splitIndex -lt 1) {
        $splitIndex = [Math]::Min($available, $Subject.Length)
    }

    $first = $Subject.Substring(0, $splitIndex).TrimEnd()
    $rest = $Subject.Substring($splitIndex).TrimStart()
    return @(
        $prefix + $first,
        "  $rest"
    )
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
    $headShort = (git --no-pager log -1 --pretty=format:%h).Trim()
    $headSubject = (git --no-pager log -1 --pretty=format:%s).Trim()
    $branchLine = (git branch -vv | Where-Object { $_.StartsWith('*') } | Select-Object -First 1)
    $alignment = Get-BranchAlignment -BranchLine $branchLine

    $lines = New-Object System.Collections.ArrayList
    foreach ($line in (Get-Content -LiteralPath $statusFile -Encoding UTF8)) {
        [void]$lines.Add([string]$line)
    }

    $updated = $false
    $updated = (Replace-BlockLines -Lines $lines -Prefix '- Trenutni commit:' -NewLines (Format-CommitBlock -ShortHash $headShort -Subject $headSubject)) -or $updated
    $updated = (Replace-BlockLines -Lines $lines -Prefix '- lokalni hash:' -NewLines @("- lokalni hash: ``$headShort``")) -or $updated
    $updated = (Replace-BlockLines -Lines $lines -Prefix '- `main` poravnanje:' -NewLines @("- `main` poravnanje: $alignment")) -or $updated

    if ($PSBoundParameters.ContainsKey('ZadnjiZadatak') -and -not [string]::IsNullOrWhiteSpace($ZadnjiZadatak)) {
        $updated = (Replace-BlockLines -Lines $lines -Prefix '- Zadnji dovršeni zadatak:' -NewLines @("- Zadnji dovršeni zadatak: $ZadnjiZadatak")) -or $updated
    }

    $content = ($lines -join "`n") + "`n"
    Write-Utf8NoBom -Path $statusFile -Content $content

    Write-Host "STATUS_SYNC_HEAD=$headShort"
    Write-Host "STATUS_SYNC_SUBJECT=$headSubject"
    Write-Host "STATUS_SYNC_ALIGNMENT=$alignment"
    Write-Host "STATUS_SYNC_STATUS_CLEAN=$([string]($gitStatus.Count -eq 0))"
    Write-Host "STATUS_SYNC_UPDATED=$([string]$updated)"
    Write-Host "STATUS_SYNC_END=True"
    Write-Host "STATUS_SYNC_EXIT=0"
    exit 0
}
finally {
    Pop-Location
}