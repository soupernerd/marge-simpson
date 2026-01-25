#!/usr/bin/env pwsh
<#
.SYNOPSIS
    General validation tests for Marge project quality.

.DESCRIPTION
    Catches common issues before they become problems:
    - Encoding issues (non-ASCII characters that cause parsing errors)
    - Version mismatches across files
    - Missing required files
    - PS1/SH parity (ensures both platforms have equivalent scripts)
    - Documentation consistency (README references match actual files)
    
    These tests run against ALL applicable files, not specific ones.

.EXAMPLE
    .\scripts\test-general.ps1
#>

$ErrorActionPreference = "Stop"

# Find repo root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# Detect if running in .meta_marge (lightweight mode - fewer required files)
$FolderName = Split-Path -Leaf $RepoRoot
$IsMetaMarge = $FolderName -eq ".meta_marge"

$TotalTests = 0
$PassedTests = 0
$FailedTests = 0
$Errors = @()

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$FailureDetail = ""
    )
    
    $script:TotalTests++
    try {
        $result = & $Test
        if ($result -eq $true) {
            $script:PassedTests++
            Write-Host "  [PASS] $Name" -ForegroundColor Green
            return $true
        } else {
            $script:FailedTests++
            $detail = if ($FailureDetail) { " ($FailureDetail)" } else { "" }
            Write-Host "  [FAIL] $Name$detail" -ForegroundColor Red
            $script:Errors += "  [FAIL] $Name$detail"
            return $false
        }
    }
    catch {
        $script:FailedTests++
        Write-Host "  [FAIL] $Name (error: $_)" -ForegroundColor Red
        $script:Errors += "  [FAIL] $Name (error: $_)"
        return $false
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " General Validation Tests" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# Test 1: Encoding Validation (catches Unicode issues in scripts)
# ==============================================================================
Write-Host "[1/6] Checking file encoding for problematic characters..." -ForegroundColor Yellow

# Characters that commonly cause issues: em-dash, curly quotes, etc.
$problematicPatterns = @(
    @{ Pattern = [char]0x2014; Name = "em-dash"; Suggestion = "use -- instead" },
    @{ Pattern = [char]0x2013; Name = "en-dash"; Suggestion = "use - instead" },
    @{ Pattern = [char]0x2018; Name = "left single quote"; Suggestion = "use ' instead" },
    @{ Pattern = [char]0x2019; Name = "right single quote"; Suggestion = "use ' instead" },
    @{ Pattern = [char]0x201C; Name = "left double quote"; Suggestion = 'use " instead' },
    @{ Pattern = [char]0x201D; Name = "right double quote"; Suggestion = 'use " instead' }
)

$scriptFiles = Get-ChildItem -Path $RepoRoot -Include "*.ps1", "*.sh" -Recurse -File | Where-Object {
    $_.FullName -notlike "*\.meta_marge\*" -and
    $_.FullName -notlike "*\node_modules\*"
}

$encodingIssues = @()
foreach ($file in $scriptFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content) {
        foreach ($pattern in $problematicPatterns) {
            if ($content.Contains($pattern.Pattern)) {
                $relativePath = $file.FullName.Substring($RepoRoot.Length + 1)
                $encodingIssues += "$relativePath contains $($pattern.Name) ($($pattern.Suggestion))"
            }
        }
    }
}

Test-Check "No problematic Unicode in scripts" {
    $encodingIssues.Count -eq 0
} -FailureDetail ($encodingIssues -join "; ")

# Also check for UTF-8 BOM in shell scripts (can cause issues)
$bomIssues = @()
foreach ($file in ($scriptFiles | Where-Object { $_.Extension -eq ".sh" -or $_.Name -notmatch "\." })) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $relativePath = $file.FullName.Substring($RepoRoot.Length + 1)
        $bomIssues += "$relativePath has UTF-8 BOM (remove it)"
    }
}

Test-Check "No UTF-8 BOM in shell scripts" {
    $bomIssues.Count -eq 0
} -FailureDetail ($bomIssues -join "; ")

# ==============================================================================
# Test 2: Version Consistency (skip for .meta_marge)
# ==============================================================================
Write-Host ""
Write-Host "[2/6] Checking version consistency across files..." -ForegroundColor Yellow

