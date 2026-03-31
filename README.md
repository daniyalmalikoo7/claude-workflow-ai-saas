# Claude Code Workflow — AI-Native SaaS

> **The only Claude Code workflow built specifically for shipping AI-powered SaaS products.**
> Battle-tested by building a production app. Every bug found became a better command.

gstack gives you roles. superpowers gives you methodology. **This gives you both — plus the GenAI product layer that neither has.**

---

## Why This Exists

Every Claude Code setup teaches Claude how to write code. None of them teach Claude how to build **AI products** — the kind where AI isn't just a developer tool, it's the core feature your customers pay for.

If you're building a product with AI generation, RAG pipelines, vector search, prompt engineering, or LLM API calls, you need patterns that no general-purpose setup provides:

- **Prompt versioning** with semantic versions and eval scores
- **Hallucination guards** via Zod schema validation on every AI output
- **Model fallback chains** (Sonnet → Haiku → cache → graceful error)
- **Context window budgets** with token counting and truncation strategies
- **Prompt injection defense** with input sanitization
- **Per-request cost tracking** with daily budgets per user
- **Evaluation pipelines** — every prompt change runs through automated evals

This workflow encodes all of these as first-class concerns, not afterthoughts.

---

## What You Get

**17 slash commands** forming a complete engineering team:

| Command | Role | What It Does |
|---|---|---|
| `/explore` | Product Engineer | Domain exploration — business analysis, personas, competitive research, feature prioritization |
| `/architect` | Systems Architect | Technical architecture — ADRs, data model, API design, AI architecture, security threat model |
| `/plan` | Program Manager | Implementation plan — phased tasks ≤2hrs, dependency graph, parallel session strategy |
| `/implement` | Staff Engineer | Production code — TDD, type-safe, tested, following architecture doc |
| `/design-ui` | Product Designer | UI/UX — atomic design, accessibility, responsive, AI interaction patterns (streaming, confidence, regeneration) |
| `/test` | QA Engineer | Test suite — unit, integration, E2E, AI evals, adversarial inputs |
| `/review` | Principal Engineer | Code review — correctness, security, performance, AI-specific checks (prompt versioning, hallucination guards) |
| `/security` | Security Engineer | Security audit — OWASP + AI-specific (prompt injection, context poisoning, IDOR, tenant isolation) |
| `/prompt-engineer` | Prompt Engineer | Prompt lifecycle — design, version, evaluate, guard against hallucination, A/B test |
| `/debug` | Staff Debugger | Systematic debugging — reproduce, isolate, fix, prevent, regression test |
| `/commit` | Release Engineer | Structured commits — verify, stage, conventional commit |
| `/ship` | Release Manager | Pre-deploy checklist — build, test, security, performance, documentation gates |
| `/monitor` | SRE | Observability — structured logging, error tracking, AI metrics (latency, token usage, eval drift, cost) |
| `/validate` | QA Engineer | **Runtime verification** — actually runs the app and tests every feature works. Catches hardcoded data, dead buttons, broken auth, IDOR, mocked flows. |
| `/qa` | QA Lead | **End-to-end user testing** — tests every flow from a real user's perspective. Sign-up → onboarding → core features → edge cases → mobile responsive. Reports UX issues, accessibility violations. |
| `/context-check` | Context Engineer | **Context efficiency audit** — verifies CLAUDE.md accuracy against codebase, detects stale architecture docs, measures token budget, finds redundant instructions. Keeps the workflow brain healthy. |
| `/memory` | Knowledge Manager | Session memory — persist decisions, update CLAUDE.md, manage state across sessions |

**5 specialized agents**: librarian, reviewer, qa, devops, performance

**5 reusable skills**: ai-integration, database, logging-monitoring, error-handling, context-management

**3 security hooks**: pre-write-guard (secret scanning, file size), security-scanner (dangerous commands), auto-formatter (Prettier on save)

**CI/CD pipeline**: GitHub Actions with typecheck, lint, test, security audit, AI evals, staged deploy

---

## Quick Start

```bash
# Clone into your project
git clone https://github.com/daniyalmalikoo7/claude-workflow-ai-saas.git my-project
cd my-project && rm -rf .git && git init

# Customize CLAUDE.md with your project details
# Replace [PROJECT_NAME], [Stack], [Deployment]

# Start Claude Code
claude

# Begin
/explore I want to build [describe your product]
```

**Setup time**: ~5 minutes. **Time to MVP**: Hours to days, not weeks.

---

## The Workflow

```
/explore    → Understand the domain, users, market, competitors
/architect  → Design the system (ADRs, data model, API, AI architecture)
/plan       → Break into ≤2hr tasks with dependency graph
/implement  → Build in parallel sessions (Opus for architecture, Sonnet for code)
/design-ui  → Production UI (Linear/Stripe quality, not Bootstrap templates)
/test       → Write tests (unit, integration, E2E, AI evals)
/review     → Static quality gate (catches code-level issues)
/security   → Static security gate (catches auth, injection, config issues)
/monitor    → Set up observability (logging, metrics, alerts)
/validate   → RUNTIME verification (catches everything static analysis misses)
/ship       → Final deployment gate (only after /validate passes)
```

**Full walkthrough**: See [`docs/runbooks/orchestration-workflow.md`](docs/runbooks/orchestration-workflow.md)

---

## How This Compares

