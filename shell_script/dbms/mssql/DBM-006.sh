#!/bin/bash
# shell_script/dbms/mssql/DBM-006.sh
# [DBM-006] 비밀번호 복잡도 설정 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/password_policy.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/password_policy.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }password_policy.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/password_policy.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }password_policy.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/password_policy.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "validate_password.*=.*OFF" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} validate_password.*=.*OFF"
grep -qiE "PASSWORD_VERIFY_FUNCTION.*NULL" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PASSWORD_VERIFY_FUNCTION.*NULL"
grep -qiE "policy.*LOW" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} policy.*LOW"
grep -qiE "no_complexity" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_complexity"
if grep -qiE "VERIFY_FUNCTION" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} VERIFY_FUNCTION(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "validate_password" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} validate_password(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "complexity" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} complexity(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "MEDIUM" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} MEDIUM(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "STRONG" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} STRONG(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "mixed_case" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} mixed_case(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "special_char" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} special_char(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="비밀번호 복잡도 정책(길이+대소문자+숫자+특수문자) 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="비밀번호 복잡도 정책 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
