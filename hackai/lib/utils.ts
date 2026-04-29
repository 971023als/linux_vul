import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { env } from "@/lib/env";

/**
 * Merge Tailwind CSS class names safely.
 * Combines clsx (conditional classes) with twMerge (deduplication).
 */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

/**
 * Format a date string to Korean locale.
 * Returns "날짜 오류" if the string is not a valid date — never throws.
 */
export function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  if (Number.isNaN(date.getTime())) {
    // Invalid date string — surface in dev, degrade gracefully in prod
    if (env.isDev) {
      console.warn(`[utils.formatDate] Invalid date string: "${dateStr}"`);
    }
    return "날짜 오류";
  }
  return date.toLocaleDateString("ko-KR", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

/**
 * Truncate a string to a maximum length, appending an ellipsis if needed.
 * Throws in development if maxLength < 1 to catch misconfiguration early.
 */
export function truncate(str: string, maxLength: number): string {
  if (env.isDev && maxLength < 1) {
    throw new RangeError(`[utils.truncate] maxLength must be >= 1, got ${maxLength}`);
  }
  if (str.length <= maxLength) return str;
  return str.slice(0, maxLength).trimEnd() + "…";
}

/**
 * Convert a slug to a display title (kebab-case → Title Case with spaces).
 * Used for generating page titles from route segments.
 */
export function slugToTitle(slug: string): string {
  return slug
    .split("-")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

/**
 * Check if a URL is an external link (starts with http/https or //).
 */
export function isExternalUrl(url: string): boolean {
  return /^(https?:)?\/\//.test(url);
}

/**
 * Safe array access — returns undefined instead of throwing on out-of-bounds.
 * Useful when debugging unexpected empty arrays.
 *
 * @example
 *   const first = safeAt(items, 0) ?? fallback;
 */
export function safeAt<T>(arr: T[], index: number): T | undefined {
  if (index < 0 || index >= arr.length) return undefined;
  return arr[index];
}

/**
 * Group an array of objects by a key, returning a Record<string, T[]>.
 * Useful for grouping insights by risk level or APTS category in debug views.
 *
 * @example
 *   const byRisk = groupBy(insights, (i) => i.risk);
 *   // { high: [...], medium: [...], low: [...] }
 */
export function groupBy<T>(
  arr: T[],
  keyFn: (item: T) => string
): Record<string, T[]> {
  const result: Record<string, T[]> = {};
  for (const item of arr) {
    const key = keyFn(item);
    (result[key] ??= []).push(item);
  }
  return result;
}
