# Tweet Content for Tomorrow

Session: January 22, 2026 — Marge System Evolution

---

## Topic 1: Breaking Up the Monolith (AGENTS.md → Modular System)

**What we did:**
Took a massive 500+ line AGENTS.md — one file that tried to be everything — and broke it into a proper architecture:

- `AGENTS.md` — now just 91 lines of core rules and routing
- `experts/` — 8 domain expert personas, loaded on-demand
- `workflows/` — 7 explicit workflow files (audit, work, planning, loop, etc.)
- `knowledge/` — 5 persistent memory types
- `prompt_examples/` — Ready-to-use templates

Each folder has an `_index.md` router. The AI reads the index to find what it needs, then loads ONLY that file.

**Why it matters:**
A 500-line prompt costs ~500 tokens every single request. Modular = load 50-100 lines of what's actually relevant. 5-10x cost reduction per interaction.

**Tweet options:**

> Before: One 500-line AGENTS.md file
> After: 91-line core + modular folders
> 
> experts/ → 8 specialists (load on-demand)
> workflows/ → 7 modes (load by intent)
> knowledge/ → persistent memory
> 
> Same capabilities. 5-10x fewer tokens per request.

---

> My AI assistant's "brain" was one giant file.
> 
> Refactored it into:
> - Core rules (91 lines)
> - Expert personas (8 files)
> - Workflow modes (7 files)
> - Memory system (5 files)
> 
> Each folder has an _index.md router.
> 
> The AI reads the map, not the entire territory.

---

> The hardest part of AI prompt engineering isn't writing prompts.
> 
> It's organizing them so you don't load everything every time.
> 
> Monolith → Modular changed my token costs by 5-10x.

---

> "But won't splitting files make the AI less capable?"
> 
> No. It makes it more focused.
> 
> Security task? Load security.md (1,200 tokens)
> Testing task? Load testing.md (800 tokens)
> 
> vs. loading everything (5,000+ tokens) and hoping it finds the relevant parts.

---

## Topic 2: Expert Routing System

**What we did:**
Created a keyword → file mapping system. When a task mentions "security" or "auth" or "GDPR", it routes to `security.md`. Mentions "test" or "coverage"? Routes to `testing.md`.

The `_index.md` has a lookup table and even estimates token costs per file.

**Why it matters:**
Instead of the AI guessing which expertise is relevant, the system tells it. Deterministic routing beats probabilistic reasoning.

**Tweet options:**

> Built a routing table for AI expertise:
> 
> | Keywords | File |
> |----------|------|
> | security, auth, GDPR | security.md |
> | test, coverage, e2e | testing.md |
> | deploy, CI/CD, docker | devops.md |
> 
> The AI reads the table, loads the right expert.
> 
> Stop hoping the model knows things. Tell it where to look.

---

> Every expert file in my framework includes:
> 
> - Persona name and seniority level
> - When to invoke them
> - Their specific expertise
> - Common questions they answer
> 
> It's like org charts for AI.

---

> "But won't the AI just figure out which expertise to use?"
> 
> Sure. After burning tokens on reasoning.
> 
> Or I can give it a lookup table and it burns zero.
> 
> Prompt engineering is just information architecture.

---

## Topic 3: Planning vs Building (Separation of Concerns)

**What we did:**
Created a hard separation between planning mode and execution mode. When user says "PLANNING ONLY" or "plan only", the AI loads `planning.md` which explicitly forbids code changes. It can analyze, design, propose — but not touch files.

This is enforced at the workflow level, not hoped-for behavior.

**Why it matters:**
AI assistants love to "help" by making changes. Sometimes you want a rubber duck, not a teammate with commit access. Planning mode gives you that.

**Tweet options:**

> Biggest behavioral change in my AI framework:
> 
> "PLANNING ONLY" mode.
> 
> The AI can analyze. It can design. It can propose.
> It cannot touch a single file.
> 
> Sometimes you need a thinking partner, not a coding partner.

---

> My AI assistant now has two gears:
> 
> 🔵 Planning mode: "Here's what I'd do and why"
> 🟢 Building mode: "Done. Here's the diff."
> 
> The magic phrase: "PLANNING ONLY"
> 
> Separation of concerns isn't just for code.

---

> The problem with AI coding assistants:
> 
> They're optimized to DO things.
> Sometimes you just want to THINK about things.
> 
> Added explicit planning mode. No file edits allowed.
> 
> It's like `--dry-run` for AI.

---

