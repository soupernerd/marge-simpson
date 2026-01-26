# Resume — Continue Where You Left Off

> **Mode:** 🟢 LITE — Context reload, no changes  
> **Time:** ~3-5 minutes  
> **Best for:** Starting a new session, picking up multi-day work

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** RESUME — Reload context from previous sessions.

---

## Resume Protocol

### Step 1: Load Context

Read and summarize:
- `./system/tracking/tasklist.md` — What's in progress? What's pending?
- `./system/tracking/assessment.md` — Recent findings and status
- `./system/knowledge/decisions.md` — Recent decisions (last 5)
- `./system/knowledge/insights.md` — Recent learnings (last 5)

### Step 2: Identify Priority Work

From tasklist, show:
- 🔴 P0 items (critical, do first)
- 🟡 P1 items (high priority)
- 🟢 P2 items (normal priority)

### Step 3: Suggest Today's Focus

Based on priorities and recent context, recommend:
- What to work on first
- What can wait
- Any blockers to address

---

## Output Format

```markdown
## Session Resume — [Date]

### Work in Progress
| ID | Description | Status | Priority |
|----|-------------|--------|----------|
| MS-XXXX | [Description] | In Progress | P1 |

### Pending Work
| ID | Description | Priority |
|----|-------------|----------|
| MS-XXXY | [Description] | P0 |
| MS-XXXZ | [Description] | P1 |

### Recent Context
- **Last decision:** [D-NNN summary]
- **Last insight:** [I-NNN summary]

### Suggested Focus Today
1. **First:** [What and why]
2. **Then:** [What and why]
3. **If time:** [What and why]

### Blockers (if any)
- [Blocker and suggested resolution]
```

---

Do NOT:
- Make any changes
- Create new tracking IDs
- Start working (that's next step)
```

---

## ✅ Done When

- [ ] Current state understood
- [ ] Priorities clear
- [ ] Ready to start working

---

## After Resuming

- **Ready to work?** → [work.md](work.md) with the suggested focus
- **Need to understand something first?** → [explain_this.md](explain_this.md)
- **Want to audit first?** → [audit.md](audit.md)

---

## Related Prompts

- **Start working** → [work.md](work.md)
- **End session** → [wrap_up.md](wrap_up.md)
