# Dry Run: All Three Prompts (Post-Improvements)

Updated: 2026-01-28 (after MS-0006 through MS-0009)

---

## Prompt 1: `prompt.md` (General Purpose)

### The Prompt
```
Read marge-simpson/AGENTS.md and follow it.

Prompt:
- Example question: "What does the verify script do?"
- Example feature: "Add a --verbose flag to the CLI"
- Example issue: "The status command shows wrong folder name"
- Example confirmation: "MS-0042 is fixed"
- Example instruction: "Refactor the auth module to use JWT"

Output using Response Format from AGENTS.md.
```

### Trace: Question ("What does the verify script do?")
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Question only" | → Answer directly |
| 3 | Mode? | N/A (no edits) |
| 4 | Expert load? | Not required |
| 5 | Execute | Read verify.ps1, explain |
| 6 | Response | Answer + token estimate |

**Verdict:** ✅ Clean. No friction.

### Trace: Feature ("Add a --verbose flag to the CLI")
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Work request" | → work.md |
| 3 | Mode? | Full (behavior change) |
| 4 | Expert load? | Index → engineering.md |
| 5 | Work intake | Small feature (< 50 lines) → use Bug/Improvements path |
| 6 | Execute | Modify CLI, create MS-#### |
| 7 | Verify | Run verify.ps1 fast |
| 8 | Record | Update tracking |
| 9 | Response | IDs, files, verification |

**Verdict:** ✅ Clean. Small/large distinction works.

### Trace: Bug ("The status command shows wrong folder name")
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Work request" | → work.md |
| 3 | Mode? | Full (behavior change) |
| 4 | Execute | Find bug, fix it, MS-#### |
| 5 | Verify | ✓ |
| 6 | Response | Standard format |

**Verdict:** ✅ Clean.

