# Expert Index

> **DO NOT read expert files directly.** Use this index to find the right file, then read only that file.

## How to Use
1. Identify keywords from the task/feature
2. Find matching keywords in the table below
3. Read ONLY the mapped file(s)

---

## Keyword → File Mapping

| Keywords | File | Experts Included |
|----------|------|------------------|
| architecture, systems, API, scalability, microservices, distributed, data modeling | [architecture.md](architecture.md) | Principal Systems Architect, Staff Engineering Lead |
| security, auth, GDPR, HIPAA, compliance, encryption, threat model, SOC2 | [security.md](security.md) | Security & Compliance Architect, Healthcare Compliance Engineer, Financial Systems Compliance Engineer |
| test, QA, coverage, automation, pytest, jest, e2e, regression | [testing.md](testing.md) | Senior QA Engineer, Test Automation Architect |
| product, requirements, scope, MVP, roadmap, user story, prioritization | [product.md](product.md) | Product Discovery Lead, Requirements Clarity Specialist, Scope Definition Analyst, Senior Product Manager |
| deploy, CI/CD, docker, SRE, reliability, monitoring, observability, incident | [devops.md](devops.md) | Principal SRE, Build Process Engineer, Technical Integration Lead |
| docs, runbook, checklist, changelog, release notes, specification | [documentation.md](documentation.md) | Technical Specification Engineer, DevOps Documentation Specialist, Checklist & Process Designer, Release Manager |
| design, UI, UX, accessibility, WCAG, layout, components, styling | [design.md](design.md) | Visual Design Lead, Design Systems Architect, UX Accessibility Specialist, UX Layout & Information Architect, Design Systems Technical Writer |
| implementation, code, build, refactor, technical debt, audit | [implementation.md](implementation.md) | Senior Implementation Engineer, API Contract Verification Engineer, Quality-Driven Integration Specialist, Implementation Audit Specialist, Technical Debt Analyst |

---

## Quick Reference by Task Type

| Task Type | Primary File | Secondary |
|-----------|--------------|-----------|
| New feature (backend) | architecture.md | implementation.md |
| New feature (frontend) | design.md | implementation.md |
| Bug fix | implementation.md | testing.md |
| Security review | security.md | - |
| Performance issue | devops.md | architecture.md |
| API design | architecture.md | documentation.md |
| Test coverage | testing.md | - |
| Release prep | documentation.md | devops.md |

---

## File Sizes (for cost awareness)

| File | Experts | Est. Tokens |
|------|---------|-------------|
| architecture.md | 2 | ~800 |
| security.md | 3 | ~1,200 |
| testing.md | 2 | ~800 |
| product.md | 4 | ~1,600 |
| devops.md | 3 | ~1,200 |
| documentation.md | 4 | ~1,600 |
| design.md | 5 | ~2,000 |
| implementation.md | 5 | ~2,000 |
| **This index** | - | ~400 |

**Total if monolithic**: ~10,000 tokens
**Typical chunked read**: ~400 (index) + ~1,200 (1-2 files) = **~1,600 tokens**
