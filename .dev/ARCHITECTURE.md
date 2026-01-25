# Marge Architecture

> Living document describing the system structure, design decisions, and data flow.
> **Location:** `.dev/ARCHITECTURE.md` (persists across `.meta_marge/` recreations)
> **Last Updated:** 2026-01-24 | **Version:** 1.3.0

---

## ⚠️ CONSTITUTIONAL RULES — DO NOT CHANGE

These invariants are fundamental to how Marge works. Changing them will break the system.

### Path Strategy (D-006)

| Context | Path Style | Example | Why |
|---------|------------|---------|-----|
| **Source files** (`marge-simpson/`) | **Relative** (`./`) | `./workflows/work.md` | Users can rename folder to `.marge`, `marge`, etc. |
| **Meta-development** (`.meta_marge/`) | **Explicit** | `.meta_marge/workflows/work.md` | AI must not confuse meta files with source files |
| **Verify scripts** (always) | **Source folder** | `marge-simpson/scripts/verify.ps1` | Tests run against source, not meta |

**THE RULE:** Source is relative for flexibility. Meta is explicit to prevent confusion.

The `convert-to-meta` scripts transform `./` → `.meta_marge/` paths automatically. This is intentional and required. Do NOT "fix" this by making everything relative or everything explicit.

### Four Operating Modes

| Mode | Folder | AGENTS Used | Path References |
|------|--------|-------------|-----------------|
| **IDE Chat** | Source folder open | Source `AGENTS.md` | Relative (`./`) |
| **CLI Local** | `.marge/` in project | Symlinked `AGENTS.md` | Relative (`./`) |
| **CLI Global** | `~/.marge/shared/` | Shared `AGENTS.md` | Relative (`./`) |
| **Meta-dev** | `.meta_marge/` | Transformed copy | Explicit (`.meta_marge/`) |

**WHY META IS DIFFERENT:** When `.meta_marge/` exists, AI is working ON the source folder. Using relative paths would be ambiguous — `./workflows/` could mean either folder. Explicit paths eliminate confusion.

### Immutable Constraints

1. **`.meta_marge/` has no `scripts/` folder** — It uses `marge-simpson/scripts/` to verify the source
2. **Planning docs are the single source of work state** — `.marge/` is runtime, `tracking/` is tracked
3. **PRD.md ships blank** — Filled content triggers PRD mode; users fill it in, not shipped with content
4. **Verify evidence required** — Never claim "tests passed" without raw output

### Anti-Patterns (DO NOT DO)

| Bad Pattern | Why It's Wrong | Correct Approach |
|-------------|----------------|------------------|
| Making all paths relative | Breaks meta-development clarity | Source = relative, Meta = explicit |
| Making all paths explicit | Prevents folder renaming | Source uses `./` |
| Adding scripts/ to .meta_marge | Duplicates test infrastructure | Meta uses source scripts |
| Hardcoding `marge-simpson` in source | Prevents user renaming | Use `./` in source files |

---

## What is Marge?

**Marge is a persistent knowledge base that keeps AI assistants informed across sessions.**

Think of it as a "hard drive" for AI context — structured markdown files that AI reads at the start of each session to understand:
- What rules to follow (`AGENTS.md`)
- What work is in progress (`tracking/`)
- What decisions have been made (`knowledge/`)
- How to approach different task types (`workflows/`, `experts/`)

### Key Concepts

| Concept | What It Is | Purpose |
|---------|------------|---------|
| `AGENTS.md` | Operating rules AI reads first | Consistency across sessions |
| `tracking/` | Persistent work state | AI remembers tasks between sessions |
| `knowledge/` | Decisions, patterns, insights | AI doesn't repeat mistakes |
| `workflows/` | Task-specific playbooks | AI follows proven processes |
| `experts/` | Domain knowledge files | AI loads context on-demand |
| `CLI (marge)` | Convenience wrapper | Optional — chat prompts work fine |

### The Three Folder Types

1. **`marge-simpson/`** (source repo) — What you clone. Contains all Marge files. You can rename it or copy just what you need.

