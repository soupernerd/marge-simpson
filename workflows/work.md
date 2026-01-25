# Work Workflow

> Unified workflow for all trackable work: bugs, features, improvements, refactors.
> The "type" is a label, not a different process.

## When to Use

User wants something **done** - any of:
- Fix a bug / error / broken behavior
- Add a new feature / capability
- Improve / enhance existing functionality
- Refactor / clean up code

## Pre-Work: Load Relevant Context

### 1. Check Experts (if task has domain keywords)

Read `./experts/_index.md` and scan for keywords matching your task:

| Task Keywords | Load File |
|---------------|----------|
| security, auth, GDPR | `./experts/security.md` |
| test, coverage, QA | `./experts/testing.md` |
| deploy, CI/CD, docker | `./experts/devops.md` |
| architecture, API, scale | `./experts/architecture.md` |
| UI, UX, accessibility | `./experts/design.md` |

**Skip if:** Simple bug fix or task doesn't match any domain keywords.

### 2. Check Knowledge (for prior decisions)

Grep `./knowledge/decisions.md` for tags related to your task:

```powershell
Select-String -Path "./knowledge/decisions.md" -Pattern "#auth|#api|#database"
```

**Apply any relevant decisions** — don't contradict prior architectural choices without explicit approval.

**Skip if:** Knowledge files are empty or task is isolated.

## Work Intake

### For FEATURES (type: feature)

1. Create the next MS-#### ID
2. Create plan file: `./tracking/[feature-name]_MS-####.md`
   - Copy from `./tracking/_template.md`
   - Fill in: Goal, Approach, Why, Risks
   - List sub-tasks (each gets own MS-#### ID)
3. Add entry to `./tracking/assessment.md` referencing the plan
4. Add task(s) to `./tracking/tasklist.md` with parent reference
5. Increment `Next ID` in BOTH files

### For BUGS/IMPROVEMENTS/REFACTORS

1. Create the next MS-#### ID
2. Add entry to `./tracking/assessment.md`:
   ```markdown
   ### [MS-####] Short description
   - **Type:** bug | feature | improvement | refactor
   - **Status:** In Progress
   - **Description:** What needs to be done
   - **Expert(s):** (if using ./experts/ - optional)
   - **Plan:** Steps to implement
   - **Verification:** How to confirm it works
   - **Files:** (fill in as you work)
   ```
3. Add task to `./tracking/tasklist.md`:
   ```markdown
   ### [MS-####] Short description
   - **Type:** bug | feature | improvement
   - **DoD:** What "done" looks like
   - **Verification:** `./scripts/verify.ps1 fast` (Win) or `./scripts/verify.sh fast` (Unix)
   - **Status:** [ ] Not started
   ```
4. Increment `Next ID` in BOTH files

### For EXISTING work (ID already exists)

1. Find the MS-#### in `./tracking/tasklist.md`
2. Mark it `In Progress`
3. Continue from where it left off

## Execution

### Work Order (priority)

1. **First:** Existing unchecked P0/P1 items in `./tracking/tasklist.md`
2. **Then:** Newly created items from this message
3. **Finally:** Remaining items (P0 → P1 → P2)

### For Each Item

```
┌──────────────────────────────────────────────────┐
│  1. IMPLEMENT                                    │
│     - Make the smallest safe change              │
│     - Update ./tracking/assessment.md       │
└───────────────────────┬──────────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  2. VERIFY                          │
│     - Run: verify.ps1 fast (Win)    │
│            verify.sh fast (Unix)    │
│     - Run any item-specific tests   │
│     - Capture raw output            │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  3. RECORD                          │
│     - Paste evidence in assessment  │
│     - Mark task done in tasklist    │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  4. NEXT                            │
│     - Move to next item             │
│     - Or deliver if all done        │
└─────────────────────────────────────┘
```

### Verification Gate (NON-NEGOTIABLE)

**Do NOT mark done without evidence.**

- Run the verification runner
- Capture raw output (or log file path)
- Record in ./tracking/assessment.md
- Only THEN mark complete

## Labels (for tracking, not routing)

| Type | When to Use |
|------|-------------|
| `bug` | Something is broken / wrong |
| `feature` | Adding new capability |
| `improvement` | Enhancing existing functionality |
| `refactor` | Code cleanup, no behavior change |

The process is the same for all types. Labels help with prioritization and reporting.

## Mixed Work (Multiple Items)

If user provides multiple items:

1. Create MS-#### for each distinct piece of work
2. Each gets its own assessment entry and tasklist item
3. Execute in priority order
4. Verify each before moving to next

## Ambiguous Cases

| Situation | Resolution |
|-----------|------------|
| "Fix X" but X needs new code | Label as `bug`, implement what's needed |
| "Add Y" but it's really fixing missing behavior | Label as `feature`, doesn't matter |
| Not sure if bug or feature | Pick one, note your assumption, proceed |

The label is for humans. The process is the same.

---

## Response Format

When delivering work, output:

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
| Status | ✓ VERIFIED / ⚠ NEEDS ATTENTION |

### What Changed
- (Bullet list of changes)

### Verification Evidence
```
(Raw output or log path)
```

---

## After Work: Knowledge Capture

After completing work (especially significant decisions or discoveries):

1. Consider running `./workflows/session_end.md` to capture:
   - Decisions made during this work
   - Patterns observed in the codebase
   - User preferences expressed
   - Insights about the project

2. This keeps knowledge files populated for future sessions

**Skip if:** Trivial fix with no learning/decisions.
