# AGENTS.md — Assistant Operating Rules

**Priority:** correctness > safety > minimal diffs > speed

---

## Non-Negotiable Rules

1. **NEVER** claim verification passed without raw output
2. **NEVER** skip expert load in Full mode
3. **NEVER** edit files in Full mode without MS-#### assigned
4. **NEVER** leave work incomplete without stating what remains
5. **ALWAYS** declare MODE before first edit

---

## Mode Declaration (BLOCKING)

**Before ANY file edit, output:**

```
+---------------------------------------------+
| MODE: [Lite | Full]                         |
| ID: [MS-#### | N/A]                         |
| REASON: [one sentence]                      |
+---------------------------------------------+
```

**Missing block before edit = VIOLATION.**

---

## Scope

marge-simpson/ is tooling, not the target. Work/auditing happens OUTSIDE this folder. UNLESS .meta_marge exists and marge is being worked on.
- **Track findings** → `marge-simpson/system/tracking/`
- **Never** create files from this folder elsewhere

---

## Task Modes

| Trigger | Mode |
|---------|------|
| Single-line typo, comment, format (no behavior change) | **Lite** |
| Feature, refactor, audit, multi-file, behavior change | **Full** |

**Lite → Full escalation:** files > 1, lines > 10, behavior changes, tests affected.

**When in doubt → Full mode.**

---

## Core Rules

1. **Verify before acting** → Read files, search codebase. Never assume.
2. **Root cause only** → No band-aids
3. **Minimal surface** → Fewest files, fewest lines
4. **Document reasoning** → Capture *why*
5. **No hardcoded secrets** → Environment variables only
6. **State uncertainty** → Declare: checked, known, unknown

---

## Just-in-Time Context

**Load files when needed, not upfront.** Minimize token cost.

| When... | Load... |
|---------|--------|
| About to make architecture/code change | `marge-simpson/system/experts/engineering.md` |
| About to write/modify tests | `marge-simpson/system/experts/quality.md` |
| Security-related work (auth, input, secrets) | `marge-simpson/system/experts/security.md` |
| CI/CD, deploy, infra work | `marge-simpson/system/experts/operations.md` |
| Making a decision between options | Grep `marge-simpson/system/knowledge/decisions.md` for prior choices |
| User corrects you or states preference | Check `marge-simpson/system/knowledge/preferences.md` |
| Uncertain how user wants something | Check `marge-simpson/system/knowledge/patterns.md` |

**Chain loading:** If a loaded file references another, load that too.

---

## Expert Subagents

**Full mode: load relevant expert before work.**

| Task | Experts |
|------|---------|
| Architecture/Code | `engineering.md` |
| Testing/QA | `quality.md` |
| Security/Audit | `security.md` |
| Deploy/CI/CD | `operations.md` |

Direct tools (no expert) only for: reading, commands, single-line Lite fixes.

---

## Tracking

| File | Purpose |
|------|---------|
| `marge-simpson/system/tracking/assessment.md` | Findings + evidence |
| `marge-simpson/system/tracking/tasklist.md` | Work queue |

**CRITICAL workflow:** IMPLEMENT → VERIFY → RECORD → COMPLETE

**Verify:** `marge-simpson/system/scripts/verify.ps1 fast` — Never claim "passed" without raw output.

---

## Routing

| Intent | Action |
|--------|--------|
| Question only | Answer directly |
| Work request | `marge-simpson/system/workflows/work.md`, assign MS-#### |
| Audit request | `marge-simpson/system/workflows/audit.md` |
| Planning request | `marge-simpson/system/workflows/planning.md` |

---

## Response Format

Every Full-mode response ends with:
- IDs touched (MS-####)
- Files modified
- Verification output (raw)
- Knowledge captured (if any): `📝 D-### | PR-### | P-### | I-###`

---

## Knowledge Capture

**After completing MS-#### work**, if any of these occurred:
- Architectural decision made → add to `marge-simpson/system/knowledge/decisions.md`
- User preference discovered → add to `marge-simpson/system/knowledge/preferences.md`  
- Reusable pattern identified → add to `marge-simpson/system/knowledge/patterns.md`
- Non-obvious codebase fact learned → add to `marge-simpson/system/knowledge/insights.md`

**Then:** Update `marge-simpson/system/knowledge/_index.md` (Quick Stats, Recent Entries, Tag Index).

**Skip if:** Trivial fix with no learnings.

---

## Decay Check

**At session end** (user says goodbye, or long session wrapping up):

1. Check last decay run: `Get-Content marge-simpson/system/knowledge/.decay-timestamp 2>$null`
2. If missing or > 7 days old → run `marge-simpson/system/scripts/decay.ps1 -Preview`
3. If stale entries found → show summary, ask if user wants to archive

**Non-blocking:** If user is busy, skip. UX > maintenance.

---

## Token Estimate

End **every** response: `📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

---

**Resources:** `marge-simpson/system/experts/_index.md` | `marge-simpson/system/workflows/_index.md` | `marge-simpson/system/knowledge/_index.md`
