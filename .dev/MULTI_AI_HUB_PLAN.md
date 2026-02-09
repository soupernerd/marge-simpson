# Multi-AI Collaboration Hub — Planning Document

> **Goal**: Build a system where multiple AI assistants (GPT-4, Claude, Gemini, local models, etc.) can automatically discuss, deliberate, critique, and reach consensus on problems—without manual prompting.

---

## 🎯 Vision

**User Experience:**
1. User inputs a problem/vision
2. System automatically:
   - Distributes the problem to multiple AI agents
   - Each agent proposes solutions
   - Agents read and critique each other's work
   - Debate continues until consensus is reached
   - Agents decide who implements what
   - Implementation proceeds (optionally)

**Key Differentiator from your previous workflow:**
- **Before**: Manual prompting loop ("read what ChatGPT said, then respond")
- **After**: Automatic orchestration with configurable discussion protocols

---

## 🏗️ Architectural Options

### Option 1: Build on OpenClaw (Recommended)

**Why OpenClaw is ideal for your use case:**

OpenClaw already has the exact primitives you need:

| Feature | OpenClaw Capability |
|---------|---------------------|
| Multi-model support | ✅ GPT-4, Claude, Gemini, local models via Ollama |
| Agent-to-Agent messaging | ✅ `sessions_send` with automatic ping-pong |
| Agent spawning | ✅ `sessions_spawn` for creating sub-agents |
| Shared workspace | ✅ File system access, persistent memory |
| Consensus detection | ⚠️ Would need to be built on top |
| Task assignment | ⚠️ Would need to be built on top |

**Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                     YOUR MULTI-AI HUB                           │
│         (Orchestration layer built on OpenClaw)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │ Deliberation │    │  Consensus   │    │    Task      │      │
│  │   Protocol   │    │   Detector   │    │  Assigner    │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                     OPENCLAW GATEWAY                            │
│            (WebSocket control plane @ 127.0.0.1:18789)          │
├──────────┬──────────┬──────────┬──────────┬────────────────────┤
│  Agent   │  Agent   │  Agent   │  Agent   │      Shared        │
│  Claude  │  GPT-4   │  Gemini  │  Ollama  │    Workspace       │
│  ────────│──────────│──────────│──────────│                    │
│ session: │ session: │ session: │ session: │  /deliberations/   │
│ "claude" │ "gpt4"   │ "gemini" │ "local"  │  /consensus/       │
└──────────┴──────────┴──────────┴──────────┴────────────────────┘
```

**How it would work:**

1. **User submits problem** via WebChat, CLI, or API
2. **Orchestrator** (your layer) distributes to all agent sessions
3. **Each agent** writes their proposal to shared workspace (e.g., `/workspace/proposals/claude.md`)
4. **Orchestrator** uses `sessions_send` to tell each agent: "Read and critique the other proposals"
5. **Agents** use the built-in ping-pong mechanism (up to `maxPingPongTurns: 5`) to debate
6. **Consensus Detector** (your layer) monitors for agreement signals
7. **Task Assigner** (your layer) breaks down implementation and assigns to agents

**Implementation effort:** Medium (~2-3 weeks)
- OpenClaw provides 80% of the infrastructure
- You build the orchestration logic, consensus detection, and UI

---

### Option 2: Custom Python/TypeScript Wrapper

**Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR MULTI-AI HUB                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    ORCHESTRATOR                           │  │
│  │  - Turn management                                        │  │
│  │  - Context aggregation                                    │  │
│  │  - Consensus detection                                    │  │
│  │  - Task assignment                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  UNIFIED API LAYER                        │  │
│  │                                                           │  │
│  │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │  │
│  │   │ OpenAI  │  │Anthropic│  │ Google  │  │ Ollama  │    │  │
│  │   │   API   │  │   API   │  │   API   │  │  Local  │    │  │
│  │   └─────────┘  └─────────┘  └─────────┘  └─────────┘    │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                SHARED WORKSPACE                           │  │
│  │   /proposals/  /critiques/  /consensus/  /implementation/ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pros:**
- Full control over every aspect
- No external dependencies (except API keys)
- Can integrate with your existing Marge system

**Cons:**
- More code to write and maintain
- Need to handle all the WebSocket/session management yourself
- Reinventing what OpenClaw already provides

**Implementation effort:** High (~4-6 weeks)

---

### Option 3: Use Existing Multi-Agent Frameworks

| Framework | Best For | Agent-to-Agent | Multi-Provider |
|-----------|----------|----------------|----------------|
| **AutoGen** (Microsoft) | Enterprise, complex workflows | ✅ Built-in | ✅ Any LLM |
| **CrewAI** | Role-based teams | ✅ Built-in | ✅ Any LLM |
| **LangGraph** | Graph-based workflows | ✅ Built-in | ✅ Any LLM |
| **OpenClaw** | Personal AI assistant | ✅ Built-in | ✅ Any LLM |

**My recommendation:** OpenClaw (Option 1) because:
1. It already has Agent-to-Agent (`sessions_send` with ping-pong)
2. It's TypeScript (modern, type-safe)
3. Multi-model support built-in
4. Active development
5. You specifically mentioned it

---

## 🔧 OpenClaw-Based Implementation Plan

### Phase 1: Foundation (Week 1)

**Goal:** Get OpenClaw running with multiple model sessions

1. **Install OpenClaw**
   ```bash
   npm install -g openclaw
   openclaw init
   ```

2. **Configure multiple agents** in `openclaw.yaml`:
   ```yaml
   agents:
     list:
       - id: claude
         model: claude-sonnet-4-20250514
         description: "Claude agent - excels at analysis and nuance"
       - id: gpt4
         model: gpt-4-turbo
         description: "GPT-4 agent - strong at broad knowledge"
       - id: gemini
         model: gemini-2.0-flash
         description: "Gemini agent - multimodal strengths"
       - id: local
         model: ollama/deepseek-r1:8b
         description: "Local model - private, fast"
   ```

3. **Set up multi-agent routing**:
   ```yaml
   gateway:
     configuration:
       agentToAgent:
         maxPingPongTurns: 10  # Allow longer debates
   ```

### Phase 2: Deliberation Protocol (Week 2)

**Goal:** Create the orchestration layer that automates discussions

Create a **skill** that implements the deliberation protocol:

```
/.openclaw/skills/deliberation/
├── skill.yaml
├── protocol.ts      # Deliberation logic
├── consensus.ts     # Consensus detection
└── templates/
    ├── initial_prompt.md
    ├── critique_prompt.md
    └── consensus_check.md
