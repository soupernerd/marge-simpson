# Insights

> Inferred knowledge - patterns the AI has noticed that the user hasn't explicitly stated. Use cautiously.

## Entry Format
```markdown
### [I-###] Short description #tag1 #tag2
- **Observed:** YYYY-MM-DD
- **Confidence:** Low / Medium / High
- **Insight:** What was inferred
- **Evidence:** Observations that led to this
- **Verified:** [ ] User has confirmed this
- **Related:** PR-### or P-### entries
```

---

## Entries

### [I-001] Tests that run "from source folder" can pollute it #testing #paths
- **Observed:** 2026-01-24
- **Confidence:** High
- **Insight:** When tests change directory to the source folder and run CLI commands, runtime artifacts (.marge/, progress.txt) can be created in the source
- **Evidence:** "empty task" test ran `marge.ps1` from `$MsDir`, triggering PRD mode which created `.marge/progress.txt`
- **Verified:** [x] Fixed by running in temp directory
- **Related:** D-003, D-004

### [I-002] AI models struggle with multiple similar folder names #naming #clarity
- **Observed:** 2026-01-24
- **Confidence:** High
- **Insight:** When `marge-simpson/`, `.marge/`, and `.meta_marge/` all exist, AI can confuse which is which. Relative paths like `./scripts/` become ambiguous.
- **Evidence:** AI created `.marge/` folders during meta_marge audits, ran wrong verify scripts
- **Verified:** [x] Fixed with explicit paths in AGENTS.md
- **Related:** D-002

### [I-003] Shipped test data causes test pollution #testing #artifacts
- **Observed:** 2026-01-24
- **Confidence:** High
- **Insight:** Having `PRD.md` in the source repo caused the CLI to enter PRD mode during testing, even when testing "empty task gracefully"
- **Evidence:** Test expected "no task" behavior but got PRD mode because `tracking/PRD.md` existed
- **Verified:** [x] Removed PRD.md from source
- **Related:** D-004

### [I-004] CI fails after local tests pass — version/environment mismatch #ci #testing #shellcheck
- **Observed:** 2026-01-25
- **Confidence:** High
- **Insight:** Local shellcheck (v0.11.0 via winget) has different behavior than Ubuntu apt's version. Tests can pass locally but fail in CI due to:
  1. **ShellCheck version differences** — Ubuntu apt has older shellcheck that flags different warnings
  2. **Test assertions don't match code** — Tests expect patterns that were refactored out (e.g., `marge-simpson/` vs `./system/`)
  3. **Disable directives need function+body coverage** — `# shellcheck disable=SC2317` on function isn't enough, need `SC2329,SC2317` to cover unreachable function body
- **Evidence:** Multiple CI failures after verified local passes; shellcheck v0.11.0 local vs apt's older version; test expected `marge-simpson/` but AGENTS.md was refactored to use `./system/`
- **Fix pattern:** 
  1. Always run `verify.ps1 fast` as FINAL step before commit (not during development)
  2. For trap-invoked functions, use `# shellcheck disable=SC2329,SC2317` 
  3. When refactoring paths, grep for path patterns in test files too
- **Verified:** [x] Documented after 3+ occurrences
- **Related:** D-002

<!-- Example:
### [I-001] Dislikes verbose logging #logging #preferences
- **Observed:** 2026-01-12
- **Confidence:** Medium
- **Insight:** User prefers minimal console output, only errors and final results
- **Evidence:** Removed 3 console.log statements, asked for "quiet mode"
- **Verified:** [ ] User has confirmed this
- **Related:** PR-003
-->
