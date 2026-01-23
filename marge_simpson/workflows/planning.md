# Planning Workflow

> Read-only analysis mode. NO code changes allowed.

## When to Use

User's prompt contains:
- "PLANNING ONLY"
- "plan only"
- "no code changes"
- "read only"
- "analyze only"

---

## Rules (Strictly Enforced)

### ✅ DO
- Read and analyze code
- Compare code against requirements
- Generate/update `tasklist.md` with prioritized tasks
- Update `assessment.md` with findings and analysis
- Create implementation plans and recommendations

### ❌ DO NOT
- Make any code changes
- Create patches or diffs
- Modify any source files
- Run implementation commands

---

## Why Planning Mode Exists

- **Saves tokens** — analysis without implementation overhead
- **Prevents accidents** — no unintended changes during discovery
- **Clear phases** — planning and building are distinct

---

## Output

Update these files only:
- `assessment.md` — findings, gap analysis
- `tasklist.md` — prioritized tasks extracted from findings

Do NOT touch source code.
