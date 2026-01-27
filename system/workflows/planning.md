# Planning Workflow

> For design discussions, architecture proposals, and strategic planning. Creates plan documents, not implementation code.

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

### Expert Consultation (Required)
Bring in relevant experts for planning discussions:
- Architecture planning → `marge-simpson/system/experts/engineering.md`
- Security considerations → `marge-simpson/system/experts/security.md`

### No Implementation Code
- **DO NOT** modify source code, configs, or scripts
- **DO NOT** run verification scripts  
- **DO NOT** begin implementation work

**DO create:**
- Plan documents using `feature_plan_template.md` → save to `marge-simpson/system/tracking/[feature]_PLAN.md`
- MS-#### ID for the plan itself (plan tracking, not implementation tasks)
- Entry in `marge-simpson/system/tracking/assessment.md` with Status: Planning

### Focus On
- Analysis and exploration
- Architecture proposals
- Pros/cons evaluation
- Risk assessment
- Effort estimation (rough)
- Alternative approaches

## Planning Response Format

**Feature planning:** Use the template `marge-simpson/system/tracking/feature_plan_template.md`

**Quick brainstorming:** Use inline format:

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

1. Update plan's MS-#### status to "Approved" in `marge-simpson/system/tracking/assessment.md`
2. Create implementation tasks (sub-IDs) in `marge-simpson/system/tracking/tasklist.md`
3. Switch to `marge-simpson/system/workflows/work.md` process

## Examples

### Planning Request
User: "What would it take to add multi-tenant support?"

Response: Create MS-####, write plan using template, full analysis. No implementation.

### Planning to Work Transition
User: "The plan looks good, proceed with Option B"

Response: Update MS-#### status, create implementation tasks, begin work.md.

## Token Cost

~600 tokens when read
