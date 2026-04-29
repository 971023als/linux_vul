import { describe, it, expect } from "vitest";
import { faqItems } from "../data/faq";

describe("faq data", () => {
  it("should export an array with at least 15 items", () => {
    expect(faqItems).toBeDefined();
    expect(Array.isArray(faqItems)).toBe(true);
    expect(faqItems.length).toBeGreaterThanOrEqual(15);
  });

  it("every item should have required fields: id, question, answer", () => {
    for (const item of faqItems) {
      expect(typeof item.id).toBe("string");
      expect(item.id.startsWith("faq-")).toBe(true);
      expect(typeof item.question).toBe("string");
      expect(item.question.length).toBeGreaterThan(0);
      expect(typeof item.answer).toBe("string");
      expect(item.answer.length).toBeGreaterThan(0);
    }
  });

  it("should have no duplicate ids", () => {
    const ids = faqItems.map((item) => item.id);
    const uniqueIds = new Set(ids);
    expect(uniqueIds.size).toBe(ids.length);
  });

  it("should have no duplicate questions", () => {
    const questions = faqItems.map((item) => item.question);
    const uniqueQuestions = new Set(questions);
    expect(uniqueQuestions.size).toBe(questions.length);
  });

  it("tags should be an array when present", () => {
    for (const item of faqItems) {
      if (item.tags !== undefined) {
        expect(Array.isArray(item.tags)).toBe(true);
        expect(item.tags.length).toBeGreaterThan(0);
      }
    }
  });
});
