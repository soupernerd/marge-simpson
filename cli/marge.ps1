<#
.SYNOPSIS
    Marge - Autonomous AI Coding Loop (PowerShell)

.DESCRIPTION
    A command-line interface for running AI coding tasks autonomously.
    Supports Claude, OpenCode, Codex, and Aider engines.

.PARAMETER Task
    The task to perform, passed as a prompt to the AI

.PARAMETER Folder
    Target folder for Marge operations (default: .marge)

.PARAMETER Engine
    AI engine to use: claude, opencode, codex, aider (default: claude)

.PARAMETER Model
    Model override for the engine

.PARAMETER Loop
    Loop until task is complete

.PARAMETER DryRun
    Preview without running

.PARAMETER MaxIterations
    Maximum iterations for loop mode (default: 20)

.PARAMETER MaxRetries
    Maximum retries per task (default: 3)

.PARAMETER NoCommit
    Disable auto-commit after changes

.PARAMETER Verbose
    Show verbose output

.EXAMPLE
    .\marge.ps1 "fix the login button"
    .\marge.ps1 "add dark mode" -Loop
    .\marge.ps1 -Folder .meta_marge "run audit"
    .\marge.ps1 meta "run self-improvement audit"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

# ============================================
# Marge - Autonomous AI Coding Loop
# ============================================

$versionFile = Get-Content "$PSScriptRoot/../VERSION" -First 1 -ErrorAction SilentlyContinue
$script:VERSION = if ($versionFile) { $versionFile.Trim() } else { "0.0.0" }
$script:MARGE_HOME = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }

# Fallback pricing (Claude Sonnet) - used when model_pricing.json unavailable
$script:DEFAULT_INPUT_RATE = 3.00   # $/1M input tokens
$script:DEFAULT_OUTPUT_RATE = 15.00 # $/1M output tokens

# Defaults
$script:DRY_RUN = $false
$script:VERBOSE_OUTPUT = $false
$script:MODEL = ""
# FAST mode: Passed to AI context to skip verification steps (verify.ps1/verify.sh)
$script:FAST = $false
$script:LOOP = $false
$script:AUTO = $false
$script:FULL_MODE = $false
$script:LITE_MODE = $false
$script:MAX_ITER = if ($env:MAX_ITER) { [int]$env:MAX_ITER } else { 20 }
$script:MAX_RETRIES = if ($env:MAX_RETRIES) { [int]$env:MAX_RETRIES } else { 3 }
$script:RETRY_DELAY = if ($env:RETRY_DELAY) { [int]$env:RETRY_DELAY } else { 5 }
$script:AUTO_COMMIT = $true
$script:ENGINE = "claude"
$script:MARGE_FOLDER = if ($env:MARGE_FOLDER) { $env:MARGE_FOLDER } else { ".marge" }
$script:PRD_FILE = "planning_docs/PRD.md"
# Note: CONFIG_FILE intentionally reads from .marge/ (bootstrap config that can redirect to other folders)
$script:CONFIG_FILE = ".marge\config.yaml"
# Note: PROGRESS_FILE is set after arg parsing to respect --folder (see MS-0008 fix below)
$script:PROGRESS_FILE = $null
$script:PARALLEL = $false
$script:MAX_PARALLEL = if ($env:MAX_PARALLEL) { [int]$env:MAX_PARALLEL } else { 3 }
$script:BRANCH_PER_TASK = $false
$script:CREATE_PR = $false

# State
$script:iteration = 0
$script:total_input_tokens = 0
$script:total_output_tokens = 0

function Write-Info { param([string]$Message) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $Message }
function Write-Success { param([string]$Message) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $Message }
function Write-Warn { param([string]$Message) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $Message }
function Write-Err { param([string]$Message) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $Message }
function Write-Debug-Msg { param([string]$Message) if ($script:VERBOSE_OUTPUT) { Write-Host "[DEBUG] $Message" } }

function Test-PositiveInt {
    param([string]$Value, [string]$Name)
    if ($Value -notmatch '^[1-9][0-9]*$') {
        Write-Err "$Name must be a positive integer, got: $Value"
        return $false
    }
    return $true
}

function Show-Usage {
    $usage = @"

marge v$script:VERSION - Autonomous AI coding loop (PowerShell)

USAGE:
  .\marge.ps1 [options]              Run PRD tasks from planning_docs/PRD.md
  .\marge.ps1 "<task>" [options]     Run a single task
  .\marge.ps1 "<t1>" "<t2>" ...      Chain multiple tasks
  .\marge.ps1 meta "<task>"          Run task using .meta_marge folder

EXAMPLES:
  .\marge.ps1 "fix the login bug"
  .\marge.ps1 "fix bug" "add tests"  # Chain multiple tasks
  .\marge.ps1 -Full "complex task"   # Force full AGENTS.md
  .\marge.ps1 -Loop -Auto
  .\marge.ps1 -Folder .meta_marge "run audit"
  .\marge.ps1 meta "run self-improvement audit"
  .\marge.ps1 -Engine aider -Loop

OPTIONS:
  -Auto              Auto-approve for non-claude engines
  -DryRun            Preview without running
  -Model <model>     Model override
  -Fast              Skip verification
  -Full              Force full AGENTS.md (even for one-off tasks)
  -Loop              Loop until complete
  -Engine <e>        Engine: claude, opencode, codex, aider
  -Folder <dir>      Target Marge folder (default: .marge)
  -MaxIterations N   Max iterations (default: $script:MAX_ITER)
  -MaxRetries N      Max retries per task (default: $script:MAX_RETRIES)
  -NoCommit          Disable auto-commit
  -Parallel          Run tasks in parallel using git worktrees
  -MaxParallel N     Max parallel agents (default: $script:MAX_PARALLEL)
  -BranchPerTask     Create branch per task
  -CreatePR          Create PR when done
  -v, -Verbose       Verbose output
  -Version           Show version
  -Help              Show help

COMMANDS:
  init               Initialize .marge/ and planning_docs/PRD.md template
  clean              Remove local .marge/ folder
  status             Show current status and progress
  config             Show config file contents
  resume             Resume from saved progress
  doctor             Run diagnostic checks for setup

META-DEVELOPMENT:
  meta init          Set up .meta_marge/ for improving Marge itself
  meta init --fresh  Reset to clean state (clears tracked work)
  meta "<task>"      Run task with meta configuration
  meta status        Show meta-marge state and tracked work
  meta clean         Remove .meta_marge/

  Meta-development workflow:
    .meta_marge/AGENTS.md    <- Configuration (the guide)
           |
    AI audits marge-simpson/ <- Target of improvements
           |
    Changes made DIRECTLY to marge-simpson/
           |
    Work tracked in .meta_marge/planning_docs/

CONFIG FILE:
  Place .marge\config.yaml in your project:
    engine: claude
    model: ""
    max_iterations: 20
    max_retries: 3
    auto_commit: true
    folder: .marge

ENVIRONMENT:
  MARGE_HOME         Installation directory (default: ~/.marge)
  MARGE_FOLDER       Default folder (default: .marge)

"@
    Write-Output $usage
}

