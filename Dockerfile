# =============================================================================
# linux-vul-assessor — Multi-stage Dockerfile
#
# Stage 1 (builder): Go 컴파일 → ssm-runner 바이너리
# Stage 2 (runtime): Ubuntu 22.04 + Python 파이프라인 + ssm-runner 바이너리
#
# 내부망 배포 시:
#   - 인터넷 없는 환경: --network=host + 사설 미러(apt/pip/go proxy) 지정
#   - VPC 엔드포인트로 S3/SSM 연결
# =============================================================================

# ──────────────────────────────────────────────────────────────────────────────
# Stage 1 — Go 빌드
# ──────────────────────────────────────────────────────────────────────────────
FROM golang:1.22-bookworm AS builder

WORKDIR /build

# go.mod만 복사 → tidy가 go.sum을 자동 생성 (go.sum 수동 관리 불필요)
COPY ssm-runner/go.mod ./
RUN go mod tidy

# 소스 복사 & 정적 바이너리 빌드 (CGO_ENABLED=0 → glibc 의존 없음)
COPY ssm-runner/ .
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" \
    -o /bin/ssm-runner ./cmd/ssm-runner

# ──────────────────────────────────────────────────────────────────────────────
# Stage 2 — 런타임
# ──────────────────────────────────────────────────────────────────────────────
FROM ubuntu:22.04 AS runtime

LABEL maintainer="linux-vul-assessor"
LABEL description="KISA Linux Vulnerability Assessor — internal-network ready"

# 타임존 설정 (apt interactive 방지)
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

# ── 시스템 패키지 ──────────────────────────────────────────────────────────────
# 내부망 미러 사용 시:
#   --build-arg APT_MIRROR=http://my.mirror.internal/ubuntu
ARG APT_MIRROR=""
RUN if [ -n "$APT_MIRROR" ]; then \
        sed -i "s|http://archive.ubuntu.com|${APT_MIRROR}|g" /etc/apt/sources.list; \
    fi && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        ca-certificates \
        python3 \
        python3-pip \
        python3-venv \
        fonts-nanum \
        fonts-noto-cjk \
        wkhtmltopdf \
        xvfb \
        git \
        jq \
        unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── AWS CLI v2 설치 (내부망: --build-arg AWSCLI_URL=http://...) ──────────────
ARG AWSCLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
RUN curl -fsSL "$AWSCLI_URL" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp/awscliv2 && \
    /tmp/awscliv2/aws/install && \
    rm -rf /tmp/awscliv2 /tmp/awscliv2.zip

# ── Python 의존성 ──────────────────────────────────────────────────────────────
# 내부망 pip 미러: --build-arg PIP_INDEX=https://pypi.internal/simple
ARG PIP_INDEX=""
RUN pip3 install --no-cache-dir --quiet \
        ${PIP_INDEX:+--index-url "$PIP_INDEX"} \
        boto3 \
        jinja2 \
        weasyprint \
        pdfkit

# ── ssm-runner 바이너리 (Stage 1에서 복사) ──────────────────────────────────
COPY --from=builder /bin/ssm-runner /usr/local/bin/ssm-runner

# ── 프로젝트 복사 ──────────────────────────────────────────────────────────────
WORKDIR /opt/linux_vul

COPY tools/           ./tools/
COPY templates/       ./templates/
COPY runners/         ./runners/
COPY shell_script/    ./shell_script/
COPY change/          ./change/
COPY config/          ./config/
COPY ssm_documents/   ./ssm_documents/
COPY main.sh          ./main.sh

RUN chmod +x main.sh runners/*.sh && \
    find shell_script change -name "*.sh" -exec chmod +x {} \; && \
    chmod +x tools/*.py 2>/dev/null || true

# ── 출력 볼륨 ──────────────────────────────────────────────────────────────────
RUN mkdir -p output/{evidence,json,csv,html,pdf,logs}
VOLUME ["/opt/linux_vul/output"]

# ── 환경 변수 기본값 (docker run -e 로 오버라이드) ──────────────────────────
ENV AWS_DEFAULT_REGION=ap-northeast-2
ENV S3_UPLOAD_ENABLED=false
ENV S3_BUCKET=""
ENV S3_PREFIX=linux-vul/results
ENV AUDIT_TIMEOUT=30

# ── 헬스체크 ──────────────────────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=5s --retries=2 \
    CMD bash main.sh --help >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/bin/bash", "/opt/linux_vul/main.sh"]
CMD ["--help"]
