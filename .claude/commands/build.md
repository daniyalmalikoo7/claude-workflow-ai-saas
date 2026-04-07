# /build

You are the Phase 2 orchestrator — Build. Phase 1 (Design) is complete and
the user has approved the technical design.

**IMPORTANT:** Phase 2 cannot run as a single sequential session. Building a
full codebase exceeds one context window. This command produces a decomposition
into independent work packages that run in parallel worktrees.

## Pre-flight

1. Verify Phase 1 complete: check `.claude/state/phase.json` and verify all 6 design artifacts exist.
2. Read the technical design: `docs/design/01-technical-design.md`
3. Read the data model: `docs/design/05-data-model.md`
4. Update phase.json: set phase 2 to `"in-progress"`, `currentPhase` to `2`.

## Decomposition

Read the technical design and produce a sprint plan with independent work packages.
Each package can run in its own Claude Code worktree without conflicting with others.

### Standard decomposition for AI-native SaaS:

**Package 1: Database + Backend** (worktree: `pkg-backend`)
- Agents: Database Engineer → Backend Engineer → AI/ML Engineer
- Reads: `docs/design/05-data-model.md`, `docs/design/01-technical-design.md`, `docs/design/04-security-design.md`
- Produces: Prisma schema + migrations, all tRPC routers, AI service layer with LLM wrapper
- Installs: `@upstash/ratelimit` for rate limiting, `inngest` for background jobs, `resend` for email
- File ownership: `prisma/`, `src/server/`, `src/lib/ai/`, `docs/prompts/`

**Package 2: Frontend** (worktree: `pkg-frontend`)
- Agents: Frontend Engineer
- Reads: `docs/design/03-design-system.md`, `docs/design/02-ux-design.md`, `docs/design/01-technical-design.md`
- First action: `npx shadcn@latest init` then install all components from design system's Shadcn install list
- Produces: Design token CSS overrides, all pages composed from Shadcn components, product-specific custom components
- File ownership: `src/app/`, `src/components/`, `tailwind.config.ts`, `src/app/globals.css`, `components.json`

**Package 3: DevOps** (worktree: `pkg-devops`)
- Agents: DevOps Engineer
- Reads: `docs/design/01-technical-design.md`, `docs/design/04-security-design.md`
- Produces: CI/CD pipeline, Vercel config, Sentry setup (3 lines), PostHog setup (drop-in), monitoring
- File ownership: `.github/`, `vercel.json`, `next.config.ts` (deployment sections), `sentry.*.config.ts`

**Package 4: E2E Tests** (run AFTER packages 1-3 merge)
- Agents: QA Engineer
- Reads: `docs/discovery/03-prd.md`, `docs/design/02-ux-design.md`, all code from packages 1-3
- Produces: Playwright E2E tests for every feature
- File ownership: `tests/`, `playwright.config.ts`

## Output

Report the decomposition and give the user exact commands:

```
═══════════════════════════════════════════════════
PHASE 2 — Build Decomposition
═══════════════════════════════════════════════════

4 work packages. Packages 1-3 run in parallel. Package 4 runs after merge.

Package 1 — Database + Backend:
  claude --worktree pkg-backend
  Then paste: "Read .claude/agents/phase-2/database-engineer.md, then
  .claude/agents/phase-2/backend-engineer.md, then .claude/agents/phase-2/ai-ml-engineer.md.
  Execute each agent's mandate against the Phase 1 design artifacts."

Package 2 — Frontend:
  claude --worktree pkg-frontend
  Then paste: "Read .claude/agents/phase-2/frontend-engineer.md.
  Execute the mandate against docs/design/03-design-system.md and docs/design/02-ux-design.md."

Package 3 — DevOps:
  claude --worktree pkg-devops
  Then paste: "Read .claude/agents/phase-2/devops-engineer.md.
  Execute the mandate against docs/design/01-technical-design.md."

After merging packages 1-3:
Package 4 — E2E Tests:
  "Read .claude/agents/phase-2/qa-engineer.md. Write Playwright E2E tests for
  every feature. Run npx playwright test. All tests must pass."

File ownership (no conflicts):
  pkg-backend:  prisma/, src/server/, src/lib/ai/, docs/prompts/
  pkg-frontend: src/app/, src/components/, tailwind.config.ts
  pkg-devops:   .github/, vercel.json
  pkg-tests:    tests/, playwright.config.ts

After all packages complete and merge:
  → npx tsc --noEmit (must pass)
  → npm run lint (must pass)
  → npm run build (must pass)
  → npx playwright test (must pass)
  → Update phase.json: phase 2 = complete
  → Run /validate to begin Phase 3
```

## Post-completion (after user merges all packages)

When the user confirms all packages are merged and quality gate passes:
1. Update `.claude/state/phase.json`: phase 2 = complete, `currentPhase` = 3
2. Instruct: "Run /validate to begin Phase 3 — Validation."
