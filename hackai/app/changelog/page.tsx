import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { Timeline, type TimelineItem } from "@/components/Timeline";
import { SectionCard } from "@/components/SectionCard";
import { ErrorBoundary } from "@/components/ErrorBoundary";

export const metadata: Metadata = {
  title: "Changelog — Madhat Labs",
  description: "Madhat Labs 보안 연구 사이트 변경 이력",
};

const changelogItems: TimelineItem[] = [
  {
    id: "v0.1.0",
    date: "2025-07-01",
    title: "v0.1.0 — 초기 공개",
    badge: "릴리즈",
    description:
      "Next.js 14 App Router 기반 정적 문서 사이트 초기 공개. AI 에이전트 보안 인사이트 15개, 방어 원칙 11개, FAQ 15개, APTS Governance Validation 포함.",
  },
];

interface PlannedItem {
  /** Semantic version this feature is targeted for. */
  version: string;
  description: string;
}

const plannedItems: PlannedItem[] = [
  { version: "0.2.0", description: "검색 기능 추가 (Pagefind 기반 정적 검색)" },
  { version: "0.2.0", description: "docs/ 디렉터리 기반 문서 목록 자동 생성" },
  { version: "0.3.0", description: "전자금융업 보안진단 기준표 연동 (웹·모바일·HTS 66개 항목)" },
  { version: "0.3.0", description: "위험도 기반 대시보드 뷰 추가" },
  { version: "0.4.0", description: "Markdown/HTML 보고서 자동 생성 기능" },
  { version: "1.0.0", description: "정적 배포 (GitHub Pages 또는 Vercel)" },
];

export default function ChangelogPage() {
  return (
    <PageContainer narrow>
      <PageHeader
        title="Changelog"
        description="이 사이트의 주요 변경 사항을 기록합니다."
        badge="Changelog"
      />

      <h2 className="text-base font-semibold text-foreground mb-5">릴리즈 이력</h2>
      <ErrorBoundary namespace="ChangelogTimeline">
        <Timeline items={changelogItems} className="mb-12" />
      </ErrorBoundary>

      <ErrorBoundary namespace="ChangelogPlanned">
        <SectionCard variant="muted">
          <h2 className="text-base font-semibold text-foreground mb-4">향후 계획</h2>
          <ul className="space-y-2">
            {plannedItems.map((item) => (
              <li key={`${item.version}-${item.description}`} className="flex gap-3 text-sm text-muted-foreground">
                <span className="font-mono text-xs text-blue-400 flex-shrink-0 mt-0.5">
                  v{item.version}
                </span>
                <span>{item.description}</span>
              </li>
            ))}
          </ul>
        </SectionCard>
      </ErrorBoundary>

      <div className="mt-8 text-xs text-muted-foreground space-y-1">
        <p>형식: <a href="https://keepachangelog.com/ko/1.0.0/" target="_blank" rel="noopener noreferrer" className="underline hover:text-foreground">Keep a Changelog</a></p>
        <p>버전 관리: Semantic Versioning</p>
      </div>
    </PageContainer>
  );
}