> "Why not just tell the AI not to make changes?"
> 
> Because that's a suggestion. I wanted a constraint.
> 
> planning.md explicitly says: "NO CODE CHANGES"
> 
> The workflow enforces the behavior. Hope is not a strategy.

---

## Topic 4: Workflow State Machine

**What we did:**
Created explicit workflow files for different interaction patterns:
- `work.md` — standard fix/add/change cycle
- `audit.md` — codebase review (generates multiple tasks)
- `planning.md` — design-only mode, no code changes
- `loop.md` — iterate until clean
- `session_start.md` / `session_end.md` — lifecycle management

Each workflow has entry signals, exit conditions, and what gets tracked.

**Why it matters:**
"Fix this bug" and "audit the codebase" are fundamentally different operations. Same AI, different workflow loaded.

**Tweet options:**

> My AI assistant has explicit workflow modes:
> 
> • work.md → single task, single ID
> • audit.md → discovery, multiple IDs generated  
> • planning.md → design only, NO code changes
> • loop.md → iterate until clean
> 
> The prompt doesn't change the model.
> The workflow changes the behavior.

---

> The decision tree in my AI's workflow index:
> 
> ```
> User message received
>   │
>   ├─ Just asking? → Answer, no ID
>   ├─ Wants work? → work.md
>   ├─ Wants audit? → audit.md → then work.md
>   └─ Task complete? → session_end.md
> ```
> 
> State machines aren't just for backends.

---

## Topic 4: Knowledge Persistence System

**What we did:**
Created a persistent knowledge layer that survives across sessions:
- `decisions.md` — strategic choices with rationale
- `patterns.md` — observed recurring behaviors
- `preferences.md` — stated user preferences (with strength levels)
- `insights.md` — discovered facts about the codebase
- `archive.md` — decayed/deprecated entries

Even built a `decay.ps1` script that identifies stale entries (>90 days).

**Why it matters:**
AI assistants forget everything between sessions. This makes them remember — without fine-tuning.

**Tweet options:**

> My AI assistant remembers things now:
> 
> decisions.md → "We chose Postgres because..."
> patterns.md → "User always asks for TypeScript"
> preferences.md → "Strong: no semicolons"
> insights.md → "The auth module is in /lib/auth"
> 
> Persistent memory without fine-tuning. Just markdown files.

---

> Built a "decay scanner" for my AI's memory:
> 
> - Entry not accessed in 90 days? → Flag for review
> - Weak preference + stale? → Auto-archive
> - Insight unverified? → Mark for re-checking
> 
> Memory should decay. Even artificial memory.

---

> Knowledge entries in my framework have metadata:
> 
> ```
> Last Accessed: 2026-01-15
> Strength: strong | medium | weak
> Source: user-stated | observed | inferred
> ```
> 
> Not all knowledge is equal. Track its provenance.

---

## Topic 5: Self-Testing AI Framework

**What we did:**
Built a 15-test self-test suite (`test-marge.ps1`) that validates:
- Required files exist
- PowerShell syntax is valid
- Bash syntax is valid (if available)
- Folder auto-detection works
- Scripts handle edge cases (like no tests to run)

The verification runner has ASCII art banners and formatted output.

**Why it matters:**
If your AI framework can't verify itself, how do you trust it to verify anything else?

**Tweet options:**

> My AI assistant framework has a self-test suite.
> 
> 15 tests that verify the framework isn't broken.
> 
> Because the cobbler's children shouldn't have broken shoes.

---

> test-marge.ps1 validates:
> 
> ✓ Required files exist
> ✓ Scripts have valid syntax
> ✓ Folder detection works
> ✓ Edge cases handled
> 
> Takes 3 seconds to run.
> 
> Catches hours of debugging when something drifts.

---

> Added ASCII art banners to all my verification scripts.
> 
> ```
>  __  __    _    ____   ____ _____
> |  \/  |  / \  |  _ \ / ___| ____|
> | |\/| | / _ \ | |_) | |  _|  _|
> | |  | |/ ___ \|  _ <| |_| | |___
> |_|  |_/_/   \_\_| \_\\____|_____|
> ```
> 
> Does it improve functionality? No.
> Does it spark joy? Yes.

---

## Topic 6: Dual-Folder Meta-Development

**What we did:**
Created a system where `marge_simpson/` is the production template and `meta_marge/` is a working copy for developing Marge itself.

A conversion script (`convert-to-meta.ps1`) copies and transforms ALL internal paths automatically. Even handles "dual-folder documentation" files that intentionally keep both names.

**Why it matters:**
When your tooling operates on the repo it lives in, you need isolation. Otherwise you're editing the editor while it's editing.

**Tweet options:**

