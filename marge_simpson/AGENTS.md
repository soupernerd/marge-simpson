# marge_simpson/AGENTS.md — Assistant Operating Rules (General Dev)

This folder is a drop-in workflow for running audits and fixing bugs in any codebase.

Priority order: correctness > safety > minimal diffs > speed.

---

## A) Universal Rules (always apply)

1) Ground in the actual code
- Read relevant files before making claims about the codebase.
- If you haven’t opened it, treat it as unknown and don’t speculate.

2) Minimize questions (cost-aware)
- Proceed with reasonable assumptions.
- Ask questions only when blocked or when a wrong assumption would cause major rework/risk.

3) Fix root causes, not symptoms
- Diagnose and fix at the source. Avoid band-aids.

4) Small, safe, reversible changes
- Minimize blast radius: touch the fewest files/lines necessary.
- Avoid refactors unless needed for correctness, maintainability, or a requested feature.

5) Major-change checkpoint (requires approval)
Before any of the following, stop and request approval with a short plan + risks + rollback/migration notes:
- architecture changes, large refactors, dependency swaps
- schema/data format changes, API contract changes
- behavior changes that may affect users
- deleting/replacing substantial code paths

6) Evidence-driven debugging
- Use reproduction steps, logs, tracing, and tests to confirm the cause.
- Don’t guess; verify.

7) Verification is required (AUTOMATED + LINEAR)
- For EACH issue, verification is a hard gate.
- Do NOT move to the next issue until the current issue has passing verification evidence.
- Prefer adding an automated regression test. If not feasible quickly, add a deterministic repro script/steps.
- Always run the repo verification runner:
  - macOS/Linux: `./marge_simpson/verify.sh fast`
  - Windows (PowerShell): `./marge_simpson/verify.ps1 fast`
- The verification runner uses `marge_simpson/verify.config.json` if present (recommended for deterministic commands).
  If it is empty or missing, it auto-detects common test stacks.
- Include raw command output in `assessment.md` (or reference the log file path created by the verify runner).
- Never claim "tests passed" without evidence.

### Verification Gate (NON-NEGOTIABLE)
For each issue (MS-####), work MUST be linear:

A) Test plan first
   - Identify the smallest test(s) that prove the fix.
   - Prefer an automated regression test.
   - If automation is not feasible quickly, create a deterministic repro script/steps.

B) Prove it fails (before)
   - Ensure the test/repro fails on the current code (or document why it cannot).

C) Fix
   - Implement the smallest safe fix.

D) Run verification (after)
   - Run the verification runner (fast by default), plus any issue-specific command(s).

E) Record evidence
   - In `assessment.md` under the MS entry, record:
     - Tests added/changed
     - Commands executed
     - Raw output (or the verify log file path)

F) Only then
   - Mark the task Verified/Done in `tasklist.md` and proceed.

If command execution is unavailable in the current environment, treat verification as BLOCKED and request the minimum
needed capability to run `verify` (one question max).

8) Security + data safety by default
- Don’t introduce insecure patterns (secrets in code, injection risks, overly broad CORS, unsafe eval, etc.).
- Never request or output credentials. Use env vars and safe placeholders.

9) Output should be actionable and minimal
- Prefer patches/diffs and file-by-file edits.
- Keep explanations short unless asked.

10) Silent typo handling
- If the user misspells something, infer the intent and proceed without calling it out.

11) Uncertainty policy
- If unsure, say what you checked, what you know, and what remains unknown.
- Provide options + tradeoffs rather than pretending certainty.

---

## B) Repo Workflow (audit → plan → execute loop)

### Tracking IDs (required)
- Use a single shared, incrementing ID for all tracked work: `MS-0001`, `MS-0002`, ...
- Maintain a `Next ID:` field in BOTH:
  - `marge_simpson/assessment.md`
  - `marge_simpson/tasklist.md`
- When creating a new issue/task:
  1) Use the current `Next ID` as the item’s ID.
  2) Increment `Next ID` by 1 in BOTH files immediately.
- Every task must reference an ID, and every issue entry must use an ID.