2. **`.marge/`** (per-project folder) — Created by `marge init` in YOUR projects. Contains symlinks to shared resources + local tracking files. Named `.marge` to follow convention (like `.git`, `.vscode`, `.claude`).

3. **`.meta_marge/`** (meta-development) — Temporary folder for improving Marge itself. Created by `convert-to-meta`, deleted and recreated fresh each session. Uses source scripts.

### Common Misunderstandings

| Misconception | Reality |
|---------------|---------|
| "Marge runs code" | No — Marge is context. The AI runs your code via its tools. |
| "I need the CLI" | No — Copy/paste prompts into chat works fine. CLI is convenience. |
| ".marge/ should be committed" | No — It's runtime. The source repo files are what you share. |
| ".meta_marge needs its own scripts" | No — It uses marge-simpson/scripts/ to test the source. |

---

## System Overview

Marge provides structured context that AI assistants read at the start of each session. It can be used via:
1. **Chat prompts** — Copy/paste into AI chat interfaces (most common)
2. **CLI** — Optional convenience wrapper (`marge "task"`)
3. **Meta-development** — Self-improvement via `.meta_marge/`

```
┌─────────────────────────────────────────────────────────────────────┐
│                        User Project                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐  │
│  │ Source Code │    │   .marge/   │    │   tracking/           │  │
│  │   (yours)   │◄───│  (symlinks) │───►│  (per-project tracking) │  │
│  └─────────────┘    └──────┬──────┘    └─────────────────────────┘  │
│                            │                                         │
└────────────────────────────┼─────────────────────────────────────────┘
                             │ symlinks to
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     ~/.marge/ (Global Install)                       │
│  ┌─────────────────┐    ┌──────────────┐    ┌───────────────────┐   │
│  │     shared/     │    │  templates/  │    │   CLI Scripts     │   │
│  │  • AGENTS.md    │    │ • assessment │    │  • marge          │   │
│  │  • AGENTS-lite  │    │ • tasklist   │    │  • marge-init     │   │
│  │  • workflows/   │    │ • PRD.md     │    │  • marge.ps1      │   │
│  │  • experts/     │    └──────────────┘    └───────────────────┘   │
│  │  • scripts/     │                                                 │
│  └─────────────────┘                                                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

### Core Files (Root Level)

| File | Purpose | When Modified |
|------|---------|---------------|
| `AGENTS.md` | Primary AI instructions — routing, rules, response format | Core behavior changes |
| `AGENTS-lite.md` | Lightweight rules for one-off tasks (~35 lines) | Lite mode changes |
| `VERSION` | Semantic version string | Every release |
| `CHANGELOG.md` | Release notes | Every release |
| `verify.config.json` | Test profiles (fast/full) | Test command changes |
| `model_pricing.json` | Token cost estimates | Price updates |

### /cli — Command-Line Interface

| File | Purpose |
|------|---------|
| `marge` | Bash CLI — main entry point |
| `marge.ps1` | PowerShell CLI — Windows parity |
| `marge-init` | Initialize `.marge/` in a project (bash) |
| `marge-init.ps1` | Initialize `.marge/` in a project (PowerShell) |
| `install-global.sh` | Global install script (creates `~/.marge/`) |
| `install-global.ps1` | Global install script (Windows) |

**CLI Modes:**
- **Lite mode** — No local `.marge/`, uses `AGENTS-lite.md` for quick tasks
- **Full mode** — Local `.marge/` exists, uses full `AGENTS.md` + tracking
- **PRD mode** — Runs tasks from `tracking/PRD.md` sequentially

### /workflows — Structured Processes

| File | Triggers | Creates ID? |
|------|----------|-------------|
| `work.md` | Fix, add, change requests | Yes |
| `audit.md` | "Audit", "review codebase" | Yes (multiple) |
| `loop.md` | "Loop until clean" modifier | Continues existing |
| `planning.md` | "PLANNING ONLY" mode | No |
| `session_start.md` | New conversation | No |
| `session_end.md` | Task complete | No |
| `_index.md` | Routing decisions | — |

### /experts — Domain-Specific Guidance

Loaded based on task keywords (see `experts/_index.md`):

| File | Keywords |
|------|----------|
| `architecture.md` | API, scalability, systems |
| `security.md` | Auth, GDPR, encryption |
| `testing.md` | QA, coverage, pytest |
| `devops.md` | CI/CD, docker, deploy |
| `design.md` | UI, UX, accessibility |
| `implementation.md` | Code, build, refactor |
| `product.md` | Requirements, MVP, scope |
| `documentation.md` | Docs, runbooks, specs |

### /knowledge — Learned Context

| File | Purpose |
|------|---------|
| `decisions.md` | Architectural choices (D-###) |
| `patterns.md` | Observed behaviors (P-###) |
| `preferences.md` | User preferences (PR-###) |
| `insights.md` | Codebase discoveries (I-###) |
| `archive.md` | Pruned entries |
| `_index.md` | Quick stats + tag index |

### /scripts — Automation

| Script | Purpose | Usage |
|--------|---------|-------|
| `verify.ps1/.sh` | Run tests/lint/build | `verify.ps1 fast` |
| `test-syntax.ps1/.sh` | Validate script syntax | Part of verify |
| `test-general.ps1/.sh` | Structural validation | Part of verify |
| `test-marge.ps1/.sh` | Self-test suite | Part of verify |
| `cleanup.ps1/.sh` | Remove stale files | `cleanup.ps1 -Preview` |
| `decay.ps1/.sh` | Archive old entries | Quarterly maintenance |
| `status.ps1/.sh` | Show current state | Quick health check |

### /meta — Self-Improvement Tools

| File | Purpose |
|------|---------|
| `convert-to-meta.sh` | Create `.meta_marge/` for self-development |
| `convert-to-meta.ps1` | Windows version |
| `README.md` | Meta-development guide |
| `ARCHITECTURE.md` | This file — system design reference |

### /tracking — Work Tracking

| File | Purpose |
|------|---------|
| `assessment.md` | Issues found, root cause, verification |
| `tasklist.md` | Work queue (backlog → in-progress → done) |
| `PRD.md` | Product requirements for CLI PRD mode |
| `_template.md` | Feature plan template |
| `*_MS-XXXX.md` | Individual feature plans |

---

## Data Flow

### 1. User runs `marge "fix the bug"`

```
1. CLI parses args
2. Check: does .marge/ exist?
   ├─ YES → Full mode (AGENTS.md + tracking)
   └─ NO  → Lite mode (AGENTS-lite.md, no tracking)
