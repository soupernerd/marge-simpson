# Scripts Index

> Utility scripts for verification, cleanup, and maintenance. Run from repo root.

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| **verify.ps1 / .sh** | Run test suite | After any code change |
| **test-marge.ps1 / .sh** | Self-test Marge structure | Called by verify |
| **cleanup.ps1 / .sh** | Remove generated files | Before commits, fresh start |
| **status.ps1 / .sh** | Dashboard view | Quick health check |
| **decay.ps1 / .sh** | Find stale knowledge entries | Periodic maintenance |

## Common Commands

```powershell
# Windows
.\marge_simpson\scripts\verify.ps1 fast -SkipIfNoTests
.\marge_simpson\scripts\cleanup.ps1 -Preview
.\marge_simpson\scripts\status.ps1
.\marge_simpson\scripts\decay.ps1 -Preview
```

```bash
# macOS/Linux
./marge_simpson/scripts/verify.sh fast --skip-if-no-tests
./marge_simpson/scripts/cleanup.sh --preview
./marge_simpson/scripts/status.sh
./marge_simpson/scripts/decay.sh --preview
```

## Script Details

| Script | Flags | Notes |
|--------|-------|-------|
| verify | `fast`, `full`, `-SkipIfNoTests` | Profiles defined in `verify.config.json` |
| cleanup | `-Preview`, `-Force` | Preview shows what would be deleted |
| decay | `-Preview`, `-AutoArchive`, `-DaysThreshold N` | Default threshold: 90 days |
