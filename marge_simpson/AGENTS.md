# AGENTS.md — Assistant Operating Rules

This folder is a drop-in workflow for running audits and fixing bugs in any codebase.

**Priority order:** correctness > safety > minimal diffs > speed

**CRITICAL RULES:** (REQUIRED)
1. The `marge_simpson/` folder itself is excluded from audits and issue scans - it is the tooling, not the target, unless `meta_marge/` exists and is being used to update Marge.
2. Marge NEVER creates marge_simpson related files outside its own folder. All tracking docs, logs, and artifacts stay within `marge_simpson/`.

---

## A) Universal Rules

### Code First
- Read relevant files before making claims. If you haven't opened it, don't speculate.

### Cost-Aware
- Proceed with reasonable assumptions. Ask questions only when blocked or when wrong assumptions cause major rework.

### Root Causes
- Fix at the source. Avoid band-aids.

### Minimal Changes
- Touch the fewest files/lines necessary. Avoid refactors unless required.

### Major-Change Checkpoint
Before architecture changes, large refactors, schema changes, or API contract changes:
- Stop and request approval with plan + risks + rollback notes.

### Security Default
- No secrets in code, no injection risks, no unsafe patterns. Use env vars.

### Uncertainty Policy
- Say what you checked, what you know, and what remains unknown.

### Token Estimate (REQUIRED)
**CRITICAL:** At the END of EVERY response, include this line:

`📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

**Rules:**
- Input ≈ (context chars / 4) — attachments + file contents + conversation
- Output ≈ (your response chars / 4)
- Model pricing: See `marge_simpson/model_pricing.json` (human-maintained)
- Formula: Cost = (input/1M × input_per_1m) + (output/1M × output_per_1m)
- Round tokens to nearest 100, cost to 4 decimals
- **Never skip this. No exceptions.**

---

## B) Tracking System

### IDs
- All tracked work uses: `MS-0001`, `MS-0002`, ...
- Maintain `Next ID:` field in BOTH:
  - `marge_simpson/assessment.md`
  - `marge_simpson/tasklist.md`
- When creating new work: use current ID, then increment in both files.

### Source Files
| File | Purpose |
|------|---------|
| `assessment.md` | Findings, root cause, verification evidence |
| `tasklist.md` | Work queue: backlog → in-progress → done |
| `instructions_log.md` | Append-only log of user instructions |

---

## C) Verification Gate (NON-NEGOTIABLE)

For each MS-#### item:

```
1. IMPLEMENT → smallest safe fix
       ↓
2. VERIFY → run ./marge_simpson/scripts/verify.ps1 fast (or verify.sh)
       ↓
3. RECORD → paste evidence in assessment.md
       ↓
