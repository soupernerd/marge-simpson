# Assessment
Purpose: Periodic, point-in-time assessments of repo/system status.

## Read First (REQUIRED)
AI/Agents must read `AGENTS.md` before working.

---

## Tracking (required)
- **Next ID:** MS-0006
  - Use this for the next new Issue/Task ID, then increment here AND in `system/tracking/tasklist.md`.

---

## Current Snapshot
- **Last updated:** 2026-01-25
- **Scope assessed:** Full path integrity audit - all files, CI, configs, workflows
- **Build/Run context:** Windows PowerShell, verify.ps1 fast
- **Overall status:** ✅ Healthy
- **Top risks:** None after fixes applied

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

### [MS-0002] CI workflow broken paths
- **Reported:** 2026-01-25
- **Status:** Done
- **Expert(s):** devops
- **Symptom:** CI jobs fail - scripts not found at `./scripts/`
- **Root cause:** Scripts moved to `./system/scripts/` during restructure but CI not updated
- **Fix:** Updated all paths in `.github/workflows/ci.yml` from `./scripts/` to `./system/scripts/`
- **Files touched:** `.github/workflows/ci.yml`
- **Verification:**
  - Commands executed: `verify.ps1 fast`
  - Evidence: ALL CHECKS PASSED (4/4 commands)

### [MS-0003] verify.config.json wrong filename
- **Reported:** 2026-01-25
- **Status:** Done
- **Expert(s):** devops
- **Symptom:** Shell verification would fail - file `test-marge-cli.sh` doesn't exist
- **Root cause:** Typo in config - should be `test-cli.sh`
- **Fix:** Changed `test-marge-cli.sh` to `test-cli.sh` in fast_sh and full_sh profiles
- **Files touched:** `verify.config.json`
- **Verification:**
  - Commands executed: `verify.ps1 fast`
  - Evidence: Config loads correctly, all tests pass

### [MS-0004] Orphaned knowledge/ folder
- **Reported:** 2026-01-25
- **Status:** Done
- **Expert(s):** architecture
- **Symptom:** Duplicate `knowledge/decisions.md` at root level
- **Root cause:** Folder restructure (MS-0001) moved to `system/knowledge/` but old copy remained
- **Fix:** Deleted orphan folder `knowledge/`
- **Files touched:** `knowledge/` (deleted)
- **Verification:**
  - Commands executed: `Test-Path knowledge/` returns False
  - Evidence: Folder no longer exists

### [MS-0005] Bash parity issue in convert-to-meta.sh
- **Reported:** 2026-01-25
- **Status:** Done
- **Expert(s):** devops
- **Symptom:** PowerShell transform handles `./system/model_pricing.json` but Bash doesn't
- **Root cause:** Missing string replacement in Bash version
- **Fix:** Added `./system/model_pricing.json` transform to Bash script
- **Files touched:** `.dev/meta/convert-to-meta.sh`
- **Verification:**
  - Commands executed: `verify.ps1 fast`
  - Evidence: All tests pass, parity now complete

### [MS-0001] Short title
- **Reported:** YYYY-MM-DD
- **Status:** Todo / Doing / Done
- **Expert(s):** (optional) Relevant expert persona(s) from `./system/experts/_index.md`
- **Symptom:** What the user sees
- **Root cause:** The actual cause (code-level)
- **Fix:** What changed (brief)
- **Files touched:** `path/file.ext`, `path/file2.ext`
- **Verification:**
  - Test(s) added/changed: ...
  - Commands executed:
    - `./system/scripts/verify.sh fast` (or `./system/scripts/verify.ps1 fast`)
    - (any targeted command)
  - Evidence: paste raw output
- **Notes / follow-ups:** Any remaining risk or cleanup
