# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.1.0] — 2026-03-31

### Added
- `/validate` command — runtime verification that actually tests if the app works. Checks database connectivity, env vars, page wiring (detects hardcoded demo data, dead buttons, mocked flows), tenant isolation (IDOR detection), new user lifecycle, AI pipeline, and CSP configuration. Bridges the gap between "compiles" and "works" that all other commands miss.

### Changed
- Orchestration workflow: `/validate` added to Phase 7 pre-launch sequence between `/monitor` and `/ship`
- README: updated to 15 commands, added /validate to command table and workflow diagram

### Lessons Learned
- During real-world testing of ProposalPilot, the app passed /review, /security, and /ship but was fundamentally broken: hardcoded demo data on every page, auth middleware not protecting routes, buttons that triggered no actions, onboarding was a UI mock, IDOR in 6 API procedures. All of these would have been caught by /validate.

## [2.0.0] — 2026-03-28

### Added
- `/monitor` command — observability setup and health review (structured logger, Sentry, PostHog, AI metrics, cost alerts)
- `/memory` command — persistent memory management across sessions (file-based + MCP memory server)
- `logging-monitoring` skill — structured logger implementation, AI call logger, monitoring setup patterns, alert rules
- `error-handling` skill — typed AppError hierarchy, React error boundaries, API error wrapper, AI retry-with-backoff
- `context-management` skill — token counting (tiktoken), budget enforcement, FIFO and relevance-based truncation
- `docs/prompts/example-feature.v1.md` — starter prompt template with metadata, system/user messages, output schema
- `.github/workflows/ci.yml` — CI/CD pipeline with typecheck, lint, test, security audit, AI evals, staged deploy
- `LICENSE` — MIT license file
- `CHANGELOG.md` — this file
- `CONTRIBUTING.md` — contribution guidelines

### Changed
- `CLAUDE.md` — IMPORTANT rules now reference specific skill files, added /memory and /monitor rules
- `settings.json` — added Write(.github/**) and Write(CLAUDE.md) permissions, removed invalid env var
- `README.md` — updated counts (14 commands, 5 skills), added /monitor and /memory to tables, fixed Quick Start
- `orchestration-workflow.md` — added /monitor to Phase 7, /memory to maintenance workflows
- `security-scanner.mjs` — narrowed .env pattern to only block actual read/write operations
- `.env.example` — added monitoring env vars with descriptions, AI cost alert thresholds

### Fixed
- Quick Start copy commands missing .github/ and .gitignore
- README counts stale (said 10 commands / 3 skills, actual was 14 / 5)

## [1.0.0] — 2026-03-27

### Added
- Initial release
- 12 slash commands: /explore, /architect, /plan, /implement, /design-ui, /test, /review, /security, /prompt-engineer, /debug, /commit, /ship
- 5 subagents: librarian, reviewer, qa, devops, performance
- 2 skills: ai-integration, database
- 3 hooks: pre-write-guard, security-scanner, session-logger
- CLAUDE.md with architecture invariants, AI/GenAI invariants, code style, file organization
- settings.json with permissions allow/deny lists and hook configuration
- .mcp.json with GitHub, Playwright, Memory, Filesystem servers
- .env.example with all environment variables documented
- docs/runbooks/orchestration-workflow.md — complete Phase 1-8 build workflow
