# Changelog

All notable changes to the Marge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-23

### Changed - BREAKING
- **Flat repository structure** - Repo root IS the product (no nested `marge_simpson/` folder)
- **Default folder name** - Changed from `marge_simpson` to `.marge` for user projects
- **Meta folder name** - Changed from `meta_marge` to `.marge_meta`
- **CLI location** - Moved to `cli/` subdirectory
- **Meta tools location** - Moved to `meta/` subdirectory

### Added
- **`cli/` directory** - Contains `marge`, `marge.ps1`, `marge-init`, and global install scripts
- **`meta/` directory** - Contains `convert-to-meta.sh` and `convert-to-meta.ps1`
- **Simplified installation** - Clone repo as `.marge/` and use directly

### Removed
- Root-level `install.sh` and `install.ps1` (now in `cli/`)
- Root-level `convert-to-meta.*` (now in `meta/`)
- Nested `marge_simpson/` and `meta_marge/` folders
- Old `meta_marge.md` documentation (replaced by `meta/README.md`)

### Migration
If upgrading from 1.x:
1. Your `.marge/` or `marge_simpson/` folders will continue to work
2. To use new features, re-clone the repo as `.marge/`
3. Update any scripts that referenced `marge_simpson/` paths

## [1.1.0] - 2026-01-23

### Added
- **`--folder` flag** - Target any Marge folder (e.g., `marge --folder meta_marge "task"`)
- **`meta` command shortcut** - Quick access to meta_marge folder (e.g., `marge meta "run audit"`)
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
- **Auto-detection** - Folder name detection for marge_simpson/meta_marge
- **Test suite** - Self-validating test-marge.sh
- **CI/CD** - GitHub Actions for Windows, Linux, macOS

### Repository Architecture
- `marge_simpson/` - Production template for end users
- `meta_marge/` - Self-development working copy (gitignored)
- Changes flow: `marge_simpson/` → `meta_marge/` → validate → back to `marge_simpson/`

[2.0.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Soupernerd/marge-simpson/releases/tag/v1.0.0
