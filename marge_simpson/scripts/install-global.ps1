<#
.SYNOPSIS
    Install Marge CLI globally on Windows

.DESCRIPTION
    Installs the marge command globally so it can be invoked from any directory.
    Creates a shim script in a directory on the PATH.

.PARAMETER Uninstall
    Remove marge from global path

.EXAMPLE
    .\install-global.ps1
    .\install-global.ps1 -Uninstall
#>

param(
    [switch]$Uninstall,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$script:MargeHome = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }
$script:SharedDir = "$script:MargeHome\shared"

function Write-Banner {
    Write-Host ""
    Write-Host "  __  __    _    ____   ____ _____   " -ForegroundColor Blue
    Write-Host " |  \/  |  / \  |  _ \ / ___| ____|  " -ForegroundColor Blue
    Write-Host " | |\/| | / _ \ | |_) | |  _|  _|    " -ForegroundColor Blue
    Write-Host " | |  | |/ ___ \|  _ <| |_| | |___   " -ForegroundColor Blue
    Write-Host " |_|  |_/_/   \_\_| \_\\____|_____|  " -ForegroundColor Blue
    Write-Host "        Global Installation          " -ForegroundColor Blue
    Write-Host ""
}

function Get-InstallDirectory {
    # Check common locations in PATH
    $paths = @(
        "$env:USERPROFILE\.local\bin",
        "$env:USERPROFILE\bin",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    )

    foreach ($path in $paths) {
        if ($env:PATH -split ';' | Where-Object { $_ -eq $path }) {
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            }
            return $path
        }
    }

    # Default to creating .local\bin
    $defaultPath = "$env:USERPROFILE\.local\bin"
    if (-not (Test-Path $defaultPath)) {
        New-Item -ItemType Directory -Path $defaultPath -Force | Out-Null
    }
    return $defaultPath
}

function Invoke-Uninstall {
    Write-Host "Uninstalling Marge CLI..." -ForegroundColor Blue

    $removed = 0

    $locations = @(
        "$env:USERPROFILE\.local\bin",
        "$env:USERPROFILE\bin",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    )

    foreach ($loc in $locations) {
        $margePath = "$loc\marge.ps1"
        $margeCmd = "$loc\marge.cmd"
        $margeInitPath = "$loc\marge-init.ps1"
        $margeInitCmd = "$loc\marge-init.cmd"

        if (Test-Path $margePath) {
            Remove-Item $margePath -Force
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " Removed $margePath"
            $removed++
        }
        if (Test-Path $margeCmd) {
            Remove-Item $margeCmd -Force
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " Removed $margeCmd"
            $removed++
        }
        if (Test-Path $margeInitPath) {
            Remove-Item $margeInitPath -Force
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " Removed $margeInitPath"
            $removed++
        }
        if (Test-Path $margeInitCmd) {
            Remove-Item $margeInitCmd -Force
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " Removed $margeInitCmd"
            $removed++
        }
    }

    if ($removed -eq 0) {
        Write-Host "No Marge CLI installations found." -ForegroundColor Yellow
    }
    else {
        Write-Host "Marge CLI uninstalled successfully." -ForegroundColor Green
    }
}

function Invoke-Install {
    Write-Banner

    # Check if source scripts exist
    $margeScript = "$script:SharedDir\scripts\marge.ps1"
    $margeInitScript = "$script:SharedDir\scripts\marge-init.ps1"

    if (-not (Test-Path $margeScript)) {
        Write-Host "Error: marge.ps1 not found at $margeScript" -ForegroundColor Red
        Write-Host "Please ensure Marge is properly installed in $script:MargeHome"
        exit 1
    }

    # Get install directory
    $installDir = Get-InstallDirectory

    Write-Host "Installing to $installDir..." -ForegroundColor Blue

    # Create wrapper scripts
    $margeWrapperContent = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$margeScript" %*
"@

    $margeInitWrapperContent = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$margeInitScript" %*
"@

    # Write .cmd wrappers for command prompt
    $margeWrapperContent | Out-File -FilePath "$installDir\marge.cmd" -Encoding ascii -Force
    Write-Host "  " -NoNewline
    Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
    Write-Host " Created marge.cmd"

    $margeInitWrapperContent | Out-File -FilePath "$installDir\marge-init.cmd" -Encoding ascii -Force
    Write-Host "  " -NoNewline
    Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
    Write-Host " Created marge-init.cmd"

    # Copy .ps1 scripts for PowerShell direct use
    Copy-Item $margeScript "$installDir\marge.ps1" -Force
    Write-Host "  " -NoNewline
    Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
    Write-Host " Copied marge.ps1"

    Copy-Item $margeInitScript "$installDir\marge-init.ps1" -Force
    Write-Host "  " -NoNewline
    Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
    Write-Host " Copied marge-init.ps1"

    # Check if install dir is in PATH
    $inPath = $env:PATH -split ';' | Where-Object { $_ -eq $installDir }

    Write-Host ""
    if ($inPath) {
        Write-Host ([string]([char]0x2501) * 52) -ForegroundColor Green
        Write-Host "  Marge CLI installed successfully!" -ForegroundColor Green
        Write-Host ([string]([char]0x2501) * 52) -ForegroundColor Green
        Write-Host ""
        Write-Host "Usage:"
        Write-Host "  marge help              Show help"
        Write-Host "  marge init              Initialize marge_simpson in a project"
        Write-Host "  marge fix `"bug desc`"    Create a bug fix task"
        Write-Host "  marge add `"feature`"     Create a feature task"
        Write-Host "  marge audit             Run a codebase audit"
        Write-Host "  marge verify            Run verification"
        Write-Host ""
    }
    else {
        Write-Host "Warning: $installDir is not in PATH" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Add it to your PATH by running:"
        Write-Host ""
        Write-Host "  `$env:PATH += `";$installDir`"" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To make it permanent, add to your PowerShell profile:"
        Write-Host "  `$PROFILE"
        Write-Host ""
        Write-Host "Or add to System Environment Variables via:"
        Write-Host "  Settings > System > About > Advanced system settings > Environment Variables"
    }
}

# Main
if ($Help) {
    Write-Host "Usage: install-global.ps1 [-Uninstall] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Uninstall    Remove marge from global path"
    Write-Host "  -Help         Show this help"
}
elseif ($Uninstall) {
    Invoke-Uninstall
}
else {
    Invoke-Install
}
