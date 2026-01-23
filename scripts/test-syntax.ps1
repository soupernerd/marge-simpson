<#
.SYNOPSIS
    Validates PowerShell and Bash script syntax.

.DESCRIPTION
    Parses all .ps1 and .sh files in the repository to catch syntax errors
    before they cause runtime failures. This prevents issues like:
    - Escaped quote problems in here-strings
    - Invalid variable references
    - Encoding issues with special characters (em-dashes, etc.)

.EXAMPLE
    .\scripts\test-syntax.ps1
#>

$ErrorActionPreference = "Stop"

# Find repo root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Syntax Validation" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$TotalFiles = 0
$PassedFiles = 0
$FailedFiles = 0
$Errors = @()

# Validate PowerShell files
Write-Host "[1/2] Checking PowerShell (.ps1) files..." -ForegroundColor Yellow

$ps1Files = Get-ChildItem -Path $RepoRoot -Filter "*.ps1" -Recurse -File | Where-Object {
    $_.FullName -notlike "*\.meta_marge\*" -and
    $_.FullName -notlike "*\node_modules\*"
}

foreach ($file in $ps1Files) {
    $TotalFiles++
    $relativePath = $file.FullName.Substring($RepoRoot.Length + 1)
    
    try {
        # Parse the file - this will throw if there are syntax errors
        $tokens = $null
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName,
            [ref]$tokens,
            [ref]$parseErrors
        )
        
        if ($parseErrors -and $parseErrors.Count -gt 0) {
            $FailedFiles++
            foreach ($err in $parseErrors) {
                $Errors += "  [FAIL] $relativePath : Line $($err.Extent.StartLineNumber): $($err.Message)"
            }
            Write-Host "  [FAIL] $relativePath" -ForegroundColor Red
        } else {
            $PassedFiles++
            Write-Host "  [PASS] $relativePath" -ForegroundColor Green
        }
    } catch {
        $FailedFiles++
        $Errors += "  [FAIL] $relativePath : $($_.Exception.Message)"
        Write-Host "  [FAIL] $relativePath" -ForegroundColor Red
    }
}

# Validate Bash files (if bash is available)
Write-Host ""
Write-Host "[2/2] Checking Bash (.sh) files..." -ForegroundColor Yellow

# Check if bash is available and functional (not just WSL without distro)
$bashAvailable = $false
$bashCmd = Get-Command "bash" -ErrorAction SilentlyContinue
if ($bashCmd) {
    # Test if bash actually works (WSL might be installed but have no distro)
    try {
        $testResult = bash -c "echo test" 2>&1
        if ($testResult -eq "test") {
            $bashAvailable = $true
        }
    } catch {
        # bash failed to run
    }
}

if (-not $bashAvailable) {
    Write-Host "  [SKIP] bash not available or functional on this system" -ForegroundColor Yellow
} else {
    $shFiles = Get-ChildItem -Path $RepoRoot -Filter "*.sh" -Recurse -File | Where-Object {
        $_.FullName -notlike "*\.meta_marge\*" -and
        $_.FullName -notlike "*\node_modules\*"
    }
    
    # Also check files without extension that have bash shebang
    $noExtFiles = Get-ChildItem -Path $RepoRoot -File -Recurse | Where-Object {
        $_.Extension -eq "" -and
        $_.FullName -notlike "*\.meta_marge\*" -and
        $_.FullName -notlike "*\node_modules\*" -and
        $_.FullName -notlike "*\.git\*"
    }
    
    foreach ($file in $noExtFiles) {
        $firstLine = Get-Content -Path $file.FullName -First 1 -ErrorAction SilentlyContinue
        if ($firstLine -match "^#!.*bash") {
            $shFiles += $file
        }
    }
    
    foreach ($file in $shFiles) {
        $TotalFiles++
        $relativePath = $file.FullName.Substring($RepoRoot.Length + 1)
        
        # Convert Windows path to Unix path for bash
        $unixPath = $file.FullName -replace '\\', '/'
        
        try {
            # Use bash -n for syntax checking only (no execution)
            $result = bash -n "$unixPath" 2>&1
            if ($LASTEXITCODE -eq 0) {
                $PassedFiles++
                Write-Host "  [PASS] $relativePath" -ForegroundColor Green
            } else {
                $FailedFiles++
                $Errors += "  [FAIL] $relativePath : $result"
                Write-Host "  [FAIL] $relativePath" -ForegroundColor Red
            }
        } catch {
            $FailedFiles++
            $Errors += "  [FAIL] $relativePath : $($_.Exception.Message)"
            Write-Host "  [FAIL] $relativePath" -ForegroundColor Red
        }
    }
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Summary" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Total files: $TotalFiles"
Write-Host "  Passed: $PassedFiles" -ForegroundColor Green
Write-Host "  Failed: $FailedFiles" -ForegroundColor $(if ($FailedFiles -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($Errors.Count -gt 0) {
    Write-Host "Errors:" -ForegroundColor Red
    foreach ($err in $Errors) {
        Write-Host $err -ForegroundColor Red
    }
    Write-Host ""
    exit 1
}

Write-Host "All syntax checks passed!" -ForegroundColor Green
exit 0
