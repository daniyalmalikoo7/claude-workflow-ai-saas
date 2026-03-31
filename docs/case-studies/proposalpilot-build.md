# Case Study: Building ProposalPilot with This Workflow

> **A real AI-powered SaaS product built from zero to production using every command in this workflow.**
> This is not a tutorial with toy examples. This is a war story — what worked, what broke, what we learned.

## What We Built

**ProposalPilot** — an AI-powered proposal and SOW engine for professional services companies. Ingests RFPs, extracts requirements, matches past wins from a knowledge base, and generates tailored brand-consistent proposals.

**Stack**: Next.js 15, TypeScript strict, Tailwind, shadcn/ui, tRPC v11, Prisma v6, PostgreSQL (Supabase), pgvector, Tiptap editor, Google Gemini, Clerk auth, Stripe billing

**What was produced**: 9 database models, 5 tRPC routers, 4 versioned prompts, AI pipeline with fallback chain and hallucination guards, SSE streaming editor, PDF/DOCX export, multi-tenant auth, 4-tier billing, dark/light mode

**Build time**: ~6 hours of Claude Code sessions across one day

---

## Phase 1: Domain Exploration

**Command**: `/explore`

**Prompt used**:
```
/explore ProposalPilot — an AI-powered proposal and SOW engine for professional 
services companies (agencies, consultancies, IT firms, MSPs).

The product solves a $6.2T market problem: professional services companies spend 
20-40 hours writing each proposal, with a 70-80% loss rate. That's $4,500-$8,000 
in senior staff time wasted per lost proposal.

ProposalPilot workflow:
1. INGEST — Upload RFP/brief (PDF, DOCX, email) or describe the opportunity
2. EXTRACT — AI extracts every requirement, evaluation criterion, deadline
3. MATCH — AI searches knowledge base for relevant past proposals, case studies
4. GENERATE — AI produces complete proposal draft with brand voice and formatting
5. REFINE — Human reviews/edits in collaborative rich-text editor
6. EXPORT — One-click export to branded PDF/DOCX

Target customers: Marketing/digital agencies, IT consulting firms, MSPs (50-500 employees)
Pricing: Starter $49/mo, Growth $199/mo, Scale $499/mo, Enterprise $999/mo
Competitors: Responsive/RFPIO ($20K+/yr), Loopio ($25K+/yr), PandaDoc ($49/mo no AI)
```

**Model**: Opus (domain analysis needs deep reasoning)
**Tokens consumed**: ~61K (spawned 2 parallel subagents — one for codebase analysis, one for market research)
**Time**: ~15 minutes

**What it produced**:
- `docs/architecture/001-domain-exploration.md` — index with strategic recommendations
- `docs/architecture/001a-business-analysis.md` — personas, value prop, KPIs, risks
- `docs/architecture/001b-technical-analysis.md` — data model, integrations, scale, AI architecture
- `docs/architecture/001c-competitive-intelligence.md` — 7 competitors analyzed, UX patterns
- `docs/architecture/001d-recommendation-matrix.md` — 30 features ranked, MVP scope, pricing model

**Key finding**: The /explore command generated sub-documents autonomously — more thorough than expected. Found real market data (57.2% CAGR for the RFP sub-segment) via web research subagent.

**Lesson learned**: /explore on Opus is thorough but expensive (~61K tokens). For future projects, consider using Sonnet for explore if the domain is well-understood, or provide a more focused prompt to reduce research scope.

---

## Phase 2: Architecture (SKIPPED — Pre-built)

**What we did**: We had already generated the architecture and implementation plan during a dry-run validation of the workflow. Instead of burning another ~50K tokens on /architect and /plan, we copied the pre-built documents directly:

```bash
cp 002-system-architecture.md docs/architecture/
cp 003-implementation-plan.md docs/architecture/
```

**Lesson learned**: If you've already done discovery in a prior conversation (or have strong opinions about the architecture), skip /architect and /plan. Write the docs yourself or reuse existing ones. The workflow reads docs from disk — it doesn't care who wrote them. This saved ~100K tokens.

---

## Phase 3: Parallel Implementation

### Session Layout

We ran 3 parallel Claude Code sessions simultaneously, each on Sonnet for cost efficiency:

```
Terminal 1 (Sonnet) — Foundation: scaffolding, schema, auth, billing
Terminal 2 (Sonnet) — AI Pipeline: file processing, embeddings, prompts, fallback chain
Terminal 3 (Sonnet) — UI: editor, dashboard, knowledge base, onboarding, settings
```

