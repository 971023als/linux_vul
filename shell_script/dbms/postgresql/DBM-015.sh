#!/bin/bash
# shell_script/dbms/postgresql/DBM-015.sh
# [DBM-015] 업무상 불필요한 시스템 테이블 접근 권한 제거 – postgresql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/postgresql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/system_table_privileges.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }system_table_privileges.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }system_table_privileges.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/postgresql/system_table_privileges.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "APPUSER.*DBA_.*SELECT" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} APPUSER.*DBA_.*SELECT"
grep -qiE "PUBLIC.*SYS.*EXECUTE" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} PUBLIC.*SYS.*EXECUTE"
grep -qiE "ALL SYSTEM PRIV.*APPUSER" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} ALL SYSTEM PRIV.*APPUSER"
if grep -qiE "없음" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 없음(system_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "불필요 권한 없음" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 불필요 권한 없음(system_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "no_system_priv" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no_system_priv(system_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "회수" "${INPUT_DIR}/system_table_privileges.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 회수(system_table_privileges.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="일반 계정 시스템 테이블 접근 권한 없음 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="시스템 테이블 접근 권한 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
