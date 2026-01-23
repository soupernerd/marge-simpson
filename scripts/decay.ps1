<#
.SYNOPSIS
    Marge Simpson Knowledge Decay Scanner - identifies stale entries.

.DESCRIPTION
    Scans knowledge/*.md files for entries with old Last Accessed dates.
    Flags entries for review or auto-archives based on decay rules:
    
    - Last Accessed > 90 days → Flag for review
    - Insight unverified > 60 days → Mark for verification
    - Weak preference + > 90 days → Auto-archive (with -AutoArchive)
    - Pattern not observed recently → Flag for review

.PARAMETER AutoArchive
    Automatically archive weak preferences older than 90 days.

.PARAMETER DaysThreshold
    Days since last access to consider stale (default: 90).

.PARAMETER Preview
    Show what would be archived without making changes.

.EXAMPLE
    .\scripts\decay.ps1
    .\scripts\decay.ps1 -AutoArchive
    .\scripts\decay.ps1 -DaysThreshold 60 -Preview
#>

param(
    [switch]$AutoArchive,
    [int]$DaysThreshold = 90,
    [switch]$Preview
)

$ErrorActionPreference = "Stop"

# Dynamic folder detection (scripts are now in scripts/ subfolder)
$ScriptsDir = $PSScriptRoot
$MsDir = (Get-Item $ScriptsDir).Parent.FullName
$MsFolderName = Split-Path $MsDir -Leaf
$RepoRoot = (Get-Item $MsDir).Parent.FullName
$KnowledgePath = Join-Path $MsDir "knowledge"

$Today = Get-Date

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
    Write-Host "    |              K N O W L E D G E   D E C A Y   S C A N                    |" -ForegroundColor Yellow
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

function Write-Entry([string]$Id, [string]$Title, [string]$Issue, [string]$Color = "Yellow") {
    $truncTitle = if ($Title.Length -gt 35) { $Title.Substring(0, 32) + "..." } else { $Title }
    Write-Host "    [$Id] " -NoNewline -ForegroundColor $Color
    Write-Host "$truncTitle" -NoNewline -ForegroundColor White
    Write-Host " - $Issue" -ForegroundColor DarkGray
}

# ==============================================================================
# PARSING FUNCTIONS
# ==============================================================================

function Get-KnowledgeEntries([string]$FilePath) {
    if (-not (Test-Path $FilePath)) {
        return @()
    }
    
    $content = Get-Content -Path $FilePath -Raw
    $entries = @()
    
    # Match entry blocks starting with ### [X-###]
    $pattern = '###\s*\[([A-Z]+-\d+)\]\s*([^\n]+)[\s\S]*?(?=###\s*\[|$)'
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $id = $match.Groups[1].Value
        $title = $match.Groups[2].Value.Trim()
        $block = $match.Value
        
        $entry = @{
            Id = $id
            Title = $title
            Block = $block
            LastAccessed = $null
            Strength = $null
            Verified = $null
            DaysOld = $null
            File = $FilePath
        }
        
        # Extract Last Accessed date
        if ($block -match "Last Accessed:\s*(\d{4}-\d{2}-\d{2})") {
            $entry.LastAccessed = [datetime]::Parse($Matches[1])
            $entry.DaysOld = ($Today - $entry.LastAccessed).Days
        }
        
        # Extract Strength (for preferences)
        if ($block -match "Strength:\s*(Weak|Moderate|Strong)") {
            $entry.Strength = $Matches[1]
        }
        
        # Extract Verified status (for insights)
        if ($block -match "Verified:\s*\[\s*\]") {
            $entry.Verified = $false
        } elseif ($block -match "Verified:\s*\[x\]") {
            $entry.Verified = $true
        }
        
        # Extract Observed/Stated date if no Last Accessed
        if (-not $entry.LastAccessed) {
            if ($block -match "(?:Observed|Stated|Date):\s*(\d{4}-\d{2}-\d{2})") {
                $entry.LastAccessed = [datetime]::Parse($Matches[1])
                $entry.DaysOld = ($Today - $entry.LastAccessed).Days
            }
        }
        
        $entries += $entry
    }
    
    return $entries
}

function Move-ToArchive([hashtable]$Entry, [string]$Reason) {
    $archivePath = Join-Path $KnowledgePath "archive.md"
    $sourcePath = $Entry.File
    
    # Prepare archive entry
    $archiveBlock = $Entry.Block.TrimEnd()
    $archiveBlock += "`n- **Archived:** $($Today.ToString('yyyy-MM-dd')) | Reason: $Reason`n"
    
    if ($Preview) {
        Write-Host "    [PREVIEW] Would archive $($Entry.Id) to archive.md" -ForegroundColor Magenta
        return
    }
    
    # Add to archive.md
    if (Test-Path $archivePath) {
        $archiveContent = Get-Content -Path $archivePath -Raw
        # Insert before the last line or at end
        if ($archiveContent -match "_No entries yet._") {
            $archiveContent = $archiveContent -replace "_No entries yet._", $archiveBlock
        } else {
            $archiveContent = $archiveContent.TrimEnd() + "`n`n$archiveBlock"
        }
        Set-Content -Path $archivePath -Value $archiveContent
    }
    
    # Remove from source file
    $sourceContent = Get-Content -Path $sourcePath -Raw
    $escapedBlock = [regex]::Escape($Entry.Block)
    $sourceContent = $sourceContent -replace $escapedBlock, ""
    # Clean up extra newlines
    $sourceContent = $sourceContent -replace "`n{3,}", "`n`n"
    Set-Content -Path $sourcePath -Value $sourceContent.TrimEnd()
    
    Write-Host "    [ARCHIVED] $($Entry.Id) → archive.md" -ForegroundColor Green
}

# ==============================================================================
# MAIN
# ==============================================================================

Write-Banner

if (-not (Test-Path $KnowledgePath)) {
    Write-Host "  No knowledge/ folder found at: $KnowledgePath" -ForegroundColor Yellow
    Write-Host "  Nothing to scan." -ForegroundColor Gray
    exit 0
}

Write-Host "  Scanning: $KnowledgePath" -ForegroundColor Gray
Write-Host "  Threshold: $DaysThreshold days" -ForegroundColor Gray
if ($Preview) {
    Write-Host "  Mode: PREVIEW (no changes)" -ForegroundColor Magenta
}
if ($AutoArchive) {
    Write-Host "  Auto-archive: ENABLED" -ForegroundColor Yellow
}

# Collect all entries
$allEntries = @()
$files = @("decisions.md", "preferences.md", "patterns.md", "insights.md")

foreach ($file in $files) {
    $filePath = Join-Path $KnowledgePath $file
    $entries = Get-KnowledgeEntries $filePath
    $allEntries += $entries
}

if ($allEntries.Count -eq 0) {
    Write-Host ""
    Write-Host "  No knowledge entries found." -ForegroundColor Gray
    Write-Host "  Knowledge base is empty - nothing to decay." -ForegroundColor Green
    exit 0
}

# Categorize stale entries
$staleEntries = @()
$unverifiedInsights = @()
$weakOldPreferences = @()
$toArchive = @()

foreach ($entry in $allEntries) {
    # Skip entries with no date info
    if (-not $entry.DaysOld) { continue }
    
    $fileName = Split-Path $entry.File -Leaf
    
    # Check for unverified insights > 60 days
    if ($fileName -eq "insights.md" -and $entry.Verified -eq $false -and $entry.DaysOld -gt 60) {
        $unverifiedInsights += $entry
    }
    
    # Check for weak preferences > threshold
    if ($fileName -eq "preferences.md" -and $entry.Strength -eq "Weak" -and $entry.DaysOld -gt $DaysThreshold) {
        $weakOldPreferences += $entry
        if ($AutoArchive) {
            $toArchive += @{ Entry = $entry; Reason = "Weak preference, $($entry.DaysOld) days stale" }
        }
    }
    
    # Check for general staleness
    if ($entry.DaysOld -gt $DaysThreshold) {
        $staleEntries += $entry
    }
}

# Report findings
$totalStale = $staleEntries.Count
$hasIssues = ($staleEntries.Count -gt 0) -or ($unverifiedInsights.Count -gt 0)

if ($staleEntries.Count -gt 0) {
    Write-Section "STALE ENTRIES (> $DaysThreshold days)"
    foreach ($entry in $staleEntries) {
        $color = if ($entry.DaysOld -gt 180) { "Red" } elseif ($entry.DaysOld -gt 120) { "Yellow" } else { "DarkYellow" }
        Write-Entry $entry.Id $entry.Title "$($entry.DaysOld) days old" $color
    }
}

if ($unverifiedInsights.Count -gt 0) {
    Write-Section "UNVERIFIED INSIGHTS (> 60 days)"
    foreach ($entry in $unverifiedInsights) {
        Write-Entry $entry.Id $entry.Title "Unverified for $($entry.DaysOld) days" "Cyan"
    }
}

if ($weakOldPreferences.Count -gt 0) {
    Write-Section "WEAK PREFERENCES (candidates for archive)"
    foreach ($entry in $weakOldPreferences) {
        Write-Entry $entry.Id $entry.Title "Weak + $($entry.DaysOld) days old" "Magenta"
    }
}

# Auto-archive if enabled
if ($toArchive.Count -gt 0 -and $AutoArchive) {
    Write-Section "ARCHIVING"
    foreach ($item in $toArchive) {
        Move-ToArchive $item.Entry $item.Reason
    }
}

# Summary
Write-Section "SUMMARY"

$totalEntries = $allEntries.Count
$healthyCount = $totalEntries - $totalStale
$healthPct = if ($totalEntries -gt 0) { [math]::Round(($healthyCount / $totalEntries) * 100) } else { 100 }

Write-Host ""
Write-Host "    Total entries:      $totalEntries" -ForegroundColor Gray
Write-Host "    Healthy:            $healthyCount ($healthPct%)" -ForegroundColor $(if ($healthPct -ge 80) { "Green" } elseif ($healthPct -ge 50) { "Yellow" } else { "Red" })
Write-Host "    Stale:              $($staleEntries.Count)" -ForegroundColor $(if ($staleEntries.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "    Unverified:         $($unverifiedInsights.Count)" -ForegroundColor $(if ($unverifiedInsights.Count -eq 0) { "Green" } else { "Cyan" })
if ($toArchive.Count -gt 0) {
    Write-Host "    Archived:           $($toArchive.Count)" -ForegroundColor Green
}

Write-Host ""

if (-not $hasIssues) {
    Write-Host "  [OK] Knowledge base is healthy!" -ForegroundColor Green
} else {
    Write-Host "  Recommendations:" -ForegroundColor White
    if ($staleEntries.Count -gt 0) {
        Write-Host "    - Review stale entries - update Last Accessed or archive" -ForegroundColor Gray
    }
    if ($unverifiedInsights.Count -gt 0) {
        Write-Host "    - Verify or archive unverified insights" -ForegroundColor Gray
    }
    if ($weakOldPreferences.Count -gt 0 -and -not $AutoArchive) {
        Write-Host "    - Run with -AutoArchive to clean up weak preferences" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor DarkGray
Write-Host ""

exit 0
