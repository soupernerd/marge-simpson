# Meta-Development Prompts

> Specialized prompts for developing/improving Marge itself.  
> For general project use, see the parent `prompts/` folder.

## When to Use

These are for **Marge contributors** who want to:
- Audit the marge-simpson codebase
- Improve CLI, workflows, or documentation
- Deep-dive into path integrity after restructures

## Available Prompts

| Prompt | Purpose | Mode |
|--------|---------|------|
| [deep_system_audit.md](deep_system_audit.md) | Comprehensive audit + loop + experts | AUDIT + LOOP |
| [path_integrity_audit.md](path_integrity_audit.md) | All paths + cross-validation + orphans | AUDIT |
| [suggest_features.md](suggest_features.md) | Feature proposals for Marge | PLANNING ONLY |

## Usage

1. Set up `.meta_marge/` first:
   ```bash
   marge meta init
   # Or: ./.dev/meta/convert-to-meta.sh
   ```
2. Use prompts with: "Read the AGENTS.md file in the `.meta_marge` folder..."
3. Work is tracked in `.meta_marge/system/tracking/`



