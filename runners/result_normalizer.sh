#!/bin/bash
# runners/result_normalizer.sh
# -----------------------------------------------------------------------------
# [Result Normalizer] 스크립트 실행 결과를 표준 7-state 값으로 정규화한다.
#
# 사용법:
#   result_normalizer.sh --stdout <file> --stderr <file> --exit-code <n> \
#                        --evidence-dir <dir> --check-id <id>
#
# 표준 상태값:
#   PASS, FAIL, NA, MANUAL_REVIEW, EVIDENCE_MISSING, ERROR, NOT_IMPLEMENTED
#
# 출력: stdout에 JSON (normalized_result.json 내용)
# -----------------------------------------------------------------------------

set -u

STDOUT_FILE=""
STDERR_FILE=""
EXIT_CODE=0
EVIDENCE_DIR=""
CHECK_ID=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stdout)      STDOUT_FILE="${2:-}";  shift 2 ;;
        --stderr)      STDERR_FILE="${2:-}";  shift 2 ;;
        --exit-code)   EXIT_CODE="${2:-0}";   shift 2 ;;
        --evidence-dir) EVIDENCE_DIR="${2:-}"; shift 2 ;;
        --check-id)    CHECK_ID="${2:-}";     shift 2 ;;
        *) shift ;;
    esac
done

# ------------------------------------------------------------------
# 내용 읽기
# ------------------------------------------------------------------
STDOUT_CONTENT=""
STDERR_CONTENT=""

[[ -f "$STDOUT_FILE" ]] && STDOUT_CONTENT=$(cat "$STDOUT_FILE")
[[ -f "$STDERR_FILE" ]] && STDERR_CONTENT=$(cat "$STDERR_FILE")

# ------------------------------------------------------------------
# 규칙 1: stderr 있고 exit code non-zero → ERROR
# ------------------------------------------------------------------
if [[ -n "$STDERR_CONTENT" && "$EXIT_CODE" -ne 0 ]]; then
    python3 -c "
import json
print(json.dumps({
    'status': 'ERROR',
    'reason': 'stderr 출력 및 비정상 종료 코드 감지',
    'raw_status': '',
    'exit_code': int('$EXIT_CODE'),
    'evidence_count': 0
}, ensure_ascii=False))
"
    exit 0
fi

# ------------------------------------------------------------------
# 규칙 2: stdout 비어있고 exit code 0 → MANUAL_REVIEW
# ------------------------------------------------------------------
if [[ -z "$(echo "$STDOUT_CONTENT" | tr -d '[:space:]')" && "$EXIT_CODE" -eq 0 ]]; then
    python3 -c "
import json
print(json.dumps({
    'status': 'MANUAL_REVIEW',
    'reason': '스크립트 출력이 비어 있습니다 (판단 불가)',
    'raw_status': '',
    'exit_code': 0,
    'evidence_count': 0
}, ensure_ascii=False))
"
    exit 0
fi

# ------------------------------------------------------------------
# 규칙 3: stdout에서 STATUS= 추출
# ------------------------------------------------------------------
RAW_STATUS=$(echo "$STDOUT_CONTENT" | grep -m1 -E '^STATUS=' | sed 's/^STATUS=//' | tr -d '[:space:]')
RAW_REASON=$(echo "$STDOUT_CONTENT"  | grep -m1 -E '^REASON='  | sed 's/^REASON=//')
RAW_EVIDENCE=$(echo "$STDOUT_CONTENT" | grep -m1 -E '^EVIDENCE=' | sed 's/^EVIDENCE=//')

# ------------------------------------------------------------------
# 상태값 매핑
# ------------------------------------------------------------------
NORMALIZED_STATUS=""
case "${RAW_STATUS^^}" in
    PASS|양호|OK|정상)
        NORMALIZED_STATUS="PASS"
        ;;
    FAIL|취약|위험|미흡)
        NORMALIZED_STATUS="FAIL"
        ;;
    NA|N/A|해당없음)
        NORMALIZED_STATUS="NA"
        ;;
    MANUAL_REVIEW|수동점검|수동검토|MANUAL|확인필요)
        NORMALIZED_STATUS="MANUAL_REVIEW"
        ;;
    EVIDENCE_MISSING|증적없음|근거없음|파일없음)
        NORMALIZED_STATUS="EVIDENCE_MISSING"
        ;;
    ERROR|오류)
        NORMALIZED_STATUS="ERROR"
        ;;
    NOT_IMPLEMENTED|미구현|TODO)
        NORMALIZED_STATUS="NOT_IMPLEMENTED"
        ;;
    "")
        # STATUS= 없음 → MANUAL_REVIEW
        NORMALIZED_STATUS="MANUAL_REVIEW"
        RAW_REASON="스크립트에서 STATUS= 출력 없음 – 수동 검토 필요"
        ;;
    *)
        NORMALIZED_STATUS="MANUAL_REVIEW"
        RAW_REASON="해석할 수 없는 상태값: ${RAW_STATUS}"
        ;;
esac

# ------------------------------------------------------------------
# 규칙 4: PASS인데 증적이 없으면 EVIDENCE_MISSING으로 강등
# ------------------------------------------------------------------
EVIDENCE_COUNT=0
if [[ -n "$EVIDENCE_DIR" && -d "$EVIDENCE_DIR" ]]; then
    for f in "$EVIDENCE_DIR"/*; do
        [[ -f "$f" ]] || continue
        # 0바이트 또는 주석/placeholder only 파일은 유효 증적 제외
        fsize=$(stat -c%s "$f" 2>/dev/null || echo 0)
        if [[ "$fsize" -eq 0 ]]; then
            continue
        fi
        # placeholder-only 확인: 실질 내용(비주석, 비공백) 없으면 제외
        real_lines=$(grep -v '^\s*#' "$f" | grep -v '^\s*$' | wc -l)
        if [[ "$real_lines" -eq 0 ]]; then
            continue
        fi
        EVIDENCE_COUNT=$((EVIDENCE_COUNT + 1))
    done
fi

if [[ "$NORMALIZED_STATUS" == "PASS" && "$EVIDENCE_COUNT" -eq 0 ]]; then
    NORMALIZED_STATUS="EVIDENCE_MISSING"
    RAW_REASON="유효 증적 없이 PASS 출력 감지 – EVIDENCE_MISSING으로 강등"
fi

# ------------------------------------------------------------------
# 규칙 5: PASS, FAIL, NA 외 상태는 PASS 집계 금지 (정보 기록용)
# ------------------------------------------------------------------
IN_PASS_COUNT=false
[[ "$NORMALIZED_STATUS" == "PASS" ]] && IN_PASS_COUNT=true

# ------------------------------------------------------------------
# 최종 JSON 출력
# ------------------------------------------------------------------
python3 -c "
import json
print(json.dumps({
    'status': '$NORMALIZED_STATUS',
    'reason': '''${RAW_REASON}''',
    'raw_status': '$RAW_STATUS',
    'exit_code': int('$EXIT_CODE'),
    'evidence_count': int('$EVIDENCE_COUNT'),
    'in_pass_count': $([[ "$IN_PASS_COUNT" == "true" ]] && echo "True" || echo "False"),
    'evidence': '''${RAW_EVIDENCE}'''
}, ensure_ascii=False))
"
exit 0
