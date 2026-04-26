#!/bin/bash
# shell_script/dbms/mssql/DBM-020.sh
# [DBM-020] 불필요하게 WITH GRANT OPTION 옵션이 설정된 권한 제거 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/roles.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/roles.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }roles.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/roles.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }roles.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/public_role_privileges.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }public_role_privileges.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }public_role_privileges.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/roles.txt public_role_privileges.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "GRANT_OPTION=YES.*APPUSER" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} GRANT_OPTION=YES.*APPUSER"
grep -qiE "GRANT_OPTION=YES.*APPUSER" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} GRANT_OPTION=YES.*APPUSER"
grep -qiE "WITH GRANT OPTION.*PUBLIC" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} WITH GRANT OPTION.*PUBLIC"
grep -qiE "WITH GRANT OPTION.*PUBLIC" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} WITH GRANT OPTION.*PUBLIC"
grep -qiE "grant_option.*true" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} grant_option.*true"
grep -qiE "grant_option.*true" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} grant_option.*true"
if grep -qiE "GRANT_OPTION=NO" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} GRANT_OPTION=NO(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "GRANT_OPTION=NO" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} GRANT_OPTION=NO(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "GRANT OPTION 없음" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} GRANT OPTION 없음(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "GRANT OPTION 없음" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} GRANT OPTION 없음(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "WITHOUT GRANT OPTION" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} WITHOUT GRANT OPTION(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "WITHOUT GRANT OPTION" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} WITHOUT GRANT OPTION(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "grant_option.*없음" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} grant_option.*없음(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "grant_option.*없음" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} grant_option.*없음(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="불필요한 WITH GRANT OPTION 없음 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="WITH GRANT OPTION 설정 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
