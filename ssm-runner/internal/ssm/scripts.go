// internal/ssm/scripts.go
// SSM RunCommand에 전달할 bash 스크립트 생성

package ssm

import "fmt"

// buildSingleScript 단일 체크용 inline 스크립트
func buildSingleScript(req RunSingleRequest) string {
	uploadEnabled := "false"
	if req.S3Bucket != "" {
		uploadEnabled = "true"
	}

	return fmt.Sprintf(`#!/bin/bash
set -uo pipefail

REPO="%s"
CHECK_ID="%s"
PROFILE="%s"
S3_BUCKET="%s"
S3_PREFIX="%s"
AUDIT_TIMEOUT="%d"
S3_UPLOAD_ENABLED="%s"
AWS_REGION="${AWS_DEFAULT_REGION:-ap-northeast-2}"

RUNNER="${REPO}/runners/shell_runner.sh"
SCRIPT_PATH="${REPO}/shell_script/${PROFILE}/${CHECK_ID}.sh"
OUTPUT_DIR="${REPO}/output/evidence"

# 실행 전 검증
if [ ! -f "$RUNNER" ]; then
    echo "[SSM] ERROR: runner not found: $RUNNER" >&2; exit 1
fi
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "[SSM] ERROR: check script not found: $SCRIPT_PATH" >&2; exit 2
fi

# S3 설정 환경변수로 주입 (shell_runner.sh가 참조)
export S3_BUCKET S3_PREFIX AWS_REGION S3_UPLOAD_ENABLED AUDIT_TIMEOUT

echo "=== [SSM] %s 시작: $(date) ==="
echo "    Instance : $(curl -sf --max-time 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || hostname -s)"
echo "    Profile  : ${PROFILE}"

bash "$RUNNER" \
    --check   "$CHECK_ID" \
    --script  "$SCRIPT_PATH" \
    --output  "$OUTPUT_DIR" \
    --profile "$PROFILE"

EXIT=$?
echo "=== [SSM] %s 완료: exit=${EXIT} ==="
exit $EXIT
`,
		req.RepoPath,
		req.CheckID,
		req.Profile,
		req.S3Bucket,
		req.S3Prefix,
		req.Timeout,
		uploadEnabled,
		req.CheckID,
		req.CheckID,
	)
}

// buildFullScript 전체 감사용 inline 스크립트
func buildFullScript(req RunFullRequest) string {
	uploadEnabled := "false"
	if req.S3Bucket != "" {
		uploadEnabled = "true"
	}
	forceFlag := ""
	if req.Force {
		forceFlag = "--force"
	}
	pipelineFlag := "false"
	if req.RunPipeline {
		pipelineFlag = "true"
	}

	return fmt.Sprintf(`#!/bin/bash
set -uo pipefail

REPO="%s"
PROFILE="%s"
S3_BUCKET="%s"
S3_PREFIX="%s"
AUDIT_TIMEOUT="%d"
S3_UPLOAD_ENABLED="%s"
RUN_PIPELINE="%s"
FORCE_FLAG="%s"
AWS_REGION="${AWS_DEFAULT_REGION:-ap-northeast-2}"

MAIN="${REPO}/main.sh"

if [ ! -f "$MAIN" ]; then
    echo "[SSM] ERROR: main.sh not found: $MAIN" >&2; exit 1
fi

export S3_BUCKET S3_PREFIX AWS_REGION S3_UPLOAD_ENABLED AUDIT_TIMEOUT

INAME=$(curl -sf --max-time 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || hostname -s)

echo "=== [SSM] linux-vul 전체 감사 시작: $(date) ==="
echo "    Instance : ${INAME}"
echo "    Profile  : ${PROFILE}"
echo "    S3 prefix: s3://${S3_BUCKET}/${S3_PREFIX}/${PROFILE}/"
echo "    Pipeline : ${RUN_PIPELINE}"

# Phase 0: audit
bash "$MAIN" audit --profile "$PROFILE" $FORCE_FLAG
AUDIT_RC=$?
echo "[SSM] audit 완료: exit=${AUDIT_RC}"

if [ $AUDIT_RC -ne 0 ]; then
    echo "[SSM] audit 실패 — 파이프라인 중단" >&2; exit $AUDIT_RC
fi

# Phase 1+: normalize → csv → report
if [ "$RUN_PIPELINE" = "true" ]; then
    echo "[SSM] normalize 실행..."
    bash "$MAIN" normalize || { echo "[SSM] normalize 실패" >&2; exit 2; }

    echo "[SSM] csv 변환..."
    bash "$MAIN" csv      || { echo "[SSM] csv 실패" >&2; exit 3; }

    echo "[SSM] report 생성..."
    bash "$MAIN" report   || { echo "[SSM] report 실패" >&2; exit 4; }

    # HTML 보고서 S3 업로드
    HTML_FILE=$(ls -t "${REPO}/output/html"/report_*.html 2>/dev/null | head -1)
    if [ -n "$HTML_FILE" ] && [ -n "$S3_BUCKET" ] && command -v aws &>/dev/null; then
        TS=$(date +%%Y%%m%%d_%%H%%M%%S)
        HTML_KEY="${S3_PREFIX}/${PROFILE}/reports/report_${INAME}_${TS}.html"
        aws s3 cp "$HTML_FILE" "s3://${S3_BUCKET}/${HTML_KEY}" \
            --region "$AWS_REGION" --content-type "text/html" >/dev/null 2>&1 \
          && echo "[SSM] 보고서 업로드: s3://${S3_BUCKET}/${HTML_KEY}" \
          || echo "[SSM] 보고서 업로드 실패" >&2
    fi
fi

echo "=== [SSM] 전체 감사 완료: $(date) ==="
`,
		req.RepoPath,
		req.Profile,
		req.S3Bucket,
		req.S3Prefix,
		req.Timeout,
		uploadEnabled,
		pipelineFlag,
		forceFlag,
	)
}
