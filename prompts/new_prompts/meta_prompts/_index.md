# Meta Marge Prompts — For Evolving Marge Itself

> **Version:** 1.0.0 | **Purpose:** Self-improvement prompts for Marge contributors
> 
> These prompts target `.meta_marge/` and improve Marge's core capabilities.

---

## Philosophy

**Meta Marge's Purpose:**
- 🔄 **Continuous evolution** — Every run makes Marge better
- 🎯 **Expert-driven** — Specialists audit and improve
- 📊 **Measurable** — Track what works, deprecate what doesn't
- 🛡️ **Safe** — Changes don't break existing functionality

---

## Available Prompts

| Prompt | Purpose | Tier |
|--------|---------|------|
| [deep_audit.md](deep_audit.md) | Comprehensive Marge audit with loop | 🔴 Deep |
| [prompt_audit.md](prompt_audit.md) | Audit prompt quality and effectiveness | 🟡 Standard |
| [expert_calibration.md](expert_calibration.md) | Tune expert personas | 🟡 Standard |
| [consistency_audit.md](consistency_audit.md) | Ensure prompts follow standards | 🟡 Standard |
| [release.md](release.md) | Prepare Marge for release | 🟡 Standard |
| [evolve.md](evolve.md) | Self-improvement protocol | 🔴 Deep |

---

## When to Use Meta Prompts

| Goal | Prompt |
|------|--------|
| Regular health check | deep_audit.md |
| Prompts feeling stale? | prompt_audit.md |
| Experts giving bad advice? | expert_calibration.md |
| Inconsistent experiences? | consistency_audit.md |
| Ready to release? | release.md |
| Make Marge fundamentally better | evolve.md |

---

## Setup Reminder

Before using meta prompts, ensure you're targeting `.meta_marge/`:

```bash
# Initialize meta_marge if not exists
marge meta init

# Or manually:
# Copy marge-simpson to .meta_marge/
# Work in .meta_marge/ context
```

All prompts reference `./` which means `.meta_marge/` when run in meta context.
