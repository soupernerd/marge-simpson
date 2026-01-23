# OLD AGENTS.md — Historical Reference

> **Note:** This file preserves the original monolithic AGENTS.md structure before it was split into modular workflow files. Kept for historical reference only.

---

# AGENTS.md — Marge Simpson Mode

This folder is a drop-in workflow for running audits and fixing bugs in any codebase.

**Priority order:** correctness > safety > minimal diffs > speed

## How to use this folder

1. Copy this folder into the root of any project.
2. Add `.marge/` to your `.gitignore` (tracking files are internal).
3. Tell the AI: "Use the .marge folder for audits and fixes."

## A) Universal Rules

### Code First
- Read relevant files before making claims. If you haven't opened it, don't speculate.

### Cost-Aware
- Ask questions only when blocked. Proceed with reasonable assumptions otherwise.

### Root Causes
- Fix at the source. Avoid band-aids.

### Minimal Changes
- Touch the fewest files/lines necessary. No gratuitous refactors.

### Security Default
- No secrets in code, no injection risks, no unsafe patterns. Use env vars.

### Uncertainty Policy
- Say what you checked, what you know, and what remains unknown.

---

## B) Tracking System

### Work IDs
- All tracked work uses sequential IDs: `MS-0001`, `MS-0002`, ...
- Maintain `Next ID:` field in both assessment.md and tasklist.md

### Source Files
| File | Purpose |
|------|---------|
| `assessment.md` | Findings, root cause analysis, verification evidence |
| `tasklist.md` | Active work queue: backlog → in-progress → done |
| `instructions_log.md` | Append-only log of user instructions |

---

## C) Verification Gate

**NON-NEGOTIABLE:** Every fix must be verified before marking complete.

```
1. IMPLEMENT → smallest safe fix
       ↓
2. VERIFY → run tests/build
       ↓
3. RECORD → paste evidence in assessment.md
       ↓
4. COMPLETE → mark done in tasklist.md
```

---

## D) Workflow

### Intent Detection
| Intent | Signals | Action |
|--------|---------|--------|
| **Question** | "How", "why", "what" | Answer directly. No ID needed. |
| **Work** | Fix, add, change, build | Create MS-#### and execute |
| **Audit** | "Audit", "review codebase" | Full discovery scan |

### Audit Mode
1. Scan repo structure
2. Identify issues
3. Create MS-#### for each finding
4. Execute fixes in priority order

### Iterative Loop Mode
When user says "loop until clean" or similar:
- Keep fixing until validation passes
- Maximum 5 iterations by default
- Re-scan after each fix cycle

---

## E) Response Format

When completing work:

```
+=======================================================+
|    __  __    _    ____   ____ _____                   |
|   |  \/  |  / \  |  _ \ / ___| ____|                  |
|   | |\/| | / _ \ | |_) | |  _|  _|                    |
|   | |  | |/ ___ \|  _ <| |_| | |___                   |
|   |_|  |_/_/   \_\_| \_\\____|_____|   WORK COMPLETE  |
+=======================================================+
```

| Field | Value |
|-------|-------|
| IDs Touched | MS-000X, MS-000Y |
| Files Modified | `file1.ts`, `file2.ts` |
| Status | VERIFIED / NEEDS ATTENTION |

---

## F) Memory System

### Knowledge Files
- `decisions.md` — Strategic choices with rationale
- `patterns.md` — Recurring observed behaviors
- `preferences.md` — User's stated preferences
- `insights.md` — Learned facts about codebase

### Experts
Domain-specific knowledge in `experts/` folder:
- Architecture, Security, Testing, DevOps
- Product, Design, Documentation
- Implementation, Sui-Move

---

## G) Critical Rules

1. The `.marge/` folder is excluded from audits (it's the tooling, not the target)
2. Marge NEVER creates files outside the .marge folder
3. Always verify before claiming completion
4. Track all work with MS-#### IDs

---

**This file is archived. See the current modular structure in:**
- `AGENTS.md` (compact router)
- `workflows/` (separate workflow files)
- `experts/` (domain expertise)
- `knowledge/` (learned context)
