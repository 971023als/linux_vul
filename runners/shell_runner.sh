#!/bin/bash
# runners/shell_runner.sh
# Purpose: 개별 U-xx.sh 격리 실행, 증적 저장, S3 MD 업로드
#
# Usage: shell_runner.sh --check U-01 --script PATH [--output DIR] [--profile ubuntu]
# 디버깅: DEBUG=1 shell_runner.sh ...  (main.sh에서 자동 상속됨)

set -uo pipefail

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${RUNNER_DIR}/.." && pwd)"
CONFIG_FILE="${PROJECT_DIR}/config/assessment.conf"

DEBUG="${DEBUG:-0}"

CHECK_ID=""
SCRIPT_PATH=""
OUTPUT_DIR="${PROJECT_DIR}/output/evidence"
PROFILE="unknown"
EXIT_CODE=0

# =============================================================================
# 디버그 로거
# =============================================================================
function dbg() {
    [ "$DEBUG" = "0" ] && return
    local ts; ts=$(date '+%H:%M:%S.%3N' 2>/dev/null || date '+%H:%M:%S')
    echo "[DBG ${ts}][runner] $*" >&2
}

dbg "shell_runner.sh 시작 — PID=$$ PPID=$PPID"
dbg "RUNNER_DIR=${RUNNER_DIR} PROJECT_DIR=${PROJECT_DIR}"

# =============================================================================
# config 로드
# =============================================================================
if [ -f "$CONFIG_FILE" ]; then
    dbg "config 로드: ${CONFIG_FILE}"
    source "$CONFIG_FILE"
    dbg "config 완료 — S3_BUCKET=${S3_BUCKET:-<unset>} S3_UPLOAD_ENABLED=${S3_UPLOAD_ENABLED:-false}"
else
    dbg "config 없음: ${CONFIG_FILE} → 기본값 사용"
fi

S3_BUCKET="${S3_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-linux-vul/results}"
AWS_REGION="${AWS_REGION:-ap-northeast-2}"
S3_UPLOAD_ENABLED="${S3_UPLOAD_ENABLED:-false}"
AUTO_DETECT_INSTANCE_ID="${AUTO_DETECT_INSTANCE_ID:-true}"
INSTANCE_ID_FALLBACK="${INSTANCE_ID_FALLBACK:-$(hostname -s 2>/dev/null || echo 'local')}"
AUDIT_TIMEOUT="${AUDIT_TIMEOUT:-30}"

dbg "설정 → S3_UPLOAD=${S3_UPLOAD_ENABLED} REGION=${AWS_REGION} TIMEOUT=${AUDIT_TIMEOUT}s"

# =============================================================================
# 인스턴스 ID 감지
# =============================================================================
get_instance_id() {
    dbg "get_instance_id: AUTO_DETECT=${AUTO_DETECT_INSTANCE_ID}"
    if [ "$AUTO_DETECT_INSTANCE_ID" = "true" ]; then
        dbg "get_instance_id: EC2 메타데이터 조회 (max-time=2s)"
        local iid
        iid=$(curl -sf --max-time 2 \
            http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "")
        if [ -n "$iid" ]; then
            dbg "get_instance_id: EC2 instance-id=${iid}"
            echo "$iid"; return
        fi
        dbg "get_instance_id: EC2 응답 없음 → fallback"
    fi
    dbg "get_instance_id: fallback → ${INSTANCE_ID_FALLBACK}"
    echo "${INSTANCE_ID_FALLBACK}"
}

# =============================================================================
# Help
# =============================================================================
function usage() {
    echo "Usage: $0 --check ID --script PATH [--output DIR] [--profile OS]"
    exit 1
}

# =============================================================================
# 인자 파싱
# =============================================================================
dbg "인자 파싱: $*"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --check)   CHECK_ID="$2";    shift ;;
        --script)  SCRIPT_PATH="$2"; shift ;;
        --output)  OUTPUT_DIR="$2";  shift ;;
        --profile) PROFILE="$2";     shift ;;
        *)         echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done
dbg "파싱 완료 — CHECK_ID=${CHECK_ID} PROFILE=${PROFILE} SCRIPT_PATH=${SCRIPT_PATH}"

if [ -z "$CHECK_ID" ] || [ -z "$SCRIPT_PATH" ]; then
    usage
fi

# =============================================================================
# 증적 디렉터리 준비
# =============================================================================
ITEM_EVIDENCE_DIR="${OUTPUT_DIR}/${CHECK_ID}"
dbg "증적 디렉터리: ${ITEM_EVIDENCE_DIR}"
mkdir -p "$ITEM_EVIDENCE_DIR"

STDOUT_FILE="${ITEM_EVIDENCE_DIR}/stdout.txt"
STDERR_FILE="${ITEM_EVIDENCE_DIR}/stderr.txt"
EXIT_CODE_FILE="${ITEM_EVIDENCE_DIR}/exit_code.txt"

# =============================================================================
# 스크립트 실행
# =============================================================================
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "ERROR: Script not found: $SCRIPT_PATH" > "$STDERR_FILE"
    echo "1" > "$EXIT_CODE_FILE"
    dbg "ERROR: 스크립트 없음: ${SCRIPT_PATH}"
    exit 1
fi

SCRIPT_SIZE=$(wc -c < "$SCRIPT_PATH" 2>/dev/null || echo "?")
dbg "스크립트 실행: 크기=${SCRIPT_SIZE}bytes TIMEOUT=${AUDIT_TIMEOUT}s"

EXEC_START=$(date +%s%N 2>/dev/null || date +%s)

