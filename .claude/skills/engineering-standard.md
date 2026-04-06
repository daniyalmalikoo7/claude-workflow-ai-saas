# Engineering Standard

This standard is inherited by every build and validation agent. Rules are
enforced by quality-gate.sh. Guidelines are enforced by agent mandates.

## Rules — machine-enforced, zero tolerance

These are checked by hooks. Violations block completion.

- **Zero `as any` casts.** Use proper types, generics, or `unknown` with type guards.
- **Zero empty catch blocks.** Every catch must log the error and either re-throw, return a fallback, or show user feedback.
- **TypeScript strict mode.** `npx tsc --noEmit` must pass clean. No `@ts-ignore`.
- **Lint clean.** `npm run lint` must pass with zero warnings treated as errors.
- **Build clean.** `npm run build` must succeed.
- **No hardcoded secrets.** API keys, passwords, tokens in code = blocked by security-scanner.sh.
- **No console.log in production code.** Use structured logging or console.error for genuine errors.

## Guidelines — agent-enforced

These are checked during code review. Not machine-checkable but always followed.

- **Files under 300 lines.** Extract components/utilities at 250. Exceptions: generated code, test suites, schema files.
- **No business logic in UI components.** Components render state. Hooks and services compute state. Never mix.
- **Every async operation has explicit error handling** with user-visible feedback — toast, error boundary, or inline error state. Silent failures are bugs.
- **Every external API call has:** timeout (30s default), retry with backoff (3 attempts), fallback behavior, error toast on failure.
- **Single Responsibility.** One file = one concern. One function = one job. If the name needs "and" you need two functions.
- **Name for behavior, not structure.** `useProposalGeneration` not `useData`. `validateRequirements` not `processInput`.
- **No prop drilling beyond 2 levels.** Use context, composition, or state management.
- **Every database query is scoped.** Multi-tenant: always filter by organizationId from session. Never trust client-provided IDs for authorization.
- **Test behavior, not implementation.** Test what the user sees and does, not internal state transitions.

## File organization

```
src/
├── app/              # Next.js routes — thin, delegate to components
├── components/
│   ├── ui/           # Primitive components (Button, Input, Card)
│   ├── features/     # Feature-specific composites (ProposalEditor, KBUploader)
│   └── layouts/      # Page layouts, navigation, sidebar
├── server/
│   ├── routers/      # tRPC routers — one per domain (proposal, kb, billing)
│   └── services/     # Business logic — pure functions, testable
├── lib/
│   ├── ai/           # LLM integration, prompt management, eval
│   ├── utils/        # Pure utility functions
│   └── hooks/        # Custom React hooks
└── types/            # Shared TypeScript types and Zod schemas
```

## Commit convention

Format: `type(scope): description`
Types: feat, fix, docs, test, refactor, chore, perf
Scopes: app, api, db, ai, ui, auth, billing, infra
