# AGENTS.md — Assistant Operating Rules

**Priority:** correctness > safety > minimal diffs > speed

**Scope:** This folder is tooling, not the target. Audit the workspace/repo OUTSIDE this folder. Track findings in `./system/tracking/`. Never create files from this folder outside it.

---

## Task Complexity

| Task | Mode |
|------|------|
| Typo, rename, comment, format, spelling | **Lite** → Read, fix, list files. No ID tracking. |
| Feature, refactor, audit, multi-file, architecture | **Full** → Follow workflows below. |

---

## Core Rules

1. **Read first** — Open files before claiming
2. **Search before implementing** — Don't assume missing
3. **Root cause fixes** — No band-aids
4. **Minimal changes** — Fewest files/lines
5. **Capture why** — Document reasoning
6. **No secrets** — Use env vars
7. **State uncertainty** — What you checked, know, don't know

**Major changes** → Stop, get approval with plan + risks.

---

## Subagents

**Status:** `ENABLED` _(say "no subagents" to disable)_

Use for: research, audits, multi-file edits, parallel implementation, multiple bugs.
Direct tools OK for: single file, simple edit, terminal commands.

**Default to subagents when in doubt.**

---

## Tracking

| File | Purpose |
|------|---------|
| `./system/tracking/assessment.md` | Findings + evidence |
| `./system/tracking/tasklist.md` | Work queue |

```
IMPLEMENT → VERIFY → RECORD → COMPLETE
```

Verify: `./system/scripts/verify.ps1 fast` (Win) or `./system/scripts/verify.sh fast` (Unix)

**Never claim "passed" without raw output.**

---

## Routing

| Intent | Action |
|--------|--------|
| Question | Answer directly |
| Work | Read `./system/workflows/work.md`, create MS-#### |
| Audit | Read `./system/workflows/audit.md` |
| Planning | Read `./system/workflows/planning.md` — NO code |
| Loop | Read `./system/workflows/loop.md` |

Mixed intent: Answer questions inline, then process work items (each gets MS-####).

---

## Response Format

Output: IDs touched, files modified, verification evidence, knowledge captured.
Full format: `./system/workflows/work.md`

---

## Token Estimate

End every response: `📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`

---

## Resources

| Need | Load |
|------|------|
| Decisions | `./system/knowledge/_index.md` |
| Experts | `./system/experts/_index.md` |
| Workflows | `./system/workflows/_index.md` |