function Get-Slug {
    param([string]$Text)
    $Text.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', '' | Select-Object -First 50
}

function Load-Config {
    if (-not (Test-Path $script:CONFIG_FILE)) { return }

    try {
        Get-Content $script:CONFIG_FILE -ErrorAction Stop | ForEach-Object {
            if ($_ -match '^\s*(\w+)\s*:\s*(.*)$') {
                $key = $Matches[1]
                $value = $Matches[2].Trim().Trim('"').Trim("'")

                switch ($key) {
                    "engine" { if (-not $script:ENGINE -or $script:ENGINE -eq "claude") { $script:ENGINE = $value } }
                    "model" { if (-not $script:MODEL) { $script:MODEL = $value } }
                    "max_iterations" {
                        if ($value -match '^[1-9][0-9]*$') {
                            $script:MAX_ITER = [int]$value
                        } else {
                            Write-Warn "Config: max_iterations must be a positive integer, got '$value' - using default ($script:MAX_ITER)"
                        }
                    }
                    "max_retries" {
                        if ($value -match '^[1-9][0-9]*$') {
                            $script:MAX_RETRIES = [int]$value
                        } else {
                            Write-Warn "Config: max_retries must be a positive integer, got '$value' - using default ($script:MAX_RETRIES)"
                        }
                    }
                    "auto_commit" { $script:AUTO_COMMIT = $value -eq "true" }
                    "folder" { if (-not $env:MARGE_FOLDER) { $script:MARGE_FOLDER = $value } }
                }
            }
        }
    } catch {
        Write-Warn "Failed to parse config file '$script:CONFIG_FILE': $($_.Exception.Message)"
        Write-Warn "Using default configuration values"
    }
}

function Save-Progress {
    param([int]$TaskIndex, [string]$Status = "running")

    New-Item -ItemType Directory -Path $script:MARGE_FOLDER -Force | Out-Null
    @"
iteration=$script:iteration
task_index=$TaskIndex
timestamp=$([DateTimeOffset]::Now.ToUnixTimeSeconds())
status=$Status
"@ | Out-File -FilePath $script:PROGRESS_FILE -Encoding utf8
}

function Load-Progress {
    if (-not (Test-Path $script:PROGRESS_FILE)) { return $false }

    Get-Content $script:PROGRESS_FILE | ForEach-Object {
        if ($_ -match '^(\w+)=(.*)$') {
            switch ($Matches[1]) {
                "iteration" { $script:iteration = [int]$Matches[2] }
            }
        }
    }
    return $true
}

function Clear-Progress {
    Remove-Item -Path $script:PROGRESS_FILE -ErrorAction SilentlyContinue
}

function Send-Notification {
    param([string]$Message = "Marge complete")
    
    # Try Windows 10+ toast notification
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
        
        $template = @"
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">Marge</text>
            <text id="2">$Message</text>
        </binding>
    </visual>
</toast>
"@
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Marge").Show($toast)
    }
    catch {
        # Fallback: try BurntToast module if available
        if (Get-Module -ListAvailable -Name BurntToast -ErrorAction SilentlyContinue) {
            try {
                New-BurntToastNotification -Text "Marge", $Message -ErrorAction SilentlyContinue
            } catch { }
        }
    }
}

function Get-TokenUsage {
    param([string]$OutputFile)
    
    $inputTokens = 0
    $outputTokens = 0
    
    if (-not (Test-Path $OutputFile)) { return @{ Input = 0; Output = 0 } }
    
    $content = Get-Content $OutputFile -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return @{ Input = 0; Output = 0 } }
    
    # Token parsing patterns (MS-0003 documentation):
    # Pattern 1: Claude CLI stream-json format - "type": "result" contains nested usage object
    # Pattern 2: Generic OpenAI-style - standalone "usage" object with input/output_tokens  
    # Pattern 3: Fallback for APIs returning only total_tokens - estimates 70/30 split
    #
    # Each pattern is tried in order; first successful parse wins.
    # If adding a new engine, check its output format and add appropriate pattern.
    
    # Pattern 1: Claude stream-json ("type": "result" with usage nested)
    if ($content -match '"type"\s*:\s*"result".*?"input_tokens"\s*:\s*(\d+)') {
        $inputTokens = [int]$Matches[1]
    }
    if ($content -match '"type"\s*:\s*"result".*?"output_tokens"\s*:\s*(\d+)') {
        $outputTokens = [int]$Matches[1]
    }
    
    # Pattern 2: Look for usage object directly if above failed
    if ($inputTokens -eq 0 -and $outputTokens -eq 0) {
        if ($content -match '"input_tokens"\s*:\s*(\d+)') {
            $inputTokens = [int]$Matches[1]
        }
        if ($content -match '"output_tokens"\s*:\s*(\d+)') {
            $outputTokens = [int]$Matches[1]
        }
    }
    
    # Pattern 3: Check for total_tokens as fallback
    if ($inputTokens -eq 0 -and $outputTokens -eq 0) {
        if ($content -match '"total_tokens"\s*:\s*(\d+)') {
            $total = [int]$Matches[1]
            $inputTokens = [math]::Floor($total * 0.7)
            $outputTokens = [math]::Floor($total * 0.3)
        }
    }
    
    return @{ Input = $inputTokens; Output = $outputTokens }
}

function Write-TokenUsage {
    param([string]$OutputFile)
    
    $tokens = Get-TokenUsage $OutputFile
    
    if ($tokens.Input -gt 0 -or $tokens.Output -gt 0) {
        # Default Claude Sonnet-class pricing (fallback when file missing/invalid)
        $inputRate = $script:DEFAULT_INPUT_RATE
        $outputRate = $script:DEFAULT_OUTPUT_RATE
        $usingFallback = $false
        
        # Try to read from model_pricing.json
        $pricingFile = "./$script:MARGE_FOLDER/model_pricing.json"
        if (-not (Test-Path $pricingFile)) {
            $pricingFile = Join-Path $script:MARGE_HOME "shared\model_pricing.json"
        }
        
        if (Test-Path $pricingFile) {
            try {
                $pricing = Get-Content $pricingFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                
                # Validate expected structure: must have 'models' array
                if (-not $pricing.models -or $pricing.models -isnot [System.Array]) {
                    Write-Warn "model_pricing.json missing 'models' array - using fallback pricing (`$3/`$15 per 1M tokens)"
                    $usingFallback = $true
                }
                else {
                    $modelName = if ($script:MODEL -match "opus") { "Claude Opus" } else { "Claude Sonnet" }
                    $modelPricing = $pricing.models | Where-Object { $_.name -match $modelName } | Select-Object -First 1
                    if ($modelPricing) {
                        # Validate pricing fields exist and are numeric
                        if ($null -ne $modelPricing.input_per_1m -and $null -ne $modelPricing.output_per_1m) {
                            $inputRate = [double]$modelPricing.input_per_1m
                            $outputRate = [double]$modelPricing.output_per_1m
                        }
                        else {
                            Write-Warn "model_pricing.json entry missing pricing fields - using fallback pricing"
                            $usingFallback = $true
                        }
                    }
                }
            }
            catch {
                Write-Warn "Failed to parse model_pricing.json: $($_.Exception.Message) - using fallback pricing (`$3/`$15 per 1M tokens)"
                $usingFallback = $true
            }
        }
        else {
            Write-Debug-Msg "model_pricing.json not found - using fallback pricing"
            $usingFallback = $true
        }
        
        $cost = (($tokens.Input * $inputRate) + ($tokens.Output * $outputRate)) / 1000000
        Write-Host "  Tokens: " -NoNewline -ForegroundColor Cyan
        Write-Host "$($tokens.Input) in / $($tokens.Output) out" -NoNewline
        Write-Host " · Cost: " -NoNewline -ForegroundColor Cyan
        Write-Host "`$$([math]::Round($cost, 4))"
        
        # Update totals
        $script:total_input_tokens += $tokens.Input
        $script:total_output_tokens += $tokens.Output
    }
    else {
        Write-Host "  Token usage not available" -ForegroundColor Yellow
    }
}

