export type ResearchStatus = "active" | "completed" | "planned";

export interface ResearchQuestion {
  id: string;
  question: string;
  context: string;
  status: ResearchStatus;
  relatedInsights?: string[];
  tags: string[];
}

export const researchQuestions = [
  {
    id: "rq-001",
    question:
      "오케스트레이터-에이전트 간 신뢰 전파를 차단하는 가장 효과적인 아키텍처 패턴은 무엇인가?",
    context:
      "멀티 에이전트 시스템에서 하위 에이전트의 오염된 응답이 오케스트레이터를 통해 전체 파이프라인으로 전파되는 경로를 분석하고, 경계 검증 패턴을 도출한다.",
    status: "active",
    relatedInsights: ["ins-004"],
    tags: ["멀티 에이전트", "신뢰 전파", "아키텍처"],
  },
  {
    id: "rq-002",
    question:
      "간접 프롬프트 인젝션 탐지를 위한 실용적인 전처리 필터 기준은 무엇인가?",
    context:
      "RAG 파이프라인에서 외부 문서를 처리할 때 인젝션 페이로드를 식별하는 패턴 기반 또는 의미 기반 필터의 효과성을 비교 연구한다.",
    status: "active",
    relatedInsights: ["ins-002"],
    tags: ["간접 인젝션", "필터", "RAG"],
  },
  {
    id: "rq-003",
    question:
      "AI 에이전트의 최소 권한 설계에서 동적 권한 위임의 안전한 경계는 어디인가?",
    context:
      "에이전트가 사용자 요청에 따라 권한을 일시적으로 확장해야 할 때, 안전한 동적 위임 패턴과 남용 방지 메커니즘을 연구한다.",
    status: "planned",
    relatedInsights: ["ins-003", "ins-011"],
    tags: ["최소 권한", "동적 위임", "IAM"],
  },
  {
    id: "rq-004",
    question:
      "Human-in-the-Loop 설계에서 사용자 피로도와 보안 강도의 최적 균형점은?",
    context:
      "승인 요청이 너무 빈번하면 사용자가 습관적으로 승인하게 되어 보안 효과가 없어진다. 위험도 기반 승인 임계값 설정의 실증적 기준을 연구한다.",
    status: "planned",
    relatedInsights: ["ins-009"],
    tags: ["Human-in-the-Loop", "UX", "위험도"],
  },
  {
    id: "rq-005",
    question:
      "컨텍스트 윈도우 포화 공격에서 안전 지침 지속성을 보장하는 프롬프트 구성 전략은?",
    context:
      "긴 컨텍스트에서 시스템 프롬프트 내 안전 지침이 희석되는 현상의 메커니즘을 분석하고, 지침 반복 배치, 앵커링, 요약 기법의 효과를 비교한다.",
    status: "active",
    relatedInsights: ["ins-010"],
    tags: ["컨텍스트 관리", "프롬프트 설계", "안전성"],
  },
  {
    id: "rq-006",
    question:
      "에이전트 행동 기준선 정의를 위한 측정 지표와 이상 탐지 임계값은?",
    context:
      "에이전트의 정상 동작을 정의하는 측정 가능한 지표(툴 호출 빈도, 응답 길이 분포, 외부 요청 패턴 등)를 도출하고, 이상 탐지 규칙 설계 방법론을 연구한다.",
    status: "planned",
    relatedInsights: ["ins-008"],
    tags: ["이상 탐지", "모니터링", "기준선"],
  },
  {
    id: "rq-007",
    question:
      "전자금융업 환경에서 AI 에이전트 도입 시 준수해야 할 규제 요건과 기술적 통제의 매핑은?",
    context:
      "금융감독원 전자금융업 보안 진단 기준(66개 항목)과 AI 에이전트 보안 통제를 매핑하여, 규제 준수를 위한 에이전트 설계 가이드라인을 도출한다.",
    status: "planned",
    relatedInsights: ["ins-015"],
    tags: ["전자금융업", "규제 준수", "컴플라이언스"],
  },
] satisfies ResearchQuestion[];
