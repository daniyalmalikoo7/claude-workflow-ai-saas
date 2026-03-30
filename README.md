# 🏗️ Production Claude Code Setup

### Build and ship production-grade applications with a complete AI engineering team.

This is a drop-in Claude Code configuration that gives you a team of specialized agents, battle-tested workflows, and production-grade guardrails — the kind of setup used to build products at companies like Stripe, Linear, and Vercel.

**What you get**: 14 slash commands, 5 specialized agents, 5 reusable skills, 3 security hooks, CI/CD pipeline, cost tracking, prompt versioning, hallucination guards, and a complete build-to-ship orchestration workflow.

**Time to set up**: ~15 minutes.
**Time to ship an MVP**: Hours to days, not weeks.

---

## Quick Start

```bash
# 1. Copy this setup into your project
cp -r production-claude-setup/.claude your-project/.claude
cp -r production-claude-setup/.github your-project/.github
cp production-claude-setup/CLAUDE.md your-project/CLAUDE.md
cp production-claude-setup/.mcp.json your-project/.mcp.json
cp production-claude-setup/.env.example your-project/.env.example
cp production-claude-setup/.gitignore your-project/.gitignore
cp -r production-claude-setup/docs your-project/docs

# 2. Customize CLAUDE.md with your project details
#    (Replace the [PLACEHOLDERS] at the top)

# 3. Start Claude Code in your project
cd your-project
claude

# 4. Begin the workflow
/explore I want to build [describe your product]
```

---

## What's Inside

### Slash Commands (Your Engineering Team)

| Command | Role | What It Does |
|---|---|---|
| `/explore` | Product Engineer | Domain exploration — business analysis, user personas, competitive research, feature prioritization |
| `/architect` | Systems Architect | Complete technical architecture — ADRs, data model, API design, AI architecture, security threat model |
| `/plan` | Program Manager | Implementation plan — phased tasks ≤2hrs each, dependency graph, Gantt chart |
| `/implement` | Staff Engineer | Production code — TDD, type-safe, tested, documented, following architecture doc |
| `/design-ui` | Product Designer | UI/UX — atomic design, accessibility, responsive, AI interaction patterns, micro-interactions |
| `/test` | QA Engineer | Comprehensive tests — unit, integration, E2E, AI evals, adversarial inputs |
| `/review` | Principal Engineer | Code review — correctness, security, performance, AI-specific checks |
| `/security` | Security Engineer | Security audit — OWASP, AI-specific (prompt injection, context poisoning), STRIDE threat model |
| `/prompt-engineer` | Prompt Engineer | Prompt lifecycle — design, version, evaluate, guard against hallucination |
| `/debug` | Staff Debugger | Systematic debugging — reproduce, isolate, fix, prevent, add regression test |
| `/commit` | Release Engineer | Structured commits — verify, stage, conventional commit, atomic changes |
| `/ship` | Release Manager | Pre-deploy checklist — build, test, security, performance, documentation gates |
| `/monitor` | SRE | Observability setup and health checks — structured logging, Sentry, PostHog, AI metrics, cost alerts |
| `/memory` | Knowledge Manager | Persistent memory management — save decisions, update CLAUDE.md, manage session state across sessions |

### Subagents (Background Workers)

| Agent | Trigger | Purpose |
|---|---|---|
| `librarian` | On demand | Searches codebase for patterns, answers architecture questions, finds relevant code |
| `reviewer` | After `/implement` | Automated code review focused on types, security, performance, tests |
| `qa` | After implementation | Validates against acceptance criteria, runs test suite, checks accessibility |
| `devops` | On demand | Infrastructure, deployment, monitoring, cost management |
| `performance` | On demand | Performance profiling and optimization for frontend, backend, and AI calls |

### Skills (Reusable Knowledge)

| Skill | Purpose |
|---|---|
| `ai-integration` | Production patterns for provider abstraction, prompt loading, fallback chains, cost tracking, hallucination guards |
| `database` | Schema design rules, Prisma conventions, query patterns, migration safety |
| `logging-monitoring` | Structured logger implementation, AI call logging, Sentry/PostHog setup, AI-specific metrics and alert rules |
| `error-handling` | Typed AppError class hierarchy, React error boundaries, API error wrapper, AI retry-with-backoff pattern |
| `context-management` | Token counting (tiktoken), context budget enforcement, FIFO and relevance-based truncation strategies |

