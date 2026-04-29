import { env } from "@/lib/env";

/** Explicit shape prevents accidental property additions and keeps the type
 *  independent of the runtime value — important because `url` is now dynamic. */
export interface SiteConfig {
  name: string;
  title: string;
  description: string;
  /** Base URL for the site. Read from NEXT_PUBLIC_SITE_URL at runtime;
   *  falls back to the GitHub Pages URL in production and localhost in dev. */
  url: string;
  ogImage: string;
  links: { github: string };
  author: string;
  keywords: string[];
}

export const siteConfig: SiteConfig = {
  name: "Madhat Labs",
  title: "Madhat Labs — AI 에이전트 보안 연구",
  description:
    "AI 에이전트 시스템의 공격 표면을 탐구하고 방어 원칙을 정립하는 방어형 보안 연구 저장소입니다.",
  /** Single source of truth — env.siteUrl reads NEXT_PUBLIC_SITE_URL or falls
   *  back intelligently per environment (see lib/env.ts). */
  url: env.siteUrl,
  ogImage: "/og-image.png",
  links: {
    github: "https://github.com/madhat-labs",
  },
  author: "Madhat Labs Research",
  keywords: [
    "AI 에이전트 보안",
    "LLM 보안",
    "프롬프트 인젝션",
    "DevSecOps",
    "방어형 보안 연구",
    "OWASP APTS",
    "IAM",
    "클라우드 보안",
  ],
};
