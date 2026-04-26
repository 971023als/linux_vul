#!/bin/bash
# shell_script/dbms/mssql/DBM-009.sh
# -----------------------------------------------------------------------------
# [DBM-009] 감사 로그 수집 및 백업 여부
# profile: mssql
# -----------------------------------------------------------------------------
# Phase 0: 실제 DB 접속 금지. 로컬 증적 파일만 분석.
# 출력 형식: STATUS=PASS|FAIL|NA|MANUAL_REVIEW|EVIDENCE_MISSING|ERROR|NOT_IMPLEMENTED
# -----------------------------------------------------------------------------

set -u

CHECK_ID="DBM-009"
PROFILE="mssql"
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"

STATUS="EVIDENCE_MISSING"
REASON=""
EVIDENCE=""

# ------------------------------------------------------------------
# 필수 증적 파일 존재 확인
# ------------------------------------------------------------------
MISSING_FILES=""
_ef="${INPUT_DIR}/audit_config.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} audit_config.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} audit_config.txt(placeholder만)"
    fi
fi
_ef="${INPUT_DIR}/audit_backup.txt"
if [[ ! -f "$_ef" ]] || [[ $(stat -c%s "$_ef" 2>/dev/null || echo 0) -eq 0 ]]; then
    MISSING_FILES="${MISSING_FILES} audit_backup.txt(없음)"
else
    real=$(grep -v '^\s*#' "$_ef" | grep -v '^\s*$' | wc -l)
    if [[ "$real" -eq 0 ]]; then
        MISSING_FILES="${MISSING_FILES} audit_backup.txt(placeholder만)"
    fi
fi
if [[ -n "$MISSING_FILES" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 파일이 없거나 유효 내용이 없습니다: ${MISSING_FILES}"
    echo "EVIDENCE=${INPUT_DIR}/  파일 필요: audit_config.txt audit_backup.txt"
    exit 0
fi

# ------------------------------------------------------------------
# 취약 패턴 검색 (FAIL 후보)
# ------------------------------------------------------------------
FAIL_FOUND=""
grep -qiE "audit=off" "${INPUT_DIR}/audit_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} audit=off(audit_config.txt)"
grep -qiE "audit=off" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} audit=off(audit_backup.txt)"
grep -qiE "audit_trail=none" "${INPUT_DIR}/audit_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} audit_trail=none(audit_config.txt)"
grep -qiE "audit_trail=none" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} audit_trail=none(audit_backup.txt)"
grep -qiE "no_backup" "${INPUT_DIR}/audit_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_backup(audit_config.txt)"
grep -qiE "no_backup" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} no_backup(audit_backup.txt)"
grep -qiE "disabled" "${INPUT_DIR}/audit_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} disabled(audit_config.txt)"
grep -qiE "disabled" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} disabled(audit_backup.txt)"
grep -qiE "비활성" "${INPUT_DIR}/audit_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 비활성(audit_config.txt)"
grep -qiE "비활성" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} 비활성(audit_backup.txt)"

# ------------------------------------------------------------------
# 양호 패턴 검색 (PASS 후보)
# ------------------------------------------------------------------
PASS_FOUND=""
PASS_COUNT=0
if grep -qiE "audit" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} audit(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "audit" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} audit(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "logging" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} logging(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "logging" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} logging(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "trail" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} trail(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "trail" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} trail(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "backup" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} backup(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "backup" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} backup(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "archive" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} archive(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "archive" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} archive(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "retention" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} retention(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "retention" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} retention(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "SIEM" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SIEM(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "SIEM" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SIEM(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "감사로그" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 감사로그(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "감사로그" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 감사로그(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "백업" "${INPUT_DIR}/audit_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 백업(audit_config.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi
if grep -qiE "백업" "${INPUT_DIR}/audit_backup.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 백업(audit_backup.txt)"; PASS_COUNT=$((PASS_COUNT + 1)); fi

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
    EVIDENCE="audit_config.txt에 감사 활성화 + audit_backup.txt에 보관 정책 확인 시 PASS 후보"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"
    REASON="단일 키워드만 확인됨 – 수동 검토 필요: ${PASS_FOUND}"
    EVIDENCE="단일 키워드 매칭은 PASS 확정 불가. 원본 증적 파일 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"
    REASON="audit_config.txt에 감사 활성화 + audit_backup.txt에 보관 정책 확인 시 PASS 후보"
    EVIDENCE="증적 파일은 존재하나 자동 판단 기준 미충족"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
