#!/bin/bash
# shell_script/dbms/mysql/DBM-012.sh
# [DBM-012] 취약한 운영체제 역할 인증 기능 비활성화 – mysql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mysql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/remote_access.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/remote_access.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }remote_access.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/remote_access.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }remote_access.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/roles.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/roles.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }roles.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/roles.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }roles.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mysql/remote_access.txt roles.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "OS_AUTHENT_PREFIX=\"\"" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} OS_AUTHENT_PREFIX=\"\""
grep -qiE "OS_AUTHENT_PREFIX=\"\"" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} OS_AUTHENT_PREFIX=\"\""
grep -qiE "sqlnet.authentication_services=\(ALL\)" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sqlnet.authentication_services=\(ALL\)"
grep -qiE "sqlnet.authentication_services=\(ALL\)" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sqlnet.authentication_services=\(ALL\)"
grep -qiE "AUTHENTICATION_SERVICES=ALL" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} AUTHENTICATION_SERVICES=ALL"
grep -qiE "AUTHENTICATION_SERVICES=ALL" "${INPUT_DIR}/roles.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} AUTHENTICATION_SERVICES=ALL"
if grep -qiE "AUTHENTICATION_SERVICES=\(NTS\)" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AUTHENTICATION_SERVICES=\(NTS\)(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "AUTHENTICATION_SERVICES=\(NTS\)" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AUTHENTICATION_SERVICES=\(NTS\)(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "AUTHENTICATION_SERVICES=NONE" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AUTHENTICATION_SERVICES=NONE(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "AUTHENTICATION_SERVICES=NONE" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AUTHENTICATION_SERVICES=NONE(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "os_authent_prefix" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} os_authent_prefix(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "os_authent_prefix" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} os_authent_prefix(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "scram-sha-256" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} scram-sha-256(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "scram-sha-256" "${INPUT_DIR}/roles.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} scram-sha-256(roles.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="OS 인증 기반 접근 제한 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="OS 인증 기능 비활성화 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
