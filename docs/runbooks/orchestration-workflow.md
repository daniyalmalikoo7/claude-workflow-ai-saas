# Production Orchestration Workflow

## The Complete Build Pipeline

This document defines the end-to-end workflow for building a production application using this Claude Code setup. Follow these phases in order.

---

## Phase 0: Project Initialization (15 minutes)

```
1. Copy this setup into your project root
2. Customize CLAUDE.md:
   - Replace [PROJECT_NAME] with your project name
   - Replace [Stack] with your actual tech stack
   - Replace [Deployment] with your deployment target
3. Set up .env from .env.example
4. Run: npm install (or your package manager)
5. Verify: claude /explore "quick test" — confirm Claude sees the setup
```

---

## Phase 1: Discovery & Exploration (1-2 hours)

**Command**: `/explore [your project description]`

**What happens**:
- The explore agent analyzes your domain from business + technology angles
- Produces user personas, competitive analysis, feature priority matrix
- Output: `docs/architecture/001-domain-exploration.md`

**Your role**: Review the output. Add context the AI missed. Refine the priority matrix.

**Parallel session** (optional): Use a second Claude session to research competitors, gather API docs, or explore technical constraints.

---

## Phase 2: Architecture & Planning (1-2 hours)

**Command**: `/architect`

**What happens**:
- Reads the exploration doc, produces complete system architecture
- ADRs for every major decision (database, auth, AI, frontend)
- Data model, API surface, file structure, security threat model
- Output: `docs/architecture/002-system-architecture.md`

**Then**: `/plan`

**What happens**:
- Breaks the architecture into implementation phases
- Each task is ≤2 hours, independently testable, with clear acceptance criteria
- Produces a Gantt chart showing parallelism
- Output: `docs/architecture/003-implementation-plan.md`

**Your role**: Review architecture decisions. Challenge anything that feels over-engineered for an MVP. Approve the plan.

---

## Phase 3: Foundation Build (2-4 hours)

**Run in sequence** (these are foundational, order matters):

```
Session 1: /implement Set up project scaffolding — package.json, tsconfig, 
           ESLint, Prettier, Tailwind, directory structure per architecture doc

Session 2: /implement Set up database — Prisma schema, initial migration, 
           seed script per the data model in the architecture doc

Session 3: /implement Set up authentication — NextAuth/Clerk/Auth.js 
           with the providers specified in the architecture doc

Session 4: /implement Set up the AI integration layer — provider abstraction, 
           prompt loader, cost tracker, fallback chain using the patterns 
           in .claude/skills/ai-integration.md
```

After each session, run `/review` to catch issues early.

---

## Phase 4: Core Feature Build (4-12 hours)

**Run in parallel** (3-5 Claude Code sessions simultaneously):

```
Session A: /implement [Core Feature 1 — per implementation plan]
Session B: /implement [Core Feature 2 — per implementation plan]  
Session C: /design-ui [Main UI components — per implementation plan]
Session D: /prompt-engineer [AI feature prompts — per implementation plan]
Session E: /test [Write tests for completed features]
```

**Workflow per feature**:
1. `/implement [feature]` — Build it
2. The reviewer agent runs automatically on the output
3. `/test [feature]` — Write comprehensive tests
4. `/commit [feature]` — Stage, verify, commit with conventional commit message
5. Move to next feature

**Key patterns**:
- Keep sessions focused: one feature per session
- Use `/plan` to re-prioritize if you discover something unexpected
- Use the librarian agent (`@librarian`) when you need to find existing patterns
- Run `/debug` immediately when something breaks — don't let bugs accumulate

---

## Phase 5: AI Feature Hardening (2-4 hours)

**Dedicated to making AI features production-ready**:

```
Session 1: /prompt-engineer [Evaluate and iterate on all prompts]
           — Run eval suites, improve scores, document baselines

Session 2: /implement [Hallucination guards and context management]
           — Output validation, confidence scoring, fallback chain testing

Session 3: /security [AI-specific security audit]
           — Prompt injection testing, context poisoning prevention,
             PII handling, cost abuse prevention

Session 4: /test [AI integration tests]
           — Mock providers, test fallback chains, adversarial inputs
```

