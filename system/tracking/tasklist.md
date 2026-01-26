# Tasklist

Purpose: Single source of truth for active work. Keep this current as tasks are added/closed.
Rule: If it's being worked on, it must be here.

## Read First (REQUIRED)

AI/Agents must read `AGENTS.md` before working.

---

## Tracking (required)

- **Next ID:** MS-0005
  - Use this for the next new Issue/Task ID, then increment here AND in `system/tracking/assessment.md`.

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
  - **Expert(s):** Relevant expert(s) from `./system/experts/_index.md`
  - **Definition of Done:** …
  - **Verification:**
    - Run automated verification:
      - macOS/Linux: `./system/scripts/verify.sh fast`
      - Windows: `./system/scripts/verify.ps1 fast`
    - Add/adjust a regression test or deterministic repro for this MS item.
    - Record evidence in `./system/tracking/assessment.md` (raw output or verify log path).
  - **Files likely involved:** …
  - **Linked assessment:** [MS-0001]

### P1 — Should fix (important but not blocking)

- [ ] **MS-0002 —** …

### P2 — Nice to have (polish / refactor / cleanup)

- [ ] **MS-0003 —** …

---

## In Progress

_(none)_

---

## Done (recent)

- [x] **MS-0004 — Workflow Hardening (H1-H6)**
  - **Completed:** 2026-01-26
  - **Expert(s):** Comprehension, Prompting, Audit, Architecture, Testing, Implementation
  - **Verification:**
    - Commands run: `verify.ps1 fast` after each phase
    - Evidence: 4/4 passed (syntax, general, marge, cli)
  - **Changes:**
    - AGENTS.md: Added Non-Negotiable Rules, Mode Declaration block, Task Mode boundaries, 3-File Checkpoint
    - AGENTS-lite.md: Added Lite Mode Limits
    - work.md: Added H5 (One ID = One Concept), H6 (Tracking Sync mandatory)
    - session_end.md: Removed soft language, trimmed entry formats
    - loop.md: Simplified min/max parsing section
    - _index.md: Added AGENTS.md reference note
