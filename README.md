# Marge Simpson - sMITten Recursive Context + Experts

# Includes Automated Testing 🛠️

**Full Featured - Drop-in AI workflow for automated audits, bug fixes, new feature suggestion/implementation and testing - for any codebase.**

<p float="none">
  <img src="marge_simpson/assets/many_marge_experts.jpg" width="100%" />
</p>

---

## Install (30 seconds)

### Option A: Drop-in (per-project)

1. Copy just the **`marge_simpson/`** folder into your repo root
2. Use a prompt template below

> **💡 Renamed the folder?** Replace `marge_simpson` with your folder name in prompts.

### Option B: Global Install (multi-project)

For users working across multiple repos who want:
- **Clean repos** — `marge_simpson/` is gitignored, not committed
- **Shared resources** — experts, workflows, and knowledge shared globally
- **Per-project tracking** — MS-IDs and logs isolated per project

**Install globally:**
```bash
# macOS/Linux
./install-global.sh

# Windows
.\install-global.ps1
```

**Use the CLI:**
```bash
marge "fix the login bug"           # Run a task with marge workflow
marge "add dark mode" --model opus  # Use specific model
marge "fix all bugs" --loop         # Loop until complete (max 20 iterations)
marge "audit" --loop --auto         # Fully autonomous (no prompts)
marge init                          # Initialize marge_simpson/ in current project
marge status                        # Show marge status
marge experts                       # List available experts
```

**CLI Options:**

| Option | Description |
|--------|-------------|
| `--loop` | Keep iterating until task is complete |
| `--auto` | Run without user input (skip permission prompts) |
| `--model <model>` | Override model (sonnet, opus, haiku) |
| `--fast` | Skip verification steps |
| `--dry-run` | Preview prompt without launching claude |

**Environment Variables:**

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_ITER` | 20 | Maximum loop iterations |
| `MARGE_HOME` | `~/.marge` | Marge installation directory |

The `marge` command:
1. Auto-initializes `marge_simpson/` if not present
2. Launches `claude` with your task + full marge workflow context
3. Claude follows AGENTS.md rules, tracks work with MS-IDs, verifies changes

**Loop mode features (`--loop`):**
- **MAX_ITER guard** — Prevents infinite loops (configurable via `MAX_ITER` env var)
- **Task completion detection** — Checks `tasklist.md` for unchecked boxes and `assessment.md` for completion indicators
- **Auto-commit progress** — Creates git checkpoints after each iteration (`Marge auto iteration N`)

This creates `marge_simpson/` with:
- **Symlinks** to `~/.marge/shared/` (AGENTS.md, experts, workflows, scripts)
- **Local copies** of tracking files (assessment.md, tasklist.md, verify.config.json)
- Auto-adds `marge_simpson/` to `.gitignore`

**Structure:**
```
~/.marge/
├── shared/           # Symlinked to all projects
│   ├── AGENTS.md
│   ├── experts/      # Add custom experts here (shared across projects)
│   ├── workflows/
│   ├── scripts/
│   └── knowledge/
├── templates/        # Copied per-project
│   ├── assessment.md
│   ├── tasklist.md
│   └── verify.config.json
├── marge             # CLI wrapper (marge run, marge status, etc.)
└── marge-init        # Project initialization script
```

> **💡 Custom experts:** Add domain-specific expert files to `~/.marge/shared/experts/` and they'll be available in all your projects.

---

## Iterative Loop Mode (optional, for when you want to have some fun)

Add a loop phrase to any prompt and Marge will keep iterating until the work is complete.

> **🔄 Quick start:** Use `marge "your task" --loop` or add `loop until clean` to any prompt template below.
>
> **⚙️ Control iterations:** Set `MAX_ITER=10` env var, or add `min 3` / `max 10` to prompts.
>
> See [prompt_examples/](marge_simpson/prompt_examples/) for ready-to-use templates with looping.

---

## Prompt Templates

### 🔍 System Audit
*Use first, or periodically to refresh the plan.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Run a system-wide audit of this workspace/repo (read-only).
- Read and understand the architecture and major workflows.
- Identify correctness issues, risky patterns, and high-impact improvements.
- Do not break intended functionality.

Update/create tracking docs:
- marge_simpson/assessment.md (snapshot + findings + new MS issues)
- marge_simpson/tasklist.md (prioritized tasks with DoD + verification)
- skip adding this instruction to marge_simpson/instructions_log.md

After finished above, search for and list remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

### 🐛 Features & Issues
*Report bugs or request features. Each becomes tracked work.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

New Feature / Issues:
- Example Feature: "Lets add a drop down next to search that allows for.."
- Example / New Issue: "The right hand side nav is not expanding as expected"
- Example / Existing issue not fixed: "MS-0046 is still exhibiting [insert issue here]"

After finished above, search for and list remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

### 📝 Instructions
*Give direct instructions without needing a feature/issue format.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Instruction:
- (your instruction here)
- (another instruction here)

After finished above, search for and list remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

### ❓ Questions & Confirmations
*Ask questions or confirm fixes. Quick answers grounded in code.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Questions / Confirmations:
1. (Question/confirmation here)
2. (Question/confirmation here)
3. Example Confirmation: "MS-00xx fixed"
4. Example Question: "Are there alternatives to codemirror?"

After finished above, search for and list remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

### 📝 Have MARGE Suggest Features
*Give direct instructions without needing a feature/issue format.*

```
Read and follow the rules in `marge_simpson/AGENTS.md`.

