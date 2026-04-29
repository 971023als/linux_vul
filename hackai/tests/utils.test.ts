import { describe, it, expect } from "vitest";
import { cn, formatDate, truncate, slugToTitle, isExternalUrl, safeAt, groupBy } from "../lib/utils";

describe("cn (class merge)", () => {
  it("merges simple class strings", () => {
    expect(cn("foo", "bar")).toBe("foo bar");
  });

  it("deduplicates conflicting tailwind classes", () => {
    // twMerge should keep the last one
    expect(cn("text-sm", "text-lg")).toBe("text-lg");
  });

  it("ignores falsy values", () => {
    expect(cn("foo", false && "bar", undefined, null as unknown as string)).toBe("foo");
  });

  it("supports conditional objects", () => {
    expect(cn({ active: true, inactive: false })).toBe("active");
  });
});

describe("formatDate", () => {
  it("formats a valid ISO date to Korean locale", () => {
    const result = formatDate("2025-07-01");
    expect(result).toContain("2025");
    expect(result).toContain("7");
  });

  it("returns '날짜 오류' for invalid date string", () => {
    expect(formatDate("not-a-date")).toBe("날짜 오류");
    expect(formatDate("")).toBe("날짜 오류");
  });
});

describe("truncate", () => {
  it("returns the original string if within limit", () => {
    expect(truncate("hello", 10)).toBe("hello");
    expect(truncate("hello", 5)).toBe("hello");
  });

  it("truncates and appends ellipsis", () => {
    const result = truncate("hello world", 5);
    expect(result).toContain("…");
    expect(result.length).toBeLessThanOrEqual(6); // 5 chars + ellipsis
  });
});

describe("slugToTitle", () => {
  it("converts kebab-case to Title Case", () => {
    expect(slugToTitle("hello-world")).toBe("Hello World");
    expect(slugToTitle("ai-agent-security")).toBe("Ai Agent Security");
  });

  it("handles single word", () => {
    expect(slugToTitle("insights")).toBe("Insights");
  });
});

describe("isExternalUrl", () => {
  it("identifies http/https URLs as external", () => {
    expect(isExternalUrl("https://example.com")).toBe(true);
    expect(isExternalUrl("http://example.com")).toBe(true);
  });

  it("identifies protocol-relative URLs as external", () => {
    expect(isExternalUrl("//example.com")).toBe(true);
  });

  it("identifies internal paths as not external", () => {
    expect(isExternalUrl("/about")).toBe(false);
    expect(isExternalUrl("/insights")).toBe(false);
    expect(isExternalUrl("relative/path")).toBe(false);
  });
});

describe("safeAt", () => {
  const arr = ["a", "b", "c"];

  it("returns item at valid index", () => {
    expect(safeAt(arr, 0)).toBe("a");
    expect(safeAt(arr, 2)).toBe("c");
  });

  it("returns undefined for out-of-bounds index", () => {
    expect(safeAt(arr, 3)).toBeUndefined();
    expect(safeAt(arr, -1)).toBeUndefined();
  });

  it("returns undefined for empty array", () => {
    expect(safeAt([], 0)).toBeUndefined();
  });
});

describe("groupBy", () => {
  const items = [
    { id: 1, cat: "a" },
    { id: 2, cat: "b" },
    { id: 3, cat: "a" },
  ];

  it("groups items by key function", () => {
    const result = groupBy(items, (i) => i.cat);
    expect(result.a).toHaveLength(2);
    expect(result.b).toHaveLength(1);
    expect(result.a.map((i) => i.id)).toEqual([1, 3]);
  });

  it("returns empty object for empty array", () => {
    expect(groupBy([], (i: { cat: string }) => i.cat)).toEqual({});
  });
});
