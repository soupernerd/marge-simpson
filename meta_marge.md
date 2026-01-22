# Creating Your Own Meta Marge

This guide explains how to create a `meta_marge` folder for meta-development — i.e., improving Marge itself.

---

## What is Meta Marge?

**marge_simpson** is the production-ready Marge system you drop into other repos.

**meta_marge** is a *copy* of marge_simpson that you use to develop and test improvements to Marge itself. All paths and references are transformed so the two folders are completely isolated — nothing commingles.

When you're done improving Marge via meta_marge:
1. Copy your changes back to marge_simpson
2. Test marge_simpson works in isolation
3. Deploy marge_simpson to your other repos

---

## Quick Start

### Option 1: Use the Conversion Script (Recommended)

```powershell
# Windows PowerShell
.\convert-to-meta.ps1 -Force

# Or with custom names
.\convert-to-meta.ps1 -SourceName "marge_simpson" -TargetName "my_meta_marge"
```

```bash
# macOS/Linux
./convert-to-meta.sh

# Or with options
./convert-to-meta.sh -f                    # Force overwrite
./convert-to-meta.sh -s marge_simpson -t my_meta_marge
```

The script:
1. Copies `marge_simpson/` → `meta_marge/`
2. Transforms ALL text files, replacing `marge_simpson` → `meta_marge` in paths and references
3. Resets work queues (assessment.md, tasklist.md, instructions_log.md) to a clean slate
4. Clears verify_logs/
5. Runs verification to confirm everything works

### Option 2: Manual Conversion

1. **Copy the folder:**
   ```powershell
   Copy-Item -Recurse marge_simpson meta_marge
   ```

2. **Find and replace in ALL files:**
   - `marge_simpson/` → `meta_marge/`
   - `marge_simpson\` → `meta_marge\`
   - `[marge_simpson]` → `[meta_marge]`
   - `'marge_simpson'` → `'meta_marge'`
   - `"marge_simpson"` → `"meta_marge"`
   - Any other references

3. **Reset work queues** (assessment.md, tasklist.md, instructions_log.md)

4. **Clear verify_logs/**

5. **Test:**
   ```powershell
   .\meta_marge\scripts\verify.ps1 fast
   ```

---

## How the Conversion Works

The `convert-to-meta.ps1` script is **fully dynamic**:

- **No hardcoded file lists** — it discovers all files in the source folder automatically
- **Future-proof** — if you add, remove, or rename files in marge_simpson, the script adapts
- **Comprehensive replacement** — uses both literal patterns and regex to catch all references
- **Verification built-in** — checks for any remaining source references and runs the test suite

### What Gets Transformed

| Pattern | Example Before | Example After |
|---------|----------------|---------------|
| Paths (forward slash) | `./marge_simpson/scripts/verify.ps1` | `./meta_marge/scripts/verify.ps1` |
| Paths (backslash) | `.\marge_simpson\scripts\verify.ps1` | `.\meta_marge\scripts\verify.ps1` |
| Brackets | `[marge_simpson]` | `[meta_marge]` |
| Single quotes | `'marge_simpson'` | `'meta_marge'` |
| Double quotes | `"marge_simpson"` | `"meta_marge"` |
| Backticks | `` `marge_simpson` `` | `` `meta_marge` `` |
| Word boundaries | `the marge_simpson folder` | `the meta_marge folder` |

### Files Transformed

The script transforms any file with these extensions:
- `.md`, `.txt`, `.json`, `.yml`, `.yaml`, `.toml`
- `.ps1`, `.sh`, `.bash`, `.zsh`
- `.py`, `.js`, `.ts`, `.jsx`, `.tsx`
- `.html`, `.css`, `.scss`, `.less`
- `.xml`, `.config`, `.cfg`, `.ini`
- And more...

Binary files and `verify_logs/` are skipped.

---

## Workflow: Developing Marge

1. **Create meta_marge:**
   ```powershell
   .\convert-to-meta.ps1 -Force
   ```

2. **Work in meta_marge:**
   - Make improvements to the Marge system
   - Use the standard Marge workflow (AGENTS.md, assessment.md, tasklist.md)
   - Run verification: `.\meta_marge\scripts\verify.ps1 fast`

3. **When done, copy changes back to marge_simpson:**
   - Manually copy the specific files you changed
   - Or diff the folders and apply patches
   - Test marge_simpson independently

4. **Repeat as needed:**
   - Next time you want to improve Marge, regenerate meta_marge from the updated marge_simpson

---

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-Force` | false | Overwrite existing target folder without prompting |
| `-SourceName` | `marge_simpson` | Name of the source folder to copy from |
| `-TargetName` | `meta_marge` | Name of the target folder to create |

### Examples

```powershell
# Basic usage (prompts if meta_marge exists)
.\convert-to-meta.ps1

# Overwrite without prompting
.\convert-to-meta.ps1 -Force

# Custom folder names
.\convert-to-meta.ps1 -SourceName "marge_simpson" -TargetName "dev_marge"

# Create multiple meta instances for parallel development
.\convert-to-meta.ps1 -TargetName "meta_marge_feature_a"
.\convert-to-meta.ps1 -TargetName "meta_marge_feature_b"
```

---

## Troubleshooting

### "WARNING: 'marge_simpson' still found in: filename"

The script found files that still contain the source folder name after transformation. This can happen if:
- A file has an unusual encoding
- The reference is in an unexpected format

**Fix:** Manually edit the file to replace the remaining references.

### Verification fails after conversion

If `.\meta_marge\scripts\verify.ps1 fast` fails:
1. Check the error output
2. Ensure all paths were transformed correctly
3. Run the conversion again with `-Force`

### Want to keep work queue history?

By default, the script resets assessment.md, tasklist.md, and instructions_log.md to clean states. If you want to preserve them:
1. Backup the files before running the script
2. Restore them after the conversion
3. Manually update any `marge_simpson` references to `meta_marge`

---

## Best Practices

1. **Always test after conversion** — run `.\meta_marge\scripts\verify.ps1 fast`
2. **Keep marge_simpson clean** — it's your source of truth for production
3. **Don't mix work** — meta_marge is for improving Marge; marge_simpson is for using Marge in other repos
4. **Regenerate often** — when marge_simpson changes significantly, regenerate meta_marge instead of manually syncing
