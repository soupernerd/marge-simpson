<#
.SYNOPSIS
    Initialize marge_simpson/ in the current project directory.

.DESCRIPTION
    Creates a hybrid setup with:
    - Symlinks to global shared resources (AGENTS.md, experts, workflows, etc.)
    - Local per-project files (assessment.md, tasklist.md, verify_logs/)

.PARAMETER Force
    Overwrite existing marge_simpson/ folder.

.PARAMETER NoGitignore
    Don't add marge_simpson/ to .gitignore.

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
    [string]$MargeHome = $null
)

$ErrorActionPreference = "Stop"

# Determine MARGE_HOME
if (-not $MargeHome) {
    $MargeHome = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }
}

$TargetDir = ".\marge_simpson"

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

Write-Host "Initializing marge_simpson/..."

# Create directory structure
New-Item -ItemType Directory -Force -Path "$TargetDir\verify_logs" | Out-Null

# Create symlinks to shared resources
# Note: Creating symlinks on Windows may require admin privileges or Developer Mode
$SharedLinks = @(
    "AGENTS.md",
    "assets",
    "bak",
    "experts",
    "knowledge",
    "model_pricing.json",
    "plans",
    "prompt_examples",
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

# Copy per-project templates
$TemplateFiles = @(
    "assessment.md",
    "instructions_log.md",
    "tasklist.md",
    "verify.config.json"
)

foreach ($item in $TemplateFiles) {
    $srcPath = "$MargeHome\templates\$item"
    if (Test-Path $srcPath) {
        Copy-Item -Force $srcPath "$TargetDir\"
    }
}

# Update .gitignore
if (-not $NoGitignore) {
    $gitignorePath = ".\.gitignore"
    $margeEntry = "marge_simpson/"

    if (Test-Path $gitignorePath) {
        $content = Get-Content $gitignorePath -Raw -ErrorAction SilentlyContinue
        if ($content -notmatch "(?m)^marge_simpson/`$") {
            Add-Content $gitignorePath "`n# Marge workflow folder (local tooling)`nmarge_simpson/"
            Write-Host "Added marge_simpson/ to .gitignore"
        }
    } else {
        Set-Content $gitignorePath "# Marge workflow folder (local tooling)`nmarge_simpson/"
        Write-Host "Created .gitignore with marge_simpson/"
    }
}

Write-Host ""
Write-Host "marge_simpson/ initialized" -ForegroundColor Green
Write-Host ""

if ($SymlinkFailed) {
    Write-Host "Structure (copies - symlinks unavailable):"
} else {
    Write-Host "Structure:"
}

Write-Host "  marge_simpson\"
Write-Host "  ├── AGENTS.md           → $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  ├── experts\            → $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  ├── workflows\          → $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  ├── scripts\            → $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  ├── knowledge\          → $MargeHome\shared\ $(if($SymlinkFailed){'(copy)'}else{'(symlink)'})"
Write-Host "  ├── assessment.md       (local - per-project)"
Write-Host "  ├── tasklist.md         (local - per-project)"
Write-Host "  ├── verify.config.json  (local - per-project)"
Write-Host "  ├── instructions_log.md (local - per-project)"
Write-Host "  └── verify_logs\        (local - per-project)"
Write-Host ""
Write-Host "Edit verify.config.json to configure your project's test commands."
Write-Host ""
Write-Host "Ready to use marge! Start with:"
Write-Host "  - Read marge_simpson\AGENTS.md for workflow rules"
Write-Host "  - Add tasks to marge_simpson\tasklist.md"
Write-Host "  - Run verification: .\marge_simpson\scripts\verify.ps1 fast"
