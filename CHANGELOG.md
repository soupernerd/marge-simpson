# Changelog

All notable changes to the Marge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.2.2]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Soupernerd/marge-simpson/compare/v1.1.0...v1.2.1
[1.1.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Soupernerd/marge-simpson/releases/tag/v1.0.0
