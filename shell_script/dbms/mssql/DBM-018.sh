#!/bin/bash
# shell_script/dbms/mssql/DBM-018.sh
# [DBM-018] 업무상 불필요한 ODBC/OLE-DB 데이터 소스 및 드라이버 제거 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/remote_access.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/remote_access.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }remote_access.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/remote_access.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }remote_access.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/remote_access.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "Named Pipes.*ENABLED" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} Named Pipes.*ENABLED"
grep -qiE "OLEDB.*ENABLED" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} OLEDB.*ENABLED"
grep -qiE "unnecessary_dsn" "${INPUT_DIR}/remote_access.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} unnecessary_dsn"
if grep -qiE "Named Pipes.*DISABLED" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} Named Pipes.*DISABLED(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "Shared Memory.*LOCALHOST" "${INPUT_DIR}/remote_access.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} Shared Memory.*LOCALHOST(remote_access.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="불필요한 ODBC/Named Pipes 비활성화 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="ODBC/OLE-DB 드라이버 사용 현황 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
