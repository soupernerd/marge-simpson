````markdown
# Path Integrity Audit Prompt

> **Purpose:** Comprehensive scan of all file paths with cross-validation against filesystem and workflow coverage.  
> **Mode:** AUDIT + SUBAGENTS + EXPERT CONSULTATION + WORKFLOW TESTING  
> **When to use:** After folder restructures, before releases, when path-related bugs surface.

---

## The Prompt

Copy everything below the line:

---

```
Read marge-simpson/AGENTS.md and follow it.

## PATH INTEGRITY AUDIT — Full System Scan

### Overview

Audit ALL file paths in the workspace. Cross-check against actual filesystem. Validate path type correctness (relative, hardcoded, dynamic). Test all workflows end-to-end. Identify orphaned files.

### Phase 1: Path Discovery (Subagents)

Spawn subagents to scan every file. Each subagent reports:

**Subagent 1: Source Code Paths**
- Scan all `.ps1`, `.sh`, `.py`, `.js`, `.ts` files
- Extract every path reference (strings, variables, Join-Path, etc.)
- For each path: note file location, line number, path value, path type used

**Subagent 2: Documentation Paths**  
- Scan all `.md`, `.txt`, `.json`, `.yml`, `.yaml` files
- Extract path references (inline code, links, examples)
- For each path: note file location, line number, path value, expected target

**Subagent 3: Configuration Paths**
- Scan config files: `*.config.json`, `*.yml`, `package.json`, etc.
- Extract path patterns, globs, includes/excludes
- For each: note purpose and what it should match

**Subagent 4: Filesystem Inventory**
- List ALL files and folders that exist
- Create complete tree structure
- Note any empty folders or unexpected files

### Phase 2: Path Validation

For EVERY path found, validate:

| Check | Pass/Fail | Evidence |
|-------|-----------|----------|
| **Exists?** | Does the path resolve to an actual file/folder? | Test with `Test-Path` or `test -e` |
| **Type correct?** | Is relative/hardcoded/dynamic appropriate for context? | See Path Type Rules below |
| **Consistent?** | Same path referenced the same way across files? | Cross-reference all occurrences |
| **Reachable?** | Can path be reached from where it's used? | Test actual resolution |

### Phase 3: Path Type Rules (CRITICAL)

Load expert knowledge from `marge-simpson/system/experts/engineering.md` and apply these rules:

**RELATIVE paths (`./path/to/file`):**
- Use when: Same repo, script invoked from repo root
- Context: Internal references within a project
- Example: `marge-simpson/system/tracking/assessment.md`

**HARDCODED paths (`.meta_marge/system/tracking/`):**
- Use when: Cross-repo references, meta-development, CI/CD
- Context: When the AI needs to know exact location regardless of cwd
- Example: `.meta_marge/system/tracking/` (meta refers to itself explicitly)

**DYNAMIC paths (variables, Join-Path, $PSScriptRoot):**
- Use when: Scripts need portability, different install locations possible
- Context: CLI tools, global installs, user-facing scripts
- Example: `$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path`

**NEVER:**
- Mix relative and hardcoded for same target in same context
- Use relative paths in meta_marge for meta_marge files (use hardcoded)
- Use hardcoded paths for scripts that test source (they should point to source)

### Phase 4: Transform Script Audit

Special focus on path transformation scripts (e.g., `convert-to-meta.ps1/.sh`):

1. **List all transform patterns** (regex replacements, string substitutions)
2. **For each pattern:**
   - Input: What does it match?
   - Output: What does it produce?
   - Test: Provide example input → expected output
3. **Verify transforms are idempotent** (running twice doesn't break things)
4. **Check bash vs PowerShell parity** (same transforms in both)

### Phase 5: Workflow Coverage Testing

Test each workflow end-to-end. Load `marge-simpson/system/workflows/_index.md` first.

**For each workflow (`work.md`, `audit.md`, `loop.md`, `planning.md`, `session_start.md`, `session_end.md`):**

| Test | Method | Pass/Fail |
|------|--------|-----------|
| All referenced files exist | Check each `marge-simpson/system/X` path | |
| Paths resolve correctly | Test from repo root | |
| No circular dependencies | Map reference graph | |
| Examples work | Run any example commands | |

**Workflow Integration Tests:**
1. Simulate: New issue → work.md → tracking update → verify
2. Simulate: Audit → findings → work items → fix → verify
3. Simulate: Loop mode → multiple passes → clean exit

### Phase 6: Orphan Detection

Identify files NOT touched by any workflow:

1. **List all files in repo**
2. **Mark files referenced by:**
   - AGENTS.md
   - Any workflow file
   - Any script
   - README or documentation
3. **Remaining files are potential orphans**

**Exclude from orphan detection:**
- `.git/` contents
- `.github/` contents  
- `node_modules/` (if exists)
- Files explicitly marked as manually-run (check for comments)
- Asset files (`assets/`)
- License, changelog, version files

**For each orphan candidate:**
- Is it intentionally standalone? (e.g., one-off scripts)
- Should it be integrated into workflows?
- Should it be deleted?

### Phase 7: Expert Consultation

After discovery, load relevant experts:

- Path consistency issues → `marge-simpson/system/experts/engineering.md`
- Script portability issues → `marge-simpson/system/experts/operations.md`
- Workflow gaps → `marge-simpson/system/experts/engineering.md`
- Test coverage for paths → `marge-simpson/system/experts/quality.md`

Have experts review and refine recommendations.

### Phase 8: Fix Execution

**Priority Order:**
1. **P0-BROKEN:** Paths that don't resolve (404s, file not found)
2. **P1-WRONG-TYPE:** Paths using wrong type (relative where hardcoded needed)
3. **P2-INCONSISTENT:** Same path referenced differently in different places
4. **P3-ORPHAN:** Unreferenced files that should be integrated or removed

For each fix:
1. Create MS-#### tracking ID
2. Implement fix with clear rationale
3. Run `marge-simpson/system/scripts/verify.ps1 fast` (Windows) or `marge-simpson/system/scripts/verify.sh fast` (Unix)
4. Record in `marge-simpson/system/tracking/assessment.md`

### Phase 9: Verification Suite

Run complete verification:

```powershell
# Windows - Full verification
marge-simpson/system/scripts/verify.ps1

