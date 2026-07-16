#requires -Version 7.0

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$hookPath = Join-Path $repoRoot '.githooks\pre-commit'

Write-Host 'P9_HOOK_INSTALL_BEGIN=True'

if (-not (Test-Path -LiteralPath $hookPath -PathType Leaf)) {
    Write-Host 'ERROR: PRE_COMMIT_HOOK_MISSING'
    Write-Host 'P9_HOOK_INSTALL_EXIT=1'
    exit 1
}

Push-Location $repoRoot
try {
    & git config --local core.hooksPath .githooks
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'ERROR: GIT_HOOKS_PATH_CONFIG_FAIL'
        Write-Host 'P9_HOOK_INSTALL_EXIT=1'
        exit 1
    }

    $configuredPath = [string](& git config --local --get core.hooksPath)
    if ($LASTEXITCODE -ne 0 -or $configuredPath.Trim() -ne '.githooks') {
        Write-Host 'ERROR: GIT_HOOKS_PATH_VERIFY_FAIL'
        Write-Host 'P9_HOOK_INSTALL_EXIT=1'
        exit 1
    }
}
finally {
    Pop-Location
}

Write-Host 'P9_HOOKS_PATH=.githooks'
Write-Host 'P9_HOOK_INSTALL_STATUS=OK'
Write-Host 'P9_HOOK_INSTALL_EXIT=0'
exit 0
