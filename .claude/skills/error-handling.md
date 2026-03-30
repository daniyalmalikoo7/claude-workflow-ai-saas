# Skill: Error Handling & Recovery

Every error path must be handled explicitly. These are the exact patterns to follow.

## API Error Handler (Server-Side)

```typescript
// src/lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true,
    public context?: Record<string, unknown>
  ) {
    super(message);
    this.name = "AppError";
  }
}

export class AIError extends AppError {
  constructor(message: string, context?: Record<string, unknown>) {
    super(message, "AI_ERROR", 502, true, context);
    this.name = "AIError";
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, unknown>) {
    super(message, "VALIDATION_ERROR", 400, true, context);
  }
}

export class RateLimitError extends AppError {
  constructor(retryAfterMs: number = 60000) {
    super("Rate limit exceeded", "RATE_LIMIT", 429, true, { retryAfterMs });
  }
}

// API route error wrapper
export function withErrorHandler<T>(
  handler: (req: Request) => Promise<T>
): (req: Request) => Promise<Response> {
  return async (req) => {
    try {
      const result = await handler(req);
      return Response.json(result);
    } catch (error) {
      if (error instanceof AppError && error.isOperational) {
        logger.warn(error.message, { code: error.code, ...error.context });
        return Response.json(
          { error: { code: error.code, message: error.message } },
          { status: error.statusCode }
        );
      }
      // Unexpected error — log full details, return generic message
      logger.error("Unhandled error", {
        error: error instanceof Error ? error.message : "Unknown",
        stack: error instanceof Error ? error.stack : undefined,
      });
      return Response.json(
        { error: { code: "INTERNAL_ERROR", message: "Something went wrong" } },
        { status: 500 }
      );
    }
  };
}
```

## React Error Boundary

```typescript
// src/components/atoms/error-boundary.tsx
"use client";
import { Component, type ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, info: { componentStack: string }) => void;
}

interface State { hasError: boolean; error: Error | null; }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    this.props.onError?.(error, { componentStack: info.componentStack || "" });
    logger.error("React error boundary caught", {
      error: error.message,
      componentStack: info.componentStack,
    });
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div role="alert" className="p-4 rounded-lg bg-red-50 text-red-800">
          <h2 className="font-medium">Something went wrong</h2>
          <button onClick={() => this.setState({ hasError: false, error: null })}
                  className="mt-2 text-sm underline">
            Try again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

## AI Error Recovery Chain

```typescript
// src/lib/ai/error-recovery.ts
export async function callWithRetry<T>(
  fn: () => Promise<T>,
  options: { maxRetries?: number; baseDelayMs?: number } = {}
): Promise<T> {
  const { maxRetries = 3, baseDelayMs = 1000 } = options;
  let lastError: Error | undefined;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      // Don't retry on validation errors or auth errors
      if (error instanceof ValidationError) throw error;
      if (error instanceof AppError && error.statusCode === 401) throw error;

      if (attempt < maxRetries) {
        const delay = baseDelayMs * Math.pow(2, attempt) + Math.random() * 500;
        logger.warn("AI call failed, retrying", {
          attempt: attempt + 1,
          maxRetries,
          delayMs: delay,
          error: lastError.message,
        });
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }
  throw lastError;
}
```

## Rules
- NEVER swallow errors silently (empty catch blocks)
- NEVER expose stack traces or internal details to users
- ALWAYS log the full error server-side, return a safe message client-side
- ALWAYS use typed error classes, never throw raw strings
- ALWAYS include a user-facing recovery action (retry button, contact support, etc.)
- For AI errors: fall through the chain (retry → fallback model → cache → graceful message)
