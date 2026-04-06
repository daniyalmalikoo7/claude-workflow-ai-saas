#!/bin/bash
# .claude/hooks/artifact-validate.sh
# Three-tier artifact validation: BLOCK / WARN / PASS
# Usage: bash .claude/hooks/artifact-validate.sh <filepath>
#
# BLOCK (exit 2): File missing, empty, or stub (<50 words)
# WARN  (exit 0 + message): Missing expected sections or below depth
# PASS  (exit 0 clean): All checks pass

FILE="$1"
WARNINGS=0
BASENAME=$(basename "$FILE" 2>/dev/null)

# ── TIER 1: BLOCK — structural failures ──────────────────────────

if [[ -z "$FILE" ]]; then
  echo "ARTIFACT VALIDATION: No file path provided"
  echo "Usage: bash .claude/hooks/artifact-validate.sh <filepath>"
  exit 2
fi

if [[ ! -f "$FILE" ]]; then
  echo "✘ BLOCKED: File does not exist: $FILE"
  exit 2
fi

WORD_COUNT=$(wc -w < "$FILE" 2>/dev/null | tr -d ' ')

if [[ "$WORD_COUNT" -lt 10 ]]; then
  echo "✘ BLOCKED: $BASENAME is empty or near-empty ($WORD_COUNT words)"
  exit 2
fi

if [[ "$WORD_COUNT" -lt 50 ]]; then
  echo "✘ BLOCKED: $BASENAME is a stub ($WORD_COUNT words, minimum 50)"
  exit 2
fi

# ── TIER 2: WARN — depth and section checks ─────────────────────

# Helper: case-insensitive section check
has_section() {
  grep -qi "$1" "$FILE" 2>/dev/null
}

warn() {
  echo "⚠ WARNING: $1"
  WARNINGS=$((WARNINGS + 1))
}

# Determine artifact type by filename pattern and check required content
case "$BASENAME" in
  *01-domain-research*)
    MIN_WORDS=200
    has_section "problem.statement"    || warn "$BASENAME missing 'Problem Statement' section"
    has_section "target.user"          || warn "$BASENAME missing 'Target User' section"
    has_section "competiti"            || warn "$BASENAME missing competitive landscape"
    has_section "insight"              || warn "$BASENAME missing key insight"
    ;;
  *02-strategy-brief*)
    MIN_WORDS=200
    has_section "success.metric\|okr\|objective" || warn "$BASENAME missing success metrics/OKRs"
    has_section "roi\|return\|revenue\|cost"     || warn "$BASENAME missing ROI/financial analysis"
    ;;
  *03-prd*)
    MIN_WORDS=300
    has_section "scope"                          || warn "$BASENAME missing scope definition"
    has_section "non.scope\|out.of.scope\|excluded" || warn "$BASENAME missing non-scope/exclusions"
    has_section "user.stor\|acceptance.criter"   || warn "$BASENAME missing user stories"
    ;;
  *04-requirements*)
    MIN_WORDS=200
    has_section "functional"                     || warn "$BASENAME missing functional requirements"
    has_section "non.functional"                 || warn "$BASENAME missing non-functional requirements"
    ;;
  *05-feasibility*)
    MIN_WORDS=200
    has_section "build.vs.buy\|build.versus\|make.or.buy" || warn "$BASENAME missing build vs buy"
    has_section "alternative\|simpler\|existing"  || warn "$BASENAME missing alternatives analysis"
    ;;
  *06-risk-analysis*|*06-adrs*)
    MIN_WORDS=200
    has_section "vendor\|lock.in\|dependency"    || warn "$BASENAME missing vendor/dependency risk"
    has_section "risk\|mitigation"               || warn "$BASENAME missing risk assessment"
    ;;
  *07-go-nogo*)
    MIN_WORDS=150
    has_section "decision"                       || warn "$BASENAME missing Decision section"
    # Must contain an explicit decision
    if ! grep -qiE '\b(GO|NO-GO|NO.GO|PIVOT)\b' "$FILE" 2>/dev/null; then
      echo "✘ BLOCKED: $BASENAME must contain explicit decision: GO, NO-GO, or PIVOT"
      exit 2
    fi
    ;;
  *01-technical-design*)
    MIN_WORDS=400
    has_section "component\|architecture"        || warn "$BASENAME missing component/architecture"
    has_section "api\|contract\|endpoint"        || warn "$BASENAME missing API contracts"
    has_section "data.flow\|sequence\|integrat"  || warn "$BASENAME missing data flow"
    has_section "technology\|stack\|choice"      || warn "$BASENAME missing technology choices"
    ;;
  *02-ux-design*)
    MIN_WORDS=300
    has_section "journey\|persona\|research"     || warn "$BASENAME missing UX research"
    has_section "wireframe\|screen\|layout\|flow" || warn "$BASENAME missing wireframes/flows"
    ;;
  *03-design-system*)
    MIN_WORDS=200
    has_section "color\|token\|palette"          || warn "$BASENAME missing color tokens"
    has_section "tailwind\|css\|custom.propert"  || warn "$BASENAME missing implementation code"
    has_section "component\|button\|card\|input" || warn "$BASENAME missing component inventory"
    ;;
  *04-security-design*)
    MIN_WORDS=300
    has_section "threat\|attack\|vulnerabilit"   || warn "$BASENAME missing threat model"
    has_section "auth\|authenticat\|authorizat"  || warn "$BASENAME missing auth design"
    # Must contain testable commands
    if ! grep -qiE 'curl|test|script|verify|command' "$FILE" 2>/dev/null; then
      warn "$BASENAME missing testable commands (curl/test scripts)"
    fi
    ;;
  *05-data-model*)
    MIN_WORDS=200
    has_section "model\|schema\|entity\|table"   || warn "$BASENAME missing data model"
    has_section "index\|migration\|relation"     || warn "$BASENAME missing indexes/migrations"
    ;;
  *06-performance-spec*)
    MIN_WORDS=200
    if ! grep -qiE 'p50|p95|p99|percentile|latency' "$FILE" 2>/dev/null; then
      warn "$BASENAME missing percentile targets (P50/P95/P99)"
    fi
    has_section "budget\|target\|limit\|threshold" || warn "$BASENAME missing performance budgets"
    ;;
  # Validation reports (Phase 3)
  *qa-report*|*performance-report*|*security-report*|*accessibility-report*|*code-review*)
    MIN_WORDS=150
    has_section "finding\|result\|issue\|pass\|fail" || warn "$BASENAME missing findings/results"
    ;;
  *)
    MIN_WORDS=100  # Default minimum for unknown artifact types
    ;;
esac

# Check word count against type-specific minimum
if [[ "$WORD_COUNT" -lt "${MIN_WORDS:-100}" ]]; then
  warn "$BASENAME has $WORD_COUNT words (expected minimum $MIN_WORDS for this artifact type)"
fi

# ── TIER 3: REPORT ───────────────────────────────────────────────

if [[ $WARNINGS -gt 0 ]]; then
  echo "─────────────────────────────────────────────────────"
  echo "⚠ VALIDATED WITH $WARNINGS WARNING(S): $BASENAME ($WORD_COUNT words)"
  echo "  Review warnings above. Artifact accepted but may need improvement."
  echo "─────────────────────────────────────────────────────"
  exit 0  # Warn but don't block
fi

echo "✓ PASSED: $BASENAME ($WORD_COUNT words, all sections present)"
exit 0
