import { describe, it, expect } from "vitest";
import { navItems } from "../data/navigation";

describe("navigation data", () => {
  it("should export an array with at least one item", () => {
    expect(navItems).toBeDefined();
    expect(Array.isArray(navItems)).toBe(true);
    expect(navItems.length).toBeGreaterThan(0);
  });

  it("every item should have required fields: label and href", () => {
    for (const item of navItems) {
      expect(typeof item.label).toBe("string");
      expect(item.label.length).toBeGreaterThan(0);
      expect(typeof item.href).toBe("string");
      expect(item.href.startsWith("/")).toBe(true);
    }
  });

  it("should include a home route at /", () => {
    const home = navItems.find((item) => item.href === "/");
    expect(home).toBeDefined();
  });

  it("should have no duplicate hrefs", () => {
    const hrefs = navItems.map((item) => item.href);
    const uniqueHrefs = new Set(hrefs);
    expect(uniqueHrefs.size).toBe(hrefs.length);
  });

  it("should have no duplicate labels", () => {
    const labels = navItems.map((item) => item.label);
    const uniqueLabels = new Set(labels);
    expect(uniqueLabels.size).toBe(labels.length);
  });
});
