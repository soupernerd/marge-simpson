<#
.SYNOPSIS
    Marge v1.1.0 - Autonomous AI Coding Loop (PowerShell)

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
    .\marge.ps1 -Folder meta_marge "run audit"
    .\marge.ps1 meta "run self-improvement audit"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

# ============================================
# Marge v1.1.0 - Autonomous AI Coding Loop
# ============================================

$script:VERSION = "1.1.0"
$script:MARGE_HOME = if ($env:MARGE_HOME) { $env:MARGE_HOME } else { "$env:USERPROFILE\.marge" }

# Defaults
$script:DRY_RUN = $false
$script:VERBOSE_OUTPUT = $false
$script:MODEL = ""
$script:FAST = $false
$script:LOOP = $false
$script:AUTO = $false
$script:MAX_ITER = if ($env:MAX_ITER) { [int]$env:MAX_ITER } else { 20 }
$script:MAX_RETRIES = if ($env:MAX_RETRIES) { [int]$env:MAX_RETRIES } else { 3 }
$script:RETRY_DELAY = if ($env:RETRY_DELAY) { [int]$env:RETRY_DELAY } else { 5 }
$script:AUTO_COMMIT = $true
$script:ENGINE = "claude"
$script:MARGE_FOLDER = if ($env:MARGE_FOLDER) { $env:MARGE_FOLDER } else { ".marge" }
$script:PRD_FILE = "PRD.md"
$script:CONFIG_FILE = ".marge\config.yaml"
$script:PROGRESS_FILE = ".marge\progress.txt"

# State
$script:iteration = 0
$script:total_input_tokens = 0
$script:total_output_tokens = 0

function Write-Info { param([string]$Message) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $Message }
function Write-Success { param([string]$Message) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $Message }
function Write-Warn { param([string]$Message) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $Message }
function Write-Err { param([string]$Message) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $Message }
function Write-Debug-Msg { param([string]$Message) if ($script:VERBOSE_OUTPUT) { Write-Host "[DEBUG] $Message" } }

function Show-Usage {
    $usage = @"

marge v$script:VERSION - Autonomous AI coding loop (PowerShell)

USAGE:
  .\marge.ps1 [options]              Run PRD tasks from PRD.md
  .\marge.ps1 "<task>" [options]     Run a single task
  .\marge.ps1 meta "<task>"          Run task using meta_marge folder

EXAMPLES:
  .\marge.ps1 "fix the login bug"
  .\marge.ps1 -Loop -Auto
  .\marge.ps1 -Folder meta_marge "run audit"
  .\marge.ps1 meta "run self-improvement audit"
  .\marge.ps1 -Engine aider -Loop

OPTIONS:
  -Auto              Auto-approve for non-claude engines
  -DryRun            Preview without running
  -Model <model>     Model override
  -Fast              Skip verification
  -Loop              Loop until complete
  -Engine <e>        Engine: claude, opencode, codex, aider
  -Folder <dir>      Target Marge folder (default: .marge)
  -MaxIterations N   Max iterations (default: $script:MAX_ITER)
  -MaxRetries N      Max retries per task (default: $script:MAX_RETRIES)
  -NoCommit          Disable auto-commit
  -Verbose           Verbose output
  -Version           Show version
  -Help              Show help

COMMANDS:
  init               Initialize .marge/ config and PRD.md template
  status             Show current status and progress
  config             Show config file contents
  meta               Shortcut for -Folder meta_marge

CONFIG FILE:
  Place .marge\config.yaml in your project:
    engine: claude
    model: ""
    max_iterations: 20
    folder: .marge

ENVIRONMENT:
  MARGE_HOME         Installation directory (default: ~/.marge)
  MARGE_FOLDER       Default folder (default: .marge)

"@
    Write-Host $usage
}

function Get-Slug {
    param([string]$Text)
    $Text.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', '' | Select-Object -First 50
}

function Load-Config {
    if (-not (Test-Path $script:CONFIG_FILE)) { return }

    Get-Content $script:CONFIG_FILE | ForEach-Object {
        if ($_ -match '^\s*(\w+)\s*:\s*(.*)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim().Trim('"').Trim("'")

            switch ($key) {
                "engine" { if (-not $script:ENGINE -or $script:ENGINE -eq "claude") { $script:ENGINE = $value } }
                "model" { if (-not $script:MODEL) { $script:MODEL = $value } }
                "max_iterations" { $script:MAX_ITER = [int]$value }
                "max_retries" { $script:MAX_RETRIES = [int]$value }
                "auto_commit" { $script:AUTO_COMMIT = $value -eq "true" }
                "folder" { if (-not $env:MARGE_FOLDER) { $script:MARGE_FOLDER = $value } }
            }
        }
    }
}

