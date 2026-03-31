param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$FilePaths
)

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent

function Get-LineLengthLimit {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $configPath = Join-Path $RepoRoot ".markdownlint.json"
    if (!(Test-Path -LiteralPath $configPath)) {
        return 80
    }

    try {
        $config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($null -ne $config.MD013 -and $null -ne $config.MD013.line_length) {
            return [int]$config.MD013.line_length
        }
    }
    catch {
    }

    return 80
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $repoUri = [System.Uri]((Resolve-Path -LiteralPath $RepoRoot).Path + [System.IO.Path]::DirectorySeparatorChar)
    $fileUri = [System.Uri](Resolve-Path -LiteralPath $Path).Path
    return $repoUri.MakeRelativeUri($fileUri).ToString().Replace('%20', ' ')
}

$maxLen = Get-LineLengthLimit -RepoRoot $root
$violations = New-Object System.Collections.Generic.List[string]
$targets = @()

foreach ($filePath in $FilePaths) {
    $resolved = if ([System.IO.Path]::IsPathRooted($filePath)) {
        $filePath
    }
    else {
        Join-Path $root $filePath
    }

    if (!(Test-Path -LiteralPath $resolved)) {
        throw "nedostaje markdown datoteka: $filePath"
    }

    $targets += $resolved
}

Write-Host "MARKDOWN_SCOPE_BEGIN=True"
Write-Host "MARKDOWN_SCOPE_FILES=$($targets.Count)"
foreach ($target in ($targets | Sort-Object -Unique)) {
    Write-Host "MARKDOWN_SCOPE_FILE=$(Get-RelativePath -RepoRoot $root -Path $target)"
}

foreach ($target in ($targets | Sort-Object -Unique)) {
    $relative = Get-RelativePath -RepoRoot $root -Path $target
    $lines = Get-Content -LiteralPath $target -Encoding UTF8
    $seenHeadings = @{}

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNo = $i + 1
        $line = [string]$lines[$i]

        if ($line.Length -gt $maxLen) {
            $violations.Add("${relative}:${lineNo}: MD013 line-length expected<=$maxLen actual=$($line.Length)")
        }

        if ($line -match '^(#{1,6})\s+(.*)$') {
            $headingText = $Matches[2].Trim()
            if ($headingText -match '[\.;:!?]$') {
                $violations.Add("${relative}:${lineNo}: MD026 no-trailing-punctuation trailing punctuation in heading")
            }

            if ($seenHeadings.ContainsKey($headingText)) {
                $violations.Add("${relative}:${lineNo}: MD024 no-duplicate-heading duplicate heading '$headingText'")
            }
            else {
                $seenHeadings[$headingText] = $lineNo
            }
        }
    }
}

foreach ($violation in $violations) {
    Write-Host "MARKDOWN_SCOPE_VIOLATION: $violation"
}

$exitCode = if ($violations.Count -eq 0) { 0 } else { 1 }
Write-Host "MARKDOWN_SCOPE_VIOLATIONS=$($violations.Count)"
Write-Host "MARKDOWN_SCOPE_END=True"
Write-Host "MARKDOWN_SCOPE_EXIT=$exitCode"
exit $exitCode