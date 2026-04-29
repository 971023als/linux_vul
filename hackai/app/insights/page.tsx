import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { InsightCard } from "@/components/InsightCard";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { insights, type RiskLevel } from "@/data/insights";
import { filterValid, isInsight } from "@/lib/guards";
import { groupBy } from "@/lib/utils";
import { logger } from "@/lib/debug";

export const metadata: Metadata = {
  title: "Insights — Madhat Labs",
  description: "AI 에이전트 보안 인사이트 15개 — 위험도 및 APTS 카테고리별 정리",
};

/** Indicator dot colour per risk level */
const RISK_DOT: Record<string, string> = {
  high:   "bg-red-500",
  medium: "bg-yellow-500",
  low:    "bg-green-500",
};

/** Korean label per risk level */
const RISK_LABEL: Record<string, string> = {
  high:   "위험도 높음",
  medium: "위험도 중간",
  low:    "위험도 낮음",
};

/** Render order for risk groups */
const RISK_ORDER = ["high", "medium", "low"] as const;

export default function InsightsPage() {
  // filterValid drops malformed entries before groupBy — data integrity first
  const validInsights = filterValid(insights, isInsight, "Insight");

  if (validInsights.length !== insights.length) {
    logger.warn(
      "InsightsPage",
      `${insights.length - validInsights.length}개 인사이트가 유효성 검사를 통과하지 못했습니다.`
    );
  }

  const byRisk = groupBy(validInsights, (i) => i.risk);

  return (
    <PageContainer>
      <PageHeader
        title="보안 인사이트"
        description={`AI 에이전트 시스템의 주요 보안 위협과 방어 관점 분석 ${validInsights.length}개. 모든 내용은 방어·교육 목적입니다.`}
        badge="Insights"
      />

      {RISK_ORDER.map((level) => {
        const items = byRisk[level] ?? [];
        if (items.length === 0) return null;

        const headingId = `${level}-risk-heading`;

        return (
          <section key={level} className="mb-10" aria-labelledby={headingId}>
            <h2
              id={headingId}
              className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2"
            >
              <span
                className={`inline-block h-2 w-2 rounded-full ${RISK_DOT[level]}`}
                aria-hidden="true"
              />
              {RISK_LABEL[level]}
              <span className="text-sm font-normal text-muted-foreground">
                ({items.length}개)
              </span>
            </h2>

            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {items.map((insight) => (
                /* ErrorBoundary isolates a single broken card — rest of grid stays visible */
                <ErrorBoundary key={insight.id} namespace={`InsightCard-${insight.id}`}>
                  <InsightCard insight={insight} />
                </ErrorBoundary>
              ))}
            </div>
          </section>
        );
      })}
    </PageContainer>
  );
}
