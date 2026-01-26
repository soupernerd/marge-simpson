# Prompt Audit — Evaluate Prompt Quality & Effectiveness

> **Mode:** 🟡 STANDARD — Analysis with recommendations  
> **Time:** ~20-30 minutes  
> **Best for:** Prompt quality assessment, user experience improvement

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Analyze prompt quality, suggest improvements.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- product.md (Product Discovery Lead, Requirements Clarity Specialist)
- documentation.md (Technical Specification Engineer, Checklist & Process Designer)
- design.md (UX Layout & Information Architect)
- implementation.md (Implementation Audit Specialist)

---

## Prompt Audit Scope

### What to Audit

- [ ] **All prompts** in ./prompts/
- [ ] **Specific prompt:** [name]
- [ ] **New prompts only:** ./prompts/new_prompts/

---

## Audit Protocol

### Phase 1: Specification Quality

For each prompt, assess:

| Criterion | Check |
|-----------|-------|
| **Clarity** | Are instructions unambiguous? |
| **Completeness** | Are all steps defined? |
| **Actionability** | Can AI execute without guessing? |
| **Output** | Is expected output format clear? |
| **Verification** | Is success measurable? |

### Phase 2: UX Quality

| Criterion | Check |
|-----------|-------|
| **Cognitive load** | Is it overwhelming or clear? |
| **Examples** | Are fill-in sections guided? |
| **Mode badge** | Is mode (AUDIT/WORK/etc) clear? |
| **Time estimate** | Do users know how long it takes? |
| **Flow** | Do related prompts connect? |

### Phase 3: Consistency

| Criterion | Check |
|-----------|-------|
| **Structure** | Same sections in same order? |
| **Terminology** | Same terms for same concepts? |
| **Expert loading** | Consistent guidance? |
| **Output format** | Same format patterns? |
| **Done-when** | All have success criteria? |

### Phase 4: Effectiveness

| Criterion | Check |
|-----------|-------|
| **Purpose served** | Does it accomplish its goal? |
| **Edge cases** | Does it handle variations? |
| **Integration** | Does it work with other prompts? |
| **Evolution** | Does it capture learnings? |

---

## Output Format

```markdown
## Prompt Audit — [Date]

### Summary
| Metric | Value |
|--------|-------|
| Prompts audited | X |
| Issues found | X |
| Critical gaps | X |
| Quick fixes | X |

### Quality Scores

| Prompt | Spec | UX | Consistency | Effectiveness | Overall |
|--------|------|-----|-------------|---------------|---------|
| [name] | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | B+ |

### Critical Issues

| ID | Prompt | Issue | Impact | Fix |
|----|--------|-------|--------|-----|
| MS-XXXX | [name] | [Issue] | [Impact] | [Fix] |

### Quick Wins

| Prompt | Fix | Effort |
|--------|-----|--------|
| [name] | [Fix] | 5 min |

### Missing Prompts

| Need | Gap | Suggested Prompt |
|------|-----|------------------|
| [Need] | [What's missing] | [New prompt name] |

### Consistency Violations

| Element | Expected | Found In | Fix |
|---------|----------|----------|-----|
| [Element] | [Pattern] | [Prompt] | [Action] |

### Recommendations

#### Immediate (P0/P1)
1. [Action]

#### Soon (P2)
1. [Action]

#### Backlog (P3)
1. [Action]
```

---

## Scoring Guide

| Score | Meaning |
|-------|---------|
| ⭐⭐⭐⭐ | Excellent — no issues |
| ⭐⭐⭐ | Good — minor issues |
| ⭐⭐ | Adequate — needs work |
| ⭐ | Poor — major issues |
```

---

## ✅ Done When

- [ ] All target prompts assessed
- [ ] Issues categorized and prioritized
- [ ] Quick wins identified
- [ ] MS-#### created for fixes
- [ ] Recommendations provided

---

## Related Prompts

- **Fix prompt issues** → Use regular [work.md](../work.md)
- **Check consistency** → [consistency_audit.md](consistency_audit.md)
- **Full Marge audit** → [deep_audit.md](deep_audit.md)
