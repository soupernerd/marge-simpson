# AGENTS.md — Assistant Operating Rules

**Priority:** correctness > safety > minimal diffs > speed

---

## Core Principle

**User prompt = Approval to execute.**

When a user asks you to do something, DO IT. Don't announce it and stop. Don't ask for confirmation. Execute, then report what you did.

---

## Non-Negotiable Rules

1. **NEVER** claim verification passed without raw output
2. **NEVER** skip expert load in Full mode
3. **NEVER** leave work incomplete without stating what remains
4. **ALWAYS** execute what you say you will execute in the same response
5. **ALWAYS** declare MODE before first edit (inline with execution, not as a stopping point)

---

## Mode Declaration

**Before your first file edit, output:**

```
+---------------------------------------------+
| MODE: [Lite | Full]                         |
| ID: [MS-#### | N/A]                         |
| REASON: [one sentence]                      |
+---------------------------------------------+
```

**Then immediately execute.** The MODE block is for visibility, not a checkpoint.

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
| About to make code changes | `marge-simpson/system/experts/_index.md` → select relevant expert(s) |
| Making a decision between options | Grep `marge-simpson/system/knowledge/decisions.md` for prior choices |
| User corrects you or states preference | Check `marge-simpson/system/knowledge/preferences.md` |
| Uncertain how user wants something | Check `marge-simpson/system/knowledge/patterns.md` |

**Expert selection flow:**
1. Load `_index.md` first (~50 tokens)
2. Use keyword mapping to identify needed expert(s)
3. Load only those expert files

**Chain loading:** If a loaded file references another, load that too.

---

## Expert Subagents

**Full mode: load `marge-simpson/system/experts/_index.md` first, then select:**

| Task Keywords | Expert File |
|---------------|-------------|
| architecture, API, refactor, implementation | `engineering.md` |
| test, QA, coverage, automation | `quality.md` |
| security, auth, encryption, compliance | `security.md` |
| deploy, CI/CD, docker, monitoring | `operations.md` |

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
| Confirmation (MS-#### done) | Verify claim, update tracking, mark Done |

---

## Response Format

Every Full-mode response ends with:
- IDs touched (MS-####)
- Files modified
- Verification output (raw)
- Knowledge captured (if any)

---

## Knowledge Capture

**After completing MS-#### work**, capture noteworthy learnings:

| What happened | Add to |
|---------------|--------|
| Made architectural decision | `marge-simpson/system/knowledge/decisions.md` |
| User stated preference | `marge-simpson/system/knowledge/preferences.md` |
| Noticed reusable pattern | `marge-simpson/system/knowledge/patterns.md` |
| Learned non-obvious fact | `marge-simpson/system/knowledge/insights.md` |

**Format:** Date + brief entry. No ID schemes required.

**Skip if:** Trivial fix with no learnings. Don't force it.

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
