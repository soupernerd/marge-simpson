# Meta-Development Guide

> How to work on Marge itself using Marge.

## Overview

Meta-development means improving the Marge system while using it. This creates a working copy (`.marge_meta/`) that's separate from the source of truth, so you can make changes without affecting the production templates.

## Quick Start

```bash
# 1. Create meta working copy
./meta/convert-to-meta.sh
# Creates: .marge_meta/ (or meta_marge/ if in marge_simpson/)

# 2. Work on Marge using Marge
./cli/marge --folder .marge_meta "run self-audit"
# OR in chat: "Read AGENTS.md in .marge_meta and run a self-audit"

# 3. When satisfied, manually copy specific changed files back
#    Review changes carefully before committing
```

## How It Works

```
/                           ← Repo root (source of truth, committed to git)
      ↓
 convert-to-meta.sh
      ↓
.marge_meta/                ← Working copy (gitignored)
      ↓
 (make improvements using AI)
      ↓
 (manually copy specific changes back)
      ↓
/                           ← Updated with improvements
```

## The Conversion Process

`convert-to-meta.sh` does:

1. **Copies** all files from repo root to `.marge_meta/`
2. **Transforms** internal path references:
   - `.marge/` → `.marge_meta/`
   - Script paths updated
3. **Resets** assessment.md and tasklist.md to clean state

## Commands

### Create Meta Copy
```bash
./meta/convert-to-meta.sh              # Creates .marge_meta/
./meta/convert-to-meta.sh -f           # Force overwrite existing
```

### Copy Changes Back
```bash
# Manual process - review what changed and copy specific files
# There's no automatic reverse to encourage careful review
diff -r .marge_meta/ ./                # Compare changes
cp .marge_meta/AGENTS.md ./AGENTS.md   # Copy specific improved files
```

### PowerShell
```powershell
.\meta\convert-to-meta.ps1
.\meta\convert-to-meta.ps1 -Force
```

## Best Practices

1. **Always start fresh** — Run `convert-to-meta.sh` before each meta session
2. **Test in meta first** — Verify improvements work in `.marge_meta/` before copying back
3. **Review diffs** — Check `git diff` after `--reverse` to see what changed
4. **Commit frequently** — Small, focused commits make review easier

## Folder Structure

```
.marge_meta/                  ← Your working copy
├── AGENTS.md                 ← Edit this to improve AI instructions
├── workflows/                ← Edit workflow definitions
├── experts/                  ← Edit expert profiles
├── assessment.md             ← Track issues found during meta-dev
├── tasklist.md               ← Track meta-dev tasks
└── ...
```

## Tips

- Use `./cli/marge meta "task"` as shortcut for `--folder .marge_meta`
- The `.marge_meta/` folder is gitignored — your experiments won't pollute commits
- Run audits frequently: `./cli/marge meta "audit this folder"`
