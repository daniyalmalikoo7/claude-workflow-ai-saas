# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.2.0] — 2026-03-31

### Added
- `/qa` command — end-to-end quality assurance from a real user's perspective. Tests every user flow: sign-up → onboarding → core features → edge cases → mobile responsive. Reports visual issues, accessibility violations, and broken flows. Complements `/validate` (infrastructure) with user-facing verification.
- `/context-check` command — audits Claude Code's context efficiency. Verifies CLAUDE.md accuracy against actual codebase, detects stale architecture docs, measures token budget usage, finds redundant instructions, and identifies missing project knowledge. Keeps the workflow's "brain" healthy.
- `.claude-plugin/plugin.json` — marketplace manifest enabling installation via `/plugin marketplace add daniyalmalikoo7/claude-workflow-ai-saas`
- `.claudeignore` — excludes node_modules, build artifacts, lock files, and static assets from Claude's context window, saving thousands of tokens per session
- Competitive positioning in README — clear comparison table showing differentiation from gstack, superpowers, and everything-claude-code

### Changed
- Complete README rewrite — leads with the value proposition ("the only Claude Code workflow built specifically for shipping AI-powered SaaS products"), includes battle-test results table, GenAI product layer documentation, and competitive comparison
- Command count: 15 → 17 (added /qa and /context-check)

### Quality Gates (Updated Workflow)
The pre-launch sequence is now:
```
/review          → Static code quality (reads code)
/security        → Static security audit (reads code)
/test            → Write test suite (reads code)
/monitor         → Set up observability (configures infra)
/validate        → Runtime infrastructure verification (runs the app)
/qa              → End-to-end user flow testing (uses the app)
/context-check   → Verify Claude's context is accurate and efficient
/ship            → Final deployment gate
```

## [2.1.0] — 2026-03-31

### Added
- `/validate` command — runtime verification that actually tests if the app works. Checks database connectivity, env vars, page wiring (detects hardcoded demo data, dead buttons, mocked flows), tenant isolation (IDOR detection), new user lifecycle, AI pipeline, and CSP configuration. Bridges the gap between "compiles" and "works" that all other commands miss.

### Changed
- Orchestration workflow: `/validate` added to Phase 7 pre-launch sequence between `/monitor` and `/ship`
- README: updated to 15 commands, added /validate to command table and workflow diagram

### Fixed
- Removed invalid `PostResponse` hook event from `settings.json` — only `PreToolUse`, `PostToolUse`, `Notification`, and `Stop` are valid Claude Code hook events

### Lessons Learned
- During real-world testing of ProposalPilot, the app passed /review, /security, and /ship but was fundamentally broken: hardcoded demo data on every page, auth middleware not protecting routes, buttons that triggered no actions, onboarding was a UI mock, IDOR in 6 API procedures. All of these would have been caught by /validate.

## [2.0.0] — 2026-03-28

### Added
- Initial release with 14 slash commands, 5 agents, 5 skills, 3 hooks, CI/CD pipeline
- GenAI product layer: prompt versioning, hallucination guards, fallback chains, eval pipelines, context budgets, cost tracking
- Complete orchestration workflow from /explore to /ship
- Synthesized patterns from obra/superpowers, garrytan/gstack, trailofbits/claude-code-config, Boris Cherny's setup, Builder.io guides, and Anthropic best practices
