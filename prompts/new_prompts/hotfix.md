# Hotfix — Emergency Production Fix

> **Mode:** 🟡 STANDARD — Urgent fix with mandatory rollback plan  
> **Time:** ~5-15 minutes  
> **Best for:** Production is broken, users are affected, speed matters

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** HOTFIX — Emergency fix, minimal scope, mandatory rollback.

---

## Emergency Details

### What's Broken
(Be specific — symptoms, error messages, affected users)

- 

### Impact
- [ ] Production down
- [ ] Data at risk
- [ ] Users blocked
- [ ] Security vulnerability
- [ ] Revenue impact

### When It Started
(Timestamp, recent deployment, etc.)

- 

---

## Hotfix Protocol

### 1. Diagnose (2 min max)
- Identify root cause
- Locate affected code
- Do NOT investigate tangential issues

### 2. Plan Rollback FIRST
Before changing anything:
```markdown
## Rollback Plan
- **Revert commit:** [hash or "create new"]
- **Database:** [no changes | rollback script needed]
- **External services:** [no impact | manual steps]
- **Test rollback:** [how to verify rollback works]
```

### 3. Implement Minimal Fix
- Change ONLY what's necessary
- No refactoring, no improvements
- No "while I'm here" changes

### 4. Verify
```powershell
./system/scripts/verify.ps1 fast  # Windows
```
```bash
./system/scripts/verify.sh fast   # Unix
```

Plus manual verification:
- [ ] Bug no longer reproduces
- [ ] No new errors introduced
- [ ] Affected users can proceed

### 5. Track
- Create MS-#### with P0 priority
- Document root cause
- Note follow-up work needed

---

## Output Format

```markdown
## HOTFIX: [Brief Description]

| Field | Value |
|-------|-------|
| **ID** | MS-XXXX (P0) |
| **Status** | ✅ DEPLOYED / ⚠️ READY / ❌ BLOCKED |
| **Root Cause** | [1-2 sentences] |
| **Files Changed** | `file.ts` |

### Rollback Plan
- Revert: `git revert [hash]`
- Database: [steps or "none"]
- Verify: [how]

### Fix Applied
- [What was changed]

### Verification
- [x] Verify script passed
- [x] Manual test passed
- [ ] Monitoring confirmed (if applicable)

### Follow-up Work (P1)
- [ ] Add test for this case
- [ ] Address root cause properly
- [ ] Update monitoring/alerts
```

---

## Anti-Patterns (Especially in Emergencies)

- ❌ "Let me also refactor this while I'm here"
- ❌ Skipping rollback plan
- ❌ Making multiple unrelated changes
- ❌ Not documenting the fix
- ❌ Forgetting follow-up work
```

---

## ✅ Done When

- [ ] Rollback plan documented BEFORE changes
- [ ] Minimal fix implemented
- [ ] Bug no longer reproduces
- [ ] MS-#### created with P0 priority
- [ ] Follow-up work captured

---

## Post-Hotfix

After the emergency is resolved:
1. Schedule proper fix via [work.md](work.md)
2. Add missing tests
3. Conduct mini post-mortem
4. Update monitoring if needed

---

## Related Prompts

- **Proper fix later?** → [work.md](work.md)
- **Need to understand first?** → [explain_this.md](explain_this.md)
- **Root cause analysis?** → [audit.md](audit.md)
