# Dependency Audit — Security & Freshness Check

> **Mode:** 🟡 STANDARD — Analysis with security focus  
> **Time:** ~15-20 minutes  
> **Best for:** Security reviews, upgrade planning, vulnerability assessment

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Analyze dependencies for security and freshness.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- security.md (Security & Compliance Architect)
- devops.md (for upgrade strategy)

---

## Dependency Sources

Identify and analyze:
- [ ] package.json / package-lock.json (Node.js)
- [ ] requirements.txt / Pipfile / poetry.lock (Python)
- [ ] go.mod / go.sum (Go)
- [ ] Cargo.toml / Cargo.lock (Rust)
- [ ] Other: [specify]

---

## Audit Protocol

### Phase 1: Inventory

List all dependencies:
- Direct dependencies
- Development dependencies
- Transitive dependencies (major ones)

### Phase 2: Security Scan

Check for known vulnerabilities:
- CVEs affecting current versions
- Security advisories
- Severity levels (Critical, High, Medium, Low)

Commands to help:
```bash
npm audit                    # Node.js
pip-audit                    # Python
go list -m -u all           # Go (outdated check)
cargo audit                  # Rust
```

### Phase 3: Freshness Analysis

For each dependency:

| Dependency | Current | Latest | Behind | Risk |
|------------|---------|--------|--------|------|
| react | 17.0.2 | 18.2.0 | Major | 🟡 Medium |
| lodash | 4.17.21 | 4.17.21 | Current | 🟢 None |

### Phase 4: Upgrade Planning

Prioritize updates by:
1. Security vulnerabilities (always first)
2. Breaking changes risk
3. Maintenance status (is it maintained?)
4. Dependency chains (what else needs updating?)

---

## Output Format

```markdown
## Dependency Audit — [Date]

### Summary
| Metric | Value |
|--------|-------|
| Total dependencies | X |
| Direct | X |
| Dev only | X |
| Outdated | X |
| Vulnerable | X |

### Security Status: 🟢/🟡/🔴

### Critical Vulnerabilities (Fix Immediately)

| ID | Package | Vulnerability | Severity | Fix Version |
|----|---------|---------------|----------|-------------|
| MS-XXXX | [pkg] | CVE-XXXX-XXXX | Critical | X.Y.Z |

### High Priority Updates

| Package | Current | Target | Breaking? | Notes |
|---------|---------|--------|-----------|-------|
| [pkg] | X.Y.Z | A.B.C | Yes/No | [notes] |

### Outdated (Non-Critical)

| Package | Current | Latest | Versions Behind |
|---------|---------|--------|-----------------|
| ... | ... | ... | ... |

### Unmaintained Dependencies ⚠️
- [package] — Last update: [date], consider replacing with [alternative]

### Upgrade Plan

**Phase 1: Security (This Week)**
1. Update [pkg] to fix CVE-XXXX
2. Update [pkg] to fix CVE-YYYY

**Phase 2: Major Updates (Plan Sprint)**
1. Upgrade [pkg] from X to Y — Breaking changes: [list]

**Phase 3: Routine Updates (Backlog)**
1. Minor/patch updates as part of regular maintenance

### Commands to Execute
```bash
# Security fixes
npm update [pkg]@[version]

# Major upgrades (test thoroughly)
npm install [pkg]@[version]
```
```

---

## ✅ Done When

- [ ] All dependencies inventoried
- [ ] Security vulnerabilities identified
- [ ] MS-#### created for critical vulnerabilities
- [ ] Upgrade plan prioritized
- [ ] Commands ready to execute

---

## Related Prompts

- **Do the upgrades?** → [work.md](work.md)
- **Full security review?** → [audit.md](audit.md) with security focus
- **Test after upgrades?** → [test_audit.md](test_audit.md)
