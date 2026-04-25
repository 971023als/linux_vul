# Phase 0: 하네스 엔지니어링 및 진단 안정화 전략 문서

본 문서는 `linux_vul` 프로젝트의 Phase 0 작업을 수행함에 있어, 기존 로직의 무결성을 보장하고 안정적인 진단 환경을 구축하기 위한 **하네스 엔지니어링(Harness Engineering)** 전략을 상세히 기술합니다.

---

## 1. 개요 (Overview)

현재 프로젝트의 가장 큰 문제는 **실행 환경의 불일치**입니다. `.sh` 파일을 `python3` 인터프리터로 호출하는 등의 오류는 진단 결과의 신뢰도를 떨어뜨리고 런타임 에러를 유발합니다. 이를 해결하기 위해 단순 수정을 넘어, 실행을 추상화하고 결과를 정형화하는 **Runner 기반 아키텍처**를 도입합니다.

---

## 2. Shell Runner 설계 (Harness Logic)

`runners/shell_runner.sh`는 모든 진단 스크립트 실행의 **게이트웨이** 역할을 합니다.

### 2.1 주요 기능 (Responsibilities)
1.  **실행 환경 강제 (Execution Enforcement):** 파일 확장자와 관계없이 내부적으로 `bash` 환경에서 실행되도록 보장합니다.
2.  **데이터 캡처 (Result Capturing):**
    *   `stdout`: 표준 출력 (진단 결과 문자열)
    *   `stderr`: 에러 출력 (디버깅용)
    *   `exit_code`: 종료 코드 (실행 성공 여부 판단)
3.  **타임아웃 제어 (Timeout Control):** 무한 루프에 빠진 스크립트가 전체 진단을 멈추지 않도록 제어합니다.
4.  **증적 자동화 (Auto-Evidencing):** 실행 결과를 즉시 `output/evidence/` 하위의 항목별 디렉터리로 격리 저장합니다.

### 2.2 Runner 실행 워크플로우
```text
[Main Script] -> [Shell Runner] -> [Target U-xx.sh]
                     │
                     ├─> stdout -> output/evidence/U-xx/stdout.txt
                     ├─> stderr -> output/evidence/U-xx/stderr.txt
                     └─> exit_code -> output/evidence/U-xx/exit_code.txt
```

---

## 3. `vul.sh` 수정 및 안정화 전략

기존 배포판별 `vul.sh` 파일에 존재하는 `python3 "$SCRIPT_PATH"` 형태의 잘못된 호출을 수정합니다.

### 3.1 하네스 기반 수정 원칙
1.  **직접 호출 금지:** `vul.sh`가 `U-xx.sh`를 직접 호출하는 대신, `shell_runner.sh`를 통해 호출하도록 구조를 변경합니다.
2.  **멱등성 보장 (Idempotency):** 여러 번 수정 시도를 해도 동일한 정상 상태를 유지하도록 `sed` 등을 활용한 자동화 패치를 적용합니다.
3.  **회귀 테스트 (Regression Test):** 수정 후 `bash -n` 명령을 통해 문법 오류가 없는지 검증합니다.

### 3.2 패치 로직 (Example)
*   **AS-IS:** `RESULT=$(python3 "$SCRIPT_PATH")`
*   **TO-BE:** `RESULT=$(bash ../../runners/shell_runner.sh --script "$SCRIPT_PATH")`

---

## 4. 검증 및 하네스 테스트 (Verification)

작업 완료 후 다음 항목을 통해 하네스가 정상 작동하는지 확인합니다.

| 테스트 항목 | 검증 방법 | 기대 결과 |
|---|---|---|
| 인터프리터 검증 | `vul.sh` 내 `python3` 문자열 검색 | `U-xx.sh` 호출부에서 제거됨 |
| 실행 격리 테스트 | `output/evidence/U-01/` 디렉터리 확인 | `stdout.txt` 등이 생성됨 |
| 오류 캡처 테스트 | 의도적 에러 유발 스크립트 실행 | `stderr.txt`에 에러 내용 기록됨 |
| 문법 무결성 | `bash -n` 실행 | 아무런 문법 오류가 출력되지 않음 |

---

## 5. 향후 확장성

이 하네스 구조가 안착되면, 이후 Phase에서 **결과 정규화(Normalization)** 및 **JSON 통합 보고서 생성** 로직을 Runner 끝단에 간단히 추가할 수 있습니다.
