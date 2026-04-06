#!/bin/bash
# .claude/hooks/quality-gate.sh
# Runs on Stop event. Blocks completion if quality checks fail.
# Smart: skips code checks when no package.json exists (Phase 0/1).

FAILURES=0
CHECKS_RUN=0

fail() {
  echo "  ✘ $1"
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "  ✓ $1"
}

skip() {
  echo "  ○ $1 (skipped)"
}

echo "┌──────────────────────────────────────────────────┐"
echo "│             QUALITY GATE CHECK                   │"
echo "└──────────────────────────────────────────────────┘"

# ── Code quality checks (only when package.json exists) ──────────

if [[ -f "package.json" ]]; then

  # TypeScript check
  if command -v npx &> /dev/null && [[ -f "tsconfig.json" ]]; then
    CHECKS_RUN=$((CHECKS_RUN + 1))
    if npx tsc --noEmit 2>/dev/null; then
      pass "TypeScript: zero type errors"
    else
      fail "TypeScript: type errors found — run 'npx tsc --noEmit' to see details"
    fi
  else
    skip "TypeScript (no tsconfig.json)"
  fi

  # Lint check
  if grep -q '"lint"' package.json 2>/dev/null; then
    CHECKS_RUN=$((CHECKS_RUN + 1))
    if npm run lint --silent 2>/dev/null; then
      pass "Lint: clean"
    else
      fail "Lint: errors found — run 'npm run lint' to see details"
    fi
  else
    skip "Lint (no lint script in package.json)"
  fi

  # Build check
  if grep -q '"build"' package.json 2>/dev/null; then
    CHECKS_RUN=$((CHECKS_RUN + 1))
    if npm run build --silent 2>/dev/null; then
      pass "Build: successful"
    else
      fail "Build: failed — run 'npm run build' to see details"
    fi
  else
    skip "Build (no build script in package.json)"
  fi

  # Playwright E2E tests (if test directory exists)
  if [[ -d "tests" ]] || [[ -d "tests/e2e" ]]; then
    if ls tests/**/*.spec.ts tests/e2e/**/*.spec.ts 2>/dev/null | head -1 | grep -q .; then
      CHECKS_RUN=$((CHECKS_RUN + 1))
      if npx playwright test 2>/dev/null; then
        pass "E2E Tests: all passing"
      else
        fail "E2E Tests: failures — run 'npx playwright test' to see details"
      fi
    else
      skip "E2E Tests (no .spec.ts files found)"
    fi
  else
    skip "E2E Tests (no tests directory)"
  fi

  # Unit tests
  if grep -q '"test"' package.json 2>/dev/null; then
    if [[ -d "tests" ]] || [[ -d "__tests__" ]] || [[ -d "src" ]]; then
      CHECKS_RUN=$((CHECKS_RUN + 1))
      if npm test --silent 2>/dev/null; then
        pass "Unit Tests: passing"
      else
        fail "Unit Tests: failures — run 'npm test' to see details"
      fi
    else
      skip "Unit Tests (no test files found)"
    fi
  fi

else
  echo "  ○ No package.json — code quality checks skipped (Phase 0/1)"
fi

# ── Artifact quality checks (always run) ─────────────────────────

# Check for common bad patterns in any staged/changed files
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null; git diff --staged --name-only 2>/dev/null)

  if [[ -n "$CHANGED_FILES" ]]; then
    # Check for 'as any' in TypeScript files
    TS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx)$')
    if [[ -n "$TS_FILES" ]]; then
      ANY_COUNT=0
      while IFS= read -r f; do
        if [[ -f "$f" ]]; then
          c=$(grep -c 'as any' "$f" 2>/dev/null || echo 0)
          ANY_COUNT=$((ANY_COUNT + c))
        fi
      done <<< "$TS_FILES"
      if [[ $ANY_COUNT -gt 0 ]]; then
        CHECKS_RUN=$((CHECKS_RUN + 1))
        fail "'as any' found $ANY_COUNT time(s) in changed TypeScript files"
      fi
    fi

    # Check for empty catch blocks
    if [[ -n "$TS_FILES" ]]; then
      EMPTY_CATCH=0
      while IFS= read -r f; do
        if [[ -f "$f" ]]; then
          c=$(grep -cE 'catch\s*\([^)]*\)\s*\{\s*\}' "$f" 2>/dev/null || echo 0)
          EMPTY_CATCH=$((EMPTY_CATCH + c))
        fi
      done <<< "$TS_FILES"
      if [[ $EMPTY_CATCH -gt 0 ]]; then
        CHECKS_RUN=$((CHECKS_RUN + 1))
        fail "Empty catch blocks found $EMPTY_CATCH time(s) — add error handling"
      fi
    fi
  fi
fi

# ── Report ───────────────────────────────────────────────────────

echo ""
if [[ $FAILURES -gt 0 ]]; then
  echo "┌──────────────────────────────────────────────────┐"
  echo "│  ✘ QUALITY GATE FAILED: $FAILURES check(s) failed       │"
  echo "│  Fix issues above before continuing.             │"
  echo "└──────────────────────────────────────────────────┘"
  exit 2
elif [[ $CHECKS_RUN -gt 0 ]]; then
  echo "┌──────────────────────────────────────────────────┐"
  echo "│  ✓ QUALITY GATE PASSED: $CHECKS_RUN check(s) clean      │"
  echo "└──────────────────────────────────────────────────┘"
  exit 0
else
  echo "  ✓ Quality gate: no checks applicable at this stage"
  exit 0
fi
