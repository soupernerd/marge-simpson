# Workflows Index

> Route to the right workflow based on intent. Read only what you need.

## Scope Inference

When both `meta_marge/` and `marge_simpson/` exist, paths can be ambiguous.

### Rule: Ask When Ambiguous

If the user references a shared path (e.g., "fix prompt_examples/", "update README.md"):

> "I noticed you have both `meta_marge/` and `marge_simpson/`. Which folder should I apply this to?
> - `marge_simpson/` (source of truth)
> - `meta_marge/` (working copy for meta-development)"

### When NOT Ambiguous

| Signal | Target |
|--------|--------|
| User explicitly names folder | Use that folder |
| Only `marge_simpson/` exists | User's project (repo root) |
| Path only exists in one folder | Use that folder |

### Tracking Always Follows AGENTS.md

Whichever AGENTS.md you read determines where IDs go:
- Read `meta_marge/AGENTS.md` → IDs in `meta_marge/tasklist.md`
- Read `marge_simpson/AGENTS.md` → IDs in `marge_simpson/tasklist.md`

## Quick Reference

| Intent | Signal | Workflow File | Creates ID? |
|--------|--------|---------------|-------------|
| **Session Start** | New conversation, first message | [session_start.md](session_start.md) | No |
| **Question** | Curiosity, "how", "why", "what" | None (answer directly) | No |
| **Work** | Fix, add, change, build | [work.md](work.md) | Yes (or continue existing) |
| **Audit** | "audit", "review codebase" | [audit.md](audit.md) → then work.md | Yes (generates multiple) |
| **Planning** | "PLANNING ONLY", "plan only", "no code changes" | [planning.md](planning.md) | Yes (findings become tasks) |
| **Loop** | "loop until clean", "iterate until done" | [loop.md](loop.md) | Depends on work type |
| **Session End** | Task complete, goodbye, natural end | [session_end.md](session_end.md) | No |

## Decision Tree

```
User message received
    │
    ├─ Just asking a question? → Answer directly, no ID needed
    │
    ├─ Wants something done (fix/add/change)?
    │   └─ Read workflows/work.md
    │
    ├─ Wants codebase audit/review?
    │   └─ Read workflows/audit.md (discovery)
    │   └─ Then workflows/work.md (execution)
    │
    └─ Task complete / session ending?
        └─ Read workflows/session_end.md
```

## Token Costs

| Scenario | Files to Read | Tokens |
|----------|---------------|--------|
| Question only | AGENTS.md only | ~1,500 |
| Single work item | AGENTS.md + work.md | ~2,500 |
| Audit | AGENTS.md + audit.md + work.md | ~3,000 |
| Session end | session_end.md | ~500 |
