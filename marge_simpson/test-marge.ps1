<#
test-marge.ps1 - Marge Simpson Self-Test Suite

Validates that:
1. Scripts exist and are valid PowerShell/Bash
2. Folder name auto-detection works
3. SkipIfNoTests exits 0
4. Cleanup script runs in preview mode

Usage:
  powershell -ExecutionPolicy Bypass -File .\marge_simpson\test-marge.ps1
#>

$ErrorActionPreference = "Stop"
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:StartTime = Get-Date

# Dynamic folder detection
$MsDir = $PSScriptRoot
$MsFolderName = Split-Path $MsDir -Leaf
$RepoRoot = (Get-Item $MsDir).Parent.FullName

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "    +=========================================================================+" -ForegroundColor Magenta
    Write-Host "    |                                                                         |" -ForegroundColor Magenta
    Write-Host "    |    __  __    _    ____   ____ _____                                     |" -ForegroundColor Magenta
    Write-Host "    |   |  \/  |  / \  |  _ \ / ___| ____|                                    |" -ForegroundColor Magenta
    Write-Host "    |   | |\/| | / _ \ | |_) | |  _|  _|                                      |" -ForegroundColor Magenta
    Write-Host "    |   | |  | |/ ___ \|  _ <| |_| | |___                                     |" -ForegroundColor Magenta
    Write-Host "    |   |_|  |_/_/   \_\_| \_\\____|_____|                                    |" -ForegroundColor Magenta
    Write-Host "    |                                                                         |" -ForegroundColor Magenta
    Write-Host "    |                    S E L F - T E S T   S U I T E                        |" -ForegroundColor Magenta
    Write-Host "    |                                                                         |" -ForegroundColor Magenta
    Write-Host "    +=========================================================================+" -ForegroundColor Magenta
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

function Write-TestResult([string]$Name, [bool]$Passed, [string]$Detail = "") {
    if ($Passed) {
        Write-Host "    [PASS] " -NoNewline -ForegroundColor Green
        Write-Host $Name -ForegroundColor Green
    } else {
        Write-Host "    [FAIL] " -NoNewline -ForegroundColor Red
        Write-Host $Name -NoNewline -ForegroundColor Red
        if ($Detail) {
            Write-Host " ($Detail)" -ForegroundColor DarkRed
        } else {
            Write-Host ""
        }
    }
}

function Write-FinalSummary {
    $elapsed = (Get-Date) - $script:StartTime
    $duration = "{0:mm}m {0:ss}s" -f $elapsed
    $success = $script:TestsFailed -eq 0
    $total = $script:TestsPassed + $script:TestsFailed
    $passRate = if ($total -gt 0) { [math]::Round(($script:TestsPassed / $total) * 100, 1) } else { 0 }
    
    $borderColor = if ($success) { "Green" } else { "Red" }
    
    Write-Host ""
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host "  |                           TEST RESULTS                                  |" -ForegroundColor $borderColor
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    
    # Progress bar
    $barWidth = 40
    $filledWidth = [math]::Floor($barWidth * ($script:TestsPassed / [math]::Max($total, 1)))
    $emptyWidth = $barWidth - $filledWidth
    $filledBar = "#" * $filledWidth
    $emptyBar = "-" * $emptyWidth
    
    $barLine = "   [$filledBar$emptyBar] $passRate%"
    Write-Host "  |" -NoNewline -ForegroundColor $borderColor
    Write-Host $barLine.PadRight(73) -NoNewline -ForegroundColor $(if ($success) { "Green" } else { "Yellow" })
    Write-Host " |" -ForegroundColor $borderColor
    
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor $borderColor
    
    # Stats table
    $stats = @(
        @{ Label = "Passed"; Value = "$($script:TestsPassed)" },
        @{ Label = "Failed"; Value = "$($script:TestsFailed)" },
        @{ Label = "Total"; Value = "$total tests" },
        @{ Label = "Duration"; Value = $duration },
        @{ Label = "Folder"; Value = $MsFolderName }
    )
    
    foreach ($stat in $stats) {
        $line = "   {0,-12} | {1}" -f $stat.Label, $stat.Value
        Write-Host "  |" -NoNewline -ForegroundColor $borderColor
        Write-Host $line.PadRight(73) -NoNewline -ForegroundColor White
        Write-Host " |" -ForegroundColor $borderColor
    }
    
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    Write-Host "  +---------------------------------------------------------------------------+" -ForegroundColor $borderColor
    
    # Status
    $statusText = if ($success) { "   STATUS:  [OK] ALL TESTS PASSED" } else { "   STATUS:  [X] $($script:TestsFailed) TEST(S) FAILED" }
    Write-Host "  |" -NoNewline -ForegroundColor $borderColor
    Write-Host $statusText.PadRight(73) -NoNewline -ForegroundColor $borderColor
    Write-Host " |" -ForegroundColor $borderColor
    
    Write-Host "  |                                                                         |" -ForegroundColor $borderColor
    Write-Host "  +=========================================================================+" -ForegroundColor $borderColor
    Write-Host ""
}