function New-Worktree {
    param([string]$TaskSlug)
    
    $worktreeDir = "$script:MARGE_FOLDER/worktrees/$TaskSlug"
    
    if (-not (Test-Path $worktreeDir)) {
        try {
            git worktree add $worktreeDir -b "marge/$TaskSlug" 2>$null
        }
        catch {
            try {
                git worktree add $worktreeDir "marge/$TaskSlug" 2>$null
            }
            catch {
                return $null
            }
        }
    }
    return $worktreeDir
}

function Remove-Worktrees {
    try {
        git worktree prune 2>$null
        Remove-Item -Recurse -Force "$script:MARGE_FOLDER/worktrees" -ErrorAction SilentlyContinue
    } catch { }
}

function Invoke-TaskParallel {
    param([string]$Task, [int]$Num, [string]$Slug)
    
    $workDir = New-Worktree $Slug
    if (-not $workDir) {
        Write-Err "Failed to setup worktree for $Slug"
        return $false
    }
    
    Write-Info "Running task $Num in worktree: $workDir"
    return Invoke-Task $Task $Num $workDir
}

function Test-Engine {
    param([string]$EngineName)

    $installHints = @"

  Install with one of:
    claude:   npm install -g @anthropic-ai/claude-cli
    aider:    pip install aider-chat
    opencode: go install github.com/opencode-ai/opencode@latest
    codex:    npm install -g @openai/codex

  Or specify a different engine: marge --engine aider 'your task'
"@

    switch ($EngineName) {
        "claude" { if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) { Write-Err "claude not found.$installHints"; return $false } }
        "opencode" { if (-not (Get-Command "opencode" -ErrorAction SilentlyContinue)) { Write-Err "opencode not found.$installHints"; return $false } }
        "codex" { if (-not (Get-Command "codex" -ErrorAction SilentlyContinue)) { Write-Err "codex not found.$installHints"; return $false } }
        "aider" { if (-not (Get-Command "aider" -ErrorAction SilentlyContinue)) { Write-Err "aider not found.$installHints"; return $false } }
        default { Write-Err "Unknown engine: $EngineName"; return $false }
    }
    return $true
}

function Build-EngineCmd {
    param([string]$EngineName)

    switch ($EngineName) {
        "claude" {
            $cmd = "claude --dangerously-skip-permissions --verbose --output-format stream-json"
            if ($script:MODEL) { $cmd += " --model $script:MODEL" }
            $cmd += " -p"
            return $cmd
        }
        "opencode" {
            $cmd = "opencode --approval-mode full-auto"
            if ($script:MODEL) { $cmd += " --model $script:MODEL" }
            return $cmd
        }
        "codex" { return "codex exec --full-auto" }
        "aider" {
            $cmd = "aider --yes --message"
            if ($script:MODEL) { $cmd += " --model $script:MODEL" }
            return $cmd
        }
    }
}

function Invoke-AutoCommit {
    param([int]$IterNum)

    if (-not $script:AUTO_COMMIT) { return }

    try {
        git rev-parse --git-dir 2>$null | Out-Null
        git add . 2>$null
        git commit -m "Marge auto iteration $IterNum" 2>$null
    }
    catch { }
}

function Test-TaskComplete {
    $tasklistPath = "./$script:MARGE_FOLDER/planning_docs/tasklist.md"
    $assessmentPath = "./$script:MARGE_FOLDER/planning_docs/assessment.md"

    if (Test-Path $tasklistPath) {
        $content = Get-Content $tasklistPath -Raw
        if ($content -match '\[ \]') { return $false }
    }

    if (Test-Path $assessmentPath) {
        $content = Get-Content $assessmentPath -Raw
        if ($content -match '(clean|complete|no issues)') { return $true }
    }

    return $true
}

function Show-Spinner {
    param(
        [string]$Task,
        [System.Diagnostics.Process]$Process,
        [string]$OutputFile = ""
    )

    $spinChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $spinIdx = 0
    $startTime = Get-Date
    $truncatedTask = if ($Task.Length -gt 45) { $Task.Substring(0, 45) + "..." } else { $Task }
    $currentStep = "Working"

    while (-not $Process.HasExited) {
        $elapsed = (Get-Date) - $startTime
        $mins = [math]::Floor($elapsed.TotalMinutes)
        $secs = $elapsed.Seconds

        # Check output for step indicators (ported from bash version)
        if ($OutputFile -and (Test-Path $OutputFile)) {
            try {
                $content = Get-Content $OutputFile -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    # Take last ~3000 chars for performance
                    if ($content.Length -gt 3000) {
                        $content = $content.Substring($content.Length - 3000)
                    }
                    
                    if ($content -match 'git commit') {
                        $currentStep = "Committing"
                    }
                    elseif ($content -match 'git add') {
                        $currentStep = "Staging"
                    }
                    elseif ($content -match 'lint|eslint|biome') {
                        $currentStep = "Linting"
                    }
                    elseif ($content -match 'test|jest|vitest|pytest') {
                        $currentStep = "Testing"
                    }
                    elseif ($content -match '"tool":"[Ww]rite"|"tool":"[Ee]dit"') {
                        $currentStep = "Writing"
                    }
                    elseif ($content -match '"tool":"[Rr]ead"|"tool":"[Gg]lob"') {
                        $currentStep = "Reading"
                    }
                    elseif ($content -match '[Tt]hinking') {
                        $currentStep = "Thinking"
                    }
                }
            }
            catch {
                # Ignore read errors, keep current step
            }
        }

        $spinner = $spinChars[$spinIdx % $spinChars.Length]
        Write-Host "`r  $spinner $currentStep [$($mins.ToString('00')):$($secs.ToString('00'))] $truncatedTask    " -NoNewline

        $spinIdx++
        Start-Sleep -Milliseconds 100
    }

    Write-Host "`r$(' ' * 80)`r" -NoNewline
}

