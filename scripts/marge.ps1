<#
.SYNOPSIS
    marge - CLI wrapper for Marge Simpson Mode

.DESCRIPTION
    A command-line interface for managing Marge tasks, audits, and verification.

.PARAMETER Command
    The command to execute: fix, add, audit, status, verify, init, help

.PARAMETER Args
    Additional arguments for the command

.EXAMPLE
    marge fix "the login button is broken"
    marge add "dark mode support"
    marge audit
    marge verify fast
#>

param(
    [Parameter(Position=0)]
    [string]$Command = "help",

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

$script:MargeHome = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }
$script:SharedDir = "$script:MargeHome\shared"

function Write-Banner {
    Write-Host ""
    Write-Host "  __  __    _    ____   ____ _____ " -ForegroundColor Blue
    Write-Host " |  \/  |  / \  |  _ \ / ___| ____|" -ForegroundColor Blue
    Write-Host " | |\/| | / _ \ | |_) | |  _|  _|  " -ForegroundColor Blue
    Write-Host " | |  | |/ ___ \|  _ <| |_| | |___ " -ForegroundColor Blue
    Write-Host " |_|  |_/_/   \_\_| \_\\____|_____|" -ForegroundColor Blue
    Write-Host ""
}

function Show-Help {
    Write-Banner
    Write-Host "Usage: marge [command] [args...]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  fix <description>    Create a bug fix task"
    Write-Host "  add <description>    Create a feature task"
    Write-Host "  audit                Run a codebase audit"
    Write-Host "  status               Show current task status"
    Write-Host "  verify [fast|full]   Run verification (default: fast)"
    Write-Host "  init                 Initialize marge_simpson folder"
    Write-Host "  help                 Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  marge fix `"the login button is broken`""
    Write-Host "  marge add `"dark mode support`""
    Write-Host "  marge audit"
    Write-Host "  marge verify fast"
    Write-Host ""
    Write-Host "Environment:"
    Write-Host "  MARGE_HOME           Marge installation directory (default: ~/.marge)"
}

function Find-ProjectRoot {
    $dir = Get-Location
    while ($dir -and $dir.Path -ne [System.IO.Path]::GetPathRoot($dir.Path)) {
        if (Test-Path "$($dir.Path)\marge_simpson") {
            return $dir.Path
        }
        if (Test-Path "$($dir.Path)\.git") {
            return $dir.Path
        }
        $dir = Split-Path $dir.Path -Parent
        if ($dir) { $dir = Get-Item $dir }
    }
    return (Get-Location).Path
}

function Test-MargeFolder {
    param([string]$ProjectRoot)

    if (-not (Test-Path "$ProjectRoot\marge_simpson")) {
        Write-Host "Warning: marge_simpson folder not found in project." -ForegroundColor Yellow
        Write-Host "Run " -NoNewline
        Write-Host "marge init" -ForegroundColor Green -NoNewline
        Write-Host " to set up Marge in this project."
        return $false
    }
    return $true
}

