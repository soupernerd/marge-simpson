# 🛤️ Path Integrity Audit

> **Purpose:** Comprehensive validation of all file paths, cross-references, and workflow coverage  
> **Mode:** `AUDIT` + `SUBAGENTS` + `EXPERT CONSULTATION` + `WORKFLOW TESTING`  
> **Duration:** Multi-phase systematic scan

---

## 📖 About This Prompt

### When to Use

| Scenario | Fit |
|:---------|:---:|
| After folder restructure | ✅ Perfect fit |
| Before CI/CD pipeline setup | ✅ Validates all paths |
| Path-related bugs surfacing | ✅ Root cause analysis |
| Pre-release validation | ✅ Comprehensive check |
| Quick health check | ❌ Use `system_audit.md` |
| General code review | ❌ Use `deep_system_audit.md` |

### Best Practices

| Practice | Why It Matters |
|:---------|:---------------|
| **Run after any restructure** | Paths break silently during moves |
| **Test from repo root** | Validates standard execution context |
| **Check both OS variants** | PowerShell + Bash should produce same results |
| **Document orphan decisions** | Prevents future confusion about intentionally standalone files |

### Related Prompts

- **[system_audit.md](system_audit.md)** — Quick read-only health check
- **[deep_system_audit.md](deep_system_audit.md)** — Full audit with fixes

---

## ✂️ THE PROMPT — COPY EVERYTHING BELOW THIS LINE

---

Read the AGENTS.md file in this folder and follow it.

## 🛤️ PATH INTEGRITY AUDIT — Full System Scan

> **Objective:** Validate every file path in the workspace. Cross-check against filesystem.  
> **Scope:** All code, docs, configs, and workflows.  
> **Exit Criteria:** All paths valid, all workflows passing, orphans resolved.

---

### Phase 1: Path Discovery

**Objective:** Extract every path reference using parallel subagents.

#### Subagent Assignments

| Subagent | Target Files | Extract |
|:---------|:-------------|:--------|
| 🔧 **Source Paths** | `.ps1`, `.sh`, `.py`, `.js`, `.ts` | Path strings, variables, `Join-Path`, `$PSScriptRoot` |
| 📄 **Doc Paths** | `.md`, `.txt`, `.json`, `.yml`, `.yaml` | Inline code refs, links, code block examples |
| ⚙️ **Config Paths** | `*.config.json`, `*.yml`, `package.json` | Path patterns, globs, includes/excludes |
| 📁 **Filesystem** | Entire workspace | Complete file/folder tree, empty dirs, unexpected files |

**Subagent Output Format:**

```markdown
| File | Line | Path Value | Path Type | Context |
|------|------|------------|-----------|---------|
| script.ps1 | 42 | ./system/tracking/ | relative | Assignment to $TrackingPath |
```

---

### Phase 2: Path Validation

**Objective:** Verify every discovered path.

#### Validation Matrix

| Check | Method | Pass Criteria |
|:------|:-------|:--------------|
| **Exists?** | `Test-Path` / `test -e` | Path resolves to actual file/folder |
| **Type Correct?** | See Path Type Rules | Relative/hardcoded/dynamic appropriate for context |
| **Consistent?** | Cross-reference scan | Same target → same path style everywhere |
| **Reachable?** | Test from usage location | Path resolves correctly from execution context |

#### Validation Output:

```markdown
| Path | Exists | Type OK | Consistent | Reachable | Status |
|------|:------:|:-------:|:----------:|:---------:|:------:|
| ./system/tracking/ | ✅ | ✅ | ✅ | ✅ | ✅ PASS |
| ./tracking/ | ❌ | ❌ | - | - | ❌ FAIL |
```

---

### Phase 3: Path Type Rules

**Objective:** Apply correct path type based on context.

#### 📐 Relative Paths (`./path/to/file`)

| Use When | Example | Context |
|:---------|:--------|:--------|
| Same repository | `./system/tracking/assessment.md` | Internal project references |
| Script invoked from repo root | `./system/scripts/verify.ps1` | Standard execution context |
| Documentation links | `[Link](./docs/guide.md)` | Markdown cross-references |

#### 🔒 Hardcoded Paths (`.meta_marge/system/tracking/`)

| Use When | Example | Context |
|:---------|:--------|:--------|
| Cross-repo references | `.meta_marge/system/tracking/` | Meta framework referencing itself |
| CI/CD pipelines | `/home/runner/work/project/` | Known deployment paths |
| Explicit location required | Full absolute path | When cwd uncertainty exists |

