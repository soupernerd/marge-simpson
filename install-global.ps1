<#
.SYNOPSIS
    Installs marge globally with shared resources and per-project initialization.

.DESCRIPTION
    Creates a global marge installation at ~/.marge (or custom directory) with:
    - shared/: Resources symlinked to all projects
    - templates/: Per-project files copied during init
    - marge-init.ps1: Script to initialize projects

.PARAMETER InstallDir
    Installation directory. Default: $env:USERPROFILE\.marge

.PARAMETER Force
    Overwrite existing installation.

.EXAMPLE
    .\install-global.ps1
    .\install-global.ps1 -Force
    .\install-global.ps1 -InstallDir "D:\tools\marge"
#>

param(
    [string]$InstallDir = "$env:USERPROFILE\.marge",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SrcDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src = Join-Path $SrcDir "marge_simpson"

if (-not (Test-Path $Src)) {
    Write-Error "marge_simpson/ folder not found in $SrcDir"
    exit 1
}

if (Test-Path $InstallDir) {
    if (-not $Force) {
        Write-Error "$InstallDir already exists. Use -Force to overwrite."
        exit 1
    }
    Write-Host "Removing existing installation..."
    Remove-Item -Recurse -Force $InstallDir
}

Write-Host "Installing marge globally to $InstallDir..."

# Create directory structure
New-Item -ItemType Directory -Force -Path "$InstallDir\shared" | Out-Null
New-Item -ItemType Directory -Force -Path "$InstallDir\templates" | Out-Null

# Copy shared resources
$SharedItems = @(
    "AGENTS.md",
    "assets",
    "experts",
    "knowledge",
    "model_pricing.json",
    "prompt_examples",
    "README.md",
    "scripts",
    "VERSION",
    "workflows"
)

foreach ($item in $SharedItems) {
    $srcPath = Join-Path $Src $item
    if (Test-Path $srcPath) {
        Copy-Item -Recurse -Force $srcPath "$InstallDir\shared\"
    }
}

# Copy per-project templates
$TemplateItems = @(
    "assessment.md",
    "instructions_log.md",
    "tasklist.md",
    "verify.config.json"
)

foreach ($item in $TemplateItems) {
    $srcPath = Join-Path $Src $item
    if (Test-Path $srcPath) {
        Copy-Item -Force $srcPath "$InstallDir\templates\"
    }
}

# Install marge-init script
Copy-Item -Force (Join-Path $SrcDir "marge-init.ps1") "$InstallDir\marge-init.ps1"

# Validate installation
Write-Host "Validating installation..."
$Required = @(
    "$InstallDir\shared\AGENTS.md",
    "$InstallDir\shared\scripts\verify.ps1",
    "$InstallDir\shared\workflows",
    "$InstallDir\shared\experts",
    "$InstallDir\templates\assessment.md",
    "$InstallDir\templates\tasklist.md",
    "$InstallDir\marge-init.ps1"
)

$Missing = @()
foreach ($file in $Required) {
    if (-not (Test-Path $file)) {
        $Missing += $file
    }
}

if ($Missing.Count -gt 0) {
    Write-Warning "Installation may be incomplete. Missing:"
    foreach ($f in $Missing) {
        Write-Warning "  - $f"
    }
}

Write-Host ""
Write-Host "marge installed globally to $InstallDir" -ForegroundColor Green
Write-Host ""
Write-Host "Structure:"
Write-Host "  $InstallDir\"
Write-Host "  ├── shared\        # Shared resources (symlinked to projects)"
Write-Host "  │   ├── AGENTS.md"
Write-Host "  │   ├── experts\"
Write-Host "  │   ├── workflows\"
Write-Host "  │   ├── scripts\"
Write-Host "  │   └── knowledge\"
Write-Host "  ├── templates\     # Per-project templates"
Write-Host "  │   ├── assessment.md"
Write-Host "  │   ├── tasklist.md"
Write-Host "  │   └── verify.config.json"
Write-Host "  └── marge-init.ps1 # Project initialization script"
Write-Host ""
Write-Host "To use marge-init from anywhere, add to your PowerShell profile:"
Write-Host "  Add-Content `$PROFILE 'function marge-init { & `"$InstallDir\marge-init.ps1`" @args }'"
Write-Host ""
Write-Host "Or add $InstallDir to your PATH."
Write-Host ""
Write-Host "Usage:"
Write-Host "  cd your-project"
Write-Host "  marge-init          # Initialize marge_simpson/ with symlinks"
Write-Host "  marge-init -Force   # Reinitialize (overwrites existing)"
