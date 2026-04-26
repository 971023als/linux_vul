#!/bin/bash
# shell_script/dbms/oracle/DBM-010.sh
# [DBM-010] Listener Control Utility(lsnrctl) 보안 설정 여부 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/listener_config.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/listener_config.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }listener_config.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/listener_config.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }listener_config.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/listener_config.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "ADMIN_RESTRICTIONS=OFF" "${INPUT_DIR}/listener_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} ADMIN_RESTRICTIONS=OFF"
grep -qiE "ADMIN_RESTRICTIONS_LISTENER=OFF" "${INPUT_DIR}/listener_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} ADMIN_RESTRICTIONS_LISTENER=OFF"
grep -qiE "NA=true" "${INPUT_DIR}/listener_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} NA=true"
if grep -qiE "ADMIN_RESTRICTIONS=ON" "${INPUT_DIR}/listener_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ADMIN_RESTRICTIONS=ON(listener_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "ADMIN_RESTRICTIONS_LISTENER=ON" "${INPUT_DIR}/listener_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ADMIN_RESTRICTIONS_LISTENER=ON(listener_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SECURE_REGISTER=IPC" "${INPUT_DIR}/listener_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SECURE_REGISTER=IPC(listener_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SECURE_REGISTER_LISTENER=IPC" "${INPUT_DIR}/listener_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SECURE_REGISTER_LISTENER=IPC(listener_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="Listener 원격 관리 차단, IPC 등록 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="Listener 보안 설정 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
