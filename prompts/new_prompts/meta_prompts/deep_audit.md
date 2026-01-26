# Deep Audit — Comprehensive Marge System Review

> **Mode:** 🔴 DEEP — Multi-phase audit with loop until clean  
> **Time:** ~45-60 minutes  
> **Best for:** Periodic health checks, pre-release, post-major-changes

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** DEEP AUDIT — Loop until Marge is clean (min 2, max 5 passes).

---

## Expert Loading (All Required)

This is comprehensive. Load all relevant experts from ./system/experts/_index.md:
- implementation.md (Implementation Audit Specialist, Technical Debt Analyst)
- documentation.md (Technical Specification Engineer)
- testing.md (Senior QA Engineer)
- architecture.md (Principal Systems Architect)
- product.md (Requirements Clarity Specialist)

---

## Phase 1: Discovery

### Code Quality Scan
- Duplicated logic across files
- Error handling gaps
- Hardcoded values that should be config
- Dead code (unused functions, unreachable paths)
- Inconsistencies between similar components

### Documentation Scan
- README accuracy vs actual behavior
- CLI help text matches implementation
- Inline comments accurate
- Version numbers consistent
- Broken internal links

### User Experience Scan
- Confusing error messages
- Missing input validation
- Edge cases not handled
- Unnecessary complexity
- Friction points for new users

---

## Phase 2: Expert Consultation

After discovery, consult loaded experts:
- Implementation expert: Validate code findings, suggest fixes
- Documentation expert: Assess doc quality, recommend improvements
- Testing expert: Identify coverage gaps, prioritize tests
- Architecture expert: Review structural issues, confirm patterns
- Product expert: Validate UX findings, prioritize by user impact

---

## Phase 3: Categorize & Prioritize

| Priority | Criteria | Action |
|----------|----------|--------|
| **P0-CRITICAL** | Broken core features, security issues, data risks | Fix this pass |
| **P1-HIGH** | Bugs affecting users, reliability issues | Fix this pass |
| **P2-MEDIUM** | Code quality, missing tests, tech debt | Queue for backlog |
| **P3-LOW** | Polish, minor improvements | Document only |
| **FEATURE** | New capabilities that would benefit users | Separate backlog |

---

## Phase 4: Execute Fixes (Loop)

For each P0 and P1 issue:

1. Create MS-#### tracking ID
2. Implement the fix
3. Run verification:
```powershell
./system/scripts/verify.ps1 fast  # Windows
```
```bash
./system/scripts/verify.sh fast   # Unix
```
4. Update ./system/tracking/assessment.md with evidence
5. Mark complete in ./system/tracking/tasklist.md

**Loop Criteria:**
- ✅ Continue if: P0/P1 issues remain unfixed
- 🛑 Stop when: All P0/P1 resolved, P2+ documented
- ⚠️ Emergency stop: After 5 passes, output remaining as P1 for next session

---

## Phase 5: Update Supporting Docs

Before completing, ensure:

### Tracking Docs
- [ ] assessment.md — Audit snapshot, all findings with MS-####, verification evidence
- [ ] tasklist.md — Completed items moved to Done, P2/P3 in Backlog

### Knowledge Docs
- [ ] decisions.md — New decisions recorded with D-#### IDs
- [ ] insights.md — Unexpected findings, lessons learned
- [ ] patterns.md — New patterns discovered

### Release Docs
- [ ] CHANGELOG.md — Changes under [Unreleased] or new version
- [ ] VERSION — Bumped if warranted (patch/minor/major)
- [ ] README.md — Updated if behavior changed

---

## Output Format

```markdown
## Deep Audit — [Date]

### Executive Summary
| Metric | Value |
|--------|-------|
| Scope | Full Marge system |
| Passes | X of 5 max |
| P0 Found/Fixed | X/X |
| P1 Found/Fixed | X/X |
| P2 Backlogged | X |
| P3 Documented | X |

### System Health: 🟢/🟡/🔴

### Expert Consultations
| Expert | Key Finding | Recommendation |
|--------|-------------|----------------|
| Implementation | [Finding] | [Action] |
| Documentation | [Finding] | [Action] |
| Testing | [Finding] | [Action] |

### Fixes Applied

| ID | Issue | Fix | Evidence |
|----|-------|-----|----------|
| MS-XXXX | [Issue] | [Fix] | ✅ verify.ps1 |

### Backlog Created (P2)

| ID | Issue | Priority |
|----|-------|----------|
| MS-XXXY | [Issue] | P2 |

### Feature Suggestions

| Suggestion | User Benefit | Complexity |
|------------|--------------|------------|
| [Feature] | [Benefit] | Low/Med/High |

### Documentation Updates
- [x] assessment.md
- [x] tasklist.md
- [x] CHANGELOG.md (if fixes applied)
- [ ] VERSION (if warranted)
- [ ] knowledge/*.md (if learnings)

### Verification Evidence
```
[Raw output from verify script]
```
```

---

## Anti-Patterns

- ❌ Claiming "clean" without running verify
- ❌ Fixing P2 before all P0/P1 done
- ❌ Skipping expert consultation
- ❌ Forgetting to update CHANGELOG
- ❌ Infinite loops (respect max 5)
```

---

## ✅ Done When

- [ ] All P0/P1 issues fixed and verified
- [ ] P2/P3 documented in backlog
- [ ] All tracking docs updated
- [ ] CHANGELOG reflects changes
- [ ] Verification evidence provided

---

## Related Prompts

- **Quick consistency check** → [consistency_audit.md](consistency_audit.md)
- **Prompt-specific audit** → [prompt_audit.md](prompt_audit.md)
- **Prepare for release** → [release.md](release.md)
