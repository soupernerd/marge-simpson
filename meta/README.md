# Meta-Development Guide

> How to work on Marge itself using Marge.

## Overview

Meta-development means improving the Marge system while using it. This creates a working copy (`.meta_marge/`) inside your workspace that's separate from the source, so you can make changes without affecting the production templates.

## Quick Start

```bash
# 1. Create meta working copy
./meta/convert-to-meta.sh
# Creates: .meta_marge/ (inside your workspace, gitignored)

# 2. Work on Marge using Marge
./cli/marge --folder .meta_marge "run self-audit"
# OR: ./cli/marge meta "run self-audit"
# OR in chat: "Read AGENTS.md in .meta_marge and run a self-audit"

# 3. When satisfied, manually copy specific changed files back
#    Review changes carefully before committing
```

## How It Works

```
marge-simpson/              ← Repo root (source of truth, committed to git)
├── AGENTS.md
├── scripts/
├── ...
└── .meta_marge/            ← Working copy (gitignored)
    ├── AGENTS.md           ← Edit to improve AI instructions
    ├── workflows/          ← Edit workflow definitions
    ├── experts/            ← Edit expert profiles
    └── ...

      ↓
 (make improvements using AI)
      ↓
 (manually copy specific changes back to repo root)
      ↓
marge-simpson/              ← Updated with improvements
```

## The Conversion Process

`convert-to-meta.sh` does:

1. **Creates** `.meta_marge/` inside your workspace
2. **Copies** all Marge files into it (excluding .git, node_modules)
3. **Transforms** internal path references to `.meta_marge`
4. **Resets** planning_docs/assessment.md and planning_docs/tasklist.md to clean state

## Commands

### Create Meta Copy
```bash
./meta/convert-to-meta.sh              # Creates .meta_marge/
./meta/convert-to-meta.sh -f           # Force overwrite existing
```

### Copy Changes Back
```bash
# Manual process - review what changed and copy specific files
# There's no automatic reverse to encourage careful review
diff -r .meta_marge/ ./                # Compare changes
cp .meta_marge/AGENTS.md ./AGENTS.md   # Copy specific improved files
```

### PowerShell
```powershell
.\meta\convert-to-meta.ps1
.\meta\convert-to-meta.ps1 -Force
```

## Best Practices

1. **Always start fresh** — Run `convert-to-meta.sh` before each meta session
2. **Test in meta first** — Verify improvements work in `.meta_marge/` before copying back
3. **Review diffs** — Check changes carefully before copying back
4. **Commit frequently** — Small, focused commits make review easier

## Folder Structure

```
.meta_marge/                  ← Your working copy (gitignored)
├── AGENTS.md                 ← Edit this to improve AI instructions
├── workflows/                ← Edit workflow definitions
├── experts/                  ← Edit expert profiles
├── planning_docs/            ← Track meta-dev work
│   ├── assessment.md         ← Issues found during meta-dev
│   └── tasklist.md           ← Meta-dev tasks
└── ...
```

## Tips

- Use `./cli/marge meta "task"` as shortcut for `--folder .meta_marge`
- The `.meta_marge/` folder is gitignored — your experiments won't pollute commits
- Run audits frequently: `./cli/marge meta "audit this folder"`
- All marge meta folders use the same name (`.meta_marge/`) regardless of source
