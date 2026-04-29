import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { SectionCard } from "@/components/SectionCard";
import { RiskCallout } from "@/components/RiskCallout";
import { AptsTable, APTS_CATEGORIES } from "@/components/AptsTable";
import { ErrorBoundary } from "@/components/ErrorBoundary";

export const metadata: Metadata = {
  title: "Governance — Madhat Labs",
  description: "윤리·법적 고지, 허용/비허용 사용 기준, APTS Governance Validation",
};

const ALLOWED_USES = [
  "AI 에이전트 시스템 방어 아키텍처 설계 참조",
  "보안 교육·강의 자료로 활용",
  "내부 보안 정책 수립 및 위험 평가 참조",
  "학술 연구 인용 (출처 명시)",
  "거버넌스 프레임워크 비교 연구",
] as const;

const DISALLOWED_USES = [
  "비인가 시스템 침투·공격에 활용",
  "공격 도구·익스플로잇 구현에 사용",
  "이 내용 기반의 공격형 파생 저작물 작성",
  "허가받지 않은 시스템의 취약점 탐색",
  "악의적 프롬프트 인젝션 페이로드 개발",
] as const;

const TIER_DESCRIPTIONS = [
  {
    title: "Tier 1 — 기초 거버넌스",
    body: "에이전트 사용 정책, 입력·출력 경계 정의, 기본 로깅 체계. 8개 도메인에 대한 기초 통제 설명 포함.",
  },
  {
    title: "Tier 2 — 운영 거버넌스",
    body: "위험도 기반 우선순위, 감사 추적, 이상 탐지 정책. SE·SC·HO·MR·RP 도메인의 운영 수준 통제.",
  },
  {
    title: "Tier 3 — 심화 거버넌스 (검토 기준 참조)",
    body: "AL·AR·TP 도메인의 고급 위협 모델과 아키텍처 수준 방어 원칙. Tier 3 기준까지 검토 가능한 수준으로 문서화. 이는 Tier 3 인증 완료가 아닙니다.",
  },
] as const;

export default function GovernancePage() {
  return (
    <PageContainer>
      <PageHeader
        title="거버넌스 및 윤리 고지"
        description="이 저장소의 허용·비허용 사용 기준과 APTS Governance Validation 내용을 안내합니다."
        badge="Governance"
      />

      {/* Allowed / Disallowed */}
      <ErrorBoundary namespace="GovernanceUsage">
        <div className="grid gap-5 sm:grid-cols-2 mb-10">
          <SectionCard variant="bordered">
            <h2 className="text-base font-semibold text-green-500 mb-3 flex items-center gap-2">
              <span aria-hidden="true">✓</span> 허용 사용
            </h2>
            <ul className="space-y-2 text-sm text-muted-foreground">
              {ALLOWED_USES.map((item) => (
                <li key={item} className="flex gap-2">
                  <span className="text-green-500 flex-shrink-0" aria-hidden="true">›</span>
                  {item}
                </li>
              ))}
            </ul>
          </SectionCard>

          <SectionCard variant="bordered">
            <h2 className="text-base font-semibold text-red-500 mb-3 flex items-center gap-2">
              <span aria-hidden="true">✗</span> 비허용 사용
            </h2>
            <ul className="space-y-2 text-sm text-muted-foreground">
              {DISALLOWED_USES.map((item) => (
                <li key={item} className="flex gap-2">
                  <span className="text-red-500 flex-shrink-0" aria-hidden="true">›</span>
                  {item}
                </li>
              ))}
            </ul>
          </SectionCard>
        </div>
      </ErrorBoundary>

      {/* APTS Governance Validation */}
      <ErrorBoundary namespace="GovernanceApts">
        <section aria-labelledby="apts-heading" className="mb-10">
          <h2 id="apts-heading" className="text-xl font-bold text-foreground mb-2">
            APTS Governance Validation
          </h2>
          <p className="text-sm text-muted-foreground mb-2">
            OWASP Agentic Penetration Testing Standard (APTS) 8개 도메인
          </p>

          <RiskCallout variant="info" className="mb-5">
            이 저장소는 APTS Tier 3 인증을 완료한 것이 아닙니다. APTS Tier 1~3 기준을 참조하여
            방어적 거버넌스 구조를 검토 가능한 형태로 문서화한 것입니다.
          </RiskCallout>

          {/* Extracted component — easier to test and reuse */}
          <AptsTable categories={APTS_CATEGORIES} className="mb-6" />

          {/* Tier descriptions */}
          <div className="space-y-4 mt-6">
            {TIER_DESCRIPTIONS.map((tier) => (
              <SectionCard key={tier.title} variant="muted">
                <h3 className="text-sm font-semibold text-foreground mb-2">
                  {tier.title}
                </h3>
                <p className="text-sm text-muted-foreground leading-relaxed">
                  {tier.body}
                </p>
              </SectionCard>
            ))}
          </div>
        </section>
      </ErrorBoundary>

      {/* Legal disclaimer */}
      <RiskCallout variant="warn" title="법적 고지">
        이 저장소의 내용은 현재 시점의 연구 결과를 바탕으로 하며, 법적 또는 규제 준수를
        보장하지 않습니다. 보안 결정을 내리기 전에 전문가 자문을 구하시기 바랍니다.
        이 내용의 오용으로 인한 결과에 대해 Madhat Labs는 책임을 지지 않습니다.
      </RiskCallout>
    </PageContainer>
  );
}