if ($IsMetaMarge) {
    Write-Host "  [SKIP] Version tests - not applicable for .meta_marge" -ForegroundColor Cyan
} else {
    $versionFile = Join-Path $RepoRoot "VERSION"
    $expectedVersion = (Get-Content $versionFile -Raw).Trim()

    $versionFiles = @(
        @{ Path = "cli\marge"; Pattern = 'VERSION="([^"]+)"' },
        @{ Path = "cli\marge.ps1"; Pattern = '\$script:VERSION\s*=\s*"([^"]+)"' }
    )

    Test-Check "VERSION file exists and is valid" {
        (Test-Path $versionFile) -and ($expectedVersion -match '^\d+\.\d+\.\d+')
    }

    foreach ($vf in $versionFiles) {
        $filePath = Join-Path $RepoRoot $vf.Path
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw
            if ($content -match $vf.Pattern) {
                $fileVersion = $Matches[1]
                Test-Check "$($vf.Path) version matches VERSION file ($expectedVersion)" {
                    $fileVersion -eq $expectedVersion
                } -FailureDetail "found $fileVersion"
            }
        }
    }
}

# ==============================================================================
# Test 3: PS1/SH Script Parity
# ==============================================================================
Write-Host ""
Write-Host "[3/6] Checking PS1/SH script parity..." -ForegroundColor Yellow

# Core script pairs always checked
$scriptPairs = @(
    @{ Base = "scripts\verify"; Extensions = @(".ps1", ".sh") },
    @{ Base = "scripts\cleanup"; Extensions = @(".ps1", ".sh") },
    @{ Base = "scripts\decay"; Extensions = @(".ps1", ".sh") },
    @{ Base = "scripts\status"; Extensions = @(".ps1", ".sh") },
    @{ Base = "scripts\test-marge"; Extensions = @(".ps1", ".sh") },
    @{ Base = "scripts\test-syntax"; Extensions = @(".ps1", ".sh") }
)

# Additional pairs only in full Marge (not .meta_marge)
if (-not $IsMetaMarge) {
    $scriptPairs += @(
        @{ Base = "cli\install-global"; Extensions = @(".ps1", ".sh") },
        @{ Base = ".dev\convert-to-meta"; Extensions = @(".ps1", ".sh") }
    )
}

foreach ($pair in $scriptPairs) {
    $baseName = Split-Path -Leaf $pair.Base
    $allExist = $true
    $missing = @()
    
    foreach ($ext in $pair.Extensions) {
        $fullPath = Join-Path $RepoRoot "$($pair.Base)$ext"
        if (-not (Test-Path $fullPath)) {
            $allExist = $false
            $missing += "$baseName$ext"
        }
    }
    
    Test-Check "Script pair exists: $baseName (.ps1 and .sh)" {
        $allExist
    } -FailureDetail "missing: $($missing -join ', ')"
}

# ==============================================================================
# Test 4: Required Files Exist
# ==============================================================================
Write-Host ""
Write-Host "[4/6] Checking required files exist..." -ForegroundColor Yellow

# Core files always required
$requiredFiles = @(
    "AGENTS.md",
    "verify.config.json",
    "workflows\_index.md",
    "workflows\work.md",
    "workflows\audit.md",
    "workflows\loop.md",
    "workflows\planning.md",
    "workflows\session_start.md",
    "workflows\session_end.md",
    "experts\_index.md",
    "knowledge\_index.md",
    "scripts\_index.md",
    "tracking\assessment.md",
    "tracking\tasklist.md"
)

# Additional files only required in full Marge (not .meta_marge)
if (-not $IsMetaMarge) {
    $requiredFiles += @(
        "README.md",
        "CHANGELOG.md",
        "VERSION",
        "LICENSE",
        "model_pricing.json",
        "cli\marge",
        "cli\marge.ps1",
        "cli\marge-init",
        "cli\marge-init.ps1"
    )
}

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $RepoRoot $file
    Test-Check "Required file: $file" {
        Test-Path $fullPath
    }
}

# ==============================================================================
# Test 5: README Documentation Consistency (skip for .meta_marge)
# ==============================================================================
Write-Host ""
Write-Host "[5/6] Checking README references match actual files..." -ForegroundColor Yellow

