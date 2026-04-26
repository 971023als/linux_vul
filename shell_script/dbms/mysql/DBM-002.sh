#!/bin/bash
# shell_script/dbms/mysql/DBM-002.sh
# -----------------------------------------------------------------------------
# [DBM-002] 불필요하거나 관리되지 않는 계정 제거
# profile: mysql
# -----------------------------------------------------------------------------
# Phase 0: 실제 DB 접속 금지. 로컬 증적 파일만 분석.
# 출력 형식: STATUS=PASS|FAIL|NA|MANUAL_REVIEW|EVIDENCE_MISSING|ERROR|NOT_IMPLEMENTED
# -----------------------------------------------------------------------------

set -u

CHECK_ID="DBM-002"
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
_ef="${INPUT_DIR}/admin_users.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} admin_users.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} admin_users.txt(placeholder만)"
    fi
fi
if [[ -n "$MISSING_FILES" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 파일이 없거나 유효 내용이 없습니다: ${MISSING_FILES}"
    echo "EVIDENCE=${INPUT_DIR}/  파일 필요: users.txt admin_users.txt"
    exit 0
fi

# ------------------------------------------------------------------
# 취약 패턴 검색 (FAIL 후보)
# ------------------------------------------------------------------
FAIL_FOUND=""
grep -qiE "expired" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} expired(users.txt)"
grep -qiE "expired" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} expired(admin_users.txt)"
grep -qiE "inactive" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} inactive(users.txt)"
grep -qiE "inactive" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} inactive(admin_users.txt)"
grep -qiE "unused" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} unused(users.txt)"
grep -qiE "unused" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} unused(admin_users.txt)"
grep -qiE "guest" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} guest(users.txt)"
grep -qiE "guest" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} guest(admin_users.txt)"
grep -qiE "test" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} test(users.txt)"
grep -qiE "test" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} test(admin_users.txt)"
grep -qiE "sample" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sample(users.txt)"
grep -qiE "sample" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sample(admin_users.txt)"
grep -qiE "demo" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} demo(users.txt)"
grep -qiE "demo" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} demo(admin_users.txt)"
grep -qiE "퇴사" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 퇴사(users.txt)"
grep -qiE "퇴사" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 퇴사(admin_users.txt)"
grep -qiE "휴면" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 휴면(users.txt)"
grep -qiE "휴면" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 휴면(admin_users.txt)"
grep -qiE "미사용" "${INPUT_DIR}/users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 미사용(users.txt)"
grep -qiE "미사용" "${INPUT_DIR}/admin_users.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 미사용(admin_users.txt)"

# ------------------------------------------------------------------
# 양호 패턴 검색 (PASS 후보)
# ------------------------------------------------------------------
PASS_FOUND=""
PASS_COUNT=0
if grep -qiE "all_accounts_reviewed" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} all_accounts_reviewed(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "all_accounts_reviewed" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} all_accounts_reviewed(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "no_inactive" "${INPUT_DIR}/users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no_inactive(users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "no_inactive" "${INPUT_DIR}/admin_users.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no_inactive(admin_users.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi

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
    EVIDENCE="users.txt 내 test/guest/demo 등 불필요 계정이 없고 admin_users.txt와 대조 검토 완료 시 PASS 후보"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"
    REASON="단일 키워드만 확인됨 – 수동 검토 필요: ${PASS_FOUND}"
    EVIDENCE="단일 키워드 매칭은 PASS 확정 불가. 원본 증적 파일 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"
    REASON="users.txt 내 test/guest/demo 등 불필요 계정이 없고 admin_users.txt와 대조 검토 완료 시 PASS 후보"
    EVIDENCE="증적 파일은 존재하나 자동 판단 기준 미충족"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