function Save-Progress {
    param([int]$TaskIndex, [string]$Status = "running")

    New-Item -ItemType Directory -Path ".marge" -Force | Out-Null
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

function Test-Engine {
    param([string]$EngineName)

    switch ($EngineName) {
        "claude" { if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) { Write-Err "claude not found"; return $false } }
        "opencode" { if (-not (Get-Command "opencode" -ErrorAction SilentlyContinue)) { Write-Err "opencode not found"; return $false } }
        "codex" { if (-not (Get-Command "codex" -ErrorAction SilentlyContinue)) { Write-Err "codex not found"; return $false } }
        "aider" { if (-not (Get-Command "aider" -ErrorAction SilentlyContinue)) { Write-Err "aider not found"; return $false } }
        default { Write-Err "Unknown engine: $EngineName"; return $false }
    }
    return $true
}

function Build-EngineCmd {
    param([string]$EngineName, [string]$Prompt)

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
    $tasklistPath = "./$script:MARGE_FOLDER/tasklist.md"
    $assessmentPath = "./$script:MARGE_FOLDER/assessment.md"

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
    param([string]$Task, [System.Diagnostics.Process]$Process)

    $spinChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $spinIdx = 0
    $startTime = Get-Date
    $truncatedTask = if ($Task.Length -gt 45) { $Task.Substring(0, 45) + "..." } else { $Task }

    while (-not $Process.HasExited) {
        $elapsed = (Get-Date) - $startTime
        $mins = [math]::Floor($elapsed.TotalMinutes)
        $secs = $elapsed.Seconds

        $spinner = $spinChars[$spinIdx % $spinChars.Length]
        Write-Host "`r  $spinner Working [$($mins.ToString('00')):$($secs.ToString('00'))] $truncatedTask    " -NoNewline

        $spinIdx++
        Start-Sleep -Milliseconds 100
    }

    Write-Host "`r$(' ' * 80)`r" -NoNewline
}

