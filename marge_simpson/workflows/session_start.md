# Session Start Workflow

> Knowledge retrieval at conversation start. Ensures stored context is applied.
> Complements `session_end.md` (write) with read-side behavior.

## When to Run

- **First message** of a new conversation
- **After long gap** in same conversation (context may have shifted)
- **NOT every message** — this is startup, not per-request

---

## Phase 1: Quick Preference Scan

Read `knowledge/_index.md` and scan for **broad preferences** that affect all work:

| Tag | Impact |
|-----|--------|
| `#code-style` | Formatting, naming conventions |
| `#communication` | Response length, detail level |
| `#workflow` | How user likes to work |
| `#tools` | Preferred languages, frameworks |

**If tags exist:** Read the matching entries from `preferences.md`.

**Apply immediately:** These shape how you respond for the entire session.

---

## Phase 2: Active Context Check

Check `_index.md` → **Recent Entries** section for:

| Entry Type | Action |
|------------|--------|
| Active decisions (D-###) | Note constraints for current work |
| Unverified insights (I-###) | Opportunity to verify this session |
| Strong patterns (P-###) | Follow unless user says otherwise |

**Keep in working memory:** Reference these when making decisions.

---

## Phase 3: Project Context (If Known)

If you know what project/repo the user is working on:

1. Search `insights.md` for project-specific entries
2. Check `decisions.md` for prior architectural choices
3. Note any `#project-name` tagged entries

**Goal:** Don't re-ask questions already answered in previous sessions.

---

## Retrieval Triggers (During Work)

Beyond session start, retrieve knowledge when:

| Trigger | Action |
|---------|--------|
| **About to make architectural choice** | Check `decisions.md` for prior decisions on same topic |
| **Choosing between options** | Check `preferences.md` for user's typical choice |
| **Uncertain how user wants something** | Check `patterns.md` for observed behavior |
| **User corrects you** | Check if this contradicts stored knowledge → update if so |

---

## Conflict Handling

If current request conflicts with stored knowledge:

```
⚠️ Note: You previously indicated [PR-003: prefer Rust over Python].
   This request uses Python. Should I:
   1. Proceed with Python (one-time exception)
   2. Use Rust instead
   3. Update your preference (Python is now preferred)
```

**Never silently override stored preferences.**

---

## Output (None Required)

This workflow is **silent** — no output to user unless:
- Conflict detected (show warning above)
- Unverified insight can be confirmed ("Last time I noted X — still accurate?")

The goal is to *apply* knowledge, not announce that you're reading it.
