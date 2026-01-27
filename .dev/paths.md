# Path Audit: marge-simpson → .meta_marge

> Full inventory of all hardcoded paths in marge-simpson/ (excluding .meta_marge/).
> Each path shows: **SOURCE** (what's in marge-simpson) → **META** (what should appear in .meta_marge)

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Should be TRANSFORMED to .meta_marge path |
| 🔒 | Should STAY as marge-simpson (points to source files) |
| 📋 | Human-readable docs (not exec paths) |
| ⚠️ | Potential issue / needs review |

---

## AGENTS.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 35 | `marge-simpson/system/tracking/` | ✅ | `.meta_marge/system/tracking/` |
| 72 | `marge-simpson/system/experts/engineering.md` | 🔒 | `marge-simpson/system/experts/engineering.md` (stay) |
| 73 | `marge-simpson/system/experts/quality.md` | 🔒 | `marge-simpson/system/experts/quality.md` (stay) |
| 74 | `marge-simpson/system/experts/security.md` | 🔒 | `marge-simpson/system/experts/security.md` (stay) |
| 75 | `marge-simpson/system/experts/operations.md` | 🔒 | `marge-simpson/system/experts/operations.md` (stay) |
| 76 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 77 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 78 | `marge-simpson/system/knowledge/patterns.md` | ✅ | `.meta_marge/system/knowledge/patterns.md` |
| 101 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 102 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 107 | `marge-simpson/system/scripts/verify.ps1 fast` | 🔒 | `marge-simpson/system/scripts/verify.ps1 fast` (stay) |
| 114 | `marge-simpson/system/workflows/work.md` | ✅ | `.meta_marge/system/workflows/work.md` |
| 115 | `marge-simpson/system/workflows/audit.md` | ✅ | `.meta_marge/system/workflows/audit.md` |
| 116 | `marge-simpson/system/workflows/planning.md` | ✅ | `.meta_marge/system/workflows/planning.md` |
| 131 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 132 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 133 | `marge-simpson/system/knowledge/patterns.md` | ✅ | `.meta_marge/system/knowledge/patterns.md` |
| 134 | `marge-simpson/system/knowledge/insights.md` | ✅ | `.meta_marge/system/knowledge/insights.md` |
| 138 | `marge-simpson/system/knowledge/_index.md` | ✅ | `.meta_marge/system/knowledge/_index.md` |
| 147 | `marge-simpson/system/knowledge/.decay-timestamp` | ⚠️ | **SKIP** (meta mode disables decay) |
| 148 | `marge-simpson/system/scripts/decay.ps1` | 🔒 | **SKIP** (meta mode disables decay) |
| 152 | `marge-simpson/system/experts/_index.md` | 🔒 | `marge-simpson/system/experts/_index.md` (stay) |
| 153 | `marge-simpson/system/workflows/_index.md` | ✅ | `.meta_marge/system/workflows/_index.md` |
| 154 | `marge-simpson/system/knowledge/_index.md` | ✅ | `.meta_marge/system/knowledge/_index.md` |

---

## verify.config.json

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 3-6 | `.\marge-simpson\system\scripts\test-syntax.ps1` | 🔒 | `.\marge-simpson\system\scripts\test-syntax.ps1` (stay) |
| 3-6 | `.\marge-simpson\system\scripts\test-general.ps1` | 🔒 | `.\marge-simpson\system\scripts\test-general.ps1` (stay) |
| 3-6 | `.\marge-simpson\system\scripts\test-marge.ps1` | 🔒 | `.\marge-simpson\system\scripts\test-marge.ps1` (stay) |
| 3-6 | `.\marge-simpson\system\scripts\test-cli.ps1` | 🔒 | `.\marge-simpson\system\scripts\test-cli.ps1` (stay) |
| 16-19 | `marge-simpson/system/scripts/test-syntax.sh` | 🔒 | `marge-simpson/system/scripts/test-syntax.sh` (stay) |
| 16-19 | `marge-simpson/system/scripts/test-general.sh` | 🔒 | `marge-simpson/system/scripts/test-general.sh` (stay) |
| 16-19 | `marge-simpson/system/scripts/test-marge.sh` | 🔒 | `marge-simpson/system/scripts/test-marge.sh` (stay) |
| 16-19 | `marge-simpson/system/scripts/test-cli.sh` | 🔒 | `marge-simpson/system/scripts/test-cli.sh` (stay) |

**Note:** .meta_marge gets its OWN verify.config.json with trigger wrappers that add test-templates tests.

---

## system/workflows/_index.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 9 | `marge-simpson/system/tracking/` | ✅ | `.meta_marge/system/tracking/` |
| 10 | `marge-simpson/system/workflows/` | ✅ | `.meta_marge/system/workflows/` |
| 11 | `marge-simpson/system/experts/` | 🔒 | `marge-simpson/system/experts/` (stay) |
| 12 | `marge-simpson/system/knowledge/` | ✅ | `.meta_marge/system/knowledge/` |
| 37 | `marge-simpson/system/workflows/planning.md` | ✅ | `.meta_marge/system/workflows/planning.md` |
| 41 | `marge-simpson/system/workflows/work.md` | ✅ | `.meta_marge/system/workflows/work.md` |
| 42 | `marge-simpson/system/workflows/loop.md` | ✅ | `.meta_marge/system/workflows/loop.md` |
| 45 | `marge-simpson/system/workflows/audit.md` | ✅ | `.meta_marge/system/workflows/audit.md` |
| 46 | `marge-simpson/system/workflows/work.md` | ✅ | `.meta_marge/system/workflows/work.md` |
| 49 | `marge-simpson/system/workflows/session_end.md` | ✅ | `.meta_marge/system/workflows/session_end.md` |
| 52 | `marge-simpson/system/workflows/session_end.md` | ✅ | `.meta_marge/system/workflows/session_end.md` |

---

## system/workflows/work.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 33 | `marge-simpson/system/experts/engineering.md` | 🔒 | `marge-simpson/system/experts/engineering.md` (stay) |
| 34 | `marge-simpson/system/experts/quality.md` | 🔒 | `marge-simpson/system/experts/quality.md` (stay) |
| 35 | `marge-simpson/system/experts/security.md` | 🔒 | `marge-simpson/system/experts/security.md` (stay) |
| 36 | `marge-simpson/system/experts/operations.md` | 🔒 | `marge-simpson/system/experts/operations.md` (stay) |
| 40 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 41 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 58 | `marge-simpson/system/tracking/[name]_MS-####.md` | ✅ | `.meta_marge/system/tracking/[name]_MS-####.md` |
| 59 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 59 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 64 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 72 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 76 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 90 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 136 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 137 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 152 | `marge-simpson/system/knowledge/decisions.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 153 | `marge-simpson/system/knowledge/preferences.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 154 | `marge-simpson/system/knowledge/patterns.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 155 | `marge-simpson/system/knowledge/insights.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 157 | `marge-simpson/system/knowledge/_index.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 165 | `marge-simpson/system/knowledge/.decay-timestamp` | ⚠️ | **SKIP** (meta mode disables decay) |
| 166 | `marge-simpson/system/scripts/decay.ps1` | 🔒 | `marge-simpson/system/scripts/decay.ps1` (stay) |

---

## system/workflows/audit.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 18 | `marge-simpson/system/experts/security.md` | 🔒 | `marge-simpson/system/experts/security.md` (stay) |
| 19 | `marge-simpson/system/experts/engineering.md` | 🔒 | `marge-simpson/system/experts/engineering.md` (stay) |
| 19 | `marge-simpson/system/experts/quality.md` | 🔒 | `marge-simpson/system/experts/quality.md` (stay) |
| 20 | `marge-simpson/system/experts/engineering.md` | 🔒 | `marge-simpson/system/experts/engineering.md` (stay) |
| 21 | `marge-simpson/system/experts/_index.md` | 🔒 | `marge-simpson/system/experts/_index.md` (stay) |
| 29 | `marge-simpson/system/knowledge/_index.md` | ✅ | `.meta_marge/system/knowledge/_index.md` |
| 30 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 32 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 55 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |

---

## system/workflows/planning.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 20 | `marge-simpson/system/experts/engineering.md` | 🔒 | `marge-simpson/system/experts/engineering.md` (stay) |
| 21 | `marge-simpson/system/experts/security.md` | 🔒 | `marge-simpson/system/experts/security.md` (stay) |
| 29 | `marge-simpson/system/tracking/[feature]_PLAN.md` | ✅ | `.meta_marge/system/tracking/[feature]_PLAN.md` |
| 31 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 43 | `marge-simpson/system/tracking/feature_plan_template.md` | ✅ | `.meta_marge/system/tracking/feature_plan_template.md` |
| 104 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 105 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 106 | `marge-simpson/system/workflows/work.md` | ✅ | `.meta_marge/system/workflows/work.md` |

---

## system/workflows/session_start.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 16 | `marge-simpson/system/knowledge/_index.md` | ✅ | `.meta_marge/system/knowledge/_index.md` |
| 25 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 51 | `marge-simpson/system/knowledge/insights.md` | ✅ | `.meta_marge/system/knowledge/insights.md` |
| 52 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 65 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 66 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 67 | `marge-simpson/system/knowledge/patterns.md` | ✅ | `.meta_marge/system/knowledge/patterns.md` |

---

## system/workflows/session_end.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 31 | `marge-simpson/system/knowledge/_index.md` | ⚠️ | **SKIP** (meta mode disables knowledge capture) |
| 61 | `marge-simpson/system/knowledge/preferences.md` | ⚠️ | **SKIP** |
| 62 | `marge-simpson/system/knowledge/decisions.md` | ⚠️ | **SKIP** |
| 63 | `marge-simpson/system/knowledge/patterns.md` | ⚠️ | **SKIP** |
| 64 | `marge-simpson/system/knowledge/insights.md` | ⚠️ | **SKIP** |
| 76 | `marge-simpson/system/knowledge/*.md` | ⚠️ | **SKIP** |
| 114 | `marge-simpson/system/knowledge/_index.md` | ⚠️ | **SKIP** |
| 120 | `marge-simpson/system/knowledge/_index.md` | ⚠️ | **SKIP** |
| 134 | `marge-simpson/system/knowledge/.decay-timestamp` | ⚠️ | **SKIP** |
| 140 | `marge-simpson/system/scripts/decay.ps1` | 🔒 | `marge-simpson/system/scripts/decay.ps1` (stay) |
| 142 | `marge-simpson/system/knowledge/.decay-timestamp` | ⚠️ | **SKIP** |
| 157 | `marge-simpson/system/knowledge/archive.md` | ⚠️ | **SKIP** |

---

## system/tracking/tasklist.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 14 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 35 | `marge-simpson/system/experts/_index.md` | 🔒 | `marge-simpson/system/experts/_index.md` (stay) |
| 39 | `marge-simpson/system/scripts/verify.sh fast` | 🔒 | `marge-simpson/system/scripts/verify.sh fast` (stay) |
| 40 | `marge-simpson/system/scripts/verify.ps1 fast` | 🔒 | `marge-simpson/system/scripts/verify.ps1 fast` (stay) |
| 42 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |

---

## system/tracking/assessment.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 14 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 63 | `marge-simpson/system/experts/_index.md` | 🔒 | `marge-simpson/system/experts/_index.md` (stay) |
| 69 | `marge-simpson/system/scripts/verify.ps1 fast` | 🔒 | `marge-simpson/system/scripts/verify.ps1 fast` (stay) |

---

## system/knowledge/_index.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 14 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 17 | `marge-simpson/system/knowledge/*.md` | ✅ | `.meta_marge/system/knowledge/*.md` |
| 47-51 | `marge-simpson/system/knowledge/decisions.md` | ✅ | `.meta_marge/system/knowledge/decisions.md` |
| 47-51 | `marge-simpson/system/knowledge/patterns.md` | ✅ | `.meta_marge/system/knowledge/patterns.md` |
| 47-51 | `marge-simpson/system/knowledge/preferences.md` | ✅ | `.meta_marge/system/knowledge/preferences.md` |
| 47-51 | `marge-simpson/system/knowledge/insights.md` | ✅ | `.meta_marge/system/knowledge/insights.md` |
| 47-51 | `marge-simpson/system/knowledge/archive.md` | ✅ | `.meta_marge/system/knowledge/archive.md` |
| 74 | `marge-simpson/system/knowledge/archive.md` | ✅ | `.meta_marge/system/knowledge/archive.md` |

---

## system/scripts/_index.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 30 | `marge-simpson/system/scripts/verify.sh fast --skip-if-no-tests` | 📋 | N/A (example command) |
| 31 | `marge-simpson/system/scripts/cleanup.sh --preview` | 📋 | N/A (example command) |
| 32 | `marge-simpson/system/scripts/status.sh` | 📋 | N/A (example command) |
| 33 | `marge-simpson/system/scripts/decay.sh --preview` | 📋 | N/A (example command) |

---

## system/scripts/verify.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 15-17 | `marge-simpson/system/scripts/verify.sh` | 📋 | N/A (example in comments) |

---

## system/scripts/test-templates.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 4 | `marge-simpson/system/scripts/` | 📋 | N/A (comment explaining location) |
| 7 | `marge-simpson/` | 📋 | N/A (comment - must check source) |
| 18 | `marge-simpson/system/scripts/` | 📋 | N/A (comment) |
| 25 | `.meta_marge/` vs `marge-simpson/` | 📋 | N/A (validation check) |

---

## system/scripts/test-templates.ps1

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 5 | `marge-simpson/` | 📋 | N/A (comment) |
| 7 | `marge-simpson/system/scripts/` | 📋 | N/A (comment) |
| 10 | `marge-simpson/` | 📋 | N/A (comment) |
| 12 | `marge-simpson/` | 📋 | N/A (comment) |
| 28 | `.meta_marge/` vs `marge-simpson/` | 📋 | N/A (validation check) |

---

## system/scripts/test-marge.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 13 | `marge-simpson/system/scripts/test-marge.sh` | 📋 | N/A (example command) |
| 146-147 | `marge-simpson/system/` | 📋 | N/A (grep pattern check) |

---

## system/scripts/test-cli.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 10 | `marge-simpson/system/scripts/test-cli.sh` | 📋 | N/A (example command) |

---

## system/scripts/test-cli.ps1

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 433 | `marge-simpson/system/tracking/PRD.md` | 📋 | N/A (comment explaining temp dir usage) |

---

## system/scripts/status.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 14 | `marge-simpson/system/scripts/status.sh` | 📋 | N/A (example command) |

---

## system/scripts/decay.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 15-17 | `marge-simpson/system/scripts/decay.sh` | 📋 | N/A (example commands) |

---

## system/scripts/cleanup.sh

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 13 | `marge-simpson/system/scripts/cleanup.sh` | 📋 | N/A (example command) |

---

## system/scripts/cleanup.ps1

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 12 | `marge-simpson/system/scripts/cleanup.ps1` | 📋 | N/A (example command) |

---

## system/CHANGELOG.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 64 | `github.com/Soupernerd/marge-simpson/releases` | 🔒 | N/A (GitHub URL - no transform) |
| 71-74 | `github.com/Soupernerd/marge-simpson/compare/...` | 🔒 | N/A (GitHub URLs - no transform) |

---

## README.md

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 31 | `marge-simpson/` | 📋 | N/A (installation instruction) |
| 81 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| 89 | `marge-simpson/system/tracking/assessment.md` | ✅ | `.meta_marge/system/tracking/assessment.md` |
| 90 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 92 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 103 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| 110 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 121 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| 127 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 138 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| 146 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 192 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| 206 | `marge-simpson/system/tracking/tasklist.md` | ✅ | `.meta_marge/system/tracking/tasklist.md` |
| 393 | `marge-simpson/` (target of improvements) | 📋 | N/A (meta workflow explanation) |
| 394 | `marge-simpson/system/scripts/test-marge.sh` | 🔒 | N/A (testing source files) |

---

## prompts/*.md

| File | Line | Source Path | Transform? | Meta Path |
|------|------|-------------|------------|-----------|
| audit.md | 1 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| prompt.md | 1 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| suggest.md | 1 | `Read marge-simpson/AGENTS.md` | ✅ | `Read .meta_marge/AGENTS.md` |
| suggest.md | 10 | `marge-simpson/system/tracking/recommended_features.md` | ✅ | `.meta_marge/system/tracking/recommended_features.md` |

---

## cli/marge (bash)

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 58 | `system/tracking/PRD.md` | 📋 | N/A (generic user workspace) |
| 176 | `marge-simpson/` (target of improvements) | 📋 | N/A (meta workflow diagram) |
| 178 | `marge-simpson/` | 📋 | N/A (meta workflow diagram) |
| 180 | `.meta_marge/system/tracking/` | 📋 | N/A (already meta path) |
| 444 | `./system/model_pricing.json` | 📋 | N/A (user workspace path) |
| 546 | `.meta_marge/system/tracking/assessment.md` | 📋 | N/A (already meta path) |
| 556-561 | `.meta_marge/system/tracking/` | 📋 | N/A (already meta paths) |
| 674-678 | `marge-simpson/` and `.meta_marge/` | 📋 | N/A (status display) |
| 756 | `./system/model_pricing.json` | 📋 | N/A (user workspace) |
| 1239-1261 | `system/tracking/PRD.md` | 📋 | N/A (init creates in user workspace) |

---

## cli/marge.ps1

| Line | Source Path | Transform? | Meta Path |
|------|-------------|------------|-----------|
| 105 | `system/tracking/PRD.md` | 📋 | N/A (generic user workspace) |
| 207 | `marge-simpson/` (target) | 📋 | N/A (meta workflow diagram) |
| 209 | `marge-simpson/` | 📋 | N/A (meta workflow diagram) |
| 211 | `.meta_marge/system/tracking/` | 📋 | N/A (already meta path) |
| 406 | `./system/model_pricing.json` | 📋 | N/A (user workspace path) |
| 1023-1046 | `system/tracking/PRD.md` | 📋 | N/A (init creates in user workspace) |
| 1295-1325 | `.meta_marge\system\tracking\` | 📋 | N/A (already meta paths) |
| 1438-1441 | `marge-simpson/` and `.meta_marge/` | 📋 | N/A (status display) |

---

## .dev/meta/convert-to-meta.ps1 (THE TRANSFORMER)

This is the file that CREATES .meta_marge. It contains transform logic, not paths to transform.

**Transform patterns defined:**

```powershell
# Line 121: AGENTS.md instruction
'Read marge-simpson/AGENTS\.md' → 'Read .meta_marge/AGENTS.md'

# Lines 128-130: Tracking, workflows, knowledge → .meta_marge
'marge-simpson/system/tracking/' → '.meta_marge/system/tracking/'
'marge-simpson/system/workflows/' → '.meta_marge/system/workflows/'
'marge-simpson/system/knowledge/' → '.meta_marge/system/knowledge/'

# NOT transformed (stays pointing to source):
'marge-simpson/system/experts/' → stays as-is
'marge-simpson/system/scripts/' → stays as-is
```

---

# Summary: Transform Rules

## SHOULD BE TRANSFORMED (✅)

| Pattern | Becomes |
|---------|---------|
| `marge-simpson/system/tracking/` | `.meta_marge/system/tracking/` |
| `marge-simpson/system/workflows/` | `.meta_marge/system/workflows/` |
| `marge-simpson/system/knowledge/` | `.meta_marge/system/knowledge/` |
| `Read marge-simpson/AGENTS.md` | `Read .meta_marge/AGENTS.md` |

## SHOULD STAY AS-IS (🔒)

| Pattern | Reason |
|---------|--------|
| `marge-simpson/system/experts/` | AI loads actual expert files from source |
| `marge-simpson/system/scripts/` | Verify/test scripts run from source |
| `marge-simpson/system/CHANGELOG.md` | Source file being modified |
| GitHub URLs with `marge-simpson` | External references |

## SPECIAL CASES (⚠️)

| Pattern | Meta Behavior |
|---------|---------------|
| Knowledge capture paths | SKIP section in meta AGENTS.md |
| Decay check paths | SKIP section in meta AGENTS.md |
| `feature_plan_template.md` | Should be in .meta_marge/system/tracking/ |

---

# Issues Found

## 1. ⚠️ Knowledge paths in workflows need review

In `work.md` and `session_end.md`, knowledge capture sections reference `marge-simpson/system/knowledge/`. 

**Current convert-to-meta.ps1 behavior:** Transforms these paths to `.meta_marge/system/knowledge/`

**Expected behavior:** Since meta mode DISABLES knowledge capture (replaced with SKIP message in AGENTS.md), these transformed paths in the workflow copies are harmless but confusing.

**Recommendation:** Either:
1. Leave as-is (harmless since AGENTS.md skip overrides) ✅ Current
2. Or add workflow-specific patches to remove those sections entirely

## 2. ⚠️ deep_audit.md has CHANGELOG path

Line 23 references `marge-simpson/system/CHANGELOG.md` which should STAY as source reference, not transform.

**Current convert-to-meta.ps1:** Does NOT have a specific rule for this, but general transform won't match it since pattern is `marge-simpson/system/tracking/` not `marge-simpson/system/`.

**Status:** ✅ CORRECT (no transform happens)

## 3. ✅ Experts paths correctly untouched

All `marge-simpson/system/experts/` paths correctly stay as-is.

## 4. ✅ Scripts paths correctly untouched

All `marge-simpson/system/scripts/` paths correctly stay as-is.

---

# Verification Checklist

To verify convert-to-meta.ps1 is working correctly:

- [ ] `.meta_marge/AGENTS.md` contains `.meta_marge/system/tracking/` (not marge-simpson)
- [ ] `.meta_marge/AGENTS.md` contains `marge-simpson/system/experts/` (unchanged)
- [ ] `.meta_marge/AGENTS.md` contains `marge-simpson/system/scripts/verify.ps1` (unchanged)
- [ ] `.meta_marge/system/workflows/work.md` contains `.meta_marge/system/tracking/` (transformed)
- [ ] `.meta_marge/system/workflows/work.md` contains `marge-simpson/system/experts/` (unchanged)
- [ ] `.meta_marge/prompts/` files contain `Read .meta_marge/AGENTS.md` (transformed)
- [ ] Knowledge Capture section in `.meta_marge/AGENTS.md` says "SKIP"
- [ ] Decay Check section in `.meta_marge/AGENTS.md` says "SKIP"

---

*Generated: Path Audit for marge-simpson v1.3.3*
