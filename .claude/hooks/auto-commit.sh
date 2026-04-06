#!/bin/bash
# .claude/hooks/auto-commit.sh
# Fires on Stop event after quality-gate passes.
# Creates a conventional commit if uncommitted changes exist.

if ! command -v git &> /dev/null || ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Check for uncommitted changes
if git diff --quiet HEAD 2>/dev/null && git diff --staged --quiet 2>/dev/null; then
  exit 0  # Nothing to commit
fi

CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --staged --name-only 2>/dev/null)
CHANGED=$(echo "$CHANGED" | sort -u)

# Determine commit type and scope from changed files
TYPE="chore"
SCOPE=""

if echo "$CHANGED" | grep -q "agents/"; then
  TYPE="feat"; SCOPE="agents"
elif echo "$CHANGED" | grep -q "commands/"; then
  TYPE="feat"; SCOPE="commands"
elif echo "$CHANGED" | grep -q "hooks/"; then
  TYPE="feat"; SCOPE="hooks"
elif echo "$CHANGED" | grep -q "skills/"; then
  TYPE="feat"; SCOPE="skills"
elif echo "$CHANGED" | grep -q "docs/discovery/\|docs/design/"; then
  TYPE="docs"; SCOPE="artifacts"
elif echo "$CHANGED" | grep -q "docs/reports/"; then
  TYPE="docs"; SCOPE="reports"
elif echo "$CHANGED" | grep -q "README\|CHANGELOG\|docs/"; then
  TYPE="docs"
elif echo "$CHANGED" | grep -q "tests/\|spec\.ts\|spec\.tsx"; then
  TYPE="test"
elif echo "$CHANGED" | grep -q "src/"; then
  TYPE="feat"; SCOPE="app"
elif echo "$CHANGED" | grep -q "prisma/"; then
  TYPE="feat"; SCOPE="db"
fi

FILE_COUNT=$(echo "$CHANGED" | wc -l | tr -d ' ')
SCOPE_PART=""
[[ -n "$SCOPE" ]] && SCOPE_PART="($SCOPE)"
TIMESTAMP=$(date '+%H:%M')

git add -A 2>/dev/null
git commit -m "${TYPE}${SCOPE_PART}: update ${FILE_COUNT} file(s) — ${TIMESTAMP}" --no-verify 2>/dev/null

exit 0
