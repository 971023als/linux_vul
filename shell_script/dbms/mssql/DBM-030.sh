#!/bin/bash
# shell_script/dbms/mssql/DBM-030.sh
# -----------------------------------------------------------------------------
# [DBM-030] xp_cmdshell 사용 비활성화
# profile: mssql
# -----------------------------------------------------------------------------
# Phase 0: 실제 DB 접속 금지. 로컬 증적 파일만 분석.
# 출력 형식: STATUS=PASS|FAIL|NA|MANUAL_REVIEW|EVIDENCE_MISSING|ERROR|NOT_IMPLEMENTED
# -----------------------------------------------------------------------------

set -u

CHECK_ID="DBM-030"
PROFILE="mssql"
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"

STATUS="EVIDENCE_MISSING"
REASON=""
EVIDENCE=""

# ------------------------------------------------------------------
# 필수 증적 파일 존재 확인
# ------------------------------------------------------------------
MISSING_FILES=""
_ef="${INPUT_DIR}/xp_cmdshell_status.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} xp_cmdshell_status.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} xp_cmdshell_status.txt(placeholder만)"
    fi
fi
if [[ -n "$MISSING_FILES" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 파일이 없거나 유효 내용이 없습니다: ${MISSING_FILES}"
    echo "EVIDENCE=${INPUT_DIR}/  파일 필요: xp_cmdshell_status.txt"
    exit 0
fi

# ------------------------------------------------------------------
# 취약 패턴 검색 (FAIL 후보)
# ------------------------------------------------------------------
FAIL_FOUND=""
grep -qiE "xp_cmdshell.*=.*1" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} xp_cmdshell.*=.*1(xp_cmdshell_status.txt)"
grep -qiE "xp_cmdshell.*enabled" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} xp_cmdshell.*enabled(xp_cmdshell_status.txt)"
grep -qiE "value.*=.*1" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} value.*=.*1(xp_cmdshell_status.txt)"

# ------------------------------------------------------------------
# 양호 패턴 검색 (PASS 후보)
# ------------------------------------------------------------------
PASS_FOUND=""
PASS_COUNT=0
if grep -qiE "xp_cmdshell.*=.*0" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} xp_cmdshell.*=.*0(xp_cmdshell_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "xp_cmdshell.*disabled" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} xp_cmdshell.*disabled(xp_cmdshell_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "value.*=.*0" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} value.*=.*0(xp_cmdshell_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "비활성" "${INPUT_DIR}/xp_cmdshell_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 비활성(xp_cmdshell_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi

# ------------------------------------------------------------------
# 판정 로직
# 원칙: 단일 키워드 매칭만으로 PASS 확정 금지.
#       PASS는 최소 2개 이상의 독립 증적 또는 명확한 설정값이 있을 때만 허용.
# ------------------------------------------------------------------
if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"
    REASON="취약 패턴이 감지되었습니다: ${FAIL_FOUND}"
    EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"
    REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"
    EVIDENCE="xp_cmdshell_status.txt에 disabled/0 확인 시 PASS 후보"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"
    REASON="단일 키워드만 확인됨 – 수동 검토 필요: ${PASS_FOUND}"
    EVIDENCE="단일 키워드 매칭은 PASS 확정 불가. 원본 증적 파일 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"
    REASON="xp_cmdshell_status.txt에 disabled/0 확인 시 PASS 후보"
    EVIDENCE="증적 파일은 존재하나 자동 판단 기준 미충족"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
