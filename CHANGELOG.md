# Changelog

## [2.3.1] — 2026-04-07

### Assembly-First: Single Source of Truth

Tested on two products (AI Proposal Generator + SOC 2 Compliance Platform).
Phase 0 + Phase 1 produce 30K+ words of principal-level output per product.

### Added

- **assembly-stack.md** — new skill file. Single source of truth for all services, MCPs, Shadcn components, and stack defaults. Every agent inherits this via CLAUDE.md.

### Changed

- **CLAUDE.md** — references assembly-stack.md skill. "What You Never Do" includes building what Shadcn/services provide.
- **engineering-standard.md** — cleaned up duplicate sections. References assembly-stack.md. Added stack version pins (Next.js 16+, Prisma 6+, Tailwind v4).
- **ui-designer.md** — rewritten to extend Shadcn/ui. Outputs CSS variable overrides + Shadcn install list. Never designs custom Button/Dialog/Table.
- **system-architect.md** — must include MCP configuration, alternative evaluation per tech choice, assembly stack section.
- **frontend-engineer.md** — Shadcn-first: `npx shadcn@latest init`, install components, compose custom from primitives.
- **backend-engineer.md** — Upstash `@upstash/ratelimit` for rate limiting, Inngest for background jobs, Resend for email.
- **devops-engineer.md** — Sentry (3 lines setup), PostHog (drop-in). Never build custom monitoring.
- **build.md** — work packages updated: Shadcn init for frontend, Upstash/Inngest/Resend for backend, Sentry/PostHog for devops.
- **session-start.sh** — fixed macOS compatibility (`md5` instead of `md5sum`).
- **session-end.sh** — fixed macOS compatibility.

### Removed

- All v2.2.0 leftover files: `.github/workflows/`, `.env.example`, `.mcp.json`, `CONTRIBUTING.md`, `docs/case-studies/`, `docs/architecture/`, `docs/examples/`, `docs/prompts/`, `docs/runbooks/`, `.claude-plugin/`

## [2.3.0] — 2026-04-04

### The Overhaul: From Prompt Collection to Automation System

v2.3.0 is a complete rewrite. The workflow system was critiqued as "theater" — 
ProposalPilot, the battle-test product, was built by ignoring the entire system.
v2.3.0 fixes the 7 systemic failures identified in the critique and rebuilds
every component to produce predictable, validatable, high-quality output.

### Added

**28 Agent Files (complete operating manuals)**
- 7 Phase 0 agents: domain-researcher, business-strategist, product-expert, business-analyst (adversarial), due-diligence-engineer, technical-risk-analyst, devils-advocate
- 6 Phase 1 agents: system-architect, ux-designer (merged with UX researcher), ui-designer (produces code), security-architect (testable threat model), data-architect (actual Prisma schema), performance-architect (P50/P95/P99)
- 6 Phase 2 agents: frontend-engineer, backend-engineer, ai-ml-engineer, database-engineer, devops-engineer, qa-engineer (embedded)
- 5 Phase 3 agents: qa-lead, performance-engineer, security-engineer, accessibility-engineer, code-reviewer
- 4 Phase 4 agents: release-manager, monitoring-engineer, cost-engineer, growth-analyst

**7 Command Files (orchestrators with self-validation)**
- /discover — 7-agent Phase 0 with artifact validation and retry
- /design — 6-agent Phase 1 producing code artifacts
- /build — work package decomposition for parallel worktrees
- /validate — 5-agent Phase 3 measuring against Phase 1 specs
- /ship — 4-agent Phase 4 with deployment preparation
- /status — project state dashboard
- /fix — systematic finding resolution from validation reports

**7 Hook Files (deterministic enforcement)**
- artifact-validate.sh — three-tier validation (BLOCK/WARN/PASS)
- phase-gate.sh — blocks phase transitions until prerequisites met
- quality-gate.sh — blocks on tsc/lint/build/test failures
- security-scanner.sh — blocks secrets in staged files
- session-start.sh — auto-reads project state
- session-end.sh — auto-checkpoints memory
- auto-commit.sh — conventional commits on clean gate

**5 Skill Files (shared knowledge)**
- engineering-standard.md — rules (machine-enforced) + guidelines (agent-enforced)
- uiux-standard.md — Netflix/Apple benchmark with enforceable specifics
- security-patterns.md — concrete patterns with implementation code
- ai-integration.md — prompt versioning, eval pipelines, hallucination guards, cost tracking
- performance-budget.md — industry benchmarks with measurement commands

**State Machine**
- phase.json tracks current phase, completion timestamps, artifact paths, decisions
- Phase gates read state and enforce transitions deterministically

### Changed

- Agent count: 32 → 28 (removed redundancy, improved depth)
- UX Researcher merged into UX Designer (research-then-wireframe in one artifact)
- Engineering Manager cut (sequencing handled by /build command)
- Principal Engineer cut (enforcement via skill + hook + Phase 3 Code Reviewer)
- Cloud Specialist merged into DevOps Engineer (one role for solo developer)
- Incident Commander merged into Release Manager (basic runbook, not full incident process)
- Strategic Planner renamed to Technical Risk Analyst (concrete risks, not 2-year speculation)
- Phase 1 agents produce code (Tailwind config, Prisma schema, test commands) not prose
- /build produces work packages for parallel execution instead of sequential single-session

### Fixed

- Commands now self-validate artifacts after each agent (retry on failure)
- Phase gates now actually enforced (shell scripts with exit 2)
- Artifact validation checks content quality, not just file existence
- Session management automated (hooks, not human discipline)
- Quality standards enforced by hooks, not just documented in skill files

## [2.2.0] — 2026-03-28

- Initial release with 17 commands, 5 agents, 3 hooks
- GenAI product layer (prompt versioning, hallucination guards, cost tracking)
- Battle-tested by ProposalPilot (identified systemic failures that drove v2.3.0)