function Invoke-Task {
    param([string]$Task, [int]$Num = 1, [string]$WorkDir = ".")

    Write-Info "Task $Num`: $Task"
    Save-Progress $Num "running"

    # Determine mode: lite vs full
    $margeDir = Join-Path $WorkDir $script:MARGE_FOLDER
    $useLiteMode = $false
    
    if (-not (Test-Path $margeDir) -and -not $script:FULL_MODE) {
        $useLiteMode = $true
        $script:LITE_MODE = $true
        Write-Debug-Msg "Using lite mode (AGENTS-lite.md)"
    }

    if ($useLiteMode) {
        # Validate MARGE_HOME exists for lite mode
        if (-not (Test-Path $script:MARGE_HOME)) {
            Write-Err "MARGE_HOME not found: $($script:MARGE_HOME)"
            Write-Err "Install marge globally first, or set MARGE_HOME to your installation."
            return $false
        }
        
        # Lite mode - use AGENTS-lite.md content directly
        $agentsLitePath = Join-Path $script:MARGE_HOME "shared\AGENTS-lite.md"
        if (-not (Test-Path $agentsLitePath)) {
            $agentsLitePath = Join-Path $script:MARGE_HOME "AGENTS-lite.md"
        }
        
        if (-not (Test-Path $agentsLitePath)) {
            Write-Err "AGENTS-lite.md not found in $($script:MARGE_HOME)"
            Write-Err "Your marge installation may be incomplete. Try reinstalling."
            return $false
        }
        
        $agentsContent = Get-Content $agentsLitePath -Raw
        
        $fastSuffix = if ($script:FAST) { " [FAST MODE: Skip verification steps]" } else { "" }
        $autoSuffix = if ($script:AUTO) { "`n[AUTO MODE: Proceed autonomously without asking for user confirmation. Make decisions using best judgment.]" } else { "" }
        $prompt = @"
Read and follow these rules:

$agentsContent

Task: $Task$fastSuffix$autoSuffix
"@
    } else {
        # Full mode - ensure .marge folder exists
        if (-not (Test-Path $margeDir)) {
            $initScript = Join-Path $script:MARGE_HOME "marge-init.ps1"
            if (Test-Path $initScript) {
                & $initScript 2>$null
            }
        }

        # Build prompt
        $loopSuffix = if ($script:LOOP) { " Loop until complete." } else { "" }
        $fastSuffix = if ($script:FAST) { "`n`n[FAST MODE: Skip verification steps - do not run verify.ps1/verify.sh]" } else { "" }
        $autoSuffix = if ($script:AUTO) { "`n[AUTO MODE: Proceed autonomously without asking for user confirmation. Make decisions using best judgment.]" } else { "" }
        $prompt = @"
Read the AGENTS.md file in the $script:MARGE_FOLDER folder and follow it.

Instruction:
- $Task$loopSuffix$fastSuffix$autoSuffix

After finished, list remaining unchecked items in $script:MARGE_FOLDER/planning_docs/tasklist.md.
"@
    }

    if ($script:DRY_RUN) {
        $cmd = Build-EngineCmd $script:ENGINE
        $modeDisplay = if ($useLiteMode) { "lite" } else { "full" }
        Write-Host "Mode: $modeDisplay" -ForegroundColor Cyan
        Write-Host "Would run: $cmd `"<prompt>`"" -ForegroundColor Cyan
        return $true
    }

    $cmd = Build-EngineCmd $script:ENGINE
    $retry = 0
    $outputFile = "$env:TEMP\marge_output_$PID.txt"

    # Ensure temp file cleanup on any exit (success, error, interrupt)
    try {
    while ($retry -lt $script:MAX_RETRIES) {
        Write-Debug-Msg "Attempt $($retry + 1)/$script:MAX_RETRIES"
        Write-Debug-Msg "Command: $cmd `"<prompt>`""
        Write-Debug-Msg "WorkDir: $WorkDir"

        try {
            # MS-0010 fix: Escape special characters for cmd.exe to prevent injection/breakage
            # Escape quotes first, then cmd.exe metacharacters
            $escapedPrompt = $prompt -replace '"', '\"' -replace '([&|<>^%])', '^$1'
            $fullCmd = "$cmd `"$escapedPrompt`""

            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "cmd.exe"
            $pinfo.Arguments = "/c $fullCmd > `"$outputFile`" 2>&1"
            $pinfo.WorkingDirectory = (Resolve-Path $WorkDir).Path
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $true

            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $pinfo
            $process.Start() | Out-Null

            Show-Spinner $Task $process $outputFile
            $process.WaitForExit()

            $exitCode = $process.ExitCode
            Write-Debug-Msg "Exit code: $exitCode"

            if ($script:VERBOSE_OUTPUT -and (Test-Path $outputFile)) {
                Get-Content $outputFile
            }

            if ($exitCode -eq 0) {
                Write-Success "Task $Num completed"
                Write-TokenUsage $outputFile
                Invoke-AutoCommit $Num
                Save-Progress $Num "completed"
                Remove-Item $outputFile -ErrorAction SilentlyContinue
                return $true
            }
        }
        catch {
            Write-Debug-Msg "Error: $_"
        }

        $retry++
        if ($retry -lt $script:MAX_RETRIES) {
            Start-Sleep -Seconds $script:RETRY_DELAY
        }
    }

    Save-Progress $Num "failed"
    Write-Err "Task failed after $script:MAX_RETRIES retries"
    # Show last 10 lines of output to help user understand the failure
    if (Test-Path $outputFile) {
        Write-Err "Last 10 lines of output:"
        Write-Err "----------------------------------------"
        Get-Content $outputFile -Tail 10 | ForEach-Object { Write-Err $_ }
        Write-Err "----------------------------------------"
    }
    return $false
    }
    finally {
        # Cleanup temp file on any exit path
        Remove-Item $outputFile -ErrorAction SilentlyContinue
    }
}

function Get-PrdTasks {
    param([string]$File)

    if (-not (Test-Path $File)) { return @() }

    $tasks = @()
    Get-Content $File | ForEach-Object {
        if ($_ -match '^###\s+(.+)$') {
            $taskName = $Matches[1] -replace '^Task\s+\d+:\s*', ''
            $tasks += $taskName
        }
    }
    return $tasks
}

