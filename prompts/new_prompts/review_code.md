# Review Code — Expert Code Review

> **Mode:** 🟡 STANDARD — Analysis with optional tracking  
> **Time:** ~10-20 minutes  
> **Best for:** PR reviews, pre-merge checks, quality assessment

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** REVIEW — Analyze code quality, suggest improvements.

---

## Expert Loading (Required)

Based on the code type, I'll load relevant experts:
- Code quality → implementation.md
- Security concerns → security.md  
- Test coverage → testing.md
- Architecture → architecture.md

---

## What to Review

(Choose one approach, delete the others)

### Option A: Specific Files
Review these files:
- `path/to/file1.ts`
- `path/to/file2.ts`

### Option B: Recent Changes
Review changes in:
- [ ] Staged files (git diff --staged)
- [ ] Unstaged files (git diff)
- [ ] Last N commits

### Option C: Component/Feature
Review all code related to:
- "[Feature name or component]"

---

## Review Focus

Check all that apply (delete unchecked):

- [x] **Correctness:** Logic errors, edge cases, bugs
- [x] **Security:** Vulnerabilities, unsafe patterns, secrets
- [x] **Performance:** Bottlenecks, unnecessary operations
- [x] **Maintainability:** Clarity, naming, complexity
- [x] **Testing:** Coverage gaps, test quality
- [ ] **Style:** Formatting, conventions (usually handled by linters)

---

## Output Format

```markdown
## Code Review: [Files/Feature]

### Summary
| Metric | Value |
|--------|-------|
| Files Reviewed | X |
| Issues Found | X |
| Critical | X |
| Suggestions | X |

### Critical Issues (fix before merge)
| File:Line | Issue | Fix |
|-----------|-------|-----|
| `file.ts:42` | SQL injection risk | Use parameterized query |

### Improvements (recommended)
| File:Line | Issue | Suggestion |
|-----------|-------|------------|
| ... | ... | ... |

### Good Practices Noted ✅
- [Positive finding]

### Test Coverage
- Covered: [what]
- Missing: [what]

### Recommendation
- [ ] ✅ Approve
- [ ] ⚠️ Approve with comments
- [ ] ❌ Request changes (critical issues)
```

---

## Tracking (Optional)

If critical issues found:
- Create MS-#### for each in ./system/tracking/assessment.md
- Add to ./system/tracking/tasklist.md

If no critical issues:
- No tracking needed for clean reviews
```

---

## ✅ Done When

- [ ] All requested files/changes reviewed
- [ ] Issues categorized by severity
- [ ] Actionable feedback provided
- [ ] Clear recommendation given

---

## Related Prompts

- **Issues found?** → [work.md](work.md) to fix them
- **Need full system review?** → [audit.md](audit.md)
- **Security concerns?** → [dependency_audit.md](dependency_audit.md)
