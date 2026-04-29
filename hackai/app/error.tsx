"use client";

/**
 * Route-level error boundary for the Next.js App Router.
 *
 * This file is automatically used by Next.js when any page or layout
 * in the `app/` directory throws an unhandled error during rendering.
 *
 * Ref: https://nextjs.org/docs/app/api-reference/file-conventions/error
 */

import { useEffect } from "react";
import Link from "next/link";
import { logger } from "@/lib/debug";
import { env } from "@/lib/env";

interface ErrorPageProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function ErrorPage({ error, reset }: ErrorPageProps) {
  useEffect(() => {
    // Log to debug utility — surfaces in browser console during development
    logger.error("app/error", error.message, {
      digest: error.digest,
      stack: error.stack,
    });
  }, [error]);

  const isDev = env.isDev;

  return (
    <div className="mx-auto max-w-3xl px-4 py-16 sm:py-24 text-center">
      <p
        className="text-6xl font-bold text-red-500/20 font-mono mb-4"
        aria-hidden="true"
      >
        오류
      </p>

      <h1 className="text-2xl font-bold text-foreground mb-2">
        페이지 렌더링 중 오류가 발생했습니다
      </h1>

      <p className="text-sm text-muted-foreground mb-6 max-w-md mx-auto">
        일시적인 문제일 수 있습니다. 다시 시도하거나 홈으로 돌아가 주세요.
      </p>

      {/* Dev-only error detail */}
      {isDev && (
        <div className="mb-6 text-left rounded-lg border border-red-500/30 bg-red-500/5 p-4">
          <p className="text-xs font-semibold text-red-400 mb-1">
            개발 환경 오류 상세 (프로덕션에서는 숨겨집니다)
          </p>
          <pre className="text-xs text-red-300/80 overflow-auto whitespace-pre-wrap break-words max-h-48">
            {error.message}
            {error.digest ? `\n\ndigest: ${error.digest}` : ""}
          </pre>
        </div>
      )}

      {/* Action buttons */}
      <div className="flex flex-wrap items-center justify-center gap-3">
        <button
          type="button"
          onClick={reset}
          className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
        >
          다시 시도
        </button>
        <Link
          href="/"
          className="inline-flex items-center justify-center rounded-lg border border-border bg-background px-5 py-2.5 text-sm font-medium text-foreground hover:bg-muted transition-colors"
        >
          홈으로 돌아가기
        </Link>
      </div>
    </div>
  );
}
