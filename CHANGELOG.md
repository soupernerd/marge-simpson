# Changelog

All notable changes to the Marge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **`marge doctor` command** - Diagnostics for troubleshooting (checks engines, config, environment)
- **model_pricing.json validation** - Graceful fallback if JSON malformed or missing
- **`-Help` parameter** for `install-global.ps1` and `convert-to-meta.ps1`
- **Meta command test suite** - 9 new tests for meta init/status/clean commands
- **Unix verify profiles** - `fast_sh` and `full_sh` profiles in verify.config.json
- **Expanded subagent guidance** - AGENTS.md now encourages subagents for edits/creation, not just research
- **verify.sh auto-profile selection** - Automatically uses `fast_sh` profile on Unix if available
- **test-cli.sh** - Bash equivalent of test-cli.ps1 for Unix platform testing (24 tests)
- **Project type detection (PS1)** - `marge status` now shows project type (parity with bash)
- **Spinner step detection (PS1)** - Shows meaningful progress (Reading, Writing, Testing, etc.) instead of just "Working"
- **Functional CLI command tests** - Tests for init, clean, doctor, config, resume commands
- **Edge case tests** - Tests for invalid engine, invalid max-iterations, empty tasks

### Changed
- **Help text parity** - PS1 and Bash help now show identical OPTIONS and META-DEVELOPMENT sections
- **Show-Usage output** - Changed from Write-Host to Write-Output (now capturable for testing)
- **Early engine validation** - `--engine` parameter now validated during arg parsing with helpful error message
- **CLI test count increased** - From 23 to 36 tests with new functional and edge case coverage

### Fixed
- **Bash invalid flag handling** - Now shows friendly "Unknown option" message with help suggestion
- **README missing --auto** - Added --auto flag to CLI options table
- **README missing utilities** - Added `marge doctor` and `marge clean` to Utilities section
- **README missing --help** - Added `--help, -h` to CLI Options table
- **loop.md default clarity** - Clarified loop workflow default (5) vs CLI `--max-iterations` default (20)
- **deep_system_audit.md incorrect reference** - Fixed AGENTS.md path to use standard relative reference
- **marge-init bash symlink fallback** - Added copy fallback when symlinks not supported (parity with PS1)
- **Config parse warnings** - Both PS1 and bash now warn when config.yaml has parse errors or invalid values

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

[1.3.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Soupernerd/marge-simpson/compare/v1.1.0...v1.2.1
[1.1.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Soupernerd/marge-simpson/releases/tag/v1.0.0