function Invoke-PrdMode {
    $tasks = Get-PrdTasks $script:PRD_FILE

    if ($tasks.Count -eq 0) {
        Write-Warn "No tasks in $script:PRD_FILE. Create PRD.md or run: .\marge.ps1 init"
        return
    }

    Write-Host ""
    Write-Host "Marge v$script:VERSION" -ForegroundColor White
    Write-Host "Found $($tasks.Count) tasks in $script:PRD_FILE"
    Write-Host "Folder: $script:MARGE_FOLDER" -ForegroundColor Cyan
    if ($script:PARALLEL) {
        Write-Host "Mode: parallel (max $script:MAX_PARALLEL)" -ForegroundColor Cyan
    }
    Write-Host ""

    if ($script:DRY_RUN) {
        Write-Host "Tasks:" -ForegroundColor White
        $taskNum = 0
        foreach ($task in $tasks) {
            $taskNum++
            Write-Host "  $taskNum. $task"
        }
        return
    }

    if ($script:PARALLEL) {
        # Parallel mode using jobs
        $jobs = @()
        $running = 0
        $taskNum = 0
        
        foreach ($task in $tasks) {
            $taskNum++
            $slug = Get-Slug $task
            
            while ($running -ge $script:MAX_PARALLEL) {
                $completed = Get-Job -State Completed
                if ($completed) {
                    $completed | ForEach-Object { Receive-Job $_; Remove-Job $_ }
                    $running -= $completed.Count
                }
                Start-Sleep -Milliseconds 500
            }
            
            $job = Start-Job -ScriptBlock {
                param($TaskText, $TaskNum, $TaskSlug, $ScriptPath)
                & $ScriptPath $TaskText -Folder ".marge"
            } -ArgumentList $task, $taskNum, $slug, $MyInvocation.MyCommand.Path
            
            $jobs += $job
            $running++
        }
        
        # Wait for all jobs to complete
        $jobs | Wait-Job | ForEach-Object { Receive-Job $_; Remove-Job $_ }
        Remove-Worktrees
        $script:iteration = $taskNum
    }
    else {
        foreach ($task in $tasks) {
            $script:iteration++

            if ($script:BRANCH_PER_TASK) {
                $slug = Get-Slug $task
                try {
                    git checkout -b "marge/$slug" 2>$null
                } catch {
                    try { git checkout "marge/$slug" 2>$null } catch { }
                }
            }

            $result = Invoke-Task $task $script:iteration
            if (-not $result -and -not $script:LOOP) { break }

            if (Test-TaskComplete) {
                Write-Success "All tasks complete!"
                break
            }

            if ($script:iteration -ge $script:MAX_ITER) {
                Write-Warn "Max iterations reached"
                break
            }
        }
    }

    if ($script:CREATE_PR) {
        Write-Info "Creating PR..."
        $prTitle = "Marge: Completed $script:iteration tasks"
        $prBody = "Automated PR by marge v$script:VERSION"
        try {
            gh pr create --title $prTitle --body $prBody 2>$null
        } catch {
            Write-Warn "PR creation failed (gh CLI may not be installed)"
        }
    }

    Clear-Progress
    Write-Host ""
    Show-SessionSummary $script:iteration
    Send-Notification "Completed $script:iteration tasks"
}

function Invoke-SingleTask {
    param([string]$Task)

    # Pre-check mode for display
    $margeDir = "./$script:MARGE_FOLDER"
    $modeDisplay = if (-not (Test-Path $margeDir) -and -not $script:FULL_MODE) { "lite" } else { "full" }

    Write-Host ""
    Write-Host "Marge v$script:VERSION - Single task" -ForegroundColor White
    Write-Host "Task: " -NoNewline; Write-Host $Task -ForegroundColor Cyan
    Write-Host "Mode: " -NoNewline; Write-Host $modeDisplay -ForegroundColor Cyan
    if ($modeDisplay -eq "full") {
        Write-Host "Folder: " -NoNewline; Write-Host $script:MARGE_FOLDER -ForegroundColor Cyan
    }
    Write-Host ""

    if ($script:LOOP) {
        while ($script:iteration -lt $script:MAX_ITER) {
            $script:iteration++
            Write-Host "=== Iteration $script:iteration / $script:MAX_ITER ===" -ForegroundColor White

            Invoke-Task $Task $script:iteration | Out-Null
            if (Test-TaskComplete) {
                Write-Success "Complete!"
                break
            }

            Start-Sleep -Seconds 1
        }
    }
    else {
        $script:iteration = 1
        Invoke-Task $Task 1 | Out-Null
    }

    Write-Host ""
    Show-SessionSummary $script:iteration
    Send-Notification "Task complete"
}

function Initialize-Config {
    New-Item -ItemType Directory -Path ".marge" -Force | Out-Null
    New-Item -ItemType Directory -Path "planning_docs" -Force | Out-Null

    @"
engine: claude
model: ""
max_iterations: 20
max_retries: 3
auto_commit: true
folder: .marge
"@ | Out-File -FilePath ".marge\config.yaml" -Encoding utf8

    if (-not (Test-Path "planning_docs/PRD.md")) {
        @"
# PRD

### Task 1: Setup
- [ ] Initialize project

### Task 2: Implementation
- [ ] Build features

### Task 3: Testing
- [ ] Write tests
"@ | Out-File -FilePath "planning_docs/PRD.md" -Encoding utf8
    }

    Write-Success "Initialized .marge/ and planning_docs/"
}

function Get-ProjectType {
    <#
    .SYNOPSIS
        Detect project type based on config files
    #>
    if (Test-Path "package.json") {
        return "node"
    }
    elseif (Test-Path "Cargo.toml") {
        return "rust"
    }
    elseif (Test-Path "go.mod") {
        return "go"
    }
    elseif ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml")) {
        return "python"
    }
    elseif (Test-Path "Gemfile") {
        return "ruby"
    }
    else {
        return "unknown"
    }
}

function Show-Status {
    Write-Host "Marge Status" -ForegroundColor White
    Write-Host "Project type: $(Get-ProjectType)"
    Write-Host "Folder: $script:MARGE_FOLDER"
    
    # Compute PROGRESS_FILE if not yet set (for early-exit commands like 'status')
    $progressFile = if ($script:PROGRESS_FILE) { $script:PROGRESS_FILE } else { "$script:MARGE_FOLDER\progress.txt" }

    if (Test-Path $progressFile) {
        Write-Host "Progress file: $progressFile"
        Get-Content $progressFile
    }
    else {
        Write-Host "No active progress"
    }

    if (Test-Path $script:PRD_FILE) {
        $tasks = Get-PrdTasks $script:PRD_FILE
        Write-Host "PRD tasks: $($tasks.Count)"
    }
}