| Feature | This Workflow | gstack (54K★) | superpowers (120K★) | everything-claude-code (50K★) |
|---|---|---|---|---|
| Role-based commands | ✅ 15 commands | ✅ 28 commands | ✅ 7-phase methodology | ✅ 60 commands |
| AI product patterns | ✅ **Full GenAI layer** | ❌ General purpose | ❌ General purpose | ❌ General purpose |
| Prompt versioning | ✅ Semantic versions + eval scores | ❌ | ❌ | ❌ |
| Hallucination guards | ✅ Zod validation + confidence scoring | ❌ | ❌ | ❌ |
| Model fallback chains | ✅ Primary → fallback → cache → error | ❌ | ❌ | ❌ |
| Cost tracking | ✅ Per-request, per-user budgets | ❌ | ❌ | ❌ |
| Runtime validation | ✅ `/validate` (infra + wiring) | ✅ `/qa` (browser UI) | ❌ | ❌ |
| Context management | ✅ Token budgets + truncation | ❌ | ❌ | ❌ |
| Security hooks | ✅ Pre-write + bash scanner | ✅ Basic | ✅ Via skills | ✅ AgentShield |
| Architecture-to-ship pipeline | ✅ Structured 11-phase | Flat commands | ✅ 7-phase | Flat commands |
| Battle-tested | ✅ ProposalPilot (real app) | ✅ YC internal | ✅ Community | ✅ Hackathon winner |
| AI SaaS specific | ✅ **Purpose-built** | ❌ | ❌ | ❌ |

**Bottom line**: If you're building a general app, gstack or superpowers are excellent. If you're building a product where **AI is the core feature** — where you need prompt engineering, hallucination prevention, cost optimization, and evaluation pipelines — this is the only workflow that treats those as first-class concerns.

---

## Battle-Tested: What We Found

This workflow was validated by building [ProposalPilot](https://github.com/daniyalmalikoo7) — a real AI-powered proposal engine with 9 database models, tRPC API, Clerk auth, Stripe billing, Tiptap editor, SSE streaming, and pgvector semantic search.

The app passed `/review`, `/security`, and `/ship`. Then we actually ran it and discovered:

| Bug | Which command missed it | Now caught by |
|---|---|---|
| Hardcoded demo data on every page | `/review` said "looks good" | `/validate` Phase 3.2 |
| Auth middleware existed but didn't protect routes | `/security` checked code, not behavior | `/validate` Phase 3.1 |
| Buttons rendered but triggered no actions | Nothing | `/validate` Phase 3.2 |
| Onboarding was a UI mock with `setTimeout` | `/review` said "onboarding exists ✅" | `/validate` Phase 3.3 |
| IDOR in 6 API procedures | `/security` missed it | `/validate` Phase 4.1 |
| CSP headers blocked auth provider's JavaScript | `/security` checked headers, not runtime | `/validate` Phase 5.1 |
| `PostResponse` hook event crashed Claude Code | Nothing | `/validate` Phase 1.6 |
| New users hit "Organization not found" | Nothing | `/validate` Phase 4.2 |

Every bug found became a check in `/validate`. This isn't a theoretical workflow — it's one that failed, learned, and got better.

---

## GenAI Product Layer (The Differentiator)

### Prompt Versioning
```markdown
# docs/prompts/requirement-extractor.v1.md
---
id: requirement-extractor
version: 1.0.0
model: claude-haiku-4-5-20251001
temperature: 0.1
eval_score: 0.92
last_evaluated: 2026-03-30
---
[System message here]
```

### Hallucination Guards
Every AI output passes through validation before reaching users:
- JSON structure validation (Zod schemas)
- Confidence scoring with thresholds
- Source citation verification against knowledge base
- Fabricated URL/reference detection

### Model Fallback Chain
```
Primary (Sonnet) → Fallback (Haiku) → Cached response → Graceful error
```
Each step: exponential backoff with jitter, Zod validation, hallucination guard check.

### Cost Tracking
Every AI call logs: prompt hash, model, tokens in/out, latency, cache hit, estimated USD cost. Per-user daily budgets prevent runaway spending.

---

## Customization

### Adapt CLAUDE.md
The `CLAUDE.md` file is the brain. Customize:
1. **Project Context**: Your project name, stack, deployment target
2. **Critical Commands**: Your build/test/lint commands
3. **Architecture Invariants**: Add project-specific rules

### Add MCP Servers
Edit `.mcp.json` to add integrations (Postgres, Sentry, GitHub, etc.)

### Add Custom Commands
Create files in `.claude/commands/`:
```markdown
# .claude/commands/my-command.md
You are a [role] responsible for [task].
## Process
1. Step one
2. Step two
$ARGUMENTS
```

---

## Parallel Session Strategy

For maximum throughput, run 3-5 sessions:

```
Terminal 1 (Opus)    → Architecture, review, security decisions
Terminal 2 (Sonnet)  → Feature implementation
Terminal 3 (Sonnet)  → UI components
Terminal 4 (Sonnet)  → Tests and AI evals
Terminal 5 (Haiku)   → Quick questions, docs, simple tasks
```

Use `/clear` between major tasks. The architecture docs on disk ARE the context — Claude reads them fresh each session.

---

## Sources

This workflow synthesizes patterns from the best in the ecosystem:

- [anthropics/claude-code](https://github.com/anthropics/claude-code) — Official reference
- [obra/superpowers](https://github.com/obra/superpowers) — Development methodology (120K+ ★)
- [garrytan/gstack](https://github.com/garrytan/gstack) — Role-based engineering team (54K+ ★)
- [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) — Security-first defaults
- [Anthropic best practices](https://www.anthropic.com/engineering/claude-code-best-practices) — Official guidance
- Boris Cherny (Claude Code creator) — Parallel sessions, shared CLAUDE.md
- Steve Sewell (Builder.io) — Production tips, `/clear` aggressively

---

## License

MIT — Use this to build something great.
