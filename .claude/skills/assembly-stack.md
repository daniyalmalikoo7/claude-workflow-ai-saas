# Assembly Stack — What We Use, What We Don't Build

This is the definitive reference for what already exists and must be used.
Every agent in every phase inherits this skill via CLAUDE.md.

The principle: **~20% custom code (your differentiator), ~80% assembled from
proven services and libraries.** Building infrastructure that exists as a
managed service is a waste of the only resource that matters: time.

---

## Component Library: Shadcn/ui

The UI foundation. Never build these from scratch.

**What Shadcn provides (use directly):**
Button, Card, Dialog, AlertDialog, DropdownMenu, Sheet, Tabs, Table,
DataTable (TanStack), Form (react-hook-form + zod), Input, Select,
Textarea, Command (cmdk), Toast (Sonner), Badge, Skeleton, Separator,
Tooltip, Popover, NavigationMenu, Sidebar, Avatar, Checkbox, Switch,
RadioGroup, Progress, ScrollArea, Accordion

**Setup:** `npx shadcn@latest init` then `npx shadcn@latest add [components]`

**Custom components are built BY COMPOSING Shadcn primitives:**
- ProposalEditor = Shadcn Card + Tiptap + Badge (confidence)
- KBUploader = Shadcn Dialog + Form + Button + Progress
- ConfidenceBadge = Shadcn Badge with semantic color tokens

**Complementary libraries (Shadcn-compatible):**
- Magic UI — animated landing page components
- Origin UI — pre-built application patterns
- Lucide Icons — icon library (Shadcn default)
- Framer Motion — complex animations when CSS transitions aren't enough

---

## Managed Services

| Need | Service | Free Tier | Don't Build |
|---|---|---|---|
| **Auth** | Clerk | 10K MAU | Login, signup, MFA, org management, session handling |
| **Database** | Supabase (Postgres + pgvector) | 500MB, 1GB storage | DB hosting, connection pooling, vector search infra |
| **Payments** | Stripe | Pay per transaction | Checkout, subscriptions, invoices, customer portal |
| **Hosting** | Vercel Pro | 100GB bandwidth | CDN, edge functions, preview deploys, cron, analytics |
| **Rate Limiting** | Upstash Redis + @upstash/ratelimit | 10K cmds/day | Rate limiting middleware, token buckets |
| **Background Jobs** | Inngest | 5K runs/month | Job queues, delayed execution, retries |
| **Email** | Resend + React Email | 3K emails/month | SMTP infrastructure, templates |
| **Error Tracking** | Sentry | 5K events/month | Error capture, source maps, alerting |
| **Analytics** | PostHog | 1M events/month | Funnels, session recording, feature flags |
| **File Storage** | Supabase Storage | Included | S3-compatible storage, signed URLs |
| **Real-time** | Supabase Realtime | Included | WebSocket infrastructure |
| **Cron** | Vercel Cron | Included | Scheduled tasks |
| **PDF Export** | @react-pdf/renderer | Open source | PDF generation |

**Use existing service UIs — don't redesign them:**
- Clerk: hosted sign-in/sign-up pages, user profile, org switcher
- Stripe: customer portal for subscription management, hosted checkout

---

## MCP Servers

MCPs give Claude Code direct access to infrastructure during development.

**Global (install once):**
```
claude mcp add github --scope user -- npx -y @modelcontextprotocol/server-github
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
claude mcp add brave-search --scope user -- npx -y @brave/brave-search-mcp-server
```

**Per-project (.mcp.json — committed to git):**
```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": { "SUPABASE_URL": "", "SUPABASE_SERVICE_ROLE_KEY": "" }
    },
    "stripe": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp"],
      "env": { "STRIPE_SECRET_KEY": "" }
    }
  }
}
```

---

## Technology Stack Defaults

| Layer | Default | Switch only if |
|---|---|---|
| Framework | Next.js 16+ (App Router) | Need non-React framework |
| Language | TypeScript strict | Non-negotiable |
| API | tRPC v11 | Public API needed (use REST) |
| ORM | Prisma 6+ | Need lighter ORM (use Drizzle) |
| Database | Supabase Postgres + pgvector | No vector search needed (use Neon) |
| Auth | Clerk | Must self-host auth (use Auth.js) |
| Payments | Stripe | Need simpler billing (use Lemon Squeezy) |
| UI | Shadcn/ui | Non-negotiable |
| AI Primary | Anthropic Claude | — |
| AI Fallback | OpenAI GPT-4o | Different provider = true redundancy |
| Embeddings | Voyage AI | OpenAI text-embedding-3-small |
| Hosting | Vercel | Need long-running processes (use Railway) |

Every deviation requires an ADR: what, why, alternatives, trade-offs, revisit conditions.

---

## The Assembly Test

Before any agent writes custom code:

1. **Does Shadcn provide it?** → Install and use it
2. **Does a managed service handle it?** → Integrate it
3. **Does an MCP server exist?** → Use it during development
4. **Does an npm package (>10K downloads/week, maintained) exist?** → Use it
5. **None of the above?** → Build custom. That's your differentiator.

---

## What IS Custom (the ~20%)

- AI generation logic (prompts, RAG pipeline, response formatting)
- Confidence scoring algorithm
- Domain-specific business rules
- Product-specific UI components (composed from Shadcn primitives)
- Integration glue between assembled services

Everything else is assembly.