---

## Phase 6: Polish & UX (2-4 hours)

```
Session 1: /design-ui [Polish all UI components — loading states, 
           error states, empty states, transitions, responsive]

Session 2: /implement [Accessibility audit fixes — WCAG 2.1 AA]

Session 3: /implement [Performance optimization — bundle size, 
           lazy loading, caching, image optimization]

Session 4: /design-ui [AI interaction UX — streaming, confidence 
           indicators, regenerate, error recovery]
```

---

## Phase 7: Pre-Launch (2-3 hours)

**Run in sequence**:

```
1. /review          — Full codebase review (static analysis)
2. /security        — Security audit (static + config analysis)
3. /test            — Full test suite with coverage report
4. /monitor         — Set up observability (logging, metrics, alerts)
5. /validate        — Runtime infrastructure verification: env vars, DB, page wiring,
                      tenant isolation, AI pipeline. Fix everything before proceeding.
6. /qa              — End-to-end user flow testing: sign-up → onboarding → core features
                      → edge cases → mobile responsive. Fix broken flows.
7. /context-check   — Verify CLAUDE.md accuracy, architecture doc currency, context
                      efficiency. Ensure the workflow brain matches reality.
8. /ship            — Final deployment gate (only after all above pass)
```

**Why this order matters:**
- /review and /security check the **code** (static analysis)
- /validate checks the **infrastructure** (runtime, but not user-facing)
- /qa checks the **product** (from the user's perspective)
- /context-check checks the **workflow itself** (is Claude working with accurate context?)
- /ship checks **deployment readiness** (the final gate)

If you skip /validate, you ship code that compiles but doesn't connect. If you skip /qa, you ship infrastructure that works but users can't use. If you skip /context-check, future sessions work with stale context.

Fix any blockers found. Re-run `/ship` until green.

---

## Phase 8: Launch

```
1. Deploy to staging
2. Smoke test critical paths manually
3. Deploy to production
4. Monitor dashboards for first 24 hours
5. Celebrate 🎉
```

---

## Ongoing: Maintenance Workflow

For new features after launch:
```
/explore [new feature idea]  →  Discovery
/plan [new feature]          →  Task breakdown  
/implement [task]            →  Build
/test [task]                 →  Verify
/review                      →  Quality gate
/commit                      →  Version control
/ship                        →  Deploy gate
/memory                      →  Persist decisions and learnings
```

For bugs:
```
/debug [bug description]     →  Root cause + fix + prevention
/test [regression test]      →  Prevent recurrence
/commit                      →  Ship the fix
/memory                      →  Record the gotcha for future sessions
```

For AI prompt iteration:
```
/prompt-engineer [prompt]    →  Iterate on prompt
Run evals                    →  Measure improvement
/commit                      →  Version the prompt
/monitor                     →  Check eval scores post-deploy
```

For observability reviews (weekly):
```
/monitor                     →  Review system health, AI metrics, cost trends
/memory                      →  Update baselines and thresholds
```

---

## Session Management Tips

**Parallel sessions** (recommended: 3-5 simultaneous):
- Use separate terminal tabs or Claude Squad
- Each session works on independent tasks from the plan
- Use git worktrees for true parallel development:
  ```bash
  git worktree add ../project-feature-a feature/feature-a
  git worktree add ../project-feature-b feature/feature-b
  ```

**Context management**:
- Use `/clear` aggressively — fresh context beats stale context
- Start each session by telling Claude what you're working on
- Reference architecture docs: "implement task 3.2 from the implementation plan"
- For long sessions, periodically ask Claude to summarize progress

**Cost optimization**:
- Use Sonnet for implementation (fast, good quality, lower cost)
- Use Opus for architecture, complex debugging, and code review
- Use Haiku for quick questions and simple tasks
- Session logs track cost in `.claude/logs/`
