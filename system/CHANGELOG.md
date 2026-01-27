# Changelog

All notable changes to the Marge project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.3] - 2026-01-26

### Fixed
- **P0: AGENTS.md encoding corruption** - Restored file with clean UTF-8 content (MS-0001)
- **P1: Folder references standardized** - All prompts now use hardcoded "marge-simpson folder" (MS-0002)
- **P1: Removed non-existent pro_prompts references** - Cleaned up _index.md files (MS-0003)

### Changed
- **AGENTS.md slimmed from 188->80 lines** - Removed redundant sections (MS-0004)
- **Expert files consolidated 9->4** - engineering.md, quality.md, security.md, operations.md (~88% token reduction)
- **All paths now hardcoded with `marge-simpson/` prefix** - No more relative paths (MS-0005)
- **convert-to-meta refactored** - Now uses inclusion list (4 items) instead of exclusion list (20+ items)

---

## [1.3.2] - 2026-01-26

### Added
- **Hardline enforcement rules** - Mode declaration, MS-#### tracking, 3-file checkpoint
- **Security test suite** - Input validation tests (path traversal, injection)
- **Non-Negotiable Rules** - 5 NEVER/ALWAYS rules in AGENTS.md

### Security
- Removed eval command injection in bash CLI
- Replaced cmd.exe wrapper with ProcessStartInfo
- MODEL and MARGE_HOME input validation
- Symlink checks before rm -rf

---

## [1.3.1] - 2026-01-25

### Added
- `init --help` support for both PS and Bash
- Prompts reorganization (general vs marge-specific)
- `system/tracking/PRD.md` template

### Fixed
- PS `resume` crash on missing progress file
- Bash `log_err` undefined function
- PS/Bash path parity issues

---

## [1.3.0] - 2026-01-23

### Added
- **Lite Mode** - Minimal `AGENTS-lite.md` for one-off tasks
- **Task Chaining** - `marge "task1" "task2" "task3"`
- **`marge clean` command**
- **Token totals with cost** in session summary

---

## Earlier Versions

For changes prior to v1.3.0, see the [release history](https://github.com/Soupernerd/marge-simpson/releases).

**Summary of earlier releases:**
- **v1.2.x** - Folder-agnostic templates (later reverted), flat repo structure
- **v1.1.x** - `--folder` flag, `meta` command, PowerShell CLI
- **v1.0.0** - Initial release with AGENTS.md, workflows, experts, CLI

[1.3.3]: https://github.com/Soupernerd/marge-simpson/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/Soupernerd/marge-simpson/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/Soupernerd/marge-simpson/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/Soupernerd/marge-simpson/compare/v1.2.2...v1.3.0
