# Changelog

이 파일은 프로젝트의 주요 변경 사항을 기록합니다.  
형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따릅니다.

---

## [0.1.0] - 2025-07-01

### 추가됨

- **전체 저장소 초기 공개**
  - Next.js 14 App Router + TypeScript + Tailwind CSS 기반 정적 문서 사이트 구조
  - 다크모드 지원 및 접근성 고려 레이아웃
  - Docker multi-stage 빌드 설정 (Dockerfile, docker-compose.yml)

- **문서 콘텐츠**
  - 홈 페이지: Madhat Labs 개요, 기술적 난관 요약, 방어 교훈 카드
  - About 페이지: 연구 목적, 범위, 대상 독자
  - Architecture 페이지: 웹·클라우드·IAM 계층 개념 설명
  - Insights 페이지: 15개 이상의 AI 에이전트 보안 인사이트
  - Defensive Principles 페이지: 11개 방어 원칙 상세 설명
  - FAQ 페이지: 15개 이상 질문/답변
  - Governance 페이지: 윤리·법적 고지, 허용/비허용 사용 기준
  - References 페이지: 영상 기반 참조 자료 목록
  - Changelog 페이지: 변경 이력 UI

- **데이터 파일**
  - `data/navigation.ts`: 메뉴 구조
  - `data/insights.ts`: 인사이트 데이터 (15개)
  - `data/faq.ts`: FAQ 데이터 (15개)
  - `data/research-questions.ts`: 연구 질문 목록
  - `data/defensive-principles.ts`: 방어 원칙 목록

- **컴포넌트**
  - Header, Footer, PageContainer, Hero, SectionCard, InsightCard, FaqList, RiskCallout, Timeline, Badge

- **GitHub 운영 파일**
  - CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
  - PULL_REQUEST_TEMPLATE.md
  - ISSUE_TEMPLATE 3종 (문서 요청, 아키텍처 질문, 방어 논의)

- **APTS Governance Validation 섹션**
  - OWASP APTS 8개 도메인 매핑 (SE, SC, HO, AL, AR, MR, TP, RP)
  - Tier 1~3 거버넌스 커버리지 설명
  - 증거 기반 보고 모델 정의
  - Tier 3 인증이 아닌 "Tier 3 기준까지 검토 가능한 거버넌스 구조"로 명확히 한정

- **테스트**
  - Vitest 기반 3개 테스트 파일 (navigation, faq, insights)

### 포함하지 않은 것

- 공격 실행 코드, exploit, RCE 재현 코드
- 실제 네트워크 스캐너 또는 자동 공격 로직
- 운영 환경 자격증명, API 키, 토큰
- 실존 취약 시스템에 대한 실제 점검 결과
- Madhat Labs Azure 환경의 실제 구성 정보

### 알려진 한계

- `lib/mdx.ts`는 실제 MDX 파싱 없이 placeholder 로더로 구현
- PDF 출력 기능 미포함
- 검색 기능 미포함 (정적 사이트 범위 내 구현 예정)

---

## 향후 계획

- `[0.2.0]` 검색 기능 추가 (Pagefind 또는 유사 정적 검색)
- `[0.2.0]` 문서 목록 자동 생성 (docs/ 디렉터리 기반)
- `[0.3.0]` 전자금융업 보안진단 기준표 연동 (웹·모바일·HTS 66개 항목)
- `[0.3.0]` 위험도 기반 대시보드 뷰 추가
- `[0.4.0]` Markdown/HTML 보고서 자동 생성 기능
- `[1.0.0]` 정적 배포 (GitHub Pages 또는 Vercel)

---

## 안전한 연구 저장소 운영 원칙

이 저장소의 모든 변경 사항은 다음 원칙을 따릅니다:

1. **방어 우선**: 모든 콘텐츠는 방어, 교육, 문서화 목적에 한정한다.
2. **공격 기능 배제**: 공격 재현, exploit, 우회 코드는 어떤 버전에서도 포함하지 않는다.
3. **사실 기반**: 제공된 기반 정보 외 추측이나 fabricated detail을 넣지 않는다.
4. **검증 가능**: 모든 주장은 참조 가능한 근거를 포함하거나 placeholder로 명시한다.
5. **책임 있는 공개**: 민감한 기술 세부사항은 개념 수준에서만 설명한다.
