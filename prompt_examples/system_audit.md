Read the AGENTS.md file in this folder and follow it.

**AUDIT MODE** - Read-only analysis, no code changes.

1. **Understand the system**
   - Read meta/ARCHITECTURE.md (if exists) and key files
   - Map the major components, workflows, and data flows
   - Identify the intended behavior and design patterns

2. **Identify issues** (prioritize by impact)
   - P0: Correctness bugs, security risks, data loss potential
   - P1: Reliability issues, error handling gaps, test coverage
   - P2: Code quality, maintainability, performance concerns

3. **Update tracking docs**
   - marge-simpson/planning_docs/assessment.md → System snapshot + findings + new MS-#### issues
   - marge-simpson/planning_docs/tasklist.md → Prioritized tasks with DoD + verification steps

4. **Report**
   - List all MS-#### IDs created
   - Show unchecked items from tasklist.md (P0 → P1 → P2)
   - Suggest order of operations

Output using the Response Format from AGENTS.md, with detailed info on each ms-00xx, in table format.