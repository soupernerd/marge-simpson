# Work — The Workhorse Prompt

> **Mode:** 🟡 STANDARD — Tracked work with verification  
> **Time:** ~10-30 minutes  
> **Best for:** Features, bugs, tasks, improvements — most common work

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** WORK — Implement with tracking and verification.

---

## Expert Loading (Required)

Load experts based on work type from ./system/experts/_index.md:
- Features → architecture.md + implementation.md
- Bugs → implementation.md + testing.md
- Security → security.md
- UI/UX → design.md
- Refactor → implementation.md

---

## Work Items

(Delete examples, replace with yours. One item per line.)

Format: [TYPE] Description
Types: FEATURE | BUG | TASK | REFACTOR | IMPROVEMENT

Examples (delete these):
- [FEATURE] Add CSV export to the reports dashboard
- [BUG] Login fails when password contains special characters  
- [TASK] Update dependencies to latest stable versions
- [REFACTOR] Extract auth logic into dedicated service
- [IMPROVEMENT] Add loading spinner to slow API calls

Your items:
- 

---

## Priority (optional)

If multiple items, specify priority:
- P0: Critical — blocks everything
- P1: High — needed soon
- P2: Medium — standard priority

---

## Execution Flow

For each work item:

### 1. Plan
- Identify affected files
- Consider edge cases
- Note any risks

### 2. Implement
- Make smallest safe change
- Follow existing code patterns
- Add tests if applicable

### 3. Verify
```powershell
./system/scripts/verify.ps1 fast  # Windows
```
```bash
./system/scripts/verify.sh fast   # Unix
```

### 4. Track
- Create MS-#### ID in ./system/tracking/assessment.md
- Add to ./system/tracking/tasklist.md
- Mark complete with evidence

---

## Output Format

```markdown
## Work Completed

| Field | Value |
|-------|-------|
| **IDs Touched** | MS-XXXX, MS-XXXY |
| **Files Modified** | `file1.ts`, `file2.ts` |
| **Status** | ✅ VERIFIED |

### What Changed
- [Bullet list of changes per ID]

### Verification Evidence
```
[Raw output from verify script]
```

### Remaining Work
| ID | Priority | Summary | Status |
|----|----------|---------|--------|
| MS-XXXX | P1 | ... | Not started |
```

---

## Anti-Patterns (Avoid These)

- ❌ "Fix everything" — too vague, specify what
- ❌ Mixing P0 and P2 items — handle in priority order
- ❌ Skipping verification — never claim done without evidence
- ❌ Large changes without plan — break into smaller items
```

---

## ✅ Done When

- [ ] All work items have MS-#### IDs
- [ ] Each item implemented and verified
- [ ] Evidence pasted in output
- [ ] assessment.md and tasklist.md updated

---

## Related Prompts

- **Quick fix?** → [fix_this.md](fix_this.md)
- **Emergency?** → [hotfix.md](hotfix.md)
- **Need to plan first?** → [plan_feature.md](plan_feature.md)
- **Found more issues?** → [audit.md](audit.md)
