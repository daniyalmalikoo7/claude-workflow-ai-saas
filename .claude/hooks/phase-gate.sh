#!/bin/bash
# .claude/hooks/phase-gate.sh
# Enforces phase transitions. Exit 2 = blocked. Exit 0 = allowed.
# Cannot be bypassed by conversation. Deterministic.

STATE_FILE=".claude/state/phase.json"

# No state file = only /discover allowed, which creates it
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# jq required for JSON parsing
if ! command -v jq &> /dev/null; then
  echo "⚠ jq not installed — phase gate checks skipped."
  exit 0
fi

get_phase_status() {
  jq -r ".phases[\"$1\"].status // \"not-started\"" "$STATE_FILE" 2>/dev/null
}

get_decision() {
  jq -r '.phases["0"].decision // "none"' "$STATE_FILE" 2>/dev/null
}

block() {
  echo "══════════════════════════════════════════════════════════"
  echo "  PHASE GATE BLOCKED"
  echo "  $1"
  echo "══════════════════════════════════════════════════════════"
  exit 2
}

# Check artifact existence for Phase 1 → Phase 2 gate
check_design_artifacts() {
  local missing=()
  [[ ! -f "docs/design/01-technical-design.md" ]] && missing+=("Technical Design Document")
  [[ ! -f "docs/design/02-ux-design.md" ]]        && missing+=("UX Design")
  [[ ! -f "docs/design/03-design-system.md" ]]     && missing+=("Design System")
  [[ ! -f "docs/design/04-security-design.md" ]]   && missing+=("Security Design")
  [[ ! -f "docs/design/05-data-model.md" ]]        && missing+=("Data Model")
  [[ ! -f "docs/design/06-performance-spec.md" ]]  && missing+=("Performance Spec")

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "══════════════════════════════════════════════════════════"
    echo "  PHASE GATE BLOCKED: Design artifacts missing:"
    printf '    ✘ %s\n' "${missing[@]}"
    echo "  Run /design to produce all Phase 1 artifacts."
    echo "══════════════════════════════════════════════════════════"
    exit 2
  fi
}

# Check validation reports for Phase 3 → Phase 4 gate
check_validation_reports() {
  local missing=()
  [[ ! -f "docs/reports/qa-report.md" ]]            && missing+=("QA Report")
  [[ ! -f "docs/reports/performance-report.md" ]]    && missing+=("Performance Report")
  [[ ! -f "docs/reports/security-report.md" ]]       && missing+=("Security Report")
  [[ ! -f "docs/reports/accessibility-report.md" ]]  && missing+=("Accessibility Report")
  [[ ! -f "docs/reports/code-review.md" ]]           && missing+=("Code Review")

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "══════════════════════════════════════════════════════════"
    echo "  PHASE GATE BLOCKED: Validation reports missing:"
    printf '    ✘ %s\n' "${missing[@]}"
    echo "  Run /validate to produce all Phase 3 reports."
    echo "══════════════════════════════════════════════════════════"
    exit 2
  fi
}

# Determine required gate from current phase
CURRENT=$(jq -r '.currentPhase // 0' "$STATE_FILE" 2>/dev/null)

case "$CURRENT" in
  0)
    # Phase 0 in progress — no gate needed
    exit 0
    ;;
  1)
    # Entering Phase 1 — Phase 0 must be complete with GO
    [[ "$(get_phase_status 0)" != "complete" ]] && \
      block "Phase 0 (Discovery) not complete. Run /discover first."
    [[ "$(get_decision)" != "GO" ]] && \
      block "Go/No-Go decision is '$(get_decision)', not GO. Review docs/discovery/07-go-nogo.md"
    ;;
  2)
    # Entering Phase 2 — Phase 1 complete + all design artifacts
    [[ "$(get_phase_status 1)" != "complete" ]] && \
      block "Phase 1 (Design) not complete. Run /design first."
    check_design_artifacts
    ;;
  3)
    # Entering Phase 3 — Phase 2 complete
    [[ "$(get_phase_status 2)" != "complete" ]] && \
      block "Phase 2 (Build) not complete. Complete /build first."
    ;;
  4)
    # Entering Phase 4 — Phase 3 complete + all validation reports
    [[ "$(get_phase_status 3)" != "complete" ]] && \
      block "Phase 3 (Validation) not complete. Run /validate first."
    check_validation_reports
    ;;
esac

exit 0
