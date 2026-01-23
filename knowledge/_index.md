# Knowledge Index

> **DO NOT read knowledge files directly.** Grep for tags/keywords first, then read only matching entries.

## How to Use

1. Identify what you're looking for (topic, tag, ID)
2. Grep the relevant file(s) for matches
3. Read only the specific matching entry/entries

**Example:**
```powershell
# Find decisions about authentication
Select-String -Path "knowledge/decisions.md" -Pattern "#auth"

# Find all entries tagged with typescript
Select-String -Path "knowledge/*.md" -Pattern "#typescript"
```

---

## Quick Stats
- **Decisions:** 0 entries
- **Patterns:** 0 entries
- **Preferences:** 0 entries
- **Insights:** 0 entries

---

## Recent Entries (last 5)
_None yet_

---

## Tag Index

| Tag | File(s) | Count |
|-----|---------|-------|
| _No entries yet_ | - | 0 |

---

## File Reference

| File | Purpose | When to Add |
|------|---------|-------------|
| [decisions.md](decisions.md) | Strategic choices with rationale | After making architecture/tech decisions |
| [patterns.md](patterns.md) | Recurring behaviors observed | After noticing repeated user preferences |
| [preferences.md](preferences.md) | User's stated preferences | When user expresses how they like things done |
| [insights.md](insights.md) | Learned facts about codebase | After discovering non-obvious codebase info |
| [archive.md](archive.md) | Pruned entries (historical) | When entry meets prune criteria |

---

## Entry ID Formats

- `D-###` - Decisions
- `P-###` - Patterns
- `PR-###` - Preferences
- `I-###` - Insights

---

## Maintenance

**When adding entries:**
1. Add to the appropriate category file
2. Update this index:
   - Increment Quick Stats count
   - Add to Recent Entries (keep last 5)
   - Update Tag Index

**Quarterly review:**
- Archive entries older than 6 months to `knowledge/archive.md`
- Review and merge duplicate/similar entries
