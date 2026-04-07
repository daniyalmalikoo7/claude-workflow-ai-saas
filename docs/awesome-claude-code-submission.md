# awesome-claude-code Submission

## PR Title
Add claude-workflow-ai-saas — 28-agent SDLC pipeline with enforced phase gates

## Category
Workflows

## Entry
```markdown
- [claude-workflow-ai-saas](https://github.com/daniyalmalikoo7/claude-workflow-ai-saas) — 28-agent SDLC pipeline for AI-native SaaS. 5 phases (Discovery → Design → Build → Validate → Ship), enforced phase gates via shell hooks, assembly-first defaults (Shadcn, Clerk, Stripe, Supabase), artifact validation with retry, and adversarial Go/No-Go gate. Tested: produces 30K+ words of principal-level specification per product from 2 commands.
```

## Description for PR Body

### What this adds

A complete Claude Code workflow for building AI-native SaaS products. Unlike existing workflows that focus on code quality, this one encodes the full SDLC — starting with "should we build this?" before any code is written.

### Key differentiators from existing entries

1. **Pre-build phases**: 7 discovery agents (Domain Researcher, Business Strategist, Product Expert, Business Analyst, Due Diligence Engineer, Technical Risk Analyst, Devil's Advocate) run before any design or code.

2. **Enforced phase gates**: Shell scripts with exit code 2 block premature phase transitions. You cannot `/build` before `/design` completes. Claude cannot bypass this through conversation.

3. **Assembly-first defaults**: Single source of truth skill file specifying Shadcn/ui, Clerk, Stripe, Supabase, Upstash, Inngest, Resend, Sentry, PostHog as defaults. Agents build only product differentiators, not infrastructure.

4. **Phase 1 produces code, not prose**: UI Designer outputs Shadcn install list + CSS variable overrides. Security Architect outputs curl test commands. Data Architect outputs Prisma schema. Performance Architect outputs P50/P95/P99 targets per endpoint.

5. **Artifact validation with retry**: `artifact-validate.sh` checks content quality (required sections, minimum depth, domain-specific patterns), not just file existence. Commands retry agents whose output fails validation.

### Tested results

- AI Proposal Generator: 12,295 words across 7 Phase 0 artifacts, conditional GO with pricing inconsistency caught
- SOC 2 Compliance Platform: 32,553 words across 13 Phase 0+1 artifacts, 17 Prisma models, 11 security test scripts

### Stats

- 28 agents across 5 phases
- 7 slash commands
- 7 enforcement hooks
- 6 skill files
- MIT license
