/**
 * Debug / logging utility.
 *
 * All output is gated behind isDev or the NEXT_PUBLIC_DEBUG flag so that
 * production bundles stay silent. Call sites remain in code; the compiler
 * tree-shakes the body in production.
 *
 * ─────────────────────────────────────────────────────────────
 * Usage:
 *   import { logger } from "@/lib/debug";
 *
 *   logger.info("component", "mounted", { props });
 *   logger.warn("data", "empty insights array");
 *   logger.error("fetch", "failed", error);
 *   logger.group("render cycle", () => { ... });
 * ─────────────────────────────────────────────────────────────
 */

import { env } from "@/lib/env";

type LogLevel = "info" | "warn" | "error" | "debug";

const LEVEL_STYLE: Record<LogLevel, string> = {
  debug: "color:#6b7280",
  info:  "color:#3b82f6",
  warn:  "color:#f59e0b",
  error: "color:#ef4444",
};

function isEnabled(): boolean {
  // Server-side (SSR/build): always silent in prod
  if (typeof window === "undefined") {
    return env.isDev || env.isTest;
  }
  // Client-side: respect debug flag
  return env.isDev || env.debug;
}

function buildPrefix(level: LogLevel, namespace: string): string {
  const ts = new Date().toISOString().slice(11, 23); // HH:MM:SS.mmm
  return `[${ts}] [${level.toUpperCase()}] [${namespace}]`;
}

function log(level: LogLevel, namespace: string, message: string, data?: unknown): void {
  if (!isEnabled()) return;

  const prefix = buildPrefix(level, namespace);
  const consoleFn = level === "error" ? console.error
                  : level === "warn"  ? console.warn
                  : console.log;

  if (data !== undefined) {
    consoleFn(`%c${prefix}`, LEVEL_STYLE[level], message, data);
  } else {
    consoleFn(`%c${prefix}`, LEVEL_STYLE[level], message);
  }
}

export const logger = {
  /** General informational log. */
  info(namespace: string, message: string, data?: unknown): void {
    log("info", namespace, message, data);
  },

  /** Non-fatal warning — something unexpected but recoverable. */
  warn(namespace: string, message: string, data?: unknown): void {
    log("warn", namespace, message, data);
  },

  /** Error — always logs, even in production, for critical failures. */
  error(namespace: string, message: string, data?: unknown): void {
    // Errors always surface regardless of isDev flag
    const prefix = buildPrefix("error", namespace);
    if (data !== undefined) {
      console.error(`%c${prefix}`, LEVEL_STYLE.error, message, data);
    } else {
      console.error(`%c${prefix}`, LEVEL_STYLE.error, message);
    }
  },

  /** Verbose debug detail — only when NEXT_PUBLIC_DEBUG=true. */
  debug(namespace: string, message: string, data?: unknown): void {
    if (!env.debug) return;
    log("debug", namespace, message, data);
  },

  /**
   * Group related logs together in the browser console.
   * The callback runs synchronously inside a console.group block.
   */
  group(label: string, fn: () => void): void {
    if (!isEnabled()) { fn(); return; }
    console.group(label);
    try { fn(); } finally { console.groupEnd(); }
  },

  /**
   * Measure execution time of a synchronous function.
   * Returns the function's return value unchanged.
   */
  time<T>(label: string, fn: () => T): T {
    if (!isEnabled()) return fn();
    console.time(label);
    try { return fn(); } finally { console.timeEnd(label); }
  },
} as const;

export type Logger = typeof logger;
