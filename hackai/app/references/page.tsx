import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { ReferenceCard, type Reference } from "@/components/ReferenceCard";
import { ErrorBoundary } from "@/components/ErrorBoundary";

export const metadata: Metadata = {
  title: "References — Madhat Labs",
  description: "AI 에이전트 보안 연구 참조 자료 목록",
};

const REFERENCES = [
  {
    id: "ref-001",
    title: "OWASP Top 10 for Large Language Model Applications",
    source: "OWASP",
    year: "2023",
    type: "standard",
    url: "https://owasp.org/www-project-top-10-for-large-language-model-applications/",
    description:
      "LLM 애플리케이션의 주요 10가지 보안 위험. 프롬프트 인젝션, 과도한 에이전트 권한 등 핵심 위협을 정의한다.",
  },
  {
    id: "ref-002",
    title:
      "Not What You've Signed Up For: Compromising Real-World LLM-Integrated Applications with Indirect Prompt Injection",
    source: "Greshake et al.",
    year: "2023",
    type: "paper",
    description:
      "간접 프롬프트 인젝션 공격 유형을 체계적으로 분류하고 실제 LLM 통합 애플리케이션에 대한 공격 표면을 분석한 연구. 방어 관점에서 샌드박싱과 신뢰 경계 설계의 필요성을 논증한다.",
  },
  {
    id: "ref-003",
    title: "OWASP APTS: Agentic Penetration Testing Standard",
    source: "OWASP",
    year: "2024",
    type: "standard",
    description:
      "AI 에이전트 시스템에 대한 침투 테스트 표준 프레임워크. SE·SC·HO·AL·AR·MR·TP·RP 8개 도메인으로 공격 표면을 분류한다.",
  },
  {
    id: "ref-004",
    title: "Prompt Injection Attacks against GPT-3",
    source: "Riley et al.",
    year: "2022",
    type: "paper",
    description:
      "GPT-3 기반 시스템에 대한 프롬프트 인젝션 공격을 최초로 체계화한 연구. '프롬프트 인젝션'이라는 용어를 정립했다.",
  },
  {
    id: "ref-005",
    title: "AWS Security Best Practices for AI Services",
    source: "Amazon Web Services",
    year: "2024",
    type: "blog",
    description:
      "AWS 환경에서 AI 서비스를 운영할 때 적용해야 할 IAM 최소 권한, 네트워크 분리, 시크릿 관리 지침.",
  },
  {
    id: "ref-006",
    title: "Microsoft Responsible AI Principles",
    source: "Microsoft",
    year: "2023",
    type: "standard",
    description:
      "공정성, 신뢰성, 개인정보 보호, 포용성, 투명성, 책임을 AI 설계 원칙으로 정의한 프레임워크.",
  },
  {
    id: "ref-007",
    title: "Mitigating Skeleton Key: LLM Jailbreak and Safety Guidance",
    source: "Microsoft Security",
    year: "2024",
    type: "blog",
    description:
      "LLM 안전 장치 우회(Jailbreak) 유형인 Skeleton Key 공격의 메커니즘과 완화 방법을 설명한 Microsoft의 기술 블로그.",
  },
  {
    id: "ref-008",
    title: "Claude's Constitution — Model Specification",
    source: "Anthropic",
    year: "2024",
    type: "standard",
    description:
      "Anthropic이 Claude 모델의 행동 원칙을 정의한 Constitutional AI 명세. 에이전트 안전성 설계의 참조 모델로 활용된다.",
  },
] satisfies Reference[];

export default function ReferencesPage() {
  return (
    <PageContainer>
      <PageHeader
        title="참조 자료"
        description="이 저장소의 인사이트와 방어 원칙은 아래 공개 자료를 참조합니다."
        badge="References"
      />

      <ErrorBoundary namespace="ReferenceList">
        <div className="space-y-4">
          {REFERENCES.map((ref) => (
            <ReferenceCard key={ref.id} reference={ref} />
          ))}
        </div>
      </ErrorBoundary>

      <p className="mt-8 text-xs text-muted-foreground">
        ※ 위 자료는 공개된 연구·표준·문서를 인용한 것입니다. 각 자료의 저작권은
        원저작자에게 있습니다.
      </p>
    </PageContainer>
  );
}
