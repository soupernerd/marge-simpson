# Changelog

All notable changes to the Marge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **`marge doctor` command** - Diagnostics for troubleshooting
- **model_pricing.json validation** - Graceful fallback if malformed
- **`-Help` parameter** for install-global and convert-to-meta scripts
- **Meta command test suite** - 9 tests for meta init/status/clean
- **Unix verify profiles** - `fast_sh`/`full_sh` in verify.config.json
- **Expanded subagent guidance** - AGENTS.md encourages subagents for edits
- **verify.sh auto-profile selection** - Uses `fast_sh` on Unix if available
- **test-cli.sh** - Bash equivalent (24 tests)
- **Project type detection (PS1)** - Parity with bash
- **Spinner step detection (PS1)** - Shows Reading, Writing, Testing, etc.
- **CLI test expansion** - init, clean, doctor, config, resume, edge cases
- **--fast/--auto mode instructions** - Passes mode hints to AI prompt
- **Argument bounds checking** - Validates options have required values
- **Task failure output** - Shows last 10 lines on failure
- **Temp file cleanup on exit** - All exit paths now clean up
- **Complexity hint for lite mode** - CLI auto-detects simple tasks (typo fixes, renames, formatting) for lite mode; defaults to full AGENTS.md
- **Dynamic VERSION** - Read from VERSION file, not hardcoded
- **First-run guidance** - `marge init` shows quick start example
- **Subagent toggle** - Explicit ENABLED/DISABLED in AGENTS.md
- **Folder creation prohibition** - AI can't create .marge/ during chat
- **Cross-platform shebang** - `#!/usr/bin/env pwsh` on PS1 scripts
- **Path flexibility** - Source uses relative paths (`./`); convert-to-meta transforms to explicit

### Changed
- **README identity clarification** - Updated tagline from "drop-in workflow" to "persistent knowledge base that keeps AI assistants informed across sessions"
- **ARCHITECTURE.md identity** - Describes Marge as a "hard drive for AI context" rather than "prompt engineering framework"

