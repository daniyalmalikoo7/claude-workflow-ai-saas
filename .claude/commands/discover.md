# /discover

You are the Phase 0 orchestrator — Discovery & Strategy. The user has provided this idea:

**"$ARGUMENTS"**

Your job: activate 7 agents in sequence. Each produces one artifact. Each artifact
is validated before proceeding. Write artifacts to disk immediately — later agents
read prior artifacts from disk, not from conversation history.

## Pre-flight

1. Create `docs/discovery/` directory if it doesn't exist.
2. Create `.claude/state/phase.json` from `.claude/state/phase.json.template` if it doesn't exist. Set project name from the idea. Set phase 0 to `"in-progress"` with current timestamp.

## Execution — 7 agents, sequential, validated

**CRITICAL: For each agent below:**
a. Read the agent file from disk: `cat .claude/agents/phase-0/[agent].md`
b. Fully adopt that agent's identity, mandate, and output format
c. Write the artifact to disk immediately after producing it
d. Validate: `bash .claude/hooks/artifact-validate.sh [artifact-path]`
e. If validation BLOCKS: re-read the agent file, identify what's missing, produce again (max 2 retries)
f. Report: `✓ [Agent Name]: [artifact-path] ([word count] words)`
g. Move to next agent

**CRITICAL: When an agent's inputs include a prior artifact, read it from disk with `cat docs/discovery/[file]` — do NOT rely on conversation memory.**

### Agent 1: Domain Researcher
- File: `.claude/agents/phase-0/domain-researcher.md`
- Produce: `docs/discovery/01-domain-research.md`

### Agent 2: Business Strategist
- File: `.claude/agents/phase-0/business-strategist.md`
- Read input: `docs/discovery/01-domain-research.md`
- Produce: `docs/discovery/02-strategy-brief.md`

### Agent 3: Product Expert
- File: `.claude/agents/phase-0/product-expert.md`
- Read inputs: `docs/discovery/01-domain-research.md`, `docs/discovery/02-strategy-brief.md`
- Produce: `docs/discovery/03-prd.md`

### Agent 4: Business Analyst
- File: `.claude/agents/phase-0/business-analyst.md`
- Read inputs: `docs/discovery/03-prd.md`, `docs/discovery/01-domain-research.md`, `docs/discovery/02-strategy-brief.md`
- Produce: `docs/discovery/04-requirements.md`

### Agent 5: Due Diligence Engineer
- File: `.claude/agents/phase-0/due-diligence-engineer.md`
- Read inputs: `docs/discovery/01-domain-research.md`, `docs/discovery/03-prd.md`, `docs/discovery/04-requirements.md`
- Produce: `docs/discovery/05-feasibility.md`

### Agent 6: Technical Risk Analyst
- File: `.claude/agents/phase-0/technical-risk-analyst.md`
- Read inputs: `docs/discovery/05-feasibility.md`, `docs/discovery/01-domain-research.md`, `docs/discovery/04-requirements.md`
- Produce: `docs/discovery/06-risk-analysis.md`

### Agent 7: Devil's Advocate
- File: `.claude/agents/phase-0/devils-advocate.md`
- Read inputs: ALL 6 artifacts above (read each from disk)
- Produce: `docs/discovery/07-go-nogo.md`
- **ADDITIONAL CHECK:** Verify file contains "GO", "NO-GO", or "PIVOT"

## Post-flight

1. Update `.claude/state/phase.json`:
   - Set phase 0 status to `"complete"`
   - Set `completedAt` to current timestamp
   - Record all 7 artifact paths
   - Record the decision from `07-go-nogo.md` (GO, NO-GO, or PIVOT)
   - If decision is GO: set `currentPhase` to `1`

2. Report summary:
   ```
   ═══════════════════════════════════════════════════
   PHASE 0 COMPLETE — Discovery & Strategy
   ═══════════════════════════════════════════════════
   ✓ Domain Researcher:     01-domain-research.md (XXX words)
   ✓ Business Strategist:   02-strategy-brief.md (XXX words)
   ✓ Product Expert:        03-prd.md (XXX words)
   ✓ Business Analyst:      04-requirements.md (XXX words)
   ✓ Due Diligence Engineer: 05-feasibility.md (XXX words)
   ✓ Technical Risk Analyst: 06-risk-analysis.md (XXX words)
   ✓ Devil's Advocate:      07-go-nogo.md (XXX words)

   Decision: [GO / NO-GO / PIVOT]
   [If GO]: Conditions: [list from go-nogo.md]

   → Review docs/discovery/07-go-nogo.md
   → If you agree, run /design to begin Phase 1
   ```

   If NO-GO or PIVOT: explain what must change and why, based on the Devil's Advocate's report.
