# claude-workflow-ai-saas

A complete Claude Code workflow that takes an AI-native SaaS product from idea to shipped product through a 5-phase, 28-agent SDLC pipeline with enforced phase gates.

## What This Is

A drop-in Claude Code configuration that gives you a virtual engineering team. Install it in any project directory. Give Claude an idea. Run 5 commands. Get a shipped product.

**The gap it fills:** Every existing Claude Code workflow (everything-claude-code, superpowers, gstack) teaches Claude to write better code. None of them start with "should we build this?" or "what's the design?" This workflow encodes the full 100% — discovery, design, build, validation, and deployment.

## How It Works

```
/discover "your idea"    →  7 agents investigate the market, define scope, issue Go/No-Go
                            ← You review the Go/No-Go decision

/design                  →  6 agents produce technical design, wireframes, design system,
                            security threat model, database schema, performance spec
                            ← You review the technical design

/build                   →  4 work packages for parallel Claude Code worktrees
                            (database + backend, frontend, devops, tests)

/validate                →  5 agents measure against Phase 1 specs
                            (QA, performance, security, accessibility, code review)

/ship                    →  4 agents prepare deployment, monitoring, cost analysis
                            ← You approve deployment
```

**Your total involvement:** Provide the idea. Make 3 decisions (Go/No-Go, design approval, deploy approval). Everything between those moments is the team.

## What Makes This Different

| Capability | This Workflow | everything-claude-code | superpowers | gstack |
|---|---|---|---|---|
| Pre-build discovery (Phase 0) | ✓ 7 agents | ✗ | ✗ | ✗ |
| Design system before code (Phase 1) | ✓ Actual Tailwind config | ✗ | ✗ | ✗ |
| Enforced phase gates (shell scripts) | ✓ Exit code 2 = blocked | ✗ | ✗ | ✗ |
| Artifact validation with retry | ✓ Section + depth checks | ✗ | ✗ | ✗ |
| GenAI product layer | ✓ Prompts, evals, cost tracking | ✗ | ✗ | ✗ |
| Security threat model with tests | ✓ Actual curl commands | ✗ | ✗ | ✗ |
| Performance spec with P50/P95/P99 | ✓ Per endpoint | ✗ | ✗ | ✗ |

## Installation

```bash
git clone https://github.com/daniyalmalikoo7/claude-workflow-ai-saas .workflow
cp -r .workflow/.claude . && cp .workflow/CLAUDE.md . && cp .workflow/settings.json .
claude
```

## The 28 Agents

| Phase | Count | Agents |
|---|---|---|
| 0 — Discovery | 7 | Domain Researcher, Business Strategist, Product Expert, Business Analyst, Due Diligence Engineer, Technical Risk Analyst, Devil's Advocate |
| 1 — Design | 6 | System Architect, UX Designer, UI Designer, Security Architect, Data Architect, Performance Architect |
| 2 — Build | 6 | Frontend Engineer, Backend Engineer, AI/ML Engineer, Database Engineer, DevOps Engineer, QA Engineer |
| 3 — Validation | 5 | QA Lead, Performance Engineer, Security Engineer, Accessibility Engineer, Code Reviewer |
| 4 — Ship | 4 | Release Manager, Monitoring Engineer, Cost Engineer, Growth Analyst |

## Enforcement

Phase gates are shell scripts that return exit code 2 to block actions. Claude cannot bypass them through conversation.

- **phase-gate.sh** — blocks phase transitions until prerequisites are met
- **quality-gate.sh** — blocks completion if tsc/lint/build/tests fail
- **artifact-validate.sh** — blocks on empty/stub artifacts, warns on missing sections
- **security-scanner.sh** — blocks commits containing secrets or API keys
- **session-start.sh / session-end.sh** — auto-reads/writes project state

## Stack Compatibility

Built for AI-native SaaS with: Next.js, tRPC, Prisma, Supabase/Postgres + pgvector, Clerk, Stripe, and any LLM provider (Anthropic, Google, OpenAI).

Adaptable to other stacks by modifying the Phase 1 agent output templates.

## License

MIT

## Author

[Osama (daniyalmalikoo7)](https://github.com/daniyalmalikoo7)
