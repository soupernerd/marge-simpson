#!/usr/bin/env pwsh
<#
cleanup.ps1 — Marge Simpson Artifact Cleanup

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

# Dynamic folder detection — works regardless of folder name
$margeDir = $PSScriptRoot
$msFolderName = Split-Path $margeDir -Leaf
$repoRoot = (Get-Item $margeDir).Parent.FullName
$previewMode = -not $Confirm

Write-Host ""
Write-Host "============================================================"
Write-Host "[$msFolderName] Intelligent Cleanup"
Write-Host "============================================================"
Write-Host ""
Write-Host "  repo_root: $repoRoot"
Write-Host "  mode: $(if ($previewMode) {'PREVIEW (pass -Confirm to apply)'} else {'APPLYING CHANGES'})"
Write-Host "  keep_logs: $KeepLogs minimum"
Write-Host "  archive_after: $ArchiveAfterDays days"
Write-Host ""

$cutoffDate = (Get-Date).AddDays(-$ArchiveAfterDays)
$changes = @{
    LogsRemoved     = 0
    LogsBytesFreed  = 0
}

# ============================================================
# 1. Clean verify_logs/ - Keep last N OR within M days (whichever keeps more)
# ============================================================

Write-Host "[1/3] Analyzing verify_logs/..."

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
                Write-Host "  [remove] $($log.Name) - $([math]::Round($log.Length/1024, 1))KB - $($log.LastWriteTime.ToString('yyyy-MM-dd'))"
            }
            
            if (-not $previewMode) {
                Remove-Item $log.FullName -Force
            }
        }
        
        Write-Host "  Total: $($allLogs.Count) logs, keeping $KeepLogs minimum + any recent"
        Write-Host "  Result: $($changes.LogsRemoved) logs $(if ($previewMode) {'would be '})removed"
    }
    elseif ($allLogs) {
        Write-Host "  Total: $($allLogs.Count) logs (below $KeepLogs threshold, keeping all)"
    }
    else {
        Write-Host "  No log files found"
    }
}
else {
    Write-Host "  No verify_logs/ directory found"
}

Write-Host ""

# ============================================================
# 2. Report on assessment.md (no auto-modification)
# ============================================================

Write-Host "[2/3] Analyzing assessment.md..."

$assessmentFile = Join-Path $margeDir "assessment.md"

if (Test-Path $assessmentFile) {
    $assessmentSize = (Get-Item $assessmentFile).Length
    $assessmentKB = [math]::Round($assessmentSize / 1024, 1)
    
    Write-Host "  Size: ${assessmentKB}KB"
    
    if ($assessmentKB -gt 50) {
        Write-Host "  [suggestion] File is large. Consider archiving completed (DONE) entries."
        Write-Host "               You can move old MS-#### entries to assessment_archive.md"
    }
    else {
        Write-Host "  Size is reasonable, no action needed"
    }
}
else {
    Write-Host "  No assessment.md found"
}

Write-Host ""

# ============================================================
# 3. Report on tasklist.md (no auto-modification)
# ============================================================

Write-Host "[3/3] Analyzing tasklist.md..."

$tasklistFile = Join-Path $margeDir "tasklist.md"

if (Test-Path $tasklistFile) {
    $tasklistSize = (Get-Item $tasklistFile).Length
    $tasklistKB = [math]::Round($tasklistSize / 1024, 1)
    $tasklistContent = Get-Content $tasklistFile -ErrorAction SilentlyContinue
    $tasklistLines = if ($tasklistContent) { $tasklistContent.Count } else { 0 }
    
    Write-Host "  Size: ${tasklistKB}KB, $tasklistLines lines"
    
    if ($tasklistKB -gt 20) {
        Write-Host "  [suggestion] Consider moving old DONE items to a 'Completed Archive' section"
    }
    else {
        Write-Host "  Size is reasonable, no action needed"
    }
}
else {
    Write-Host "  No tasklist.md found"
}

Write-Host ""

# ============================================================
# Summary
# ============================================================

Write-Host "============================================================"
Write-Host "[summary]"
Write-Host "============================================================"
Write-Host ""
Write-Host "  Logs: $($changes.LogsRemoved) $(if ($previewMode) {'would be '})removed ($([math]::Round($changes.LogsBytesFreed/1024, 1))KB)"
Write-Host ""

if ($previewMode) {
    Write-Host "[!] PREVIEW MODE - no changes made"
    Write-Host "    Run with -Confirm to apply these changes"
}
else {
    Write-Host "[OK] Changes applied"
}
Write-Host ""
