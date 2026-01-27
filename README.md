# Marge Simpson - sMITten Recursive Context + Experts

## Includes Automated Testing 🛠️

**A structured context system for AI coding assistants.** Drop-in AGENTS.md rules, work tracking templates, and CLI tools that give your AI session continuity and accountability.

Works with VS Code Copilot, Claude, Cursor, and any AI coding assistant.

<p float="none">
  <img src="./.dev/assets/many_marge_experts.jpg" width="100%" />
</p>

---

## Five Ways to Use Marge

| Method | Best For | How |
|--------|----------|-----|
| 💬 **Chat Prompts** | Interactive work, questions, debugging | Paste [prompt templates](#-chat-prompt-templates) into VS Code Copilot, Cursor, etc. |
| 🖥️ **CLI (Local)** | Automation in one project | Run `./cli/marge "task"` from this repo |
| 🌐 **CLI (Global)** | Multi-project automation | Install once with `./cli/install-global.sh`, then run `marge "task"` anywhere |
| ⚡ **CLI (Lite)** | Quick one-off tasks | Auto-detected for simple tasks like `marge "fix typo"` — no tracking overhead |
| 🔧 **Meta Development** | Contributing to Marge | Run `./.dev/meta/convert-to-meta.sh` then use prompts targeting `.meta_marge/` |

---

## Quick Start

### Option A: Drop-in Folder (Simplest)

1. **Clone or copy this repo** into your project as `marge-simpson/`
2. Use a [Chat Prompt](#-chat-prompt-templates) from below

```bash
# Example: copy into your project
cp -r marge-simpson my-project/marge-simpson
```

### Option B: CLI (Local)

```bash
# From within this repo
./cli/marge "fix the login bug"
./cli/marge "add dark mode" --model opus
```

### Option C: CLI (Global Install)

```bash
# Install once, use everywhere
./cli/install-global.sh      # macOS/Linux
.\cli\install-global.ps1     # Windows

# Then in any project:
marge init                   # Initialize .marge/ in current project
marge "fix the bug"          # Run task
```

---

# 💬 Chat Prompt Templates

> **Use when:** You're working interactively in VS Code, Cursor, or another IDE with AI chat.

## 🔄 Iterative Loop Mode (optional)

Add a loop phrase to any prompt and Marge will keep iterating until work is complete.

> **🔄 Quick start:** Add `loop until clean` to any prompt template below.
>
> **⚙️ Control iterations:** Add `min 3` or `max 10` to set bounds.
>
> See [prompts/](./prompts/) for ready-to-use templates.

---

## 🔍 System Audit
*Use first, or periodically to refresh the plan.*

```
Read marge-simpson/AGENTS.md and follow it.

Run a system-wide audit of this workspace/repo (read-only).
- Read and understand the architecture and major workflows.
- Identify correctness issues, risky patterns, and high-impact improvements.
- Do not break intended functionality.

Update/create tracking docs:
- marge-simpson/system/tracking/assessment.md (snapshot + findings + new MS issues)
- marge-simpson/system/tracking/tasklist.md (prioritized tasks with DoD + verification)

After finished above, search for and list remaining unchecked items (if any exist) in marge-simpson/system/tracking/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## 🐛 Features & Issues
*Report bugs or request features. Each becomes tracked work.*

```
Read marge-simpson/AGENTS.md and follow it.

New Feature / Issues:
- Example Feature: "Lets add a drop down next to search that allows for.."
- Example / New Issue: "The right hand side nav is not expanding as expected"
- Example / Existing issue not fixed: "MS-0046 is still exhibiting [insert issue here]"

After finished above, search for and list remaining unchecked items (if any exist) in marge-simpson/system/tracking/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## 📝 Instructions
*Give direct instructions without needing a feature/issue format.*

```
Read marge-simpson/AGENTS.md and follow it.

Instruction:
- (your instruction here)
- (another instruction here)

After finished above, search for and list remaining unchecked items (if any exist) in marge-simpson/system/tracking/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## ❓ Questions & Confirmations
*Ask questions or confirm fixes. Quick answers grounded in code.*

```
Read marge-simpson/AGENTS.md and follow it.

Questions / Confirmations:
1. (Question/confirmation here)
2. (Question/confirmation here)
3. Example Confirmation: "MS-00xx fixed"
4. Example Question: "Are there alternatives to codemirror?"

After finished above, search for and list remaining unchecked items (if any exist) in marge-simpson/system/tracking/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## 📝 Have MARGE Suggest Features
*Let Marge propose new features based on your codebase.*

```
Read and follow the rules in AGENTS.md (in the marge-simpson folder).

MODE: PLANNING ONLY (no code changes, no patches, no execution).

Goal: Propose new features for this project.

Requirements:
- Suggest 3-8 viable feature ideas.
- Rank them highest to lowest by end-user UX / value (UX/value is the primary decision factor).
- Do not prioritize "easy to build" unless it also clearly improves UX/value.
- Do not treat anything as approved - these are proposals only.

For each feature (keep it concise):
- Name (short)
- What it does (1-2 sentences)
- Who it helps / why it matters (1 sentence)
- Biggest risk or dependency (1 bullet)
- How you would validate success (1 bullet; user-facing metric or acceptance criteria)

Output format:
1) Ranked list of features
2) A short "Top pick summary" (2-4 lines) explaining why the #1-#2 options win on UX/value

Update/append/create tracking doc:
- recommended_features.md (with the bullet points created per feature)

Minimize follow-up questions. If info is missing, make reasonable assumptions and state them briefly.
```

---

## 🔀 Combined Prompts (mix and match)
*Mix questions and issues in one prompt for efficiency.*

```
Read marge-simpson/AGENTS.md and follow it.

Questions / Confirmations:
1. (Question/confirmation here)
2. (Question/confirmation here)

Instruction:
- (your instruction here)
- (another instruction here)

New Feature / Issues:
- (New Feature or Issue here)
- (New Feature or Issue here)

After finished above, search for and list remaining unchecked items (if any exist) in marge-simpson/system/tracking/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## 💬 Pro Tips for Chat

### Deep Reasoning ("Ultrathink")
For complex problems, debugging, or architectural decisions:
- "Think extra hard about this"
- "Take your time reasoning through this"
- "Use extended thinking for this problem"

### Fresh Context for Long Sessions
After very long conversations (50+ exchanges), consider:
- Starting a fresh conversation for new major features
- Using session_end workflow to capture knowledge before restarting
- Keeping focused conversations (one major topic per chat)

---

# 🖥️ CLI Reference

## Basic Usage

```bash
# Single task mode
marge "fix the login bug"              # Run task with spinner + timer
marge "add dark mode" --model opus     # Override model
marge "audit codebase" --dry-run       # Preview without executing

# Target different folders
marge --folder .marge "run audit"      # Explicit folder
marge meta "run self-improvement"      # Shortcut for meta development

# PRD mode (run tasks from system/tracking/PRD.md)
marge                                  # Run all tasks from system/tracking/PRD.md
marge --parallel --max-parallel 3      # Run tasks in parallel (bash only)
marge --branch-per-task --create-pr    # Git workflow automation (bash only)

# Loop mode
marge "full cleanup" --loop            # Iterate until complete
marge --loop --max-iterations 10       # Limit iterations

# Utilities
marge init                             # Initialize .marge/ and system/tracking/
marge init --help                      # Show init help
marge status                           # Show project type, progress, PRD tasks
marge resume                           # Resume from saved progress
marge config                           # Show config file
marge doctor                           # Run diagnostic checks
marge clean                            # Remove .marge/ folder
```

## CLI Options

| Flag | Description |
|------|-------------|
| `--folder <dir>` | Target Marge folder (default: `.marge`) |
| `--dry-run` | Preview prompt without launching claude |
| `--model <model>` | Override model (sonnet, opus, haiku) |
| `--engine <e>` | AI engine: claude, opencode, codex, aider |
| `--auto` | Auto-approve prompts for non-claude engines |
| `--fast` | Skip verification steps |
| `--full` | Force full AGENTS.md (even for one-off tasks) |
| `--loop` | Keep iterating until task complete |
| `--max-iterations N` | Max iterations (default: 20) |
| `--max-retries N` | Max retries per task (default: 3) |
| `--parallel` | Run tasks in parallel using git worktrees *(bash only)* |
| `--max-parallel N` | Max concurrent tasks (default: 3) *(bash only)* |
| `--branch-per-task` | Create separate git branch for each task *(bash only)* |
| `--create-pr` | Create PR when done (requires gh CLI) *(bash only)* |
| `--no-commit` | Disable auto-commit |
| `-v, --verbose` | Debug output |
| `--version` | Show version |
| `--help, -h` | Show help message |

**Environment Variables:**
- `MARGE_HOME` — Global installation directory (default: `~/.marge`)
- `MARGE_FOLDER` — Default target folder (default: `.marge`)

## CLI Config File

Place `.marge/config.yaml` in your project:

```yaml
engine: claude           # claude, opencode, codex, aider
model: ""                # sonnet, opus, haiku (or leave empty)
max_iterations: 20
max_retries: 3
auto_commit: true
folder: .marge           # default target folder
```

## CLI UX Features

| Feature | Description |
|---------|-------------|
| **Spinner** | Animated progress indicator with Marge's hair blue 💙 |
| **Timer** | Shows elapsed time `[MM:SS]` |
| **Step Detection** | Working → Reading → Writing → Testing → Committing |
| **Token Display** | Shows input/output tokens and cost after completion |
| **Notifications** | Desktop notifications on completion (Linux/macOS) |

## Smart Project Detection

Marge auto-detects your project type:
- **Node.js** — `package.json`
- **Rust** — `Cargo.toml`
- **Go** — `go.mod`
- **Python** — `requirements.txt` or `pyproject.toml`
- **Ruby** — `Gemfile`

---

# Reference

## What It Does

| Behavior | Description |
|----------|-------------|
| **Reads first** | Opens files before making claims |
| **Tracks work** | Every fix gets an ID (`MS-0001`, `MS-0002`, …) |
| **Verifies** | Runs tests automatically after each fix |
| **Stays focused** | Minimal diffs, root cause fixes |

**Two source-of-truth files:**
- `system/tracking/tasklist.md` — what's left / doing / done
- `system/tracking/assessment.md` — root cause notes + verification evidence

## What's Inside

| File/Folder | Purpose |
|-------------|---------|
| `AGENTS.md` | Rules the assistant follows |
| `system/tracking/` | Assessment, tasklist, and feature plans |
| `cli/` | CLI tools (marge, marge-init, install-global) |
| `system/scripts/` | Verify scripts, test suite |
| `system/workflows/` | Session start/end, planning, audit workflows |
| `system/experts/` | Domain expert instructions |
| `system/knowledge/` | Decisions, patterns, preferences |
| `prompts/` | Ready-to-copy templates |
| `.dev/` | Tools for contributing to Marge |

## Test Configuration

Custom test commands in `verify.config.json`:

**Node.js:**
```json
{
  "fast": ["npm test"],
  "full": ["npm ci", "npm test", "npm run build"]
}
```

**Python:**
```json
{
  "fast": ["python -m pytest -q"],
  "full": ["pip install -e .", "python -m pytest", "python -m mypy src/"]
}
```

**Go:**
```json
{
  "fast": ["go test ./..."],
  "full": ["go test -v -race ./...", "go build ./..."]
}
```

No config? Scripts auto-detect Node, Python, Go, Rust, .NET, Java.

> **📁 Path Note:** Marge's `verify.config.json` uses paths relative to the **parent directory** (repo root), not the Marge folder itself. This is intentional — `verify.ps1`/`verify.sh` execute from the parent directory.

---

## For Contributors

Want to improve Marge itself? See [.dev/README.md](./.dev/README.md) for the meta-development workflow.

Quick version:
1. Run `./.dev/meta/convert-to-meta.sh` (or `.ps1`) to create `.meta_marge/`
2. Use prompts with "Read .meta_marge/AGENTS.md"
3. AI makes improvements directly to `marge-simpson/` (guided by `.meta_marge/AGENTS.md`)
4. Test with `marge-simpson/system/scripts/test-marge.sh` (or `.ps1`)

---

## Attributions

Co-authored-by: Brandon Arbuthnot <arbuthnot-eth@users.noreply.github.com>

Including but not limited to:

- Marge CLI
- Lite mode (AGENTS-lite.md, --full flag)
- Task chaining (marge "t1" "t2" "t3")
- marge clean command
- .marge folder convention
- Various CLI improvements and bug fixes

---

## License

Do whatever you want with it. Fork it, rename it, ship it.