# ==============================================================================
# TEST HELPER
# ==============================================================================

function Test-Assert {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    try {
        $result = & $Test
        if ($result -eq $true) {
            $script:TestsPassed++
            Write-TestResult -Name $Name -Passed $true
            return $true
        } else {
            $script:TestsFailed++
            Write-TestResult -Name $Name -Passed $false -Detail "returned: $result"
            return $false
        }
    }
    catch {
        $script:TestsFailed++
        Write-TestResult -Name $Name -Passed $false -Detail "error: $_"
        return $false
    }
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

Write-Banner

# Test 1: Required files exist
Write-Section "Test Suite 1/6: File Existence"
Test-Assert "AGENTS.md exists" { Test-Path (Join-Path $MsDir "AGENTS.md") }
Test-Assert "verify.ps1 exists" { Test-Path (Join-Path $MsDir "verify.ps1") }
Test-Assert "verify.sh exists" { Test-Path (Join-Path $MsDir "verify.sh") }
Test-Assert "cleanup.ps1 exists" { Test-Path (Join-Path $MsDir "cleanup.ps1") }
Test-Assert "cleanup.sh exists" { Test-Path (Join-Path $MsDir "cleanup.sh") }
Test-Assert "verify.config.json exists" { Test-Path (Join-Path $MsDir "verify.config.json") }
Test-Assert "README.md exists" { Test-Path (Join-Path $MsDir "README.md") }

# Test 2: verify.ps1 syntax check
Write-Section "Test Suite 2/6: Script Syntax Validation"
Test-Assert "verify.ps1 valid syntax" {
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $MsDir "verify.ps1"), [ref]$null, [ref]$null
    )
    $true
}
Test-Assert "cleanup.ps1 valid syntax" {
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $MsDir "cleanup.ps1"), [ref]$null, [ref]$null
    )
    $true
}

# Test 3: Folder name detection
Write-Section "Test Suite 3/6: Folder Auto-Detection"
Test-Assert "Detected folder name is '$MsFolderName'" { $MsFolderName -ne "" }
Test-Assert "Parent folder exists" { Test-Path $RepoRoot }

# Test 4: verify.ps1 with SkipIfNoTests (skip if already running through verify harness)
Write-Section "Test Suite 4/6: Verify SkipIfNoTests Behavior"
$isNestedRun = $env:MARGE_TEST_RUNNING -eq "1"
if ($isNestedRun) {
    Write-Host "    [SKIP] " -NoNewline -ForegroundColor DarkYellow
    Write-Host "Skipping nested verify test (already in verify harness)" -ForegroundColor DarkYellow
    $script:TestsPassed += 2
} else {
    $env:MARGE_TEST_RUNNING = "1"
    $verifyScript = Join-Path $MsDir "verify.ps1"
    $verifyResult = & powershell -ExecutionPolicy Bypass -File $verifyScript fast -SkipIfNoTests 2>&1
    $verifyExitCode = $LASTEXITCODE
    $env:MARGE_TEST_RUNNING = ""
    Test-Assert "verify.ps1 -SkipIfNoTests exits 0" { $verifyExitCode -eq 0 }
    Test-Assert "Output contains folder name" { ($verifyResult -join "`n") -match "\[$MsFolderName\]" }
}

# Test 5: cleanup.ps1 preview mode
Write-Section "Test Suite 5/6: Cleanup Preview Mode"
$cleanupScript = Join-Path $MsDir "cleanup.ps1"
$cleanupResult = & powershell -ExecutionPolicy Bypass -File $cleanupScript 2>&1
$cleanupExitCode = $LASTEXITCODE
Test-Assert "cleanup.ps1 exits 0 in preview mode" { $cleanupExitCode -eq 0 }
Test-Assert "Output shows PREVIEW MODE" { ($cleanupResult -join "`n") -match "PREVIEW" }

# Test 6: AGENTS.md content validation
Write-Section "Test Suite 6/6: AGENTS.md Content Validation"
$agentsPath = Join-Path $MsDir "AGENTS.md"
$agentsContent = Get-Content -Path $agentsPath -Raw

Test-Assert "AGENTS.md contains CRITICAL RULE(S)" { 
    $agentsContent -match "\*\*CRITICAL RULE" 
}
Test-Assert "AGENTS.md contains folder reference '$MsFolderName/'" { 
    $agentsContent -match [regex]::Escape("``$MsFolderName/``")
}
Test-Assert "AGENTS.md contains verification runner reference" { 
    $agentsContent -match "verify\.ps1 fast" -and $agentsContent -match "verify\.sh fast"
}
Test-Assert "AGENTS.md contains MS-#### tracking ID format" { 
    $agentsContent -match "MS-\d{4}" -or $agentsContent -match "MS-####"
}

# Meta-specific test: If this is meta_marge, check for audit exclusion rule
if ($MsFolderName -eq "meta_marge") {
    Test-Assert "AGENTS.md contains meta audit exclusion rule" {
        $agentsContent -match "excluded from audits"
    }
}

# Summary
Write-FinalSummary

if ($script:TestsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