```

**Deliberation Skill Logic:**

```typescript
// protocol.ts (pseudocode)
interface DeliberationConfig {
  problem: string;
  agents: string[];          // ["claude", "gpt4", "gemini"]
  maxRounds: number;         // Max discussion rounds
  consensusThreshold: number; // e.g., 0.8 = 80% agreement
  workspace: string;         // Shared file path
}

async function runDeliberation(config: DeliberationConfig) {
  // Phase 1: Initial Proposals
  for (const agent of config.agents) {
    await sessions_spawn({
      agentId: agent,
      task: `
        Problem: ${config.problem}
        
        Write your proposed solution to: ${config.workspace}/${agent}_proposal.md
        
        Format:
        ## Summary
        ## Approach
        ## Tradeoffs
        ## Implementation Steps
      `
    });
  }
  
  // Phase 2: Cross-Critique
  for (const critic of config.agents) {
    const others = config.agents.filter(a => a !== critic);
    await sessions_send({
      sessionKey: critic,
      message: `
        Read the proposals from: ${others.map(a => `${config.workspace}/${a}_proposal.md`).join(', ')}
        
        Write your critique to: ${config.workspace}/${critic}_critique.md
        
        For each proposal:
        - Strengths
        - Weaknesses
        - What you'd adopt
        - What you'd change
      `
    });
  }
  
  // Phase 3: Consensus Building
  let round = 0;
  let consensus = false;
  
  while (!consensus && round < config.maxRounds) {
    round++;
    
    // Each agent synthesizes and proposes unified solution
    for (const agent of config.agents) {
      await sessions_send({
        sessionKey: agent,
        message: `
          Read all proposals and critiques in ${config.workspace}/
          
          Propose a unified solution that addresses the critiques.
          Write to: ${config.workspace}/round_${round}/${agent}_synthesis.md
          
          If you agree with another agent's synthesis, explicitly state:
          "CONSENSUS: I agree with [agent]'s synthesis"
        `
      });
    }
    
    // Check for consensus
    consensus = await checkConsensus(config.workspace, round, config.agents);
  }
  
  // Phase 4: Task Assignment
  if (consensus) {
    await sessions_send({
      sessionKey: config.agents[0], // Lead agent
      message: `
        Based on the consensus solution in ${config.workspace}/
        
        Assign implementation tasks to each agent based on their strengths:
        - Claude: [tasks]
        - GPT-4: [tasks]
        - Gemini: [tasks]
        
        Write task assignments to: ${config.workspace}/task_assignments.md
      `
    });
  }
}
```

### Phase 3: User Interface (Week 3)

**Goal:** Make it easy for users to trigger and monitor deliberations

**Option A: CLI Extension**
```bash
openclaw deliberate "How should we architect a real-time chat system?" \
  --agents claude,gpt4,gemini \
  --max-rounds 5 \
  --output ./deliberations/chat-architecture/
