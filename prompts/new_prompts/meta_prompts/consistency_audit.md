# Consistency Audit — Ensure Standards Across Prompts

> **Mode:** 🟡 STANDARD — Analysis with normalization  
> **Time:** ~15-25 minutes  
> **Best for:** After adding prompts, standardization sweeps

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Check and enforce consistency across all prompts.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- documentation.md (Technical Specification Engineer)
- implementation.md (Truth Sync Coordinator)

---

## Consistency Standards

### Required Elements (Every Prompt Must Have)

| Element | Standard |
|---------|----------|
| **Title** | `# [Name] — [Brief Description]` |
| **Mode badge** | `> **Mode:** 🟢/🟡/🔴 [TYPE] — [consequence]` |
| **Time estimate** | `> **Time:** ~X-Y minutes` |
| **Best for** | `> **Best for:** [use cases]` |
| **Expert loading** | Section with expert references |
| **Output format** | Clear template in code block |
| **Done-when** | Checklist of success criteria |
| **Related prompts** | Links to next steps |

### Terminology Standards

| Concept | Use This | Not This |
|---------|----------|----------|
| Work tracking | MS-#### | MS-XXXX, issue-123 |
| Decision tracking | D-#### | decision-X, ADR-X |
| Insight tracking | I-#### | insight-X |
| Pattern tracking | P-#### | pattern-X |
| Preference tracking | PR-#### | pref-X |
| Verification | `verify.ps1 fast` / `verify.sh fast` | test, check, validate |
| Priority | P0, P1, P2, P3 | Critical, High, Med, Low |
| Mode | AUDIT, WORK, PLANNING, LITE | other terms |

### Structure Standards

```markdown
# [Title]

> **Mode:** ...
> **Time:** ...
> **Best for:** ...

---

## The Prompt

Copy everything below the line:

---

[Prompt content in code block]

---

## ✅ Done When

- [ ] ...

---

## Related Prompts

- **[Action]** → [prompt.md](prompt.md)
```

---

## Audit Protocol

### Phase 1: Element Check

For each prompt, verify all required elements:

| Prompt | Title | Mode | Time | Best | Expert | Output | Done | Related |
|--------|-------|------|------|------|--------|--------|------|---------|
| [name] | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |

### Phase 2: Terminology Check

Grep for non-standard terms:
- `MS-XXXX` → Should be `MS-####`
- `Critical/High/Medium/Low` → Should be `P0/P1/P2/P3`
- Inconsistent verification commands

### Phase 3: Cross-References

Check that:
- All `[Related prompts]` links work
- Expert file references are valid
- Workflow references exist

### Phase 4: Normalize

For each violation:
- Document the issue
- Provide the fix
- Apply if approved

---

## Output Format

```markdown
## Consistency Audit — [Date]

### Summary
| Metric | Value |
|--------|-------|
| Prompts checked | X |
| Fully compliant | X |
| Need updates | X |
| Total violations | X |

### Compliance Matrix

| Prompt | Elements | Terms | Links | Score |
|--------|----------|-------|-------|-------|
| [name] | 8/8 | ✅ | ✅ | 100% |
| [name] | 6/8 | ⚠️ | ✅ | 75% |

### Violations Found

#### Missing Elements
| Prompt | Missing | Fix |
|--------|---------|-----|
| [name] | Time estimate | Add `> **Time:** ~X min` |

#### Terminology Issues
| Prompt | Found | Should Be | Line |
|--------|-------|-----------|------|
| [name] | "Critical" | "P0" | 42 |

#### Broken Links
| Prompt | Link | Issue |
|--------|------|-------|
| [name] | [link] | File not found |

### Fixes Applied

| ID | Prompt | Fix |
|----|--------|-----|
| MS-XXXX | [name] | [What was fixed] |

### Normalization Diff

If changes made, show before/after:
```diff
- > **Mode:** AUDIT — read-only analysis
+ > **Mode:** 🟡 STANDARD (AUDIT) — read-only analysis
```
```

---

## ✅ Done When

- [ ] All prompts checked
- [ ] Violations documented
- [ ] Fixes applied
- [ ] All links verified working
- [ ] All terminology normalized

---

## Related Prompts

- **Audit prompts deeper** → [prompt_audit.md](prompt_audit.md)
- **Full Marge audit** → [deep_audit.md](deep_audit.md)
- **Update experts** → [expert_calibration.md](expert_calibration.md)