### Session 1 Prompt (Foundation):
```
Read CLAUDE.md and docs/architecture/002-system-architecture.md.
Implement the project foundation:
1. Next.js 15 app with TypeScript strict, Tailwind, shadcn/ui
2. Prisma schema with all models from the data model section
3. tRPC router scaffold
4. Base layout with sidebar nav
Run npx tsc --noEmit when done.
```

### Session 2 Prompt (AI Pipeline):
```
Read docs/architecture/002-system-architecture.md and .claude/skills/ai-integration.md.
Build the file processing and AI pipeline:
1. File upload endpoint for PDF (pdf-parse) and DOCX (mammoth)
2. Text chunking — 500 tokens per chunk, 50 token overlap
3. pgvector setup for semantic search
4. Create docs/prompts/requirement-extractor.v1.md with the prompt template
5. Create docs/prompts/section-generator.v1.md with the prompt template
Run npx tsc --noEmit when done.
```

### Session 3 Prompt (UI):
```
Read docs/architecture/002-system-architecture.md.
Build the dashboard and onboarding:
1. Dashboard page — proposal cards with status, deadline, completion %, cursor pagination
2. Knowledge base page — grid view with type badges, semantic search, upload dropzone
3. Onboarding flow — 3 steps: upload past proposals, configure brand voice, see demo
4. Settings page — org details, billing (Stripe portal), team members
Make it look like Linear — dense, professional, clean. Dark and light mode.
Run npx tsc --noEmit when done.
```

### How Parallel Sessions Were Isolated
- Each session worked on different **directories** — Session 1 touched `src/server/` and `prisma/`, Session 2 touched `src/lib/ai/` and `docs/prompts/`, Session 3 touched `src/app/` and `src/components/`
- No two sessions edited the same file simultaneously
- After each session completed and `tsc --noEmit` passed, we committed immediately:

```bash
# In a separate terminal (not Claude Code):
git add -A
git commit -m "feat: [description of what this session built]"
```

- The architecture doc (`002-system-architecture.md`) was the shared contract — each session read it but none modified it

**Lesson learned**: Parallel sessions work when you partition by directory. If two sessions need to edit the same file (e.g., `package.json`), let one finish first, commit, then start the other. The `tsc --noEmit` at the end of each prompt catches any cross-session conflicts.

---

## Phase 4: Wiring Session

After the 3 parallel sessions completed, we needed a focused session to connect everything:

```
Read docs/architecture/002-system-architecture.md.
Wire the AI pipeline to the tRPC routers:
1. Connect ai.extractRequirements to the requirement-extractor prompt and file processor
2. Connect ai.generateSection to the section-generator prompt and KB search
3. Connect ai.matchContent to the pgvector semantic search
4. Connect kb.create to the file upload + embedding pipeline
5. Add Stripe checkout and webhook handler for 4 tiers
Run npx tsc --noEmit when done.
```

**And in a parallel session** — the editor and export:
```
Read docs/architecture/002-system-architecture.md.
Build the proposal editor and export:
1. Tiptap rich-text editor with AI content injection
2. Split layout: requirements sidebar, editor, KB search panel
3. "Generate" button per section with SSE streaming
4. Export to PDF and DOCX
5. Brand voice configuration page
Run npx tsc --noEmit when done.
```

---

## Phase 5: Quality Gates

### /review (Opus)

**Prompt**: `/review` (no additional arguments — the command knows what to do)

**Result**: 🔴 Needs Rework — found 7 blockers, 10 should-fixes, 6 nits

**Critical findings**:
| ID | Issue | Location |
|---|---|---|
| B1 | Zero auth on API routes (stream-section, upload) | src/app/api/ |
| B2 | Hardcoded "demo-org" in proposal editor | proposals/[id]/page.tsx:87 |
| B3 | Prompt injection via KB content and brand voice | generate-section.ts, stream-section route |
| B4 | Proposal editor using hardcoded demo data, not DB | proposals/[id]/page.tsx:23-69 |
| B5 | Unsafe type assertion on AI stream output | use-section-generation.ts:92 |
| B6 | No error boundaries | proposals/[id]/page.tsx |
| B7 | Zero test coverage | Project-wide |

