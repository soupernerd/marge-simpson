# New Prompts — Expert-Designed Prompt Library

> **Version:** 1.0.0 | **Designed by:** Product, Design, Documentation, Implementation Experts
> 
> These prompts are designed to maximize value for both Regular Marge users (auditing/documenting/improving their projects) and Meta Marge users (evolving Marge itself).

---

## Philosophy

**The Spirit of Marge:**
- 📊 **Track everything** — Work has IDs, decisions have records, nothing is lost
- 🧠 **Experts guide the way** — Complex tasks bring in specialists  
- ✅ **Verify before claiming** — Evidence or it didn't happen
- 🔄 **Always evolving** — Each session makes the system better

---

## Prompt Tiers

| Tier | When to Use | Tracking | Time |
|------|-------------|----------|------|
| 🟢 **Lite** | Typos, quick fixes, questions | None | <5 min |
| 🟡 **Standard** | Features, bugs, audits | MS-#### IDs | 5-30 min |
| 🔴 **Deep** | Multi-phase audits, architecture | Full ceremony | 30+ min |

---

## Regular Marge Prompts (For Your Projects)

### 🚀 Getting Started
| Prompt | Purpose | Tier |
|--------|---------|------|
| [quick_start.md](quick_start.md) | First 5 minutes — understand your project | 🟢 Lite |
| [explain_this.md](explain_this.md) | Understand code without changing it | 🟢 Lite |

### 💬 Ask & Learn
| Prompt | Purpose | Tier |
|--------|---------|------|
| [ask.md](ask.md) | Questions, clarifications, research | 🟢 Lite |
| [review_code.md](review_code.md) | Code review with expert perspective | 🟡 Standard |

### 🔨 Do Work  
| Prompt | Purpose | Tier |
|--------|---------|------|
| [work.md](work.md) | Features, bugs, tasks — the workhorse | 🟡 Standard |
| [fix_this.md](fix_this.md) | Quick fix, minimal ceremony | 🟢 Lite |
| [hotfix.md](hotfix.md) | Emergency production fix | 🟡 Standard |
| [refactor.md](refactor.md) | Safe refactoring with rollback | 🟡 Standard |

### 🔍 Audit & Review
| Prompt | Purpose | Tier |
|--------|---------|------|
| [audit.md](audit.md) | System-wide review, find issues | 🟡 Standard |
| [test_audit.md](test_audit.md) | Test coverage analysis | 🟡 Standard |
| [dependency_audit.md](dependency_audit.md) | Outdated deps, security vulnerabilities | 🟡 Standard |
| [performance_audit.md](performance_audit.md) | Find bottlenecks, optimize | 🟡 Standard |

### 📝 Document
| Prompt | Purpose | Tier |
|--------|---------|------|
| [generate_docs.md](generate_docs.md) | Create README, API docs, architecture | 🟡 Standard |
| [decision_record.md](decision_record.md) | Capture architectural decisions | 🟡 Standard |

### 🎯 Plan
| Prompt | Purpose | Tier |
|--------|---------|------|
| [plan_feature.md](plan_feature.md) | Feature planning (no code) | 🟡 Standard |
| [suggest_features.md](suggest_features.md) | Brainstorm improvements | 🟢 Lite |

### 🔄 Session Management
| Prompt | Purpose | Tier |
|--------|---------|------|
| [resume.md](resume.md) | Continue where you left off | 🟢 Lite |
| [wrap_up.md](wrap_up.md) | End session, capture learnings | 🟢 Lite |

---

## Meta Marge Prompts (For Evolving Marge)

> Located in [meta_prompts/](meta_prompts/)

| Prompt | Purpose | Tier |
|--------|---------|------|
| [meta_prompts/deep_audit.md](meta_prompts/deep_audit.md) | Comprehensive Marge audit with loop | 🔴 Deep |
| [meta_prompts/prompt_audit.md](meta_prompts/prompt_audit.md) | Audit prompt quality and effectiveness | 🟡 Standard |
| [meta_prompts/expert_calibration.md](meta_prompts/expert_calibration.md) | Tune expert personas | 🟡 Standard |
| [meta_prompts/consistency_audit.md](meta_prompts/consistency_audit.md) | Ensure all prompts follow standards | 🟡 Standard |
| [meta_prompts/release.md](meta_prompts/release.md) | Prepare Marge for release | 🟡 Standard |
| [meta_prompts/evolve.md](meta_prompts/evolve.md) | Self-improvement protocol | 🔴 Deep |

---

## Quick Reference by Intent

```
"I want to..."
│
├─► UNDERSTAND something → explain_this.md, ask.md
├─► FIX something quick → fix_this.md
├─► FIX something urgent → hotfix.md  
├─► BUILD something new → work.md
├─► REVIEW code quality → audit.md, review_code.md
├─► FIND security issues → dependency_audit.md
├─► FIND performance issues → performance_audit.md
├─► IMPROVE test coverage → test_audit.md
├─► DOCUMENT the project → generate_docs.md
├─► PLAN a feature → plan_feature.md
├─► CONTINUE from yesterday → resume.md
└─► IMPROVE MARGE ITSELF → meta_prompts/
```

---

## Success Criteria

Every prompt includes:
- ✅ Clear mode badge (AUDIT / WORK / PLANNING)
- ✅ Time estimate
- ✅ Done-when checklist
- ✅ Expert loading guidance
- ✅ Verification step with evidence
- ✅ Related prompts

---

## Versioning

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-26 | 1.0.0 | Initial expert-designed prompt library |
