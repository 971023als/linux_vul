#!/bin/bash
# shell_script/dbms/postgresql/DBM-004.sh
# -----------------------------------------------------------------------------
# [DBM-004] 데이터베이스 내 중요정보 안전한 암호화 적용 여부
# profile: postgresql
# -----------------------------------------------------------------------------
# Phase 0: 실제 DB 접속 금지. 로컬 증적 파일만 분석.
# 출력 형식: STATUS=PASS|FAIL|NA|MANUAL_REVIEW|EVIDENCE_MISSING|ERROR|NOT_IMPLEMENTED
# -----------------------------------------------------------------------------

set -u

CHECK_ID="DBM-004"
PROFILE="postgresql"
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/postgresql}"

STATUS="EVIDENCE_MISSING"
REASON=""
EVIDENCE=""

# ------------------------------------------------------------------
# 필수 증적 파일 존재 확인
# ------------------------------------------------------------------
MISSING_FILES=""
_ef="${INPUT_DIR}/encryption_status.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} encryption_status.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} encryption_status.txt(placeholder만)"
    fi
fi
_ef="${INPUT_DIR}/object_list.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} object_list.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} object_list.txt(placeholder만)"
    fi
fi
if [[ -n "$MISSING_FILES" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 파일이 없거나 유효 내용이 없습니다: ${MISSING_FILES}"
    echo "EVIDENCE=${INPUT_DIR}/  파일 필요: encryption_status.txt object_list.txt"
    exit 0
fi

# ------------------------------------------------------------------
# 취약 패턴 검색 (FAIL 후보)
# ------------------------------------------------------------------
FAIL_FOUND=""
grep -qiE "plaintext" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} plaintext(encryption_status.txt)"
grep -qiE "plaintext" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} plaintext(object_list.txt)"
grep -qiE "unencrypted" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} unencrypted(encryption_status.txt)"
grep -qiE "unencrypted" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} unencrypted(object_list.txt)"
grep -qiE "no_encryption" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_encryption(encryption_status.txt)"
grep -qiE "no_encryption" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_encryption(object_list.txt)"
grep -qiE "암호화없음" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 암호화없음(encryption_status.txt)"
grep -qiE "암호화없음" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 암호화없음(object_list.txt)"

# ------------------------------------------------------------------
# 양호 패턴 검색 (PASS 후보)
# ------------------------------------------------------------------
PASS_FOUND=""
PASS_COUNT=0
if grep -qiE "TDE" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} TDE(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "TDE" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} TDE(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "AES" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AES(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "AES" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} AES(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "SHA-256" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SHA-256(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "SHA-256" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SHA-256(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "encrypted" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} encrypted(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "encrypted" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} encrypted(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "암호화적용" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 암호화적용(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "암호화적용" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 암호화적용(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "column_encryption" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} column_encryption(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "column_encryption" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} column_encryption(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "tablespace_encryption" "${INPUT_DIR}/encryption_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} tablespace_encryption(encryption_status.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "tablespace_encryption" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} tablespace_encryption(object_list.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi

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
    EVIDENCE="encryption_status.txt에 TDE/AES 적용 확인 + object_list.txt에 평문 저장 없으면 PASS 후보"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"
    REASON="단일 키워드만 확인됨 – 수동 검토 필요: ${PASS_FOUND}"
    EVIDENCE="단일 키워드 매칭은 PASS 확정 불가. 원본 증적 파일 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"
    REASON="encryption_status.txt에 TDE/AES 적용 확인 + object_list.txt에 평문 저장 없으면 PASS 후보"
    EVIDENCE="증적 파일은 존재하나 자동 판단 기준 미충족"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
