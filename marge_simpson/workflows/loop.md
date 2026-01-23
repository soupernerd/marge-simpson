# Loop Workflow

> Iterative validation mode for continuous improvement until clean.

## Activation Triggers

When the user's message includes phrases like:
- "loop until clean"
- "iterate until done"
- "keep going until no issues"
- "repeat until perfect"

## Loop Process

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

## Validation by Work Type

| Work Type | Loop Validates Until... |
|-----------|------------------------|
| **Feature** | Fully implemented, all edge cases handled, tests pass |
| **Bug/Issue** | Root cause fixed, no regressions, verification passes |
| **Instruction** | All instructions executed correctly and completely |
| **Audit** | Zero new findings on full re-scan |
| **Confirmation** | The specific item is verified as truly resolved |
| **Question** | ⛔ NO LOOP - answer once, done |
| **Planning** | ⛔ NO LOOP - proposals/brainstorms don't iterate |

## When NOT to Loop

Auto-skip looping even if triggered:
- Pure questions (curiosity, "how", "why", "what does X do")
- Planning mode prompts (contains "PLANNING ONLY" or "no code changes")
- Already-answered items in a mixed prompt

## Mixed Prompts

Loop applies ONLY to work items, not questions:
1. Answer questions once
2. Loop on the actionable work

## Loop Rules

- The loop validates **the specific work requested** (not generic scanning)
- Keep a short "Pass N" log of what was found/improved/completed
- Continue until the work is **fully complete with zero remaining gaps**
- Default maximum: 5 passes (ask user if more needed)

## Min/Max Loop Counts

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

## Examples

| Scenario | Loop Behavior |
|----------|---------------|
| Feature request + loop | Keep refining until feature is complete and tested |
| Bug fix + loop | Keep fixing until bug is fully resolved with no regressions |
| Audit + loop | Keep scanning until zero new issues found |
| Question + loop | Loop ignored, answer provided once |
| Planning + loop | Loop ignored, proposals provided once |

## Pass Log Format

After each pass, record briefly:

```
### Pass N
- What was checked
- What was fixed (if any)
- Remaining issues (if any)
- Status: CONTINUE / COMPLETE
```

## Token Cost

~800 tokens when read
