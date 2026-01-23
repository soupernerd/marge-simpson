# tasklist.md
Purpose: Single source of truth for active work. Keep this current as tasks are added/closed.
Rule: If it's being worked on, it must be here.

## Read First (REQUIRED)
AI/Agents must read `AGENTS.md` before working.

---

## Tracking (required)
- **Next ID:** MS-0001
  - Use this for the next new Issue/Task ID, then increment here AND in `assessment.md`.

---

## Active Priorities (Top 5)
1) …
2) …
3) …
4) …
5) …

---

## Work Queue

### P0 — Must fix (breaking / core workflow)
- [ ] **MS-0001 —** (clear, testable outcome)
  - **Why:** …
  - **Expert(s):** (optional) Relevant expert persona(s) from `EXPERT_REGISTRY.md`
  - **Definition of Done:** …
  - **Verification:**
    - Run automated verification:
      - macOS/Linux: `./scripts/verify.sh fast`
      - Windows: `./scripts/verify.ps1 fast`
    - Add/adjust a regression test or deterministic repro for this MS item.
    - Record evidence in `assessment.md` (raw output or verify log path).
  - **Files likely involved:** …
  - **Linked assessment:** [MS-0001]

### P1 — Should fix (important but not blocking)
- [ ] **MS-0002 —** …

### P2 — Nice to have (polish / refactor / cleanup)
- [ ] **MS-0003 —** …

---

## In Progress
- [ ] **MS-000X —** …
  - **Started:** YYYY-MM-DD
  - **Expert(s):** (optional) Relevant expert persona(s) from `EXPERT_REGISTRY.md`
  - **Current status:** …
  - **Blockers:** …
  - **Next step:** …

---

## Done (recent)
- [x] **MS-000X —** …
  - **Completed:** YYYY-MM-DD
  - **Expert(s):** (optional) Relevant expert persona(s) from `EXPERT_REGISTRY.md`
  - **Verification:**
    - Commands run: …
    - Evidence: (paste raw output)
