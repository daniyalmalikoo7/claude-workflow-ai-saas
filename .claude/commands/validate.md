# /validate

You are the Phase 3 orchestrator — Validation. The codebase is built. Now we
prove it meets the spec. Each validation agent measures against a specific
Phase 1 design artifact. Nothing ships without all 5 reports.

## Pre-flight

1. Verify Phase 2 complete: check `.claude/state/phase.json`.
2. Verify code quality: run `npx tsc --noEmit && npm run lint && npm run build`. All must pass.
3. Create `docs/reports/` directory if it doesn't exist.
4. Update phase.json: set phase 3 to `"in-progress"`, `currentPhase` to `3`.

## Execution — 5 agents, sequential

Each validation agent produces an independent report. A security failure
doesn't get waived because performance looks good. All 5 must pass.

### Agent 1: QA Lead
- File: `.claude/agents/phase-3/qa-lead.md`
- Measures against: `docs/discovery/03-prd.md` (user stories, acceptance criteria)
- Produce: `docs/reports/qa-report.md`
- Key action: Run `npx playwright test --reporter=html`. Report pass/fail rate.

### Agent 2: Performance Engineer
- File: `.claude/agents/phase-3/performance-engineer.md`
- Measures against: `docs/design/06-performance-spec.md` (P50/P95/P99 targets)
- Produce: `docs/reports/performance-report.md`
- Key action: Measure every endpoint against targets. Report PASS/FAIL per endpoint.

### Agent 3: Security Engineer
- File: `.claude/agents/phase-3/security-engineer.md`
- Measures against: `docs/design/04-security-design.md` (threat model, test commands)
- Produce: `docs/reports/security-report.md`
- Key action: Run every test command from the security design. Report PASS/FAIL per threat.

### Agent 4: Accessibility Engineer
- File: `.claude/agents/phase-3/accessibility-engineer.md`
- Measures against: `docs/design/03-design-system.md` (contrast ratios, touch targets)
- Produce: `docs/reports/accessibility-report.md`
- Key action: Run Lighthouse accessibility on every page. Report scores.

### Agent 5: Code Reviewer
- File: `.claude/agents/phase-3/code-reviewer.md`
- Measures against: @.claude/skills/engineering-standard.md
- Produce: `docs/reports/code-review.md`
- Key action: Audit code against standards. Report ship/fix/block verdict.

## Post-flight

1. Count findings by severity across all 5 reports:
   - CRITICAL: blocks ship. Must fix.
   - HIGH: blocks ship. Must fix.
   - MEDIUM: should fix. Doesn't block.
   - LOW: nice to fix. Track for later.

2. Update `.claude/state/phase.json`:
   - If zero CRITICAL and zero HIGH: phase 3 = complete, `currentPhase` = 4
   - If any CRITICAL or HIGH: phase 3 remains `"in-progress"`

3. Report:
   ```
   ═══════════════════════════════════════════════════
   PHASE 3 — Validation Results
   ═══════════════════════════════════════════════════
   QA:            [X passed, Y failed] — [PASS/FAIL]
   Performance:   [X endpoints within budget] — [PASS/FAIL]
   Security:      [X threats tested, Y vulnerabilities] — [PASS/FAIL]
   Accessibility: [Lighthouse scores per page] — [PASS/FAIL]
   Code Review:   [Verdict: ship/fix/block]

   Findings: X CRITICAL, Y HIGH, Z MEDIUM, W LOW

   [If all pass]: → Run /ship to begin Phase 4
   [If failures]:  → Run /fix to address findings systematically
   ```
