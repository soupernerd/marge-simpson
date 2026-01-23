<#
.SYNOPSIS
    Marge Simpson Status Dashboard - instant project visibility.

.DESCRIPTION
    Displays a formatted summary of:
    - Task counts by status (backlog, in-progress, done)
    - Priority breakdown (P0, P1, P2)
    - Last verification result
    - Knowledge entry counts
    - Next task recommendation

.EXAMPLE
    .\marge_simpson\scripts\status.ps1
#>

$ErrorActionPreference = "SilentlyContinue"

# Dynamic folder detection (scripts are now in scripts/ subfolder)
$ScriptsDir = $PSScriptRoot
$MsDir = (Get-Item $ScriptsDir).Parent.FullName
$MsFolderName = Split-Path $MsDir -Leaf
$RepoRoot = (Get-Item $MsDir).Parent.FullName

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "    +=========================================================================+" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    |    __  __    _    ____   ____ _____                                     |" -ForegroundColor Cyan
    Write-Host "    |   |  \/  |  / \  |  _ \ / ___| ____|                                    |" -ForegroundColor Cyan
    Write-Host "    |   | |\/| | / _ \ | |_) | |  _|  _|                                      |" -ForegroundColor Cyan
    Write-Host "    |   | |  | |/ ___ \|  _ <| |_| | |___                                     |" -ForegroundColor Cyan
    Write-Host "    |   |_|  |_/_/   \_\_| \_\\____|_____|                                    |" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    |                   S T A T U S   D A S H B O A R D                       |" -ForegroundColor Cyan
    Write-Host "    |                                                                         |" -ForegroundColor Cyan
    Write-Host "    +=========================================================================+" -ForegroundColor Cyan
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

function Write-Row([string]$Label, [string]$Value, [string]$Color = "Gray") {
    $paddedLabel = $Label.PadRight(20)
    $paddedValue = $Value.PadRight(50)
    Write-Host "    $paddedLabel" -NoNewline -ForegroundColor DarkGray
    Write-Host "$paddedValue" -ForegroundColor $Color
}

# ==============================================================================
# PARSING FUNCTIONS
# ==============================================================================

function Get-TasklistStats {
    $tasklistPath = Join-Path $MsDir "tasklist.md"
    
    $stats = @{
        Backlog = 0
        InProgress = 0
        Done = 0
        P0 = 0
        P1 = 0
        P2 = 0
        NextTask = $null
        NextID = "MS-0001"
    }
    
    if (-not (Test-Path $tasklistPath)) {
        return $stats
    }
    
    $content = Get-Content -Path $tasklistPath -Raw
    
    # Extract Next ID
    if ($content -match "Next ID:\s*(MS-\d+)") {
        $stats.NextID = $Matches[1]
    }
    
    # Parse sections
    $currentSection = ""
    $lines = $content -split "`n"
    
    foreach ($line in $lines) {
        # Detect section headers
        if ($line -match "^##\s*Backlog") { $currentSection = "Backlog" }
        elseif ($line -match "^##\s*In-Progress") { $currentSection = "InProgress" }
        elseif ($line -match "^##\s*Done") { $currentSection = "Done" }
        
        # Count MS-#### entries
        if ($line -match "^\s*###?\s*\[?(MS-\d+)\]?") {
            $taskId = $Matches[1]
            
            switch ($currentSection) {
                "Backlog" { 
                    $stats.Backlog++
                    # Capture first backlog item as next task
                    if (-not $stats.NextTask -and $line -match "\[?(MS-\d+)\]?\s*(.+)") {
                        $stats.NextTask = "$($Matches[1]) $($Matches[2].Trim())"
                    }
                }
                "InProgress" { 
                    $stats.InProgress++
                    # In-progress takes priority for "next"
                    if ($line -match "\[?(MS-\d+)\]?\s*(.+)") {
                        $stats.NextTask = "$($Matches[1]) $($Matches[2].Trim())" 
                    }
                }
                "Done" { $stats.Done++ }
            }
        }
        
        # Count priorities (look for P0/P1/P2 markers)
        if ($currentSection -eq "Backlog" -or $currentSection -eq "InProgress") {
            if ($line -match "\bP0\b") { $stats.P0++ }
            elseif ($line -match "\bP1\b") { $stats.P1++ }
            elseif ($line -match "\bP2\b") { $stats.P2++ }
        }
    }
    
    return $stats
}

