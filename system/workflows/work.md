# Work Workflow

> For all trackable work: bugs, features, improvements, refactors.

## When to Use

User wants something **done** — fix, add, improve, or refactor.

---

## Pre-Work

### 0. Mode Check (Required)

Before ANY work, explicitly declare:
- **Mode:** Lite or Full
- **Reason:** Why this qualifies

| If... | Then... |
|-------|--------|
| Single typo, comment, format | Lite (no MS-####) |
| Multi-file OR affects system behavior | Full (MS-#### required) |
| Unsure | Full (over-tracking > lost context) |

**Skip this step = skip tracking = violation.**

### 1. Load Context (Just-in-Time)

**Load only what's relevant to this task:**

| If task involves... | Load... |
|---------------------|---------|
| Architecture, code structure | `marge-simpson/system/experts/engineering.md` |
| Tests, QA | `marge-simpson/system/experts/quality.md` |
| Security, auth, secrets | `marge-simpson/system/experts/security.md` |
| CI/CD, deploy, infra | `marge-simpson/system/experts/operations.md` |

**Then check knowledge** (quick grep, not full read):
```powershell
Select-String -Path "marge-simpson/system/knowledge/decisions.md" -Pattern "#relevant-tag"
Select-String -Path "marge-simpson/system/knowledge/preferences.md" -Pattern "#relevant-tag"
```

Don't contradict prior decisions. Respect stored preferences.

---

## Work Intake

**One ID = One Concept:**
- Each MS-#### tracks ONE conceptual change
- "Fix login bug" = 1 ID (even if 3 files)
- "Fix login bug" + "Add logout" = 2 IDs
- 10 unrelated fixes = 10 IDs

### Features
1. Create MS-#### ID
2. Create plan: `marge-simpson/system/tracking/[name]_MS-####.md` (copy from `feature_plan_template.md`)
3. Add to `marge-simpson/system/tracking/assessment.md` + `marge-simpson/system/tracking/tasklist.md`
4. Increment Next ID in both

### Bugs/Improvements/Refactors
1. Create MS-#### ID
2. Add to `marge-simpson/system/tracking/assessment.md`:
   ```
   ### [MS-####] Description
   - **Type:** bug | feature | improvement | refactor
   - **Status:** In Progress
   - **Plan:** Steps
   - **Verification:** How to confirm
   ```
3. Add to `marge-simpson/system/tracking/tasklist.md`
4. Increment Next ID

### Existing Work
Find MS-#### in `marge-simpson/system/tracking/tasklist.md`, mark `In Progress`, continue.

---

## Execution

**Priority:** Existing P0/P1 first → New items → Remaining P0→P1→P2

### For Each Item

```
IMPLEMENT → VERIFY → RECORD → NEXT
```

1. **Implement** — Smallest safe change, update `marge-simpson/system/tracking/assessment.md`
2. **Verify** — Run `verify.ps1 fast` (Win) or `verify.sh fast` (Unix)
3. **Record** — Paste evidence, mark done in tasklist
4. **Next** — Continue or deliver

**Do NOT mark done without evidence.**

---

## Labels

| Type | When |
|------|------|
| bug | Something broken |
| feature | New capability |
| improvement | Enhance existing |
| refactor | Cleanup, no behavior change |

Process is same for all. Labels are for humans.

---

## Response Format

| Field | Value |
|-------|-------|
| **IDs Touched** | MS-000X, MS-000Y |
| **Files Modified** | `file1.ts`, `file2.ts` |
| **File Counter** | [1] [2] [3] ← CHECKPOINT |
| **Status** | ✓ VERIFIED |

**3-File Counter Rule:** When counter reaches 3, STOP and confirm all files serve same concept before continuing.

### What Changed
- (Bullet list)

### Verification Evidence
```
(Raw output)
```

### Knowledge Captured (if any)
`📝 D-### | PR-### | P-### | I-###`

### Tracking Sync (MANDATORY)
```
- [ ] All MS-#### in response exist in marge-simpson/system/tracking/tasklist.md
- [ ] All files modified listed in marge-simpson/system/tracking/assessment.md
- [ ] Next ID matches in both tracking files
```
**IF any unchecked → fix tracking before responding.**

---

## After Work

### Knowledge Capture (If Noteworthy)

**After completing MS-####**, check if any of these occurred:

| What happened | Add to | ID format |
|---------------|--------|-----------|
| Made architectural decision | `marge-simpson/system/knowledge/decisions.md` | D-### |
| User stated preference | `marge-simpson/system/knowledge/preferences.md` | PR-### |
| Noticed repeated user behavior | `marge-simpson/system/knowledge/patterns.md` | P-### |
| Learned non-obvious codebase fact | `marge-simpson/system/knowledge/insights.md` | I-### |

**If yes:** Add entry, update `marge-simpson/system/knowledge/_index.md` (Quick Stats, Recent Entries, Tag Index).

**If no:** Skip. Don't force it.

### Decay Check (Session End Only)

**Only when user says goodbye or long session wrapping up:**

1. Check: `Get-Content marge-simpson/system/knowledge/.decay-timestamp 2>$null`
2. If missing or > 7 days → run `marge-simpson/system/scripts/decay.ps1 -Preview`
3. Show stale entries to user, ask if they want to archive

**UX > maintenance.** If user is busy, skip decay.
