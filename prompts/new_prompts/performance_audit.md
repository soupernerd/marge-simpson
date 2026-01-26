# Performance Audit — Find and Fix Bottlenecks

> **Mode:** 🟡 STANDARD — Analysis with optimization focus  
> **Time:** ~20-30 minutes  
> **Best for:** Slow applications, scaling prep, optimization sprints

---

## The Prompt

Copy everything below the line:

---

```
Read the AGENTS.md file in the marge-simpson folder and follow it.

**MODE:** AUDIT — Identify performance issues and optimization opportunities.

---

## Expert Loading (Required)

Load from ./system/experts/_index.md:
- architecture.md (for system-level issues)
- implementation.md (for code-level optimizations)
- devops.md (for infrastructure/deployment)

---

## Performance Context

### Symptoms (what's slow?)

(Delete examples, replace with yours)

- "Page load takes 8+ seconds"
- "API response time > 2s"
- "Memory usage keeps growing"
- "High CPU during [operation]"

Your symptoms:
- 

### Constraints

- Target response time: [e.g., <200ms]
- Budget for changes: [small/medium/large refactor OK?]
- Environment: [production/staging/local]

---

## Audit Protocol

### Phase 1: Measure Baseline

Before optimizing, establish:
- Current response times
- Resource usage (CPU, memory, network)
- User-impacting metrics

### Phase 2: Code-Level Analysis

Look for:

| Issue Type | Signs | Example |
|------------|-------|---------|
| **N+1 queries** | Loop with DB calls | `users.forEach(u => getOrders(u.id))` |
| **Missing indexes** | Slow queries, full scans | `WHERE status = 'active'` without index |
| **Blocking I/O** | Sequential async calls | `await a(); await b();` vs `Promise.all` |
| **Memory leaks** | Growing memory, no release | Event listeners not removed |
| **Expensive re-renders** | UI jank, high CPU | Missing memoization |
| **Large payloads** | Slow network, big JSON | Returning entire objects vs needed fields |
| **Synchronous processing** | Blocked event loop | Heavy computation in request handler |

### Phase 3: Architecture-Level Analysis

Look for:
- Caching opportunities (frequently read, rarely changed data)
- Denormalization needs (complex joins on every request)
- Queue candidates (work that doesn't need immediate response)
- CDN opportunities (static assets, geographically distributed users)

### Phase 4: Prioritize

Rank by impact × effort:

| Issue | Impact | Effort | Priority |
|-------|--------|--------|----------|
| Add DB index | 🔴 High | 🟢 Low | **DO FIRST** |
| Rewrite module | 🟡 Med | 🔴 High | Maybe later |

---

## Output Format

```markdown
## Performance Audit — [Date]

### Current State
| Metric | Value | Target | Gap |
|--------|-------|--------|-----|
| Page load | 8.2s | <3s | 5.2s |
| API p95 | 2.4s | <200ms | 2.2s |
| Memory | 2GB | <512MB | 1.5GB |

### Bottlenecks Found

#### Critical (P0) — Biggest Impact
| ID | Issue | Location | Impact | Fix |
|----|-------|----------|--------|-----|
| MS-XXXX | N+1 queries in user list | `api/users.ts:45` | 80% of load time | Batch query |

#### High (P1) — Significant Impact
| ID | Issue | Location | Impact | Fix |
|----|-------|----------|--------|-----|
| ... | ... | ... | ... | ... |

#### Medium (P2) — Nice to Have
| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| ... | ... | ... | ... |

### Quick Wins 🎯
1. **[Fix]** — Expected improvement: X% — Effort: Low
2. **[Fix]** — Expected improvement: X% — Effort: Low

### Architecture Recommendations
- [ ] Add caching layer for [what]
- [ ] Consider async processing for [what]
- [ ] Evaluate CDN for [what]

### Optimization Plan

**Phase 1: Quick Wins (This Week)**
1. [Action]
2. [Action]

**Phase 2: Medium Effort (Next Sprint)**
1. [Action]

**Phase 3: Large Refactor (Plan)**
1. [Action]

### Measurement After
How to verify improvements:
- [ ] Re-run benchmarks
- [ ] Compare p50, p95, p99
- [ ] Monitor in production
```

---

## ✅ Done When

- [ ] Baseline metrics captured
- [ ] Bottlenecks identified and ranked
- [ ] MS-#### created for P0/P1 issues
- [ ] Quick wins identified
- [ ] Optimization plan prioritized

---

## Related Prompts

- **Implement optimizations?** → [work.md](work.md)
- **Profile specific code?** → [explain_this.md](explain_this.md)
- **Full codebase audit?** → [audit.md](audit.md)
