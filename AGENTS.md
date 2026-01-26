# AGENTS.md — Assistant Operating Rules

**Priority:** correctness > safety > minimal diffs > speed

---

## Usage Modes (Critical) (Hard)

- **IDE Chat:** `prompts/` + `system/tracking/` — no `.marge/`
- **CLI:** `marge` commands — `.marge/` optional

---

## Scope (Critical) (Hard)

This folder is tooling, not the target. Work happens OUTSIDE this folder.
- **Track findings** → `./system/tracking/`
- **Never** create files from this folder elsewhere
- **Always** invoke expert subagents for analysis

---

## Task Modes (Critical) (Hard)

| Trigger | Mode | Behavior |
|---------|------|----------|
| Typo, rename, comment, format | **Lite** | Read → Fix → List files changed. No MS-#### ID. |
| Feature, refactor, audit, multi-file | **Full** | Workflow + MS-#### + Expert subagents |

---

## Core Rules (Critical) (Hard)

1. **Verify before acting** — Read files, search codebase. Never assume.
2. **Root cause only** — No band-aids or workarounds
3. **Minimal surface** — Fewest files, fewest lines
4. **Document reasoning** — Capture *why*, not just *what*
5. **No hardcoded secrets** — Environment variables only
6. **State uncertainty** — Declare: checked, known, unknown

**Stop for approval when:** 3+ files, architectural change, or public API modification. Include plan + risks.

---

## Expert Subagents (Critical) (Hard)

**Full mode requires experts. No exceptions.**

| Task | Experts | Reference |
|------|---------|-----------|
| Security/audit | 2-3 security | `security.md` |
| Architecture | Systems + Implementation | `architecture.md` |
| Code changes | Implementation + Testing | `implementation.md`, `testing.md` |
| Frontend/UI | Design + Implementation | `design.md` |
| Deployment | DevOps + Documentation | `devops.md` |
| Research | 2+ domain experts | `./system/experts/_index.md` |

**Rules:**
- Parallel subagents when tasks are independent
- Direct tools (no expert) only for: reading, running commands, single-line Lite fixes
- Uncertain? More experts, not fewer.

---

## Tracking (Critical) (Hard)

| File | Purpose |
|------|---------|
| `./system/tracking/assessment.md` | Findings + evidence |
| `./system/tracking/tasklist.md` | Work queue || `./system/tracking/feature_plan_template.md` | Template for feature plans |

**When to use what:**
- Simple bug/fix/task: `assessment.md` + `tasklist.md` only
- New feature (multi-step): Copy `feature_plan_template.md` → `[feature]_PLAN.md` + tracking files
**Workflow:** IMPLEMENT → VERIFY → RECORD → COMPLETE

**Verify command:**
- Windows: `./system/scripts/verify.ps1 fast`
- Unix: `./system/scripts/verify.sh fast`

**Rule:** Never claim "passed" without pasting raw output. If verify fails, fix before proceeding.

---

## Routing (Critical) (Hard)

| Intent | Action |
|--------|--------|
| Question only | Answer directly, no workflow |
| Work request | Load `./system/workflows/work.md`, assign MS-#### |
| Audit request | Load `./system/workflows/audit.md` |
| Planning request | Load `./system/workflows/planning.md` |
| Review request | Load `./system/workflows/audit.md` (analysis mode) |
| Document request | Load `./system/workflows/work.md` (docs are work) |
| Decision capture | Load `./system/workflows/session_end.md` |
| Session start/resume | Load `./system/workflows/session_start.md` |
| Loop/continuation | Load `./system/workflows/loop.md` |

**Mixed intent:** Answer questions inline, then process each work item (separate MS-####).

---

## Response Format (Critical) (Hard)

Every Full-mode response ends with:
- IDs touched (MS-####)
- Files modified
- Verification output (raw)
- Knowledge captured

Full template: `./system/workflows/work.md`

---

## Token Estimate (Critical) (Hard)

End **every** response: `📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

---

## Resources (Critical) (Hard)

- **Decisions:** `./system/knowledge/_index.md`
- **Experts:** `./system/experts/_index.md`
- **Workflows:** `./system/workflows/_index.md`

---

## Mindset (Critical)

**Craftsman, not generator.** Every change must be:
- **Elegant** — simplest solution that fully solves it
- **Inevitable** — so right it feels like the only way
- **Better** — leave codebase improved, never degraded

| Folder | Contains |
|--------|----------|
| `system/` | workflows, experts, tracking, scripts |
| `prompts/` | user-facing prompt templates |
| `cli/` | command-line tools |

**When stuck:** Re-read AGENTS.md → Check `decisions.md` → Load expert → Ask.
