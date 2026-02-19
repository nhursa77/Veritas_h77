param()

$ErrorActionPreference = "Stop"
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Path $PSScriptRoot -Parent
$lintScript = Join-Path $PSScriptRoot "lint_markdown.py"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"
$pythonExe = if (Test-Path -LiteralPath $venvPython) { $venvPython } else { "python" }

if (!(Test-Path -LiteralPath $lintScript)) {
    Write-Host "MDLINT_BEGIN=True"
    Write-Host "ERROR: nedostaje skripta lint_markdown.py"
    Write-Host "MDLINT_END=True"
    Write-Host "MDLINT_EXIT=2"
    exit 2
}

Push-Location $root
try {
    $stagedChanges = @(git diff --cached --name-only)
    $candidateChanges = @()

    if ($stagedChanges.Count -gt 0) {
        $candidateChanges = $stagedChanges
    }
    else {
        $candidateChanges = @(git diff --name-only)
    }

    $mdTargets = @(
        $candidateChanges |
            ForEach-Object { [string]$_ } |
            Where-Object { $_ -match '\.md$' } |
            Sort-Object -Unique
    )

    if ($mdTargets.Count -eq 0) {
        Write-Host "MDLINT_BEGIN=True"
        Write-Host "MDLINT_TARGET_COUNT=0"
        Write-Host "MDLINT_END=True"
        Write-Host "MDLINT_EXIT=0"
        exit 0
    }

    Write-Host "MDLINT_TARGET_COUNT=$($mdTargets.Count)"
    foreach ($target in $mdTargets) {
        Write-Host "MDLINT_TARGET=$target"
    }

    & $pythonExe $lintScript @mdTargets
    $exitCode = $LASTEXITCODE
    exit $exitCode
}
finally {
    Pop-Location
}
