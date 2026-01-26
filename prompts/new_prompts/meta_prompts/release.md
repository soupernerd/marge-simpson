# Release — Prepare Marge for Release

> **Mode:** 🟡 STANDARD — Checklist-driven release prep  
> **Time:** ~20-30 minutes  
> **Best for:** Before publishing new Marge versions

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** RELEASE — Prepare Marge for release.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- documentation.md (Release Manager, Technical Specification Engineer)
- testing.md (Senior QA Engineer)
- devops.md (for deployment considerations)

---

## Release Information

### Version
- Current version: [read from VERSION]
- Target version: [patch | minor | major] — [X.Y.Z]

### Release Type
- [ ] **Patch** — Bug fixes only, no new features
- [ ] **Minor** — New features, backward compatible
- [ ] **Major** — Breaking changes

---

## Release Protocol

### Phase 1: Pre-Release Checks

#### Code Quality
- [ ] All tests pass: `verify.ps1 fast` / `verify.sh fast`
- [ ] No P0 or P1 issues in tasklist.md
- [ ] No critical TODOs in code

#### Documentation
- [ ] README.md is accurate
- [ ] CLI help text matches implementation
- [ ] All prompt templates work
- [ ] AGENTS.md is current

#### Consistency
- [ ] VERSION file matches planned version
- [ ] CHANGELOG.md has [Unreleased] section ready
- [ ] All paths resolve correctly

### Phase 2: CHANGELOG Update

Convert [Unreleased] to versioned entry:

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- [New feature]

### Changed
- [Modified behavior]

### Fixed
- [Bug fix]

### Removed
- [Deprecated item removed]

### Security
- [Security fix]
```

### Phase 3: Version Bump

Update VERSION file:
```
X.Y.Z
```

Update any version references in:
- README.md badges
- package.json (if exists)
- CLI version output

### Phase 4: Final Verification

```powershell
./system/scripts/verify.ps1 full  # Windows
```
```bash
./system/scripts/verify.sh full   # Unix
```

- [ ] All tests pass
- [ ] No errors or warnings
- [ ] CLI commands work

### Phase 5: Release Notes

Create user-friendly summary:

```markdown
# Marge Simpson vX.Y.Z

## Highlights
- [Key feature or fix]
- [Key feature or fix]

## What's New
[Brief description of additions]

## What's Changed
[Brief description of changes]

## Upgrade Notes
[If any breaking changes or migration needed]

## Full Changelog
See [CHANGELOG.md](CHANGELOG.md)
```

---

## Output Format

```markdown
## Release Preparation — vX.Y.Z

### Pre-Release Checklist
- [x] Tests pass
- [x] No P0/P1 issues
- [x] README accurate
- [x] CHANGELOG ready
- [x] VERSION updated

### Changes in This Release
| Category | Count |
|----------|-------|
| Added | X |
| Changed | X |
| Fixed | X |
| Removed | X |

### Breaking Changes
- [If any]

### Verification
```
[Output from verify.ps1 full]
```

### Release Notes
[Paste release notes]

### Ready to Release
- [ ] ✅ All checks pass — Ready to tag and publish
- [ ] ⚠️ Minor issues — [What needs attention]
- [ ] ❌ Not ready — [What's blocking]
```

---

## Post-Release

After publishing:
1. Create git tag: `git tag vX.Y.Z`
2. Push tag: `git push origin vX.Y.Z`
3. Create GitHub release (if applicable)
4. Announce (if applicable)
5. Reset [Unreleased] section in CHANGELOG
```

---

## ✅ Done When

- [ ] All pre-release checks pass
- [ ] VERSION bumped
- [ ] CHANGELOG updated
- [ ] Release notes ready
- [ ] Final verification passes

---

## Related Prompts

- **Found issues?** → [deep_audit.md](deep_audit.md)
- **Consistency problems?** → [consistency_audit.md](consistency_audit.md)
- **Test coverage?** → Use regular [test_audit.md](../test_audit.md)
