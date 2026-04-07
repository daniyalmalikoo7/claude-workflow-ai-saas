#!/bin/bash
# .claude/hooks/session-start.sh
# Fires on first tool use. Reads project state into Claude's context.
# Ensures Claude always knows where the project stands.

STATE_FILE=".claude/state/phase.json"
MEMORY_STATE="docs/memory/STATE.md"
BLOCKERS="docs/memory/BLOCKERS.md"

# Only print once per session (use a temp marker)
# Cross-platform: macOS uses md5, Linux uses md5sum
if command -v md5sum &>/dev/null; then
  HASH=$(pwd | md5sum | cut -d' ' -f1)
elif command -v md5 &>/dev/null; then
  HASH=$(pwd | md5 -q)
else
  HASH=$(pwd | cksum | cut -d' ' -f1)
fi
MARKER="/tmp/.claude-session-started-${HASH}"
if [[ -f "$MARKER" ]]; then
  exit 0  # Already printed this session
fi
touch "$MARKER"

echo "┌──────────────────────────────────────────────────┐"
echo "│              SESSION START                       │"
echo "└──────────────────────────────────────────────────┘"

# Read phase state
if [[ -f "$STATE_FILE" ]] && command -v jq &> /dev/null; then
  PHASE=$(jq -r '.currentPhase // 0' "$STATE_FILE" 2>/dev/null)
  PROJECT=$(jq -r '.project // "Unknown"' "$STATE_FILE" 2>/dev/null)
  echo "  Project: $PROJECT"
  echo "  Current Phase: $PHASE"

  for p in 0 1 2 3 4; do
    STATUS=$(jq -r ".phases[\"$p\"].status // \"not-started\"" "$STATE_FILE" 2>/dev/null)
    LABEL=""
    case $p in
      0) LABEL="Discovery" ;;
      1) LABEL="Design" ;;
      2) LABEL="Build" ;;
      3) LABEL="Validation" ;;
      4) LABEL="Ship" ;;
    esac
    case $STATUS in
      complete)     echo "    Phase $p ($LABEL): ✓ complete" ;;
      in-progress)  echo "    Phase $p ($LABEL): ● in progress" ;;
      skipped)      echo "    Phase $p ($LABEL): ○ skipped" ;;
      *)            echo "    Phase $p ($LABEL): · not started" ;;
    esac
  done
else
  echo "  No project state found. Run /discover to begin Phase 0."
fi

# Read memory state
if [[ -f "$MEMORY_STATE" ]]; then
  echo ""
  echo "  ── Latest State ──"
  head -20 "$MEMORY_STATE" | sed 's/^/  /'
fi

# Read blockers
if [[ -f "$BLOCKERS" ]]; then
  OPEN=$(grep -ciE '\[open\]\|\[in.progress\]' "$BLOCKERS" 2>/dev/null)
  if [[ "$OPEN" -gt 0 ]]; then
    echo ""
    echo "  ⚠ $OPEN open blocker(s) — see docs/memory/BLOCKERS.md"
  fi
fi

echo ""
exit 0
