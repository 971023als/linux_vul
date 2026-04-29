import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { SectionCard } from "@/components/SectionCard";
import { Badge } from "@/components/Badge";
import { RiskCallout } from "@/components/RiskCallout";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { researchQuestions } from "@/data/research-questions";
import { filterValid, isResearchQuestion } from "@/lib/guards";

export const metadata: Metadata = {
  title: "About — Madhat Labs",
  description: "Madhat Labs 연구 목적, 범위, 대상 독자 소개",
};

export default function AboutPage() {
  const validResearch = filterValid(researchQuestions, isResearchQuestion, "ResearchQuestion");

  return (
    <PageContainer narrow>
      <PageHeader
        title="About Madhat Labs"
        description="AI 에이전트 보안 연구의 목적과 범위를 소개합니다."
        badge="소개"
      />

      <div className="space-y-6">
        <SectionCard variant="bordered">
          <h2 className="text-lg font-semibold text-foreground mb-3">연구 목적</h2>
          <p className="text-sm text-muted-foreground leading-relaxed">
            Madhat Labs는 AI 에이전트 시스템, 클라우드 환경, IAM 아키텍처에서 발생하는
            보안 취약점을 방어 관점에서 연구합니다. 공격자의 시각으로 위협을 이해하되,
            그 결과는 오직 방어·교육·정책 수립에 활용합니다.
          </p>
        </SectionCard>

        <SectionCard variant="bordered">
          <h2 className="text-lg font-semibold text-foreground mb-3">연구 범위</h2>
          <ul className="space-y-2 text-sm text-muted-foreground">
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              AI 에이전트 보안: 프롬프트 인젝션, 간접 인젝션, 에이전트 권한 남용
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              클라우드·IAM 보안: 역할 탈취, 권한 상승, 공급망 위협
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              멀티 에이전트 아키텍처: 신뢰 전파, 오케스트레이션 보안
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              DevSecOps 통합: 보안 자동화, CI/CD 파이프라인 보안
            </li>
          </ul>
        </SectionCard>

        <SectionCard variant="bordered">
          <h2 className="text-lg font-semibold text-foreground mb-3">대상 독자</h2>
          <ul className="space-y-2 text-sm text-muted-foreground">
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              AI/LLM 애플리케이션을 개발하는 백엔드·풀스택 개발자
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              클라우드 환경의 보안을 담당하는 보안 엔지니어·아키텍트
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              AI 거버넌스 및 컴플라이언스를 설계하는 정책 담당자
            </li>
            <li className="flex gap-2">
              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">•</span>
              방어팀(Blue Team) 및 DevSecOps 실무자
            </li>
          </ul>
        </SectionCard>

        {/* Active research questions — sourced from data/research-questions.ts */}
        <ErrorBoundary namespace="ResearchQuestions">
        <SectionCard variant="muted">
          <h2 className="text-lg font-semibold text-foreground mb-4">현재 연구 주제</h2>
          <ul className="space-y-4">
            {validResearch.map((rq) => (
              <li key={rq.id} className="flex gap-3">
                <Badge
                  variant={
                    rq.status === "active"
                      ? "default"
                      : rq.status === "planned"
                      ? "outline"
                      : "success"
                  }
                  className="flex-shrink-0 mt-0.5"
                >
                  {rq.status === "active" ? "진행 중" : rq.status === "planned" ? "예정" : "완료"}
                </Badge>
                <div>
                  <p className="text-sm font-medium text-foreground leading-snug">
                    {rq.question}
                  </p>
                  <p className="text-xs text-muted-foreground mt-1 leading-relaxed">
                    {rq.context}
                  </p>
                </div>
              </li>
            ))}
          </ul>
        </SectionCard>
        </ErrorBoundary>

        <RiskCallout variant="warn" title="이 저장소가 포함하지 않는 것">
          공격 실행 코드, 익스플로잇, 취약점 재현 절차, 운영 환경 자격증명은 어떤
          버전에서도 포함하지 않습니다. 모든 내용은 개념적 수준의 설명을 원칙으로 합니다.
        </RiskCallout>
      </div>
    </PageContainer>
  );
}
