#!/bin/bash
# shell_script/dbms/mssql/DBM-025.sh
# [DBM-025] Audit Table에 대한 접근 제어 미흡 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/audit_table_privileges.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }audit_table_privileges.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }audit_table_privileges.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/audit_table_privileges.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "APPUSER.*AUD\$.*SELECT" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} APPUSER.*AUD\$.*SELECT"
grep -qiE "PUBLIC.*AUDIT.*SELECT" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*AUDIT.*SELECT"
grep -qiE "everyone.*audit" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} everyone.*audit"
if grep -qiE "일반 계정.*불가" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 일반 계정.*불가(audit_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "접근 불가" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 접근 불가(audit_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "DBA.*전용" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} DBA.*전용(audit_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SYSAUDIT" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SYSAUDIT(audit_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "no.*public.*audit" "${INPUT_DIR}/audit_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no.*public.*audit(audit_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="감사 테이블 접근 권한 DBA 전용 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="감사 테이블 접근 권한 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
