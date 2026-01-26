# Generate Docs — Create Project Documentation

> **Mode:** 🟡 STANDARD — Generate documentation from code  
> **Time:** ~15-25 minutes  
> **Best for:** README creation, API docs, architecture documentation

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** DOCUMENT — Generate documentation from code analysis.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- documentation.md (Technical Specification Engineer, API Documentation Architect)
- architecture.md (if documenting architecture)

---

## Documentation Request

### What to Document

(Choose one or more, delete unused)

- [ ] **README.md** — Project overview, setup, usage
- [ ] **ARCHITECTURE.md** — System design, components, data flow
- [ ] **API.md** — Endpoints, request/response formats
- [ ] **CONTRIBUTING.md** — How to contribute
- [ ] **CHANGELOG.md** — Version history
- [ ] **Inline docs** — JSDoc, docstrings, comments
- [ ] **Custom:** [describe]

### Existing Docs

- [ ] No existing docs (create from scratch)
- [ ] Existing docs need update (preserve structure)
- [ ] Existing docs are outdated (rewrite)

---

## Documentation Protocol

### Phase 1: Code Analysis

Before writing docs, understand:
- Project purpose and scope
- Key features and capabilities
- Installation requirements
- Usage patterns
- API surface (if applicable)

### Phase 2: Audience Check

Who reads this?
- [ ] End users (focus: how to use)
- [ ] Developers (focus: how it works)
- [ ] Contributors (focus: how to modify)
- [ ] All of the above (layered docs)

### Phase 3: Generate

Follow these standards:
- Clear, concise language
- Code examples that actually work
- Accurate commands and paths
- Proper markdown formatting
- Version-aware (note which version docs apply to)

### Phase 4: Verify

- [ ] Code examples tested
- [ ] Links work
- [ ] Commands execute correctly
- [ ] Screenshots current (if included)

---

## Output Format (README Example)

```markdown
# [Project Name]

> [One-line description]

[Badges: version, license, build status]

## What It Does

[2-3 sentence description]

## Quick Start

```bash
# Install
[command]

# Run
[command]
```

## Installation

### Prerequisites
- [Requirement 1]
- [Requirement 2]

### Steps
1. [Step 1]
2. [Step 2]

## Usage

### Basic Usage
```bash
[example]
```

### Configuration
[Table of config options]

## API Reference

[If applicable]

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

[License type] — see [LICENSE](LICENSE)
```

---

## Output Format (ARCHITECTURE Example)

```markdown
# Architecture

## Overview

[System diagram or description]

## Components

### [Component 1]
- **Purpose:** [what it does]
- **Location:** `path/to/code`
- **Dependencies:** [what it needs]

### [Component 2]
...

## Data Flow

[How data moves through the system]

## Key Decisions

[Why things are built this way]

## External Dependencies

| Dependency | Purpose | Version |
|------------|---------|---------|
| ... | ... | ... |
```
```

---

## ✅ Done When

- [ ] Documentation generated
- [ ] Code examples verified
- [ ] Formatting correct
- [ ] Ready for commit

---

## Related Prompts

- **Document decisions?** → [decision_record.md](decision_record.md)
- **Audit first?** → [audit.md](audit.md)
- **Understand code first?** → [explain_this.md](explain_this.md)
