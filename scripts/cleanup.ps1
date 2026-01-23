#!/usr/bin/env pwsh
<#
cleanup.ps1 - Marge Simpson Artifact Cleanup

Reports on Marge tracking files and suggests archiving when they get large.
This script auto-detects its own folder name, so you can rename the folder if needed.

CLEANUP RULES:
1. planning_docs/assessment.md  - Suggest archiving if large (no auto-modification)
2. planning_docs/tasklist.md    - Suggest archiving if large (no auto-modification)

Usage:
  ./cleanup.ps1                    # Analyze and report
#>

param(
    [int]$ArchiveAfterDays = 7     # Suggest archiving entries after this many days
)

$ErrorActionPreference = "Stop"

# Dynamic folder detection (scripts are now in scripts/ subfolder)
$scriptsDir = $PSScriptRoot
$margeDir = (Get-Item $scriptsDir).Parent.FullName
$msFolderName = Split-Path $margeDir -Leaf
$repoRoot = (Get-Item $margeDir).Parent.FullName

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "    +=========================================================================+" -ForegroundColor Yellow
    Write-Host "    |                                                                         |" -ForegroundColor Yellow
    Write-Host "    |    __  __    _    ____   ____ _____                                     |" -ForegroundColor Yellow
    Write-Host "    |   |  \/  |  / \  |  _ \ / ___| ____|                                    |" -ForegroundColor Yellow
    Write-Host "    |   | |\/| | / _ \ | |_) | |  _|  _|                                      |" -ForegroundColor Yellow
    Write-Host "    |   | |  | |/ ___ \|  _ <| |_| | |___                                     |" -ForegroundColor Yellow
    Write-Host "    |   |_|  |_/_/   \_\_| \_\\____|_____|                                    |" -ForegroundColor Yellow
    Write-Host "    |                                                                         |" -ForegroundColor Yellow
    Write-Host "    |               A R T I F A C T   C L E A N U P                           |" -ForegroundColor Yellow
    Write-Host "    |                                                                         |" -ForegroundColor Yellow
    Write-Host "    +=========================================================================+" -ForegroundColor Yellow
    Write-Host ""
}

function Write-Section([string]$Title) {
    Write-Host ""
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  | " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Title".PadRight(73) -NoNewline -ForegroundColor White
    Write-Host " |" -ForegroundColor DarkGray
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
}

function Write-Info([string]$Text) {
    Write-Host "    [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Gray
}

function Write-Success([string]$Text) {
    Write-Host "    [OK] " -NoNewline -ForegroundColor Green
    Write-Host $Text -ForegroundColor Green
}

function Write-Suggestion([string]$Text) {
    Write-Host "    [*] " -NoNewline -ForegroundColor Yellow
    Write-Host $Text -ForegroundColor Yellow
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

Write-Banner

Write-Section "PREVIEW MODE - Analysis Only"
Write-Info "This script analyzes Marge files and suggests actions"
Write-Info "No files are modified automatically"

Write-Section "Configuration"
Write-Info "Folder: $msFolderName"
Write-Info "Repo Root: $repoRoot"
Write-Info "Archive After: $ArchiveAfterDays days"

# ==============================================================================
# 1. Report on planning_docs/assessment.md
# ==============================================================================

Write-Section "Step 1/2: Analyzing planning_docs/assessment.md"

$assessmentFile = Join-Path $margeDir "planning_docs\assessment.md"

if (Test-Path $assessmentFile) {
    $assessmentSize = (Get-Item $assessmentFile).Length
    $assessmentKB = [math]::Round($assessmentSize / 1024, 1)
    
    Write-Info "Size: ${assessmentKB}KB"
    
    if ($assessmentKB -gt 50) {
        Write-Suggestion "File is large. Consider archiving completed (DONE) entries."
        Write-Info "You can move old MS-#### entries to assessment_archive.md"
    }
    else {
        Write-Success "Size is reasonable, no action needed"
    }
}
else {
    Write-Info "No planning_docs/assessment.md found"
}

# ==============================================================================
# 2. Report on planning_docs/tasklist.md
# ==============================================================================

Write-Section "Step 2/2: Analyzing planning_docs/tasklist.md"

$tasklistFile = Join-Path $margeDir "planning_docs\tasklist.md"

if (Test-Path $tasklistFile) {
    $tasklistSize = (Get-Item $tasklistFile).Length
    $tasklistKB = [math]::Round($tasklistSize / 1024, 1)
    $tasklistContent = Get-Content $tasklistFile -ErrorAction SilentlyContinue
    $tasklistLines = if ($tasklistContent) { $tasklistContent.Count } else { 0 }
    
    Write-Info "Size: ${tasklistKB}KB, $tasklistLines lines"
    
    if ($tasklistKB -gt 20) {
        Write-Suggestion "Consider moving old DONE items to a 'Completed Archive' section"
    }
    else {
        Write-Success "Size is reasonable, no action needed"
    }
}
else {
    Write-Info "No planning_docs/tasklist.md found"
}

Write-Host ""
Write-Host "  +=========================================================================+" -ForegroundColor Yellow
Write-Host "  |                          ANALYSIS COMPLETE                              |" -ForegroundColor Yellow
Write-Host "  +=========================================================================+" -ForegroundColor Yellow
Write-Host ""
