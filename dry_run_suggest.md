# Dry Run Trace: `suggest.md` prompt

---

## Step 1: Routing Decision

**Input signals:**
- "Read .meta_marge/AGENTS.md" → Meta-development context
- "**PLANNING MODE**" → Explicit planning trigger
- "No implementation changes" → Planning signal
- "Create: .meta_marge/system/tracking/recommended_features.md" → File creation request

**AGENTS.md Routing table check:**
| Intent | Action |
|--------|--------|
| Planning request | `.meta_marge/system/workflows/planning.md` |

**Decision:** Route to `planning.md` workflow

---

## Step 2: Load Workflow

**Would read:** `.meta_marge/system/workflows/planning.md`

**Key rules from planning.md:**
- "No Implementation Code" section says:
  - ❌ DO NOT modify source code, configs, or scripts
  - ❌ DO NOT run verification scripts
  - ✅ **DO create:** Plan documents, MS-#### ID for the plan, documentation of recommendations

**Conflict check:** The prompt says "No implementation changes" but also "Create: recommended_features.md"
- planning.md explicitly allows: "Documentation of recommendations (e.g., `marge-simpson/system/tracking/recommended_features.md`)"
- ✅ This is permitted — documentation ≠ implementation

---

## Step 3: Mode Selection

**Check triggers:**
- Single file creation (documentation)
- No behavior change
- Planning mode explicitly stated

**However:** Planning creates an MS-#### ID per planning.md rules

**Decision:** Full mode (planning with ID tracking)

```
+---------------------------------------------+
| MODE: Full                                  |
| ID: MS-0005 (plan)                          |
| REASON: Planning mode with tracked output   |
+---------------------------------------------+
```

---

## Step 4: Expert Loading

**planning.md requires:**
> "Bring in relevant experts for planning discussions"

**For feature proposals, would load:**
- `marge-simpson/system/experts/engineering.md` — Architecture/feature assessment

**Would NOT load:** security.md (no security focus in prompt)

---

## Step 5: Context Gathering

**To propose meaningful features, I would read:**

1. **Current capabilities** — Already know from audit:
   - CLI (marge, marge-init, install-global)
   - Workflows (audit, work, loop, planning, session_*)
   - Experts system
   - Knowledge capture
   - Verification suite

2. **Existing roadmap/issues** — Check:
   - `.meta_marge/system/tracking/tasklist.md` (know MS-0002 is open)
   - `.meta_marge/system/tracking/assessment.md` (current state)

3. **User patterns** — Would check:
   - `.meta_marge/system/knowledge/preferences.md`
   - `.meta_marge/system/knowledge/patterns.md`

4. **README.md** — Feature gaps vs documented capabilities

---

## Step 6: Actions

**Would create:** `.meta_marge/system/tracking/recommended_features.md`

**Content structure:**
```markdown
# Recommended Features — MS-0005

## Methodology
- Analyzed current capabilities
- Identified gaps based on user workflows
- Ranked by end-user value

## Proposed Features

### 1. [Feature Name]
- **What:** ...
- **Why:** ...
- **Risk:** ...

### 2. [Feature Name]
...
(3-8 features total)
```

**Would also update:**
- `.meta_marge/system/tracking/assessment.md` — Add MS-0005 entry with Status: Planning
- `.meta_marge/system/tracking/assessment.md` — Increment Next ID to MS-0006

---

## Step 7: Verification

**planning.md says:** "DO NOT run verification scripts"

**So:** No verify.ps1 run. File creation only.

---

## Step 8: Response Format

Per AGENTS.md, would end with:
- IDs touched: MS-0005
- Files modified: `recommended_features.md`, `assessment.md`
- Verification output: N/A (planning mode)
- Token estimate

---

## ⚠️ Issues Noticed

1. **Path inconsistency in prompt:** The prompt says `Create: .meta_marge/system/tracking/recommended_features.md` but the base `suggest.md` in marge-simpson says `marge-simpson/system/tracking/recommended_features.md`. The .meta_marge version was correctly transformed.

2. **ID tracking question:** Should a planning document get an MS-#### ID? The planning.md says yes ("MS-#### ID for the plan itself"), but this feels like overhead for a suggestions doc. Could be P2 to clarify.

3. **No tasklist update:** planning.md doesn't explicitly say to add to tasklist.md for planning items — only assessment.md. Is that intentional? (Plans aren't "work" until approved?)
