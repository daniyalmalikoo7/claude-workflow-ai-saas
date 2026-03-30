#!/usr/bin/env node

/**
 * Session Logger Hook
 * Logs session activity for cost tracking, audit, and observability.
 * Writes to .claude/logs/ (gitignored).
 */

import { mkdirSync, appendFileSync } from "fs";
import { join } from "path";

const logDir = join(process.cwd(), ".claude", "logs");

try {
  mkdirSync(logDir, { recursive: true });

  const now = new Date();
  const dateStr = now.toISOString().split("T")[0];
  const logFile = join(logDir, `session-${dateStr}.jsonl`);

  const entry = {
    timestamp: now.toISOString(),
    session_id: process.env.CLAUDE_SESSION_ID || "unknown",
    event: "post_response",
    model: process.env.CLAUDE_MODEL || "unknown",
    cwd: process.cwd(),
  };

  appendFileSync(logFile, JSON.stringify(entry) + "\n");
} catch {
  // Non-blocking — logging failure should never break the workflow
}

process.exit(0);
