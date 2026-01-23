# Scripts Index

> Utility scripts for verification, cleanup, and maintenance. Run from repo root.

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **verify.ps1 / .sh** | Run test suite | After any code change |
| **test-syntax.ps1 / .sh** | Validate script syntax | Called by verify |
| **test-general.ps1 / .sh** | General validation (encoding, version, parity) | Called by verify |
| **test-marge.ps1 / .sh** | Self-test Marge structure | Called by verify |
| **test-marge-cli.sh** | Test CLI & global install | After CLI changes |
| **cleanup.ps1 / .sh** | Remove generated files | Before commits, fresh start |
| **status.ps1 / .sh** | Dashboard view | Quick health check |
| **decay.ps1 / .sh** | Find stale knowledge entries | Periodic maintenance |

## Common Commands

```powershell
# Windows
.\scripts\verify.ps1 fast -SkipIfNoTests
.\scripts\cleanup.ps1 -Preview
.\scripts\status.ps1
.\scripts\decay.ps1 -Preview
```

```bash
# macOS/Linux
./scripts/verify.sh fast --skip-if-no-tests
./scripts/cleanup.sh --preview
./scripts/status.sh
./scripts/decay.sh --preview
```

## Script Details

| Script | Flags | Notes |
|--------|-------|-------|
| verify | `fast`, `full`, `-SkipIfNoTests` | Profiles defined in `verify.config.json` |
| test-syntax | (none) | Checks PS1/Bash syntax validity |
| test-general | (none) | 61 tests: encoding, version, parity, required files, README, workflows |
| test-marge | (none) | Self-test of Marge structure |
| cleanup | `-Preview`, `-Force` | Preview shows what would be deleted |
| decay | `-Preview`, `-AutoArchive`, `-DaysThreshold N` | Default threshold: 90 days |
