#!/bin/bash
# shell_script/dbms/oracle/DBM-017.sh
# [DBM-017] 사용자별 계정 분리 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/users.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/users.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }users.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/users.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }users.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/admin_users.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/admin_users.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }admin_users.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/admin_users.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }admin_users.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/users.txt admin_users.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "shared_account" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} shared_account"
grep -qiE "shared_account" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} shared_account"
grep -qiE "공용계정" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 공용계정"
grep -qiE "공용계정" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 공용계정"
grep -qiE "guest.*OPEN" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} guest.*OPEN"
grep -qiE "guest.*OPEN" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} guest.*OPEN"
grep -qiE "anonymous" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} anonymous"
grep -qiE "anonymous" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} anonymous"
if grep -qiE "APPUSER" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} APPUSER(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "APPUSER" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} APPUSER(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "appuser" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} appuser(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "appuser" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} appuser(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "READONLY" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} READONLY(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "READONLY" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} READONLY(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "readonly" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} readonly(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "readonly" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} readonly(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "변경승인" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 변경승인(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "변경승인" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 변경승인(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "APPROVED" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} APPROVED(users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "APPROVED" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} APPROVED(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="개인별 계정 분리 및 공용 계정 없음 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="계정 분리 현황 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