function Show-Doctor {
    <#
    .SYNOPSIS
        Run diagnostic checks for Marge setup
    #>
    Write-Host ""
    Write-Host "Marge Doctor - Diagnostics" -ForegroundColor White
    Write-Host ""
    
    $warnings = 0
    $errors = 0
    
    # Check engines
    Write-Host "Engines:" -ForegroundColor White
    $engines = @('claude', 'opencode', 'aider', 'codex')
    foreach ($eng in $engines) {
        $found = Get-Command $eng -ErrorAction SilentlyContinue
        if ($found) {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " $eng (found)"
        } else {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline
            Write-Host " $eng (not found)"
        }
    }
    
    # Check at least one engine available
    $anyEngine = $engines | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue }
    if (-not $anyEngine) {
        $errors++
    }
    
    Write-Host ""
    Write-Host "Config:" -ForegroundColor White
    
    # Check config file
    $configPath = ".marge\config.yaml"
    if (Test-Path $configPath) {
        # Basic YAML validation - check for colon-separated key:value pairs
        $configContent = Get-Content $configPath -Raw -ErrorAction SilentlyContinue
        $validYaml = $true
        if ($configContent) {
            $lines = $configContent -split "`n" | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') }
            foreach ($line in $lines) {
                if ($line.Trim() -and -not ($line -match '^\s*\w+\s*:')) {
                    $validYaml = $false
                    break
                }
            }
        }
        if ($validYaml) {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " .marge/config.yaml (valid)"
        } else {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline
            Write-Host " .marge/config.yaml (invalid YAML)"
            $warnings++
        }
    } else {
        Write-Host "  " -NoNewline
        Write-Host "-" -ForegroundColor Yellow -NoNewline
        Write-Host " .marge/config.yaml: not found"
    }
    
    # Check MARGE_HOME
    if ($env:MARGE_HOME) {
        if (Test-Path $env:MARGE_HOME) {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " MARGE_HOME: $env:MARGE_HOME"
        } else {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline
            Write-Host " MARGE_HOME: $env:MARGE_HOME (path not found)"
            $warnings++
        }
    } else {
        Write-Host "  " -NoNewline
        Write-Host "-" -ForegroundColor Yellow -NoNewline
        Write-Host " MARGE_HOME: not set"
    }
    
    Write-Host ""
    Write-Host "Files:" -ForegroundColor White
    
    # Check model_pricing.json
    $pricingPaths = @(
        "./$script:MARGE_FOLDER/model_pricing.json",
        "./model_pricing.json",
        (Join-Path $script:MARGE_HOME "shared\model_pricing.json"),
        (Join-Path $script:MARGE_HOME "model_pricing.json")
    )
    $pricingFound = $false
    $pricingValid = $false
    $pricingPath = $null
    
    foreach ($path in $pricingPaths) {
        if (Test-Path $path) {
            $pricingFound = $true
            $pricingPath = $path
            try {
                $null = Get-Content $path -Raw | ConvertFrom-Json
                $pricingValid = $true
            } catch {
                $pricingValid = $false
            }
            break
        }
    }
    
    if ($pricingFound) {
        if ($pricingValid) {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
            Write-Host " model_pricing.json (valid)"
        } else {
            Write-Host "  " -NoNewline
            Write-Host ([char]0x2717) -ForegroundColor Red -NoNewline
            Write-Host " model_pricing.json (invalid JSON)"
            $warnings++
        }
    } else {
        Write-Host "  " -NoNewline
        Write-Host "-" -ForegroundColor Yellow -NoNewline
        Write-Host " model_pricing.json: not found"
    }
    
    # Check .marge folder
    if (Test-Path $script:MARGE_FOLDER -PathType Container) {
        Write-Host "  " -NoNewline
        Write-Host ([char]0x2713) -ForegroundColor Green -NoNewline
        Write-Host " $($script:MARGE_FOLDER)/ folder exists"
    } else {
        Write-Host "  " -NoNewline
        Write-Host "-" -ForegroundColor Yellow -NoNewline
        Write-Host " $($script:MARGE_FOLDER)/ folder: not found (will use lite mode)"
    }
    
    Write-Host ""
    
    # Summary
    if ($errors -gt 0) {
        Write-Host "Status: " -NoNewline
        Write-Host "Not ready" -ForegroundColor Red -NoNewline
        Write-Host " ($errors critical issue$(if ($errors -ne 1) {'s'}))"
        exit 1
    } elseif ($warnings -gt 0) {
        Write-Host "Status: " -NoNewline
        Write-Host "Ready to use" -ForegroundColor Green -NoNewline
        Write-Host " ($warnings warning$(if ($warnings -ne 1) {'s'}))"
        exit 0
    } else {
        Write-Host "Status: " -NoNewline
        Write-Host "Ready to use" -ForegroundColor Green
        exit 0
    }
}

# =============================================================================
# META-MARGE FUNCTIONS (MS-0015)
# =============================================================================

function Test-MetaHasWork {
    <#
    .SYNOPSIS
        Check if .meta_marge/planning_docs has tracked work (MS-#### entries)
    #>
    $assessmentPath = ".meta_marge\planning_docs\assessment.md"
    if (-not (Test-Path $assessmentPath)) { return $false }
    
    $content = Get-Content $assessmentPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    
    # Check for MS-#### entries (indicates tracked work)
    return $content -match 'MS-\d{4}'
}

function Get-MetaWorkSummary {
    <#
    .SYNOPSIS
        Get summary of tracked work in .meta_marge/planning_docs
    #>
    $summary = @{
        Issues = 0
        Tasks = 0
    }
    
    $assessmentPath = ".meta_marge\planning_docs\assessment.md"
    if (Test-Path $assessmentPath) {
        $content = Get-Content $assessmentPath -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $matches = [regex]::Matches($content, 'MS-\d{4}')
            $summary.Issues = $matches.Count
        }
    }
    
    $tasklistPath = ".meta_marge\planning_docs\tasklist.md"
    if (Test-Path $tasklistPath) {
        $content = Get-Content $tasklistPath -Raw -ErrorAction SilentlyContinue
        if ($content) {
            # Count uncompleted tasks (not in Done section)
            $matches = [regex]::Matches($content, '\[\s*\]\s*\*\*\[MS-\d{4}\]')
            $summary.Tasks = $matches.Count
        }
    }
    
    return $summary
}

function Initialize-Meta {
    <#
    .SYNOPSIS
        Initialize .meta_marge/ for meta-development (improving Marge itself)
    .PARAMETER Fresh
        Reset to clean state (clears existing work)
    #>
    param([switch]$Fresh)
    
    # Check for existing .meta_marge with work
    if ((Test-Path ".meta_marge" -PathType Container) -and -not $Fresh) {
        if (Test-MetaHasWork) {
            $summary = Get-MetaWorkSummary
            Write-Warn ".meta_marge/ exists with tracked work:"
            Write-Host "  - $($summary.Issues) issues in assessment.md"
            Write-Host "  - $($summary.Tasks) tasks in tasklist.md"
            Write-Host ""
            Write-Host "Options:"
            Write-Host "  * Continue using existing setup (recommended)"
            Write-Host "  * marge meta init --fresh   (start over, loses tracked work)"
            Write-Host ""
            Write-Info "Keeping existing .meta_marge/"
            return $true
        } else {
            Write-Info ".meta_marge/ already exists (no changes needed)"
            return $true
        }
    }
    
    # Try to find convert-to-meta script (we're in a marge repo)
    $scriptLocations = @(
        "$PSScriptRoot\..\meta\convert-to-meta.ps1",
        ".\meta\convert-to-meta.ps1"
    )
    
    foreach ($convertScript in $scriptLocations) {
        if (Test-Path $convertScript) {
            Write-Info "Setting up .meta_marge/ (full meta-development environment)..."
            $args = @()
            if ($Fresh) { $args += "-Force" }
            & $convertScript @args
            return $LASTEXITCODE -eq 0
        }
    }
    
    # Fallback: minimal setup for global install users
    Write-Warn "Full meta setup not available (convert-to-meta.ps1 not found)"
    Write-Host ""
    Write-Host "Creating minimal .meta_marge/ folder..."
    Write-Host "For full meta-development, clone the marge repo:"
    Write-Host "  git clone https://github.com/org/marge-simpson"
    Write-Host ""
    
    New-Item -ItemType Directory -Path ".meta_marge" -Force | Out-Null
    New-Item -ItemType Directory -Path ".meta_marge\planning_docs" -Force | Out-Null
    
    # Create minimal AGENTS.md
    @"
# AGENTS.md -- Meta-Development Mode

This is a minimal .meta_marge/ setup. For full meta-development:
1. Clone the marge repo
2. Run: .\meta\convert-to-meta.ps1

## Scope
Audit and improve the marge-simpson/ codebase.
Track work in .meta_marge/planning_docs/
"@ | Out-File -FilePath ".meta_marge\AGENTS.md" -Encoding utf8
    
    # Create empty planning docs
    @"
# .meta_marge Assessment

**Next ID:** MS-0001

## Triage

_None_
"@ | Out-File -FilePath ".meta_marge\planning_docs\assessment.md" -Encoding utf8

    @"
# .meta_marge Tasklist

**Next ID:** MS-0001

## Backlog

_None_

## Done

_None_
"@ | Out-File -FilePath ".meta_marge\planning_docs\tasklist.md" -Encoding utf8
    
    Write-Success "Created minimal .meta_marge/"
    return $true
}

