# Wrap Up — End Session, Capture Learnings

> **Mode:** 🟢 LITE — Documentation, no new work  
> **Time:** ~5-10 minutes  
> **Best for:** End of work session, before context is lost

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** WRAP UP — Capture learnings, update docs, prepare for next session.

---

## Wrap Up Protocol

### Step 1: Status Check

Review what happened this session:
- What work items were completed? (MS-####)
- What's still in progress?
- What was discovered but not addressed?

### Step 2: Knowledge Capture

Did we learn anything worth recording?

**Decisions made:** (Add to ./system/knowledge/decisions.md)
- D-[NNN]: [Decision summary]

**Patterns discovered:** (Add to ./system/knowledge/patterns.md)
- P-[NNN]: [Pattern summary]

**Insights gained:** (Add to ./system/knowledge/insights.md)
- I-[NNN]: [Insight summary]

**Preferences noted:** (Add to ./system/knowledge/preferences.md)
- PR-[NNN]: [Preference summary]

### Step 3: Update Tracking

Ensure tracking docs reflect reality:
- `./system/tracking/tasklist.md` — Mark completed items, update statuses
- `./system/tracking/assessment.md` — Add any new findings

### Step 4: Note for Next Session

What should the next session start with?
- Priority items
- Blockers to resolve
- Questions to answer

---

## Output Format

```markdown
## Session Wrap Up — [Date]

### Completed This Session
| ID | Description | Status |
|----|-------------|--------|
| MS-XXXX | [Description] | ✅ Done |
| MS-XXXY | [Description] | ✅ Done |

### Still In Progress
| ID | Description | Status |
|----|-------------|--------|
| MS-XXXZ | [Description] | 🔄 In Progress |

### Knowledge Captured
- **Decisions:** [D-NNN if any]
- **Patterns:** [P-NNN if any]
- **Insights:** [I-NNN if any]

### Files Updated
- [x] tasklist.md
- [x] assessment.md
- [ ] decisions.md (if applicable)
- [ ] CHANGELOG.md (if applicable)

### Next Session Should
1. Continue: [MS-XXXX] — [context]
2. Address: [item] — [why]
3. Consider: [item] — [why]

### Notes
[Any other context that would be useful]
```

---

## When to Skip

Skip wrap-up if:
- Session was just questions (no work done)
- No learnings worth capturing
- Will continue immediately (same context)
```

---

## ✅ Done When

- [ ] Work status captured
- [ ] Learnings documented
- [ ] Tracking docs current
- [ ] Next session prepared

---

## Related Prompts

- **Start next session** → [resume.md](resume.md)
- **Record a decision** → [decision_record.md](decision_record.md)
