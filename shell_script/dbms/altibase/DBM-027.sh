#!/bin/bash
# shell_script/dbms/altibase/DBM-027.sh
# [DBM-027] 데이터베이스 접속 시 통신구간에 비밀번호 평문 노출 – altibase
# Phase 0/1: 로컬 증적 파일만 분석, DB 직접 접속 금지
set -u
INPUT_DIR="${INPUT_DIR:-input/evidence/dbms/altibase}"
STATUS="EVIDENCE_MISSING"; REASON=""; EVIDENCE=""

MISSING=""
if [[ ! -f "${INPUT_DIR}/network_encryption.txt" ]] || [[ $(stat -c%s "${INPUT_DIR}/network_encryption.txt" 2>/dev/null||echo 0) -eq 0 ]]; then
    MISSING="${MISSING:+$MISSING }network_encryption.txt(없음)"
fi
_rl=$(grep -v '^\s*#' "${INPUT_DIR}/network_encryption.txt" 2>/dev/null|grep -v '^\s*$'|wc -l)
[[ "$_rl" -eq 0 ]] && MISSING="${MISSING:+$MISSING }network_encryption.txt(placeholder)" 
if [[ -n "$MISSING" ]]; then
    echo "STATUS=EVIDENCE_MISSING"
    echo "REASON=필수 증적 없음: ${MISSING}"
    echo "EVIDENCE=input/evidence/dbms/altibase/network_encryption.txt 필요"
    exit 0
fi

FAIL_FOUND=""; PASS_FOUND=""; PASS_COUNT=0
grep -qiE "ssl=off" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} ssl=off"
grep -qiE "SSL_ENABLE=0" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} SSL_ENABLE=0"
grep -qiE "FORCE_ENCRYPTION=0" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} FORCE_ENCRYPTION=0"
grep -qiE "require_secure_transport=OFF" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null && FAIL_FOUND="${FAIL_FOUND} require_secure_transport=OFF"
if grep -qiE "ENCRYPTION_SERVER=REQUIRED" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ENCRYPTION_SERVER=REQUIRED(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "FORCE_ENCRYPTION=1" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} FORCE_ENCRYPTION=1(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "require_secure_transport=ON" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} require_secure_transport=ON(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "rds.force_ssl=1" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} rds.force_ssl=1(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "ssl=on" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} ssl=on(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "SSL_ENABLE=1" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} SSL_ENABLE=1(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi
if grep -qiE "TLS" "${INPUT_DIR}/network_encryption.txt" 2>/dev/null; then PASS_FOUND="${PASS_FOUND} TLS(network_encryption.txt)"; PASS_COUNT=$((PASS_COUNT+1)); fi

if [[ -n "$FAIL_FOUND" ]]; then
    STATUS="FAIL"; REASON="취약 패턴 감지: ${FAIL_FOUND}"; EVIDENCE="입력 증적에서 취약 설정 발견"
elif [[ "$PASS_COUNT" -ge 2 ]]; then
    STATUS="PASS"; REASON="양호 패턴 ${PASS_COUNT}개 확인: ${PASS_FOUND}"; EVIDENCE="TLS/SSL 암호화 통신 강제 확인됨"
elif [[ "$PASS_COUNT" -eq 1 ]]; then
    STATUS="MANUAL_REVIEW"; REASON="단일 패턴만 확인 – 수동 검토 필요: ${PASS_FOUND}"; EVIDENCE="원본 증적 직접 확인 필요"
else
    STATUS="MANUAL_REVIEW"; REASON="통신 암호화 설정 수동 확인 필요"; EVIDENCE="증적 파일 존재하나 자동 판단 불가"
fi

echo "STATUS=${STATUS}"
echo "REASON=${REASON}"
echo "EVIDENCE=${EVIDENCE}"
exit 0
