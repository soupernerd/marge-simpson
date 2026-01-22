<#
.SYNOPSIS
    Converts marge_simpson folder into meta_marge for meta-development.

.DESCRIPTION
    This script copies marge_simpson to meta_marge (or updates existing meta_marge)
    and transforms ALL internal paths and references from marge_simpson to meta_marge.
    
    It dynamically discovers all files in the source folder - no hardcoded file lists.
    This ensures the script works even when marge_simpson changes (files added, removed, renamed).

.PARAMETER Force
    Overwrite existing meta_marge folder without prompting.

.PARAMETER SourceName
    Name of source folder (default: marge_simpson)

.PARAMETER TargetName
    Name of target folder (default: meta_marge)

.EXAMPLE
    .\convert-to-meta.ps1
    .\convert-to-meta.ps1 -Force
    .\convert-to-meta.ps1 -SourceName "marge_simpson" -TargetName "my_meta_marge"
#>

param(
    [switch]$Force,
    [string]$SourceName = "marge_simpson",
    [string]$TargetName = "meta_marge"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceFolder = Join-Path $repoRoot $SourceName
$targetFolder = Join-Path $repoRoot $TargetName

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Convert $SourceName -> $TargetName" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Validate source exists
if (-not (Test-Path $sourceFolder)) {
    Write-Host "ERROR: Source folder not found: $sourceFolder" -ForegroundColor Red
    exit 1
}

# Prevent converting to itself
if ($SourceName -eq $TargetName) {
    Write-Host "ERROR: Source and target names cannot be the same." -ForegroundColor Red
    exit 1
}

# Check if target exists
if (Test-Path $targetFolder) {
    if (-not $Force) {
        $response = Read-Host "$TargetName already exists. Overwrite? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Aborted." -ForegroundColor Yellow
            exit 0
        }
    }
    Write-Host "[1/5] Removing existing $TargetName..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $targetFolder
} else {
    Write-Host "[1/5] Target folder does not exist, will create fresh." -ForegroundColor Green
}

# Copy folder
Write-Host "[2/5] Copying $SourceName -> $TargetName..." -ForegroundColor Green
Copy-Item -Recurse -Force $sourceFolder $targetFolder

