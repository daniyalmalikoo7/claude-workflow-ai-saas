#!/usr/bin/env node

/**
 * Pre-Write Guard Hook
 * Blocks writes to protected files, enforces file size limits,
 * and prevents secrets from being committed.
 *
 * Claude Code hooks receive tool input as JSON on stdin:
 * { "tool_name": "Write", "tool_input": { "file_path": "...", "content": "..." } }
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

const filePath = input?.tool_input?.file_path || "";
const content = input?.tool_input?.content || "";

const PROTECTED_PATTERNS = [
  /^\.env($|\.local|\.production)/,
  /^\.git\//,
  /node_modules\//,
  /package-lock\.json$/,
  /\.claude\/hooks\//,
];

const MAX_FILE_LINES = 350;

for (const pattern of PROTECTED_PATTERNS) {
  if (pattern.test(filePath)) {
    process.stderr.write(`BLOCKED: Protected file "${filePath}" cannot be modified by agents.\n`);
    process.exit(2);
  }
}

if (content) {
  const lineCount = content.split("\n").length;
  if (lineCount > MAX_FILE_LINES) {
    process.stderr.write(`BLOCKED: File exceeds ${MAX_FILE_LINES} lines (${lineCount}). Extract into smaller modules first.\n`);
    process.exit(2);
  }
}

const SECRET_PATTERNS = [
  /sk-[a-zA-Z0-9]{20,}/,
  /-----BEGIN (RSA |EC )?PRIVATE KEY-----/,
  /AKIA[0-9A-Z]{16}/,
  /ghp_[a-zA-Z0-9]{36}/,
  /password\s*[:=]\s*['"][^'"]+['"]/,
];

if (content) {
  for (const pattern of SECRET_PATTERNS) {
    if (pattern.test(content)) {
      process.stderr.write("BLOCKED: Potential secret/credential detected. Use environment variables instead.\n");
      process.exit(2);
    }
  }
}

process.exit(0);
