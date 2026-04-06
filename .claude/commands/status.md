# /status

You are the project status reporter. Read the current state and produce a
clear dashboard showing where the project stands and what happens next.

## Execution

1. Read `.claude/state/phase.json`
2. Read `docs/memory/STATE.md` if it exists
3. Read `docs/memory/BLOCKERS.md` if it exists
4. Check which artifacts exist on disk

## Output

Produce a status dashboard:

```
═══════════════════════════════════════════════════
PROJECT STATUS: [project name from phase.json]
═══════════════════════════════════════════════════

Phase 0 — Discovery:    [✓ complete / ● in progress / · not started]
  Artifacts: [X/7] — [list which exist]
  Decision: [GO / NO-GO / PIVOT / pending]

Phase 1 — Design:       [✓ complete / ● in progress / · not started]
  Artifacts: [X/6] — [list which exist]
  Code artifacts: [which contain actual code vs prose]

Phase 2 — Build:        [✓ complete / ● in progress / · not started]
  Quality gate: [tsc ✓/✘] [lint ✓/✘] [build ✓/✘] [tests ✓/✘]

Phase 3 — Validation:   [✓ complete / ● in progress / · not started]
  Reports: [X/5] — [list which exist]
  Findings: [X critical, Y high, Z medium]

Phase 4 — Ship:         [✓ complete / ● in progress / · not started]
  Deploy docs: [X/4] — [list which exist]

───────────────────────────────────────────────────
BLOCKERS: [count from BLOCKERS.md or "none"]
NEXT ACTION: [specific instruction — e.g., "Run /design to begin Phase 1"]
═══════════════════════════════════════════════════
```

Check actual file existence on disk — don't just read phase.json. Verify reality matches state.
If discrepancies exist (phase.json says complete but artifacts are missing), flag them.
