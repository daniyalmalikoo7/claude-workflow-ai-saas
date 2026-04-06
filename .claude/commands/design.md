# /design

You are the Phase 1 orchestrator — Design & Architecture. Phase 0 (Discovery)
is complete. The user has reviewed the Go/No-Go decision and agreed to proceed.

## Pre-flight

1. Verify Phase 0 is complete: `bash .claude/hooks/phase-gate.sh` — if it blocks, stop and tell the user.
2. Check `.claude/state/phase.json` — phase 0 must be complete with decision GO.
3. Create `docs/design/` directory if it doesn't exist.
4. Update phase.json: set phase 1 to `"in-progress"`, `currentPhase` to `1`.

## Execution — 6 agents, sequential, validated

**CRITICAL: Same rules as /discover:**
- Read each agent file from disk before activation
- Write artifacts to disk immediately
- Later agents read prior artifacts from disk, not conversation memory
- Validate each artifact with artifact-validate.sh
- Retry up to 2 times if validation fails

### Agent 1: System Architect
- File: `.claude/agents/phase-1/system-architect.md`
- Read inputs: `docs/discovery/03-prd.md`, `docs/discovery/04-requirements.md`, `docs/discovery/06-risk-analysis.md`
- Produce: `docs/design/01-technical-design.md`

### Agent 2: UX Designer
- File: `.claude/agents/phase-1/ux-designer.md`
- Read inputs: `docs/discovery/03-prd.md`, `docs/discovery/01-domain-research.md`, `docs/discovery/04-requirements.md`
- Produce: `docs/design/02-ux-design.md`

### Agent 3: UI Designer
- File: `.claude/agents/phase-1/ui-designer.md`
- Read inputs: `docs/design/02-ux-design.md`, `docs/discovery/01-domain-research.md`
- Produce: `docs/design/03-design-system.md`
- **CRITICAL:** This artifact must contain actual Tailwind config code and CSS custom properties — not prose descriptions of colors. Validate by checking for `extend` or `theme` keywords.

### Agent 4: Security Architect
- File: `.claude/agents/phase-1/security-architect.md`
- Read inputs: `docs/design/01-technical-design.md`, `docs/discovery/04-requirements.md`
- Produce: `docs/design/04-security-design.md`
- **CRITICAL:** Must contain testable curl/test commands. Validate by checking for `curl` or `test` keywords.

### Agent 5: Data Architect
- File: `.claude/agents/phase-1/data-architect.md`
- Read inputs: `docs/design/01-technical-design.md`, `docs/discovery/03-prd.md`, `docs/discovery/06-risk-analysis.md`
- Produce: `docs/design/05-data-model.md`
- **CRITICAL:** Must contain actual Prisma schema code. Validate by checking for `model` and `@id` keywords.

### Agent 6: Performance Architect
- File: `.claude/agents/phase-1/performance-architect.md`
- Read inputs: `docs/design/01-technical-design.md`, `docs/design/05-data-model.md`, `docs/discovery/04-requirements.md`
- Produce: `docs/design/06-performance-spec.md`
- **CRITICAL:** Must contain P50/P95/P99 targets per endpoint.

## Post-flight

1. Update `.claude/state/phase.json`:
   - Set phase 1 status to `"complete"`, `completedAt` to current timestamp
   - Record all 6 artifact paths
   - Set `currentPhase` to `2`

2. Report summary:
   ```
   ═══════════════════════════════════════════════════
   PHASE 1 COMPLETE — Design & Architecture
   ═══════════════════════════════════════════════════
   ✓ System Architect:      01-technical-design.md (XXX words)
   ✓ UX Designer:           02-ux-design.md (XXX words)
   ✓ UI Designer:           03-design-system.md (XXX words) [contains code]
   ✓ Security Architect:    04-security-design.md (XXX words) [contains test commands]
   ✓ Data Architect:        05-data-model.md (XXX words) [contains Prisma schema]
   ✓ Performance Architect: 06-performance-spec.md (XXX words) [contains P50/P95/P99]

   → Review docs/design/01-technical-design.md (the technical design)
   → If you approve the design, run /build to begin Phase 2
   ```

   This is USER DECISION #2. The user reviews the technical design and approves or redirects.
