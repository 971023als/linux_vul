#!/bin/bash
# shell_script/dbms/mssql/DBM-023.sh
# [DBM-023] 업무상 불필요한 데이터베이스 Object 제거 – mssql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/mssql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/object_list.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/object_list.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }object_list.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/object_list.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }object_list.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/mssql/object_list.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "SCOTT" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} SCOTT"
grep -qiE "test_table" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} test_table"
grep -qiE "sample_db" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} sample_db"
grep -qiE "demo" "${INPUT_DIR}/object_list.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} demo"
if grep -qiE "샘플 스키마.*없음" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 샘플 스키마.*없음(object_list.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "불필요한.*없음" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 불필요한.*없음(object_list.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "제거됨" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 제거됨(object_list.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CUSTOMERS" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CUSTOMERS(object_list.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "ORDERS" "${INPUT_DIR}/object_list.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ORDERS(object_list.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="불필요한 샘플/테스트 오브젝트 없음 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="불필요한 오브젝트 존재 여부 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
