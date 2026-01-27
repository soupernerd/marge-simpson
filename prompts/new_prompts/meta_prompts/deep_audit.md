Read marge-simpson/AGENTS.md and follow it.

## DEEP AUDIT — Loop until clean (min 2, max 5 passes)

**Load experts:** implementation, documentation, testing, architecture, product

### Each Pass

1. **Scan** code quality, documentation accuracy, user friction
2. **Consult** loaded experts for validation
3. **Prioritize** P0/P1 (fix now) vs P2/P3 (backlog)
4. **Fix** all P0/P1 issues with MS-#### tracking
5. **Verify** with `verify.ps1 fast`

### Stop When
- All P0/P1 resolved
- P2+ documented in `marge-simpson/system/tracking/tasklist.md`
- Max 5 passes reached

### Update Before Done
- `marge-simpson/system/tracking/assessment.md` — findings + evidence
- `marge-simpson/system/tracking/tasklist.md` — completed + backlog
- `marge-simpson/system/CHANGELOG.md` — under [Unreleased]
- `marge-simpson/system/knowledge/decisions.md`, `marge-simpson/system/knowledge/insights.md` — if applicable

### Output
| Metric | Value |
|--------|-------|
| Passes | X/5 |
| P0 Fixed | X |
| P1 Fixed | X |
| System Health | 🟢/🟡/🔴 |



