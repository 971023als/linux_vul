#!/bin/bash
# shell_script/dbms/mysql/DBM-001.sh
# -----------------------------------------------------------------------------
# [DBM-001] 취약하게 설정된 비밀번호 제거
# profile: mysql
# -----------------------------------------------------------------------------
# Phase 0: 실제 DB 접속 금지. 로컬 증적 파일만 분석.
# 출력 형식: STATUS=PASS|FAIL|NA|MANUAL_REVIEW|EVIDENCE_MISSING|ERROR|NOT_IMPLEMENTED
# -----------------------------------------------------------------------------

set -u

CHECK_ID="DBM-001"
PROFILE="mysql"
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mysql}"

STATUS="EVIDENCE_MISSING"
REASON=""
EVIDENCE=""

# ------------------------------------------------------------------
# 필수 증적 파일 존재 확인
# ------------------------------------------------------------------
MISSING_FILES=""
_ef="${INPUT_DIR}/users.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} users.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} users.txt(placeholder만)"
    fi
fi
_ef="${INPUT_DIR}/password_policy.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} password_policy.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} password_policy.txt(placeholder만)"
    fi
fi
if [[ -n "$MISSING_FILES" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 파일이 없거나 유효 내용이 없습니다: ${MISSING_FILES}"
    echo "EVIDENCE=${INPUT_DIR}/  파일 필요: users.txt password_policy.txt"
    exit 0
fi

# ------------------------------------------------------------------
# 취약 패턴 검색 (FAIL 후보)
# ------------------------------------------------------------------
FAIL_FOUND=""
grep -qiE "default" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} default(users.txt)"
grep -qiE "default" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} default(password_policy.txt)"
grep -qiE "weak" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} weak(users.txt)"
grep -qiE "weak" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} weak(password_policy.txt)"
grep -qiE "same_as_user" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} same_as_user(users.txt)"
grep -qiE "same_as_user" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} same_as_user(password_policy.txt)"
grep -qiE "initial" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} initial(users.txt)"
grep -qiE "initial" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} initial(password_policy.txt)"
grep -qiE "초기비밀번호" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 초기비밀번호(users.txt)"
grep -qiE "초기비밀번호" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 초기비밀번호(password_policy.txt)"
grep -qiE "기본패스워드" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 기본패스워드(users.txt)"
grep -qiE "기본패스워드" "${INPUT_DIR}/password_policy.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 기본패스워드(password_policy.txt)"

# ------------------------------------------------------------------
# 양호 패턴 검색 (PASS 후보)
# ------------------------------------------------------------------
PASS_FOUND=""
PASS_COUNT=0
if grep -qiE "password_verify_function" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_verify_function(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "password_verify_function" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} password_verify_function(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "complexity" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} complexity(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "complexity" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} complexity(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "complexity_check" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} complexity_check(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "complexity_check" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} complexity_check(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "PASSWORD_POLICY" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PASSWORD_POLICY(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "PASSWORD_POLICY" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} PASSWORD_POLICY(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "복잡도" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 복잡도(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "복잡도" "${INPUT_DIR}/password_policy.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 복잡도(password_policy.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi

# ------------------------------------------------------------------
# 판정 로직
# 원칙: 단일 키워드 매칭만으로 PASS 확정 금지.
#       PASS는 최소 2개 이상의 독립 증적 또는 명확한 설정값이 있을 때만 허용.
# ------------------------------------------------------------------
if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"
    REASON="취약 패턴이 감지되었습니다: ${FAIL_FOUND}"
    EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"
    REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"
    EVIDENCE="password_policy.txt에 복잡도 정책이 명확히 설정되고 users.txt에 취약 패턴이 없으면 PASS 후보"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"
    REASON="단일 키워드만 확인됨 – 수동 검토 필요: ${PASS_FOUND}"
    EVIDENCE="단일 키워드 매칭은 PASS 확정 불가. 원본 증적 파일 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"
    REASON="password_policy.txt에 복잡도 정책이 명확히 설정되고 users.txt에 취약 패턴이 없으면 PASS 후보"
    EVIDENCE="증적 파일은 존재하나 자동 판단 기준 미충족"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
