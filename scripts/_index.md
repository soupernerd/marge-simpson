# Scripts Index

> Utility scripts for verification, cleanup, and maintenance. Run from repo root.

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **verify.ps1 / .sh** | Run test suite | After any code change |
| **test-syntax.ps1 / .sh** | Validate script syntax | Called by verify |
| **test-general.ps1 / .sh** | General validation (encoding, version, parity) | Called by verify |
| **test-marge.ps1 / .sh** | Self-test Marge structure | Called by verify |
| **test-cli.ps1 / .sh** | CLI integration tests | After CLI changes |
| **test-marge-cli.sh** | Test CLI & global install | After CLI changes |
| **cleanup.ps1 / .sh** | Remove generated files | Before commits, fresh start |
| **status.ps1 / .sh** | Dashboard view | Quick health check |
| **decay.ps1 / .sh** | Find stale knowledge entries | Periodic maintenance |

## Common Commands

```powershell
# Windows
.\marge-simpson\scripts\verify.ps1 fast -SkipIfNoTests
.\marge-simpson\scripts\cleanup.ps1 -Preview
.\marge-simpson\scripts\status.ps1
.\marge-simpson\scripts\decay.ps1 -Preview
```

```bash
# macOS/Linux
./marge-simpson/scripts/verify.sh fast --skip-if-no-tests
./marge-simpson/scripts/cleanup.sh --preview
./marge-simpson/scripts/status.sh
./marge-simpson/scripts/decay.sh --preview
```

## Script Details

| Script | Flags | Notes |
|--------|-------|-------|
| verify | `fast`, `full`, `-SkipIfNoTests` | Profiles defined in `verify.config.json` |
| test-syntax | (none) | Checks PS1/Bash syntax validity |
| test-general | (none) | 60 tests: encoding, version, parity, required files, README, workflows |
| test-marge | (none) | Self-test of Marge structure |
| cleanup | `-Preview`, `-Force` | Preview shows what would be deleted |
| decay | `-Preview`, `-AutoArchive`, `-DaysThreshold N` | Default threshold: 90 days |
