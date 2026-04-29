export interface FaqItem {
  id: string;
  question: string;
  answer: string;
  tags?: string[];
  /** Optional URL citation shown below the answer. */
  reference?: string;
}

export const faqItems = [
  {
    id: "faq-001",
    question: "이 저장소의 목적은 무엇인가요?",
    answer:
      "AI 에이전트 시스템의 보안 취약점을 방어 관점에서 연구하고 문서화하는 것이 목적입니다. 공격 코드나 익스플로잇은 포함하지 않으며, 방어팀과 개발자가 더 안전한 시스템을 설계할 수 있도록 인사이트와 원칙을 제공합니다.",
    tags: ["목적", "방어", "개요"],
  },
  {
    id: "faq-002",
    question: "Madhat Labs는 어떤 조직인가요?",
    answer:
      "Madhat Labs는 AI 에이전트 보안과 클라우드 환경의 방어형 보안 연구를 수행하는 독립 연구 단위입니다. 연구 결과는 방어·교육 목적으로만 공개됩니다.",
    tags: ["조직", "소개"],
  },
  {
    id: "faq-003",
    question: "프롬프트 인젝션이 왜 위험한가요?",
    answer:
      "AI 에이전트는 사용자 지시와 시스템 프롬프트를 동일한 채널로 처리하는 경우가 많습니다. 공격자가 이 채널에 악의적인 지시를 주입하면 에이전트가 의도하지 않은 행동을 실행할 수 있습니다. 특히 에이전트가 파일 시스템 접근, 외부 API 호출, 코드 실행 권한을 가진 경우 피해 범위가 커집니다.",
    tags: ["프롬프트 인젝션", "위험성"],
  },
  {
    id: "faq-004",
    question: "간접 프롬프트 인젝션(Indirect Prompt Injection)이란?",
    answer:
      "에이전트가 처리하는 외부 데이터(웹 페이지, 파일, 데이터베이스 결과 등)에 공격 지시가 숨겨진 경우입니다. 사용자가 직접 공격 내용을 입력하지 않더라도, 에이전트가 읽는 외부 콘텐츠를 통해 공격이 이루어집니다.",
    tags: ["간접 인젝션", "RAG"],
  },
  {
    id: "faq-005",
    question: "AI 에이전트에 최소 권한 원칙을 어떻게 적용하나요?",
    answer:
      "에이전트가 수행하는 작업에 필요한 툴과 데이터 접근만 허용합니다. IAM 역할은 읽기 전용으로 시작하고 필요한 경우에만 쓰기 권한을 추가합니다. 툴 목록은 화이트리스트 방식으로 명시적으로 정의하고, 미사용 권한은 정기적으로 제거합니다.",
    tags: ["최소 권한", "IAM", "접근 제어"],
  },
  {
    id: "faq-006",
    question: "멀티 에이전트 시스템에서 신뢰를 어떻게 관리해야 하나요?",
    answer:
      "에이전트 간 통신에서 신뢰는 자동으로 전파되어서는 안 됩니다. 각 에이전트는 수신한 메시지를 검증하고, 오케스트레이터는 하위 에이전트 출력을 직접 실행하지 않고 구조화된 형태로 파싱한 후 처리해야 합니다. 에이전트 간 통신 채널에 인증을 적용하는 것도 권장됩니다.",
    tags: ["멀티 에이전트", "신뢰 경계"],
  },
  {
    id: "faq-007",
    question: "AI 에이전트 로그는 어떻게 남겨야 하나요?",
    answer:
      "툴 호출 입출력, 컨텍스트 상태 변화, 에이전트 간 메시지, 결정 근거를 구조화된 JSON 형태로 기록합니다. 로그는 변조를 방지하기 위해 쓰기 전용 스토리지에 보관하고, 보존 기간과 접근 제어 정책을 명확히 정의해야 합니다.",
    tags: ["로깅", "가시성", "포렌식"],
  },
  {
    id: "faq-008",
    question: "Human-in-the-Loop는 모든 에이전트 행동에 필요한가요?",
    answer:
      "모든 행동에 필요하지는 않지만, 되돌리기 어렵거나 위험도가 높은 행동(파일 삭제, 외부 이메일 발송, 금융 거래 등)에는 반드시 사람 승인 단계를 두어야 합니다. 위험도 기준에 따라 자동화 범위를 명확히 정의하는 것이 실용적입니다.",
    tags: ["Human-in-the-Loop", "위험도"],
  },
  {
    id: "faq-009",
    question: "LLM 공급망 위험은 무엇을 의미하나요?",
    answer:
      "사용 중인 기반 모델, 파인튜닝 데이터, 플러그인, 라이브러리 중 하나라도 오염되거나 악의적인 경우 서비스 전체가 영향을 받습니다. 모델 공급자와 플러그인 출처를 검증하고, 모델 업데이트 시 행동 변화를 모니터링하는 체계가 필요합니다.",
    tags: ["공급망", "모델 보안"],
  },
  {
    id: "faq-010",
    question: "이 저장소의 내용을 공격에 활용할 수 있나요?",
    answer:
      "아니오. 이 저장소는 방어·교육 목적으로만 작성되었으며, 공격 코드나 재현 절차를 포함하지 않습니다. 내용을 비인가 시스템 공격에 활용하는 것은 CODE_OF_CONDUCT 및 라이선스 조건에 위반되며, 관련 법령에 따른 법적 책임이 발생할 수 있습니다.",
    tags: ["이용 정책", "윤리"],
  },
  {
    id: "faq-011",
    question: "OWASP LLM Top 10이란 무엇인가요?",
    answer:
      "OWASP(Open Worldwide Application Security Project)가 정의한 LLM 애플리케이션의 주요 10가지 보안 위험 목록입니다. 프롬프트 인젝션, 민감 정보 노출, 공급망 위협, 과도한 에이전트 권한 등이 포함됩니다. 이 저장소의 인사이트는 OWASP LLM Top 10을 참조합니다.",
    tags: ["OWASP", "LLM", "표준"],
    reference: "https://owasp.org/www-project-top-10-for-large-language-model-applications/",
  },
  {
    id: "faq-012",
    question: "APTS 프레임워크는 무엇인가요?",
    answer:
      "OWASP AI/LLM 환경을 위한 에이전트 침투 테스트 표준(Agentic Penetration Testing Standard)의 약칭입니다. SE(시스템 탈출), SC(비밀 탈취), HO(운영 방해), AL(에이전트 레이어 공격), AR(아키텍처 악용), MR(모니터링 회피), TP(신뢰 오염), RP(응답 조작)의 8개 도메인으로 구성됩니다. 이 저장소의 거버넌스 검토는 APTS Tier 1~3 기준을 참조합니다.",
    tags: ["APTS", "OWASP", "거버넌스"],
  },
  {
    id: "faq-013",
    question: "이 사이트를 로컬에서 실행하려면 어떻게 하나요?",
    answer:
      "Node.js 20 이상이 설치된 환경에서 `npm install` 후 `npm run dev`를 실행하면 localhost:3000에서 확인할 수 있습니다. Docker를 사용하는 경우 `docker compose up`으로 실행할 수 있습니다.",
    tags: ["설치", "로컬 실행"],
  },
  {
    id: "faq-014",
    question: "기여하고 싶다면 어떻게 해야 하나요?",
    answer:
      "CONTRIBUTING.md를 먼저 읽고, 허용되는 기여 유형을 확인해 주세요. Fork 후 기능/수정 브랜치를 만들고 Pull Request를 제출합니다. 방어 관점 콘텐츠, 문서 개선, FAQ 확장, 테스트 추가 등을 환영합니다. 공격 코드나 비인가 시스템 정보는 수용하지 않습니다.",
    tags: ["기여", "PR"],
  },
  {
    id: "faq-015",
    question: "취약점을 발견하면 어디에 신고하나요?",
    answer:
      "공개 Issue로 취약점 상세 내용을 등록하지 마세요. GitHub Security Advisory의 'Report a vulnerability' 기능을 이용하거나 저장소 관리자에게 직접 비공개 연락을 주세요. SECURITY.md에 상세 절차가 안내되어 있습니다.",
    tags: ["보안 신고", "responsible disclosure"],
  },
] satisfies FaqItem[];