> My AI framework has two copies of itself:
> 
> `marge_simpson/` — production template
> `meta_marge/` — dev environment for the framework itself
> 
> A script transforms 24 files, replacing all internal paths.
> 
> Meta-development requires meta-isolation.

---

> The convert-to-meta script:
> 
> 1. Copies the production folder
> 2. Transforms ALL text files (paths, references)
> 3. Resets work queues to clean state
> 4. Runs verification to confirm nothing broke
> 
> Takes 5 seconds. Catches path collisions before they happen.

---

> Edge case in my conversion script:
> 
> Some files (like README.md) intentionally document BOTH folders.
> 
> Solution: maintain a "dual-folder doc" list that gets skipped during transformation.
> 
> Not every reference is a bug.

---

## Topic 7: Feature Removal (Clean Delete)

**What we did:**
Removed two features entirely: `instructions_log.md` and `verify_logs/`. Traced references across 15+ files. Removed ~200 lines of dead code.

The system still verifies — it just outputs to console instead of saving log files.

**Why it matters:**
Features that seemed useful at design time became maintenance overhead. Clean deletion > deprecation warnings.

**Tweet options:**

> Deleted two features from my AI framework today.
> 
> instructions_log → gone
> verify_logs → gone  
> 
> 15 files edited. ~200 lines removed.
> 
> Tests still pass. The system still verifies. It just stopped hoarding logs.

---

> Dead code archaeology:
> 
> One deleted feature had tendrils in:
> - 6 scripts (Write-Log, tee commands)
> - 4 documentation files
> - 2 template files
> - 2 conversion scripts
> 
> grep is your friend. grep is your only friend.

---

## Topic 8: Scope Control Rules

**What we did:**
Added critical scope rules to prevent the AI from modifying itself during audits:

1. The marge folder is **excluded from audits** — it's the tooling, not the target
2. A conditional clause: "unless `meta_marge/` exists and is being used to update Marge"
3. The conversion script removes this clause for meta_marge (since meta_marge IS the target)

**Why it matters:**
Without scope control, an AI auditing a codebase would "fix" its own instructions. Recursive self-improvement sounds cool until it's a bug.

**Tweet options:**

> Most important line in my AI framework's rules:
> 
> "The marge_simpson/ folder is **excluded from audits** — it is the tooling, not the target."
> 
> Without this, the AI would "improve" its own instructions during codebase reviews.
> 
> Scope control isn't optional.

---

> Added a conditional clause to my AI's scope rules:
> 
> "excluded from audits... unless `meta_marge/` exists and is being used to update Marge"
> 
> The meta version intentionally removes this clause.
> 
> Same rules. Different scope. Context-aware behavior.

---

## Topic 9: Token Cost Awareness

**What we did:**
Added token estimation to every response and created `model_pricing.json` with per-model costs. The expert index even shows estimated tokens per file.

**Why it matters:**
AI costs money. Every token loaded is a choice. Making costs visible changes behavior.

**Tweet options:**

> Every response from my AI framework ends with:
> 
> `📊 ~In: 2,400 | Out: 890 | Est: $0.0142`
> 
> Making costs visible changes behavior.
> 
> You wouldn't ignore your AWS bill. Don't ignore token spend.

---

> My expert index shows token estimates:
> 
> | File | Experts | Est. Tokens |
> |------|---------|-------------|
> | architecture.md | 2 | ~800 |
> | security.md | 3 | ~1,200 |
> | product.md | 4 | ~1,600 |
> 
> Load what you need. Know what it costs.

---

## Bonus: Thread Openers

> Spent today evolving my AI assistant framework.
> 
> Started as one 500-line file. Now it's:
> - 8 expert personas
> - 7 workflow modes
> - 5 knowledge types
> - 15-test self-verification
> - Dual-folder meta-development
> 
> Thread on what "AI memory" looks like without fine-tuning 🧵

---

> "How do you make an AI assistant remember things?"
> 
> Option 1: Fine-tuning ($$$, slow, risky)
> Option 2: Vector databases (complex, overkill for most)
> Option 3: Markdown files with structure
> 
> I chose option 3. Here's the architecture 🧵

---

## Raw Stats

- AGENTS.md: 500+ lines → 91 lines (core rules only)
- Expert files: 8 domain specialists
- Workflow files: 7 explicit modes
- Knowledge files: 5 persistence types
- Scripts: 10 (verify, test, cleanup, decay, status, convert × 2 platforms)
- Tests: 15 passing
- Files in full system: 50+
- Lines removed (dead code): ~200
- Total refactor time: Multiple sessions