function Invoke-Task {
    param([string]$Task, [int]$Num = 1, [string]$WorkDir = ".")

    Write-Info "Task $Num`: $Task"
    Save-Progress $Num "running"

    # Initialize marge folder if needed
    $margeDir = Join-Path $WorkDir $script:MARGE_FOLDER
    if (-not (Test-Path $margeDir)) {
        $initScript = Join-Path $script:MARGE_HOME "marge-init"
        if (Test-Path $initScript) {
            & $initScript 2>$null
        }
    }

    # Build prompt
    $loopSuffix = if ($script:LOOP) { " Loop until complete." } else { "" }
    $prompt = @"
Read the AGENTS.md file in the $script:MARGE_FOLDER folder and follow it.

Instruction:
- $Task$loopSuffix

After finished, list remaining unchecked items in $script:MARGE_FOLDER/tasklist.md.
"@

    if ($script:DRY_RUN) {
        $cmd = Build-EngineCmd $script:ENGINE
        Write-Host "Would run: $cmd `"<prompt>`"" -ForegroundColor Cyan
        return $true
    }

    $cmd = Build-EngineCmd $script:ENGINE
    $retry = 0
    $outputFile = "$env:TEMP\marge_output_$PID.txt"

    while ($retry -lt $script:MAX_RETRIES) {
        Write-Debug-Msg "Attempt $($retry + 1)/$script:MAX_RETRIES"
        Write-Debug-Msg "Command: $cmd `"<prompt>`""
        Write-Debug-Msg "WorkDir: $WorkDir"

        try {
            $fullCmd = "$cmd `"$prompt`""

            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "cmd.exe"
            $pinfo.Arguments = "/c $fullCmd > `"$outputFile`" 2>&1"
            $pinfo.WorkingDirectory = (Resolve-Path $WorkDir).Path
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $true

            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $pinfo
            $process.Start() | Out-Null

            Show-Spinner $Task $process
            $process.WaitForExit()

            $exitCode = $process.ExitCode
            Write-Debug-Msg "Exit code: $exitCode"

            if ($script:VERBOSE_OUTPUT -and (Test-Path $outputFile)) {
                Get-Content $outputFile
            }

            if ($exitCode -eq 0) {
                Write-Success "Task $Num completed"
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
    Remove-Item $outputFile -ErrorAction SilentlyContinue
    return $false
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
    Write-Host ""

    foreach ($task in $tasks) {
        $script:iteration++

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

    Clear-Progress
    Write-Host ""
    Show-SessionSummary $script:iteration
}

function Invoke-SingleTask {
    param([string]$Task)

    Write-Host ""
    Write-Host "Marge v$script:VERSION - Single task" -ForegroundColor White
    Write-Host "Task: " -NoNewline; Write-Host $Task -ForegroundColor Cyan
    Write-Host "Folder: " -NoNewline; Write-Host $script:MARGE_FOLDER -ForegroundColor Cyan
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
}

function Initialize-Config {
    New-Item -ItemType Directory -Path ".marge" -Force | Out-Null

    @"
engine: claude
model: ""
max_iterations: 20
max_retries: 3
auto_commit: true
folder: .marge
"@ | Out-File -FilePath ".marge\config.yaml" -Encoding utf8

    if (-not (Test-Path "PRD.md")) {
        @"
# PRD

### Task 1: Setup
- [ ] Initialize project

### Task 2: Implementation
- [ ] Build features

### Task 3: Testing
- [ ] Write tests
"@ | Out-File -FilePath "PRD.md" -Encoding utf8
    }

    Write-Success "Initialized .marge/"
}

function Show-Status {
    Write-Host "Marge Status" -ForegroundColor White
    Write-Host "Folder: $script:MARGE_FOLDER"

    if (Test-Path $script:PROGRESS_FILE) {
        Write-Host "Progress file: $script:PROGRESS_FILE"
        Get-Content $script:PROGRESS_FILE
    }
    else {
        Write-Host "No active progress"
    }

    if (Test-Path $script:PRD_FILE) {
        $tasks = Get-PrdTasks $script:PRD_FILE
        Write-Host "PRD tasks: $($tasks.Count)"
    }
}

function Show-SessionSummary {
    param([int]$IterCount = 0)

    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White
    Write-Host "Session Summary" -ForegroundColor White
    Write-Host "  Iterations: $IterCount"
    Write-Host "  Folder: $script:MARGE_FOLDER"

    if ($script:total_input_tokens -gt 0 -or $script:total_output_tokens -gt 0) {
        Write-Host "  Tokens: $script:total_input_tokens in / $script:total_output_tokens out" -ForegroundColor Cyan
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
    elseif ($arg -match '^(-Model|--model)$') { $i++; $script:MODEL = $Arguments[$i]; $matched = $true }
    elseif ($arg -match '^(-Engine|--engine)$') { $i++; $script:ENGINE = $Arguments[$i]; $matched = $true }
    elseif ($arg -match '^(-Fast|--fast)$') { $script:FAST = $true; $matched = $true }
    elseif ($arg -match '^(-Loop|--loop)$') { $script:LOOP = $true; $matched = $true }
    elseif ($arg -match '^(-MaxIterations|--max-iterations)$') { $i++; $script:MAX_ITER = [int]$Arguments[$i]; $matched = $true }
    elseif ($arg -match '^(-MaxRetries|--max-retries)$') { $i++; $script:MAX_RETRIES = [int]$Arguments[$i]; $matched = $true }
    elseif ($arg -match '^(-NoCommit|--no-commit)$') { $script:AUTO_COMMIT = $false; $matched = $true }
    elseif ($arg -match '^(-Folder|--folder)$') { $i++; $script:MARGE_FOLDER = $Arguments[$i]; $matched = $true }
    elseif ($arg -match '^(-Verbose|--verbose|-v)$') { $script:VERBOSE_OUTPUT = $true; $matched = $true }
    elseif ($arg -match '^(-Version|--version)$') { Write-Host "marge $script:VERSION"; exit 0 }
    elseif ($arg -match '^(-Help|--help|-h|help)$') { Show-Usage; exit 0 }
    elseif ($arg -eq 'init') { Initialize-Config; exit 0 }
    elseif ($arg -eq 'status') { Show-Status; exit 0 }
    elseif ($arg -eq 'config') { if (Test-Path ".marge\config.yaml") { Get-Content ".marge\config.yaml" }; exit 0 }
    elseif ($arg -eq 'meta') { $script:MARGE_FOLDER = "meta_marge"; $matched = $true }
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

# Run
if ($positional.Count -gt 0) {
    $taskString = $positional -join " "
    Invoke-SingleTask $taskString
}
else {
    Invoke-PrdMode
}