**Fix session** (single Sonnet prompt listing all 6 fixable blockers):
```
Fix these 7 blockers in order:
B1. AUTH ON API ROUTES: Wire auth() from @clerk/nextjs/server...
B2. HARDCODED ORG ID: Remove const ORG_ID = "demo-org"...
B3. PROMPT INJECTION: Apply sanitizeForPrompt() to ALL user-sourced content...
B4. WIRE REAL DATA: Replace hardcoded arrays with trpc.proposal.get()...
B5. VALIDATE STREAM OUTPUT: Validate with SectionGeneratorOutputSchema.safeParse()...
B6. ERROR BOUNDARIES: Create error.tsx files...
Run npx tsc --noEmit after all fixes.
```

### /security (Opus after /clear)

**Result**: 5 security findings, all resolved in one session

| ID | Fix Applied |
|---|---|
| SEC-001 | Security headers (CSP, HSTS, X-Frame-Options) |
| SEC-002 | Stripe webhook deduplication with DB transaction |
| SEC-003 | orgProtectedProcedure middleware on all routers |
| SEC-004 | Rate limiting (20/min AI, 50/hr uploads) |
| SEC-006 | Centralized env validation at import time |

### /ship (Opus after /clear)

**Result**: SHIP WITH KNOWN ISSUES

- Build: ✅ PASS
- TypeScript: ✅ PASS (zero errors)
- Secrets scan: ✅ PASS
- Security: ✅ PASS (all 5 findings resolved)
- Known issues: no ESLint config, no test suite, npm audit vulns in Prisma deps, in-memory rate limiter

---

## Phase 6: The /validate Discovery

**This is the most important part of the case study.**

The app passed /review, /security, and /ship. All green. We deployed and opened the browser.

**What we found**:
- Dashboard showed 7 fake proposals ("Digital Transformation Initiative", "Cloud Migration Strategy")
- "+ New Proposal" button did nothing
- No Clerk auth requests — middleware wasn't protecting routes
- Zero tRPC calls on page load — all data was hardcoded
- Proposal rows weren't clickable

**The realization**: Every quality gate checked code on disk. None of them started the app and verified it actually worked. This gap exists in every Claude Code workflow repo we surveyed (25+ repos checked).

**What we built**: The `/validate` command — a runtime verification engineer that:
1. Checks env vars aren't placeholders
2. Tests database connectivity
3. Reads every page's source code looking for hardcoded demo data
4. Verifies auth middleware protects routes
5. Checks every tRPC procedure uses server-side org ID (not client-supplied)
6. Tests the new user lifecycle (sign up → first page → first action)
7. Verifies AI pipeline configuration
8. Checks CSP headers allow all required domains

**First /validate run found**:
- ❌ IDOR in ai.ts — 6 procedures accepted client-supplied orgId
- ❌ Onboarding was a setTimeout mock with DEMO_TEXT
- ❌ No Organization record auto-created for new users
- ❌ GenerateContext leaked client-supplied orgId
- ❌ .env.example referenced removed Anthropic vars
- ❌ CSP blocked Clerk's JavaScript

Every one of these would have been a production incident. None were caught by /review, /security, or /ship.

---

## Phase 7: Context and Memory Management

### How We Kept Context Fresh

**Rule 1: /clear between every major task.** The architecture docs on disk ARE the context. Claude reads them fresh each session. A bloated 150K-token context window performs worse than a clean one.

**Rule 2: Architecture docs are the shared brain.** Every command reads from `docs/architecture/`. This is why the workflow creates these documents — they serve as persistent context that survives /clear and new sessions.

**Rule 3: Commit after every task.** Git history is memory. If Claude Code crashes (it did — Cursor crashed mid-session), the code changes are on disk. We lost the session but not the work.

**Rule 4: One task per prompt.** "Build everything" produces worse results than "Build the Prisma schema with all models from the data model section." Focused prompts → focused output → less wasted tokens.

**Token budget for the entire build**:
| Phase | Model | Approx Tokens | Approx Cost |
|---|---|---|---|
| /explore | Opus | 61K | ~$1.80 |
| /architect + /plan | Skipped (pre-built docs) | 0 | $0 |
| 3 parallel /implement sessions | Sonnet | ~180K total | ~$1.08 |
| Wiring session | Sonnet | ~60K | ~$0.36 |
| /review | Opus | ~50K | ~$1.50 |
| Fix blockers | Sonnet | ~40K | ~$0.24 |
| /security | Opus | ~40K | ~$1.20 |
| /ship | Opus | ~30K | ~$0.90 |
| /validate | Sonnet | ~40K | ~$0.24 |
| Fix /validate findings | Sonnet | ~40K | ~$0.24 |
| **Total** | | **~541K** | **~$7.56** |