### Hooks (Automated Guardrails)

| Hook | Trigger | What It Does |
|---|---|---|
| `pre-write-guard` | Before any file write | Blocks protected files, enforces 350-line limit, scans for secrets |
| `security-scanner` | Before any bash command | Blocks dangerous commands (rm -rf, sudo, pipe-to-shell, etc.) |
| `session-logger` | After every response | Logs session activity for cost tracking and audit |
| Auto-formatter | After every file write | Runs Prettier on saved files |

---

## The Complete Workflow

```
/explore   →  Understand the domain
/architect →  Design the system
/plan      →  Break into executable tasks
/implement →  Build (parallel sessions)
/test      →  Verify
/review    →  Quality gate
/security  →  Security gate
/monitor   →  Observability setup
/ship      →  Launch gate
/memory    →  Persist learnings for next session
```

**Full walkthrough**: See `docs/runbooks/orchestration-workflow.md`

---

## GenAI-Specific Features

This setup is designed specifically for building products that incorporate AI. It includes:

**Prompt Versioning**: Store prompts as versioned markdown files with metadata (model, temperature, eval scores). Never hardcode prompts in source code.

**Hallucination Guards**: Every AI output passes through validation (Zod schemas), confidence scoring, and content filtering before reaching users.

**Context Management**: Token counting, truncation strategies, and context budgets prevent context window overflows and control costs.

**Prompt Injection Defense**: User inputs are sanitized before injection into prompts. System and user messages are strictly separated.

**Model Fallback Chain**: Primary model → fallback model → semantic cache → graceful error. Never show users a raw API failure.

**Cost Tracking**: Every AI call logs token counts, model used, latency, and estimated cost. Per-user daily budgets prevent runaway spending.

**Evaluation Pipeline**: Every prompt has an eval dataset. Prompt changes must maintain or improve eval scores.

**Anti-Hallucination Patterns**: Structured outputs (JSON schemas), confidence thresholds, source citation requirements, and human-in-the-loop for high-stakes decisions.

---

## Customization

### Adapt CLAUDE.md to Your Stack

The `CLAUDE.md` file is the brain. Customize these sections for your project:

1. **Project Context**: Your actual project name, tech stack, deployment target
2. **Critical Commands**: Your actual build/test/lint commands
3. **File Organization**: Your actual directory structure
4. **Architecture Invariants**: Add any project-specific rules

### Add More MCP Servers

Edit `.mcp.json` to add integrations:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" }
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server"],
      "env": { "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}" }
    }
  }
}
```

### Add Custom Commands

Create new files in `.claude/commands/`:

```markdown
# .claude/commands/my-command.md
You are a [role] responsible for [task].

## Process
1. Step one
2. Step two

$ARGUMENTS
```

Then use with: `/my-command [arguments]`

---

## Recommended Parallel Session Layout

For maximum throughput, run 3-5 sessions simultaneously:

```
┌──────────────────────────────────────────────────────┐
│ Terminal 1 (Opus)    │ Terminal 2 (Sonnet)            │
│ Architecture/Review  │ Feature Implementation         │
├──────────────────────┤────────────────────────────────│
│ Terminal 3 (Sonnet)  │ Terminal 4 (Sonnet)            │
│ UI Components        │ Tests & AI Evals               │
├──────────────────────┤────────────────────────────────│
│ Terminal 5 (Haiku)                                    │
│ Quick questions, docs, simple tasks                   │
└──────────────────────────────────────────────────────┘
```

Use `git worktrees` for parallel development on separate branches:
```bash
git worktree add ../project-auth feature/auth
git worktree add ../project-dashboard feature/dashboard
git worktree add ../project-ai feature/ai-integration
```

---

## Inspired By

This setup synthesizes the best patterns from:
- **[anthropics/claude-code](https://github.com/anthropics/claude-code)** — Official reference
- **[everything-claude-code](https://github.com/anthropics/skills)** — 28 agents, 119 skills
- **[obra/superpowers](https://github.com/obra/superpowers)** — 7-phase development methodology
- **[garrytan/gstack](https://github.com/garrytan/gstack)** — Role-based engineering team
- **[trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config)** — Security-first defaults
- **Boris Cherny's setup** — Claude Code creator's own workflow
- **Builder.io's guides** — Steve Sewell's production tips

---

## License

MIT — Use this to build something great.
