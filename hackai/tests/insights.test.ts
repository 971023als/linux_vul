import { describe, it, expect } from "vitest";
import { insights, type RiskLevel, type AptsCategory } from "../data/insights";

const VALID_RISK_LEVELS: RiskLevel[] = ["high", "medium", "low"];
const VALID_APTS_CATEGORIES: AptsCategory[] = [
  "SE",
  "SC",
  "HO",
  "AL",
  "AR",
  "MR",
  "TP",
  "RP",
];

describe("insights data", () => {
  it("should export an array with at least 15 items", () => {
    expect(insights).toBeDefined();
    expect(Array.isArray(insights)).toBe(true);
    expect(insights.length).toBeGreaterThanOrEqual(15);
  });

  it("every item should have required fields", () => {
    for (const item of insights) {
      expect(typeof item.id).toBe("string");
      expect(item.id.startsWith("ins-")).toBe(true);
      expect(typeof item.title).toBe("string");
      expect(item.title.length).toBeGreaterThan(0);
      expect(typeof item.summary).toBe("string");
      expect(item.summary.length).toBeGreaterThan(0);
      expect(typeof item.detail).toBe("string");
      expect(item.detail.length).toBeGreaterThan(0);
    }
  });

  it("every item should have a valid risk level", () => {
    for (const item of insights) {
      expect(VALID_RISK_LEVELS).toContain(item.risk);
    }
  });

  it("every item should have a valid APTS category", () => {
    for (const item of insights) {
      expect(VALID_APTS_CATEGORIES).toContain(item.apts);
    }
  });

  it("should have no duplicate ids", () => {
    const ids = insights.map((item) => item.id);
    const uniqueIds = new Set(ids);
    expect(uniqueIds.size).toBe(ids.length);
  });

  it("should cover all 8 APTS categories", () => {
    const usedCategories = new Set(insights.map((item) => item.apts));
    for (const category of VALID_APTS_CATEGORIES) {
      expect(usedCategories.has(category)).toBe(true);
    }
  });

  it("tags should be an array with at least one entry", () => {
    for (const item of insights) {
      expect(Array.isArray(item.tags)).toBe(true);
      expect(item.tags.length).toBeGreaterThan(0);
    }
  });

  it("should have at least one high-risk insight", () => {
    const highRisk = insights.filter((item) => item.risk === "high");
    expect(highRisk.length).toBeGreaterThan(0);
  });
});
