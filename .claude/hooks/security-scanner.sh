#!/bin/bash
# .claude/hooks/security-scanner.sh
# Scans changed/staged files for secrets and API keys.
# Exit 2 if secrets found. Exit 0 if clean.

if ! command -v git &> /dev/null || ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0  # Not in a git repo, skip
fi

FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
if [[ -z "$FILES" ]]; then
  FILES=$(git diff --name-only HEAD 2>/dev/null)
fi

if [[ -z "$FILES" ]]; then
  exit 0  # No changed files
fi

FOUND=0

# Patterns that indicate secrets
PATTERNS=(
  'sk-[a-zA-Z0-9]{20,}'                    # OpenAI/Anthropic API keys
  'sk-ant-[a-zA-Z0-9]+'                    # Anthropic keys
  'AIza[0-9A-Za-z_-]{35}'                  # Google API keys
  'ghp_[a-zA-Z0-9]{36}'                    # GitHub personal tokens
  'PRIVATE.KEY'                             # Private key markers
  'BEGIN RSA PRIVATE KEY'                   # RSA keys
  'password\s*[:=]\s*["\x27][^"\x27]+'     # Hardcoded passwords
  'secret\s*[:=]\s*["\x27][^"\x27]+'       # Hardcoded secrets
  'mongodb\+srv://[^"]*:[^"]*@'            # MongoDB connection strings
  'postgres://[^"]*:[^"]*@'                # Postgres connection strings
)

while IFS= read -r file; do
  # Skip non-text files, env examples, and lock files
  [[ "$file" == *.png ]] || [[ "$file" == *.jpg ]] || [[ "$file" == *.ico ]] && continue
  [[ "$file" == *.lock ]] || [[ "$file" == *lock.json ]] && continue
  [[ "$file" == ".env.example" ]] || [[ "$file" == ".env.template" ]] && continue
  [[ "$file" == *node_modules* ]] && continue
  [[ ! -f "$file" ]] && continue

  for pattern in "${PATTERNS[@]}"; do
    MATCHES=$(grep -nE "$pattern" "$file" 2>/dev/null)
    if [[ -n "$MATCHES" ]]; then
      if [[ $FOUND -eq 0 ]]; then
        echo "══════════════════════════════════════════════════════════"
        echo "  SECURITY SCANNER: Potential secrets detected"
        echo "══════════════════════════════════════════════════════════"
      fi
      echo ""
      echo "  File: $file"
      echo "$MATCHES" | head -3 | while IFS= read -r line; do
        echo "    $line"
      done
      FOUND=$((FOUND + 1))
    fi
  done
done <<< "$FILES"

if [[ $FOUND -gt 0 ]]; then
  echo ""
  echo "══════════════════════════════════════════════════════════"
  echo "  ✘ BLOCKED: $FOUND file(s) contain potential secrets."
  echo "  Move secrets to .env (never committed)."
  echo "  Use environment variables in production."
  echo "══════════════════════════════════════════════════════════"
  exit 2
fi

exit 0
