# Decision Record — Capture Architectural Decisions

> **Mode:** 🟡 STANDARD — Document decisions for future reference  
> **Time:** ~10-15 minutes  
> **Best for:** Recording why we chose X over Y, documenting trade-offs

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** DOCUMENT — Record architectural decisions.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- architecture.md (Principal Systems Architect)
- documentation.md (Technical Specification Engineer)

---

## Decision to Record

### Decision Summary
(One sentence: what we decided)

- 

### Context
(What prompted this decision? What problem were we solving?)

- 

### Options Considered
(List alternatives we evaluated)

1. **[Option A]:** [brief description]
2. **[Option B]:** [brief description]
3. **[Option C]:** [brief description]

---

## Decision Record Protocol

### Phase 1: Document the Decision

Fill out the ADR (Architecture Decision Record) template:

```markdown
# ADR-[NNN]: [Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** [YYYY-MM-DD]
**Deciders:** [Who made the decision]

## Context

[What is the issue that we're seeing that motivates this decision?]

## Decision

[What is the change that we're proposing/doing?]

## Options Considered

### Option 1: [Name]
- **Pros:** [list]
- **Cons:** [list]
- **Effort:** [Low/Medium/High]

### Option 2: [Name]
- **Pros:** [list]
- **Cons:** [list]
- **Effort:** [Low/Medium/High]

### Option 3: [Name]
...

## Decision Rationale

[Why did we choose this option?]

## Consequences

### Positive
- [Expected benefit]

### Negative
- [Known tradeoff]

### Risks
- [Potential issue and mitigation]

## Related Decisions
- [Link to related ADRs if any]
```

### Phase 2: Store the Decision

Add to `./system/knowledge/decisions.md`:
```markdown
### D-[NNN] [Date] — [Title]
**Decision:** [One-line summary]
**Rationale:** [Why]
**Trade-offs:** [What we gave up]
**Tags:** #architecture #database #api #security #performance
```

### Phase 3: Update Affected Code (Optional)

If the decision changes existing code:
- Add inline comments explaining "why"
- Update README or ARCHITECTURE docs
- Create MS-#### for implementation

---

## Output Format

```markdown
## Decision Recorded

| Field | Value |
|-------|-------|
| **ID** | D-[NNN] |
| **Title** | [Title] |
| **Status** | Accepted |
| **Date** | [Date] |

### Summary
[One paragraph summary]

### Key Trade-offs
| We Get | We Give Up |
|--------|------------|
| [Benefit] | [Cost] |

### Files Updated
- `./system/knowledge/decisions.md` — Added D-[NNN]
- `[Other files if applicable]`

### Follow-up Actions
- [ ] [If any implementation needed]
```

---

## When to Record Decisions

**Always record:**
- Technology/framework choices
- Architecture patterns chosen
- Data model decisions
- API design choices
- Security approach

**Sometimes record:**
- Library selections (if non-obvious)
- Performance trade-offs
- Scope cuts and why

**Don't record:**
- Obvious choices (standard library usage)
- Temporary decisions that will change
- Personal preferences without trade-offs

---

## ✅ Done When

- [ ] ADR written with all sections
- [ ] Added to decisions.md
- [ ] Trade-offs clearly stated
- [ ] Tags added for searchability

---

## Related Prompts

- **Implement the decision?** → [work.md](work.md)
- **Review architecture?** → [audit.md](audit.md)
- **Plan a feature using this decision?** → [plan_feature.md](plan_feature.md)
