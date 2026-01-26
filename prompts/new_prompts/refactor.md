# Refactor — Safe Refactoring with Impact Analysis

> **Mode:** 🟡 STANDARD — Tracked work with verification  
> **Time:** ~15-30 minutes  
> **Best for:** Code cleanup, architecture improvements, tech debt reduction

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** REFACTOR — Improve structure without changing behavior.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- implementation.md (Senior Implementation Engineer)
- testing.md (for regression prevention)
- architecture.md (if structural changes)

---

## Refactoring Target

### What to Refactor
(Delete examples, replace with yours)

- "Extract the auth logic into a separate service"
- "Convert callbacks to async/await in api/*.js"
- "Consolidate duplicate validation functions"
- "Rename `processData` to something meaningful"

Your refactor:
- 

### Why
(What problem does this solve?)

- 

---

## Refactoring Protocol

### Phase 1: Impact Analysis

Before changing anything, identify:

```markdown
## Impact Analysis

### Files Affected
| File | Change Type | Risk |
|------|-------------|------|
| `file.ts` | Major rewrite | 🔴 High |
| `file2.ts` | Import update | 🟢 Low |

### Dependencies
- What depends on this code?
- What does this code depend on?

### Tests Affected
- Existing tests: [list]
- New tests needed: [list]

### Risk Assessment
- [ ] 🟢 Low: Isolated change, good test coverage
- [ ] 🟡 Medium: Multiple files, some test coverage
- [ ] 🔴 High: Core code, limited tests

### Rollback Plan
- How to revert if issues found
```

### Phase 2: Implement

- Make changes incrementally
- Commit logical chunks
- Preserve existing behavior exactly
- Update imports/references everywhere

### Phase 3: Verify

```powershell
./system/scripts/verify.ps1 fast  # Windows
```
```bash
./system/scripts/verify.sh fast   # Unix
```

Additional checks:
- [ ] All tests still pass
- [ ] No new warnings/errors
- [ ] Behavior unchanged (test same inputs → same outputs)

### Phase 4: Track

- Create MS-#### with type=refactor
- Document what improved and why
- Note any follow-up work

---

## Output Format

```markdown
## Refactor: [Description]

| Field | Value |
|-------|-------|
| **ID** | MS-XXXX |
| **Type** | refactor |
| **Files Changed** | X files |
| **Status** | ✅ VERIFIED |

### Impact Summary
- Risk level: [Low/Medium/High]
- Tests: [X passed, Y updated, Z added]

### What Changed
| Before | After | Reason |
|--------|-------|--------|
| [old pattern] | [new pattern] | [why better] |

### Files Modified
- `file1.ts` - [what changed]
- `file2.ts` - [what changed]

### Verification Evidence
```
[Raw output from verify script]
```

### Follow-up Work
- [ ] Update documentation
- [ ] Add missing tests
- [ ] Consider related refactors
```

---

## Refactoring Golden Rules

✅ **DO:**
- Keep refactors behavior-preserving
- Test before and after
- Make atomic commits
- Document the "why"

❌ **DON'T:**
- Mix refactors with features
- Refactor untested code (add tests first)
- Make "while I'm here" changes
- Skip impact analysis for big changes
```

---

## ✅ Done When

- [ ] Impact analysis complete
- [ ] All changes preserve existing behavior
- [ ] Tests pass
- [ ] MS-#### created and documented

---

## Related Prompts

- **Need tests first?** → [test_audit.md](test_audit.md)
- **Major architecture change?** → [plan_feature.md](plan_feature.md)
- **Found issues during refactor?** → [audit.md](audit.md)
