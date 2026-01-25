# AGENTS.md — Assistant Operating Rules

**Priority:** correctness > safety > minimal diffs > speed

**Scope (CRITICAL):**
1. This folder is **excluded from audits** — it is the tooling, not the target.
2. Audit the workspace/repo OUTSIDE this folder. Track findings in `./tracking/`.
3. Never create files from this folder outside this folder.

---

## Core Rules

1. **Read first** — Open files before making claims
2. **Search before implementing** — Don't assume functionality is missing
3. **Root cause fixes** — No band-aids
4. **Minimal changes** — Fewest files/lines necessary
5. **Capture the why** — Document WHY fixes work, not just what changed
6. **No secrets in code** — Use env vars
7. **Uncertainty disclosure** — State what you checked, what you know, what remains unknown

**Major changes** (architecture, schema, API contracts) → Stop, get approval with plan + risks.

---

## AI Behavior (VS Code Copilot)

**Subagents:** `ENABLED` _(user can say "no subagents" to disable)_

Subagents are your primary tool. Use them liberally for any non-trivial work:

### Always Use Subagents For:
- **Research** — Searching across many files, finding patterns, understanding codebase
- **Audits** — Code quality, security, documentation, test coverage scans
- **Multi-file edits** — When changes span 3+ files, spawn subagents per file/area
- **Implementation** — Complex features can be parallelized (UI, API, tests as separate agents)
- **Fixes** — Multiple independent bugs → one subagent per bug
- **Creation** — New modules, components, or test suites

### Subagent Patterns:
```
# Research (read-only)
"Find all usages of X pattern across the codebase. Return file paths and line numbers."

# Implementation (writes code)
"Implement Y in file Z. Make edits directly using replace_string_in_file. Return files modified."

# Parallel work (multiple agents)
Spawn 2-5 agents for independent tasks, wait for all, then verify.
```

### When Direct Tools Are Fine:
- Single file, known location, simple edit
- Running terminal commands
- Quick file reads for context you'll use immediately

**Default to subagents when in doubt.** The cost of parallelization is lower than sequential mistakes.

---

## Tracking

| File | Purpose |
|------|---------|
| `./tracking/assessment.md` | Findings + root cause + verification evidence |
| `./tracking/tasklist.md` | Work queue: backlog → in-progress → done |
| `./tracking/[name]_MS-XXXX.md` | Feature plans (created for each feature) |
```
IMPLEMENT → VERIFY → RECORD → COMPLETE
```

```bash
# Windows
./scripts/verify.ps1 fast -SkipIfNoTests

# macOS/Linux
./scripts/verify.sh fast --skip-if-no-tests
```

**Never claim "tests passed" without raw output or log path.**

---

## Routing

| Intent | Action |
|--------|--------|
| Question | Answer directly (no ID unless issue found) |
| Work (fix, add, change) | Read `./workflows/work.md`, create MS-#### |
| Audit | Read `./workflows/audit.md` first |
| Planning mode (`PLANNING ONLY`, `plan only`) | Read `./workflows/planning.md` — NO code changes |
| Loop mode (`loop until clean`) | Read `./workflows/loop.md` |

**Mixed intent** (e.g., question + feature + bug): Answer questions inline (no ID unless issue found), then process each work item per `work.md` (each gets MS-####).

---

## Response Format

When delivering work, output:
- IDs touched
- Files modified
- Verification evidence (raw output)

See `./workflows/work.md` for full format.

---

## Token Estimate (REQUIRED)

End every response with:

`📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

Pricing in `./model_pricing.json`.

---

## Resources (Active Routing)

**Load based on task type:**

| Situation | Read First |
|-----------|------------|
| Any work task | `./knowledge/_index.md` → check for relevant decisions |
| Domain-specific work | `./experts/_index.md` → load matching expert file |
| Unsure which workflow | `./workflows/_index.md` → find the right one |

**Quick keyword scan:**
- Security/auth/compliance → `./experts/security.md`
- Testing/QA/coverage → `./experts/testing.md`  
- Deploy/CI-CD/infra → `./experts/devops.md`
- Architecture/API/scale → `./experts/architecture.md`
