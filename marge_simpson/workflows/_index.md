# Workflows Index

> Route to the right workflow based on intent. Read only what you need.

## Scope Inference

When both `meta_marge/` and `.marge/` exist, paths can be ambiguous.

### Rule: Ask When Ambiguous

If the user references a shared path (e.g., "fix prompt_examples/", "update README.md"):

> "I noticed you have both `meta_marge/` and `.marge/`. Which folder should I apply this to?
> - `.marge/` (source of truth)
> - `meta_marge/` (working copy for meta-development)"

### When NOT Ambiguous

| Signal | Target |
|--------|--------|
| User explicitly names folder | Use that folder |
| Only `.marge/` exists | User's project (repo root) |
| Path only exists in one folder | Use that folder |

### Tracking Always Follows AGENTS.md

Whichever AGENTS.md you read determines where IDs go:
- Read `meta_marge/AGENTS.md` → IDs in `meta_marge/tasklist.md`
- Read `.marge/AGENTS.md` → IDs in `.marge/tasklist.md`

## Quick Reference

| Intent | Signal | Workflow File | Creates ID? |
|--------|--------|---------------|-------------|
| **Session Start** | New conversation, first message | [session_start.md](session_start.md) | No |
| **Question** | Curiosity, "how", "why", "what" | None (answer directly) | No |
| **Work** | Fix, add, change, build | [work.md](work.md) | Yes (or continue existing) |
| **Audit** | "audit", "review codebase" | [audit.md](audit.md) → then work.md | Yes (generates multiple) |
| **Loop** | "loop until clean", "iterate" | [loop.md](loop.md) (modifier) | Continues existing |
| **Planning** | "PLANNING ONLY", design discussion | [planning.md](planning.md) | No |
| **Session End** | Task complete, goodbye, natural end | [session_end.md](session_end.md) | No |

## Decision Tree

```
User message received
    │
    ├─ Just asking a question? → Answer directly, no ID needed
    │
    ├─ Planning/design discussion? (no code changes)
    │   └─ Read workflows/planning.md
    │
    ├─ Wants something done (fix/add/change)?
    │   ├─ Read workflows/work.md
    │   └─ If "loop until clean" → Also read workflows/loop.md
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
| Work + loop | AGENTS.md + work.md + loop.md | ~3,300 |
| Audit | AGENTS.md + audit.md + work.md | ~3,000 |
| Planning only | AGENTS.md + planning.md | ~2,100 |
| Session end | session_end.md | ~500 |
