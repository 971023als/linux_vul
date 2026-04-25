# 주요정보통신기반시설 Linux 취약점 진단 자동화 도구 (Linux-Vul-Assessor)

주요정보통신기반시설 Linux/Unix 취약점 진단 가이드를 기반으로 `U-01 ~ U-72` 항목을 자동 점검하고, 증적 수집 및 다국어(JSON/CSV/HTML/PDF) 보고서를 생성하는 전문 진단 도구입니다.

---

## 📂 프로젝트 디렉터리 구조

```text
linux_vul/
├── main.sh                 # 통합 실행 엔트리포인트 (audit, report, setup 등)
├── Dockerfile              # 보고서 생성 및 S3 전송 환경 컨테이너 설정
├── SPEC.md                 # 상세 설계 및 기술 스펙 문서
├── README.md               # 사용자 가이드 및 프로젝트 개요
│
├── shell_scirpt/           # [Legacy] OS별 취약점 진단 쉘 스크립트 (U-01 ~ U-72)
│   ├── ubuntu/             # Ubuntu/Debian 계열
│   ├── centos/             # CentOS/RHEL 계열
│   └── ...
├── change/                 # [Legacy] 취약점 조치(Remediation) 스크립트
├── Python_json/            # [Legacy] Python 기반 결과 처리 로직
│
├── runners/                # [New] 안전한 실행을 위한 Wrapper 스크립트
├── tools/                  # [New] 자동화 도구 (S3 업로더, 보고서 파이프라인 등)
│   └── s3_uploader.py      # AWS S3 결과 자동 저장 스크립트
├── output/                 # [New] 진단 결과물 및 증적 저장소
│   ├── json/               # 정규화된 진단 결과 (JSON)
│   ├── html/               # 시각화된 보고서 (HTML)
│   ├── pdf/                # 최종 제출용 보고서 (PDF)
│   └── evidence/           # 항목별 판단 근거 (설정 파일 캡처 등)
├── config/                 # [New] 환경 설정 (S3 버킷, 프로필 정보 등)
└── templates/              # [New] 보고서 생성을 위한 HTML/CSS 템플릿
```

---

## 🏗 아키텍처 및 하네스 엔지니어링 (Harness Engineering)

본 도구는 **안정성(Safety)**과 **재현성(Reproducibility)**을 최우선으로 설계되었습니다.

### 1. 테스트 하네스 구조
- **Runner Isolation:** 기존 쉘스크립트를 직접 수정하지 않고 `runners/shell_runner.sh`가 이를 호출하여 결과를 표준화합니다.
- **Evidence First:** 모든 `PASS` 결과는 반드시 `output/evidence/`에 저장된 판단 근거(설정 파일 등)를 동반해야 합니다.
- **Dry-run Support:** `remediate` 모드는 실제 시스템 변경 전 반드시 `--dry-run`을 통해 변경될 내용을 미리 확인할 수 있습니다.

### 2. 주요 디렉터리 역할
- `shell_scirpt/`: 배포판별 진단 로직 (ReadOnly 권장)
- `change/`: 조치 스크립트 (시스템 변경 유발)
- `output/`: 모든 산출물 (JSON, CSV, HTML, PDF, Evidence)
- `tools/`: S3 업로더, 보고서 생성 파이프라인 등 보조 도구
- `config/`: S3 버킷 정보, 프로필 설정 등

---

## 🚀 시작하기

### 환경 준비
```bash
# 초기 구조 생성
bash main.sh setup
```

### 진단 실행 (Audit Mode)
```bash
# Ubuntu 프로필로 진단 수행
bash main.sh audit --profile ubuntu
```

### 보고서 생성 및 S3 업로드
```bash
# 진단 완료 후 보고서 생성 및 S3 전송
bash main.sh report --upload
```

---

## 🐳 Docker 환경 가이드

일관된 보고서 생성을 위해 Docker 환경을 권장합니다.

### 이미지 빌드
```bash
docker build -t linux-vul-assessor .
```

### 호스트 진단 실행 (Privileged Mode)
호스트의 파일을 진단하기 위해 호스트 루트를 `/host`에 마운트합니다.
```bash
docker run --rm -v /:/host:ro -v $(pwd)/output:/app/output linux-vul-assessor audit --profile ubuntu
```

---

## ☁️ AWS S3 연동

진단 결과는 중앙 집중 관리를 위해 S3로 자동 전송될 수 있습니다.

### 설정 (`config/assessment.conf`)
```ini
S3_BUCKET="your-audit-results-bucket"
AWS_REGION="ap-northeast-2"
```

### 수동 업로드
```bash
python3 tools/s3_uploader.py --path ./output --bucket my-audit-bucket --hostname server-01
```

---

## 📝 라이선스 및 주의사항
- 본 도구는 인가된 서버에서만 사용해야 합니다.
- `remediate` 모드 사용 시 반드시 사전 백업을 확인하십시오.
