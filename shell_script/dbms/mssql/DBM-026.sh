#!/bin/bash
# shell_script/dbms/mssql/DBM-026.sh
# [DBM-026] SA 계정에 대한 보안설정 미흡 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/sa_status.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/sa_status.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }sa_status.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/sa_status.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }sa_status.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/sa_status.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "is_disabled=0" "${INPUT_DIR}/sa_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} is_disabled=0"
grep -qiE "SA.*OPEN" "${INPUT_DIR}/sa_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} SA.*OPEN"
grep -qiE "sa.*enabled" "${INPUT_DIR}/sa_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sa.*enabled"
if grep -qiE "is_disabled=1" "${INPUT_DIR}/sa_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} is_disabled=1(sa_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SA.*disabled" "${INPUT_DIR}/sa_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SA.*disabled(sa_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "is_disabled=1.*sa" "${INPUT_DIR}/sa_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} is_disabled=1.*sa(sa_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="SA 계정 비활성화 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="SA 계정 비활성화 여부 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
