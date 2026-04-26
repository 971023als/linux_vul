#!/bin/bash
# shell_script/dbms/postgresql/DBM-005.sh
# [DBM-005] 로그인 실패 횟수에 따른 접속 제한 설정 – postgresql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/postgresql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/failed_login_policy.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }failed_login_policy.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }failed_login_policy.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/password_policy.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/password_policy.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }password_policy.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/password_policy.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }password_policy.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/postgresql/failed_login_policy.txt password_policy.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "FAILED_LOGIN_ATTEMPTS=0" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} FAILED_LOGIN_ATTEMPTS=0"
grep -qiE "FAILED_LOGIN_ATTEMPTS=0" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} FAILED_LOGIN_ATTEMPTS=0"
grep -qiE "UNLIMITED" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} UNLIMITED"
grep -qiE "UNLIMITED" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} UNLIMITED"
grep -qiE "no_lockout" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_lockout"
grep -qiE "no_lockout" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_lockout"
if grep -qiE "FAILED_LOGIN_ATTEMPTS=[1-9]" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} FAILED_LOGIN_ATTEMPTS=[1-9](failed_login_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "FAILED_LOGIN_ATTEMPTS=[1-9]" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} FAILED_LOGIN_ATTEMPTS=[1-9](password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "lockout_threshold" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} lockout_threshold(failed_login_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "lockout_threshold" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} lockout_threshold(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "connection_control" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} connection_control(failed_login_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "connection_control" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} connection_control(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "failed_login_attempts=[1-9]" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} failed_login_attempts=[1-9](failed_login_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "failed_login_attempts=[1-9]" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} failed_login_attempts=[1-9](password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "maxretry" "${INPUT_DIR}/failed_login_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} maxretry(failed_login_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "maxretry" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} maxretry(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="로그인 실패 잠금 정책(임계값 5 이하) 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="로그인 실패 잠금 정책 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
