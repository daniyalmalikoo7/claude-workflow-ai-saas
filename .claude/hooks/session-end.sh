#!/bin/bash
# .claude/hooks/session-end.sh
# Fires on Stop event (after quality-gate). Updates memory files.

MEMORY_DIR="docs/memory"
SESSION_LOG="$MEMORY_DIR/SESSION_LOG.md"
STATE_FILE="$MEMORY_DIR/STATE.md"

# Create memory directory if needed
mkdir -p "$MEMORY_DIR"

# Timestamp
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
DATE_SHORT=$(date '+%Y-%m-%d %H:%M')

# Get changed files
CHANGED=""
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGED=$(git diff --name-only HEAD 2>/dev/null; git diff --staged --name-only 2>/dev/null)
fi

# Append to session log
if [[ -n "$CHANGED" ]]; then
  FILE_COUNT=$(echo "$CHANGED" | sort -u | wc -l | tr -d ' ')
  {
    echo ""
    echo "## Session — $DATE_SHORT"
    echo "Files changed: $FILE_COUNT"
    echo "$CHANGED" | sort -u | head -20 | sed 's/^/- /'
    if [[ $(echo "$CHANGED" | sort -u | wc -l) -gt 20 ]]; then
      echo "- ... and more"
    fi
  } >> "$SESSION_LOG"
fi

# Auto-commit memory files
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  if [[ -n "$(git diff "$MEMORY_DIR" .claude/state/ 2>/dev/null)" ]] || \
     [[ -n "$(git diff --staged "$MEMORY_DIR" .claude/state/ 2>/dev/null)" ]]; then
    git add "$MEMORY_DIR/" .claude/state/ 2>/dev/null
    git commit -m "docs(memory): auto-checkpoint $DATE_SHORT" --no-verify 2>/dev/null
  fi
fi

# Clean up session marker
MARKER="/tmp/.claude-session-started-$(pwd | md5sum | cut -d' ' -f1)"
rm -f "$MARKER" 2>/dev/null

exit 0
