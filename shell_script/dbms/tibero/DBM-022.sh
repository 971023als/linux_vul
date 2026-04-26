#!/bin/bash
# shell_script/dbms/tibero/DBM-022.sh
# [DBM-022] 데이터베이스 구동 계정의 umask 설정 미흡 – tibero
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/tibero}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/service_account.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/service_account.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }service_account.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/service_account.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }service_account.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/tibero/service_account.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "umask=000" "${INPUT_DIR}/service_account.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} umask=000"
grep -qiE "umask=002" "${INPUT_DIR}/service_account.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} umask=002"
grep -qiE "umask=006" "${INPUT_DIR}/service_account.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} umask=006"
grep -qiE "is_root=true" "${INPUT_DIR}/service_account.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} is_root=true"
if grep -qiE "umask=022" "${INPUT_DIR}/service_account.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} umask=022(service_account.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "umask=027" "${INPUT_DIR}/service_account.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} umask=027(service_account.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "is_root=false" "${INPUT_DIR}/service_account.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} is_root=false(service_account.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="umask 022 이상 설정 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="umask 설정 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
