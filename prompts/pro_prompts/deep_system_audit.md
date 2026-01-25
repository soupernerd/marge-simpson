# 🔬 Deep System Audit

> **Purpose:** Comprehensive, multi-pass system audit with active remediation  
> **Mode:** `AUDIT` + `LOOP` + `SUBAGENTS` + `EXPERT CONSULTATION`  
> **Duration:** 2-5 passes until clean

---

## 📖 About This Prompt

### When to Use

| Scenario | Fit |
|:---------|:---:|
| Full codebase review | ✅ |
| Pre-release validation | ✅ |
| After major changes | ✅ |
| Quick read-only check | ❌ Use `system_audit.md` |
| Path/workflow validation | ❌ Use `path_integrity_audit.md` |

### Variations

You can modify the prompt by replacing the first line with one of these:

| Variation | Replace First Line With |
|:----------|:------------------------|
| ⚡ Quick Check | `QUICK AUDIT — Subagents scan for P0/P1 only. Skip documentation updates. Report findings, don't fix.` |
| 🚀 Pre-Release | `PRE-RELEASE AUDIT — Loop until clean (min 3). Focus: breaking changes, version consistency. Zero P0/P1 tolerance.` |
| 🔐 Security Focus | `SECURITY AUDIT — Load ./system/experts/security.md first. P0 = ANY security issue. Loop until all security issues = 0.` |
| 📄 Docs Only | `DOCUMENTATION AUDIT — Load ./system/experts/documentation.md. Fix doc inconsistencies only. No code logic changes.` |

### Best Practices

| Practice | Why It Matters |
|:---------|:---------------|
| **Start fresh session** | Deep audits benefit from clean context |
| **Allow minimum 2 loops** | First pass finds issues; second verifies fixes |
| **Trust the process** | Let the AI decide autonomously during loops |

### Related Prompts

- **[system_audit.md](system_audit.md)** — Quick read-only check
- **[path_integrity_audit.md](path_integrity_audit.md)** — Path/workflow validation

---

## ✂️ THE PROMPT — COPY EVERYTHING BELOW THIS LINE

---

Read the AGENTS.md file in this folder and follow it.

## 🔬 DEEP SYSTEM AUDIT — Loop Until Clean

> **Mode:** AUDIT + LOOP — Discover, fix, verify, repeat.  
> **Iterations:** Minimum 2, Maximum 5 passes  
> **Exit Criteria:** All P0/P1 issues resolved, P2+ documented

---

### Phase 1: Discovery

**Objective:** Parallel investigation using subagents.

#### Subagent Deployment

| Subagent | Focus Area | Key Questions |
|:---------|:-----------|:--------------|
| 🔍 **Code Quality** | Logic & implementation | Duplication? Dead code? Hardcoded values? Error handling gaps? |
| 📄 **Documentation** | Accuracy & completeness | README current? Help text accurate? Comments useful? Links valid? |
| 👤 **User Experience** | Usability & clarity | Errors helpful? Validation present? Edge cases handled? |

**Instructions to Subagents:**

```
Scan assigned focus area. Report findings as:
- File: [path]
- Line: [number]  
- Issue: [description]
- Severity: [P0/P1/P2/P3]
- Suggested Fix: [approach]
```

---

### Phase 2: Expert Consultation

**Objective:** Refine findings with domain expertise.

**Load experts based on findings:**

| Finding Type | Expert to Load |
|:-------------|:---------------|
| Security vulnerabilities | `./system/experts/security.md` |
| Test coverage gaps | `./system/experts/testing.md` |
| Architecture concerns | `./system/experts/architecture.md` |
| UX/design issues | `./system/experts/design.md` |
| Implementation debt | `./system/experts/implementation.md` |

**Expert Review Protocol:**
1. Present subagent findings to relevant expert
2. Request: validation, refinement, additional concerns
3. Incorporate expert insights into final assessment

---

### Phase 3: Prioritization

**Objective:** Categorize and rank all findings.

| Priority | Label | Criteria | Action |
|:--------:|:------|:---------|:-------|
| **P0** | 🔴 CRITICAL | Security, data loss, broken core | Fix immediately |
| **P1** | 🟠 HIGH | User-facing bugs, reliability | Fix this session |
| **P2** | 🟡 MEDIUM | Tech debt, missing tests | Queue to backlog |
| **P3** | 🟢 LOW | Polish, minor improvements | Document only |
| **FEAT** | 🔵 FEATURE | New capability ideas | Add to feature backlog |

