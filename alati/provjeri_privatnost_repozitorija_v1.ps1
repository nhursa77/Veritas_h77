#requires -Version 7.0

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'privatnost_predmeta_core.ps1')

$errors = [System.Collections.Generic.List[string]]::new()

function Add-GateError {
    param(
        [Parameter(Mandatory = $true)][string] $Code,
        [AllowNull()][string] $Path
    )

    $message = $Code
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $message += " PATH=$Path"
    }
    [void]$errors.Add($message)
}

function Get-IndexedText {
    param([Parameter(Mandatory = $true)][string] $Path)

    $output = @(& git show ":$Path" 2>$null)
    if ($LASTEXITCODE -ne 0) {
        Add-GateError -Code 'INDEX_READ_FAIL' -Path $Path
        return $null
    }

    return ($output | ForEach-Object { [string]$_ }) -join "`n"
}

Write-Host 'P9_PRIVACY_GATE_BEGIN=True'

Push-Location $repoRoot
try {
    if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
        Add-GateError -Code 'GIT_NOT_AVAILABLE' -Path $null
    }
    else {
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) {
            Add-GateError -Code 'NOT_A_GIT_WORKTREE' -Path $null
        }
    }

    if ($errors.Count -eq 0) {
        $indexedPaths = @(
            git -c core.quotepath=false ls-files --cached |
                ForEach-Object { ([string]$_).Replace('\', '/') } |
                Sort-Object -Unique
        )
        if ($LASTEXITCODE -ne 0) {
            Add-GateError -Code 'INDEX_LIST_FAIL' -Path $null
            $indexedPaths = @()
        }

        Write-Host "P9_PRIVACY_GATE_INDEXED_COUNT=$($indexedPaths.Count)"

        foreach ($path in $indexedPaths) {
            if (
                $path -match '^(?i)[.]veritas_lokalno/' -or
                $path -match '^(?i)predmeti/sud/prekrsajni/(STVARNI|PRIVATNI)_[^/]+'
            ) {
                Add-GateError -Code 'FORBIDDEN_TRACKED_PATH' -Path $path
            }

            if (
                $path -match '^predmeti/sud/prekrsajni/([^/]+)/' -and
                $Matches[1] -notmatch '^OGLEDNI_[A-Z0-9_]+$'
            ) {
                Add-GateError -Code 'NON_SYNTHETIC_TRACKED_SUBJECT_ROOT' -Path $path
            }
        }

        $subjectFiles = @(
            $indexedPaths |
                Where-Object {
                    $_ -match '^predmeti/sud/prekrsajni/OGLEDNI_[A-Z0-9_]+/'
                }
        )
        $subjectRoots = @(
            $subjectFiles |
                ForEach-Object { ($_ -split '/')[0..3] -join '/' } |
                Sort-Object -Unique
        )
        foreach ($subjectRoot in $subjectRoots) {
            $subjectJson = "$subjectRoot/predmet.json"
            if ($subjectJson -notin $indexedPaths) {
                Add-GateError -Code 'TRACKED_SUBJECT_MISSING_PREDMET_JSON' -Path $subjectRoot
            }
        }

        foreach ($subjectFile in $subjectFiles) {
            $extension = [System.IO.Path]::GetExtension($subjectFile).ToLowerInvariant()
            $leafName = [System.IO.Path]::GetFileName($subjectFile)
            if (
                $extension -notin @('.json', '.md', '.txt') -and
                $leafName -ne '.gitkeep'
            ) {
                Add-GateError `
                    -Code 'UNSCANNABLE_TRACKED_SUBJECT_FILE' `
                    -Path $subjectFile
            }
        }

        $predmetPaths = @(
            $indexedPaths |
                Where-Object {
                    $_ -match '^predmeti/sud/prekrsajni/OGLEDNI_[A-Z0-9_]+/predmet[.]json$'
                }
        )
        foreach ($predmetPath in $predmetPaths) {
            $raw = Get-IndexedText -Path $predmetPath
            if ($null -eq $raw) {
                continue
            }

            try {
                $document = $raw | ConvertFrom-Json
            }
            catch {
                Add-GateError -Code 'INDEXED_PREDMET_JSON_PARSE_FAIL' -Path $predmetPath
                continue
            }

            $subjectId = ($predmetPath -split '/')[3]
            $result = Test-VeritasPredmetDocument `
                -Document $document `
                -ExpectedMode public `
                -ExpectedSubjectId $subjectId
            foreach ($errorCode in $result.Errors) {
                Add-GateError -Code $errorCode -Path $predmetPath
            }
        }

        $textExtensions = @(
            '.json', '.md', '.txt', '.csv', '.tsv', '.xml', '.yml', '.yaml'
        )
        $textPaths = @(
            $indexedPaths |
                Where-Object {
                    $_ -like 'predmeti/*' -and
                    [System.IO.Path]::GetExtension($_).ToLowerInvariant() -in $textExtensions
                }
        )
        foreach ($path in $textPaths) {
            $raw = Get-IndexedText -Path $path
            if ($null -eq $raw) {
                continue
            }

            foreach ($riskCode in @(Get-VeritasHighRiskFindingCodes -Text $raw)) {
                Add-GateError `
                    -Code "HIGH_RISK_IDENTIFIER_$riskCode" `
                    -Path $path
            }
        }

        $ignoreText = Get-IndexedText -Path '.gitignore'
        if ($null -ne $ignoreText) {
            $requiredIgnoreRules = @(
                '.veritas_lokalno/',
                'predmeti/sud/prekrsajni/STVARNI_*/',
                'predmeti/sud/prekrsajni/PRIVATNI_*/'
            )
            $ignoreLines = @(
                $ignoreText -split "`n" |
                    ForEach-Object { $_.Trim() } |
                    Where-Object { $_ -ne '' }
            )
            foreach ($rule in $requiredIgnoreRules) {
                if ($rule -notin $ignoreLines) {
                    Add-GateError -Code 'INDEXED_GITIGNORE_RULE_MISSING' -Path $rule
                }
            }

            $ignoreSentinels = @(
                '.veritas_lokalno/P9_SENTINEL.txt',
                'predmeti/sud/prekrsajni/STVARNI_P9_SENTINEL/predmet.json',
                'predmeti/sud/prekrsajni/PRIVATNI_P9_SENTINEL/predmet.json'
            )
            foreach ($sentinel in $ignoreSentinels) {
                & git check-ignore -q --no-index -- $sentinel
                if ($LASTEXITCODE -ne 0) {
                    Add-GateError -Code 'EFFECTIVE_GITIGNORE_RULE_MISSING' -Path $sentinel
                }
            }
        }

        $untracked = @(
            git -c core.quotepath=false status --porcelain `
                --untracked-files=all -- predmeti/sud/prekrsajni |
                Where-Object { [string]$_ -match '^\?\? ' }
        )
        if ($LASTEXITCODE -ne 0) {
            Add-GateError -Code 'UNTRACKED_STATUS_CHECK_FAIL' -Path $null
        }
        foreach ($line in $untracked) {
            $untrackedPath = ([string]$line).Substring(3).Replace('\', '/')
            Add-GateError -Code 'UNTRACKED_SUBJECT_FILE' -Path $untrackedPath
        }
    }
}
finally {
    Pop-Location
}

foreach ($errorMessage in $errors) {
    Write-Host "ERROR: $errorMessage"
}

if ($errors.Count -gt 0) {
    Write-Host "P9_PRIVACY_GATE_ERROR_COUNT=$($errors.Count)"
    Write-Host 'P9_PRIVACY_GATE_STATUS=BLOCKED'
    Write-Host 'P9_PRIVACY_GATE_EXIT=1'
    exit 1
}

Write-Host 'P9_PRIVACY_GATE_ERROR_COUNT=0'
Write-Host 'P9_PRIVACY_GATE_STATUS=OK'
Write-Host 'P9_PRIVACY_GATE_EXIT=0'
exit 0