function Show-MetaStatus {
    <#
    .SYNOPSIS
        Show .meta_marge/ status and tracked work
    #>
    Write-Host ""
    Write-Host "Meta-Marge Status" -ForegroundColor White
    Write-Host "-----------------"
    
    if (-not (Test-Path ".meta_marge" -PathType Container)) {
        Write-Warn ".meta_marge/ not initialized"
        Write-Host ""
        Write-Host "To set up meta-development:"
        Write-Host "  marge meta init"
        return
    }
    
    Write-Host "Folder: " -NoNewline
    Write-Host ".meta_marge/" -ForegroundColor Cyan
    
    # Check for AGENTS.md
    if (Test-Path ".meta_marge\AGENTS.md") {
        Write-Host "AGENTS.md: " -NoNewline
        Write-Host "OK" -ForegroundColor Green
    } else {
        Write-Host "AGENTS.md: " -NoNewline
        Write-Host "X missing" -ForegroundColor Red
    }
    
    # Show tracked work
    $summary = Get-MetaWorkSummary
    Write-Host ""
    Write-Host "Tracked Work:" -ForegroundColor White
    Write-Host "  Issues: $($summary.Issues)"
    Write-Host "  Tasks:  $($summary.Tasks)"
    
    # Show workflow diagram
    Write-Host ""
    Write-Host "Workflow:" -ForegroundColor White
    Write-Host "  1. .meta_marge/AGENTS.md    (Configuration - the guide)"
    Write-Host "  2. AI audits marge-simpson/ (Target of improvements)"
    Write-Host "  3. Changes made DIRECTLY to marge-simpson/"
    Write-Host "  4. Work tracked in .meta_marge/planning_docs/"
    Write-Host ""
}

function Remove-Meta {
    <#
    .SYNOPSIS
        Remove .meta_marge/ folder
    #>
    if (-not (Test-Path ".meta_marge" -PathType Container)) {
        Write-Warn ".meta_marge/ folder not found"
        return
    }
    
    if (Test-MetaHasWork) {
        $summary = Get-MetaWorkSummary
        Write-Warn "This will delete tracked work:"
        Write-Host "  - $($summary.Issues) issues"
        Write-Host "  - $($summary.Tasks) tasks"
        Write-Host ""
    }
    
    $response = Read-Host "Remove .meta_marge/ folder? [y/N]"
    if ($response -match '^[Yy]$') {
        Remove-Item -Recurse -Force ".meta_marge"
        Write-Success "Removed .meta_marge/"
    } else {
        Write-Info "Cancelled"
    }
}

function Invoke-MetaSetupPrompt {
    <#
    .SYNOPSIS
        Prompt user to set up .meta_marge/ when running meta task without it
    .OUTPUTS
        $true if setup completed, $false if user declined
    #>
    Write-Host ""
    Write-Warn "Meta-marge not set up yet."
    Write-Host ""
    Write-Host "Meta-development lets you improve Marge itself."
    Write-Host "This will create .meta_marge/ with the proper configuration."
    Write-Host ""
    
    $response = Read-Host "Set up now? [Y/n]"
    if ($response -match '^[Nn]$') {
        Write-Host ""
        Write-Host "To set up later, run: " -NoNewline
        Write-Host "marge meta init" -ForegroundColor Cyan
        return $false
    }
    
    return Initialize-Meta
}

function Get-ModelPricing {
    # Default Claude Sonnet pricing
    $inputRate = $script:DEFAULT_INPUT_RATE
    $outputRate = $script:DEFAULT_OUTPUT_RATE
    
    # Try to read from model_pricing.json
    $pricingFile = "./$script:MARGE_FOLDER/model_pricing.json"
    if (-not (Test-Path $pricingFile)) {
        $pricingFile = Join-Path $script:MARGE_HOME "shared\model_pricing.json"
    }
    
    if (Test-Path $pricingFile) {
        try {
            $pricing = Get-Content $pricingFile -Raw | ConvertFrom-Json
            $modelName = if ($script:MODEL -match "opus") { "Claude Opus" } else { "Claude Sonnet" }
            $modelPricing = $pricing.models | Where-Object { $_.name -match $modelName } | Select-Object -First 1
            if ($modelPricing) {
                $inputRate = $modelPricing.input_per_1m
                $outputRate = $modelPricing.output_per_1m
            }
        } catch { }
    }
    
    return @{ InputRate = $inputRate; OutputRate = $outputRate }
}

function Show-SessionSummary {
    param([int]$IterCount = 0)

    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White
    Write-Host "Session Summary" -ForegroundColor White
    Write-Host "  Iterations: $IterCount"
    Write-Host "  Folder: $script:MARGE_FOLDER"

    if ($script:total_input_tokens -gt 0 -or $script:total_output_tokens -gt 0) {
        $pricing = Get-ModelPricing
        $totalCost = (($script:total_input_tokens * $pricing.InputRate) + ($script:total_output_tokens * $pricing.OutputRate)) / 1000000
        
        Write-Host "  Tokens: " -NoNewline
        Write-Host "$script:total_input_tokens in / $script:total_output_tokens out" -ForegroundColor Cyan
        Write-Host "  Cost: " -NoNewline
        Write-Host "`$$([math]::Round($totalCost, 4))" -ForegroundColor Cyan
    }

    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White
}

# ============================================
# Main
# ============================================

Load-Config

# Parse arguments manually since PowerShell param() doesn't handle mixed positional/named well
$positional = @()
$i = 0

