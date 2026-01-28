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

Always load relevant experts for planning discussions — even quick brainstorms benefit from expert framing.

- Architecture/features → `marge-simpson/system/experts/engineering.md`
- Security considerations → `marge-simpson/system/experts/security.md`

> **Note:** This overrides AGENTS.md "Just-in-Time" guidance. For planning, load experts upfront.

### No Implementation Code
- **DO NOT** modify source code, configs, or scripts
- **DO NOT** run verification scripts  
- **DO NOT** begin implementation work

**DO create:**
- Plan documents using `feature_plan_template.md` → save to `marge-simpson/system/tracking/[feature]_PLAN.md`
- MS-#### ID for formal plans (architecture, large features)
- Entry in `marge-simpson/system/tracking/assessment.md` with Status: Planning

**Suggestions (no MS-ID needed):**
- Feature brainstorms → `marge-simpson/system/tracking/recommended_features.md`
- These are input for future work, not tracked work themselves
- When user approves a suggestion → then create MS-ID and add to tasklist

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

### When These Apply

**These checkpoints ONLY apply when:**
- User explicitly invokes planning mode ("PLANNING ONLY", "design discussion", etc.)
- User asks "what would it take to..." or "propose a solution"

**If user says "do X" without planning triggers → EXECUTE DIRECTLY. No checkpoint.**

### Major Changes (Planning Mode Only)

| Change Type | In Planning Mode |
|-------------|------------------|
| Architecture changes | Create plan first |
| Large refactors (>5 files) | Create plan first |
| Schema/database changes | Create plan first |
| API contract changes | Create plan first |
| New dependencies | Create plan first |
| Breaking changes | Create plan first |

### Plan Contents
1. **What** - Clear description of the change
2. **Why** - Business/technical justification
3. **How** - Implementation approach
4. **Risks** - What could go wrong
5. **Rollback** - How to undo if needed
6. **Effort** - Rough scope (files, complexity)

## Approving Suggestions

When user says "approve feature [N]" or "let's do feature [N]" from a recommendations doc:

1. Create new MS-#### ID for the approved feature
2. Add to `marge-simpson/system/tracking/tasklist.md` with appropriate priority
3. Add assessment entry with Status: Approved
4. If complex, create `[feature]_PLAN.md` using template
5. Proceed to implementation or wait for "proceed" signal

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
