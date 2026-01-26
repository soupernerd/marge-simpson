# Quick Start — Your First 5 Minutes with Marge

> **Mode:** 🟢 LITE — Read-only discovery, no changes  
> **Time:** ~5 minutes  
> **Best for:** First session with a new project, understanding what Marge can do

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** DISCOVERY — Understand the project, make no changes.

---

## Your Task

I'm new to this project. Help me understand it in 5 minutes.

### Step 1: Project Overview
Analyze the project and tell me:
- What this project does (1-2 sentences)
- Primary language/framework
- Project structure (key folders and their purpose)
- Entry points (where does the code start?)

### Step 2: Key Files
Identify and briefly explain:
- Main configuration files
- Core business logic location
- Test location (if any)
- Documentation files

### Step 3: Current State
Quick health check:
- Any obvious issues? (broken imports, missing dependencies)
- Is there a README? Is it accurate?
- Any work in progress? (check ./system/tracking/ if exists)

### Step 4: What Marge Can Do
Based on this project, suggest:
- 3 things I should audit first
- 2 things I should document
- 1 quick win I could tackle today

---

## Output Format

```markdown
# Project: [Name]

## Overview
[1-2 sentence description]

## Tech Stack
- Language: [X]
- Framework: [X]
- Key dependencies: [X, Y, Z]

## Structure
```
[folder tree with explanations]
```

## Key Files
| File | Purpose |
|------|---------|
| ... | ... |

## Health Check
- ✅/⚠️/❌ [Issue or positive finding]

## Recommended Next Steps
1. **Audit:** [what]
2. **Audit:** [what]  
3. **Audit:** [what]
4. **Document:** [what]
5. **Document:** [what]
6. **Quick win:** [what] — why: [reason]
```

---

Do NOT create any tracking IDs. This is discovery only.
```

---

## ✅ Done When

- [ ] I understand what the project does
- [ ] I know where the main code lives
- [ ] I have a prioritized list of next steps

---

## Related Prompts

- **Ready to work?** → [work.md](work.md)
- **Want deeper understanding?** → [explain_this.md](explain_this.md)
- **Found issues?** → [audit.md](audit.md)