function Invoke-Init {
    $projectRoot = Find-ProjectRoot
    $margeDir = "$projectRoot\marge_simpson"

    if (Test-Path $margeDir) {
        Write-Host "marge_simpson folder already exists at $margeDir" -ForegroundColor Yellow
        return
    }

    Write-Host "Initializing Marge in $projectRoot..." -ForegroundColor Blue

    # Create directories
    New-Item -ItemType Directory -Path $margeDir -Force | Out-Null
    New-Item -ItemType Directory -Path "$margeDir\verify_logs" -Force | Out-Null

    # Create symlinks (Windows requires admin or developer mode)
    try {
        New-Item -ItemType SymbolicLink -Path "$margeDir\AGENTS.md" -Target "$script:SharedDir\AGENTS.md" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\README.md" -Target "$script:SharedDir\README.md" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\VERSION" -Target "$script:SharedDir\VERSION" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\assets" -Target "$script:SharedDir\assets" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\experts" -Target "$script:SharedDir\experts" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\knowledge" -Target "$script:SharedDir\knowledge" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\model_pricing.json" -Target "$script:SharedDir\model_pricing.json" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\prompt_examples" -Target "$script:SharedDir\prompt_examples" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\scripts" -Target "$script:SharedDir\scripts" -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path "$margeDir\workflows" -Target "$script:SharedDir\workflows" -Force | Out-Null
    }
    catch {
        Write-Host "Note: Could not create symlinks. You may need to run as administrator or enable Developer Mode." -ForegroundColor Yellow
        Write-Host "Copying files instead..." -ForegroundColor Yellow
        Copy-Item "$script:SharedDir\*" -Destination $margeDir -Recurse -Force
    }

    # Create local tracking files
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
"@ | Out-File -FilePath "$margeDir\assessment.md" -Encoding utf8

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
"@ | Out-File -FilePath "$margeDir\tasklist.md" -Encoding utf8

    @"
# Instructions Log

> Append-only log of user instructions. Never edit, only append.

---
"@ | Out-File -FilePath "$margeDir\instructions_log.md" -Encoding utf8

    @"
{
  "fast": [],
  "full": []
}
"@ | Out-File -FilePath "$margeDir\verify.config.json" -Encoding utf8

    Write-Host "Marge initialized successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Created:"
    Write-Host "  - $margeDir\assessment.md"
    Write-Host "  - $margeDir\tasklist.md"
    Write-Host "  - $margeDir\instructions_log.md"
    Write-Host "  - $margeDir\verify.config.json"
    Write-Host ""
    Write-Host "Add " -NoNewline
    Write-Host "marge_simpson/" -ForegroundColor Yellow -NoNewline
    Write-Host " to your .gitignore (tracking files are internal)."
    Write-Host "Tell your AI: " -NoNewline
    Write-Host "`"Use the marge_simpson folder for audits and fixes.`"" -ForegroundColor Green
}

function Invoke-Fix {
    param([string[]]$Description)

    $desc = $Description -join " "
    if (-not $desc) {
        Write-Host "Error: Please provide a bug description" -ForegroundColor Red
        Write-Host "Usage: marge fix <description>"
        return
    }

    Write-Banner
    Write-Host "Bug Report: " -ForegroundColor Green -NoNewline
    Write-Host $desc
    Write-Host ""
    Write-Host "Instruction for AI assistant:"
    Write-Host "---"
    Write-Host "Use the marge_simpson folder. Fix this bug: $desc"
    Write-Host "Follow AGENTS.md workflow. Create MS-#### tracking ID."
    Write-Host "---"
}

function Invoke-Add {
    param([string[]]$Description)

    $desc = $Description -join " "
    if (-not $desc) {
        Write-Host "Error: Please provide a feature description" -ForegroundColor Red
        Write-Host "Usage: marge add <description>"
        return
    }

    Write-Banner
    Write-Host "Feature Request: " -ForegroundColor Green -NoNewline
    Write-Host $desc
    Write-Host ""
    Write-Host "Instruction for AI assistant:"
    Write-Host "---"
    Write-Host "Use the marge_simpson folder. Add this feature: $desc"
    Write-Host "Follow AGENTS.md workflow. Create MS-#### tracking ID."
    Write-Host "---"
}

function Invoke-Audit {
    Write-Banner
    Write-Host "Audit Request" -ForegroundColor Green
    Write-Host ""
    Write-Host "Instruction for AI assistant:"
    Write-Host "---"
    Write-Host "Use the marge_simpson folder. Run a full codebase audit."
    Write-Host "Follow workflows/audit.md process. Create MS-#### for each finding."
    Write-Host "---"
}

function Invoke-Status {
    $projectRoot = Find-ProjectRoot

    if (-not (Test-MargeFolder $projectRoot)) {
        return
    }

    Write-Banner

    $statusScript = "$projectRoot\marge_simpson\scripts\status.ps1"
    $taskList = "$projectRoot\marge_simpson\tasklist.md"

    if (Test-Path $statusScript) {
        & $statusScript
    }
    elseif (Test-Path $taskList) {
        Write-Host "=== Task List ===" -ForegroundColor Blue
        Get-Content $taskList | Select-Object -First 50
    }
    else {
        Write-Host "No status information available" -ForegroundColor Yellow
    }
}

function Invoke-Verify {
    param([string]$Mode = "fast")

    $projectRoot = Find-ProjectRoot

    if (-not (Test-MargeFolder $projectRoot)) {
        return
    }

    Write-Banner
    Write-Host "Running verification (mode: $Mode)..." -ForegroundColor Blue

    $verifyScript = "$projectRoot\marge_simpson\scripts\verify.ps1"
    if (Test-Path $verifyScript) {
        & $verifyScript $Mode
    }
    else {
        Write-Host "verify.ps1 not found" -ForegroundColor Yellow
    }
}

# Main command router
switch ($Command.ToLower()) {
    "fix" { Invoke-Fix $Args }
    "add" { Invoke-Add $Args }
    "audit" { Invoke-Audit }
    "status" { Invoke-Status }
    "verify" { Invoke-Verify ($Args[0] ?? "fast") }
    "init" { Invoke-Init }
    "help" { Show-Help }
    "--help" { Show-Help }
    "-h" { Show-Help }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Run 'marge help' for usage information."
    }
}
