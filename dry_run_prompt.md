# Dry Run: `prompt.md` Routing Trace

## Example 1: Question
**Prompt:** "What does the verify script do?"

| Step | Action | Result |
|------|--------|--------|
| 1. Read AGENTS.md | ✅ Done | |
| 2. Routing table lookup | Intent = "Question only" → Answer directly | |
| 3. Mode? | No edit needed | N/A (no MODE block) |
| 4. Expert load? | Not required for questions | |
| 5. Action | Read `verify.ps1`, explain it | |
| 6. Tracking? | No MS-#### needed | |
| 7. Response format | Answer + token estimate | |

**Verdict:** ✅ **Clean path.** Questions route correctly without overhead.

---

## Example 2: Feature
**Prompt:** "Add a --verbose flag to the CLI"

| Step | Action | Result |
|------|--------|--------|
| 1. Read AGENTS.md | ✅ Done | |
| 2. Routing table lookup | Intent = "Work request" → `work.md` | |
| 3. Mode? | Full (feature = behavior change) | |
| 4. Expert load? | AGENTS.md says "Full mode: load relevant expert before work" | engineering.md |
| 5. Work intake | Create MS-#### ID | |
| 6. What plan? | **work.md says:** Create `.meta_marge/system/tracking/[name]_MS-####.md` from template | |
| 7. Execute | Modify CLI files | |
| 8. Verify | Run verify.ps1 fast | |
| 9. Record | Update assessment.md + tasklist.md | |
| 10. Response | IDs, files, verification, knowledge | |

**Verdict:** ⚠️ **Potential friction.** For small features, creating a separate plan file feels heavyweight. The user just said "add a flag" — do they want a whole planning document first?

**Issue:** work.md Features section says "Create plan: `.meta_marge/system/tracking/[name]_MS-####.md`" — but this is overkill for small features. Should distinguish "big feature" (needs plan) vs "small feature" (just do it).

---

## Example 3: Bug/Issue
**Prompt:** "The status command shows wrong folder name"

| Step | Action | Result |
|------|--------|--------|
| 1. Read AGENTS.md | ✅ Done | |
| 2. Routing table lookup | Intent = "Work request" → `work.md` | |
| 3. Mode? | Full (affects behavior) | |
| 4. Expert load? | engineering.md (code change) | |
| 5. Work intake | Use "Bugs/Improvements/Refactors" path | No separate plan file |
| 6. Execute | Find bug, fix it | |
| 7. Verify | Run verify.ps1 fast | |
| 8. Record | Update assessment.md + tasklist.md | |
| 9. Response | IDs, files, verification, knowledge | |

**Verdict:** ✅ **Clean path.** Bug workflow is straightforward.

---

## Example 4: Confirmation
**Prompt:** "MS-0042 is fixed"

| Step | Action | Result |
|------|--------|--------|
| 1. Read AGENTS.md | ✅ Done | |
| 2. Routing table lookup | **??? No explicit match** | |
| 3. Inferred intent | User confirming completion | |
| 4. What to do? | Mark MS-0042 as Done in tracking files? | |
| 5. Mode? | Lite? (just updating status) | |
| 6. Where documented? | **Nowhere** | |

**Verdict:** ❌ **Gap.** No routing or workflow for confirmation prompts. What should happen?
- Read assessment.md to find MS-0042?
- Mark it Done?
- Ask for verification evidence first?
- Just acknowledge?

---

## Example 5: Instruction
**Prompt:** "Refactor the auth module to use JWT"

| Step | Action | Result |
|------|--------|--------|
| 1. Read AGENTS.md | ✅ Done | |
| 2. Routing table lookup | Intent = "Work request" → `work.md` | |
| 3. Mode? | Full (refactor, multi-file likely) | |
| 4. Expert load? | engineering.md + security.md (auth + JWT) | |
| 5. Work intake | Type = refactor | Bugs/Improvements/Refactors path |
| 6. Execute | Do the refactor | |
| 7. Verify | Run verify.ps1 fast | |
| 8. Record | Update tracking | |
| 9. Response | Standard format | |

**Verdict:** ✅ **Clean path.** Refactors route correctly.

---

## Summary of Findings

| Example | Verdict | Issue |
|---------|---------|-------|
| Question | ✅ Clean | — |
| Feature | ⚠️ Friction | Separate plan file for ALL features is overkill |
| Bug/Issue | ✅ Clean | — |
| Confirmation | ❌ Gap | No routing for confirmation prompts |
| Instruction | ✅ Clean | — |

---

## Proposed Fixes

**1. Feature size distinction (work.md)**
Add guidance: "Small feature (< 1 day work) → use Bugs/Improvements path. Large feature (multi-day, phased) → create plan file."

**2. Confirmation routing (AGENTS.md)**
Add row to routing table:
```
| Confirmation (MS-#### done) | Verify claim, update tracking |
```

**3. Confirmation workflow (work.md)**
Add section for handling confirmations — what evidence to require, how to mark complete.
