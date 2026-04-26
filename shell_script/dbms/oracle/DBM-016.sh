#!/bin/bash
# shell_script/dbms/oracle/DBM-016.sh
# [DBM-016] 이전 비밀번호 재사용 요구사항 충족 여부 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/password_policy.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/password_policy.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }password_policy.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/password_policy.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }password_policy.txt(placeholder)" 
if [[ ! -f "${INPUT_DIR}/password_reuse_policy.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }password_reuse_policy.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }password_reuse_policy.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/password_policy.txt password_reuse_policy.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "PASSWORD_REUSE_MAX=0" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PASSWORD_REUSE_MAX=0"
grep -qiE "PASSWORD_REUSE_MAX=0" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PASSWORD_REUSE_MAX=0"
grep -qiE "password_history=0" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} password_history=0"
grep -qiE "password_history=0" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} password_history=0"
grep -qiE "reuse_prevention=false" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} reuse_prevention=false"
grep -qiE "reuse_prevention=false" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} reuse_prevention=false"
if grep -qiE "PASSWORD_REUSE_MAX=[1-9]" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PASSWORD_REUSE_MAX=[1-9](password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "PASSWORD_REUSE_MAX=[1-9]" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PASSWORD_REUSE_MAX=[1-9](password_reuse_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_history=[1-9]" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_history=[1-9](password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_history=[1-9]" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_history=[1-9](password_reuse_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "REUSE_TIME" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} REUSE_TIME(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "REUSE_TIME" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} REUSE_TIME(password_reuse_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "reuse_prevention=true" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} reuse_prevention=true(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "reuse_prevention=true" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} reuse_prevention=true(password_reuse_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_reuse" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_reuse(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_reuse" "${INPUT_DIR}/password_reuse_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_reuse(password_reuse_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="이전 비밀번호 재사용 제한(4개 이상) 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="비밀번호 재사용 제한 정책 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
