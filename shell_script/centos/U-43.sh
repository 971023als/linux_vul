#!/bin/bash
# shell_script/centos/U-43.sh
# -----------------------------------------------------------------------------
# [U-43] 로그 파일의 정기적 점검 및 보존 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 로그 파일의 기록 여부를 확인하여 시스템 이상 징후 조기 발견 및 사후 분석 증거 확보
# -----------------------------------------------------------------------------

set -u

CODE="U-43"
CATEGORY="로그 관리"
RISK="상"
ITEM="로그 파일의 정기적 점검 및 보존"

RESULT="양호"
STATUS=""

# 1. RHEL 주요 로그 파일 리스트
LOG_FILES=("/var/log/messages" "/var/log/secure" "/var/log/maillog" "/var/log/cron" "/var/log/boot.log")
VULN_STATUS=""

for LOG in "${LOG_FILES[@]}"; do
    if [ -f "$LOG" ]; then
        # 마지막 수정 시간이 7일(168시간) 이상 경과했는지 확인 (로그 중단 여부)
        LAST_MOD=$(stat -c %Y "$LOG")
        NOW=$(date +%s)
        DIFF=$(( (NOW - LAST_MOD) / 3600 ))

        if [ "$DIFF" -gt 168 ]; then
            VULN_STATUS="${VULN_STATUS}${LOG}(${DIFF}시간 경과) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 주요 로그 파일이 최근(7일 이내)까지 기록되고 있습니다."
else
    STATUS="다음 로그 파일들의 기록이 중단된 것으로 보입니다: ${VULN_STATUS}"
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
