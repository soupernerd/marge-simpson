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

### 1. Load Experts (Required)

| Keywords | File |
|----------|------|
| security, auth | `./system/experts/security.md` |
| test, QA | `./system/experts/testing.md` |
| deploy, CI/CD | `./system/experts/devops.md` |
| architecture, API | `./system/experts/architecture.md` |
| UI, UX | `./system/experts/design.md` |

For trivial single-line fixes (typo, format), direct tools allowed per AGENTS.md.

### 2. Check Decisions

Grep `./system/knowledge/decisions.md` for relevant tags. Don't contradict prior choices.

---

## Work Intake

**One ID = One Concept:**
- Each MS-#### tracks ONE conceptual change
- "Fix login bug" = 1 ID (even if 3 files)
- "Fix login bug" + "Add logout" = 2 IDs
- 10 unrelated fixes = 10 IDs

### Features
1. Create MS-#### ID
2. Create plan: `./system/tracking/[name]_MS-####.md` (copy from `feature_plan_template.md`)
3. Add to `assessment.md` + `tasklist.md`
4. Increment Next ID in both

### Bugs/Improvements/Refactors
1. Create MS-#### ID
2. Add to `assessment.md`:
   ```
   ### [MS-####] Description
   - **Type:** bug | feature | improvement | refactor
   - **Status:** In Progress
   - **Plan:** Steps
   - **Verification:** How to confirm
   ```
3. Add to `tasklist.md`
4. Increment Next ID

### Existing Work
Find MS-#### in `tasklist.md`, mark `In Progress`, continue.

---

## Execution

**Priority:** Existing P0/P1 first → New items → Remaining P0→P1→P2

### For Each Item

```
IMPLEMENT → VERIFY → RECORD → NEXT
```

1. **Implement** — Smallest safe change, update assessment.md
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
- [ ] All MS-#### in response exist in tasklist.md
- [ ] All files modified listed in assessment.md
- [ ] Next ID matches in both tracking files
```
**IF any unchecked → fix tracking before responding.**

---

## After Work

**IF** architectural decision made OR user preference discovered OR reusable pattern identified:
→ Load `./system/workflows/session_end.md` to capture it.

**IF** trivial fix with no learnings → skip.
