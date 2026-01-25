# Decisions

> Strategic choices with documented rationale. Searchable by tags.

## Entry Format
```markdown
### [D-###] Short decision title #tag1 #tag2
- **Date:** YYYY-MM-DD
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Alternatives:** What else was considered
- **Rationale:** Why this option was chosen
- **Related:** P-### or PR-### entries
```

---

## Entries

### [D-001] .meta_marge does NOT have its own scripts/ folder #meta #architecture
- **Date:** 2026-01-24
- **Context:** .meta_marge/scripts/ was a copy of marge-simpson/scripts/, creating confusion and test failures (scripts tried to test .meta_marge/cli/ which doesn't exist)
- **Decision:** Exclude scripts/ from convert-to-meta copy. Meta-development uses marge-simpson/scripts/ directly.
- **Alternatives:** Copy scripts with path transforms, create meta-specific scripts
- **Rationale:** Scripts test the source code. When auditing via .meta_marge, we want to test marge-simpson/ (the target), not .meta_marge/ (the tooling). Single source of truth.
- **Related:** D-002

### [D-002] Explicit verify paths, not relative #paths #clarity
- **Date:** 2026-01-24  
- **Context:** AGENTS.md said `./scripts/verify.ps1` which was ambiguous when multiple marge folders exist
- **Decision:** Use explicit `marge-simpson/scripts/verify.ps1` in AGENTS.md
- **Alternatives:** Keep relative paths with clear context, use environment variables
- **Rationale:** AI models can be confused by relative paths when both `marge-simpson/` and `.meta_marge/` exist. Explicit paths eliminate ambiguity.
- **Related:** D-001

### [D-003] .marge/ is a runtime artifact, not committed #cli #gitignore
- **Date:** 2026-01-24
- **Context:** `.marge/` folder was being created during tests and potentially committed
- **Decision:** Add `.marge/` to .gitignore. Per-project CLI folders are runtime artifacts.
- **Alternatives:** Clean up after tests, use different test patterns
- **Rationale:** `.marge/` is like `.claude/` or `node_modules/` — per-project state that shouldn't be version controlled. tracking/ is the committed work tracking.
- **Related:** D-004

### [D-004] PRD.md shipped as blank template #templates #runtime
- **Date:** 2026-01-24
- **Context:** `tracking/PRD.md` existed in source with filled-in content, triggering PRD mode during tests
- **Decision:** Ship PRD.md as a blank template. Users fill it in to enable PRD mode.
- **Alternatives:** Remove PRD.md entirely, skip PRD detection in tests
- **Rationale:** PRD.md IS a valid template for global install's templates/ folder. But it must be blank — filled content is user's data, not shipped content.

### [D-005] Marge is a persistent knowledge base, not an application #identity #architecture
- **Date:** 2026-01-24
- **Context:** Documentation described Marge as a "prompt engineering framework" which mischaracterizes its purpose
- **Decision:** Describe Marge as a "persistent knowledge base that keeps AI assistants informed across sessions"
- **Alternatives:** "Framework", "toolkit", "system"
- **Rationale:** Marge is more like a hard drive for AI context. It stores what AI needs to know (rules, work state, decisions) so each session starts informed. Not code, not prompts to run — just structured context AI reads.

### [D-006] Relative paths in source, explicit paths in meta #paths #flexibility
- **Date:** 2026-01-24
- **Context:** Hardcoded `marge-simpson/` paths would break if users rename folder to `.marge` or anything else
- **Decision:** Source files use relative paths (`./`) enabling folder renaming; convert-to-meta transforms `./` to explicit `.meta_marge/` paths
- **Alternatives:** Keep hardcoded paths, require specific folder name, use environment variables
- **Rationale:** Users may rename `marge-simpson/` to `.marge/` (common pattern), `marge/`, or custom names. Relative paths work regardless. Meta-development needs explicit paths to avoid ambiguity when both folders exist. Scripts path (`./scripts/`) transforms to source folder name (e.g., `marge-simpson/scripts/`) so verification always tests the source.
- **Related:** D-002

<!-- Example:
### [D-001] Use PostgreSQL over MongoDB #database #architecture
- **Date:** 2026-01-12
- **Context:** Need persistent storage for user data
- **Decision:** Use PostgreSQL with Prisma ORM
- **Alternatives:** MongoDB, SQLite, MySQL
- **Rationale:** Team familiar with SQL, need ACID, good Prisma support
- **Related:** P-002, PR-001
-->
