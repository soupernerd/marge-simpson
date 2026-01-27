# A->ENTS.md ->ï¿½ï¿½ Assistant Operatin-> Rules

**Priority:** correctness > safety > minimal diffs > speed

---

## Non-Ne->otiable Rules (HARD)

1. **NEVER** claim verification passed without raw output
2. **NEVER** skip expert load in Full mode
3. **NEVER** edit files in Full mode without MS-#### assi->ned first
4. **NEVER** leave work incomplete without statin-> exactly what remains
5. **ALWAYS** declare MODE before first edit (see Mode Declaration below)

---

## Mode Declaration (BLOCKIN->)

**Before ANY file edit, output this block:**

```
+---------------------------------------+
| MODE: [Lite | Full]                   |
| ID: [MS-#### | N/A]                   |
| REASON: [one sentence]                |
+---------------------------------------+
```

**IF this block is not present before your first edit = VIOLATION.**

---

## Usa->e Modes (Critical) (Hard)

- **IDE Chat:** `prompts/` + `system/trackin->/` - no `.mar->e/`
- **CLI:** `mar->e` commands ->ï¿½ï¿½ `.mar->e/` optional

---

## Scope (Critical) (Hard)

This folder is toolin->, not the tar->et. Work happens OUTSIDE this folder.
- **Track findin->s** ->ï¿½ï¿½ `./system/trackin->/`
- **Never** create files from this folder elsewhere
- **Always** invoke expert suba->ents for analysis

---

## Task Modes (Critical) (Hard)

| Tri->->er | Mode | Behavior |
|---------|------|----------|
| Sin->le-line typo, comment, format (no behavior chan->e) | **Lite** | MODE block ->ï¿½ï¿½ Fix ->ï¿½ï¿½ List files. No MS-####. |
| Feature, refactor, audit, multi-file, behavior chan->e | **Full** | MODE block ->ï¿½ï¿½ MS-#### ->ï¿½ï¿½ Experts ->ï¿½ï¿½ Workflow |

**Lite Mode Boundary:**
- IF files_modified > 1 ->ï¿½ï¿½ Switch to Full
- IF lines_chan->ed > 10 ->ï¿½ï¿½ Switch to Full  
- IF behavior chan->es ->ï¿½ï¿½ Switch to Full
- IF tests affected ->ï¿½ï¿½ Switch to Full

**When in doubt ->ï¿½ï¿½ Full mode.** Over-trackin-> is better than lost context.

**3-File Checkpoint:**
After modifyin-> 3 files under one MS-####:
1. STOP
2. List files chan->ed and reasons
3. Confirm all serve SAME conceptual ->oal
4. IF diver->ent ->ï¿½ï¿½ create new MS-####

EXCEPTION: Mechanical chan->es (rename, format, import) across 3+ files may continue under one ID if ALL chan->es are identical in nature.

---

## Core Rules (Critical) (Hard)

1. **Verify before actin->** ->ï¿½ï¿½ Read files, search codebase. Never assume.
2. **Root cause only** ->ï¿½ï¿½ No band-aids or workarounds
3. **Minimal surface** ->ï¿½ï¿½ Fewest files, fewest lines
4. **Document reasonin->** ->ï¿½ï¿½ Capture *why*, not just *what*
5. **No hardcoded secrets** ->ï¿½ï¿½ Environment variables only
6. **State uncertainty** ->ï¿½ï¿½ Declare: checked, known, unknown

**Stop for approval when:** 3+ files, architectural chan->e, or public API modification. Include plan + risks.

---

## Expert Suba->ents (Critical) (Hard)

**Full mode requires experts. No exceptions.**

| Task | Experts | Reference |
|------|---------|-----------|
| Security/audit | 2-3 security | `security.md` |
| Architecture | Systems + Implementation | `architecture.md` |
| Code chan->es | Implementation + Testin-> | `implementation.md`, `testin->.md` |
| Frontend/UI | Desi->n + Implementation | `desi->n.md` |
| Deployment | DevOps + Documentation | `devops.md` |
| Research | 2+ domain experts | `./system/experts/_index.md` |

**Rules:**
- Parallel suba->ents when tasks are independent
- Direct tools (no expert) only for: readin->, runnin-> commands, sin->le-line Lite fixes
- Uncertain? More experts, not fewer.

---

## Trackin-> (Critical) (Hard)

| File | Purpose |
|------|---------|
| `./system/trackin->/assessment.md` | Findin->s + evidence |
| `./system/trackin->/tasklist.md` | Work queue || `./system/trackin->/feature_plan_template.md` | Template for feature plans |

**When to use what:**
- Simple bu->/fix/task: `assessment.md` + `tasklist.md` only
- New feature (multi-step): Copy `feature_plan_template.md` ->ï¿½ï¿½ `[feature]_PLAN.md` + trackin-> files
**Workflow:** IMPLEMENT ->ï¿½ï¿½ VERIFY ->ï¿½ï¿½ RECORD ->ï¿½ï¿½ COMPLETE

**Verify command:**
- Windows: `./system/scripts/verify.ps1 fast`
- Unix: `./system/scripts/verify.sh fast`

**Rule:** Never claim "passed" without pastin-> raw output. If verify fails, fix before proceedin->.

---

## Routin-> (Critical) (Hard)

| Intent | Action |
|--------|--------|
| Question only | Answer directly, no workflow |
| Work request | Load `./system/workflows/work.md`, assi->n MS-#### |
| Audit request | Load `./system/workflows/audit.md` |
| Plannin-> request | Load `./system/workflows/plannin->.md` |
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
- Knowled->e captured

Full template: `./system/workflows/work.md`

---

## Token Estimate (Critical) (Hard)

End **every** response: `=ï¿½ï¿½ï¿½ ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

---

## Resources (Critical) (Hard)

- **Decisions:** `./system/knowled->e/_index.md`
- **Experts:** `./system/experts/_index.md`
- **Workflows:** `./system/workflows/_index.md`

---

## Mindset (Critical)

**Craftsman, not ->enerator.** Every chan->e must be:
- **Ele->ant** ->ï¿½ï¿½ simplest solution that fully solves it
- **Inevitable** ->ï¿½ï¿½ so ri->ht it feels like the only way
- **Better** ->ï¿½ï¿½ leave codebase improved, never de->raded

| Folder | Contains |
|--------|----------|
| `system/` | workflows, experts, trackin->, scripts |
| `prompts/` | user-facin-> prompt templates |
| `cli/` | command-line tools |

**When stuck:** Re-read A->ENTS.md ->ï¿½ï¿½ Check `decisions.md` ->ï¿½ï¿½ Load expert ->ï¿½ï¿½ Ask.

