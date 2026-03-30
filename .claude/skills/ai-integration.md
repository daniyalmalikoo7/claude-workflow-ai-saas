# Skill: AI Integration Layer

Build production-grade AI integration following these exact patterns.

## Provider Abstraction

Always abstract the AI provider behind an interface:

```typescript
// src/lib/ai/providers/types.ts
export interface AIProvider {
  generate(params: GenerateParams): Promise<GenerateResult>;
  stream(params: GenerateParams): AsyncIterable<StreamChunk>;
  countTokens(text: string): number;
}

export interface GenerateParams {
  promptId: string;
  promptVersion: string;
  systemMessage: string;
  userMessage: string;
  maxTokens: number;
  temperature: number;
  responseSchema?: ZodSchema;
}

export interface GenerateResult {
  content: string;
  parsed?: unknown;
  usage: { inputTokens: number; outputTokens: number; cost: number };
  latencyMs: number;
  model: string;
  cached: boolean;
}
```

## Prompt Template Pattern

```typescript
// src/lib/ai/prompts/base.ts
import { readFileSync } from "fs";
import { join } from "path";
import matter from "gray-matter";

export function loadPrompt(promptId: string, version?: string) {
  const dir = join(process.cwd(), "docs", "prompts");
  // Find latest version if not specified
  const file = readFileSync(join(dir, `${promptId}.v${version || "latest"}.md`), "utf-8");
  const { data: metadata, content } = matter(file);

  const [systemMessage, userTemplate] = content.split("<user>");

  return {
    metadata,
    systemMessage: systemMessage.replace("<s>", "").replace("</s>", "").trim(),
    userTemplate: userTemplate?.replace("</user>", "").trim() || "",
  };
}

export function renderPrompt(template: string, variables: Record<string, string>) {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => {
    if (!(key in variables)) throw new Error(`Missing prompt variable: ${key}`);
    return sanitizeForPrompt(variables[key]);
  });
}

function sanitizeForPrompt(input: string): string {
  // Prevent prompt injection by escaping control sequences
  return input
    .replace(/<\/?s>/g, "")          // Remove system message tags
    .replace(/<\/?user>/g, "")        // Remove user message tags
    .replace(/\{\{/g, "{ {")          // Escape template syntax
    .slice(0, 10000);                  // Hard length limit
}
```

## Fallback Chain Pattern

```typescript
// src/lib/ai/fallback-chain.ts
export async function executeWithFallback<T>(
  params: GenerateParams,
  schema: ZodSchema<T>,
  options?: { maxRetries?: number }
): Promise<{ data: T; metadata: GenerateResult }> {
  const chain = [
    { provider: "anthropic", model: "claude-sonnet-4-20250514" },
    { provider: "anthropic", model: "claude-haiku-4-5-20251001" },
    { provider: "cache",     model: "semantic-cache" },
  ];

  for (const step of chain) {
    try {
      const result = await callWithRetry(step, params, options?.maxRetries ?? 2);
      const parsed = schema.safeParse(JSON.parse(result.content));

      if (parsed.success) {
        return { data: parsed.data, metadata: result };
      }

      logger.warn("AI output failed schema validation", {
        promptId: params.promptId,
        model: step.model,
        errors: parsed.error.issues,
      });
      // Try next in chain
    } catch (error) {
      logger.error("AI provider failed", {
        provider: step.provider,
        model: step.model,
        error: error instanceof Error ? error.message : "Unknown",
      });
      // Try next in chain
    }
  }

  throw new AIError("All providers in fallback chain exhausted", { params });
}
```

## Cost Tracking Pattern

```typescript
// src/lib/ai/cost-tracker.ts
const MODEL_COSTS = {
  "claude-sonnet-4-20250514": { input: 3.0 / 1_000_000, output: 15.0 / 1_000_000 },
  "claude-haiku-4-5-20251001": { input: 0.80 / 1_000_000, output: 4.0 / 1_000_000 },
  "claude-opus-4-6": { input: 15.0 / 1_000_000, output: 75.0 / 1_000_000 },
} as const;

export function calculateCost(model: string, inputTokens: number, outputTokens: number): number {
  const rates = MODEL_COSTS[model as keyof typeof MODEL_COSTS];
  if (!rates) return 0;
  return inputTokens * rates.input + outputTokens * rates.output;
}

export function logAICall(result: GenerateResult, promptId: string) {
  logger.info("ai_call", {
    promptId,
    model: result.model,
    inputTokens: result.usage.inputTokens,
    outputTokens: result.usage.outputTokens,
    cost: result.usage.cost,
    latencyMs: result.latencyMs,
    cached: result.cached,
  });
}
```

## Hallucination Guard Pattern

```typescript
// src/lib/ai/guards/hallucination.ts
export interface HallucinationCheck {
  name: string;
  check: (output: string, context: string) => Promise<boolean>;
  severity: "block" | "warn";
}

export const defaultGuards: HallucinationCheck[] = [
  {
    name: "json_validity",
    check: async (output) => { try { JSON.parse(output); return true; } catch { return false; } },
    severity: "block",
  },
  {
    name: "no_fabricated_urls",
    check: async (output) => {
      const urls = output.match(/https?:\/\/[^\s]+/g) || [];
      // Only allow URLs that were in the context
      return urls.length === 0; // Override per-prompt as needed
    },
    severity: "warn",
  },
  {
    name: "confidence_threshold",
    check: async (output) => {
      const parsed = JSON.parse(output);
      return !parsed.confidence || parsed.confidence >= 0.7;
    },
    severity: "warn",
  },
];

export async function runGuards(
  output: string,
  context: string,
  guards: HallucinationCheck[] = defaultGuards
): Promise<{ passed: boolean; failures: string[] }> {
  const failures: string[] = [];

  for (const guard of guards) {
    const passed = await guard.check(output, context);
    if (!passed) {
      failures.push(guard.name);
      if (guard.severity === "block") {
        return { passed: false, failures };
      }
    }
  }

  return { passed: failures.length === 0, failures };
}
```
