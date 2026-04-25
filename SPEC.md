# 주요정보통신기반시설 Linux 취약점 진단 자동화 도구 상세 스펙문서 v0.1

---

## 0. 문서 관리 정보

| 항목 | 내용 |
|---|---|
| 문서명 | 주요정보통신기반시설 Linux 취약점 진단 자동화 도구 상세 스펙문서 |
| 버전 | v0.1 |
| 기준 프로젝트 | linux_vul-main |
| 기준 구현체 | 현행 쉘스크립트 기반 U-01 ~ U-72 진단 구조 |
| 주요 디렉터리 | shell_scirpt/, change/, Python_json/, runners/, output/, tests/ |
| 1차 목적 | 현재 쉘스크립트를 보존하면서 안전 실행, 결과 표준화, 증적화, 보고서화를 단계적으로 구현 |
| 산출물 | Markdown, JSON, CSV, HTML, PDF |
| 기본 정책 | audit-only, dry-run, evidence-first, tests-isolation |

---

# 1. 프로젝트 개요

본 프로젝트는 주요정보통신기반시설 Linux/Unix 서버 취약점 진단 항목인 `U-01 ~ U-72`를 자동 점검하고, 점검 결과를 표준화된 JSON/CSV/HTML/PDF 보고서로 생성하는 진단 자동화 도구이다.

기존 `linux_vul-main`의 쉘스크립트 기반 진단 로직을 최대한 활용하되, 이를 안전하게 실행하고 관리할 수 있는 **Python Wrapper 및 Runner 아키텍처**를 도입한다.

---

# 2. 상세 디렉터리 구조 및 역할 (Visual Tree)

```text
linux_vul/
├── main.sh                 # 통합 실행 엔트리포인트 (audit, report, setup 등)
├── setup.sh                # 초기 환경 구축 및 권한 설정 스크립트
├── Dockerfile              # 보고서 생성 및 S3 전송 환경 컨테이너 설정
├── SPEC.md                 # 상세 설계 및 기술 스펙 문서 (본 문서)
├── README.md               # 사용자 가이드 및 프로젝트 개요
│
├── shell_scirpt/           # [Legacy] OS별 취약점 진단 쉘 스크립트 (U-01 ~ U-72)
│   ├── ubuntu/             # Ubuntu/Debian 계열
│   ├── centos/             # CentOS/RHEL 계열
│   ├── Rocky/              # Rocky Linux 계열
│   ├── Fedora/             # Fedora 계열
│   └── oracle/             # Oracle Linux 계열
├── change/                 # [Legacy] 취약점 조치(Remediation) 스크립트
├── Python_json/            # [Legacy] Python 기반 결과 처리 로직
│
├── runners/                # [New] 안전한 실행을 위한 Wrapper/Harness 영역
│   └── shell_runner.sh     # U-xx.sh 실행 및 stdout/stderr/exit_code 캡처
├── tools/                  # [New] 자동화 도구 모음
│   └── s3_uploader.py      # AWS S3 결과 자동 저장 스크립트
├── output/                 # [New] 진단 결과물 및 증적 저장소 (git ignore 권장)
│   ├── json/               # 정규화된 진단 결과 (JSON)
│   ├── csv/                # Excel 검토용 결과 (CSV)
│   ├── html/               # 시각화된 보고서 (HTML)
│   ├── pdf/                # 최종 제출용 보고서 (PDF)
│   ├── evidence/           # 항목별 판단 근거 및 로그 (stdout, stderr)
│   └── logs/               # 실행 과정의 시스템 로그
├── tests/                  # [New] 테스트 하네스 및 검증 코드 전용 디렉터리
│   └── test_runner.sh      # Shell Runner 기능 검증 테스트
├── config/                 # [New] 환경 설정 (S3, OS 프로필 등)
└── templates/              # [New] 보고서 생성을 위한 HTML/CSS 템플릿
```

---

# 3. 상세 컴포넌트 설계

### 📂 `runners/` (Harness & Execution)
*   **shell_runner.sh**: 진단 스크립트의 **샌드박스 실행**을 담당합니다.
    *   모든 스크립트를 `bash`로 실행하여 인터프리터 오류 방지.
    *   실행 결과를 `output/evidence/{ID}/` 하위에 파일로 격리 저장.
    *   성공/실패 여부를 종료 코드로 메인 스크립트에 전달.

### 📂 `tests/` (Testing Policy) - **[중요: 하네스 엔지니어링 원칙]**
*   **원칙 1 (Isolation):** 모든 테스트 코드는 반드시 `tests/` 디렉터리에만 위치해야 합니다.
*   **원칙 2 (Reproducibility):** 테스트는 독립적으로 실행 가능해야 하며, `main.sh`의 환경을 시뮬레이션할 수 있어야 합니다.
*   **원칙 3 (Evidence):** 테스트 성공/실패 여부도 기록되어야 합니다.

### 📂 `output/` (Evidence & Reporting)
*   **evidence-first:** 단순히 '양호'라고 표시하는 것이 아니라, `stdout.txt`와 `stderr.txt`를 통해 실제 어떤 명령어가 실행되었고 어떤 결과가 나왔는지 증명합니다.

---

# 4. 단계별 구현 및 현황

### ✅ Phase 0: 안정화 (Completed)
- `main.sh` 통합 진입점 구축.
- `runners/shell_runner.sh` 구현을 통한 실행 격리 완료.
- `shell_scirpt/` 내의 `python3` 호출 오류를 `bash` 호출로 자동 패치 완료.
- 하네스 테스트(`tests/test_runner.sh`)를 통한 안정성 검증.

### 🔄 Phase 1: 표준화 (Planned)
- `result_normalizer.sh` 구현: `양호/취약` 등 텍스트를 `PASS/FAIL`로 변환.
- 항목별 가중치 및 위험도 설정 로직 추가.

---

# 5. 실행 모드 상세

| 모드 | 필수 옵션 | 비고 |
|---|---|---|
| setup | - | 디렉터리 생성 및 기본 설정값 초기화 |
| audit | --profile [os] | 실서버 변경 없이 진단 데이터만 수집 |
| report | --upload (선택) | 수집된 JSON 데이터를 기반으로 리포팅 및 클라우드 전송 |
| remediate | --check [ID] --apply | 명시적 승인 하에 시스템 설정 변경 |
| verify | --check [ID] | 조치 후 해당 항목만 재진단 |

---

# 6. 인프라 연동 (Docker & S3)

### Docker 가이드
- 호스트의 `/etc` 등을 진단하기 위해 호스트 루트 마운트 필수: `-v /:/host:ro`
- 보고서 생성에 필요한 한글 폰트(`fonts-nanum`) 및 `wkhtmltopdf` 기본 포함.

### S3 업로드
- `tools/s3_uploader.py`를 통해 진단 일시 및 호스트명을 기준으로 계층적 저장 수행.
