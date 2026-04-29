# 거버넌스 프레임워크

이 문서는 Madhat Labs 연구 저장소의 거버넌스 구조와 OWASP APTS 기준 매핑을 설명합니다.

---

## 거버넌스 원칙

1. **방어 우선**: 모든 콘텐츠는 방어, 교육, 문서화 목적에 한정한다.
2. **공격 기능 배제**: 공격 재현, exploit, 우회 코드는 어떤 버전에서도 포함하지 않는다.
3. **사실 기반**: 검증 가능한 근거 없이 기술적 사실을 단정하지 않는다.
4. **책임 있는 공개**: 민감한 기술 세부사항은 개념 수준에서만 설명한다.
5. **검증 가능**: 모든 주장은 참조 가능한 근거를 포함하거나 placeholder로 명시한다.

---

## APTS Governance Validation

### 개요

이 저장소는 OWASP APTS(Agentic Penetration Testing Standard) Tier 1~3 기준을
참조하여 거버넌스 구조를 설계했습니다.

> **중요**: 이는 APTS Tier 3 인증 완료가 아닙니다.
> APTS Tier 3 기준까지 검토 가능한 거버넌스 구조임을 명시합니다.

### APTS 8개 도메인 매핑

| 도메인 코드 | 도메인명 | Tier 커버리지 | 이 저장소의 관련 문서 |
|-------------|----------|---------------|----------------------|
| SE | System Escape | Tier 1-2 | threat-model.md, defensive-principles |
| SC | Secret Compromise | Tier 1-2 | threat-model.md, architecture-overview |
| HO | Hostile Operation | Tier 1-2 | threat-model.md, defensive-principles |
| AL | Agent Layer Attack | Tier 1-3 | threat-model.md, architecture-overview |
| AR | Architecture Abuse | Tier 1-3 | architecture-overview.md |
| MR | Monitoring Resistance | Tier 1-2 | threat-model.md |
| TP | Trust Poisoning | Tier 1-3 | threat-model.md, defensive-principles |
| RP | Response Pollution | Tier 1-2 | threat-model.md |

### Tier 정의

#### Tier 1 — 기초 거버넌스

- 에이전트 사용 정책 문서화
- 입력·출력 경계 정의
- 기본 로깅 및 감사 요구사항
- 8개 APTS 도메인 식별 및 기초 설명

#### Tier 2 — 운영 거버넌스

- 위험도 기반 우선순위 체계
- 운영 수준 감사 추적
- 이상 탐지 정책
- SE·SC·HO·MR·RP 도메인 심화 통제

#### Tier 3 — 심화 거버넌스 (검토 기준 참조)

- 고급 위협 모델 (AL·AR·TP 도메인)
- 아키텍처 수준 방어 원칙
- 공급망 검증 체계
- 멀티 에이전트 신뢰 모델

---

## 증거 기반 보고 모델

이 저장소의 인사이트와 원칙은 다음 증거 유형을 기반으로 합니다:

```json
{
  "evidence_types": [
    "published_research",
    "owasp_standards",
    "cve_references",
    "vendor_security_docs",
    "conceptual_analysis"
  ],
  "excluded_evidence": [
    "real_system_scan_results",
    "unauthorized_testing_data",
    "proprietary_vulnerability_details",
    "credentials_or_tokens"
  ]
}
```

---

## 참고

이 거버넌스 프레임워크는 Madhat Labs의 연구 범위와 윤리적 기준을 반영합니다.
외부 조직의 거버넌스 수준을 평가하거나 인증하는 문서가 아닙니다.
