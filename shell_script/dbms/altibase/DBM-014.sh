#!/bin/bash
# shell_script/dbms/altibase/DBM-014.sh
# [DBM-014] 최신 보안패치와 벤더 권고사항 적용 여부 – altibase
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/altibase}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/patch_status.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/patch_status.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }patch_status.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/patch_status.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }patch_status.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/altibase/patch_status.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "STATUS=EOS" "${INPUT_DIR}/patch_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} STATUS=EOS"
grep -qiE "STATUS=EOL" "${INPUT_DIR}/patch_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} STATUS=EOL"
grep -qiE "STATUS=REVIEW_NEEDED" "${INPUT_DIR}/patch_status.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} STATUS=REVIEW_NEEDED"
if grep -qiE "STATUS=SUPPORTED" "${INPUT_DIR}/patch_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} STATUS=SUPPORTED(patch_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CU_APPLIED" "${INPUT_DIR}/patch_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CU_APPLIED(patch_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CPU_APPLIED" "${INPUT_DIR}/patch_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CPU_APPLIED(patch_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "LAST_PATCH" "${INPUT_DIR}/patch_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} LAST_PATCH(patch_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "LAST_UPDATE" "${INPUT_DIR}/patch_status.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} LAST_UPDATE(patch_status.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="최신 패치 적용 및 지원 버전 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="패치 적용 현황 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
