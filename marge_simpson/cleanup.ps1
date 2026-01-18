#!/usr/bin/env pwsh
<#
cleanup.ps1 - Marge Simpson Artifact Cleanup

Intelligent cleanup of Marge artifacts. Safe by default: preview mode unless -Confirm is passed.
This script auto-detects its own folder name, so you can rename the folder if needed.

CLEANUP RULES:
1. verify_logs/   - Keep last N logs (default 10) OR logs within M days, whichever is more
2. assessment.md  - Suggest archiving if large (no auto-modification)
3. tasklist.md    - Suggest archiving if large (no auto-modification)
4. instructions_log.md - Never modify (standing instructions are permanent)

Usage:
  ./cleanup.ps1                    # Preview mode (safe)
  ./cleanup.ps1 -Confirm           # Actually perform cleanup
  ./cleanup.ps1 -KeepLogs 20       # Keep more logs
#>

param(
    [int]$KeepLogs = 10,           # Minimum logs to keep regardless of age
    [int]$ArchiveAfterDays = 7,    # Suggest archiving entries after this many days
    [switch]$Confirm = $false,     # Must pass to actually delete
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Dynamic folder detection - works regardless of folder name
$margeDir = $PSScriptRoot
$msFolderName = Split-Path $margeDir -Leaf
$repoRoot = (Get-Item $margeDir).Parent.FullName
$previewMode = -not $Confirm
$script:StartTime = Get-Date

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

function Write-RemoveItem([string]$Text) {
    Write-Host "    [-] " -NoNewline -ForegroundColor Red
    Write-Host $Text -ForegroundColor DarkRed
}

function Write-Suggestion([string]$Text) {
    Write-Host "    [*] " -NoNewline -ForegroundColor Yellow
    Write-Host $Text -ForegroundColor Yellow
}

function Write-FinalSummary {
    param(
        [int]$LogsRemoved,
        [int]$BytesFreed,
        [bool]$IsPreview
    )
    
    $elapsed = (Get-Date) - $script:StartTime
    $duration = "{0:mm}m {0:ss}s" -f $elapsed
    $freedKB = [math]::Round($BytesFreed / 1024, 1)
    
    Write-Host ""
    Write-Host "  +=========================================================================+" -ForegroundColor Yellow
    Write-Host "  |                          CLEANUP SUMMARY                                |" -ForegroundColor Yellow
    Write-Host "  +=========================================================================+" -ForegroundColor Yellow
    Write-Host "  |                                                                         |" -ForegroundColor Yellow
    
    # Stats table
    $modeText = if ($IsPreview) { "PREVIEW (no changes made)" } else { "APPLIED" }
    $stats = @(
        @{ Label = "Mode"; Value = $modeText },
        @{ Label = "Logs"; Value = "$LogsRemoved $(if ($IsPreview) {'would be '})removed (${freedKB}KB)" },
        @{ Label = "Duration"; Value = $duration },
        @{ Label = "Folder"; Value = $msFolderName }
    )
    
    foreach ($stat in $stats) {
        $line = "   {0,-12} | {1}" -f $stat.Label, $stat.Value
        Write-Host "  |" -NoNewline -ForegroundColor Yellow
        Write-Host $line.PadRight(73) -NoNewline -ForegroundColor White
        Write-Host " |" -ForegroundColor Yellow
    }
    
    Write-Host "  |                                                                         |" -ForegroundColor Yellow
    
    if ($IsPreview) {
        Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor Yellow
        Write-Host "  |" -NoNewline -ForegroundColor Yellow
        Write-Host "   [!] Run with -Confirm to apply these changes                             " -NoNewline -ForegroundColor DarkYellow
        Write-Host "|" -ForegroundColor Yellow
        Write-Host "  |                                                                         |" -ForegroundColor Yellow
    }
    
    Write-Host "  +=========================================================================+" -ForegroundColor Yellow
    Write-Host ""
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

Write-Banner

Write-Section "Configuration"
Write-Info "Repo Root: $repoRoot"
Write-Info "Mode: $(if ($previewMode) {'PREVIEW (pass -Confirm to apply)'} else {'APPLYING CHANGES'})"
Write-Info "Keep Logs: $KeepLogs minimum"
Write-Info "Archive After: $ArchiveAfterDays days"

$cutoffDate = (Get-Date).AddDays(-$ArchiveAfterDays)
$changes = @{
    LogsRemoved     = 0
    LogsBytesFreed  = 0
}

# ==============================================================================
# 1. Clean verify_logs/ - Keep last N OR within M days (whichever keeps more)
# ==============================================================================

Write-Section "Step 1/3: Analyzing verify_logs/"

$logDir = Join-Path $margeDir "verify_logs"

if (Test-Path $logDir) {
    $allLogs = Get-ChildItem -Path $logDir -Filter "*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    
    if ($allLogs -and $allLogs.Count -gt $KeepLogs) {
        # Get logs beyond the minimum keep count
        $candidatesForRemoval = $allLogs | Select-Object -Skip $KeepLogs
        
        # Further filter: only remove if also older than archive window
        $toRemove = $candidatesForRemoval | Where-Object {
            $_.LastWriteTime -lt $cutoffDate
        }
        
        foreach ($log in $toRemove) {
            $changes.LogsBytesFreed += $log.Length
            $changes.LogsRemoved++
            
            if ($Verbose -or $previewMode) {
                Write-RemoveItem "$($log.Name) - $([math]::Round($log.Length/1024, 1))KB - $($log.LastWriteTime.ToString('yyyy-MM-dd'))"
            }
            
            if (-not $previewMode) {
                Remove-Item $log.FullName -Force
            }
        }
        
        Write-Info "Total: $($allLogs.Count) logs, keeping $KeepLogs minimum + any recent"
        if ($changes.LogsRemoved -gt 0) {
            Write-Info "Result: $($changes.LogsRemoved) logs $(if ($previewMode) {'would be '})removed"
        } else {
            Write-Success "All logs are within retention policy"
        }
    }
    elseif ($allLogs) {
        Write-Success "Total: $($allLogs.Count) logs (below $KeepLogs threshold, keeping all)"
    }
    else {
        Write-Info "No log files found"
    }
}
else {
    Write-Info "No verify_logs/ directory found"
}

# ==============================================================================
# 2. Report on assessment.md (no auto-modification)
# ==============================================================================

Write-Section "Step 2/3: Analyzing assessment.md"

$assessmentFile = Join-Path $margeDir "assessment.md"

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
    Write-Info "No assessment.md found"
}

# ==============================================================================
# 3. Report on tasklist.md (no auto-modification)
# ==============================================================================

Write-Section "Step 3/3: Analyzing tasklist.md"

$tasklistFile = Join-Path $margeDir "tasklist.md"

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
    Write-Info "No tasklist.md found"
}

# ==============================================================================
# Summary
# ==============================================================================

Write-FinalSummary -LogsRemoved $changes.LogsRemoved -BytesFreed $changes.LogsBytesFreed -IsPreview $previewMode
