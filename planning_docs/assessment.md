# Assessment
Purpose: Periodic, point-in-time assessments of repo/system status.

## Read First (REQUIRED)
AI/Agents must read `AGENTS.md` before working.

---

## Tracking (required)
- **Next ID:** MS-0001
  - Use this for the next new Issue/Task ID, then increment here AND in `planning_docs/tasklist.md`.

---

## Current Snapshot
- **Last updated:** YYYY-MM-DD
- **Scope assessed:** (folders/features/issues covered)
- **Build/Run context:** (env, branch, key flags, platform if relevant)
- **Overall status:** ✅ Healthy / ⚠️ Mixed / ❌ Broken
- **Top risks:** (1–3 bullets)

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

### [MS-0001] Short title
- **Reported:** YYYY-MM-DD
- **Status:** Todo / Doing / Done
- **Expert(s):** (optional) Relevant expert persona(s) from `experts/_index.md`
- **Symptom:** What the user sees
- **Root cause:** The actual cause (code-level)
- **Fix:** What changed (brief)
- **Files touched:** `path/file.ext`, `path/file2.ext`
- **Verification:**
  - Test(s) added/changed: ...
  - Commands executed:
    - `./scripts/verify.sh fast` (or `./scripts/verify.ps1 fast`)
    - (any targeted command)
  - Evidence: paste raw output
- **Notes / follow-ups:** Any remaining risk or cleanup