if command -v timeout &>/dev/null; then
    dbg "timeout 명령 사용"
    timeout "${AUDIT_TIMEOUT}" bash "$SCRIPT_PATH" > "$STDOUT_FILE" 2> "$STDERR_FILE"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
        echo "[HARNESS] TIMEOUT: ${CHECK_ID} exceeded ${AUDIT_TIMEOUT}s" >> "$STDERR_FILE"
        dbg "TIMEOUT: ${CHECK_ID} > ${AUDIT_TIMEOUT}s"
    fi
else
    dbg "timeout 없음 — 무제한 실행"
    bash "$SCRIPT_PATH" > "$STDOUT_FILE" 2> "$STDERR_FILE"
    EXIT_CODE=$?
fi

EXEC_END=$(date +%s%N 2>/dev/null || date +%s)
if [[ "$EXEC_START" =~ ^[0-9]{18,}$ ]]; then
    EXEC_MS=$(( (EXEC_END - EXEC_START) / 1000000 ))
    dbg "실행 완료 — exit=${EXIT_CODE} elapsed=${EXEC_MS}ms"
else
    dbg "실행 완료 — exit=${EXIT_CODE} elapsed=$(( EXEC_END - EXEC_START ))s"
fi

echo "$EXIT_CODE" > "$EXIT_CODE_FILE"

# =============================================================================
# Integrity Check
# =============================================================================
STDOUT_SIZE=$(wc -c < "$STDOUT_FILE" 2>/dev/null || echo "0")
STDOUT_LINES=$(wc -l < "$STDOUT_FILE" 2>/dev/null || echo "0")
dbg "Integrity Check: stdout=${STDOUT_SIZE}bytes / ${STDOUT_LINES}줄"

if [ ! -s "$STDOUT_FILE" ]; then
    echo "[HARNESS] WARNING: Empty stdout (EVIDENCE_MISSING) for ${CHECK_ID}" >> "$STDERR_FILE"
    dbg "Integrity: EVIDENCE_MISSING — stdout 비어있음"
else
    dbg "Integrity: OK"
fi

if [ -s "$STDERR_FILE" ]; then
    STDERR_SIZE=$(wc -c < "$STDERR_FILE")
    dbg "stderr 존재: ${STDERR_SIZE}bytes"
    if [ "$DEBUG" != "0" ]; then
        head -5 "$STDERR_FILE" | while IFS= read -r line; do
            dbg "  stderr| ${line}"
        done
    fi
fi

# =============================================================================
# S3 MD 업로드
# =============================================================================
dbg "S3 조건: ENABLED=${S3_UPLOAD_ENABLED} BUCKET=${S3_BUCKET:-<unset>} stdout_nonempty=$([ -s "$STDOUT_FILE" ] && echo Y || echo N)"

if [ "$S3_UPLOAD_ENABLED" = "true" ] && [ -n "$S3_BUCKET" ] && [ -s "$STDOUT_FILE" ]; then

    TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
    INSTANCE_ID=$(get_instance_id)
    MD_FILENAME="${CHECK_ID}_${INSTANCE_ID}_${TIMESTAMP}.md"
    S3_KEY="${S3_PREFIX}/${PROFILE}/${MD_FILENAME}"

    dbg "S3 업로드 시작: s3://${S3_BUCKET}/${S3_KEY}"

    if command -v aws &>/dev/null; then
        dbg "aws CLI: $(aws --version 2>&1 | head -1)"

        S3_START=$(date +%s%N 2>/dev/null || date +%s)
        aws s3 cp "$STDOUT_FILE" "s3://${S3_BUCKET}/${S3_KEY}" \
            --region "$AWS_REGION" \
            --content-type "text/markdown" \
            --metadata "check_id=${CHECK_ID},profile=${PROFILE},instance=${INSTANCE_ID},timestamp=${TIMESTAMP}" \
            >/dev/null 2>&1
        S3_RC=$?
        S3_END=$(date +%s%N 2>/dev/null || date +%s)

        if [[ "$S3_START" =~ ^[0-9]{18,}$ ]]; then
            dbg "S3 cp 완료: exit=${S3_RC} elapsed=$(( (S3_END - S3_START) / 1000000 ))ms"
        else
            dbg "S3 cp 완료: exit=${S3_RC}"
        fi

        if [ $S3_RC -eq 0 ]; then
            echo "[S3] Uploaded: s3://${S3_BUCKET}/${S3_KEY}" >> "$STDERR_FILE"
            echo "s3://${S3_BUCKET}/${S3_KEY}" > "${ITEM_EVIDENCE_DIR}/s3_key.txt"
            dbg "S3 업로드 성공 → s3_key.txt 저장"
        else
            echo "[S3] Upload FAILED: ${S3_KEY}" >> "$STDERR_FILE"
            dbg "S3 업로드 실패 (exit=${S3_RC}) — 로컬 증적 유지"
        fi
    else
        echo "[S3] aws CLI not found — skipping upload" >> "$STDERR_FILE"
        dbg "S3 스킵: aws CLI 없음"
    fi
else
    dbg "S3 스킵:"
    [ "$S3_UPLOAD_ENABLED" != "true" ] && dbg "  S3_UPLOAD_ENABLED=${S3_UPLOAD_ENABLED}"
    [ -z "$S3_BUCKET" ]                && dbg "  S3_BUCKET 미설정"
    [ ! -s "$STDOUT_FILE" ]            && dbg "  stdout 비어있음"
fi

# =============================================================================
# stdout 콘솔 출력
# =============================================================================
dbg "stdout 출력 (${STDOUT_SIZE}bytes) → 콘솔"
cat "$STDOUT_FILE"

dbg "shell_runner.sh 종료: CHECK_ID=${CHECK_ID} exit=${EXIT_CODE}"
exit $EXIT_CODE
