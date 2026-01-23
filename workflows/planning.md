# Planning Workflow

> For design discussions, architecture proposals, and strategic planning without code changes.

## Activation Triggers

When the user's message includes:
- "PLANNING ONLY"
- "no code changes"
- "just brainstorm"
- "design discussion"
- "architecture review"
- "what would it take to..."
- "propose a solution for..."

## Planning Mode Rules

### No Code Changes
- **DO NOT** modify any files
- **DO NOT** run verification scripts
- **DO NOT** create MS-#### work items

### Focus On
- Analysis and exploration
- Architecture proposals
- Pros/cons evaluation
- Risk assessment
- Effort estimation (rough)
- Alternative approaches

## Planning Response Format

```
## Planning: [Topic]

### Current State
- What exists now
- Key constraints

### Proposed Approach
- Option A: [Description]
  - Pros: ...
  - Cons: ...
  - Effort: Low/Medium/High

- Option B: [Description]
  - Pros: ...
  - Cons: ...
  - Effort: Low/Medium/High

### Recommendation
[Which option and why]

### Next Steps (if approved)
1. First step
2. Second step
3. ...

### Open Questions
- Question 1?
- Question 2?
```

## Checkpoint Rules

### Major Changes Requiring Planning
Before these changes, stop and request approval:

| Change Type | Requires Plan |
|-------------|---------------|
| Architecture changes | Yes |
| Large refactors (>5 files) | Yes |
| Schema/database changes | Yes |
| API contract changes | Yes |
| New dependencies | Yes |
| Breaking changes | Yes |

### Plan Contents
1. **What** - Clear description of the change
2. **Why** - Business/technical justification
3. **How** - Implementation approach
4. **Risks** - What could go wrong
5. **Rollback** - How to undo if needed
6. **Effort** - Rough scope (files, complexity)

## Transitioning to Work

When planning is approved and user says "proceed" or "implement":

1. Create MS-#### work items in tasklist.md
2. Switch to `workflows/work.md` process
3. Reference the planning discussion in work items

## Examples

### Planning Request
User: "What would it take to add multi-tenant support?"

Response: Full planning analysis, no code changes, no work IDs.

### Planning to Work Transition
User: "The plan looks good, proceed with Option B"

Response: Create MS-#### items, begin implementation following work.md.

## Token Cost

~600 tokens when read
