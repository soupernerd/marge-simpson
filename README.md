# Marge Simpson

**Drop-in AI workflow for audits and bug fixes in any codebase.**

<p float="left">
  <img src="assets/2p1f.png" width="96%" />
</p>

---

## Install (30 seconds)

1. Copy the **`marge_simpson/`** folder into your repo root
2. Use a prompt template below

> **💡 Renamed the folder?** Replace `marge_simpson` with your folder name in prompts.

---

## Prompt Templates

### 🔍 System Audit
*Use first, or periodically to refresh the plan.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Run a system-wide audit of this workspace/repo.
- Read and understand the architecture and major workflows.
- Identify correctness issues, risky patterns, and high-impact improvements.
- Do not break intended functionality.

Update/create tracking docs:
- marge_simpson/assessment.md (snapshot + findings + new MS issues)
- marge_simpson/tasklist.md (prioritized tasks with DoD + verification)
- marge_simpson/instructions_log.md (append any new standing instructions I give)

Then immediately start executing the remaining unchecked items in marge_simpson/tasklist.md (P0 → P1 → P2), keeping docs updated as you go.
Output using the Response Format (include IDs touched).
```

---

### 🐛 Features & Issues
*Report bugs or request features. Each becomes tracked work.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

New Feature / Issues:
- (describe your issue or feature request)

After finished above, search for and complete remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2).
```

---

### 📝 Instructions
*Give direct instructions without needing a feature/issue format.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Instruction:
- (your instruction here)
- (another instruction here)

After finished above, search for and complete remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2).
```

---

### ❓ Questions & Confirmations
*Ask questions or confirm fixes. Quick answers grounded in code.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Questions / Confirmations:
1. (your question here)
2. "MS-00xx fixed" (to confirm a fix worked)

After answering the questions above, search for and complete remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2).
```

---

### 🔀 Combined
*Mix questions and issues in one prompt for efficiency.*

```
Read the AGENTS.md file in the marge_simpson folder and follow it.

Questions / Confirmations:
1. (your question here)

New Feature / Issues:
- (your issue here)

After finished above, search for and complete remaining unchecked items (if any exist) in marge_simpson/tasklist.md (P0 → P1 → P2).
```

---

## What It Does

| Behavior | Description |
|----------|-------------|
| **Reads first** | Opens files before making claims |
| **Tracks work** | Every fix gets an ID (`MS-0001`, `MS-0002`, …) |
| **Verifies** | Runs tests automatically after each fix |
| **Stays focused** | Minimal diffs, root cause fixes |

**Two source-of-truth files:**
- `tasklist.md` — what's left / doing / done
- `assessment.md` — root cause notes + verification evidence

---

## What's Inside

| File | Purpose |
|------|---------|
| `AGENTS.md` | Rules the assistant follows |
| `assessment.md` | Findings + root cause + verification |
| `tasklist.md` | Prioritized tasks (backlog → done) |
| `instructions_log.md` | Your standing instructions |
| `verify.ps1` / `verify.sh` | Automated test runner |
| `prompt_examples/` | Ready-to-copy templates |

---

## Configuration

Custom test commands in `verify.config.json`:

**Node.js:**
```json
{
  "fast": ["npm test"],
  "full": ["npm ci", "npm test", "npm run build"]
}
```

**Python:**
```json
{
  "fast": ["python -m pytest -q"],
  "full": ["pip install -e .", "python -m pytest", "python -m mypy src/"]
}
```

**Go:**
```json
{
  "fast": ["go test ./..."],
  "full": ["go test -v -race ./...", "go build ./..."]
}
```

**Multi-language / Monorepo:**
```json
{
  "fast": ["npm test", "python -m pytest -q"],
  "full": ["npm ci", "npm test", "pip install -r requirements.txt", "python -m pytest"]
}
```

No config? Scripts auto-detect Node, Python, Go, Rust, .NET, Java.

---

## Repository Architecture

This repository has a **dual-folder architecture**:

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `marge_simpson/` | **Production template** — copy this to your repos | End users installing Marge |
| `meta_marge/` | **Development instance** — improve Marge here | Contributors developing Marge itself |

**Key Points:**
- `marge_simpson/` is the **source of truth** — this is what gets distributed
- `meta_marge/` is a **working copy** with all paths/references transformed
- The `convert-to-meta` scripts create `meta_marge/` from `marge_simpson/`
- Changes flow: `marge_simpson/` → `meta_marge/` (via script) → test → manual copy back

**Why two folders?**
Marge tracks work using relative paths (e.g., `./marge_simpson/tasklist.md`). To develop Marge *using* Marge, we need a separate instance with different paths so the tooling doesn't overwrite itself.

---

## For Contributors

Want to improve Marge itself? Use the **meta development workflow**:

| Folder | Purpose |
|--------|---------|
| `marge_simpson/` | Template for end users (gets copied to other repos) |
| `meta_marge/` | Development instance (improve Marge here) |

### Quick Start
```powershell
# Windows
.\convert-to-meta.ps1

# macOS/Linux
./convert-to-meta.sh
```

### Workflow
1. Run `convert-to-meta` to create/refresh `meta_marge/`
2. Use prompts referencing `meta_marge` instead of `marge_simpson`
3. Test with `./meta_marge/test-marge.ps1` (15 tests)
4. Copy changes back to `marge_simpson/` when satisfied

### Versioning
- `marge_simpson/VERSION` — bump when releasing template changes
- `meta_marge/VERSION` — auto-updated by convert script
- Semantic: **major** (breaking) / **minor** (features) / **patch** (fixes)

---

## License

Do whatever you want with it. Fork it, rename it, ship it.