3. Build prompt with instructions
4. Execute AI engine (claude, opencode, codex, aider)
5. Parse token usage from output
6. Auto-commit if enabled
7. Display session summary
```

### 2. User runs `marge init`

```
1. Validate global install exists (~/.marge/)
2. Create .marge/ in current project
3. Symlink shared resources (AGENTS.md, workflows/, etc.)
4. Copy per-project templates (assessment.md, tasklist.md)
5. Update .gitignore
```

### 3. User runs `./.dev/convert-to-meta.sh`

```
1. Copy marge-simpson/ → .meta_marge/
2. Exclude: cli/, .dev/, assets/, scripts/, .git, .marge, etc.
   (scripts/ excluded — meta uses source scripts directly)
3. Transform path references (marge-simpson → .meta_marge)
4. Reset tracking to clean state  
5. Rewrite AGENTS.md scope to target marge-simpson/
6. Run verification (marge-simpson/scripts/verify.ps1, not .meta_marge)
```

---

## Maintenance Notes

> **Design decisions** are documented in `knowledge/decisions.md` (D-### format).

### When to Update This File

- **New files added** — Add to directory structure table
- **Workflow changes** — Update data flow diagrams
- **Design decisions made** — Document in Design Decisions
- **Major refactors** — Update system overview diagram

### Meta-Development Workflow

When working in `.meta_marge/`:
1. AI reads this file to understand structure
2. Makes changes to `marge-simpson/` (not `.meta_marge/`)
3. Updates this file if structure changes
4. Commits changes with clear messages

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.3.0 | 2026-01-23 | Initial creation. Added lite mode, task chaining, clean command. |
