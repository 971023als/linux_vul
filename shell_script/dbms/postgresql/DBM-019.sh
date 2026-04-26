#!/bin/bash
# shell_script/dbms/postgresql/DBM-019.sh
# [DBM-019] 설정 파일 및 중요정보가 포함된 파일의 접근 권한 설정 적절성 – postgresql
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/postgresql}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/file_permissions.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/file_permissions.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }file_permissions.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/file_permissions.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }file_permissions.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/postgresql/file_permissions.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "chmod.*777" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} chmod.*777"
grep -qiE "-rwxrwxrwx" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} -rwxrwxrwx"
grep -qiE "Everyone.*Full" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} Everyone.*Full"
grep -qiE "world.writable" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} world.writable"
if grep -qiE "-rw-------" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} -rw-------(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "-rw-r-----" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} -rw-r-----(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "600" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 600(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "640" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 640(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "700" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 700(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "no.*public.*access" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} no.*public.*access(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "비인가자.*불가" "${INPUT_DIR}/file_permissions.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 비인가자.*불가(file_permissions.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="주요 설정 파일 600/640 권한 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="설정 파일 권한 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
