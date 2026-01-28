# Audit Workflow

> Discovery phase for system-wide review. Generates work items, then hands off to work.md.

## When to Use

User explicitly asks for:
- "Audit the codebase"
- "Review the system"
- "Check for issues"
- "Analyze the code"

**This is the ONLY workflow with a discovery phase.** Regular work items skip straight to execution.

## Load Experts (Required)

Audits require expert subagents. Load based on audit type:
- **Security audit** → `marge-simpson/system/experts/security.md`
- **Code audit** → `marge-simpson/system/experts/engineering.md` + `marge-simpson/system/experts/quality.md`
- **Architecture audit** → `marge-simpson/system/experts/engineering.md`
- **Full audit** → Multiple experts per `marge-simpson/system/experts/_index.md`

## Phase 1: Discovery

### Load Prior Context

Before scanning, check what's already known:

1. **Read `marge-simpson/system/knowledge/_index.md`** — check Quick Stats and Recent Entries
2. **Grep `marge-simpson/system/knowledge/decisions.md`** for architectural decisions:
   ```powershell
   Select-String -Path "marge-simpson/system/knowledge/decisions.md" -Pattern "#architecture|#database|#api"
   ```
3. **Note any constraints** — don't flag issues that contradict known decisions

### Resolve Tracking Location

Use the tracking paths from the active AGENTS.md:
- If the prompt instructs "Read .meta_marge/AGENTS.md" (meta run), track in `.meta_marge/system/tracking/`
- Otherwise, track in `marge-simpson/system/tracking/`

### Target of Changes (Meta Runs)

When using `.meta_marge/AGENTS.md`, apply fixes to `marge-simpson/` (not `.meta_marge/`).
If a meta audit finds issues in meta guidance itself, fixes belong in `marge-simpson/` or `.dev/meta` (meta creation scripts).

### Scan the Codebase

1. Read and understand:
   - Project structure (folders, key files)
   - Architecture patterns
   - Major workflows / entry points
   - Dependencies

2. Identify issues by category:
   - **Correctness:** Bugs, logic errors, broken flows
   - **Security:** Vulnerabilities, unsafe patterns
   - **Performance:** Bottlenecks, inefficiencies
   - **Maintainability:** Tech debt, unclear code
   - **Missing:** Gaps in functionality or tests

3. Do NOT break intended functionality while auditing.

### Document Findings

Update the active tracking `assessment.md` (see "Resolve Tracking Location"):

```markdown
## Audit: [Date] - [Scope]

### Snapshot
- **Scope:** What was audited
- **Status:** In progress / Complete
- **Top Risks:** Critical issues found

### Findings by Area

#### [Area 1]
- Finding 1
- Finding 2

#### [Area 2]
- Finding 1
```

### Generate Work Items

For each actionable finding:

1. Create MS-#### ID
2. Add assessment entry (symptom → root cause → fix plan)
3. Add tasklist entry (DoD + verification)
4. Increment Next ID

Prioritize:
- **P0:** Security issues, data loss risks, broken core functionality
- **P1:** Bugs affecting users, significant tech debt
- **P2:** Improvements, nice-to-haves, minor cleanup

## Phase 2: Execution

**After discovery:** If user wants issues fixed, fix them. Don't wait for a second "please execute" prompt.

After discovery, you have a populated tasklist. Execute using the standard work workflow:

1. Work through items in priority order (P0 → P1 → P2)
2. Verify each before moving to next
3. Update docs as you go

**If user says "audit and fix" → do both. If user says "audit only" → stop after discovery.**

## Response Format

After audit discovery, report:

```markdown
## Audit Complete

### Summary
- **Files scanned:** X
- **Issues found:** Y
- **Work items created:** MS-0001 through MS-000Z

### Priority Breakdown
| Priority | Count | Examples |
|----------|-------|----------|
| P0 | N | Critical security issue |
| P1 | N | Auth flow bug |
| P2 | N | Code cleanup |

### Ready to Execute
Proceeding with P0 items...
```

Stop after discovery and reporting unless the user asks to proceed.
