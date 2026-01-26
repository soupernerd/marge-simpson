# Assessment

Purpose: Periodic, point-in-time assessments of repo/system status.

## Read First (REQUIRED)

AI/Agents must read `AGENTS.md` before working.

---

## Tracking (required)

- **Next ID:** MS-0005
  - Use this for the next new Issue/Task ID, then increment here AND in `system/tracking/tasklist.md`.

---

## Current Snapshot

- **Last updated:** 2026-01-26
- **Scope assessed:** Full workflow hardening audit (MS-0004)
- **Build/Run context:** Windows, PowerShell, verify.ps1 fast
- **Overall status:** ✅ Healthy
- **Top risks:** None - hardening complete

---

## Known Invariants (Do Not Break)

- (list "must never regress" behaviors)
- (example: persistence rules, API contracts, key UX flows)

---

## Findings (by area)

### 1) (Area / subsystem name)

**Observations**
- …

**Issues**
- …

**Recommendations**
- …

**Impact / Risk**
- …

---

## Issues Log (root-cause oriented)

> Add one entry per issue investigated/fixed. Keep it factual and file-backed.

### [MS-0004] Workflow Hardening (H1-H6)

- **Reported:** 2026-01-26
- **Status:** Done
- **Expert(s):** Comprehension, Prompting, Audit, Architecture, Testing, Implementation
- **Symptom:** Tracking files not updated despite workflow rules existing
- **Root cause:** System had zero runtime enforcement - rules existed but nothing PREVENTED non-compliance
- **Fix:** Added 6 hardline rules with blocking gates:
  - H1: Mode Declaration block required before ANY edit
  - H2: Cannot edit in Full mode without MS-#### assigned
  - H3: Lite mode auto-escalates if >1 file, >10 lines, behavior change
  - H4: 3-File checkpoint forces review (with mechanical-change exception)
  - H5: One MS-#### = one conceptual change
  - H6: Tracking sync checkbox mandatory in every response
- **Files touched:** `AGENTS.md`, `AGENTS-lite.md`, `system/workflows/work.md`, `system/workflows/session_end.md`, `system/workflows/loop.md`, `system/workflows/_index.md`
- **Verification:**
  - Commands executed: `./system/scripts/verify.ps1 fast` (4x - after each phase)
  - Evidence: 4/4 passed all phases (syntax=13, general=60, marge=15, cli=36)
- **Notes / follow-ups:** Phase 3B (expert consolidation) deferred - prompts folders are parallel by design
