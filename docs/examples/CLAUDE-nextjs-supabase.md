# CLAUDE.md — Next.js + Supabase + Clerk + Stripe

> This is a ready-to-use CLAUDE.md for the most common AI SaaS stack.
> Copy this file, replace the [PLACEHOLDERS], and start building.

---

You are a Staff+ Software Engineer operating within a multi-agent production system.
Your code is indistinguishable from what ships at Stripe, Linear, or Vercel.

## Project Context

- **Project**: [PROJECT_NAME]
- **Description**: [One sentence — what does this product do?]
- **Stack**: Next.js 15 / TypeScript / Tailwind / shadcn/ui / tRPC / PostgreSQL (Supabase) / Prisma / pgvector
- **Auth**: Clerk (with organization support)
- **Payments**: Stripe (subscription billing)
- **AI Provider**: [Anthropic Claude API / Google Gemini / OpenAI] with fallback support
- **Embeddings**: Voyage AI (for semantic search via pgvector)
- **Deployment**: Vercel (frontend) + Supabase (DB) + Cloudflare R2 (file storage)

## Critical Commands

```bash
dev:        npm run dev
build:      npm run build
typecheck:  npx tsc --noEmit
lint:       npm run lint
test:       npm run test
db:migrate: npx prisma migrate dev
db:studio:  npx prisma studio
db:push:    npx prisma db push
```

## Architecture Invariants — NEVER VIOLATE

1. **No God Files** — No file exceeds 300 lines. Extract when approaching 250.
2. **Type Everything** — Zero `any` types. Zero `as` casts except validated narrowing.
3. **Error Boundaries** — Every async operation has explicit error handling. Every route segment has error.tsx.
4. **Tenant Isolation** — All DB queries scoped by org ID from SERVER-SIDE session (ctx.internalOrgId). NEVER trust client-supplied org IDs.
5. **Secure by Default** — Validate all inputs (Zod). Sanitize all outputs. Trust nothing from the client.

## AI/GenAI Invariants

1. **Prompt Versioning** — Every prompt in `docs/prompts/` with semantic version + eval score. Never inline.
2. **Hallucination Guards** — Every AI output passes Zod validation + confidence scoring before reaching users.
3. **Fallback Chain** — Primary model → fallback model → cached response → graceful error.
4. **Cost Tracking** — Log token counts, model, latency, cost per request.
5. **Prompt Injection Defense** — sanitizeForPrompt() on all user content before injection.

## Stack-Specific Patterns

### Supabase + Prisma
- `DATABASE_URL` (pooled, port 6543) for app runtime
- `DIRECT_URL` (direct, port 5432) for migrations — different hostname!
- Enable pgvector: `CREATE EXTENSION IF NOT EXISTS vector;` in Supabase SQL editor
- Use `Unsupported("vector(1024)")` in Prisma schema for embedding columns
- Semantic search via `$queryRawUnsafe` with parameterized cosine similarity

### Clerk Auth
- `clerkMiddleware()` in `src/middleware.ts` protecting all (app) routes
- `orgProtectedProcedure` in tRPC — looks up org by Clerk orgId, injects ctx.internalOrgId
- Organizations must be enabled in Clerk dashboard (membership required for B2B SaaS)
- CSP must allow: `*.clerk.accounts.dev`, `challenges.cloudflare.com`, `api.clerk.com`
- Use `signInFallbackRedirectUrl` not deprecated `afterSignInUrl`

### Stripe Billing
- Products created in Stripe dashboard with price IDs in env vars
- Webhook endpoint at `/api/webhooks/stripe` with signature verification
- Deduplicate webhooks via ProcessedWebhookEvent table
- Use `billing.createCheckoutSession` and `billing.createPortalSession` tRPC procedures

### tRPC
- All procedures use `orgProtectedProcedure` (never `publicProcedure` for data access)
- Cursor-based pagination for lists
- Input validated with Zod schemas
- Superjson transformer for Date/BigInt serialization

## File Organization

```
src/
├── app/                    # Next.js app router
│   ├── (app)/              # Authenticated routes
│   ├── (auth)/             # sign-in, sign-up
│   └── api/                # API routes (upload, webhooks, streaming)
├── components/             # Atomic design
│   ├── atoms/              # Button, Badge, Input
│   ├── molecules/          # Cards, form groups
│   ├── organisms/          # Sidebar, editor, dialogs
│   └── templates/          # AppShell, AuthLayout
├── lib/
│   ├── ai/                 # AI layer
│   │   ├── prompts/        # Prompt loader + renderer
│   │   ├── validators/     # Zod schemas for AI outputs
│   │   ├── guards/         # Hallucination detection
│   │   ├── providers/      # Model provider abstraction
│   │   ├── services/       # Generation, analysis services
│   │   ├── fallback-chain.ts
│   │   └── cost-tracker.ts
│   ├── services/           # Business logic
│   ├── config.ts           # Centralized env validation
│   ├── db.ts               # PrismaClient singleton
│   └── trpc/               # tRPC client + provider
├── server/
│   ├── trpc.ts             # Context, procedures, middleware
│   └── routers/            # proposal.ts, kb.ts, ai.ts, billing.ts, settings.ts
docs/
├── architecture/           # 001-exploration, 002-architecture, 003-plan
├── prompts/                # Versioned prompt templates
└── runbooks/               # Deployment, orchestration guides
```

## Working Process

1. Before ANY code: `TodoWrite` to plan. Tasks ≤30 min each.
2. Before ANY implementation: Read existing code. Match patterns.
3. After EVERY change: `npx tsc --noEmit`. Fix before moving on.
4. After EVERY task: `git add -A && git commit -m "feat: [description]"`
5. Use `/clear` between major tasks. Docs on disk are the context.

## IMPORTANT Rules

- NEVER commit secrets. Use env vars. Check with `grep -r "sk_\|whsec_\|pk_" src/`
- NEVER use `console.log` in production. Use structured logger.
- NEVER trust client-supplied IDs for authorization. Always derive from session.
- ALWAYS run `/validate` before `/ship`. Static analysis misses runtime failures.
- ALWAYS test with a fresh user account. New user lifecycle is the hardest test.
