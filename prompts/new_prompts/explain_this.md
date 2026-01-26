# Explain This — Understand Without Changing

> **Mode:** 🟢 LITE — Read-only explanation, no changes  
> **Time:** ~5-10 minutes  
> **Best for:** Learning code, onboarding team members, understanding before modifying

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** EXPLAIN — Teach me, make no changes.

---

## What I Want to Understand

(Delete examples, replace with yours)

- "How does the authentication flow work?"
- "What does the `processOrder` function do?"
- "Explain the database schema"
- "How do these components communicate?"

---

## Depth Level

Choose one (delete the others):

- **Surface:** High-level overview, concepts only (~2 min read)
- **Working:** Enough to modify safely (~5 min read)  
- **Deep:** Full technical detail with edge cases (~10 min read)

---

## Output Format

```markdown
## [Topic] Explained

### Summary
[2-3 sentence overview]

### How It Works
[Step-by-step explanation with code references]

### Key Files
| File | Role |
|------|------|
| ... | ... |

### Important Details
- [Detail 1]
- [Detail 2]

### Common Gotchas
- ⚠️ [Thing that trips people up]

### Related Areas
- [Other code/concepts this connects to]
```

---

Do NOT:
- Create tracking IDs
- Make any changes
- Suggest fixes (unless explicitly asked)
```

---

## ✅ Done When

- [ ] I understand the topic at my requested depth
- [ ] I know which files are involved
- [ ] I'm aware of any gotchas

---

## Related Prompts

- **Ready to change it?** → [work.md](work.md) or [refactor.md](refactor.md)
- **Found issues while explaining?** → [audit.md](audit.md)
- **Have questions?** → [ask.md](ask.md)
