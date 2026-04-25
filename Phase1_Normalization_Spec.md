# Phase 1: 결과 상태값 표준화(Normalization) 상세 스펙문서

본 문서는 `linux_vul` 프로젝트의 Phase 1 단계인 **진단 결과 정규화**를 위한 하네스 엔지니어링 표준을 정의합니다.

---

## 1. 표준 상태값 정의

| 상태 (Status) | 의미 (Description) |
|---|---|
| **PASS** | 보안 가이드라인의 기준을 완벽히 충족함 |
| **FAIL** | 보안 기준에 미달하여 조치가 필요함 |
| **NA** | 해당 서버의 환경상 점검 대상이 아님 |
| **MANUAL_REVIEW** | 자동 판단 불가, 전문가 검토 필요 |
| **EVIDENCE_MISSING** | 증적 파일 누락 또는 파일 크기가 0임 |
| **ERROR** | 실행 중 런타임 오류 발생 |
| **NOT_IMPLEMENTED** | 진단 로직 미구현 |

---

## 2. 증적 파일 유효성 검사 절차 (Integrity Validation)

정규화 수행 전, `shell_runner.sh` 및 `normalizer`는 다음 절차를 거쳐 데이터 무결성을 확인합니다.

1.  **Existence Check:** `output/evidence/{ID}/stdout.txt` 파일이 실제로 존재하는지 확인합니다.
2.  **Size Check:** 파일 크기가 **0 byte 초과**인지 확인합니다. (0 byte인 경우 `EVIDENCE_MISSING` 처리)
3.  **Pattern Check (Sanity):** 결과값이 비정상적으로 짧거나 깨진 문자가 포함된 경우 `MANUAL_REVIEW`로 유도합니다.
4.  **Exit Code Check:** 스크립트의 종료 코드가 0이 아닌 경우, `stdout` 내용과 관계없이 `ERROR` 또는 `MANUAL_REVIEW`로 우선 처리합니다.

---

## 3. 상태 매핑 테이블 (Dictionary)

| 원본 출력 키워드 | 표준 상태 |
|---|---|
| 양호, 안전, PASS, Pass, OK, Good | **PASS** |
| 취약, 위험, FAIL, Fail, Vulnerable | **FAIL** |
| 해당없음, N/A, Not Applicable | **NA** |
| 수동점검, 확인필요, Manual Review | **MANUAL_REVIEW** |

---

## 4. 정규화 파이프라인 (Harness Workflow)

```text
[Runner] -> [Integrity Check] -> [Status Mapping] -> [JSON Export]
```

1.  **Runner**가 실행 결과를 파일로 저장.
2.  **Integrity Check**가 파일의 유효성 검증 (파일 없음/0 byte 등 필터링).
3.  **Status Mapping**이 텍스트 키워드를 표준 코드로 변환.
4.  **JSON Export**가 `normalized_result.json`으로 최종 저장.
