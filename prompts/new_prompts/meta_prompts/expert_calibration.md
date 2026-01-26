# Expert Calibration — Tune Expert Personas

> **Mode:** 🟡 STANDARD — Analysis with recommendations  
> **Time:** ~25-35 minutes  
> **Best for:** Expert personas giving bad advice, need updates for new domains

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Evaluate and calibrate expert personas.

---

## Expert Loading (Meta)

To calibrate experts, we need to understand them:
- Read ./system/experts/_index.md first
- Then read each expert file being calibrated

---

## Calibration Scope

### What to Calibrate

- [ ] **All experts** in ./system/experts/
- [ ] **Specific expert:** [filename]
- [ ] **New domain needed:** [describe domain]

---

## Calibration Protocol

### Phase 1: Expert Inventory

List all experts and their:
- Title and experience
- Knowledge domains
- Behavioral patterns
- Role boundaries

### Phase 2: Effectiveness Assessment

For each expert, assess:

| Criterion | Check |
|-----------|-------|
| **Relevance** | Is the expertise still current? |
| **Coverage** | Does it cover the domain fully? |
| **Boundaries** | Are limits clear and appropriate? |
| **Conflicts** | Does it conflict with other experts? |
| **Usefulness** | Is the advice actually helpful? |

### Phase 3: Gap Analysis

| Gap Type | Question |
|----------|----------|
| **Missing expert** | What domains have no expert? |
| **Overlap** | Do experts duplicate coverage? |
| **Outdated** | What knowledge is stale? |
| **Boundaries** | Where do experts overstep? |

### Phase 4: Test Cases

Create scenarios to test experts:

```markdown
**Scenario:** [User situation]
**Expected expert:** [Which expert should be loaded]
**Expected advice:** [What they should recommend]
**Actual result:** [What happened when tested]
**Calibration needed?** Yes/No — [Why]
```

### Phase 5: Recommendations

For issues found, recommend:
- Update expert definition
- Add new expert
- Merge overlapping experts
- Update role boundaries
- Add/remove knowledge domains

---

## Output Format

```markdown
## Expert Calibration — [Date]

### Inventory
| Expert File | Experts Included | Token Est |
|-------------|------------------|-----------|
| architecture.md | 2 | ~800 |
| security.md | 3 | ~1,200 |
| ... | ... | ... |

### Effectiveness Scores

| Expert | Relevance | Coverage | Boundaries | Usefulness | Overall |
|--------|-----------|----------|------------|------------|---------|
| Principal Systems Architect | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | A- |

### Gap Analysis

#### Missing Expertise
| Domain | Need | Suggested Expert |
|--------|------|------------------|
| [Domain] | [Why needed] | [Title + brief def] |

#### Overlapping Coverage
| Experts | Overlap | Resolution |
|---------|---------|------------|
| [A] + [B] | [What overlaps] | [Merge/Clarify] |

#### Outdated Knowledge
| Expert | Outdated Area | Update Needed |
|--------|---------------|---------------|
| [Expert] | [Area] | [What to update] |

### Test Cases

| Scenario | Expected | Actual | Calibration |
|----------|----------|--------|-------------|
| Security code review | security.md → Security Architect | ✅ Correct | None |
| Frontend styling | design.md → Visual Design Lead | ⚠️ Missing guidance | Add CSS framework knowledge |

### Recommendations

#### Immediate (P0/P1)
| ID | Action | Expert | Impact |
|----|--------|--------|--------|
| MS-XXXX | [Action] | [Expert] | [Impact] |

#### Soon (P2)
1. [Action]

### Expert Definition Updates

If updates recommended, provide exact changes:
```markdown
## [Expert Title]
- **Title:** [Updated title]
- **Experience:** [Years]+
- **Knowledge Domains:**
  - [Updated domain 1]
  - [Added domain 2]
- **Behavioral Patterns:**
  - [Updated pattern]
- **Role Boundaries:**
  - [Updated boundary]
```
```

---

## Scoring Guide

| Score | Meaning |
|-------|---------|
| ⭐⭐⭐⭐ | Expert is well-calibrated |
| ⭐⭐⭐ | Minor updates needed |
| ⭐⭐ | Significant updates needed |
| ⭐ | Major overhaul or replacement needed |
```

---

## ✅ Done When

- [ ] All target experts assessed
- [ ] Gaps identified
- [ ] Test cases validated
- [ ] MS-#### created for updates
- [ ] Exact changes specified

---

## Related Prompts

- **Full Marge audit** → [deep_audit.md](deep_audit.md)
- **Update prompts** → [prompt_audit.md](prompt_audit.md)
- **Check consistency** → [consistency_audit.md](consistency_audit.md)