**Triage Matrix:**

```
                    ┌─────────────────────────────────────┐
  Impact on Users   │                                     │
        ▲           │   P0 ████████  P1 ████              │
        │           │                                     │
        │           │   P1 ████      P2 ████              │
        │           │                                     │
        │           │   P2 ████      P3 ████              │
        └───────────┴─────────────────────────────────────►
                           Effort to Fix
```

---

### Phase 4: Execution Loop

**Objective:** Fix all P0 and P1 issues systematically.

#### For Each Issue:

```
┌──────────────────────────────────────────────────────────┐
│  1. CREATE    → Assign MS-#### tracking ID               │
│  2. IMPLEMENT → Apply the fix                            │
│  3. VERIFY    → Run: verify.ps1 fast (or verify.sh fast) │
│  4. RECORD    → Update assessment.md with evidence       │
│  5. COMPLETE  → Mark done in tasklist.md                 │
└──────────────────────────────────────────────────────────┘
```

#### Loop Control:

| Condition | Action |
|:----------|:-------|
| P0/P1 issues remain | **Continue** to next pass |
| All P0/P1 resolved | **Stop** — document P2+ |
| Max passes (5) reached | **Escalate** — report blockers |

#### Between Passes:
1. Delete `.meta_marge` if exists
2. Recreate from clean state
3. Resume auditing with fresh perspective

---

### Phase 5: Documentation Updates

**Objective:** Ensure all supporting docs reflect current state.

#### Required Updates:

| Document | Content Required |
|:---------|:-----------------|
| `./system/tracking/assessment.md` | Audit snapshot, all findings, root cause analysis, verification evidence |
| `./system/tracking/tasklist.md` | Completed items → Done; P2/P3 → Backlog with DoD |
| `./system/knowledge/decisions.md` | New architectural decisions, pattern choices, trade-offs |
| `./system/knowledge/insights.md` | Unexpected findings, patterns discovered, lessons learned |
| `CHANGELOG.md` | Entry under [Unreleased] — Fixed/Changed/Added |
| `VERSION` | Bump if warranted: patch (fixes), minor (features), major (breaking) |

---

### Output Format

```markdown
## 🔬 Deep System Audit — [Date]

### Executive Summary

| Metric | Value |
|:-------|------:|
| **Scope** | [What was audited] |
| **Passes Completed** | X of 5 |
| **Critical Issues Found** | X |
| **Issues Fixed** | Y |
| **Backlog Items Created** | Z |

---

### Subagent Findings

| Subagent | Total Findings | P0 | P1 | P2 | P3 |
|:---------|---------------:|---:|---:|---:|---:|
| Code Quality | X | _ | _ | _ | _ |
| Documentation | X | _ | _ | _ | _ |
| User Experience | X | _ | _ | _ | _ |

---

### Expert Consultations

| Expert | Key Insight |
|:-------|:------------|
| `security.md` | [Summary of recommendation] |
| `testing.md` | [Summary of recommendation] |

---

### Fixes Applied

| ID | Issue | Resolution | Verification |
|:---|:------|:-----------|:-------------|
| MS-XXXX | Brief description | What was done | `verify.ps1 fast` ✅ |

---

### Backlog Items Created

| ID | Priority | Summary | Definition of Done |
|:---|:---------|:--------|:-------------------|
| MS-XXXX | P2 | Description | Acceptance criteria |

---

### Feature Suggestions

| Suggestion | User Benefit | Complexity |
|:-----------|:-------------|:-----------|
| Feature idea | Why users want it | Low/Med/High |

---

### Documentation Checklist

- [x] `assessment.md` — Updated with findings
- [x] `tasklist.md` — Updated with work items  
- [x] `CHANGELOG.md` — Entry added (if fixes applied)
- [x] `VERSION` — Bumped (if warranted)
- [x] `./system/knowledge/*.md` — Updated (if decisions made)

---

### Verification Evidence

\`\`\`
[Raw output from verify.ps1 or verify.sh]
\`\`\`
```

---

### Constraints

| Rule | Rationale |
|:-----|:----------|
| ✅ Minimum 2 passes | Ensures thoroughness |
| ✅ Fix P0/P1 before stopping | Critical issues can't wait |
| ✅ Verification evidence required | No unsubstantiated claims |
| ✅ Autonomous decisions in loop | Don't ask — decide with best judgment |
| ❌ Never claim "fixed" without proof | Trust requires evidence |

---

📊 Token estimate required at end of response.