# Build comprehensive replacement patterns
# Order matters: longer/more specific patterns first to avoid partial replacements
$replacements = @(
    # Path references with slashes (most specific first)
    @{ Old = "./$SourceName/"; New = "./$TargetName/" },
    @{ Old = ".\$SourceName\"; New = ".\$TargetName\" },
    @{ Old = "$SourceName/"; New = "$TargetName/" },
    @{ Old = "$SourceName\"; New = "$TargetName\" },
    
    # Bracketed references (markdown links, log prefixes)
    @{ Old = "[$SourceName]"; New = "[$TargetName]" },
    
    # Quoted references (JSON, strings)
    @{ Old = "'$SourceName'"; New = "'$TargetName'" },
    @{ Old = "`"$SourceName`""; New = "`"$TargetName`"" },
    
    # Backtick references (markdown code)
    @{ Old = "``$SourceName``"; New = "``$TargetName``" },
    
    # Word boundary patterns (various contexts)
    @{ Old = " $SourceName "; New = " $TargetName " },
    @{ Old = " $SourceName."; New = " $TargetName." },
    @{ Old = " $SourceName,"; New = " $TargetName," },
    @{ Old = " ${SourceName}:"; New = " ${TargetName}:" },
    @{ Old = " $SourceName`n"; New = " $TargetName`n" },
    @{ Old = " $SourceName`r"; New = " $TargetName`r" },
    @{ Old = "($SourceName)"; New = "($TargetName)" },
    @{ Old = ": $SourceName"; New = ": $TargetName" },
    @{ Old = "# $SourceName"; New = "# $TargetName" },
    @{ Old = "=$SourceName"; New = "=$TargetName" },
    
    # Start of line patterns
    @{ Old = "$SourceName "; New = "$TargetName " },
    @{ Old = "${SourceName}:"; New = "${TargetName}:" }
)

# Text file extensions to transform
$textExtensions = @(
    ".md", ".txt", ".json", ".yml", ".yaml", ".toml",
    ".ps1", ".sh", ".bash", ".zsh",
    ".py", ".js", ".ts", ".jsx", ".tsx",
    ".html", ".css", ".scss", ".less",
    ".xml", ".config", ".cfg", ".ini",
    ".env", ".gitignore", ".dockerignore",
    ".sql", ".graphql", ".prisma"
)

# Files with no extension that are likely text
$textFilenames = @(
    "Makefile", "Dockerfile", "Jenkinsfile", "Procfile",
    "LICENSE", "README", "CHANGELOG", "CONTRIBUTING",
    ".gitignore", ".dockerignore", ".editorconfig"
)

Write-Host "[3/5] Transforming file contents (dynamic discovery)..." -ForegroundColor Green

# Dynamically discover ALL files in the target folder
$allFiles = Get-ChildItem -Path $targetFolder -Recurse -File

$transformedCount = 0
$skippedCount = 0

# Files that document the dual-folder scenario and should NOT have marge_simpson replaced
# These files intentionally contain both folder names to explain how the system works
$dualFolderDocFiles = @(
    "workflows\_index.md",
    "workflows/_index.md"
)

foreach ($file in $allFiles) {
    $ext = $file.Extension.ToLower()
    $name = $file.Name
    
    # Determine if this is a text file
    $isTextFile = ($textExtensions -contains $ext) -or ($textFilenames -contains $name) -or ($ext -eq "")
    
    # Skip binary files and verify_logs
    if ($file.FullName -like "*\verify_logs\*") {
        continue
    }
    
    # Skip dual-folder documentation files (they intentionally contain both folder names)
    $relPath = $file.FullName.Substring($targetFolder.Length + 1)
    $isDualFolderDoc = $dualFolderDocFiles | Where-Object { $relPath -like "*$_" }
    if ($isDualFolderDoc) {
        Write-Host "  Skipped (dual-folder doc): $relPath" -ForegroundColor DarkYellow
        continue
    }
    
    if (-not $isTextFile) {
        $skippedCount++
        continue
    }
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) {
            continue
        }
        
        $originalContent = $content
        
        # Apply all replacements
        foreach ($r in $replacements) {
            $content = $content.Replace($r.Old, $r.New)
        }
        
        # Also do a regex replacement for any remaining word-boundary matches
        # This catches edge cases the literal replacements might miss
        # BUT: Exclude patterns where both folder names appear together (documentation explaining the dual-folder setup)
        # First, protect contextual references by temporarily replacing them
        $contextualPatterns = @(
            # Dual-folder documentation patterns (workflows/_index.md and similar)
            @{ Pattern = "both ``$SourceName/`` and ``$TargetName/``"; Placeholder = "###BOTH_FOLDERS_BACKTICK###" },
            @{ Pattern = "both ``$TargetName/`` and ``$SourceName/``"; Placeholder = "###BOTH_FOLDERS_BACKTICK_REV###" },
            @{ Pattern = "``$SourceName/`` and ``$TargetName/``"; Placeholder = "###AND_FOLDERS_BACKTICK###" },
            @{ Pattern = "``$TargetName/`` and ``$SourceName/``"; Placeholder = "###AND_FOLDERS_BACKTICK_REV###" },
            @{ Pattern = "``$SourceName/`` (source of truth)"; Placeholder = "###SOURCE_TRUTH###" },
            @{ Pattern = "``$TargetName/`` (working copy"; Placeholder = "###WORKING_COPY###" },
            @{ Pattern = "Read ``$SourceName/AGENTS.md``"; Placeholder = "###READ_SOURCE_AGENTS###" },
            @{ Pattern = "IDs in ``$SourceName/tasklist.md``"; Placeholder = "###IDS_SOURCE_TASKLIST###" },
            # Additional patterns for workflows/_index.md Scope Inference section
            @{ Pattern = "When both ``$SourceName/`` and ``$TargetName/`` exist"; Placeholder = "###WHEN_BOTH_EXIST###" },
            @{ Pattern = "I noticed you have both ``$SourceName/`` and ``$TargetName/``"; Placeholder = "###NOTICED_BOTH###" },
            @{ Pattern = "- ``$SourceName/`` (source of truth)"; Placeholder = "###LIST_SOURCE###" },
            @{ Pattern = "- ``$TargetName/`` (working copy for meta-development)"; Placeholder = "###LIST_TARGET###" },
            @{ Pattern = "Only ``$SourceName/`` exists"; Placeholder = "###ONLY_SOURCE_EXISTS###" },
            @{ Pattern = "Read ``$SourceName/AGENTS.md`` "; Placeholder = "###READ_AGENTS_ARROW###" },
            @{ Pattern = " ``$SourceName/tasklist.md``"; Placeholder = "###TASKLIST_SOURCE###" }
        )
        
        # Protect contextual patterns
        foreach ($ctx in $contextualPatterns) {
            $content = $content.Replace($ctx.Pattern, $ctx.Placeholder)
        }
        
        # Now do the main replacement
        $content = $content -replace "\b$([regex]::Escape($SourceName))\b", $TargetName
        
        # Restore protected patterns
        foreach ($ctx in $contextualPatterns) {
            $content = $content.Replace($ctx.Placeholder, $ctx.Pattern)
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $relPath = $file.FullName.Substring($targetFolder.Length + 1)
            Write-Host "  Transformed: $relPath" -ForegroundColor Gray
            $transformedCount++
        }
    } catch {
        # Skip files that can't be read (binary, locked, etc.)
        $skippedCount++
    }
}

Write-Host "  $transformedCount files transformed, $skippedCount skipped (binary/non-text)" -ForegroundColor Gray

# Reset work queues for fresh meta-development
Write-Host "[4/5] Resetting work queues for meta-development..." -ForegroundColor Green

# Reset assessment.md
$assessmentPath = Join-Path $targetFolder "assessment.md"
if (Test-Path $assessmentPath) {
    $assessmentContent = @"
# $TargetName Assessment

> This file tracks issues found in the Marge system itself (meta-development).
> Use this to improve the production Marge before copying it to other repos.

**Next ID:** MS-0001

---

## Triage (New Issues)

_None_

---

## Accepted (Ready to Work)

_None_

---

## In-Progress

_None_

---

## Done

_None_
"@
    Set-Content -Path $assessmentPath -Value $assessmentContent
    Write-Host "  Reset: assessment.md" -ForegroundColor Gray
}

# Reset tasklist.md
$tasklistPath = Join-Path $targetFolder "tasklist.md"
if (Test-Path $tasklistPath) {
    $tasklistContent = @"
# $TargetName Tasklist

> Work queue for meta-development tasks (improving Marge itself).

**Next ID:** MS-0001

---

## Backlog

_None_

---

## In-Progress

_None_

---

## Done

_None_
"@
    Set-Content -Path $tasklistPath -Value $tasklistContent
    Write-Host "  Reset: tasklist.md" -ForegroundColor Gray
}

# Reset instructions_log.md
$instructionsLogPath = Join-Path $targetFolder "instructions_log.md"
if (Test-Path $instructionsLogPath) {
    $instructionsLogContent = @"
# $TargetName Instructions Log

> Log of instructions and decisions during meta-development.

---

_No entries yet._
"@
    Set-Content -Path $instructionsLogPath -Value $instructionsLogContent
    Write-Host "  Reset: instructions_log.md" -ForegroundColor Gray
}

# Clear verify_logs
$verifyLogsPath = Join-Path $targetFolder "verify_logs"
if (Test-Path $verifyLogsPath) {
    Get-ChildItem -Path $verifyLogsPath -File -ErrorAction SilentlyContinue | Remove-Item -Force
    Write-Host "  Cleared: verify_logs/" -ForegroundColor Gray
}

# Transform AGENTS.md for meta_marge (add audit exclusion rule)
$agentsPath = Join-Path $targetFolder "AGENTS.md"
if (Test-Path $agentsPath) {
    $agentsContent = Get-Content -Path $agentsPath -Raw
    
    # The source marge_simpson has only 1 CRITICAL RULE. For meta_marge, we need 2 rules:
    # 1. Audit exclusion (meta_marge is the tooling, not the target)
    # 2. Files stay within the folder
    $singleRulePattern = "**CRITICAL RULES:** (REQUIRED)`n1. Marge NEVER creates $TargetName related files outside its own folder. All tracking docs, logs, and artifacts stay within ``$TargetName/``."
    $twoRulesReplacement = "**CRITICAL RULES:** (REQUIRED)`n1. The ``$TargetName/`` folder itself is excluded from audits and issue scans - it is the tooling, not the target.`n2. Marge NEVER creates $TargetName related files outside its own folder. All tracking docs, logs, and artifacts stay within ``$TargetName/``."
    
    if ($agentsContent.Contains($singleRulePattern)) {
        $agentsContent = $agentsContent.Replace($singleRulePattern, $twoRulesReplacement)
        Set-Content -Path $agentsPath -Value $agentsContent -NoNewline
        Write-Host "  Updated: AGENTS.md (added audit exclusion rule for meta_marge)" -ForegroundColor Gray
    } elseif ($agentsContent -match "excluded from audits and issue scans") {
        Write-Host "  AGENTS.md already has audit exclusion rule" -ForegroundColor Gray
    } else {
        Write-Host "  WARNING: AGENTS.md has unexpected format - check manually" -ForegroundColor Yellow
    }
}

# Verify the conversion
Write-Host "[5/5] Verifying conversion..." -ForegroundColor Green

# Check for any remaining source name references (excluding dual-folder doc files which intentionally keep both names)
$remainingRefs = 0
$expectedRefs = 0
foreach ($file in (Get-ChildItem -Path $targetFolder -Recurse -File)) {
    if ($file.FullName -like "*\verify_logs\*") { continue }
    
    $relPath = $file.FullName.Substring($targetFolder.Length + 1)
    $isDualFolderDoc = $dualFolderDocFiles | Where-Object { $relPath -like "*$_" }
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match "\b$([regex]::Escape($SourceName))\b") {
            if ($isDualFolderDoc) {
                Write-Host "  OK (expected): '$SourceName' in dual-folder doc: $relPath" -ForegroundColor DarkGray
                $expectedRefs++
            } else {
                Write-Host "  WARNING: '$SourceName' still found in: $relPath" -ForegroundColor Yellow
                $remainingRefs++
            }
        }
    } catch { }
}