# Quick verification
marge-simpson/system/scripts/verify.ps1 fast
```

```bash
# Unix - Full verification
marge-simpson/system/scripts/verify.sh

# Quick verification  
marge-simpson/system/scripts/verify.sh fast
```

**Additional path-specific tests:**
1. Grep for common broken patterns: `\.\/tracking\/` (missing system/)
2. Grep for hardcoded repo names that should be dynamic
3. Test all scripts can be invoked from repo root
4. Test convert-to-meta produces valid .meta_marge/

### Output Format

```markdown
## Path Integrity Audit — [Date]

### Executive Summary
- **Total paths scanned:** X
- **Broken paths found:** X (fixed: Y)
- **Wrong type paths:** X (fixed: Y)  
- **Inconsistent paths:** X (fixed: Y)
- **Orphan files:** X (resolved: Y)
- **Workflows tested:** X/X passing

### Path Inventory

| File | Path | Type | Target Exists | Correct Type | Status |
|------|------|------|---------------|--------------|--------|
| AGENTS.md:15 | `marge-simpson/system/tracking/` | relative | ✅ | ✅ | OK |
| convert-to-meta.ps1:42 | `.meta_marge/system/` | hardcoded | ✅ | ✅ | OK |

### Transform Script Analysis

| Script | Pattern | Input Example | Output Example | Status |
|--------|---------|---------------|----------------|--------|
| convert-to-meta.ps1 | `marge-simpson/system/tracking/` | `marge-simpson/system/tracking/assessment.md` | `.meta_marge/system/tracking/assessment.md` | ✅ |

### Workflow Coverage

| Workflow | Files Referenced | All Exist | Integration Test | Status |
|----------|------------------|-----------|------------------|--------|
| work.md | 5 | ✅ | ✅ | PASS |
| audit.md | 4 | ✅ | ✅ | PASS |

### Orphan Analysis

| File | Decision | Rationale |
|------|----------|-----------|
| `scripts/legacy.ps1` | DELETE | Superseded by new version |
| `docs/old-guide.md` | INTEGRATE | Add to workflows |

### Fixes Applied

| ID | Category | Issue | Fix | Verified |
|----|----------|-------|-----|----------|
| MS-0001 | BROKEN | `./tracking/` doesn't exist | Changed to `marge-simpson/system/tracking/` | ✅ |

### Verification Evidence
[Raw output from verify.ps1/verify.sh]

### Expert Recommendations
- [engineering.md]: [Recommendation]
- [operations.md]: [Recommendation]
```

### Loop Criteria

- **Continue if:** Any P0 or P1 path issues remain
- **Stop when:** All paths valid, all workflows pass, orphans resolved or documented
- **Max passes:** 5 (escalate if not clean by then)
```

````