$readmePath = Join-Path $RepoRoot "README.md"

if ($IsMetaMarge) {
    Write-Host "  [SKIP] README tests - not applicable for .meta_marge" -ForegroundColor Cyan
} else {
    $readmeContent = Get-Content $readmePath -Raw

    # Check that documented folders exist
    $documentedFolders = @("cli/", "scripts/", "workflows/", "experts/", "knowledge/", "tracking/", "prompts/", ".dev/")
    foreach ($folder in $documentedFolders) {
        $folderPath = Join-Path $RepoRoot ($folder.TrimEnd('/'))
        Test-Check "Documented folder exists: $folder" {
            Test-Path $folderPath -PathType Container
        }
    }

    # Check that documented CLI commands reference actual flags in marge script
    $margePath = Join-Path $RepoRoot "cli\marge"
    $margeContent = Get-Content $margePath -Raw

    $documentedFlags = @("--folder", "--dry-run", "--model", "--loop", "--engine", "--parallel", "--branch-per-task", "--create-pr", "--verbose")
    foreach ($flag in $documentedFlags) {
        Test-Check "CLI flag documented and implemented: $flag" {
            ($readmeContent -match [regex]::Escape($flag)) -and ($margeContent -match [regex]::Escape($flag))
        }
    }

    # Check README does not have outdated version numbers
    # (If README mentions a version, it should match VERSION file)
    $versionFromFile = (Get-Content (Join-Path $RepoRoot "VERSION") -Raw).Trim()
    $versionMismatch = $false
    # Look for version patterns like "v1.2.3" or "1.2.3" in README
    if ($readmeContent -match 'v?(\d+\.\d+\.\d+)') {
        $readmeVersions = [regex]::Matches($readmeContent, 'v?(\d+\.\d+\.\d+)') | 
            ForEach-Object { $_.Groups[1].Value } | 
            Select-Object -Unique
        foreach ($rv in $readmeVersions) {
            if ($rv -ne $versionFromFile -and $rv -match '^\d+\.\d+\.\d+$') {
                # Only flag if it looks like a marge version (not dependency versions)
                if ($readmeContent -match "marge.*$rv|$rv.*marge") {
                    $versionMismatch = $true
                }
            }
        }
    }
    Test-Check "README versions match VERSION file (no stale versions)" {
        -not $versionMismatch
    }
}

# ==============================================================================
# Test 6: Workflow Connectivity
# ==============================================================================
Write-Host ""
Write-Host "[6/6] Checking workflow file connectivity..." -ForegroundColor Yellow

$workflowIndex = Join-Path $RepoRoot "workflows\_index.md"
$workflowIndexContent = Get-Content $workflowIndex -Raw

$workflowFiles = @("work.md", "audit.md", "loop.md", "planning.md", "session_start.md", "session_end.md")
foreach ($wf in $workflowFiles) {
    Test-Check "Workflow $wf referenced in _index.md" {
        $workflowIndexContent -match [regex]::Escape($wf)
    }
    
    # Also check the workflow file references AGENTS.md or other workflows correctly
    $wfPath = Join-Path $RepoRoot "workflows\$wf"
    if (Test-Path $wfPath) {
        $wfContent = Get-Content $wfPath -Raw
        # Work.md should reference verification
        if ($wf -eq "work.md") {
            Test-Check "work.md references verification" {
                $wfContent -match "verify"
            }
        }
        # Audit.md should reference work.md
        if ($wf -eq "audit.md") {
            Test-Check "audit.md references work.md" {
                $wfContent -match "work\.md"
            }
        }
    }
}

# ==============================================================================
# Summary
# ==============================================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Total tests: $TotalTests"
Write-Host "  Passed: $PassedTests" -ForegroundColor Green
Write-Host "  Failed: $FailedTests" -ForegroundColor $(if ($FailedTests -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($Errors.Count -gt 0) {
    Write-Host "Errors:" -ForegroundColor Red
    foreach ($err in $Errors) {
        Write-Host $err -ForegroundColor Red
    }
    Write-Host ""
    exit 1
}

Write-Host "All general validation tests passed!" -ForegroundColor Green
exit 0
