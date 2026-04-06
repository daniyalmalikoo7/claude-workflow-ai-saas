# AI Integration Standard

The GenAI product layer that no other workflow has. This standard governs
every AI feature in the SaaS product.

## Prompt versioning

- **Every prompt is a versioned file** in `docs/prompts/[name].v[N].md`.
- **Format:** System prompt, user template with `{{variables}}`, expected output format.
- **Never edit a prompt in code.** Edit the versioned file, update the version reference.
- **Changelog:** Each prompt file includes a history section with date, change, and reason.

```
docs/prompts/
├── section-generator.v3.md
├── requirement-extractor.v2.md
├── confidence-scorer.v1.md
└── kb-retriever.v2.md
```

## LLM call wrapper

Every LLM call goes through a single wrapper that handles:

```typescript
async function callLLM(options: {
  prompt: string;
  model: string;          // Primary model
  fallbackModel?: string; // Fallback if primary fails
  maxTokens: number;
  temperature: number;
  timeoutMs?: number;     // Default 30000
  retries?: number;       // Default 3
  userId: string;         // For cost attribution
  promptVersion: string;  // e.g. "section-generator.v3"
}): Promise<LLMResponse>
```

The wrapper provides:
1. **Timeout:** Abort after `timeoutMs` (default 30s). Show user "Generation timed out."
2. **Retry with backoff:** 1s, 2s, 4s delays. Different error for rate limit vs server error.
3. **Fallback chain:** Primary model → fallback model → graceful degradation message.
4. **Cost logging:** Log `{ model, tokens_in, tokens_out, cost_usd, user_id, prompt_version, latency_ms }`.
5. **Error classification:** Distinguish retryable (rate limit, timeout) from fatal (invalid key, quota).

## Hallucination guards

- **Grounded generation:** When generating content from a knowledge base, the prompt must
  instruct the model to cite which KB chunks it used. Output without citations = flagged.
- **Confidence scoring:** Every AI-generated section gets a confidence score (0-100) based on:
  - KB coverage: what % of the section's claims are grounded in retrieved chunks
  - Retrieval relevance: cosine similarity scores of retrieved chunks
  - Completeness: does the section address all relevant requirements
- **User visibility:** Confidence score displayed as a badge. <30% = red, 30-70% = amber, >70% = green.
- **Regeneration:** Users can regenerate any section with updated KB context or requirements.

## Streaming

- **SSE (Server-Sent Events)** for long-running generation (>2s expected).
- **Progress indication:** Stream tokens as they arrive. Show typing indicator.
- **Cancelation:** User can cancel in-progress generation. Clean up server-side.
- **Error recovery:** If stream breaks mid-generation, show partial content + "Generation interrupted. Tap to retry."
- **Implementation:** Use `ReadableStream` with `TextEncoder`. Flush chunks immediately.

## Eval pipeline

Every prompt must have evaluation test cases:

```
tests/evals/
├── section-generator.eval.ts
├── requirement-extractor.eval.ts
└── confidence-scorer.eval.ts
```

Each eval file contains ≥3 test cases:
1. **Happy path:** Typical input → expected output characteristics
2. **Edge case:** Minimal input → graceful handling
3. **Adversarial:** Prompt injection attempt → no system prompt leakage

Eval scoring: assert on output structure, key content presence, and absence of prohibited content.
Run evals before deploying prompt version changes.

## Cost tracking

- **Per-request logging:** Every LLM call logs cost in USD based on model pricing.
- **Per-user aggregation:** Dashboard shows cost per user per day/week/month.
- **Budget alerts:** Configurable threshold (e.g., $50/day). Alert via email/Slack when exceeded.
- **Cost attribution:** Every AI feature has a cost center. Know exactly what each feature costs.
- **Model pricing table:** Maintained as config. Updated when providers change pricing.

```typescript
const MODEL_PRICING = {
  'gemini-2.5-flash': { input_per_1k: 0.00015, output_per_1k: 0.0006 },
  'claude-sonnet-4-20250514': { input_per_1k: 0.003, output_per_1k: 0.015 },
  // Add new models here
};
```

## RAG implementation

- **Chunking:** 512 tokens per chunk, 50-token overlap. Respect paragraph boundaries.
- **Embedding model:** Voyage AI or OpenAI text-embedding-3-small. Dimension: 1024.
- **Vector store:** pgvector with HNSW index (`lists = rows/1000`, `probes = lists/10`).
- **Retrieval:** Top-k=5 chunks by cosine similarity. Threshold: reject chunks with similarity <0.3.
- **Context window management:** Retrieved chunks + prompt + requirements must fit in model context.
  Calculate token count before sending. Truncate lowest-similarity chunks if needed.
