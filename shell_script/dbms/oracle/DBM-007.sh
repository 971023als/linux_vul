#!/bin/bash
# shell_script/dbms/oracle/DBM-007.sh
# [DBM-007] 비밀번호 변경 주기 충족 여부 – oracle
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
if [[ ! -f "${INPUT_DIR}/password_lifetime.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }password_lifetime.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }password_lifetime.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/password_policy.txt password_lifetime.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "LIFE_TIME=UNLIMITED" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} LIFE_TIME=UNLIMITED"
grep -qiE "LIFE_TIME=UNLIMITED" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} LIFE_TIME=UNLIMITED"
grep -qiE "LIFE_TIME=0" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} LIFE_TIME=0"
grep -qiE "LIFE_TIME=0" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} LIFE_TIME=0"
grep -qiE "expiration.*false" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} expiration.*false"
grep -qiE "expiration.*false" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} expiration.*false"
grep -qiE "CHECK_EXPIRATION=0" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} CHECK_EXPIRATION=0"
grep -qiE "CHECK_EXPIRATION=0" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} CHECK_EXPIRATION=0"
if grep -qiE "LIFE_TIME=[0-9]" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} LIFE_TIME=[0-9](password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "LIFE_TIME=[0-9]" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} LIFE_TIME=[0-9](password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_expiration" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_expiration(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "password_expiration" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_expiration(password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "lifetime" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} lifetime(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "lifetime" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} lifetime(password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "rotation" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} rotation(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "rotation" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} rotation(password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "VALID UNTIL" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} VALID UNTIL(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "VALID UNTIL" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} VALID UNTIL(password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "expiration_days" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} expiration_days(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "expiration_days" "${INPUT_DIR}/password_lifetime.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} expiration_days(password_lifetime.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="비밀번호 만료 정책(90일 이하) 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="비밀번호 변경 주기 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
