# Audit — System-Wide Review

> **Mode:** 🟡 STANDARD — Discovery and tracking  
> **Time:** ~20-30 minutes  
> **Best for:** Periodic health checks, pre-release reviews, understanding codebase issues

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Read-only analysis, then tracked work items.

---

## Expert Loading (Required)

Load based on audit focus from ./system/experts/_index.md:
- General audit → implementation.md + testing.md
- Security focus → security.md
- Architecture review → architecture.md
- All areas → Load multiple as needed

---

## Audit Scope

### What to Audit

(Choose and customize, delete unused)

- [ ] **Full system** — Everything in the codebase
- [ ] **Specific area:** [folder or component name]
- [ ] **Specific concern:** [security | performance | tests | docs]

### Exclusions (optional)

- Ignore: `node_modules/`, `vendor/`, `.git/`
- Ignore: [your exclusions]

---

## Audit Protocol

### Phase 1: Understand

Before finding issues, understand the system:
- Project structure and entry points
- Architecture patterns in use
- Existing conventions and decisions (check ./system/knowledge/decisions.md)

### Phase 2: Scan

Identify issues by category:

| Priority | Criteria | Examples |
|----------|----------|----------|
| **P0 Critical** | Security, data loss, broken core | SQL injection, auth bypass, data corruption |
| **P1 High** | Bugs affecting users, reliability | Crashes, wrong results, bad UX |
| **P2 Medium** | Code quality, tech debt | Duplication, poor naming, missing tests |
| **P3 Low** | Polish, nice-to-haves | Comments, minor style issues |

### Phase 3: Document

For each finding:
- Root cause (not just symptom)
- Impact assessment
- Suggested fix approach

### Phase 4: Track

Create MS-#### IDs for P0, P1, and P2 items:
- Add to ./system/tracking/assessment.md
- Add to ./system/tracking/tasklist.md
- P3 items: Document but don't track

---

## Output Format

```markdown
## Audit: [Scope] — [Date]

### Summary
| Metric | Count |
|--------|-------|
| P0 Critical | X |
| P1 High | X |
| P2 Medium | X |
| P3 Low | X |
| **Total** | X |

### System Health: 🟢/🟡/🔴

### Critical Issues (P0) — Fix Immediately
| ID | Finding | Impact | Fix |
|----|---------|--------|-----|
| MS-XXXX | [Issue] | [Impact] | [Approach] |

### High Priority (P1) — Fix Soon
| ID | Finding | Impact | Fix |
|----|---------|--------|-----|
| ... | ... | ... | ... |

### Medium Priority (P2) — Backlog
| ID | Finding | Impact | Fix |
|----|---------|--------|-----|
| ... | ... | ... | ... |

### Low Priority (P3) — Noted
- [Item without MS-#### ID]

### Good Practices Found ✅
- [Positive observations]

### Recommendations
1. [Prioritized next steps]
```

---

## After Audit

- [ ] assessment.md updated with findings
- [ ] tasklist.md updated with work items
- [ ] Consider: Start fixing P0 items now?
```

---

## ✅ Done When

- [ ] Scope fully reviewed
- [ ] Issues categorized by priority
- [ ] MS-#### IDs created for P0-P2
- [ ] Tracking docs updated
- [ ] Recommendations provided

---

## Related Prompts

- **Fix issues found?** → [work.md](work.md)
- **Specific test gaps?** → [test_audit.md](test_audit.md)
- **Dependency concerns?** → [dependency_audit.md](dependency_audit.md)
- **Performance issues?** → [performance_audit.md](performance_audit.md)
