import type { Metadata } from "next";
import Link from "next/link";
import { Hero } from "@/components/Hero";
import { SectionCard, SectionTitle } from "@/components/SectionCard";
import { PageContainer } from "@/components/PageContainer";
import { RiskCallout } from "@/components/RiskCallout";
import { Badge } from "@/components/Badge";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { insights } from "@/data/insights";
import { defensivePrinciples } from "@/data/defensive-principles";
import { filterValid, isInsight, isDefensivePrinciple } from "@/lib/guards";
import { logger } from "@/lib/debug";
import { siteConfig } from "@/lib/site";

export const metadata: Metadata = {
  title: siteConfig.title,
  description: siteConfig.description,
};

export default function HomePage() {
  // filterValid drops any malformed entries and logs a warning in dev
  const validInsights = filterValid(insights, isInsight, "Insight");
  const validPrinciples = filterValid(defensivePrinciples, isDefensivePrinciple, "DefensivePrinciple");

  const highlightedInsights = validInsights.filter((i) => i.risk === "high").slice(0, 3);
  const highlightedPrinciples = validPrinciples
    .filter((p) => p.tier === "foundational")
    .slice(0, 3);

  // Surface data integrity issues early in development
  if (validInsights.length !== insights.length) {
    logger.warn(
      "HomePage",
      `${insights.length - validInsights.length}개 인사이트가 guards를 통과하지 못했습니다.`
    );
  }
  if (validPrinciples.length !== defensivePrinciples.length) {
    logger.warn(
      "HomePage",
      `${defensivePrinciples.length - validPrinciples.length}개 방어 원칙이 guards를 통과하지 못했습니다.`
    );
  }

  return (
    <>
      <Hero />
      <PageContainer>
        {/* Governance callout */}
        <RiskCallout variant="info" title="방어형 연구 저장소" className="mb-10">
          이 사이트의 모든 내용은 방어·교육 목적에 한정됩니다. 공격 코드, 익스플로잇,
          취약점 재현 절차는 포함하지 않습니다.{" "}
          <Link href="/governance" className="underline hover:text-foreground">
            거버넌스 정책 보기 →
          </Link>
        </RiskCallout>

        {/* High-risk insights preview */}
        <ErrorBoundary namespace="InsightsPreview" fallback={
          <p className="text-sm text-muted-foreground">인사이트를 불러올 수 없습니다.</p>
        }>
          <section aria-labelledby="insights-heading" className="mb-14">
            <div className="flex items-center justify-between mb-6">
              <SectionTitle id="insights-heading" as="h2">
                주요 고위험 인사이트
              </SectionTitle>
              <Link
                href="/insights"
                className="text-sm text-blue-500 hover:text-blue-400 transition-colors"
              >
                전체 보기 →
              </Link>
            </div>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {highlightedInsights.map((insight) => (
                <SectionCard key={insight.id} variant="bordered">
                  <div className="flex items-start gap-2 mb-2">
                    <Badge variant="danger">위험도 높음</Badge>
                    <Badge variant="outline" className="font-mono">
                      {insight.apts}
                    </Badge>
                  </div>
                  <h3 className="text-sm font-semibold text-foreground mb-1">
                    {insight.title}
                  </h3>
                  <p className="text-xs text-muted-foreground leading-relaxed">
                    {insight.summary}
                  </p>
                </SectionCard>
              ))}
            </div>
          </section>
        </ErrorBoundary>

        {/* Foundational principles preview */}
        <ErrorBoundary namespace="PrinciplesPreview" fallback={
          <p className="text-sm text-muted-foreground">방어 원칙을 불러올 수 없습니다.</p>
        }>
          <section aria-labelledby="principles-heading">
            <div className="flex items-center justify-between mb-6">
              <SectionTitle id="principles-heading" as="h2">
                핵심 방어 원칙
              </SectionTitle>
              <Link
                href="/defensive-principles"
                className="text-sm text-blue-500 hover:text-blue-400 transition-colors"
              >
                11개 전체 보기 →
              </Link>
            </div>
            <div className="grid gap-4 sm:grid-cols-3">
              {highlightedPrinciples.map((principle) => (
                <SectionCard key={principle.id} variant="muted">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-xl font-bold text-blue-500" aria-hidden="true">
                      {String(principle.number).padStart(2, "0")}
                    </span>
                  </div>
                  <h3 className="text-sm font-semibold text-foreground mb-1">
                    {principle.title}
                  </h3>
                  <p className="text-xs text-muted-foreground leading-relaxed">
                    {principle.summary}
                  </p>
                </SectionCard>
              ))}
            </div>
          </section>
        </ErrorBoundary>
      </PageContainer>
    </>
  );
}
