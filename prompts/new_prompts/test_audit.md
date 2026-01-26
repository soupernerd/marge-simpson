# Test Audit — Coverage Analysis

> **Mode:** 🟡 STANDARD — Analysis with recommendations  
> **Time:** ~15-25 minutes  
> **Best for:** Understanding test coverage, identifying gaps, prioritizing test work

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Analyze test coverage, recommend improvements.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- testing.md (Senior QA Engineer, Test Automation Architect)
- implementation.md (for code understanding)

---

## Test Audit Scope

### What to Analyze

(Choose and customize)

- [ ] **Full codebase** — All testable code
- [ ] **Specific area:** [folder or component]
- [ ] **Critical paths only:** [list business-critical flows]

### Test Framework Info (if known)

- Framework: [jest | pytest | mocha | etc.]
- Test location: [__tests__ | test/ | *.test.* | etc.]
- Run command: [npm test | pytest | etc.]

---

## Audit Protocol

### Phase 1: Inventory

Map what exists:
- Test files and their targets
- Test types (unit, integration, e2e)
- Mock/stub patterns in use

### Phase 2: Coverage Analysis

For each area of code:

| Area | Has Tests? | Coverage Level | Critical? |
|------|------------|----------------|-----------|
| Auth | ✅ Yes | 🟡 Partial | 🔴 Yes |
| API | ❌ No | 🔴 None | 🔴 Yes |
| Utils | ✅ Yes | 🟢 Good | 🟡 Medium |

Coverage levels:
- 🟢 Good: Core paths + edge cases covered
- 🟡 Partial: Happy path only
- 🔴 None: No tests

### Phase 3: Gap Analysis

Identify:
- Untested critical paths
- Missing edge case coverage
- Untested error scenarios
- Integration points without tests

### Phase 4: Prioritize

Rank test additions by:
1. Risk (what breaks if this fails?)
2. Complexity (how hard to test?)
3. Frequency (how often is this code path hit?)

---

## Output Format

```markdown
## Test Audit: [Scope] — [Date]

### Summary
| Metric | Value |
|--------|-------|
| Total test files | X |
| Test framework | [name] |
| Estimated coverage | X% |
| Critical gaps | X |

### Coverage by Area

| Area | Files | Tests | Coverage | Priority |
|------|-------|-------|----------|----------|
| [area] | X | X | 🟢/🟡/🔴 | P0/P1/P2 |

### Critical Gaps (P0/P1) — Add Tests Here First

| ID | Area | What's Missing | Risk if Untested |
|----|------|----------------|------------------|
| MS-XXXX | Auth | Login failure paths | Security bypass |
| MS-XXXY | API | Error handling | Silent failures |

### Recommended Test Additions

Priority order:
1. **[Area]:** Add [specific test] — Why: [reason]
2. **[Area]:** Add [specific test] — Why: [reason]
3. ...

### Quick Wins (easy to add, high value)
- [Test that's simple but impactful]

### Test Quality Observations
- ✅ Good: [positive finding]
- ⚠️ Concern: [issue with existing tests]

### Next Steps
1. [Prioritized action]
2. [Prioritized action]
```

---

## Optional: Generate Test Skeletons

If you want test outlines generated:

```
Also generate test skeletons (describe/it blocks without implementation) for the top 3 gaps.
```
```

---

## ✅ Done When

- [ ] Test inventory complete
- [ ] Coverage gaps identified
- [ ] Gaps prioritized by risk
- [ ] MS-#### created for critical gaps
- [ ] Recommendations provided

---

## Related Prompts

- **Write the tests?** → [work.md](work.md)
- **Full codebase audit?** → [audit.md](audit.md)
- **Performance testing?** → [performance_audit.md](performance_audit.md)
