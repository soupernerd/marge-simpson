<#
.SYNOPSIS
    Initialize .marge/ in the current project directory.

.DESCRIPTION
    Creates a hybrid setup with:
    - Symlinks to global shared resources (AGENTS.md, experts, workflows, etc.)
    - Local per-project files (tracking/assessment.md, tracking/tasklist.md)

.PARAMETER Force
    Overwrite existing .marge/ folder.

.PARAMETER NoGitignore
    Don't add .marge/ to .gitignore.

.PARAMETER MargeHome
    Path to global marge installation. Default: $env:USERPROFILE\.marge
    Can also be set via MARGE_HOME environment variable.

.EXAMPLE
    marge-init
    marge-init -Force
    marge-init -MargeHome "D:\tools\marge"
#>

param(
    [switch]$Force,
    [switch]$NoGitignore,
    [switch]$Help,
    [string]$MargeHome = $null
)

$ErrorActionPreference = "Stop"

# Show help if requested
if ($Help) {
    Write-Host @"
marge-init - Initialize .marge/ in a project directory

USAGE:
  marge-init [options]

DESCRIPTION:
  Creates a hybrid setup with:
  - Symlinks to global shared resources (AGENTS.md, experts, workflows, etc.)
  - Local per-project files (tracking/assessment.md, tracking/tasklist.md)

OPTIONS:
  -Force          Overwrite existing .marge/ folder
  -NoGitignore    Don't add .marge/ to .gitignore
  -MargeHome      Path to global marge installation
                  Default: `$env:USERPROFILE\.marge or MARGE_HOME env var
  -Help           Show this help message

EXAMPLES:
  marge-init
  marge-init -Force
  marge-init -MargeHome "D:\tools\marge"

PREREQUISITES:
  Install marge globally first using:
    .\install-global.ps1
"@
    exit 0
}

# Determine MARGE_HOME
if (-not $MargeHome) {
    $MargeHome = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }
}

$TargetDir = ".\.marge"

# Validate global installation
if (-not (Test-Path "$MargeHome\shared")) {
    Write-Error @"
Global marge installation not found at $MargeHome

Install marge globally first:
  .\install-global.ps1

Or set MARGE_HOME to your installation directory:
  `$env:MARGE_HOME = "D:\path\to\marge"
"@
    exit 1
}

if (Test-Path $TargetDir) {
    if (-not $Force) {
        Write-Error "$TargetDir already exists. Use -Force to overwrite, or remove it manually."
        exit 1
    }
    Write-Host "Removing existing $TargetDir..."
    Remove-Item -Recurse -Force $TargetDir
}

Write-Host "Initializing .marge/..."

# Create directory structure
New-Item -ItemType Directory -Force -Path "$TargetDir" | Out-Null

# Create symlinks to shared resources
# Note: Creating symlinks on Windows may require admin privileges or Developer Mode
$SharedLinks = @(
    "AGENTS.md",
    "AGENTS-lite.md",
    "assets",
    "experts",
    "knowledge",
    "model_pricing.json",
    "prompts",
    "README.md",
    "scripts",
    "VERSION",
    "workflows"
)

$SymlinkFailed = $false
foreach ($item in $SharedLinks) {
    $srcPath = "$MargeHome\shared\$item"
    $dstPath = "$TargetDir\$item"

    if (Test-Path $srcPath) {
        try {
            if (Test-Path $srcPath -PathType Container) {
                New-Item -ItemType SymbolicLink -Path $dstPath -Target $srcPath -ErrorAction Stop | Out-Null
            } else {
                New-Item -ItemType SymbolicLink -Path $dstPath -Target $srcPath -ErrorAction Stop | Out-Null
            }
        } catch {
            # Fall back to copying if symlinks fail (non-admin Windows)
            if (-not $SymlinkFailed) {
                Write-Warning "Symlinks require admin privileges or Developer Mode. Falling back to copies."
                $SymlinkFailed = $true
            }
            Copy-Item -Recurse -Force $srcPath $dstPath
        }
    }
}

# Copy per-project templates into tracking/
$TrackingDir = "$TargetDir\tracking"
New-Item -ItemType Directory -Path $TrackingDir -Force | Out-Null

$TemplateFiles = @(
    "assessment.md",
    "tasklist.md",
    "PRD.md"
)

foreach ($item in $TemplateFiles) {
    $srcPath = "$MargeHome\templates\$item"
    if (Test-Path $srcPath) {
        Copy-Item -Force $srcPath "$TrackingDir\"
    }
}

# Copy verify.config.json to root
$verifyConfigSrc = "$MargeHome\templates\verify.config.json"
if (Test-Path $verifyConfigSrc) {
    Copy-Item -Force $verifyConfigSrc "$TargetDir\"
}

# Update .gitignore
if (-not $NoGitignore) {
    $gitignorePath = ".\.gitignore"
    $margeEntry = ".marge/"

    if (Test-Path $gitignorePath) {
        $content = Get-Content $gitignorePath -Raw -ErrorAction SilentlyContinue
        if ($content -notmatch "(?m)^\.marge/`$") {
            Add-Content $gitignorePath "`n# Marge workflow folder (local tooling)`n.marge/"
            Write-Host "Added .marge/ to .gitignore"
        }
    } else {
        Set-Content $gitignorePath "# Marge workflow folder (local tooling)`n.marge/"
        Write-Host "Created .gitignore with .marge/"
    }
}

Write-Host ""
Write-Host ".marge/ initialized" -ForegroundColor Green
Write-Host ""

if ($SymlinkFailed) {
    Write-Host "Structure (copies - symlinks unavailable):"
} else {
    Write-Host "Structure:"
}

Write-Host "  .marge\"
Write-Host "  +-- AGENTS.md           -> $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  +-- experts\            -> $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  +-- workflows\          -> $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  +-- scripts\            -> $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  +-- knowledge\          -> $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  +-- tracking\\"
Write-Host "  |   +-- assessment.md   (local - per-project)"
Write-Host "  |   +-- tasklist.md     (local - per-project)"
Write-Host "  |   +-- PRD.md          (local - per-project)"
Write-Host "  +-- verify.config.json  (local - per-project)"
Write-Host ""
Write-Host "Edit verify.config.json to configure your project's test commands."
Write-Host ""
Write-Host "Ready to use marge!"
Write-Host ""
Write-Host "Quick start:" -ForegroundColor Cyan
Write-Host "  marge `"describe your first task`""
Write-Host ""
Write-Host "For help:"
Write-Host "  marge --help"