### Source-of-truth files (required)
- `marge_simpson/tasklist.md` = what’s left / what’s in progress / what’s done
- `marge_simpson/assessment.md` = findings + root cause notes + verification notes
- `marge_simpson/instructions_log.md` = append-only log of new standing instructions from the user

### Issue intake trigger (when a message contains "Issues:" followed by bullets)
If the user message contains a section labeled `Issues:` with bullet points, treat each bullet as a candidate issue and follow this section exactly.

1) Treat each bullet as a candidate issue.
2) For each bullet, create an ID and record it:
   - Add/append an entry in `assessment.md` (symptom → root cause → fix → files touched → verification).
   - Add a task in `tasklist.md` (DoD + verification + status).
   - Increment `Next ID` in BOTH files.
3) Implement fixes in this order:
   A) Existing unchecked P0/P1 items already in `tasklist.md`
   B) Then the newly created items from the user’s bullet list
   C) Then continue remaining unchecked items (P0 → P1 → P2)
4) Do not mark items Done unless verification is solid.

### Execution loop
When asked to audit, refactor, repair, or upgrade:

1) Read `marge_simpson/AGENTS.md`, then scan relevant folders/files.
2) Audit without breaking intended functionality.
3) Write findings into `assessment.md`.
4) Update `tasklist.md` with concrete, ordered steps (DoD + verification).
5) Execute tasklist steps, updating docs as you go.
6) Repeat until objectives are met.

Rule: assessment + tasklist are the source of truth during the loop.

---

## C) Response Format (default)

When delivering work, use:

- **IDs touched:** MS-000X, MS-000Y
- **What changed:** (1–3 bullets)
- **Patch / edits:** (diff or file-specific blocks)
- **How to verify:** (short checklist)
- **Notes / risks:** (only if needed)

If verification fails or is incomplete, keep the item as Doing and write what's missing.

---

## D) Bulleted Issues Workflow

When the user provides a message containing `Questions / Confirmations:` and/or `Issues:` sections with bullets, follow this workflow:

### Goal
Fix all listed issues in one run. After EACH fix, run automated verification and record evidence. Do not require follow-up input unless blocked from executing commands.

### Execution Rules

1) **Minimize questions (cost-aware)**
   - Ask questions only if a wrong assumption would cause major rework or if you are blocked.
   - If needed, ask ALL questions in one short batch (max 5).

2) **Issue intake + tracking (required)**
   - Treat each bullet under `Issues:` as a new candidate item.
   - For each bullet:
     - Create the next MS-#### ID.
     - Add an entry in `marge_simpson/assessment.md`.
     - Add a task in `marge_simpson/tasklist.md` (DoD + Verification).
     - Increment `Next ID` in BOTH files immediately.

3) **Work order**
   - A) Existing unchecked P0/P1 items already in `tasklist.md`
   - B) Then the newly created items from this message
   - C) Then remaining unchecked items (P0 → P1 → P2)

4) **Verification Gate** — Follow Section A.7 exactly (NON-NEGOTIABLE).

5) **Response format** — Use Section C format, plus:
   - `Verification evidence (per ID):` section with raw output or log path

---

## E) System-Wide Audit Workflow

When the user requests a system-wide audit, follow this workflow:

### Audit Phase
1) Read and understand the architecture and major workflows.
2) Identify correctness issues, risky patterns, and high-impact improvements.
3) Do not break intended functionality.

### Update/Create Tracking Docs (required)
- `marge_simpson/assessment.md`
  - Current snapshot (scope, status, top risks)
  - Findings by area
  - Issues Log entries (MS-####) with root cause, fix plan, and verification plan
- `marge_simpson/tasklist.md`
  - Prioritized, ordered tasks with Definition of Done and Verification (automated)
- `marge_simpson/instructions_log.md`
  - Append any new standing instructions the user provides

### Execution Phase
Immediately start executing the remaining unchecked items in `marge_simpson/tasklist.md` (P0 → P1 → P2), keeping docs updated as you go.

### Verification Requirements (do not skip)
- For EACH MS item you implement, run automated verification and record evidence before moving on.
- Follow Section A.7 Verification Gate exactly (NON-NEGOTIABLE).
- Prefer adding an automated regression test for each fix.
- Never claim tests passed without raw output or a verify log file path.

### Response Format
Use Section C format, including IDs touched.
