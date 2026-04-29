export type RiskLevel = "high" | "medium" | "low";
export type AptsCategory =
  | "SE"
  | "SC"
  | "HO"
  | "AL"
  | "AR"
  | "MR"
  | "TP"
  | "RP";

export interface Insight {
  id: string;
  title: string;
  summary: string;
  detail: string;
  risk: RiskLevel;
  apts: AptsCategory;
  tags: string[];
  reference?: string;
}

export const insights = [
  {
    id: "ins-001",
    title: "프롬프트 인젝션을 통한 에이전트 목표 탈취",
    summary:
      "외부 입력이 시스템 프롬프트와 동일한 채널로 처리될 때 에이전트 목표가 공격자 의도로 대체될 수 있다.",
    detail:
      "AI 에이전트가 사용자 메시지, 툴 응답, 외부 웹 콘텐츠를 구분 없이 신뢰할 경우, 악의적인 텍스트가 시스템 지시처럼 해석된다. 방어 관점에서 입력 출처별 신뢰 수준을 명확히 구분하고, 외부 콘텐츠의 지시를 실행하기 전 검증 단계를 두는 것이 핵심이다.",
    risk: "high",
    apts: "SE",
    tags: ["프롬프트 인젝션", "입력 검증", "신뢰 경계"],
    reference: "OWASP LLM01: Prompt Injection",
  },
  {
    id: "ins-002",
    title: "간접 프롬프트 인젝션 (Indirect Prompt Injection)",
    summary:
      "에이전트가 처리하는 외부 데이터(웹 페이지, 파일, DB 결과)에 숨겨진 지시가 포함될 수 있다.",
    detail:
      "직접 입력이 아닌 외부 소스에서 읽은 데이터에 공격 페이로드가 내포되는 경우다. 에이전트가 웹 검색 결과를 파싱하거나 PDF를 읽을 때, 해당 콘텐츠가 후속 툴 호출을 조작할 수 있다. 샌드박스 환경과 출력 검증이 핵심 완화 수단이다.",
    risk: "high",
    apts: "SE",
    tags: ["간접 인젝션", "RAG 보안", "외부 콘텐츠"],
    reference: "Greshake et al. (2023), Not What You've Signed Up For",
  },
  {
    id: "ins-003",
    title: "에이전트 권한 과잉 부여 (Over-Permissioned Agent)",
    summary:
      "필요 이상의 권한을 가진 에이전트는 오염된 지시에 노출될 때 피해 범위가 극대화된다.",
    detail:
      "최소 권한 원칙(PoLP)은 AI 에이전트에도 동일하게 적용된다. 에이전트에게 필요한 툴과 데이터 접근만 허용하고, 권한 범위를 명시적으로 설계해야 한다. 특히 파일 시스템, 외부 API, 코드 실행 권한은 사전 정의된 화이트리스트 방식으로 관리하는 것이 권장된다.",
    risk: "high",
    apts: "AL",
    tags: ["최소 권한", "접근 제어", "권한 설계"],
    reference: "OWASP LLM08: Excessive Agency",
  },
  {
    id: "ins-004",
    title: "멀티 에이전트 신뢰 전파 오류",
    summary:
      "Orchestrator가 Sub-agent의 응답을 무조건 신뢰할 경우, 한 에이전트의 오염이 전체 파이프라인으로 전파된다.",
    detail:
      "멀티 에이전트 아키텍처에서 신뢰는 에이전트 간에 자동으로 전파되어서는 안 된다. 각 에이전트 경계에서 응답을 독립적으로 검증하고, 오케스트레이터가 하위 에이전트 출력을 그대로 실행하지 않도록 설계해야 한다.",
    risk: "high",
    apts: "AR",
    tags: ["멀티 에이전트", "신뢰 경계", "오케스트레이터"],
  },
  {
    id: "ins-005",
    title: "민감 데이터 학습 또는 출력 유출",
    summary:
      "에이전트가 컨텍스트에 적재된 민감 정보를 응답에 포함시키거나 외부 API로 전달할 수 있다.",
    detail:
      "RAG 파이프라인이나 긴 컨텍스트 처리 시, 기밀 데이터가 컨텍스트 윈도우에 포함된 채 외부 API로 전송되거나 응답에 그대로 노출될 수 있다. 데이터 분류(Data Classification) 체계를 통해 민감 데이터의 컨텍스트 진입 자체를 통제하는 것이 핵심이다.",
    risk: "high",
    apts: "SC",
    tags: ["데이터 유출", "RAG", "컨텍스트 보안"],
    reference: "OWASP LLM02: Sensitive Information Disclosure",
  },
  {
    id: "ins-006",
    title: "툴 호출 시 명령 인젝션",
    summary:
      "에이전트가 LLM 출력을 그대로 시스템 명령이나 SQL로 실행할 경우 명령 인젝션이 발생한다.",
    detail:
      "LLM이 생성한 코드나 명령을 샌드박스 없이 직접 실행하거나, SQL 쿼리를 파라미터 바인딩 없이 구성할 경우 고전적인 인젝션 취약점이 재현된다. 에이전트의 툴 호출 레이어에서 입력 정제(sanitization)와 허용 목록(allowlist) 검증을 반드시 수행해야 한다.",
    risk: "high",
    apts: "SE",
    tags: ["명령 인젝션", "툴 보안", "코드 실행"],
  },
  {
    id: "ins-007",
    title: "LLM 공급망 위협 (모델 공급자 의존성)",
    summary:
      "사용 중인 기반 모델이나 플러그인에 백도어 또는 악의적 동작이 포함될 수 있다.",
    detail:
      "파인튜닝 데이터, 외부 플러그인, 모델 가중치 자체가 공급망 공격의 벡터가 된다. 모델 및 플러그인 출처를 검증하고, 허가된 공급자 목록을 유지하며, 모델 업데이트 시 행동 변화를 모니터링하는 체계가 필요하다.",
    risk: "medium",
    apts: "TP",
    tags: ["공급망", "모델 보안", "플러그인"],
    reference: "OWASP LLM03: Training Data Poisoning",
  },
  {
    id: "ins-008",
    title: "에이전트 로그 부재와 포렌식 불가",
    summary:
      "툴 호출, 컨텍스트 변화, 결정 경로가 기록되지 않으면 사고 분석이 불가능하다.",
    detail:
      "AI 에이전트 시스템에서 가시성(Observability) 확보는 방어의 기본이다. 각 툴 호출, 입력/출력, 에이전트 간 메시지, 컨텍스트 상태를 구조화된 로그로 기록하고 보존해야 한다. 로그 무결성 보호와 보존 기간 정책도 함께 설계해야 한다.",
    risk: "medium",
    apts: "MR",
    tags: ["로깅", "가시성", "포렌식"],
  },
  {
    id: "ins-009",
    title: "Human-in-the-Loop 없는 고위험 행동",
    summary:
      "삭제, 송금, 외부 발송 등 고위험 행동이 사람 승인 없이 자동 실행될 수 있다.",
    detail:
      "에이전트 자율성과 안전성의 균형을 위해 위험도 기반 승인 정책이 필요하다. 파일 삭제, 이메일 발송, 금융 거래 등 되돌리기 어려운 행동은 인간 승인 단계를 필수로 설계해야 한다. 자동화 편의성보다 안전성이 우선이다.",
    risk: "high",
    apts: "HO",
    tags: ["Human-in-the-Loop", "승인 정책", "자율성"],
    reference: "OWASP LLM08: Excessive Agency",
  },
  {
    id: "ins-010",
    title: "컨텍스트 윈도우 포화 공격",
    summary:
      "공격자가 대량의 노이즈 데이터를 주입하여 중요 지시가 밀려나거나 희석되게 만들 수 있다.",
    detail:
      "긴 컨텍스트 처리 시 중요한 시스템 프롬프트나 안전 지침이 컨텍스트 중간에 위치하면 모델이 이를 충분히 반영하지 못하는 현상이 보고된다. 핵심 제약 조건을 컨텍스트 앞뒤에 배치하고, 컨텍스트 길이에 따른 행동 변화를 모니터링해야 한다.",
    risk: "medium",
    apts: "SE",
    tags: ["컨텍스트 조작", "신뢰도 저하", "긴 컨텍스트"],
  },
  {
    id: "ins-011",
    title: "IAM 역할 탈취를 통한 클라우드 권한 상승",
    summary:
      "에이전트가 클라우드 IAM 역할을 동적으로 획득할 경우, 탈취된 역할이 클라우드 리소스 접근으로 이어진다.",
    detail:
      "AI 에이전트에 부여된 IAM 역할이 과도하거나 역할 체인(role chaining)이 검증 없이 허용되면, 에이전트를 통한 클라우드 권한 상승 경로가 만들어진다. 에이전트용 IAM 역할은 최소 권한으로 설계하고, Conditions 및 SCPs로 추가 제약을 걸어야 한다.",
    risk: "high",
    apts: "AL",
    tags: ["IAM", "권한 상승", "클라우드 보안"],
  },
  {
    id: "ins-012",
    title: "에이전트 메모리 오염 (Memory Poisoning)",
    summary:
      "장기 메모리(벡터 DB 등)에 적재된 오염된 정보가 후속 에이전트 결정을 지속적으로 왜곡한다.",
    detail:
      "에이전트가 외부 메모리(RAG, 벡터 스토어)를 활용할 때, 공격자가 해당 메모리에 악의적 내용을 삽입하면 이후 모든 쿼리에 영향을 준다. 메모리 기록 시 출처 검증, 접근 제어, 정기적 무결성 검토가 필요하다.",
    risk: "high",
    apts: "SC",
    tags: ["메모리 오염", "RAG", "벡터 DB"],
  },
  {
    id: "ins-013",
    title: "응답 형식 조작을 통한 파서 익스플로잇",
    summary:
      "LLM 출력이 다운스트림 파서(JSON, XML, HTML)에 직접 전달될 때 출력 형식 조작으로 파서를 공격할 수 있다.",
    detail:
      "에이전트 출력이 프론트엔드 렌더러나 API 게이트웨이에 구조화 없이 전달되면, LLM이 악의적으로 생성한 JSON이나 HTML이 XSS나 파서 오류를 유발할 수 있다. LLM 출력을 항상 구조화된 스키마로 파싱하고 검증 후 사용해야 한다.",
    risk: "medium",
    apts: "RP",
    tags: ["출력 검증", "파서 보안", "XSS"],
    reference: "OWASP LLM05: Improper Output Handling",
  },
  {
    id: "ins-014",
    title: "DoS를 통한 에이전트 가용성 저하",
    summary:
      "공격자가 컴퓨팅 집약적 요청을 반복하거나 무한 루프를 유발하여 에이전트 가용성을 소진할 수 있다.",
    detail:
      "LLM 추론 비용은 일반 API보다 높기 때문에, 에이전트 엔드포인트에 대한 과도한 요청이나 재귀적 툴 호출 체인이 빠르게 가용성 문제로 이어진다. Rate limiting, 토큰 예산 제한, 툴 호출 깊이 제한이 핵심 완화 수단이다.",
    risk: "medium",
    apts: "HO",
    tags: ["DoS", "가용성", "Rate Limiting"],
  },
  {
    id: "ins-015",
    title: "규정 준수 로그 미흡과 감사 추적 불가",
    summary:
      "금융·의료 등 규제 산업에서 AI 에이전트 결정 경로가 감사 가능한 형태로 보존되지 않으면 규정 위반이 된다.",
    detail:
      "GDPR, HIPAA, 전자금융거래법 등 규제에서 AI 시스템의 결정 로그 보존 의무가 강화되고 있다. 에이전트 결정의 근거(컨텍스트, 입력, 사용된 도구, 출력)를 변조 불가능한 형태로 보존하는 감사 로그 체계가 필요하다.",
    risk: "medium",
    apts: "RP",
    tags: ["컴플라이언스", "감사 로그", "규제"],
  },
] satisfies Insight[];