**Lesson learned**: Opus for thinking (/explore, /review, /security), Sonnet for building (/implement, fixes). This split saved ~$30 compared to running everything on Opus.

---

## What Went Wrong (Honest Failures)

### 1. The AI provider swap mid-build
We started with Anthropic SDK but had no API credits. Switched to Google Gemini mid-build. The Claude Code session crashed during the swap (Cursor IDE crashed). Recovery: checked `git status`, found the files were saved to disk, fixed 2 TypeScript errors manually (`systemInstruction` format difference between SDKs), committed, continued.

**Lesson**: Pick your AI provider before /implement. Swapping mid-build is risky.

### 2. Prisma v6 breaking change
Prisma v6 changed how `url` and `directUrl` work in the schema. Claude Code tried to "fix" it by removing `url` entirely (following Prisma 7 docs), which broke migrations. We had to revert and explicitly tell Claude "Prisma v6 still requires url in the datasource block."

**Lesson**: When Claude Code makes a "fix" that breaks something, check the actual version of the dependency before accepting. `npx prisma --version` would have caught this.

### 3. CSP blocking Clerk
The /security command added strict Content-Security-Policy headers. These blocked Clerk's JavaScript from loading (from `*.clerk.accounts.dev`). The app showed a blank white page with a `ClerkRuntimeError` in the console.

**Lesson**: When /security adds CSP headers, immediately test that your auth provider and AI provider still work. The security command doesn't know your runtime dependencies.

### 4. The database password placeholder
The `.env.local` had `[YOUR-PASSWORD]` as a placeholder. Prisma silently failed. The app showed data from the empty database (which looked like "no data" — not an obvious error).

**Lesson**: /validate Phase 1.1 now checks for placeholder patterns in env files. But the real lesson: always verify DB connectivity with `npx prisma db execute --stdin <<< "SELECT 1;"` after setting up credentials.

### 5. Supabase connection strings confusion
Supabase provides two connection strings: pooled (port 6543 via PgBouncer) and direct (port 5432). Prisma migrations require the direct connection. The pooled connection hangs during DDL operations. We spent 15 minutes debugging a "stuck migration" before realizing the URL was wrong.

**Lesson**: DATABASE_URL (pooled, port 6543) is for the app. DIRECT_URL (direct, port 5432, different hostname) is for migrations. Always verify both.

---

## The Complete Command Sequence (Copy-Paste Ready)

For anyone wanting to replicate this build, here's the exact sequence:

```bash
# 1. Clone the workflow
git clone https://github.com/daniyalmalikoo7/claude-workflow-ai-saas.git proposalpilot
cd proposalpilot && rm -rf .git && git init

# 2. Customize CLAUDE.md (replace placeholders)

# 3. Start Claude Code
claude

# 4. Domain exploration (Opus)
/explore [paste your product description]

# 5. Switch to Sonnet for implementation
/model sonnet

# 6. Architecture (or skip if you have pre-built docs)
/architect
/plan

# 7. Implement in parallel sessions (3 terminals)
# Terminal 1: Foundation (schema, auth, billing)
# Terminal 2: AI pipeline (processing, prompts, fallback)
# Terminal 3: UI (pages, components, styling)

# 8. After each session: commit
git add -A && git commit -m "feat: [what was built]"

# 9. Quality gates (Opus, /clear between each)
/clear && /review
# Fix blockers, commit
/clear && /security
# Fix findings, commit
/clear && /ship

# 10. Runtime verification (the command that catches what static analysis misses)
/clear && /validate
# Fix all findings, commit

# 11. User flow testing
/clear && /qa
# Fix broken flows, commit

# 12. Context health check
/clear && /context-check
# Update stale docs, commit

# 13. Final ship
/clear && /ship
# Green? Deploy.
```

---

## Results

**What was built**: A complete AI-powered SaaS product with auth, billing, AI generation, rich text editing, file processing, semantic search, and multi-tenant data isolation.

**What the workflow caught**: 7 code-level blockers (via /review), 5 security issues (via /security), 6 runtime failures (via /validate) including a critical IDOR vulnerability that static analysis missed entirely.

**What the workflow missed**: Runtime failures — until we built /validate. UI/UX quality — until we built /qa. Context staleness — until we built /context-check. Each gap became a new command.

**The workflow is better because we used it.** Every failure mode discovered during this build is now a check in one of the 17 commands. That's the point of battle-testing — not to prove the workflow is perfect, but to make it better through real use.
