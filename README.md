# claude-workflow-ai-saas

A complete Claude Code workflow that takes an AI-native SaaS product from idea to shipped product through a 5-phase, 28-agent SDLC pipeline with enforced phase gates.

**Version:** 2.3.1 · **Agents:** 28 · **Commands:** 7 · **Hooks:** 7 · **Skills:** 6

---

## What This Is

A drop-in Claude Code configuration that gives you a virtual engineering team. Install it in any project directory. Give Claude an idea. Run 5 commands. Get a shipped product.

**The gap it fills:** Every existing Claude Code workflow teaches Claude to write better code. None of them start with "should we build this?" or "what's the design?" This workflow encodes the full 100% — discovery, design, build, validation, and deployment.

**Assembly-first:** The workflow defaults to Shadcn/ui, Clerk, Stripe, Supabase, Upstash, Inngest, Resend, Sentry, and PostHog. ~20% custom code (your differentiator), ~80% assembled from proven services. Building infrastructure that exists as a managed service is a defect, not a feature.

## Tested Results

**Test 1 — AI Proposal Generator:**
Phase 0 produced 12,295 words across 7 artifacts. The Devil's Advocate caught a pricing inconsistency between two artifacts, identified the load-bearing assumption, and issued a conditional GO with 4 specific conditions.

**Test 2 — SOC 2 Compliance Platform:**
Phase 0 produced 15,205 words across 7 artifacts. Phase 1 produced 17,348 words across 6 artifacts including a 3,405-word technical design, 17 Prisma models, 11 security test scripts, and P50/P95/P99 per endpoint. The Devil's Advocate required a Concierge MVP before build.

## How It Works

```
/discover "your idea"    →  7 agents investigate market, define scope, issue Go/No-Go
                            ← You review the Go/No-Go decision

/design                  →  6 agents produce technical design, wireframes, design system
                            (Shadcn install list), security threat model (curl test scripts),
                            database schema (Prisma), performance spec (P50/P95/P99)
                            ← You review the technical design

/build                   →  4 work packages for parallel Claude Code worktrees
                            (database + backend, frontend, devops, tests)

/validate                →  5 agents measure against Phase 1 specs
                            (QA, performance, security, accessibility, code review)

/ship                    →  4 agents prepare deployment, monitoring, cost analysis
                            ← You approve deployment
```

**Your involvement:** Provide the idea. Make 3 decisions. Everything else is the team.

## Installation

```bash
git clone https://github.com/daniyalmalikoo7/claude-workflow-ai-saas .workflow
cp -r .workflow/.claude . && cp .workflow/CLAUDE.md . && cp .workflow/settings.json .
chmod +x .claude/hooks/*.sh
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

Phase gates are shell scripts returning exit code 2. Claude cannot bypass them.

- **phase-gate.sh** — blocks phase transitions until prerequisites met
- **quality-gate.sh** — blocks completion if tsc/lint/build/tests fail
- **artifact-validate.sh** — three-tier validation (BLOCK/WARN/PASS)
- **security-scanner.sh** — blocks commits containing secrets
- **session-start.sh / session-end.sh** — auto-reads/writes project state
- **auto-commit.sh** — conventional commits on clean quality gate

## Assembly Stack

Defaults to proven services. See `.claude/skills/assembly-stack.md`.

| Need | Default |
|---|---|
| UI Components | Shadcn/ui (Radix + Tailwind) |
| Auth | Clerk |
| Database | Supabase (Postgres + pgvector) |
| Payments | Stripe |
| Rate Limiting | Upstash |
| Background Jobs | Inngest |
| Email | Resend |
| Error Tracking | Sentry |
| Analytics | PostHog |
| Hosting | Vercel |

## License

MIT

## Author

[Osama (daniyalmalikoo7)](https://github.com/daniyalmalikoo7)
