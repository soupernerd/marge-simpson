# Feature Proposal Prompt

Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** PLANNING ONLY — no code changes, no patches, no execution.

---

## Goal

Propose 3-8 new features for this project (marge-simpson assistant framework).

---

## Context Gathering (do this first)

1. Read `README.md`, `ARCHITECTURE.md`, and `./system/workflows/_index.md` to understand the project's purpose
2. Skim existing `./system/tracking/` to avoid duplicating planned work
3. Consider gaps in current workflows, CLI, or documentation

---

## Requirements

| Rule | Detail |
|------|--------|
| Ranking criterion | **End-user UX / value** (primary). Ease-of-build is secondary. |
| Status | Proposals only — nothing is approved yet |
| Scope | Features should be achievable within this repo (no external service dependencies unless clearly justified) |

---

## For Each Feature (keep concise)

```
### [Rank]. Feature Name
**What:** 1-2 sentence description of the feature
**Who/Why:** Who benefits and why it matters (1 sentence)
**Risk:** Biggest blocker, dependency, or uncertainty (1 bullet)
**Success metric:** How you'd validate it worked (user-facing outcome or acceptance criteria)
```

---

## Output Format

1. **Ranked feature list** (highest UX/value → lowest)
2. **Top pick summary** (3-4 lines): Why #1 and #2 win on UX/value
3. **Assumptions made** (if any)

---

## Deliverable

Create or update: `./system/tracking/recommended_features.md`

Include:
- Date generated
- The ranked feature list (full details)
- Top pick summary
- Note that these are **proposals pending review**

---

## Constraints

- Do NOT implement anything
- Do NOT create MS-#### task IDs (these are pre-approval ideas)
- Minimize follow-up questions — make reasonable assumptions and state them briefly
- If a feature overlaps with something in `./system/tracking/tasklist.md`, note the overlap rather than re-proposing
