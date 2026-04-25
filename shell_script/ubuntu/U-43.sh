#!/bin/bash
# shell_script/ubuntu/U-43.sh
# -----------------------------------------------------------------------------
# [U-43] 로그의 정기적 검토 및 보고
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 이상 징후를 조기에 발견하고 사고 발생 시 추적성을 확보하기 위한 로그 관리 상태 점검
# -----------------------------------------------------------------------------

set -u

CODE="U-43"
CATEGORY="로그 관리"
RISK="상"
ITEM="로그의 정기적 검토 및 보고"

RESULT="양호"
STATUS=""

# 1. 주요 로그 파일 존재 및 최신 업데이트 여부 확인
LOG_FILES=("/var/log/auth.log" "/var/log/syslog" "/var/log/messages" "/var/log/secure")
LOG_FOUND=false
STALE_LOGS=""

for LOG in "${LOG_FILES[@]}"; do
    if [ -f "$LOG" ]; then
        LOG_FOUND=true
        # 마지막 수정 시간이 7일 이상 된 경우 점검 필요로 간주
        LAST_MOD=$(stat -c "%Y" "$LOG")
        NOW=$(date +%s)
        if [ $(( (NOW - LAST_MOD) / 86400 )) -gt 7 ]; then
            STALE_LOGS="${STALE_LOGS}${LOG} "
        fi
    fi
done

if ! $LOG_FOUND; then
    RESULT="취약"
    STATUS="주요 시스템 로그 파일이 존재하지 않습니다."
elif [ -n "$STALE_LOGS" ]; then
    RESULT="취약"
    STATUS="일부 로그 파일이 장기간 업데이트되지 않았습니다: ${STALE_LOGS}"
else
    STATUS="주요 로그 파일이 정상적으로 기록되고 있습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] ${STATUS}"
else
    STATUS="[취약] ${STATUS}"
fi

# ==== 표준 출력 (Markdown) ====
cat << __MD_EOF__
# ${CODE}: ${ITEM}

| 항목 | 내용 |
|------|------|
| 분류 | ${CATEGORY} |
| 코드 | ${CODE} |
| 위험도 | ${RISK} |
| 진단항목 | ${ITEM} |
| 진단결과 | ${RESULT} |
| 현황 | ${STATUS} |
| 대응방안 | 주요 로그 파일의 존재 여부 및 최신 기록 여부를 정기적으로 점검 |
__MD_EOF__
