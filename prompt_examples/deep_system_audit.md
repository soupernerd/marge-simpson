# Deep System Audit Prompt

> **Purpose:** Comprehensive system-wide audit for continuous improvement.  
> **Mode:** AUDIT + LOOP + SUBAGENTS + EXPERT CONSULTATION  
> **When to use:** Periodic health checks, pre-release reviews, after major changes.

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in this folder and follow it.

## DEEP SYSTEM AUDIT — Loop until clean (min 2, max 5)

### Phase 1: Discovery (Use Subagents)

**Spawn subagents for parallel research:**

1. **Code Quality Subagent:** Search for:
   - Duplicated logic that should be consolidated
   - Error handling gaps (missing try/catch, unhandled promises)
   - Hardcoded values that should be configurable
   - Dead code or unused exports
   - Inconsistencies between similar components

2. **Documentation Subagent:** Verify:
   - README accuracy vs actual behavior
   - CLI help text matches implementation
   - Inline comments match code behavior
   - Version numbers consistent across files
   - Broken internal links

3. **User Experience Subagent:** Identify:
   - Confusing error messages
   - Missing input validation
   - Edge cases with poor UX
   - Features that could be simplified
   - Common user workflows that are harder than necessary

### Phase 2: Expert Consultation

After subagent research, load relevant experts from `experts/_index.md`:
- Found security issues? → Load `security.md`
- Found test gaps? → Load `testing.md`
- Found architecture concerns? → Load `architecture.md`
- Found UX issues? → Load `design.md`
- Found implementation debt? → Load `implementation.md`

Have experts review findings and refine recommendations.

### Phase 3: Categorize & Prioritize

Group findings into:

| Priority | Criteria | Action |
|----------|----------|--------|
| **P0-CRITICAL** | Security, data loss, broken core features | Fix immediately |
| **P1-HIGH** | Bugs affecting users, reliability issues | Fix this session |
| **P2-MEDIUM** | Code quality, missing tests, tech debt | Queue for backlog |
| **P3-LOW** | Nice-to-haves, polish, minor improvements | Document only |
| **FEATURE** | New capabilities that would benefit users | Add to feature backlog |

### Phase 4: Execute Fixes (Loop)

For each P0 and P1 issue:
1. Create MS-#### tracking ID
2. Implement the fix
3. Run `verify.ps1 fast` (or `verify.sh fast`)
4. Update assessment.md with verification evidence
5. Mark complete in tasklist.md

**Loop criteria:**
- Continue if: P0/P1 issues remain unfixed
- Stop when: All P0/P1 resolved, P2+ documented

### Phase 5: Update Supporting Docs

Before completing, ensure:

1. **assessment.md** — Contains:
   - Audit snapshot (date, scope, status)
   - All findings with MS-#### IDs
   - Root cause analysis for each fix
   - Verification evidence

2. **tasklist.md** — Contains:
   - Completed items moved to Done section
   - P2/P3 items in Backlog with clear DoD
   - Feature suggestions in separate section

3. **knowledge/decisions.md** — Record:
   - Any new architectural decisions made
   - Pattern choices and rationale
   - Trade-offs accepted

4. **knowledge/insights.md** — Capture:
   - Unexpected findings
   - Patterns discovered
   - Lessons learned

5. **CHANGELOG.md** — If fixes were applied:
   - Add entry under [Unreleased] or bump version
   - List changes by category (Fixed, Changed, Added)

6. **VERSION** — Bump if warranted:
   - Patch: Bug fixes only
   - Minor: New features or significant improvements
   - Major: Breaking changes

### Output Format

```markdown
## Deep System Audit — [Date]

### Executive Summary
- **Scope:** [What was audited]
- **Duration:** [Passes taken]
- **Critical Issues Found:** X
- **Issues Fixed This Session:** Y
- **Items Added to Backlog:** Z

### Subagent Findings

| Subagent | Findings | Priority Breakdown |
|----------|----------|-------------------|
| Code Quality | X items | P0: _, P1: _, P2: _ |
| Documentation | X items | P0: _, P1: _, P2: _ |
| User Experience | X items | P0: _, P1: _, P2: _ |

### Expert Consultations
- [Expert]: [Key insight or recommendation]

### Fixes Applied

| ID | Issue | Fix | Verification |
|----|-------|-----|--------------|
| MS-XXXX | Brief description | What was done | `verify.ps1 fast` ✅ |

### Backlog Items Created

| ID | Priority | Summary | DoD |
|----|----------|---------|-----|
| MS-XXXX | P2 | Description | Acceptance criteria |

### Feature Suggestions

| Suggestion | User Benefit | Complexity |
|------------|--------------|------------|
| Feature idea | Why users want it | Low/Med/High |

### Documentation Updates
- [x] assessment.md updated
- [x] tasklist.md updated
- [x] CHANGELOG.md updated (if fixes applied)
- [x] README.md's updated (if warranted. keep existing data and structure)
- [x] VERSION bumped (if warranted)
- [x] knowledge/*.md updated (if decisions made)

### Verification Evidence
[Raw output from verify.ps1/verify.sh]
```

📊 Token estimate required at end of response.
```

---

## Usage Variations

### Quick Health Check
```
QUICK AUDIT — Use subagents to scan for P0/P1 issues only. 
Skip documentation updates. Report findings, don't fix.
```

### Pre-Release Audit
```
PRE-RELEASE AUDIT — Loop until clean (min 3).
Focus on: breaking changes, version consistency, CHANGELOG accuracy.
Bump VERSION appropriately. Update all docs.
```

### Security-Focused Audit
```
SECURITY AUDIT — Load experts/security.md first.
Use subagents to find: auth issues, input validation gaps, 
secrets in code, dependency vulnerabilities.
P0 = any security issue. Loop until all security issues resolved.
```

### Documentation Audit
```
DOCUMENTATION AUDIT — Load experts/documentation.md.
Verify: README, CLI help, inline comments, API docs.
Fix inconsistencies. Update version references.
No code logic changes unless fixing doc generation.
```

---

## Tips for Best Results

1. **Fresh context:** Start a new chat session for deep audits
2. **Patience:** Min 2 loops ensures thoroughness
3. **Trust subagents:** They handle the breadth; you review the findings
4. **Verify always:** Never claim "fixed" without test output
5. **Document everything:** Future audits benefit from prior context

## Loop

Once you are done auditing:
1. Fix all issues found, in the order you decide. Do not ask emd user or dev any questions
2. For conflicts use your best judgement. Always put end user UX as the priority even if it means the fix is a bit harder. Dont assume the siple fix is always the best fix
3. Make sure all id'sand issues have been fixed, then delete .meta_marge folder and recreate a meta marge.
4. run this entire prompt again, for a total of 20 times. we are looping and we will be auditing, fixing, deleting meta marge, recreating meta marge, auditing, fixing etc 20 times in total.
5. During all of the time looping, do not ask questions of the dev. use best jusgemdn as described above, usigin reasoning stated above.