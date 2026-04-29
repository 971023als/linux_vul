"use client";

/**
 * ErrorBoundary — React class component that catches rendering errors
 * and displays a fallback UI instead of crashing the page.
 *
 * Next.js App Router provides route-level error.tsx handling, but
 * ErrorBoundary is useful for isolating subtree errors (e.g. a single
 * card component failing shouldn't take down the whole insights page).
 *
 * ─────────────────────────────────────────────────────────────
 * Usage:
 *   <ErrorBoundary fallback={<p>Failed to load section</p>}>
 *     <InsightCard insight={data} />
 *   </ErrorBoundary>
 *
 *   // Or with a custom error display:
 *   <ErrorBoundary
 *     namespace="InsightsSection"
 *     onError={(err, info) => logger.error("component", err.message, info)}
 *   >
 *     ...
 *   </ErrorBoundary>
 * ─────────────────────────────────────────────────────────────
 */

import { Component, type ErrorInfo, type ReactNode } from "react";
import { logger } from "@/lib/debug";
import { env } from "@/lib/env";

// ─── Props & State ───────────────────────────────────────────

interface ErrorBoundaryProps {
  children: ReactNode;

  /** Custom fallback element. Defaults to a generic error card. */
  fallback?: ReactNode;

  /** Identifies this boundary in debug logs. */
  namespace?: string;

  /** Optional callback when an error is caught. */
  onError?: (error: Error, info: ErrorInfo) => void;

  /**
   * When true, shows the error message in the fallback UI.
   * Defaults to isDev. Override explicitly if needed.
   */
  showError?: boolean;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

// ─── Component ───────────────────────────────────────────────

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
    this.handleReset = this.handleReset.bind(this);
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo): void {
    const { namespace = "unknown", onError } = this.props;

    logger.error(
      `ErrorBoundary[${namespace}]`,
      error.message,
      { stack: error.stack, componentStack: info.componentStack }
    );

    onError?.(error, info);
    this.setState({ errorInfo: info });
  }

  handleReset(): void {
    this.setState({ hasError: false, error: null, errorInfo: null });
  }

  render(): ReactNode {
    const { hasError, error } = this.state;
    const { children, fallback, namespace = "Component", showError } = this.props;

    if (!hasError) return children;

    // Use custom fallback if provided
    if (fallback !== undefined) return fallback;

    // Determine whether to show raw error message
    const shouldShowError =
      showError !== undefined
        ? showError
        : env.isDev;

    // Default fallback UI
    return (
      <div
        role="alert"
        aria-live="assertive"
        className="rounded-xl border border-red-500/30 bg-red-500/5 p-5"
      >
        <p className="text-sm font-semibold text-red-500 mb-1">
          렌더링 오류 — {namespace}
        </p>
        <p className="text-xs text-muted-foreground mb-3">
          이 섹션을 표시하는 중 오류가 발생했습니다.
        </p>

        {shouldShowError && error && (
          <pre className="mt-2 text-xs text-red-400/80 bg-red-950/30 rounded p-3 overflow-auto max-h-32 whitespace-pre-wrap break-words">
            {error.message}
          </pre>
        )}

        <button
          type="button"
          onClick={this.handleReset}
          className="mt-3 text-xs text-blue-400 hover:text-blue-300 underline underline-offset-2 transition-colors"
        >
          다시 시도
        </button>
      </div>
    );
  }
}

// ─── Convenience wrapper ─────────────────────────────────────

/**
 * Functional wrapper for common use cases.
 * Wraps a subtree with an ErrorBoundary without extra JSX nesting.
 *
 * @example
 *   withErrorBoundary(<InsightCard insight={data} />, "InsightCard")
 */
export function withErrorBoundary(
  children: ReactNode,
  namespace?: string,
  fallback?: ReactNode
): ReactNode {
  return (
    <ErrorBoundary namespace={namespace} fallback={fallback}>
      {children}
    </ErrorBoundary>
  );
}
