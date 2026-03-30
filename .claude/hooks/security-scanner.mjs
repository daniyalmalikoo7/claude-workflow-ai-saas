#!/usr/bin/env node

/**
 * Security Scanner Hook
 * Scans bash commands for dangerous patterns before execution.
 *
 * Claude Code hooks receive tool input as JSON on stdin:
 * { "tool_name": "Bash", "tool_input": { "command": "..." } }
 *
 * Exit codes:
 *   0 = allow the operation
 *   2 = block the operation (stderr message shown to Claude)
 */

import { readFileSync } from "fs";

let input;
try {
  input = JSON.parse(readFileSync("/dev/stdin", "utf-8"));
} catch {
  process.exit(0);
}

const command = input?.tool_input?.command || "";

const BLOCKED_PATTERNS = [
  { pattern: /rm\s+-rf\s+\//, reason: "Recursive delete from root" },
  { pattern: />\s*\/dev\/sd/, reason: "Direct disk write" },
  { pattern: /mkfs\./, reason: "Filesystem format" },
  { pattern: /dd\s+if=/, reason: "Raw disk operation" },
  { pattern: /:(){ :\|:& };:/, reason: "Fork bomb" },
  { pattern: /curl.*\|\s*(bash|sh|zsh)/, reason: "Pipe to shell" },
  { pattern: /wget.*\|\s*(bash|sh|zsh)/, reason: "Pipe to shell" },
  { pattern: /chmod\s+777/, reason: "World-writable permissions" },
  { pattern: /sudo\s+/, reason: "Privilege escalation" },
  { pattern: /(?:cat|less|more|head|tail|nano|vim|vi|code|open)\s+\.env(?!\.example)/, reason: "Reading .env file directly — use environment variables" },
  { pattern: />\s*\.env(?!\.example)/, reason: "Writing to .env file directly" },
  { pattern: /npm publish/, reason: "Publishing packages requires manual confirmation" },
];

for (const { pattern, reason } of BLOCKED_PATTERNS) {
  if (pattern.test(command)) {
    process.stderr.write(`BLOCKED: ${reason}\n`);
    process.exit(2);
  }
}

process.exit(0);
