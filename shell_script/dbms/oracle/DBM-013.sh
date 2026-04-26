#!/bin/bash
# shell_script/dbms/oracle/DBM-013.sh
# [DBM-013] Public Role에 불필요한 권한 제거 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/public_role_privileges.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }public_role_privileges.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }public_role_privileges.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/roles.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/roles.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }roles.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/roles.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }roles.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/public_role_privileges.txt roles.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "PUBLIC.*EXECUTE.*UTL" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*EXECUTE.*UTL"
grep -qiE "PUBLIC.*EXECUTE.*UTL" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*EXECUTE.*UTL"
grep -qiE "PUBLIC.*EXECUTE.*DBMS_" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*EXECUTE.*DBMS_"
grep -qiE "PUBLIC.*EXECUTE.*DBMS_" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*EXECUTE.*DBMS_"
grep -qiE "PUBLIC.*ALL.*PRIV" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*ALL.*PRIV"
grep -qiE "PUBLIC.*ALL.*PRIV" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*ALL.*PRIV"
if grep -qiE "없음 \(회수됨\)" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 없음 \(회수됨\)(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "없음 \(회수됨\)" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 없음 \(회수됨\)(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "no_public_priv" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no_public_priv(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "no_public_priv" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no_public_priv(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "PUBLIC.*회수" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PUBLIC.*회수(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "PUBLIC.*회수" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PUBLIC.*회수(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "REVOKE.*PUBLIC" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} REVOKE.*PUBLIC(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "REVOKE.*PUBLIC" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} REVOKE.*PUBLIC(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "DENY.*public" "${INPUT_DIR}/public_role_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} DENY.*public(public_role_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "DENY.*public" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} DENY.*public(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="PUBLIC 역할에 불필요한 권한 없음 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="PUBLIC 역할 권한 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
