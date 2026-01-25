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

<!-- Example:
### [I-001] Dislikes verbose logging #logging #preferences
- **Observed:** 2026-01-12
- **Confidence:** Medium
- **Insight:** User prefers minimal console output, only errors and final results
- **Evidence:** Removed 3 console.log statements, asked for "quiet mode"
- **Verified:** [ ] User has confirmed this
- **Related:** PR-003
-->
