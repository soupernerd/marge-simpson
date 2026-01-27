Read marge-simpson/AGENTS.md and follow it.

## RELEASE — Prepare vX.Y.Z

**Load experts:** documentation, testing, devops

**Version type:** [ ] Patch (fixes)  [ ] Minor (features)  [ ] Major (breaking)

### Pre-Release Checklist

- [ ] `verify.ps1 full` passes
- [ ] No P0/P1 in tasklist.md
- [ ] README.md accurate
- [ ] CLI help matches implementation
- [ ] CHANGELOG.md current

### Update Files

1. **VERSION** — bump to X.Y.Z
2. **CHANGELOG.md** — convert [Unreleased] to [X.Y.Z] — YYYY-MM-DD
3. **README.md** — update version badges if any

### CHANGELOG Format

```markdown
## [X.Y.Z] — YYYY-MM-DD
### Added
### Changed
### Fixed
```

### Final Verify

```powershell
marge-simpson/system/scripts/verify.ps1 full
```

### Output

- [x] Tests pass
- [x] Docs accurate
- [x] CHANGELOG updated
- [x] VERSION bumped

**Highlights:** [1-2 sentences]