### Trace: Confirmation ("MS-0042 is fixed")
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Confirmation (MS-#### done)" | → Verify claim, update tracking, mark Done |
| 3 | Mode? | Lite (status update) |
| 4 | Execute | Check assessment.md for evidence, mark Done |
| 5 | Response | Confirm or ask for evidence |

**Verdict:** ✅ Clean. New routing handles this.

### Trace: Instruction ("Refactor the auth module to use JWT")
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Work request" | → work.md |
| 3 | Mode? | Full (refactor) |
| 4 | Expert load? | Index → engineering.md + security.md |
| 5 | Execute | Do the refactor |
| 6 | Verify, Record | ✓ |

**Verdict:** ✅ Clean.

### prompt.md Summary
| Example | Verdict |
|---------|---------|
| Question | ✅ |
| Feature | ✅ |
| Bug | ✅ |
| Confirmation | ✅ (fixed) |
| Instruction | ✅ |

**No issues found.**

---

## Prompt 2: `audit.md` (Analysis Only)

### The Prompt
```
Read marge-simpson/AGENTS.md and follow it.

**AUDIT MODE** - Analysis + tracking updates only. Do not modify target code or behavior.

1. Understand the system (read key files, map components)
2. Identify issues (P0 -> P1 -> P2 priority)
3. Update tracking docs (assessment.md, tasklist.md) with MS-#### IDs
4. Stop. Report findings in chat as a table (MS-#### + 1-2 sentence summary per issue)

Output using Response Format from AGENTS.md.
```

### Trace
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Audit request" | → audit.md |
| 3 | Mode? | Full (audit) |
| 4 | Clarify scope? | **NEW:** Present scope selection menu if unclear |
| 5 | Expert load? | **NEW:** Default to Code audit (engineering + quality) |
| 6 | Load prior context | ✓ Check knowledge files |
| 7 | Discovery | Scan, document findings |
| 8 | Generate MS-#### | For actionable items |
| 9 | Stop condition | **NEW:** "AUDIT MODE" banner = explicit stop signal |
| 10 | Response format | **NEW:** Inline format (table) takes precedence |

**Verdict:** ✅ Clean. New improvements working.

### What the User Sees

```
┌─────────────────────────────────────────┐
│          AUDIT SCOPE SELECTION          │
├─────────────────────────────────────────┤
│  What would you like to audit?          │
│                                         │
│  [1] Full codebase                      │
│  [2] Specific folder (you specify)      │
│  [3] Recent changes (since last commit) │
│  [4] Security-focused review            │
│  [5] Architecture/design review         │
│                                         │
│  Reply with a number or describe scope. │
└─────────────────────────────────────────┘
```

(Only shown if scope is unclear — skip for meta-marge context)

Then the findings table as requested.

**No issues found.**

---

## Prompt 3: `suggest.md` (Planning/Brainstorm)

### The Prompt
```
Read marge-simpson/AGENTS.md and follow it.

**PLANNING MODE** - No code changes. Documentation is allowed.

Propose 3-8 features for this project, ranked by end-user value.

For each:
- **What:** 1-2 sentence description
- **Why:** Who benefits
- **Risk:** Biggest blocker

Create: marge-simpson/system/tracking/recommended_features.md

To approve a feature: "Approve feature [N] from recommendations"

Output using Response Format from AGENTS.md.
```

### Trace
| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing: "Planning request" | → planning.md |
| 3 | Mode? | Planning mode (no code) |
| 4 | Expert load? | **Required** per planning.md |
| 5 | Execution | Analyze project, create recommendations file |
| 6 | MS-#### needed? | **No** — suggestions don't need IDs |
| 7 | Output | Create `recommended_features.md` |
| 8 | Response | Standard format + approval hint |

**Verdict:** ✅ Clean.

### What Happens When User Approves?

User says: **"Approve feature 3"** or **"Approve feature [3] from recommendations"**

| Step | Action | Result |
|------|--------|--------|
| 1 | Read AGENTS.md | ✓ |
| 2 | Routing | "Work request" (not planning) |
| 3 | Mode? | Full |
| 4 | What to do? | Read `recommended_features.md`, find feature 3 |
| 5 | Work intake | Create MS-####, add to tasklist |
| 6 | Execute | Implement the feature |

**Question:** Does this work without `approve.md`?

**Test:** "Approve feature 3"
- AGENTS.md routing: Not a question, not audit, not planning → **Work request**
- work.md: User asked to do something → execute it
- AI should read recommended_features.md to understand what "feature 3" means

**Answer:** ✅ Yes, `prompt.md` handles this. `approve.md` is redundant.

---

## Summary: All Prompts Post-Improvements

| Prompt | Status | Issues |
|--------|--------|--------|
| prompt.md | ✅ Clean | None — handles all 5 example types |
| audit.md | ✅ Clean | Scope menu + defaults work well |
| suggest.md | ✅ Clean | Approval flows through prompt.md |
| approve.md | ⚠️ Redundant | Can be removed |

---

## Recommendations

### 1. Remove `approve.md`
The general `prompt.md` handles feature approval via routing. Having a separate file:
- Adds maintenance overhead
- Creates confusion about which to use
- The hint in `suggest.md` ("To approve: ...") works fine without it

### 2. Consider Simplifying Prompt Files

Current structure:
```
prompts/
├── _index.md       # Index
├── prompt.md       # General (handles 5+ cases)
├── audit.md        # Analysis-only
├── suggest.md      # Feature brainstorm
└── approve.md      # (redundant)
```

Potential simplified structure:
```
prompts/
├── _index.md       # Index
├── prompt.md       # General (everything routes through AGENTS.md)
├── audit.md        # Analysis-only (has AUDIT MODE banner)
└── suggest.md      # Feature brainstorm (has PLANNING MODE banner)
```

### 3. The Banner Pattern Works Well

Both `audit.md` and `suggest.md` use bold banners:
- `**AUDIT MODE** - Analysis + tracking updates only.`
- `**PLANNING MODE** - No code changes.`

This is **excellent UX** — makes intent unmistakable. Consider documenting this as a pattern for future prompts.

---

## UX Quality Check

| Aspect | Score | Notes |
|--------|-------|-------|
| **Clarity** | 9/10 | Banners + numbered steps are clear |
| **Routing** | 10/10 | All cases now handled |
| **Expert loading** | 9/10 | Index-first approach works |
| **Tracking** | 8/10 | Works but could still be lighter for simple tasks |
| **Error recovery** | 8/10 | Stop conditions explicit |
| **Discoverability** | 7/10 | Users must know prompts exist |

**Overall:** The system is solid. Main remaining friction is tracking overhead for tiny fixes, but that's by design (Lite mode exists for those).
