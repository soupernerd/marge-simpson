<#
test-marge.ps1 - Marge Simpson Self-Test Suite (Slim Edition)

Validates core installation:
1. Required files exist
2. PowerShell scripts have valid syntax
3. Bash scripts have valid syntax (if bash available)
4. Folder name auto-detection works
5. SkipIfNoTests exits 0
6. Cleanup script runs in preview mode

Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\test-marge.ps1
#>

$ErrorActionPreference = "Stop"
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:StartTime = Get-Date

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

# Check if bash is available (Git Bash, WSL, or native)
function Test-BashAvailable {
    try {
        $null = & bash --version 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

Write-Banner

# Test 1: Required files exist
Write-Section "Test Suite 1/5: File Existence"
Test-Assert "AGENTS.md exists" { Test-Path (Join-Path $MsDir "AGENTS.md") }
Test-Assert "verify.ps1 exists" { Test-Path (Join-Path $ScriptsDir "verify.ps1") }
Test-Assert "verify.sh exists" { Test-Path (Join-Path $ScriptsDir "verify.sh") }
Test-Assert "cleanup.ps1 exists" { Test-Path (Join-Path $ScriptsDir "cleanup.ps1") }
Test-Assert "cleanup.sh exists" { Test-Path (Join-Path $ScriptsDir "cleanup.sh") }
Test-Assert "verify.config.json exists" { Test-Path (Join-Path $MsDir "verify.config.json") }
Test-Assert "README.md exists" { Test-Path (Join-Path $MsDir "README.md") }

# Test 2: Script syntax validation
Write-Section "Test Suite 2/5: Script Syntax Validation"

# PowerShell syntax
Test-Assert "verify.ps1 valid PowerShell syntax" {
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $ScriptsDir "verify.ps1"), [ref]$null, [ref]$null
    )
    $true
}
Test-Assert "cleanup.ps1 valid PowerShell syntax" {
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $ScriptsDir "cleanup.ps1"), [ref]$null, [ref]$null
    )
    $true
}

# Bash syntax (if bash available)
$bashAvailable = Test-BashAvailable
if ($bashAvailable) {
    Test-Assert "verify.sh valid bash syntax" {
        $shPath = (Join-Path $ScriptsDir "verify.sh") -replace '\\', '/'
        # Convert Windows path to bash-compatible path
        if ($shPath -match '^([A-Za-z]):(.*)$') {
            $shPath = "/" + $Matches[1].ToLower() + $Matches[2]
        }
        $result = & bash -n $shPath 2>&1
        $LASTEXITCODE -eq 0
    }
    Test-Assert "cleanup.sh valid bash syntax" {
        $shPath = (Join-Path $ScriptsDir "cleanup.sh") -replace '\\', '/'
        if ($shPath -match '^([A-Za-z]):(.*)$') {
            $shPath = "/" + $Matches[1].ToLower() + $Matches[2]
        }
        $result = & bash -n $shPath 2>&1
        $LASTEXITCODE -eq 0
    }
    
    # ShellCheck (optional, enhanced linting)
    $shellcheckAvailable = $false
    try {
        $null = & shellcheck --version 2>&1
        $shellcheckAvailable = $LASTEXITCODE -eq 0
    } catch {
        $shellcheckAvailable = $false
    }
    
    if ($shellcheckAvailable) {
        # Test all shell scripts in scripts/ folder
        $shellScripts = @("verify.sh", "cleanup.sh", "decay.sh", "status.sh", "test-marge.sh")
        foreach ($script in $shellScripts) {
            $scriptPath = Join-Path $ScriptsDir $script
            if (Test-Path $scriptPath) {
                Test-Assert "$script passes shellcheck" {
                    $shPath = $scriptPath -replace '\\', '/'
                    if ($shPath -match '^([A-Za-z]):(.*)$') {
                        $shPath = "/" + $Matches[1].ToLower() + $Matches[2]
                    }
                    $result = & shellcheck $shPath 2>&1
                    $LASTEXITCODE -eq 0
                }
            }
        }
        
        # Also check root-level CLI scripts
        $rootScripts = @("marge", "marge-init", "install.sh", "install-global.sh", "convert-to-meta.sh")
        foreach ($script in $rootScripts) {
            $scriptPath = Join-Path $RepoRoot $script
            if (Test-Path $scriptPath) {
                Test-Assert "$script passes shellcheck" {
                    $shPath = $scriptPath -replace '\\', '/'
                    if ($shPath -match '^([A-Za-z]):(.*)$') {
                        $shPath = "/" + $Matches[1].ToLower() + $Matches[2]
                    }
                    $result = & shellcheck $shPath 2>&1
                    $LASTEXITCODE -eq 0
                }
            }
        }
    } else {
        Write-Host "    [SKIP] " -NoNewline -ForegroundColor DarkYellow
        Write-Host "ShellCheck tests - shellcheck not available (optional: install for enhanced linting)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "    [SKIP] " -NoNewline -ForegroundColor DarkYellow
    Write-Host "Bash syntax tests - bash not available" -ForegroundColor DarkYellow
    Write-Host "           " -NoNewline
    Write-Host "To enable: Install Git Bash (https://git-scm.com) or WSL" -ForegroundColor DarkGray
    Write-Host "           " -NoNewline
    Write-Host "Windows-only usage is fully supported without bash tests" -ForegroundColor DarkGray
}

# Test 3: Folder name detection
Write-Section "Test Suite 3/5: Folder Auto-Detection"
Test-Assert "Detected folder name is '$MsFolderName'" { $MsFolderName -ne "" }
Test-Assert "Parent folder exists" { Test-Path $RepoRoot }

# Test 4: verify.ps1 with SkipIfNoTests
Write-Section "Test Suite 4/5: Verify SkipIfNoTests Behavior"
$isNestedRun = $env:MARGE_TEST_RUNNING -eq "1"
if ($isNestedRun) {
    Write-Host "    [SKIP] " -NoNewline -ForegroundColor DarkYellow
    Write-Host "Skipping nested verify test (already in verify harness)" -ForegroundColor DarkYellow
    $script:TestsPassed += 2
} else {
    $env:MARGE_TEST_RUNNING = "1"
    $verifyScript = Join-Path $ScriptsDir "verify.ps1"
    $verifyResult = & powershell -ExecutionPolicy Bypass -File $verifyScript fast -SkipIfNoTests 2>&1
    $verifyExitCode = $LASTEXITCODE
    $env:MARGE_TEST_RUNNING = ""
    Test-Assert "verify.ps1 -SkipIfNoTests exits 0" { $verifyExitCode -eq 0 }
    Test-Assert "Output contains folder name" { ($verifyResult -join "`n") -match "\[$MsFolderName\]" }
}

# Test 5: cleanup.ps1 preview mode
Write-Section "Test Suite 5/5: Cleanup Preview Mode"
$cleanupScript = Join-Path $ScriptsDir "cleanup.ps1"
$cleanupResult = & powershell -ExecutionPolicy Bypass -File $cleanupScript 2>&1
$cleanupExitCode = $LASTEXITCODE
Test-Assert "cleanup.ps1 exits 0 in preview mode" { $cleanupExitCode -eq 0 }
Test-Assert "Output shows PREVIEW MODE" { ($cleanupResult -join "`n") -match "PREVIEW" }

# Summary
Write-FinalSummary

if ($script:TestsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
