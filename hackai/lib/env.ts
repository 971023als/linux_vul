/**
 * Centralized environment configuration.
 *
 * Import this instead of accessing process.env directly so that
 * IDE autocomplete, TypeScript, and tests all see a single source of truth.
 *
 * ─────────────────────────────────────────────────────────────
 * Usage:
 *   import { env } from "@/lib/env";
 *   if (env.isDev) { ... }
 * ─────────────────────────────────────────────────────────────
 */

const nodeEnv = process.env.NODE_ENV ?? "development";

export const env = {
  /** Current NODE_ENV value */
  mode: nodeEnv as "development" | "production" | "test",

  /** true when running `next dev` or `vitest` */
  isDev: nodeEnv === "development",

  /** true when running `next build` / `next start` */
  isProd: nodeEnv === "production",

  /** true when running `vitest` */
  isTest: nodeEnv === "test",

  /**
   * Site base URL — falls back to localhost in development.
   * Override with NEXT_PUBLIC_SITE_URL in .env.local for staging/prod.
   */
  siteUrl:
    process.env.NEXT_PUBLIC_SITE_URL ??
    (nodeEnv === "production"
      ? "https://madhat-labs.github.io"
      : "http://localhost:3000"),

  /**
   * Debug flag — enables verbose logging when NEXT_PUBLIC_DEBUG=true.
   * Automatically true in test environment.
   */
  debug:
    process.env.NEXT_PUBLIC_DEBUG === "true" || nodeEnv === "test",
} as const;

export type Env = typeof env;
