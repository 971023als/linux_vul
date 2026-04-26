#!/bin/bash
# shell_script/dbms/oracle/DBM-011.sh
# [DBM-011] 원격 접속에 대한 접근 제어 여부 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/remote_access.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/remote_access.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }remote_access.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/remote_access.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }remote_access.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/remote_access.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "PubliclyAccessible=true" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PubliclyAccessible=true"
grep -qiE "0\.0\.0\.0/0.*ALL" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 0\.0\.0\.0/0.*ALL"
grep -qiE "bind-address=0\.0\.0\.0" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} bind-address=0\.0\.0\.0"
grep -qiE "EXCLUDED_NODES=" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} EXCLUDED_NODES="
if grep -qiE "INVITED_NODES" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} INVITED_NODES(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "VALIDNODE_CHECKING=YES" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} VALIDNODE_CHECKING=YES(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "PubliclyAccessible=false" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PubliclyAccessible=false(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "scram-sha-256" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} scram-sha-256(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "ALLOWED_HOSTS" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ALLOWED_HOSTS(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "InboundRule" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} InboundRule(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="원격 접속 IP/계정 제한 설정 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="원격 접속 IP 제한 정책 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