### Fixed
- **P0: Get-Slug truncation bug** - Now uses `Substring()` instead of `Select-Object -First 50`
- **P1: .marge/ created during tests** - Empty task test now runs in temp directory
- **Template hardcoded paths** - Fixed `marge-simpson/` in tasklist.md and knowledge/_index.md; now uses relative `./` paths per D-006
- **P1: PRD.md is now a blank template** - Users fill it in to enable PRD mode
- **P1: Ambiguous verify path** - Now explicit `marge-simpson/scripts/verify.ps1`
- **P1: Redundant .meta_marge/scripts/** - Excluded; meta uses source scripts
- **P1: Premature loop termination** - Functions return false when files don't exist
- **P2: Path traversal validation** - Rejects `..` edge cases in both CLI scripts
- **P2: marge-init symlink indicator** - Bash now shows "(copy)" vs "(symlink)"
- **P2: Token estimate format** - AGENTS-lite.md uses `$X.XXXX` format
- **P2: Cross-platform verification docs** - work.md shows both `.ps1` and `.sh`
- **P3: Grammar/accuracy fixes** - deep_system_audit.md, loop.md
- **Security: Path traversal in --folder** - Validates folder is relative and within project
- **Security: Code injection in load_progress** - Parses explicitly instead of `source`
- **Removed unused variables** - Cleaned up dead code from CLI scripts

### Changed
- **Help text parity** - PS1 and Bash now identical
- **Show-Usage output** - Write-Output instead of Write-Host (testable)
- **Early engine validation** - Validated during arg parsing with hints
- **CLI test count** - 23 → 36 tests
- **deep_system_audit.md** - References centralized docs, removed duplication
- **Engine not found error** - Shows installation hints
- **Bash invalid flag handling** - Friendly "Unknown option" message
- **README completeness** - Added --auto, --help, doctor, clean
- **loop.md defaults** - Clarified workflow (5) vs CLI (20)
- **marge-init bash** - Added copy fallback for symlink failures
- **Config parse warnings** - Both scripts warn on invalid config.yaml
- **Missing value errors** - CLI errors if --option lacks value

## [1.3.0] - 2026-01-23

### Added
- **Lite Mode** - One-off tasks use minimal `AGENTS-lite.md` (~35 lines vs full AGENTS.md) when no local `.marge/` folder exists
- **`--full` flag** - Force full AGENTS.md workflow even for one-off tasks
- **Task Chaining** - Run multiple tasks sequentially: `marge "task1" "task2" "task3"`
- **`marge clean` command** - Remove local `.marge/` folder with safety confirmation
- **Token totals with cost** - Session summary now shows accumulated tokens and estimated cost
- **`AGENTS-lite.md`** - Lightweight agent rules for quick one-off tasks

### Changed
- CLI now auto-detects lite vs full mode based on local `.marge/` folder presence
- Single task output now shows "Mode: lite" or "Mode: full" for clarity
- Session summary enhanced with cost calculation (Claude Sonnet pricing)

### Technical
- Cherry-picked features from PR #13 (@arbuthnot-eth) with adaptations for v1.2.x architecture
- Skipped: folder rename (keep `marge-simpson/` for repo), git-free file tracking (unnecessary complexity)

## [1.2.2] - 2026-01-23

### Changed
- **Folder-agnostic templates** - All prompts and docs now use relative paths ("this folder", "planning_docs/") instead of hardcoded `.marge`
- **Flexible folder naming** - Users can name their folder anything (`marge/`, `.marge/`, `ai-assistant/`, etc.)
- **`convert-to-meta` scripts** - Now properly replace both source folder name AND `.marge` references with `.meta_marge`

### Fixed
- **MS-0001** - `.meta_marge/` was being created with `.marge` paths inside documents instead of `.meta_marge`
- All prompt_examples/*.md files updated to use relative folder references
- README.md prompt templates updated to be folder-agnostic
- workflows/_index.md scope inference updated for folder-agnostic operation

### Documentation
- Clarified three usage patterns: Direct Copy (any name), Global CLI (`.marge`), Meta-Development (`.meta_marge`)
- Updated Quick Start to emphasize folder naming flexibility

## [1.2.1] - 2026-01-23

### Changed
- **Flat repository structure** - Repo root IS the product (no nested `marge_simpson/` folder)
- **Default folder name** - Changed from `marge_simpson` to `.marge` for user projects
- **Meta folder name** - Standardized to `.meta_marge/` (inside workspace, gitignored)
- **CLI location** - Moved to `cli/` subdirectory
- **Meta tools location** - Moved to `meta/` subdirectory

### Added
- **`cli/` directory** - Contains `marge`, `marge.ps1`, `marge-init`, and global install scripts
- **`meta/` directory** - Contains `convert-to-meta.sh` and `convert-to-meta.ps1`
- **`scripts/test-syntax.ps1` and `.sh`** - Validates PowerShell/Bash script syntax at build time
- **Simplified installation** - Clone repo as `.marge/` and use directly

### Fixed
- CLI test paths now correctly reference `$MARGE_HOME/marge` instead of `$SHARED_DIR/scripts/marge`
- Version consistency across all CLI scripts

### Removed
- Root-level `install.sh` and `install.ps1` (now in `cli/`)
- Root-level `convert-to-meta.*` (now in `meta/`)
- Nested `marge_simpson/` and `.meta_marge/` folders

## [1.1.0] - 2026-01-23

### Added
- **`--folder` flag** - Target any Marge folder (e.g., `marge --folder .meta_marge "task"`)
- **`meta` command shortcut** - Quick access to `.meta_marge` folder (e.g., `marge meta "run audit"`)
- **`MARGE_FOLDER` environment variable** - Set default folder globally
- **`marge.ps1` CLI** - PowerShell version with full feature parity
- **ShellCheck linting** - CI now enforces shell script quality
- **Comprehensive test suite** - All `.sh` files validated in CI

### Changed
- README restructured with clear CLI vs Chat Prompt sections
- Improved error handling with grouped redirects (SC2129)
- Better variable scoping and pattern matching

### Fixed
- Unused variables removed (SC2034)
- Parameter expansion quoting (SC2295)
- Function reachability warnings (SC2317)

## [1.0.0] - 2026-01-20

### Added
- Initial release of Marge Simpson workflow system
- **AGENTS.md** - Core agent instructions with workflow routing
- **Workflow system** - Structured workflows for work, audit, planning, sessions
- **Expert domains** - Architecture, design, devops, implementation, etc.
- **Knowledge management** - Decisions, patterns, preferences, insights
- **Scripts** - verify.sh, cleanup.sh, decay.sh, status.sh
- **Cross-platform support** - Bash and PowerShell scripts
- **Auto-detection** - Folder name detection for marge_simpson/.meta_marge
- **Test suite** - Self-validating test-marge.sh
- **CI/CD** - GitHub Actions for Windows, Linux, macOS

### Repository Architecture
- `marge_simpson/` - Production template for end users
- `.meta_marge/` - Self-development working copy (gitignored)
- Changes flow: `marge_simpson/` → `.meta_marge/` → validate → back to `marge_simpson/`

[Unreleased]: https://github.com/Soupernerd/marge-simpson/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Soupernerd/marge-simpson/compare/v1.1.0...v1.2.1
[1.1.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Soupernerd/marge-simpson/releases/tag/v1.0.0
