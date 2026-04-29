/**
 * Runtime type guard library.
 *
 * These functions narrow TypeScript types at runtime, making it safe to
 * consume external or loosely-typed data without casting.
 *
 * ─────────────────────────────────────────────────────────────
 * Usage:
 *   import { isNonEmptyString, isInsight, assertInsightArray } from "@/lib/guards";
 *
 *   if (!isInsight(raw)) {
 *     logger.warn("data", "invalid insight shape", raw);
 *     return;
 *   }
 * ─────────────────────────────────────────────────────────────
 */

import type { Insight, RiskLevel, AptsCategory } from "@/data/insights";
import type { FaqItem } from "@/data/faq";
import type { NavItem } from "@/data/navigation";
import type { DefensivePrinciple, PrincipleTier } from "@/data/defensive-principles";
import type { ResearchQuestion, ResearchStatus } from "@/data/research-questions";
// debug.ts imports only from env.ts — no circular dependency risk
import { logger } from "@/lib/debug";

// ─── Primitives ──────────────────────────────────────────────

export function isString(v: unknown): v is string {
  return typeof v === "string";
}

export function isNonEmptyString(v: unknown): v is string {
  return typeof v === "string" && v.trim().length > 0;
}

export function isNumber(v: unknown): v is number {
  return typeof v === "number" && !Number.isNaN(v);
}

export function isObject(v: unknown): v is Record<string, unknown> {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

export function isArray<T>(
  v: unknown,
  itemGuard?: (item: unknown) => item is T
): v is T[] {
  if (!Array.isArray(v)) return false;
  if (itemGuard) return v.every(itemGuard);
  return true;
}

export function isNonEmptyArray<T>(
  v: unknown,
  itemGuard?: (item: unknown) => item is T
): v is [T, ...T[]] {
  return isArray(v, itemGuard) && v.length > 0;
}

// ─── Domain guards ───────────────────────────────────────────

const VALID_RISK_LEVELS: readonly RiskLevel[] = ["high", "medium", "low"] as const;
const VALID_APTS: readonly AptsCategory[] = ["SE","SC","HO","AL","AR","MR","TP","RP"] as const;

export function isRiskLevel(v: unknown): v is RiskLevel {
  return isString(v) && (VALID_RISK_LEVELS as string[]).includes(v);
}

export function isAptsCategory(v: unknown): v is AptsCategory {
  return isString(v) && (VALID_APTS as string[]).includes(v);
}

/**
 * Runtime guard for a single Insight object.
 * Validates required fields and their types.
 */
export function isInsight(v: unknown): v is Insight {
  if (!isObject(v)) return false;
  return (
    isNonEmptyString(v.id) &&
    isNonEmptyString(v.title) &&
    isNonEmptyString(v.summary) &&
    isNonEmptyString(v.detail) &&
    isRiskLevel(v.risk) &&
    isAptsCategory(v.apts) &&
    isArray(v.tags, isString)
  );
}

/**
 * Runtime guard for a single FaqItem.
 */
export function isFaqItem(v: unknown): v is FaqItem {
  if (!isObject(v)) return false;
  return (
    isNonEmptyString(v.id) &&
    isNonEmptyString(v.question) &&
    isNonEmptyString(v.answer)
  );
}

/**
 * Runtime guard for a single NavItem.
 */
export function isNavItem(v: unknown): v is NavItem {
  if (!isObject(v)) return false;
  return (
    isNonEmptyString(v.label) &&
    isNonEmptyString(v.href) &&
    v.href.startsWith("/")
  );
}

const VALID_TIERS: readonly PrincipleTier[] = [
  "foundational",
  "operational",
  "advanced",
] as const;

const VALID_STATUSES: readonly ResearchStatus[] = [
  "active",
  "completed",
  "planned",
] as const;

function isPrincipleTier(v: unknown): v is PrincipleTier {
  return isString(v) && (VALID_TIERS as string[]).includes(v);
}

function isResearchStatus(v: unknown): v is ResearchStatus {
  return isString(v) && (VALID_STATUSES as string[]).includes(v);
}

/**
 * Runtime guard for a single DefensivePrinciple.
 */
export function isDefensivePrinciple(v: unknown): v is DefensivePrinciple {
  if (!isObject(v)) return false;
  return (
    isNonEmptyString(v.id) &&
    isNumber(v.number) &&
    isNonEmptyString(v.title) &&
    isNonEmptyString(v.summary) &&
    isNonEmptyString(v.detail) &&
    isPrincipleTier(v.tier) &&
    isArray(v.practices, isString)
  );
}

/**
 * Runtime guard for a single ResearchQuestion.
 */
export function isResearchQuestion(v: unknown): v is ResearchQuestion {
  if (!isObject(v)) return false;
  return (
    isNonEmptyString(v.id) &&
    isNonEmptyString(v.question) &&
    isNonEmptyString(v.context) &&
    isResearchStatus(v.status) &&
    isArray(v.tags, isString)
  );
}

// ─── Assertion helpers ───────────────────────────────────────

/**
 * Assert-style guard: throws a TypeError with a descriptive message if the
 * value fails the guard. Use in data loaders and server-side code where a
 * hard failure is preferable to silently rendering garbage.
 *
 * @example
 *   const data = assertShape(raw, isInsight, "Insight from CMS");
 */
export function assertShape<T>(
  value: unknown,
  guard: (v: unknown) => v is T,
  label: string
): T {
  if (!guard(value)) {
    throw new TypeError(
      `[guards] assertShape failed for "${label}".\nReceived: ${JSON.stringify(value, null, 2)}`
    );
  }
  return value;
}

/**
 * Filter an array to only valid items, logging a warning for each invalid
 * entry. Use when partial data is acceptable (e.g., UI can show 14/15 items).
 */
export function filterValid<T>(
  items: unknown[],
  guard: (v: unknown) => v is T,
  label: string
): T[] {
  const valid: T[] = [];
  for (const item of items) {
    if (guard(item)) {
      valid.push(item);
    } else {
      // Synchronous warn — debug.ts has no import from guards.ts so no circular dep
      logger.warn("guards", `filterValid: invalid ${label} skipped`, item);
    }
  }
  return valid;
}