function Get-KnowledgeStats {
    $knowledgePath = Join-Path $MsDir "knowledge"
    
    $stats = @{
        Decisions = 0
        Preferences = 0
        Patterns = 0
        Insights = 0
        Archived = 0
    }
    
    if (-not (Test-Path $knowledgePath)) {
        return $stats
    }
    
    # Count entries by pattern [X-###]
    $files = @{
        "decisions.md" = "Decisions"
        "preferences.md" = "Preferences"
        "patterns.md" = "Patterns"
        "insights.md" = "Insights"
        "archive.md" = "Archived"
    }
    
    foreach ($file in $files.Keys) {
        $filePath = Join-Path $knowledgePath $file
        if (Test-Path $filePath) {
            $content = Get-Content -Path $filePath -Raw
            $matches = [regex]::Matches($content, "###\s*\[[A-Z]+-\d+\]")
            $stats[$files[$file]] = $matches.Count
        }
    }
    
    return $stats
}

# ==============================================================================
# MAIN
# ==============================================================================

Write-Banner

# Gather stats
$taskStats = Get-TasklistStats
$knowledgeStats = Get-KnowledgeStats

# Task Summary
Write-Section "TASK SUMMARY"

$totalPending = $taskStats.Backlog + $taskStats.InProgress
$totalAll = $totalPending + $taskStats.Done

Write-Row "Backlog" "$($taskStats.Backlog) items" $(if ($taskStats.Backlog -gt 0) { "Yellow" } else { "Green" })
Write-Row "In-Progress" "$($taskStats.InProgress) items" $(if ($taskStats.InProgress -gt 0) { "Cyan" } else { "Gray" })
Write-Row "Done" "$($taskStats.Done) items" "Green"
Write-Host ""
Write-Row "By Priority" "P0: $($taskStats.P0)  |  P1: $($taskStats.P1)  |  P2: $($taskStats.P2)" $(if ($taskStats.P0 -gt 0) { "Red" } elseif ($taskStats.P1 -gt 0) { "Yellow" } else { "Gray" })

# Progress bar
if ($totalAll -gt 0) {
    $pct = [math]::Round(($taskStats.Done / $totalAll) * 100)
    $barWidth = 40
    $filled = [math]::Floor($barWidth * $taskStats.Done / $totalAll)
    $empty = $barWidth - $filled
    $bar = ("#" * $filled) + ("-" * $empty)
    Write-Host ""
    Write-Host "    Progress        " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$bar] $pct%" -ForegroundColor $(if ($pct -eq 100) { "Green" } elseif ($pct -ge 50) { "Yellow" } else { "Gray" })
}

# Verification Status
# Knowledge Base
Write-Section "KNOWLEDGE BASE"

$totalKnowledge = $knowledgeStats.Decisions + $knowledgeStats.Preferences + $knowledgeStats.Patterns + $knowledgeStats.Insights
Write-Row "Decisions" "$($knowledgeStats.Decisions) entries" $(if ($knowledgeStats.Decisions -gt 0) { "Cyan" } else { "Gray" })
Write-Row "Preferences" "$($knowledgeStats.Preferences) entries" $(if ($knowledgeStats.Preferences -gt 0) { "Cyan" } else { "Gray" })
Write-Row "Patterns" "$($knowledgeStats.Patterns) entries" $(if ($knowledgeStats.Patterns -gt 0) { "Cyan" } else { "Gray" })
Write-Row "Insights" "$($knowledgeStats.Insights) entries" $(if ($knowledgeStats.Insights -gt 0) { "Cyan" } else { "Gray" })
if ($knowledgeStats.Archived -gt 0) {
    Write-Row "Archived" "$($knowledgeStats.Archived) entries" "DarkGray"
}

# Next Up
Write-Section "NEXT UP"

if ($taskStats.NextTask) {
    $truncated = if ($taskStats.NextTask.Length -gt 60) { 
        $taskStats.NextTask.Substring(0, 57) + "..." 
    } else { 
        $taskStats.NextTask 
    }
    Write-Row "Task" $truncated "White"
} else {
    Write-Row "Task" "No pending tasks - run an audit?" "Green"
}

Write-Row "Next ID" $taskStats.NextID "DarkGray"

Write-Host ""
Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host ""