4. COMPLETE → mark done in tasklist.md, move to next
```

**Never claim "tests passed" without raw output or log file path.**

Use `-SkipIfNoTests` / `--skip-if-no-tests` for repos without tests.

### Iterative Loop Mode (Optional)

When the user's message includes phrases like:
- "loop until clean"
- "iterate until done" 
- "keep going until no issues"
- "repeat until perfect"

**Activate iterative validation for the requested work:**

```
┌─────────────────────────────────────┐
│  1. COMPLETE THE REQUESTED WORK     │
│     - Feature? Build it fully       │
│     - Bug? Fix it completely        │
│     - Audit? Scan thoroughly        │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  2. VALIDATE AGAINST PROMPT INTENT  │
│     - Does it fulfill the request?  │
│     - Any edge cases missed?        │
│     - Any regressions introduced?   │
│     - Run verification if applicable│
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  3. LOOP OR EXIT                    │
│     - Gaps/issues found? → Fix them │
│     - Fully complete? → Done        │
└─────────────────────────────────────┘
```

**Loop validation by work type:**

| Work Type | Loop Validates Until... |
|-----------|------------------------|
| **Feature** | Fully implemented, all edge cases handled, tests pass |
| **Bug/Issue** | Root cause fixed, no regressions, verification passes |
| **Instruction** | All instructions executed correctly and completely |
| **Audit** | Zero new findings on full re-scan |
| **Confirmation** | The specific item is verified as truly resolved |
| **Question** | ⛔ NO LOOP - answer once, done |
| **Planning** | ⛔ NO LOOP - proposals/brainstorms don't iterate |

**When NOT to loop (auto-skip even if triggered):**
- Pure questions (curiosity, "how", "why", "what does X do")
- Planning mode prompts (contains "PLANNING ONLY" or "no code changes")
- Already-answered items in a mixed prompt

**Mixed prompts:** Loop applies ONLY to work items, not questions. Answer questions once, then loop on the actionable work.

**Loop rules:**
- The loop validates **the specific work requested** (not generic scanning)
- Keep a short "Pass N" log of what was found/improved/completed
- Continue until the work is **fully complete with zero remaining gaps**
- Default maximum: 5 passes (ask user if more needed)

**Min/Max loop counts (optional):**

Users can specify iteration bounds in their prompt:

| Phrase | Behavior |
|--------|----------|
| `min 3` or `minimum 3 times` | Run at least 3 passes, even if clean earlier |
| `max 10` or `maximum 10 times` | Stop after 10 passes, even if not clean |
| `min 2 max 8` | Run 2-8 passes |
| `exactly 5` or `run 5 times` | Run exactly 5 passes |

**Parsing rules:**
- Look for `min/minimum` followed by a number
- Look for `max/maximum` followed by a number
- Look for `exactly` or `run X times` for fixed count
- If no max specified, default max is 5
- If min > max, treat as exactly min passes
- Numbers can be digits (5) or words (five) for 1-10

**Examples:**
- Feature request + loop → Keep refining until feature is complete and tested
- Bug fix + loop → Keep fixing until bug is fully resolved with no regressions
- Audit + loop → Keep scanning until zero new issues found
- Question + loop → Loop ignored, answer provided once
- Planning + loop → Loop ignored, proposals provided once

---

## D) Intent Router

Infer user intent from context, not keywords.

| Intent | Signals | Action |
|--------|---------|--------|
| **Question** | "How", "why", "what", curiosity | Answer directly. No ID unless issue found. |
| **Work** | Fix, add, change, build, broken, error | Read `workflows/work.md`. Create/continue MS-####. |
| **Audit** | "Audit", "review codebase", "scan" | Read `workflows/audit.md` first. |

### Mixed Intent
If message has multiple intents:
1. Answer questions immediately
2. Create MS-#### for each work item
3. Execute in priority order

### Ambiguous
- Make a reasonable assumption and proceed
- State briefly: "Treating this as a feature request..."

---

## E) Response Format

When delivering work:

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
- (Bullet list)

### Verification Evidence
```
(Raw output or log path)
```

---

## F) Chunked Resources (Token-Efficient)

### Routing (Simple)
1. Start at `AGENTS.md`. Use Intent Router to pick the workflow.
2. Read only `workflows/_index.md`, then open the single workflow file you need.
3. If experts/knowledge are needed, read their `_index.md` first, then only the targeted small files.
4. Track work only in the folder whose AGENTS you read.
5. Keep changes minimal; avoid extra file reads unless blocked.

### Workflows
Read only when needed:
- `workflows/session_start.md` — knowledge retrieval at conversation start
- `workflows/work.md` — unified bug/feature/improvement process
- `workflows/audit.md` — codebase discovery phase
- `workflows/session_end.md` — knowledge capture + memory evolution

### Memory Evolution (CRITICAL)
**Memory is infrastructure, not a feature.** Knowledge must evolve, not just accumulate.

| Principle | Rule |
|-----------|------|
| **Evolve, don't append** | New info supersedes old → UPDATE existing entry |
| **Atomic facts** | One fact per entry. No compound statements. |
| **Conflict check first** | ALWAYS search before adding new entry |
| **Decay is healthy** | Unverified/unused entries should be archived |

**Before writing to knowledge/:**
1. Search existing entries for overlap
2. If conflict found → update existing entry with `Updated:` field
3. If truly new → add with next available ID
4. Never create duplicate concepts

### Experts (Optional)
If `experts/` folder exists:
1. Read `experts/_index.md` first (~400 tokens)
2. Find keywords in the table
3. Read only the relevant expert file(s)

### Knowledge Retrieval (REQUIRED)
**At session start:** Read `workflows/session_start.md` and apply stored preferences.

**During work:** Before making decisions, check:
1. `decisions.md` — prior choices on same topic?
2. `preferences.md` — user's typical approach?
3. `patterns.md` — observed behavior to follow?

**If conflict:** Surface it, don't silently override.

### Cost Awareness
| Scenario | Tokens |
|----------|--------|
| Question only | ~1,500 (this file) |
| Work item | ~2,500 (+ work.md) |
| Full audit | ~3,000 (+ audit.md + work.md) |
| With experts | +1,200 per expert file |

---

## G) Quick Reference

### Verification Commands
```bash
# Windows
./marge_simpson/scripts/verify.ps1 fast
./marge_simpson/scripts/verify.ps1 fast -SkipIfNoTests

# macOS/Linux  
./marge_simpson/scripts/verify.sh fast
./marge_simpson/scripts/verify.sh fast --skip-if-no-tests
```

### Work Order
1. Existing P0/P1 in tasklist.md
2. New items from user message
3. Remaining items (P0 → P1 → P2)

### Work Types (Labels)
- `bug` — something broken
- `feature` — new capability
- `improvement` — enhance existing
- `refactor` — cleanup, no behavior change

