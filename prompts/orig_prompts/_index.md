# Prompt Examples Index

> Copy-paste templates for common prompting scenarios. Use these to get started quickly.

## Quick Reference

| Intent | File | Description |
|--------|------|-------------|
| Bug fix, new feature, issue | [features_and_issues.md](features_and_issues.md) | Work items with tracking |
| General instructions | [misc_instruction.md](misc_instruction.md) | Custom instructions |
| Mixed request (questions + work) | [multiple_prompts.md](multiple_prompts.md) | Multiple intent types |
| Questions or confirmations | [questions_confirmations.md](questions_confirmations.md) | Ask, verify, confirm |
| Codebase audit | [system_audit.md](system_audit.md) | Full system review |
| Brainstorm features | [suggest_features.md](suggest_features.md) | PLANNING ONLY mode |

## When to Use Each

- **Starting work?** → `features_and_issues.md`
- **Questions only?** → `questions_confirmations.md`  
- **Want ideas, no code?** → `suggest_features.md`
- **Full review?** → `system_audit.md`
- **Multiple things?** → `multiple_prompts.md`

## Advanced (for Marge contributors)

See `prompts/for_meta/` for specialized prompts used in developing Marge itself:
- `deep_system_audit.md` — Subagents + loop + experts
- `path_integrity_audit.md` — All paths + workflows + orphans
- `pro_prompts/` — Extended versions with more detail