if ($remainingRefs -gt 0) {
    Write-Host "  $remainingRefs file(s) have unexpected '$SourceName' references" -ForegroundColor Yellow
}
if ($expectedRefs -gt 0) {
    Write-Host "  $expectedRefs file(s) have expected '$SourceName' references (dual-folder docs)" -ForegroundColor DarkGray
}

# Run verification if verify script exists (scripts are in scripts/ subfolder)
$verifyScript = Join-Path $targetFolder "scripts\verify.ps1"
if (Test-Path $verifyScript) {
    $verifyResult = & powershell -ExecutionPolicy Bypass -File $verifyScript fast 2>&1
    $verifyExitCode = $LASTEXITCODE
    
    if ($verifyExitCode -eq 0 -and $remainingRefs -eq 0) {
        Write-Host "`n============================================================" -ForegroundColor Green
        Write-Host " SUCCESS: $TargetName created and verified!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "`nYou can now use $TargetName for meta-development." -ForegroundColor Cyan
        Write-Host "Run: .\$TargetName\verify.ps1 fast" -ForegroundColor Cyan
    } elseif ($verifyExitCode -eq 0) {
        Write-Host "`n============================================================" -ForegroundColor Yellow
        Write-Host " PARTIAL: $TargetName created but has residual references" -ForegroundColor Yellow
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host "Review the warnings above and manually fix remaining references." -ForegroundColor Yellow
    } else {
        Write-Host "`n============================================================" -ForegroundColor Yellow
        Write-Host " WARNING: Conversion complete but verification had issues" -ForegroundColor Yellow
        Write-Host "============================================================" -ForegroundColor Yellow
        Write-Host $verifyResult
    }
    
    exit $verifyExitCode
} else {
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host " DONE: $TargetName created (no verify.ps1 found to run)" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    exit 0
}
