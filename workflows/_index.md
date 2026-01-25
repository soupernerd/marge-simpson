# Workflows Index

> Route to the right workflow based on intent. Read only what you need.

## Path Resolution

All paths in this folder are relative to this folder:
- `./tracking/` → tracking files
- `./workflows/` → workflow files  
- `./experts/` → domain expertise
- `./knowledge/` → decisions and patterns

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
    │   └─ Read ./workflows/planning.md
    │
    ├─ Wants something done (fix/add/change)?
    │   ├─ Read ./workflows/work.md
    │   └─ If "loop until clean" → Also read ./workflows/loop.md
    │
    ├─ Wants codebase audit/review?
    │   └─ Read ./workflows/audit.md (discovery)
    │   └─ Then ./workflows/work.md (execution)
    │
    └─ Task complete / session ending?
        └─ Read ./workflows/session_end.md
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
