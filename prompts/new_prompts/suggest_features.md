# Suggest Features — Brainstorm Improvements

> **Mode:** 🟢 LITE (PLANNING) — Ideas only, no implementation  
> **Time:** ~10-15 minutes  
> **Best for:** Brainstorming, roadmap input, exploring possibilities

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** PLANNING — Brainstorm only, no code changes.

---

## Expert Loading (Optional but Recommended)

For better suggestions, load:
- product.md (Feature Expansion Planner)
- architecture.md (feasibility check)

---

## Brainstorm Request

### Focus Area (optional)

(Delete examples, replace with yours, or leave blank for general suggestions)

- "How can we improve the user onboarding?"
- "What's missing from our API?"
- "What would make this project more maintainable?"
- Leave blank for general feature brainstorm

Your focus:
- 

### Constraints (optional)

- Effort limit: [small only | any size]
- Tech constraints: [must use X | avoid Y]
- User type: [focus on X users]

---

## Output Format

```markdown
## Feature Suggestions — [Date]

### High-Value Ideas (Top 3-5)

#### 1. [Feature Name]
- **What:** [1-2 sentence description]
- **Who benefits:** [User type]
- **Value:** [Why it matters]
- **Effort:** Low/Medium/High
- **Quick win?** Yes/No

#### 2. [Feature Name]
...

### Quick Wins (Low Effort, High Impact)
- [Feature]: [One-line description]
- [Feature]: [One-line description]

### Ambitious Ideas (High Effort, High Impact)
- [Feature]: [One-line description] — Why: [reason]

### Not Recommended
- [Idea we considered but don't suggest] — Why: [reason]

### Summary
| Rank | Feature | Effort | Impact |
|------|---------|--------|--------|
| 1 | [Feature] | Low | High |
| 2 | [Feature] | Medium | High |
| 3 | [Feature] | Low | Medium |
```

---

## Important Notes

- These are **suggestions**, not approved work
- Do NOT create MS-#### tracking IDs
- To pursue a suggestion, use [plan_feature.md](plan_feature.md)
```

---

## ✅ Done When

- [ ] 3-8 suggestions generated
- [ ] Prioritized by value
- [ ] Effort estimated
- [ ] Quick wins identified

---

## After Suggesting

If you want to pursue a suggestion:
1. **Plan it:** → [plan_feature.md](plan_feature.md)
2. **Get approval** (if major)
3. **Implement:** → [work.md](work.md)

---

## Related Prompts

- **Plan a suggestion?** → [plan_feature.md](plan_feature.md)
- **Full audit first?** → [audit.md](audit.md)
- **Record the decision?** → [decision_record.md](decision_record.md)
