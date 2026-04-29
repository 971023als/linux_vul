import { describe, it, expect } from "vitest";
import { researchQuestions, type ResearchStatus } from "../data/research-questions";
import { insights } from "../data/insights";

const VALID_STATUSES: ResearchStatus[] = ["active", "completed", "planned"];

describe("research-questions data", () => {
  it("should export a non-empty array", () => {
    expect(researchQuestions).toBeDefined();
    expect(Array.isArray(researchQuestions)).toBe(true);
    expect(researchQuestions.length).toBeGreaterThan(0);
  });

  it("every item should have required fields", () => {
    for (const rq of researchQuestions) {
      expect(typeof rq.id).toBe("string");
      expect(rq.id.startsWith("rq-")).toBe(true);
      expect(typeof rq.question).toBe("string");
      expect(rq.question.length).toBeGreaterThan(0);
      expect(typeof rq.context).toBe("string");
      expect(rq.context.length).toBeGreaterThan(0);
      expect(VALID_STATUSES).toContain(rq.status);
      expect(Array.isArray(rq.tags)).toBe(true);
      expect(rq.tags.length).toBeGreaterThan(0);
    }
  });

  it("should have no duplicate ids", () => {
    const ids = researchQuestions.map((rq) => rq.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it("relatedInsights references should point to existing insight ids", () => {
    const insightIds = new Set(insights.map((i) => i.id));
    for (const rq of researchQuestions) {
      if (rq.relatedInsights) {
        for (const ref of rq.relatedInsights) {
          expect(insightIds.has(ref)).toBe(true);
        }
      }
    }
  });

  it("should have at least one active research question", () => {
    const active = researchQuestions.filter((rq) => rq.status === "active");
    expect(active.length).toBeGreaterThan(0);
  });
});