```

**Option B: WebChat Trigger**
```
User: /deliberate How should we architect a real-time chat system?
```

**Option C: Web Dashboard** (most polished)
- Problem input form
- Real-time view of agent discussions
- Visual consensus meter
- Implementation tracking

---

## 📋 Marge Simpson Integration

Your existing Marge system has valuable patterns that could enhance this:

| Marge Feature | How to Use |
|---------------|------------|
| **Expert System** (`system/experts/`) | Assign different "expert personas" to different model agents |
| **Tracking** (`system/tracking/`) | Track deliberation progress, findings, task completion |
| **Workflows** (`system/workflows/`) | Define the deliberation workflow as a Marge workflow |
| **Knowledge** (`system/knowledge/`) | Store consensus decisions, patterns discovered |

**Hybrid Architecture:**

```
User Input
    │
    ▼
┌─────────────────────────────────────────┐
│         DELIBERATION HUB                │
│    (OpenClaw + Custom Orchestration)    │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┐
    ▼            ▼            ▼
┌────────┐  ┌────────┐  ┌────────┐
│ Claude │  │ GPT-4  │  │ Local  │
│   +    │  │   +    │  │   +    │
│ Marge  │  │ Marge  │  │ Marge  │
│ Expert │  │ Expert │  │ Expert │
└────────┘  └────────┘  └────────┘
```

Each agent could load relevant Marge expert files to enhance their specialized role.

---

## 🎬 Quick Start Path

**If you want to get started TODAY:**

1. **Install OpenClaw:**
   ```powershell
   npm install -g openclaw
   openclaw init
   openclaw gateway
   ```

2. **Configure 2 agents** (start simple):
   ```yaml
   # ~/.openclaw/openclaw.yaml
   agents:
     list:
       - id: claude
         model: claude-sonnet-4-20250514
       - id: gpt4
         model: gpt-4-turbo
   ```

3. **Test Agent-to-Agent:**
   ```
   # In WebChat to Claude:
   "Use sessions_send to ask the GPT-4 agent: What's the best approach to solving [problem]?"
   ```

4. **Add orchestration** once basic A2A works

---

## 🤔 Questions to Clarify

Before we dive into implementation, let me know:

1. **Priority**: Do you want to start with OpenClaw (fastest path) or build custom (more control)?

2. **Scope**: Just discussion/consensus, or also automated implementation?

3. **Models**: Which providers do you have access to? (OpenAI, Anthropic, Google, local?)

4. **Integration**: Keep Marge separate, or merge into a unified system?

5. **Interface**: CLI-first, web dashboard, or both?

---

## 📚 Resources

- **OpenClaw Docs**: https://docs.openclaw.ai/
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **Session Tools (Agent-to-Agent)**: https://docs.openclaw.ai/concepts/session-tool
- **AutoGen (alternative)**: https://microsoft.github.io/autogen/
- **CrewAI (alternative)**: https://www.crewai.com/
