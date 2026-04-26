#!/bin/bash
# shell_script/dbms/cloud_dbms/DBM-024.sh
# [DBM-024] 데이터베이스의 자원 사용 제한 설정 미흡 – cloud_dbms
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/cloud_dbms}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/resource_limit.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/resource_limit.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }resource_limit.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/resource_limit.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }resource_limit.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/cloud_dbms/resource_limit.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "max_connections=0" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} max_connections=0"
grep -qiE "SESSIONS_PER_USER=UNLIMITED" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} SESSIONS_PER_USER=UNLIMITED"
grep -qiE "resource_limit=OFF" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} resource_limit=OFF"
if grep -qiE "SESSIONS_PER_USER=[0-9]" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SESSIONS_PER_USER=[0-9](resource_limit.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "max_connections=[0-9]" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} max_connections=[0-9](resource_limit.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CONNECT_TIME" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CONNECT_TIME(resource_limit.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "rolconnlimit" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} rolconnlimit(resource_limit.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CPU_PER_SESSION" "${INPUT_DIR}/resource_limit.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CPU_PER_SESSION(resource_limit.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="세션/연결 수 제한 설정 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="자원 사용 제한 설정 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