MODE: PLANNING ONLY (no code changes, no patches, no execution).

Goal: Propose new features for this project.

Requirements:
- Suggest 3–8 viable feature ideas.
- Rank them highest → lowest by end-user UX / value (UX/value is the primary decision factor).
- Do not prioritize “easy to build” unless it also clearly improves UX/value.
- Do not treat anything as approved—these are proposals only.

For each feature (keep it concise):
- Name (short)
- What it does (1–2 sentences)
- Who it helps / why it matters (1 sentence)
- Biggest risk or dependency (1 bullet)
- How you would validate success (1 bullet; user-facing metric or acceptance criteria)

Output format:
1) Ranked list of features
2) A short “Top pick summary” (2–4 lines) explaining why the #1–#2 options win on UX/value

Update/append/create tracking doc:
- marge_simpson/recommended_features.md (with the bullet points created per feature)

Minimize follow-up questions. If info is missing, make reasonable assumptions and state them briefly.
```

---

### 🔀 Combined Prompts (mix and match at will)
*Mix questions and issues in one prompt for efficiency.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Questions / Confirmations:
1. (Question/confirmation here)
2. (Question/confirmation here)

Instruction:
- (your instruction here)
- (another instruction here)

New Feature / Issues:
- (New Feature or Issue here)
- (New Feature or Issue here)

After finished above, search for and list remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2). Suggest order of operations.

Output using the Response Format (include IDs created).
```

---

## What It Does

| Behavior | Description |
|----------|-------------|
| **Reads first** | Opens files before making claims |
| **Tracks work** | Every fix gets an ID (`MS-0001`, `MS-0002`, …) |
| **Verifies** | Runs tests automatically after each fix |
| **Stays focused** | Minimal diffs, root cause fixes |

**Two source-of-truth files:**
- `tasklist.md` — what's left / doing / done
- `assessment.md` — root cause notes + verification evidence

---

## What's Inside

| File | Purpose |
|------|---------|
| `AGENTS.md` | Rules the assistant follows |
| `assessment.md` | Findings + root cause + verification |
| `tasklist.md` | Prioritized tasks (backlog → done) |
| `instructions_log.md` | Your standing instructions |
| `scripts/verify.ps1` / `verify.sh` | Automated test runner |
| `scripts/test-marge.ps1` / `test-marge.sh` | Self-test suite |
| `prompt_examples/` | Ready-to-copy templates |

---

## Configuration

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

**Multi-language / Monorepo:**
```json
{
  "fast": ["npm test", "python -m pytest -q"],
  "full": ["npm ci", "npm test", "pip install -r requirements.txt", "python -m pytest"]
}
```

No config? Scripts auto-detect Node, Python, Go, Rust, .NET, Java.

---

## Repository Architecture

This repository has a **dual-folder architecture**:

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `marge_simpson/` | **Production template** — copy this to your repos | End users installing Marge |
| `meta_marge/` | **Development instance** — improve Marge here | Contributors developing Marge itself |

**Key Points:**
- `marge_simpson/` is the **source of truth** — this is what gets distributed
- `meta_marge/` is a **working copy** with all paths/references transformed
- The `convert-to-meta` scripts create `meta_marge/` from `marge_simpson/`
- Changes flow: `marge_simpson/` → `meta_marge/` (via script) → test → manual copy back

**Why two folders?**
Marge tracks work using relative paths (e.g., `./marge_simpson/tasklist.md`). To develop Marge *using* Marge, we need a separate instance with different paths so the tooling doesn't overwrite itself.

---

## For Contributors

Want to improve Marge itself? Use the **meta development workflow**:

| Folder | Purpose |
|--------|---------|
| `marge_simpson/` | Template for end users (gets copied to other repos) |
| `meta_marge/` | Development instance (improve Marge here) |

### Quick Start
```powershell
# Windows
.\convert-to-meta.ps1

# macOS/Linux
./convert-to-meta.sh
```

### To create a Meta Marge to make Marge better
1. Run `convert-to-meta` to create/refresh `meta_marge/`
2. Use prompts referencing `meta_marge` instead of `marge_simpson`
3. Test with `./meta_marge/scripts/test-marge.ps1` (15 tests)
4. Copy changes back to `marge_simpson/` when satisfied

### Versioning
- `marge_simpson/VERSION` — bump when releasing template changes
- `meta_marge/VERSION` — auto-updated by convert script
- Semantic: **major** (breaking) / **minor** (features) / **patch** (fixes)

---

## License

Do whatever you want with it. Fork it, rename it, ship it.
