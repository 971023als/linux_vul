#!/bin/bash
# shell_script/dbms/postgresql/DBM-008.sh
# [DBM-008] 사용되지 않는 세션 종료 여부 – postgresql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/postgresql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/session_timeout.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/session_timeout.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }session_timeout.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/session_timeout.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }session_timeout.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/postgresql/session_timeout.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "IDLE_TIME=0" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} IDLE_TIME=0"
grep -qiE "wait_timeout=0" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} wait_timeout=0"
grep -qiE "timeout=0" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} timeout=0"
grep -qiE "UNLIMITED" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} UNLIMITED"
if grep -qiE "IDLE_TIME" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} IDLE_TIME(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "wait_timeout" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} wait_timeout(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "interactive_timeout" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} interactive_timeout(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "idle_in_transaction" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} idle_in_transaction(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "tcp_keepalives" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} tcp_keepalives(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "IDLE_TIMEOUT" "${INPUT_DIR}/session_timeout.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} IDLE_TIMEOUT(session_timeout.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="idle 세션 자동 종료 정책 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="idle 세션 타임아웃 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
