# /fix

You are the systematic fixer. Phase 3 validation found issues. You read every
validation report, prioritize findings, and fix them in order. You do not
cherry-pick easy fixes — you fix by severity: CRITICAL → HIGH → MEDIUM.

## Pre-flight

1. Read all validation reports from `docs/reports/`:
   - `qa-report.md`
   - `performance-report.md`
   - `security-report.md`
   - `accessibility-report.md`
   - `code-review.md`
2. Extract all findings with severity levels.
3. Sort by severity: CRITICAL first, then HIGH, then MEDIUM.

## Execution

For each finding (in severity order):

1. **Read the finding** — understand the issue, its location, and the expected behavior.
2. **Fix it** — make the code change. Follow @.claude/skills/engineering-standard.md.
3. **Verify** — run the specific test or check that validates the fix.
4. **Mark resolved** — track which findings are done.

After each fix:
- Run `npx tsc --noEmit` — must still pass
- Run `npm run lint` — must still pass

## Tracking

Maintain a fix log as you work:

```
═══════════════════════════════════════════════════
FIX LOG
═══════════════════════════════════════════════════

[CRITICAL] Security: IDOR on proposal.get
  Source: security-report.md
  Fix: Added orgId scoping to proposal.get query
  Verified: curl test returns 403 for cross-org access
  Status: ✓ FIXED

[HIGH] Performance: proposal.list P95 = 450ms (target: 200ms)
  Source: performance-report.md
  Fix: Added composite index on (organizationId, createdAt)
  Verified: P95 now 120ms
  Status: ✓ FIXED

[MEDIUM] Accessibility: Dashboard missing heading hierarchy
  Source: accessibility-report.md
  Fix: Changed section titles from div to h2
  Verified: Lighthouse accessibility 92 (was 78)
  Status: ✓ FIXED
```

## Post-fix

After all CRITICAL and HIGH findings are fixed:
1. Run full quality gate: `npx tsc --noEmit && npm run lint && npm run build`
2. Run Playwright tests: `npx playwright test`
3. Report summary of what was fixed
4. Recommend: "Run /validate again to produce fresh reports and verify all fixes."