while ($i -lt $Arguments.Count) {
    $arg = $Arguments[$i]
    $matched = $false

    # Check options first (more specific)
    if ($arg -match '^(-Auto|--auto)$') { $script:AUTO = $true; $matched = $true }
    elseif ($arg -match '^(-DryRun|--dry-run)$') { $script:DRY_RUN = $true; $matched = $true }
    elseif ($arg -match '^(-Model|--model)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--model requires a value"
            exit 1
        }
        $i++
        $script:MODEL = $Arguments[$i]
        $matched = $true
    }
    elseif ($arg -match '^(-Engine|--engine)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--engine requires a value"
            exit 1
        }
        $i++
        $script:ENGINE = $Arguments[$i]
        $validEngines = @('claude', 'opencode', 'codex', 'aider')
        if ($script:ENGINE -notin $validEngines) {
            Write-Err "Unknown engine '$($script:ENGINE)'. Valid engines: claude, opencode, codex, aider"
            exit 1
        }
        $matched = $true
    }
    elseif ($arg -match '^(-Fast|--fast)$') { $script:FAST = $true; $matched = $true }
    elseif ($arg -match '^(-Full|--full)$') { $script:FULL_MODE = $true; $matched = $true }
    elseif ($arg -match '^(-Loop|--loop)$') { $script:LOOP = $true; $matched = $true }
    elseif ($arg -match '^(-MaxIterations|--max-iterations)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--max-iterations requires a value"
            exit 1
        }
        $i++
        if (-not (Test-PositiveInt $Arguments[$i] "--max-iterations")) { exit 1 }
        $script:MAX_ITER = [int]$Arguments[$i]
        $matched = $true
    }
    elseif ($arg -match '^(-MaxRetries|--max-retries)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--max-retries requires a value"
            exit 1
        }
        $i++
        if (-not (Test-PositiveInt $Arguments[$i] "--max-retries")) { exit 1 }
        $script:MAX_RETRIES = [int]$Arguments[$i]
        $matched = $true
    }
    elseif ($arg -match '^(-NoCommit|--no-commit)$') { $script:AUTO_COMMIT = $false; $matched = $true }
    elseif ($arg -match '^(-Parallel|--parallel)$') { $script:PARALLEL = $true; $matched = $true }
    elseif ($arg -match '^(-MaxParallel|--max-parallel)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--max-parallel requires a value"
            exit 1
        }
        $i++
        if (-not (Test-PositiveInt $Arguments[$i] "--max-parallel")) { exit 1 }
        $script:MAX_PARALLEL = [int]$Arguments[$i]
        $matched = $true
    }
    elseif ($arg -match '^(-BranchPerTask|--branch-per-task)$') { $script:BRANCH_PER_TASK = $true; $matched = $true }
    elseif ($arg -match '^(-CreatePR|--create-pr)$') { $script:CREATE_PR = $true; $matched = $true }
    elseif ($arg -match '^(-Folder|--folder)$') {
        if ($i + 1 -ge $Arguments.Count) {
            Write-Err "--folder requires a value"
            exit 1
        }
        $i++
        $folderValue = $Arguments[$i]
        # Security: Prevent path traversal outside project
        if ($folderValue -match '^[/\\]' -or $folderValue -match '^\.\.[/\\]' -or $folderValue -match '[/\\]\.\.[/\\]') {
            Write-Err "--folder must be a relative path within the project (got: $folderValue)"
            exit 1
        }
        $script:MARGE_FOLDER = $folderValue
        $matched = $true
    }
    elseif ($arg -match '^(-Verbose|--verbose|-v)$') { $script:VERBOSE_OUTPUT = $true; $matched = $true }
    elseif ($arg -match '^(-Version|--version)$') { Write-Host "marge $script:VERSION"; exit 0 }
    elseif ($arg -match '^(-Help|--help|-h|help)$') { Show-Usage; exit 0 }
    elseif ($arg -eq 'init') { Initialize-Config; exit 0 }
    elseif ($arg -eq 'clean') {
        if (Test-Path ".marge" -PathType Container) {
            $response = Read-Host "Remove .marge/ folder? [y/N]"
            if ($response -match '^[Yy]$') {
                Remove-Item -Recurse -Force ".marge"
                Write-Success "Removed .marge/"
            } else {
                Write-Info "Cancelled"
            }
        } else {
            Write-Warn ".marge/ folder not found"
        }
        exit 0
    }
    elseif ($arg -eq 'status') { Show-Status; exit 0 }
    elseif ($arg -eq 'doctor') { Show-Doctor; exit 0 }
    elseif ($arg -eq 'config') { if (Test-Path ".marge\config.yaml") { Get-Content ".marge\config.yaml" }; exit 0 }
    elseif ($arg -eq 'meta') {
        # Meta-marge subcommands (MS-0015)
        $nextArg = if ($i + 1 -lt $Arguments.Count) { $Arguments[$i + 1] } else { $null }
        
        switch ($nextArg) {
            'init' {
                # Check for --fresh flag
                $freshFlag = $Arguments -contains '--fresh' -or $Arguments -contains '-f'
                Initialize-Meta -Fresh:$freshFlag
                exit $LASTEXITCODE
            }
            'fresh' {
                # Alias: marge meta fresh = marge meta init --fresh
                Initialize-Meta -Fresh
                exit $LASTEXITCODE
            }
            'status' {
                Show-MetaStatus
                exit 0
            }
            'clean' {
                Remove-Meta
                exit 0
            }
            default {
                # Running a task with meta folder
                # Check if .meta_marge exists, prompt if not
                if (-not (Test-Path ".meta_marge" -PathType Container)) {
                    if (-not (Invoke-MetaSetupPrompt)) {
                        exit 0
                    }
                }
                $script:MARGE_FOLDER = ".meta_marge"
                $matched = $true
            }
        }
    }
    elseif ($arg -eq 'resume') {
        if (Load-Progress) { Write-Info "Resuming from iteration $script:iteration" }
        else { Write-Warn "No progress to resume" }
        $matched = $true
    }
    elseif ($arg -match '^-') { Write-Err "Unknown option: $arg"; exit 1 }
    else { $positional += $arg; $matched = $true }

    $i++
}

# Validate engine
if (-not (Test-Engine $script:ENGINE)) { exit 1 }

# Set PROGRESS_FILE after arg parsing to respect --folder (MS-0008 fix)
$script:PROGRESS_FILE = "$script:MARGE_FOLDER\progress.txt"

# Run
if ($positional.Count -gt 0) {
    # Task chaining: run each task sequentially
    if ($positional.Count -gt 1) {
        Write-Host ""
        Write-Host "Marge v$script:VERSION - Task chain ($($positional.Count) tasks)" -ForegroundColor White
        Write-Host "Folder: " -NoNewline; Write-Host $script:MARGE_FOLDER -ForegroundColor Cyan
        Write-Host ""
        
        $taskNum = 0
        foreach ($task in $positional) {
            $taskNum++
            Write-Host "=== Task $taskNum/$($positional.Count): $task ===" -ForegroundColor White
            $script:iteration = 1
            $result = Invoke-Task $task $taskNum
            if (-not $result) {
                Write-Err "Task $taskNum failed, stopping chain"
                break
            }
            Write-Host ""
        }
        
        Show-SessionSummary $taskNum
        Send-Notification "Completed $taskNum tasks"
    }
    else {
        Invoke-SingleTask $positional[0]
    }
}
else {
    Invoke-PrdMode
}
