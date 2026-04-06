# /ship

You are the Phase 4 orchestrator — Ship & Operate. All validation reports pass.
The user is about to approve deployment. This is USER DECISION #3.

## Pre-flight

1. Verify Phase 3 complete: check `.claude/state/phase.json` and all 5 validation reports exist.
2. Verify zero CRITICAL/HIGH findings across all reports.
3. Update phase.json: set phase 4 to `"in-progress"`, `currentPhase` to `4`.

## Execution — 4 agents, sequential

### Agent 1: Release Manager
- File: `.claude/agents/phase-4/release-manager.md`
- Produce: `docs/deploy/release-runbook.md`
- Key action: Create deployment runbook, rollback procedure, health checks.

### Agent 2: Monitoring Engineer
- File: `.claude/agents/phase-4/monitoring-engineer.md`
- Produce: `docs/deploy/monitoring-setup.md`
- Key action: Configure error tracking, analytics, SLOs, alerts.

### Agent 3: Cost Engineer
- File: `.claude/agents/phase-4/cost-engineer.md`
- Produce: `docs/deploy/cost-analysis.md`
- Key action: Per-request AI cost, projections, budget alerts, unit economics.

### Agent 4: Growth Analyst
- File: `.claude/agents/phase-4/growth-analyst.md`
- Produce: `docs/deploy/growth-plan.md`
- Key action: KPI dashboard, analytics funnel, feedback collection, iteration triggers.

## Post-flight

1. Update phase.json: phase 4 = complete, all artifact paths recorded.

2. Present the deployment decision:
   ```
   ═══════════════════════════════════════════════════
   PHASE 4 COMPLETE — Ready to Ship
   ═══════════════════════════════════════════════════

   Deployment Runbook:  docs/deploy/release-runbook.md
   Monitoring Setup:    docs/deploy/monitoring-setup.md
   Cost Analysis:       docs/deploy/cost-analysis.md
   Growth Plan:         docs/deploy/growth-plan.md

   USER DECISION #3: Approve deployment?

   To deploy:
   1. Review docs/deploy/release-runbook.md
   2. Follow the deployment steps exactly
   3. Run post-deploy smoke tests
   4. Verify monitoring is receiving data

   This product was built through 5 SDLC phases:
   Phase 0: Discovery — 7 agents produced Go/No-Go decision
   Phase 1: Design — 6 agents produced technical blueprint
   Phase 2: Build — 6 agents produced production codebase
   Phase 3: Validation — 5 agents verified quality
   Phase 4: Ship — 4 agents prepared deployment

   → The system is ready. Deploy when you're ready.
   ```
