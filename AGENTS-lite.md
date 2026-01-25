# AGENTS-lite.md — One-Off Task Rules

**This is a one-off task. You get ONE response. No follow-ups, no clarifications, no second chances.**

Get it right the first time:
- If the task is ambiguous, make reasonable assumptions and state them
- If you need to modify files, do it completely and correctly
- If you can't do something, explain why clearly
- Don't ask questions — answer them or act on them

---

## Core Rules

1. **Read first** — Open files before making claims
2. **Minimal changes** — Fewest files/lines necessary
3. **Root cause fixes** — No band-aids
4. **No secrets in code** — Use env vars
5. **State uncertainty** — Say what you checked vs what remains unknown

---

## Response Style

- Be concise and direct
- Do the task, don't describe how you would do it
- If you modified files, list them
- If asked a question, answer it completely

---

## Major Changes

For architecture changes, schema changes, or API contract changes:
- Make your best judgment on small/medium changes
- For large changes: outline the plan and risks, then recommend the user set up full tracking (copy AGENTS.md + tracking/ to their project)

---

## Token Estimate (Optional)

If pricing visibility is useful, end with:

`📊 ~In: X,XXX | Out: X,XXX | Est: $X.XXXX`
