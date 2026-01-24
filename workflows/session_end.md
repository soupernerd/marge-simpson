# Session End Workflow

> Knowledge capture and memory evolution after delivering user's work.
> Implements the "memory is infrastructure, not a feature" principle.

## When to Run

- After completing MS-#### tasks
- When user says thanks, goodbye, or conversation ends
- After significant discussions (even without formal tasks)
- **Before starting fresh** — long sessions (50+ exchanges) benefit from knowledge capture before restarting

**Do NOT run during active work.** Finish the user's request first.

### Why Start Fresh Sometimes?
Very long conversations accumulate context that can degrade reasoning quality. If you notice:
- Repeated misunderstandings
- Circular discussions
- Forgotten earlier decisions

Consider: Capture knowledge → Start new conversation → Reference captured knowledge.

---

## Phase 0: Check If Knowledge Needs Seeding (First-Time Setup)

Before extracting new facts, check if knowledge files are empty:

```powershell
# Check entry counts in _index.md
Select-String -Path "marge-simpson/knowledge/_index.md" -Pattern "entries$"
```

If all counts show 0, this is a fresh installation. Consider seeding with:

1. **Project defaults** — Common decisions visible in codebase:
   - Language/framework choices (visible in package.json, requirements.txt, etc.)
   - Code style decisions (visible in linter configs)
   - Architecture patterns (visible in folder structure)

2. **Inferred user preferences** — From this session's interactions:
   - Communication style (verbose vs concise)
   - Level of detail requested
   - Testing preferences (TDD vs test-after)

3. **Workspace insights** — Observable facts about the codebase:
   - Major modules/services discovered
   - Key entry points identified
   - Non-obvious dependencies noticed

**Seed 2-3 entries per category max.** Seeding is bootstrapping, not comprehensive documentation.

---

## Phase 1: Extract Atomic Facts

Scan the session and extract **discrete, standalone facts**:

| Fact Type | Example | File |
|-----------|---------|------|
| User stated preference | "I prefer tabs over spaces" | `preferences.md` |
| Technical decision made | "Using PostgreSQL for persistence" | `decisions.md` |
| Repeated behavior (2+ times) | User always asks for tests first | `patterns.md` |
| Discovered codebase info | "Auth module uses JWT refresh tokens" | `insights.md` |

**Extract 3-5 facts per session.** Quality over quantity.

---

## Phase 2: Check for Conflicts (CRITICAL)

Before adding new facts, **check if they conflict with existing entries**:

```powershell
# Quick search for potential conflicts
Select-String -Path "marge-simpson/knowledge/*.md" -Pattern "keyword1|keyword2"
```

### Conflict Resolution Rules

| Scenario | Action |
|----------|--------|
| **New info supersedes old** | Update existing entry, add `Updated: YYYY-MM-DD` |
| **Context changed** (e.g., switched jobs) | Archive old entry, add new one with context |
| **Contradiction unclear** | Ask user to clarify before storing |
| **Same fact, stronger evidence** | Increase confidence/strength level |

**Example conflict resolution:**
```markdown
### [PR-003] Preferred language #code-style
- **Stated:** 2026-01-10
- **Updated:** 2026-01-19 (switched from Python to Rust)
- **Strength:** Strong
- **Preference:** Rust for new projects
- **Previous:** Python (archived to PR-003-old)
```

---

## Phase 3: Write or Update Entries

### Adding NEW entry
1. Use next available ID (D-###, PR-###, P-###, I-###)
2. Add to appropriate file
3. Include timestamp

### Updating EXISTING entry
1. Add `Updated: YYYY-MM-DD` field
2. Preserve original `Stated/Observed` date
3. Note what changed in entry

### Entry Formats

**Decision (D-###):**
```markdown
### [D-###] Short title #tag1 #tag2
- **Date:** YYYY-MM-DD
- **Last Accessed:** YYYY-MM-DD
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Alternatives:** What else was considered
- **Rationale:** Why this option
```

**Preference (PR-###):**
```markdown
### [PR-###] Short description #tag1 #tag2
- **Stated:** YYYY-MM-DD
- **Last Accessed:** YYYY-MM-DD
- **Strength:** Weak / Moderate / Strong
- **Preference:** What the user prefers
- **Exceptions:** When this doesn't apply
- **Quote:** Direct quote if available
```

**Pattern (P-###):**
```markdown
### [P-###] Short title #tag1 #tag2
- **Observed:** YYYY-MM-DD
- **Last Accessed:** YYYY-MM-DD
- **Frequency:** always / usually / sometimes
- **Pattern:** Description
- **Example:** Concrete example
```

**Insight (I-###):**
```markdown
### [I-###] Short description #tag1 #tag2
- **Observed:** YYYY-MM-DD
- **Last Accessed:** YYYY-MM-DD
- **Confidence:** Low / Medium / High
- **Insight:** What was inferred
- **Evidence:** What led to this
- **Verified:** [ ] User has confirmed
```

---

## Phase 4: Update Index

After adding/updating entries, update `marge-simpson/knowledge/_index.md`:

1. **Quick Stats** — increment/update counts
2. **Recent Entries** — add new entries (keep last 5, remove oldest)
3. **Tag Index** — add any new tags with counts

---

## Phase 5: Memory Decay Check

Entries should decay over time. Check for stale entries based on **Last Accessed**:

| Condition | Action |
|-----------|--------|
| Last Accessed > 90 days | Flag for review |
| Insight unverified > 60 days | Mark for user verification |
| Weak preference + Last Accessed > 90 days | Archive |
| Pattern not observed recently | Reduce frequency or archive |
| Decision superseded | Archive with reason |

### Archiving Process
1. Move entry to `marge-simpson/knowledge/archive.md`
2. Add: `Archived: YYYY-MM-DD | Reason: <reason>`
3. Decrement count in index
4. Remove from Recent Entries if present

---

## Output (Minimal)

If knowledge was captured, note briefly:

```
---
📝 Knowledge: PR-007 added (prefers functional), D-003 updated (switched to Postgres)
```

Keep this minimal — user's work is the main output.
