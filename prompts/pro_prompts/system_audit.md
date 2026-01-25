# 🔍 System Audit

> **Purpose:** Rapid, read-only system health assessment  
> **Mode:** `AUDIT` — Analysis only, no code changes  
> **Duration:** Single pass (~15-30 min equivalent)

---

## 📖 About This Prompt

### When to Use

| Scenario | Fit |
|:---------|:---:|
| Quick health check before starting work | ✅ |
| Understanding unfamiliar codebase | ✅ |
| Pre-meeting preparation | ✅ |
| Need fixes applied immediately | ❌ Use `deep_system_audit.md` |
| Path/workflow validation | ❌ Use `path_integrity_audit.md` |

### Related Prompts

- **[deep_system_audit.md](deep_system_audit.md)** — When you need fixes applied, not just documented
- **[path_integrity_audit.md](path_integrity_audit.md)** — When paths/references need validation

---

## ✂️ THE PROMPT — COPY EVERYTHING BELOW THIS LINE

---

Read the AGENTS.md file in this folder and follow it.

## 🔍 SYSTEM AUDIT — Read-Only Analysis

> **Mode:** AUDIT — No code changes. Observe, document, recommend.

---

### Phase 1: Reconnaissance

**Objective:** Build comprehensive mental model of the system.

| Step | Action | Focus Areas |
|:----:|:-------|:------------|
| 1 | Read `.dev/ARCHITECTURE.md` | Overall design, component relationships |
| 2 | Scan entry points | Main scripts, CLI handlers, API routes |
| 3 | Map data flows | Input → Processing → Output pathways |
| 4 | Identify patterns | Design patterns, conventions in use |

**Deliverable:** Internal understanding (no output yet)

---

### Phase 2: Issue Discovery

**Objective:** Systematically identify problems by priority tier.

#### Priority Classification

| Priority | Label | Criteria | Examples |
|:--------:|:------|:---------|:---------|
| **P0** | 🔴 Critical | Blocks functionality, security risk, data loss | Auth bypass, crash on startup, data corruption |
| **P1** | 🟠 High | Degrades reliability, poor error handling | Unhandled exceptions, race conditions |
| **P2** | 🟡 Medium | Technical debt, maintainability concerns | Code duplication, missing tests, perf issues |
| **P3** | 🟢 Low | Polish, minor improvements | Style inconsistencies, documentation gaps |

**Scan Checklist:**

- [ ] **Correctness** — Does the code do what it claims?
- [ ] **Security** — Input validation, auth, secrets handling?
- [ ] **Error Handling** — Graceful failures, informative messages?
- [ ] **Edge Cases** — Boundary conditions, empty states?
- [ ] **Test Coverage** — Are critical paths tested?
- [ ] **Documentation** — README accuracy, inline comments?

---

### Phase 3: Document Findings

**Objective:** Record all findings in tracking system.

**Update:** `./system/tracking/assessment.md`

```markdown
## Audit Snapshot — [Date]

**Scope:** [What was reviewed]
**Status:** [In Progress | Complete]

### Findings

| ID | Priority | Category | Description | Location |
|----|----------|----------|-------------|----------|
| MS-XXXX | P0 | Security | Brief issue description | `file.js:42` |
```

**Update:** `./system/tracking/tasklist.md`

```markdown
## Backlog

- [ ] **MS-XXXX** (P0): Issue title
  - **DoD:** [Definition of Done]
  - **Verify:** [How to confirm fix]
```

---

### Phase 4: Report

**Objective:** Deliver actionable summary.

**Output Format:**

```markdown
## 📊 System Audit Report

### Summary
| Metric | Count |
|--------|-------|
| P0 (Critical) | X |
| P1 (High) | X |
| P2 (Medium) | X |
| P3 (Low) | X |
| **Total Issues** | X |

### Issues by Category

| ID | Pri | Category | Issue | Recommended Action |
|----|-----|----------|-------|-------------------|
| MS-XXXX | P0 | Security | Description | Fix description |

### Recommended Order of Operations

1. 🔴 **First:** [P0 items — immediate attention]
2. 🟠 **Then:** [P1 items — this session]
3. 🟡 **Later:** [P2 items — backlog]

### Unchecked Items from Tasklist

[List any pre-existing unchecked items from ./system/tracking/tasklist.md]
```

---

### Constraints

| Rule | Rationale |
|:-----|:----------|
| ❌ No code changes | Audit mode = observation only |
| ❌ No fix implementation | Document, don't modify |
| ✅ Create MS-#### IDs | All issues need tracking |
| ✅ Prioritize by impact | User-facing issues trump tech debt |
| ✅ Evidence required | Line numbers, file paths, specifics |

---

📊 Token estimate required at end of response.
