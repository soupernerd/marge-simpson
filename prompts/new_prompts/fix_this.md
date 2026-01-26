# Fix This — Quick Fix, Minimal Ceremony

> **Mode:** 🟢 LITE — Fast fix, no tracking overhead  
> **Time:** ~2-5 minutes  
> **Best for:** Typos, small bugs, formatting, comments — things that don't need ceremony

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** LITE — Quick fix, no tracking IDs needed.

---

## What to Fix

(Delete examples, replace with yours)

- "Fix the typo in README.md line 42"
- "The button color should be #3B82F6 not #3B82F5"
- "Add missing semicolon in utils.js"
- "Update copyright year to 2026"

Your fix:
- 

---

## Verification

After fixing, confirm:
- [ ] Change is minimal and correct
- [ ] No unintended side effects
- [ ] File saves without errors

---

## Output Format

**Fixed:** [What was fixed]
**File:** [Filename:line]
**Before:** `[old value]`
**After:** `[new value]`

---

Do NOT:
- Create MS-#### tracking IDs (too small for tracking)
- Update assessment.md or tasklist.md
- Make changes beyond what's requested
```

---

## ✅ Done When

- [ ] The specific issue is fixed
- [ ] Nothing else changed

---

## When to Use Something Else

| If... | Use Instead |
|-------|-------------|
| Fix requires multiple files | [work.md](work.md) |
| Fix could break things | [work.md](work.md) with verification |
| It's a production emergency | [hotfix.md](hotfix.md) |
| Not sure what to fix | [explain_this.md](explain_this.md) first |

---

## Related Prompts

- **Bigger change needed?** → [work.md](work.md)
- **Found more issues?** → [audit.md](audit.md)
