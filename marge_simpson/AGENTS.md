# AGENTS.md — Assistant Operating Rules

This folder is a drop-in workflow for running audits and fixing bugs in any codebase.

**Priority order:** correctness > safety > minimal diffs > speed

**CRITICAL RULES:**
1. Marge NEVER creates files outside its own folder. All tracking docs, logs, and artifacts stay within `marge_simpson/`.
2. The `marge_simpson/` folder itself is excluded from audits and issue scans - it is the tooling, not the target.

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
- Cost = (input/1M × $1) + (output/1M × $5) for Claude Opus 4.5
- Cost = (input/1M × $3) + (output/1M × $15) for Claude Sonnet 4.5
- Cost = (input/1M × $5) + (output/1M × $25) for Claude Opus 4.5
- Cost = (input/1M × $1.25) + (output/1M × $10.00) for GPT-5.1-Codex
- Cost = (input/1M × $1.25) + (output/1M × $10.00) for GPT-5.1-Codex-max
- Cost = (input/1M × $1.75) + (output/1M × $14.00) for GPT-5.2
- Cost = (input/1M × $1.75) + (output/1M × $14.00) for GPT-5.2-Codex
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
2. VERIFY → run ./marge_simpson/verify.ps1 fast (or verify.sh)
       ↓
3. RECORD → paste evidence in assessment.md
       ↓
4. COMPLETE → mark done in tasklist.md, move to next
```

**Never claim "tests passed" without raw output or log file path.**

Use `-SkipIfNoTests` / `--skip-if-no-tests` for repos without tests.

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
+========================================================+
|    __  __    _    ____   ____ _____                    |
|   |  \/  |  / \  |  _ \ / ___| ____|                   |
|   | |\/| | / _ \ | |_) | |  _|  _|                     |
|   | |  | |/ ___ \|  _ <| |_| | |___                    |
|   |_|  |_/_/   \_\_| \_\\____|_____|   WORK COMPLETE   |
+========================================================+
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
6. If unsure, stop and ask rather than reading more files.

### Workflows
Read only when needed:
- `workflows/work.md` — unified bug/feature/improvement process
- `workflows/audit.md` — codebase discovery phase
- `workflows/session_end.md` — knowledge capture after work complete

### Experts (Optional)
If `experts/` folder exists:
1. Read `experts/_index.md` first (~400 tokens)
2. Find keywords in the table
3. Read only the relevant expert file(s)

### Knowledge (Optional)
If `knowledge/` folder exists:
1. Read `knowledge/_index.md` first (~500 tokens)
2. Check tags for relevant entries
3. Read only the matching file(s)

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
./marge_simpson/verify.ps1 fast
./marge_simpson/verify.ps1 fast -SkipIfNoTests

# macOS/Linux  
./marge_simpson/verify.sh fast
./marge_simpson/verify.sh fast --skip-if-no-tests
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

