# Performance Budget

Measurable targets defined before implementation, validated after.
Set by Performance Architect (Phase 1). Measured by Performance Engineer (Phase 3).

## API response time targets

| Endpoint type | P50 | P95 | P99 | Example |
|---|---|---|---|---|
| List/index | <100ms | <200ms | <500ms | GET /api/proposals |
| Single record | <150ms | <300ms | <600ms | GET /api/proposals/:id |
| Create/update | <200ms | <400ms | <800ms | POST /api/proposals |
| Search/filter | <200ms | <500ms | <1000ms | GET /api/kb/search?q=... |
| AI generation | <2000ms | <5000ms | <10000ms | POST /api/generate (streamed) |
| File upload | <500ms | <1000ms | <3000ms | POST /api/kb/upload |

Any API >300ms without a loading indicator visible to the user = bug.

## How to measure

```bash
# Per-endpoint measurement (run 10 times, take P95)
for i in {1..10}; do
  curl -s -w "time_total: %{time_total}s\n" -o /dev/null \
    -H "Authorization: Bearer $TOKEN" \
    "http://localhost:3000/api/trpc/proposal.list?batch=1&input={}"
done

# Server-side: tRPC timing middleware
// Log: [PERF] proposal.list: 47ms
```

## Core Web Vitals

| Metric | Target | Measurement |
|---|---|---|
| LCP (Largest Contentful Paint) | <1.5s | First meaningful content visible |
| INP (Interaction to Next Paint) | <100ms | Response to user interaction |
| CLS (Cumulative Layout Shift) | <0.05 | No content jumping during load |
| FCP (First Contentful Paint) | <1.0s | First pixel painted |
| TTFB (Time to First Byte) | <200ms | Server response starts |

Measure with: `npx lighthouse http://localhost:3000 --only-categories=performance`

## Bundle budget

| Category | Budget | Measurement |
|---|---|---|
| Total JS (gzipped) | <300KB | `npm run build` output |
| Per-route JS | <100KB | Next.js build route sizes |
| CSS (gzipped) | <50KB | Tailwind purged output |
| Images (per page) | <500KB | Total image weight |
| Font files | <100KB | Subset to used characters |

Monitor: check `npm run build` output after every build. Flag routes exceeding 100KB.

## Database performance

- **Every query:** EXPLAIN ANALYZE during development. Flag sequential scans on >1000 rows.
- **Indexes:** Create indexes for every WHERE clause and JOIN condition used by the application.
- **N+1 queries:** Zero tolerance. Use Prisma `include{}` or `select{}`. Never query in a loop.
- **Connection pooling:** Configure for serverless (Prisma Accelerate, PgBouncer, or Supabase pooler).
  Target: <10ms connection acquisition time.
- **Query timeout:** 5s default. AI-related queries: 30s. Kill queries exceeding timeout.

## Caching strategy

| Data type | Cache | TTL | Invalidation |
|---|---|---|---|
| Static assets | CDN (Vercel Edge) | 1 year | Deploy-time hash |
| API responses (list) | In-memory / Redis | 60s | On mutation |
| User session | Cookie / JWT | 24h | On logout |
| KB embeddings | Database | Permanent | On re-upload |
| AI generation | None | N/A | Always fresh |

## Load test template

```javascript
// k6 load test script template
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp up
    { duration: '1m', target: 10 },    // Sustain
    { duration: '10s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<300'],   // P95 < 300ms
    http_req_failed: ['rate<0.01'],     // <1% error rate
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/trpc/proposal.list', {
    headers: { Authorization: `Bearer ${__ENV.TOKEN}` },
  });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}
```