#### ⚡ Dynamic Paths (variables, computed)

| Use When | Example | Context |
|:---------|:--------|:--------|
| Portability required | `$PSScriptRoot` / `$(dirname "$0")` | Scripts run from various locations |
| User-configurable | `$env:PROJECT_ROOT` | Respecting user environment |
| Multi-platform | `Join-Path` / `path.join()` | Cross-OS compatibility |

#### 🚫 Never Do This

| Anti-Pattern | Why It's Wrong |
|:-------------|:---------------|
| Mix relative + hardcoded for same target | Inconsistency causes confusion |
| Relative paths in meta_marge for meta_marge files | Self-references should be explicit |
| Hardcoded paths in source-testing scripts | Tests should point to source, not specific install |

---

### Phase 4: Transform Script Audit

**Objective:** Validate path transformation logic (e.g., `convert-to-meta.ps1`).

#### Analysis Template:

| Script | Pattern | Input → Output | Idempotent? | Bash Parity? |
|:-------|:--------|:---------------|:-----------:|:------------:|
| `convert-to-meta.ps1` | `./system/ → .meta_marge/system/` | `./system/tracking/` → `.meta_marge/system/tracking/` | ✅ | ✅ |

#### Verification Tests:
1. Run transform once → verify output
2. Run transform again → verify no change (idempotent)
3. Compare PowerShell vs Bash outputs → verify identical

---

### Phase 5: Workflow Coverage Testing

**Objective:** End-to-end validation of all workflows.

#### Load: `./system/workflows/_index.md`

#### Workflow Test Matrix:

| Workflow | Files Referenced | All Exist? | Integration Test | Status |
|:---------|:-----------------|:----------:|:----------------:|:------:|
| `work.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |
| `audit.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |
| `loop.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |
| `planning.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |
| `session_start.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |
| `session_end.md` | X files | ✅/❌ | ✅/❌ | PASS/FAIL |

#### Integration Scenarios:

| Scenario | Steps | Expected Outcome |
|:---------|:------|:-----------------|
| New Issue Flow | Issue → `work.md` → tracking update → verify | Clean verify output |
| Audit Flow | Audit → findings → work items → fix → verify | All issues tracked |
| Loop Mode | Multiple passes → fixes applied → clean exit | Zero P0/P1 remaining |

---

### Phase 6: Orphan Detection

**Objective:** Find unreferenced files that may be dead weight.

#### Detection Process:

1. **List all files** in repository
2. **Mark as referenced** if mentioned in:
   - `AGENTS.md`
   - Any workflow file (`./system/workflows/*.md`)
   - Any script (`*.ps1`, `*.sh`, `*.py`, etc.)
   - README or documentation
3. **Remaining files = potential orphans**

#### Exclusions (Not Orphans):

```
.git/           # Git internals
.github/        # GitHub configuration  
node_modules/   # Dependencies
assets/         # Static resources
LICENSE         # Legal files
CHANGELOG.md    # Standard files
VERSION         # Version marker
```

#### Orphan Resolution:

| File | Decision | Rationale |
|:-----|:---------|:----------|
| `scripts/legacy.ps1` | 🗑️ DELETE | Superseded by new version |
| `docs/old-guide.md` | 🔗 INTEGRATE | Add to workflows |
| `utils/helper.py` | ✅ KEEP | Manually-run utility (add comment) |

---

### Phase 7: Expert Consultation

**Objective:** Refine recommendations with domain expertise.

| Issue Type | Expert | Key Questions |
|:-----------|:-------|:--------------|
| Path consistency | `./system/experts/architecture.md` | Pattern alignment, convention adherence |
| Script portability | `./system/experts/devops.md` | Cross-platform compatibility |
| Doc path issues | `./system/experts/documentation.md` | Link integrity, reference accuracy |
| Workflow gaps | `./system/experts/implementation.md` | Coverage completeness |
| Path testing | `./system/experts/testing.md` | Automated path validation |

---

### Phase 8: Fix Execution

**Objective:** Resolve all path issues by priority.

#### Priority Order:

| Priority | Label | Criteria | Action |
|:--------:|:------|:---------|:-------|
| **P0** | 🔴 BROKEN | Path doesn't resolve (404, file not found) | Fix immediately |
| **P1** | 🟠 WRONG TYPE | Relative where hardcoded needed (or vice versa) | Fix this session |
| **P2** | 🟡 INCONSISTENT | Same path referenced differently across files | Standardize |
| **P3** | 🟢 ORPHAN | Unreferenced file needing integration/removal | Document decision |

#### Fix Protocol:

```
┌──────────────────────────────────────────────────────────┐
│  1. CREATE    → Assign MS-#### tracking ID               │
│  2. DOCUMENT  → Record issue + rationale in assessment   │
│  3. IMPLEMENT → Apply the path correction                │
│  4. VERIFY    → Run: verify.ps1 fast (or verify.sh fast) │
│  5. COMPLETE  → Mark done in tasklist.md                 │
└──────────────────────────────────────────────────────────┘
```

---

### Phase 9: Final Verification

**Objective:** Comprehensive verification of all fixes.

#### Verification Commands:

**Windows:**
```powershell
# Full verification
./system/scripts/verify.ps1

# Quick verification
./system/scripts/verify.ps1 fast
```

**Unix:**
```bash
# Full verification
./system/scripts/verify.sh

# Quick verification
./system/scripts/verify.sh fast
```

#### Path-Specific Tests:

| Test | Command/Method | Purpose |
|:-----|:---------------|:--------|
| Broken patterns | `grep -r "\.\/tracking\/"` | Find missing `system/` prefix |
| Hardcoded repos | `grep -r "/Users/` or `C:\\Users\\` | Dynamic path opportunities |
| Script invocation | Run from repo root | Verify all scripts work |
| Transform output | Run `convert-to-meta` | Verify `.meta_marge/` valid |

---

### Output Format

```markdown
## 🛤️ Path Integrity Audit — [Date]

### Executive Summary

| Metric | Count |
|:-------|------:|
| **Total Paths Scanned** | X |
| **Broken Paths** | X (fixed: Y) |
| **Wrong Type** | X (fixed: Y) |
| **Inconsistent** | X (fixed: Y) |
| **Orphan Files** | X (resolved: Y) |
| **Workflows Tested** | X/X passing |

---

### Path Inventory

| Location | Path | Type | Exists | Correct Type | Status |
|:---------|:-----|:-----|:------:|:------------:|:------:|
| `AGENTS.md:15` | `./system/tracking/` | relative | ✅ | ✅ | ✅ OK |
| `convert.ps1:42` | `.meta_marge/system/` | hardcoded | ✅ | ✅ | ✅ OK |

---

### Transform Script Analysis

| Script | Pattern | Input Example | Output Example | Status |
|:-------|:--------|:--------------|:---------------|:------:|
| `convert-to-meta.ps1` | `./system/ → .meta_marge/system/` | `./system/tracking/assessment.md` | `.meta_marge/system/tracking/assessment.md` | ✅ |

---

### Workflow Coverage

| Workflow | Files Ref'd | All Exist | Integration | Status |
|:---------|:-----------:|:---------:|:-----------:|:------:|
| `work.md` | 5 | ✅ | ✅ | ✅ PASS |
| `audit.md` | 4 | ✅ | ✅ | ✅ PASS |
| `loop.md` | 3 | ✅ | ✅ | ✅ PASS |

---

### Orphan Analysis

| File | Decision | Rationale |
|:-----|:---------|:----------|
| `scripts/legacy.ps1` | 🗑️ DELETE | Superseded |
| `docs/old-guide.md` | 🔗 INTEGRATE | Add to workflows |

---

### Fixes Applied

| ID | Category | Issue | Resolution | Verified |
|:---|:---------|:------|:-----------|:--------:|
| MS-XXXX | BROKEN | `./tracking/` missing prefix | → `./system/tracking/` | ✅ |

---

### Expert Recommendations

| Expert | Recommendation |
|:-------|:---------------|
| `architecture.md` | [Key insight] |
| `devops.md` | [Key insight] |

---

### Verification Evidence

\`\`\`
[Raw output from verify.ps1 or verify.sh]
\`\`\`
```

---

### Loop Criteria

| Condition | Action |
|:----------|:-------|
| P0/P1 path issues remain | **Continue** — more fixes needed |
| All paths valid + workflows pass | **Stop** — document orphan decisions |
| Max passes (5) reached | **Escalate** — report blocking issues |

---

📊 Token estimate required at end of response.
