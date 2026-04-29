/**
 * MDX content loader — placeholder implementation.
 *
 * In the current version (0.1.x), docs/ content is rendered as static
 * React components rather than parsed MDX files. This module provides
 * the interface for a future MDX pipeline.
 *
 * Planned: replace with `next-mdx-remote` or `@next/mdx` in v0.2.0
 * when the docs/ directory is populated with Markdown/MDX files.
 */

export interface DocFrontmatter {
  title: string;
  description?: string;
  date?: string;
  tags?: string[];
  draft?: boolean;
}

export interface DocContent {
  slug: string;
  frontmatter: DocFrontmatter;
  content: string;
}

/**
 * Placeholder: returns an empty list until real MDX parsing is wired up.
 * Will be replaced with `fs`-based MDX file discovery in v0.2.0.
 */
export async function getAllDocs(): Promise<DocContent[]> {
  return [];
}

/**
 * Placeholder: returns null for any slug.
 * Will be replaced with real MDX parsing in v0.2.0.
 */
export async function getDocBySlug(slug: string): Promise<DocContent | null> {
  void slug; // suppress unused parameter warning
  return null;
}
