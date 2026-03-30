# Skill: Context Window Management

Manage AI context windows to prevent overflows, control costs, and maintain output quality.

## Token Counting

```typescript
// src/lib/ai/context/token-counter.ts
// Use tiktoken for accurate counts; fall back to heuristic
import { encoding_for_model } from "tiktoken";

const encoder = encoding_for_model("cl100k_base"); // Claude-compatible

export function countTokens(text: string): number {
  try {
    return encoder.encode(text).length;
  } catch {
    // Heuristic fallback: ~4 chars per token for English
    return Math.ceil(text.length / 4);
  }
}

export function countMessageTokens(messages: { role: string; content: string }[]): number {
  let total = 0;
  for (const msg of messages) {
    total += countTokens(msg.content) + 4; // overhead per message
  }
  return total + 2; // conversation overhead
}
```

## Context Budget Enforcement

```typescript
// src/lib/ai/context/budget.ts
export interface ContextBudget {
  maxInputTokens: number;    // Hard limit for input
  maxOutputTokens: number;   // Hard limit for output
  reserveTokens: number;     // Keep free for system prompt + output
  warningThreshold: number;  // Log warning when exceeded (0.0-1.0)
}

export const DEFAULT_BUDGETS: Record<string, ContextBudget> = {
  "claude-sonnet-4-20250514": {
    maxInputTokens: 180000,
    maxOutputTokens: 8192,
    reserveTokens: 10000,
    warningThreshold: 0.8,
  },
  "claude-haiku-4-5-20251001": {
    maxInputTokens: 180000,
    maxOutputTokens: 8192,
    reserveTokens: 8000,
    warningThreshold: 0.8,
  },
};

export function checkBudget(
  tokens: number,
  budget: ContextBudget
): { ok: boolean; usage: number; warning: boolean } {
  const available = budget.maxInputTokens - budget.reserveTokens;
  const usage = tokens / available;
  return {
    ok: tokens <= available,
    usage,
    warning: usage >= budget.warningThreshold,
  };
}
```

## Context Truncation Strategies

```typescript
// src/lib/ai/context/truncation.ts

/** Remove oldest items first (chat history, logs) */
export function truncateFIFO(items: string[], maxTokens: number): string[] {
  const result: string[] = [];
  let total = 0;
  // Keep most recent items (iterate from end)
  for (let i = items.length - 1; i >= 0; i--) {
    const tokens = countTokens(items[i]);
    if (total + tokens > maxTokens) break;
    result.unshift(items[i]);
    total += tokens;
  }
  return result;
}

/** Keep highest-relevance items (search results, knowledge base) */
export function truncateByRelevance(
  items: { content: string; score: number }[],
  maxTokens: number
): string[] {
  const sorted = [...items].sort((a, b) => b.score - a.score);
  const result: string[] = [];
  let total = 0;
  for (const item of sorted) {
    const tokens = countTokens(item.content);
    if (total + tokens > maxTokens) break;
    result.push(item.content);
    total += tokens;
  }
  return result;
}

/** Summarize when context is too large */
export function buildContextWithBudget(params: {
  systemPrompt: string;
  userQuery: string;
  knowledgeBase: { content: string; score: number }[];
  chatHistory: string[];
  budget: ContextBudget;
}): { system: string; user: string; truncated: boolean } {
  const { systemPrompt, userQuery, knowledgeBase, chatHistory, budget } = params;
  const available = budget.maxInputTokens - budget.reserveTokens;

  const systemTokens = countTokens(systemPrompt);
  const queryTokens = countTokens(userQuery);
  const fixedTokens = systemTokens + queryTokens;

  // Allocate remaining budget: 60% knowledge base, 40% history
  const remaining = available - fixedTokens;
  const kbBudget = Math.floor(remaining * 0.6);
  const historyBudget = Math.floor(remaining * 0.4);

  const kbContext = truncateByRelevance(knowledgeBase, kbBudget);
  const historyContext = truncateFIFO(chatHistory, historyBudget);
  const truncated = kbContext.length < knowledgeBase.length
    || historyContext.length < chatHistory.length;

  const user = [
    "## Relevant context",
    ...kbContext,
    "## Recent history",
    ...historyContext,
    "## Current request",
    userQuery,
  ].join("\n\n");

  return { system: systemPrompt, user, truncated };
}
```

## Rules
- ALWAYS count tokens before sending to the API
- ALWAYS set a context budget per prompt type
- NEVER send unbounded context (like entire documents without truncation)
- PREFER relevance-based truncation over simple FIFO for knowledge bases
- LOG a warning when context exceeds 80% of budget
- TRACK context utilization as a metric (see logging-monitoring skill)
