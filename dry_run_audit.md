# Dry Run: `audit.md` Prompt Trace

## The Prompt
```
Read .meta_marge/AGENTS.md and follow it.

**AUDIT MODE** - Analysis + tracking updates only. Do not modify target code or behavior.

1. Understand the system (read key files, map components)
2. Identify issues (P0 -> P1 -> P2 priority)
3. Update tracking docs (assessment.md, tasklist.md) with MS-#### IDs
4. Stop. Report findings in chat as a table (MS-#### + 1-2 sentence summary per issue)

Output using Response Format from AGENTS.md.
```

---

## Step-by-Step Trace

### Step 1: Read AGENTS.md
| Action | Result |
|--------|--------|
| Read `.meta_marge/AGENTS.md` | ✅ Done |
| Core Principle | "User prompt = Approval to execute" |
| Routing table lookup | Intent = "Audit request" → `.meta_marge/system/workflows/audit.md` |

### Step 2: Determine Mode
| Check | Result |
|-------|--------|
| Is this a single-line typo/comment? | No |
| Is this Full mode? | Yes (audit = Full mode per Task Modes table) |
| Expert load required? | Yes ("NEVER skip expert load in Full mode") |

### Step 3: Load Audit Workflow
| Action | Result |
|--------|--------|
| Read `.meta_marge/system/workflows/audit.md` | ✅ Done |
| Workflow has "Load Experts (Required)" section | Must load experts |

### Step 4: Load Experts
| Audit Type | Experts to Load |
|------------|-----------------|
| Full audit | `_index.md` → then relevant experts |
| Code audit | `engineering.md` + `quality.md` |

**Wait — which type is this audit?**

The prompt says "AUDIT MODE" but doesn't specify security/code/architecture/full.

**Issue Found:** Ambiguous audit type. AI must guess or ask.

### Step 5: Load Prior Context (per audit.md)
| Action | Check |
|--------|-------|
| Read `_index.md` for Quick Stats | ✓ |
| Grep `decisions.md` for constraints | ✓ |
| Note constraints before flagging issues | ✓ |

### Step 6: Resolve Tracking Location
| Check | Result |
|-------|--------|
| Prompt says "Read .meta_marge/AGENTS.md" | Yes → meta run |
| Track in | `.meta_marge/system/tracking/` ✓ |
| Apply fixes to | `marge-simpson/` (not `.meta_marge/`) |

### Step 7: Execute Discovery Phase
| Action | Result |
|--------|--------|
| Scan codebase structure | ✓ |
| Identify issues by category | ✓ |
| Document in assessment.md | ✓ |
| Create MS-#### for actionable findings | ✓ |
| Add to tasklist.md | ✓ |
| Prioritize P0 → P1 → P2 | ✓ |

### Step 8: What Happens Next?

**Conflict detected!**

The **prompt** says:
> "4. Stop. Report findings in chat as a table"

The **audit.md workflow** says:
> "After discovery, you have a populated tasklist. Execute using the standard work workflow"
> "If user says 'audit and fix' → do both. If user says 'audit only' → stop after discovery."

The prompt clearly says "AUDIT MODE - Analysis + tracking updates only. Do not modify target code."

**Resolution:** Prompt takes precedence. Stop after discovery.

### Step 9: Response Format

**Another conflict!**

The **prompt** says:
> "Output using Response Format from AGENTS.md."

The **audit.md workflow** has its own response format:
```markdown
## Audit Complete
### Summary
- Files scanned: X
- Issues found: Y
...
```

**Question:** Which format to use?
- AGENTS.md Response Format: IDs touched, Files modified, Verification output, Knowledge captured
- audit.md Response Format: Summary table, Priority breakdown

**The prompt asks for:** "Report findings in chat as a table (MS-#### + 1-2 sentence summary per issue)"

**Resolution:** The prompt's inline format request takes precedence. Output a simple table.

---

## Summary of Findings

| Step | Verdict | Issue |
|------|---------|-------|
| 1. Read AGENTS.md | ✅ Clean | — |
| 2. Determine Mode | ✅ Clean | — |
| 3. Load audit.md | ✅ Clean | — |
| 4. Load Experts | ⚠️ Ambiguous | No audit type specified in prompt |
| 5. Load Prior Context | ✅ Clean | — |
| 6. Resolve Tracking | ✅ Clean | — |
| 7. Execute Discovery | ✅ Clean | — |
| 8. Stop vs Continue | ⚠️ Conflict | Prompt says stop, workflow says maybe continue |
| 9. Response Format | ⚠️ Conflict | Three different formats compete |

---

## Issues Identified

### Issue 1: Audit Type Not Specified (Ambiguous)
**Location:** `prompts/audit.md`
**Problem:** The prompt doesn't specify what kind of audit (security, code, architecture, full).
**Impact:** AI must guess which experts to load.
**Suggested Fix:** Either specify in the prompt OR add guidance in audit.md for "when type is unspecified, default to X"

### Issue 2: Stop/Continue Conflict
**Location:** `prompts/audit.md` vs `system/workflows/audit.md`
**Problem:** Prompt says "Stop" but workflow says "execute unless user says audit only"
**Impact:** Low — prompt is explicit, so AI should follow it. But workflow guidance is confusing.
**Suggested Fix:** Align workflow language. Add: "If prompt explicitly says 'analysis only' or 'do not modify', stop after discovery."

### Issue 3: Response Format Conflict
**Location:** `prompts/audit.md` vs `system/workflows/audit.md` vs `AGENTS.md`
**Problem:** Three competing format specifications:
  1. AGENTS.md Response Format (IDs, files, verification)
  2. audit.md Response Format (summary, priority breakdown)
  3. Prompt's inline request (table with MS-#### + summary)
**Impact:** Medium — AI must decide which to prioritize.
**Suggested Fix:** Clarify precedence: "Inline prompt format requests override workflow defaults"

---

## Proposed Fixes

**1. Default audit type (audit.md)**
Add to "Load Experts" section:
```markdown
**If audit type not specified:** Default to Code audit (engineering.md + quality.md).
```

**2. Explicit stop condition (audit.md)**
Add to "Phase 2: Execution":
```markdown
**Explicit stop signals:** If the prompt says "analysis only", "do not modify", or "stop after discovery", do NOT proceed to execution.
```

**3. Format precedence (AGENTS.md or audit.md)**
Add clarification:
```markdown
**Format precedence:** Inline prompt requests > workflow-specific format > AGENTS.md Response Format
```
