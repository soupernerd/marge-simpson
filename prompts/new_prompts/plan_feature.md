# Plan Feature — Feature Planning (No Code)

> **Mode:** 🟡 STANDARD (PLANNING) — Plan only, no implementation  
> **Time:** ~15-25 minutes  
> **Best for:** New features, major changes, architecture decisions

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** PLANNING — Plan the feature, do not implement.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- product.md (Product Discovery Lead, Requirements Clarity Specialist)
- architecture.md (for technical feasibility)
- design.md (if UI involved)

---

## Feature Description

### Feature Name
- 

### What It Does
(User-facing description, 2-3 sentences)

- 

### Who Benefits
- Primary user: [who]
- Use case: [when would they use this]

### Success Criteria
How we'll know it works:
- [ ] [Measurable outcome]
- [ ] [Measurable outcome]

---

## Planning Protocol

### Phase 1: Requirements Clarification

Answer before planning:
- What's in scope? What's explicitly OUT of scope?
- What's the MVP vs nice-to-have?
- Any constraints? (time, tech, compatibility)

### Phase 2: Technical Discovery

Investigate:
- How does this fit with existing architecture?
- What existing code can be reused?
- What new code is needed?
- Any database changes required?
- External dependencies?

### Phase 3: Risk Assessment

Identify:
- What could go wrong?
- What don't we know yet?
- Dependencies on other work?

### Phase 4: Breakdown

Split into implementable chunks:
- Each chunk = 1 work session or less
- Clear dependencies between chunks
- Testable individually

---

## Output Format

```markdown
## Feature Plan: [Name]

### Overview
| Field | Value |
|-------|-------|
| **Status** | Planning |
| **Priority** | P0/P1/P2 |
| **Effort** | S/M/L |
| **Risk** | Low/Medium/High |

### User Story
As a [user type], I want [capability] so that [benefit].

### Requirements

#### Must Have (MVP)
- [ ] [Requirement]
- [ ] [Requirement]

#### Should Have
- [ ] [Requirement]

#### Won't Have (Out of Scope)
- [Explicitly excluded item]

### Technical Approach

#### Architecture
[How it fits into the system]

#### Components Affected
| Component | Change |
|-----------|--------|
| [Component] | [What changes] |

#### Database Changes
- [If any]

#### API Changes
- [If any]

### Implementation Plan

| Phase | Task | Effort | Depends On |
|-------|------|--------|------------|
| 1 | [Task] | S/M/L | - |
| 2 | [Task] | S/M/L | Phase 1 |
| 3 | [Task] | S/M/L | Phase 2 |

### Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | Low/Med/High | Low/Med/High | [Plan] |

### Open Questions
- [ ] [Question that needs answering]

### Acceptance Criteria
- [ ] [User can do X]
- [ ] [System does Y when Z]
- [ ] [Tests pass]
- [ ] [Docs updated]
```

---

## After Planning

- [ ] Save plan to `./system/tracking/[feature]_plan.md`
- [ ] Get approval if major change
- [ ] When approved, create MS-#### IDs via [work.md](work.md)

---

## Anti-Patterns

- ❌ Starting to code during planning
- ❌ Vague requirements ("make it better")
- ❌ No success criteria
- ❌ Ignoring risks
- ❌ Monolithic plan (break it down!)
```

---

## ✅ Done When

- [ ] Requirements clear and scoped
- [ ] Technical approach defined
- [ ] Work broken into chunks
- [ ] Risks identified
- [ ] Plan documented

---

## Related Prompts

- **Implement the plan?** → [work.md](work.md)
- **Just brainstorm ideas?** → [suggest_features.md](suggest_features.md)
- **Record the decision?** → [decision_record.md](decision_record.md)
