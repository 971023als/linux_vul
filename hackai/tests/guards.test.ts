import { describe, it, expect } from "vitest";
import {
  isString,
  isNonEmptyString,
  isNumber,
  isObject,
  isArray,
  isNonEmptyArray,
  isRiskLevel,
  isAptsCategory,
  isInsight,
  isFaqItem,
  isNavItem,
  isDefensivePrinciple,
  isResearchQuestion,
  assertShape,
  filterValid,
} from "../lib/guards";
import { insights } from "../data/insights";
import { faqItems } from "../data/faq";
import { navItems } from "../data/navigation";
import { defensivePrinciples } from "../data/defensive-principles";
import { researchQuestions } from "../data/research-questions";

// ─── Primitive guards ─────────────────────────────────────────

describe("isString", () => {
  it("accepts strings", () => expect(isString("hello")).toBe(true));
  it("rejects numbers", () => expect(isString(42)).toBe(false));
  it("rejects null", () => expect(isString(null)).toBe(false));
});

describe("isNonEmptyString", () => {
  it("accepts non-empty strings", () => expect(isNonEmptyString("hi")).toBe(true));
  it("rejects empty string", () => expect(isNonEmptyString("")).toBe(false));
  it("rejects whitespace-only", () => expect(isNonEmptyString("   ")).toBe(false));
  it("rejects non-string", () => expect(isNonEmptyString(0)).toBe(false));
});

describe("isNumber", () => {
  it("accepts valid numbers", () => expect(isNumber(42)).toBe(true));
  it("rejects NaN", () => expect(isNumber(NaN)).toBe(false));
  it("rejects strings", () => expect(isNumber("3")).toBe(false));
});

describe("isObject", () => {
  it("accepts plain objects", () => expect(isObject({})).toBe(true));
  it("rejects arrays", () => expect(isObject([])).toBe(false));
  it("rejects null", () => expect(isObject(null)).toBe(false));
});

describe("isArray", () => {
  it("accepts arrays", () => expect(isArray([1, 2, 3])).toBe(true));
  it("validates items when guard provided", () => {
    expect(isArray(["a", "b"], isString)).toBe(true);
    expect(isArray(["a", 1], isString)).toBe(false);
  });
  it("rejects non-arrays", () => expect(isArray("not-array")).toBe(false));
});

describe("isNonEmptyArray", () => {
  it("accepts non-empty arrays", () => expect(isNonEmptyArray([1])).toBe(true));
  it("rejects empty arrays", () => expect(isNonEmptyArray([])).toBe(false));
});

// ─── Domain guards ────────────────────────────────────────────

describe("isRiskLevel", () => {
  it("accepts valid levels", () => {
    expect(isRiskLevel("high")).toBe(true);
    expect(isRiskLevel("medium")).toBe(true);
    expect(isRiskLevel("low")).toBe(true);
  });
  it("rejects invalid levels", () => {
    expect(isRiskLevel("critical")).toBe(false);
    expect(isRiskLevel("")).toBe(false);
  });
});

describe("isAptsCategory", () => {
  const valid = ["SE", "SC", "HO", "AL", "AR", "MR", "TP", "RP"];
  it("accepts all 8 APTS categories", () => {
    for (const cat of valid) expect(isAptsCategory(cat)).toBe(true);
  });
  it("rejects invalid categories", () => {
    expect(isAptsCategory("XX")).toBe(false);
    expect(isAptsCategory("se")).toBe(false); // case-sensitive
  });
});

// ─── Shape guards against real data ──────────────────────────

describe("isInsight — real data", () => {
  it("all insights pass the guard", () => {
    for (const insight of insights) {
      expect(isInsight(insight)).toBe(true);
    }
  });

  it("rejects object missing required fields", () => {
    expect(isInsight({ id: "ins-x" })).toBe(false);
    expect(isInsight({ id: "", title: "x", summary: "x", detail: "x", risk: "high", apts: "SE", tags: [] })).toBe(false);
  });

  it("rejects invalid risk level", () => {
    const bad = { id: "ins-x", title: "t", summary: "s", detail: "d", risk: "extreme", apts: "SE", tags: [] };
    expect(isInsight(bad)).toBe(false);
  });
});

describe("isFaqItem — real data", () => {
  it("all faq items pass the guard", () => {
    for (const item of faqItems) {
      expect(isFaqItem(item)).toBe(true);
    }
  });

  it("accepts items with optional reference field", () => {
    const withRef = { id: "faq-x", question: "Q?", answer: "A.", reference: "https://example.com" };
    expect(isFaqItem(withRef)).toBe(true);
  });

  it("rejects items missing required fields", () => {
    expect(isFaqItem({ id: "faq-x", question: "Q?" })).toBe(false); // missing answer
    expect(isFaqItem({ question: "Q?", answer: "A." })).toBe(false); // missing id
  });
});

describe("isNavItem — real data", () => {
  it("all nav items pass the guard", () => {
    for (const item of navItems) {
      expect(isNavItem(item)).toBe(true);
    }
  });
});

describe("isDefensivePrinciple — real data", () => {
  it("all defensive principles pass the guard", () => {
    for (const p of defensivePrinciples) {
      expect(isDefensivePrinciple(p)).toBe(true);
    }
  });

  it("rejects object missing required fields", () => {
    expect(isDefensivePrinciple({ id: "dp-x", number: 1, title: "t" })).toBe(false);
    expect(isDefensivePrinciple({ id: "dp-x", number: 1, title: "t", summary: "s", detail: "d", tier: "invalid", practices: [] })).toBe(false);
  });
});

describe("isResearchQuestion — real data", () => {
  it("all research questions pass the guard", () => {
    for (const rq of researchQuestions) {
      expect(isResearchQuestion(rq)).toBe(true);
    }
  });

  it("rejects invalid status", () => {
    const bad = { id: "rq-x", question: "Q?", context: "C", status: "unknown", tags: ["t"] };
    expect(isResearchQuestion(bad)).toBe(false);
  });

  it("rejects missing required fields", () => {
    expect(isResearchQuestion({ id: "rq-x", question: "Q?", status: "active" })).toBe(false); // missing context
  });
});

// ─── assertShape ─────────────────────────────────────────────

describe("assertShape", () => {
  it("returns the value when guard passes", () => {
    const result = assertShape("hello", isNonEmptyString, "greeting");
    expect(result).toBe("hello");
  });

  it("throws TypeError when guard fails", () => {
    expect(() => assertShape("", isNonEmptyString, "greeting")).toThrow(TypeError);
    expect(() => assertShape(null, isNonEmptyString, "label")).toThrow(/assertShape failed/);
  });
});

// ─── filterValid ─────────────────────────────────────────────

describe("filterValid", () => {
  it("returns only valid items", () => {
    const mixed = ["hello", "", "world", "  "];
    const result = filterValid(mixed, isNonEmptyString, "string");
    expect(result).toEqual(["hello", "world"]);
  });

  it("returns empty array if all items invalid", () => {
    const result = filterValid([null, undefined, 42], isNonEmptyString, "test");
    expect(result).toHaveLength(0);
  });
});
