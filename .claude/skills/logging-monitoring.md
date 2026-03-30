# Skill: Structured Logging & Monitoring

Production logging and monitoring patterns. Use these exactly — never use console.log.

## Structured Logger Setup

```typescript
// src/lib/logger.ts
type LogLevel = "debug" | "info" | "warn" | "error";

interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  correlationId?: string;
  userId?: string;
  [key: string]: unknown;
}

const LOG_LEVELS: Record<LogLevel, number> = { debug: 0, info: 1, warn: 2, error: 3 };
const MIN_LEVEL = (process.env.LOG_LEVEL as LogLevel) || "info";

function shouldLog(level: LogLevel): boolean {
  return LOG_LEVELS[level] >= LOG_LEVELS[MIN_LEVEL];
}

function log(level: LogLevel, message: string, meta?: Record<string, unknown>): void {
  if (!shouldLog(level)) return;
  const entry: LogEntry = {
    level,
    message,
    timestamp: new Date().toISOString(),
    ...meta,
  };
  // JSON to stdout — compatible with every log aggregator
  const output = level === "error" ? process.stderr : process.stdout;
  output.write(JSON.stringify(entry) + "\n");
}

export const logger = {
  debug: (msg: string, meta?: Record<string, unknown>) => log("debug", msg, meta),
  info: (msg: string, meta?: Record<string, unknown>) => log("info", msg, meta),
  warn: (msg: string, meta?: Record<string, unknown>) => log("warn", msg, meta),
  error: (msg: string, meta?: Record<string, unknown>) => log("error", msg, meta),
};
```

## AI Call Logging (Required for every AI request)

```typescript
// src/lib/ai/logger.ts
import { logger } from "@/lib/logger";

export function logAICall(params: {
  promptId: string;
  promptVersion: string;
  model: string;
  inputTokens: number;
  outputTokens: number;
  latencyMs: number;
  cached: boolean;
  success: boolean;
  error?: string;
  userId?: string;
}) {
  const cost = calculateCost(params.model, params.inputTokens, params.outputTokens);
  logger.info("ai_call", {
    ...params,
    cost,
    costFormatted: `$${cost.toFixed(4)}`,
  });
}
```

## Monitoring Setup Checklist

### Error Tracking (Sentry)
```typescript
// src/lib/monitoring/sentry.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 1.0,
  environment: process.env.NODE_ENV,
  beforeSend(event) {
    // Strip PII from error reports
    if (event.user) {
      delete event.user.ip_address;
      delete event.user.email;
    }
    return event;
  },
});
```

### Analytics (PostHog)
```typescript
// src/lib/monitoring/posthog.ts
import posthog from "posthog-js";

export function initAnalytics() {
  if (typeof window === "undefined") return;
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: "https://app.posthog.com",
    capture_pageview: true,
    capture_pageleave: true,
  });
}

export function trackAIUsage(event: string, properties: Record<string, unknown>) {
  posthog.capture(event, {
    ...properties,
    $set: { last_ai_usage: new Date().toISOString() },
  });
}
```

### AI-Specific Metrics to Track
- `ai_call_latency_ms` — p50, p95, p99 per prompt
- `ai_call_tokens_in` / `ai_call_tokens_out` — per user, per prompt
- `ai_call_cost_usd` — per user per day (alert if > budget)
- `ai_call_error_rate` — per model, per prompt
- `ai_call_cache_hit_rate` — overall and per prompt
- `ai_eval_score` — per prompt version (alert on regression)
- `ai_hallucination_guard_trigger_rate` — per prompt (alert if > 5%)
- `ai_fallback_trigger_rate` — per model (alert if primary fails > 1%)

### Alert Rules
```yaml
# Define in your monitoring platform
alerts:
  - name: ai_cost_budget_exceeded
    condition: sum(ai_call_cost_usd) by user > daily_budget
    action: disable_ai_for_user, notify_admin

  - name: ai_error_rate_spike
    condition: rate(ai_call_error) > 0.05 for 5m
    action: notify_oncall, check_provider_status

  - name: ai_eval_regression
    condition: ai_eval_score < baseline - 0.05
    action: block_deploy, notify_team

  - name: ai_latency_degradation
    condition: ai_call_latency_p95 > 5000ms for 10m
    action: notify_oncall, consider_model_switch
```
