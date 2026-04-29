import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { SectionCard } from "@/components/SectionCard";
import { ErrorBoundary } from "@/components/ErrorBoundary";

export const metadata: Metadata = {
  title: "Architecture — Madhat Labs",
  description: "웹·클라우드·IAM 계층 구조와 AI 에이전트 보안 아키텍처 개념 설명",
};

interface ArchLayer {
  id: string;
  label: string;
  color: string;
  ring: string;
  title: string;
  items: string[];
  threat: string;
}

const ARCH_LAYERS: ArchLayer[] = [
  {
    id: "web",
    label: "웹 계층",
    color: "text-blue-500",
    ring: "ring-blue-500/20 bg-blue-500/5",
    title: "웹 애플리케이션 계층",
    items: [
      "입력 검증 및 출력 이스케이프",
      "인증·인가 (AuthN/AuthZ) 경계",
      "세션 관리 및 토큰 수명주기",
      "CSP / CORS / HTTPS 강제 적용",
    ],
    threat: "프롬프트 인젝션, XSS, 세션 하이재킹",
  },
  {
    id: "cloud",
    label: "클라우드 계층",
    color: "text-purple-500",
    ring: "ring-purple-500/20 bg-purple-500/5",
    title: "클라우드 인프라 계층",
    items: [
      "IAM 역할 및 정책 최소 권한 설계",
      "VPC 네트워크 분리 및 Security Group",
      "서비스 간 인증 (Service Account, OIDC)",
      "시크릿 관리 (Vault, KMS)",
    ],
    threat: "권한 상승, 역할 탈취, 공급망 오염",
  },
  {
    id: "agent",
    label: "에이전트 계층",
    color: "text-green-500",
    ring: "ring-green-500/20 bg-green-500/5",
    title: "AI 에이전트 계층",
    items: [
      "신뢰 경계 명시적 설계",
      "툴 호출 화이트리스트 및 샌드박싱",
      "에이전트 간 신뢰 전파 차단",
      "Human-in-the-Loop 승인 정책",
    ],
    threat: "간접 인젝션, 메모리 오염, 과잉 권한",
  },
  {
    id: "iam",
    label: "IAM 계층",
    color: "text-orange-500",
    ring: "ring-orange-500/20 bg-orange-500/5",
    title: "Identity & Access Management",
    items: [
      "최소 권한 원칙 (PoLP) 전면 적용",
      "역할 기반 접근 제어 (RBAC)",
      "Conditions 및 SCP 추가 제약",
      "접근 로그 감사 및 이상 탐지",
    ],
    threat: "역할 체인 악용, 권한 상승 경로",
  },
];

export default function ArchitecturePage() {
  return (
    <PageContainer>
      <PageHeader
        title="보안 아키텍처 계층"
        description="웹·클라우드·IAM·에이전트 계층별 공격 표면과 방어 통제 개념을 설명합니다. 모든 내용은 개념적 수준입니다."
        badge="Architecture"
      />

      <ErrorBoundary namespace="ArchLayers">
      <div className="grid gap-5 sm:grid-cols-2">
        {ARCH_LAYERS.map((layer) => (
          <SectionCard key={layer.id} variant="bordered" className="relative">
            <div className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium mb-3 ring-1 ${layer.ring} ${layer.color}`}>
              {layer.label}
            </div>
            <h2 className="text-base font-semibold text-foreground mb-3">
              {layer.title}
            </h2>
            <ul className="space-y-1.5 mb-4">
              {layer.items.map((item) => (
                <li key={item} className="flex gap-2 text-sm text-muted-foreground">
                  <span className={`flex-shrink-0 ${layer.color}`} aria-hidden="true">›</span>
                  {item}
                </li>
              ))}
            </ul>
            <div className="border-t border-border pt-3">
              <p className="text-xs text-muted-foreground">
                <span className="font-medium text-foreground/70">주요 위협: </span>
                {layer.threat}
              </p>
            </div>
          </SectionCard>
        ))}
      </div>
      </ErrorBoundary>

      <div className="mt-10 p-6 rounded-xl bg-muted/40">
        <h2 className="text-base font-semibold text-foreground mb-3">
          멀티 에이전트 오케스트레이션 신뢰 모델
        </h2>
        <p className="text-sm text-muted-foreground leading-relaxed mb-4">
          멀티 에이전트 아키텍처에서 신뢰(Trust)는 자동으로 전파되어서는 안 됩니다.
          오케스트레이터(Orchestrator)는 하위 에이전트(Sub-agent)의 응답을 신뢰된 실행
          지시로 처리하지 않고, 독립적으로 검증한 후 구조화된 형태로만 소비해야 합니다.
        </p>
        <div className="flex flex-wrap gap-3 text-xs font-mono text-muted-foreground">
          <span className="px-2 py-1 rounded bg-background border border-border">User</span>
          <span className="self-center">→</span>
          <span className="px-2 py-1 rounded bg-background border border-blue-500/30 text-blue-400">Orchestrator</span>
          <span className="self-center">→ (검증 후)</span>
          <span className="px-2 py-1 rounded bg-background border border-border">Sub-agent A</span>
          <span className="self-center">/</span>
          <span className="px-2 py-1 rounded bg-background border border-border">Sub-agent B</span>
        </div>
        <p className="mt-3 text-xs text-muted-foreground/60">
          ※ 이 다이어그램은 개념 수준의 설명입니다. 실제 구현 세부사항은 포함하지 않습니다.
        </p>
      </div>
    </PageContainer>
  );
}
