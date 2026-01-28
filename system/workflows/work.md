# Work Workflow

> For all trackable work: bugs, features, improvements, refactors.

## Core Principle

**User prompt = Approval.** When asked to do something, execute it. Don't announce and stop.

---

## Action Phase (DO THIS FIRST)

1. **Declare MODE** (Lite or Full) — then immediately continue
2. **Execute the work** — create/edit files as requested
3. **Report what you did** — files modified, verification output

If you say "proceeding" or "I will create X", you MUST do it in the same response.
If you cannot execute, state the specific blocker (missing input, permission, environment).

---

## Mode Selection (Quick Check)

| If... | Then... |
|-------|--------|
| Single typo, comment, format | Lite (no MS-####) |
| Multi-file OR affects behavior | Full (MS-#### required) |
| Unsure | Full |

---

## Context Loading (Only If Needed)

Load experts/knowledge **only when uncertain**:

| If uncertain about... | Load... |
|---------------------|---------|
| Architecture, code structure | `marge-simpson/system/experts/engineering.md` |
| Tests, QA | `marge-simpson/system/experts/quality.md` |
| Security, auth, secrets | `marge-simpson/system/experts/security.md` |
| CI/CD, deploy, infra | `marge-simpson/system/experts/operations.md` |

If the task is clear, skip this and execute.

---

## Work Intake

**One ID = One Concept:**
- Each MS-#### tracks ONE conceptual change
- "Fix login bug" = 1 ID (even if 3 files)
- "Fix login bug" + "Add logout" = 2 IDs
- 10 unrelated fixes = 10 IDs

### Features

**Small feature** (single session, < 50 lines):
1. Create MS-#### ID
2. Use Bugs/Improvements path below (no separate plan file)

**Large feature** (multi-session, phased, or user requests planning):
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

### Confirmations
When user says "MS-#### is fixed" or similar:
1. Find MS-#### in `marge-simpson/system/tracking/assessment.md`
2. Check: Was verification evidence recorded?
   - **Yes** → Mark Done in both tracking files
   - **No** → Run verify, record evidence, then mark Done
3. Mode: Lite (status update only)

---

## Execution

**Priority:** Existing P0/P1 first → New items → Remaining P0→P1→P2

### For Each Item

```
IMPLEMENT → VERIFY → RECORD → NEXT
```

1. **Implement** — Execute the change (smallest safe change)
2. **Verify** — Run `marge-simpson/system/scripts/verify.ps1 fast` (Win) or `marge-simpson/system/scripts/verify.sh fast` (Unix)
3. **Record** — Update tracking, paste evidence
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
| **Status** | ✓ VERIFIED |

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
