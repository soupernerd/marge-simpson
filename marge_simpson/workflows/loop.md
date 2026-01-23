# Loop Workflow

> Iterative validation until work is complete.

## When to Use

User's prompt contains phrases like:
- "loop until clean"
- "iterate until done"
- "keep going until no issues"
- "repeat until perfect"

---

## Loop Flow

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

---

## Loop Validation by Work Type

| Work Type | Loop Until... |
|-----------|---------------|
| **Feature** | Fully implemented, edge cases handled, tests pass |
| **Bug/Issue** | Root cause fixed, no regressions, verification passes |
| **Instruction** | All instructions executed correctly |
| **Audit** | Zero new findings on full re-scan |
| **Confirmation** | Specific item verified as resolved |
| **Question** | ⛔ NO LOOP — answer once |
| **Planning** | ⛔ NO LOOP — proposals only |

---

## When NOT to Loop

Skip loop even if triggered:
- Pure questions (curiosity, "how", "why")
- Planning mode prompts
- Already-answered items

---

## Min/Max Iteration Counts

Users can specify bounds:

| Phrase | Behavior |
|--------|----------|
| `min 3` | At least 3 passes |
| `max 10` | Stop after 10 passes |
| `min 2 max 8` | Run 2-8 passes |
| `exactly 5` | Run exactly 5 passes |

**Default max:** 5 passes (ask user if more needed)

---

## Loop Rules

- Validate the **specific work requested**, not generic scanning
- Keep a short "Pass N" log
- Continue until **fully complete with zero remaining gaps**
