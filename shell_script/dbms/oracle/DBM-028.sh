#!/bin/bash
# shell_script/dbms/oracle/DBM-028.sh
# [DBM-028] DB 이중화 구성 시 비밀번호 평문 노출 – oracle
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/oracle}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/ha_config.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/ha_config.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }ha_config.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/ha_config.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }ha_config.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/oracle/ha_config.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "password=.*[A-Za-z0-9]" "${INPUT_DIR}/ha_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} password=.*[A-Za-z0-9]"
grep -qiE "MASTER_PASSWORD=" "${INPUT_DIR}/ha_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} MASTER_PASSWORD="
grep -qiE "plaintext" "${INPUT_DIR}/ha_config.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} plaintext"
if grep -qiE "WALLET" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} WALLET(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "CERTIFICATE" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} CERTIFICATE(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SSL.*1" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SSL.*1(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "TDS_ENCRYPTION" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} TDS_ENCRYPTION(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "sslmode=require" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} sslmode=require(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "암호화.*저장" "${INPUT_DIR}/ha_config.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} 암호화.*저장(ha_config.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="이중화 인증 정보 암호화(Wallet/Certificate) 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="이중화 설정 파일 평문 비밀번호 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
