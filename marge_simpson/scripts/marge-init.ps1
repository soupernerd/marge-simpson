<#
.SYNOPSIS
    Initialize Marge Simpson Mode in a project

.DESCRIPTION
    Sets up the marge_simpson folder with all necessary symlinks and
    tracking files for a new project.

.PARAMETER ProjectPath
    Path to the project to initialize. Defaults to current directory.

.EXAMPLE
    marge-init
    marge-init C:\Projects\MyApp
#>

param(
    [Parameter(Position=0)]
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$script:MargeHome = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }
$script:SharedDir = "$script:MargeHome\shared"

function Write-Banner {
    Write-Host ""
    Write-Host "  __  __    _    ____   ____ _____   ___ _   _ ___ _____ " -ForegroundColor Blue
    Write-Host " |  \/  |  / \  |  _ \ / ___| ____| |_ _| \ | |_ _|_   _|" -ForegroundColor Blue
    Write-Host " | |\/| | / _ \ | |_) | |  _|  _|    | ||  \| || |  | |  " -ForegroundColor Blue
    Write-Host " | |  | |/ ___ \|  _ <| |_| | |___   | || |\  || |  | |  " -ForegroundColor Blue
    Write-Host " |_|  |_/_/   \_\_| \_\\____|_____| |___|_| \_|___| |_|  " -ForegroundColor Blue
    Write-Host ""
}

# Resolve project root
$ProjectRoot = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue)?.Path ?? $ProjectPath
if (-not (Test-Path $ProjectRoot)) {
    Write-Host "Error: Path does not exist: $ProjectPath" -ForegroundColor Red
    exit 1
}
$MargeDir = "$ProjectRoot\marge_simpson"

Write-Banner

Write-Host "Initializing Marge Simpson Mode" -ForegroundColor Blue
Write-Host "Project: $ProjectRoot"
Write-Host ""

# Check if shared directory exists
if (-not (Test-Path $script:SharedDir)) {
    Write-Host "Error: Marge shared directory not found at $($script:SharedDir)" -ForegroundColor Red
    Write-Host "Please ensure Marge is properly installed."
    Write-Host ""
    Write-Host "Expected location: $($script:MargeHome)\shared"
    exit 1
}

# Check if already initialized
if (Test-Path $MargeDir) {
    Write-Host "Warning: marge_simpson folder already exists." -ForegroundColor Yellow
    $response = Read-Host "Reinitialize? This will overwrite tracking files. (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Aborted."
        exit 0
    }
}

# Create directory structure
Write-Host "Creating directory structure..." -ForegroundColor Blue
New-Item -ItemType Directory -Path $MargeDir -Force | Out-Null
New-Item -ItemType Directory -Path "$MargeDir\verify_logs" -Force | Out-Null

# Create symlinks
Write-Host "Creating symlinks to shared resources..." -ForegroundColor Blue

function New-MargeSymlink {
    param([string]$Target, [string]$Link)

    $name = Split-Path $Link -Leaf

    # Remove existing
    if (Test-Path $Link) {
        Remove-Item $Link -Force -Recurse -ErrorAction SilentlyContinue
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force -ErrorAction Stop | Out-Null
        Write-Host "  " -NoNewline
        Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
        Write-Host " $name"
    }
    catch {
        Write-Host "  ! $name (copying instead)" -ForegroundColor Yellow
        Copy-Item $Target -Destination $Link -Recurse -Force
    }
}

New-MargeSymlink "$script:SharedDir\AGENTS.md" "$MargeDir\AGENTS.md"
New-MargeSymlink "$script:SharedDir\README.md" "$MargeDir\README.md"
New-MargeSymlink "$script:SharedDir\VERSION" "$MargeDir\VERSION"
New-MargeSymlink "$script:SharedDir\assets" "$MargeDir\assets"
New-MargeSymlink "$script:SharedDir\experts" "$MargeDir\experts"
New-MargeSymlink "$script:SharedDir\knowledge" "$MargeDir\knowledge"
New-MargeSymlink "$script:SharedDir\model_pricing.json" "$MargeDir\model_pricing.json"
New-MargeSymlink "$script:SharedDir\prompt_examples" "$MargeDir\prompt_examples"
New-MargeSymlink "$script:SharedDir\scripts" "$MargeDir\scripts"
New-MargeSymlink "$script:SharedDir\workflows" "$MargeDir\workflows"

# Create tracking files
Write-Host "Creating tracking files..." -ForegroundColor Blue

@"
# Assessment

> Point-in-time snapshot of repository status and findings.

**Next ID:** MS-0001

## Current Snapshot

| Field | Value |
|-------|-------|
| Last Audit | Never |
| Open Issues | 0 |
| In Progress | 0 |

## Known Invariants

(Add project-specific rules here)

## Findings by Area

### Critical (P0)
(None)

### Important (P1)
(None)

### Nice-to-Have (P2)
(None)

---

## Issues Log

(Issues will be logged here with MS-#### IDs)
"@ | Out-File -FilePath "$MargeDir\assessment.md" -Encoding utf8
Write-Host "  " -NoNewline
Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
Write-Host " assessment.md"

@"
# Task List

> Single source of truth for active work.

**Next ID:** MS-0001

## Work Queue

### P0 - Breaking / Blocking
(None)

### P1 - Important
(None)

### P2 - Nice-to-Have
(None)

---

## In Progress
(None)

---

## Done
(None)
"@ | Out-File -FilePath "$MargeDir\tasklist.md" -Encoding utf8
Write-Host "  " -NoNewline
Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
Write-Host " tasklist.md"

@"
# Instructions Log

> Append-only log of user instructions. Never edit, only append.

---
"@ | Out-File -FilePath "$MargeDir\instructions_log.md" -Encoding utf8
Write-Host "  " -NoNewline
Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
Write-Host " instructions_log.md"

@"
{
  "fast": [],
  "full": []
}
"@ | Out-File -FilePath "$MargeDir\verify.config.json" -Encoding utf8
Write-Host "  " -NoNewline
Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
Write-Host " verify.config.json"

# Check .gitignore
Write-Host ""
$gitignorePath = "$ProjectRoot\.gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    if ($gitignoreContent -match "marge_simpson") {
        Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
        Write-Host " marge_simpson already in .gitignore"
    }
    else {
        Write-Host "! Consider adding marge_simpson/ to .gitignore" -ForegroundColor Yellow
    }
}
else {
    Write-Host "! No .gitignore found. Consider creating one with marge_simpson/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host ([string]([char]0x2501) * 52) -ForegroundColor Green
Write-Host "  Marge Simpson Mode initialized successfully!" -ForegroundColor Green
Write-Host ([string]([char]0x2501) * 52) -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Add 'marge_simpson/' to your .gitignore"
Write-Host "  2. Configure verify.config.json with your test commands"
Write-Host "  3. Tell your AI: `"Use the marge_simpson folder for audits and fixes.`""
Write-Host ""
