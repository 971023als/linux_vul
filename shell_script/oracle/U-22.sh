#!/bin/bash
# shell_script/oracle/U-22.sh
# -----------------------------------------------------------------------------
# [U-22] cron 파일 소유자 및 권한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 예약 작업 설정 파일의 무단 수정을 방지하여 악성 스크립트 실행 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-22"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="cron 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""

CRON_FILES=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
VULN_STATUS=""

for FILE in "${CRON_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE")
        PERMS=$(stat -c "%a" "$FILE")
        
        if [ "$OWNER" != "root" ] || [ "$PERMS" -gt 640 ]; then
            VULN_STATUS="${VULN_STATUS}${FILE}(${OWNER}, ${PERMS}) "
            RESULT="취약"
        fi
    fi
done

CRON_DIRS=("/etc/cron.d" "/etc/cron.daily" "/etc/cron.hourly" "/etc/cron.monthly" "/etc/cron.weekly")
for DIR in "${CRON_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        DIR_OWNER=$(stat -c "%U" "$DIR")
        DIR_PERMS=$(stat -c "%a" "$DIR")
        if [ "$DIR_OWNER" != "root" ] || [ "$DIR_PERMS" -gt 700 ]; then
            VULN_STATUS="${VULN_STATUS}${DIR}(${DIR_OWNER}, ${DIR_PERMS}) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 cron 관련 파일 및 디렉터리의 소유자/권한 설정이 적절합니다."
else
    STATUS="다음 cron 파일/디렉터리의 설정이 부적절합니다: ${VULN_STATUS}"
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
else
    STATUS="[취약] $STATUS"
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
| 진단결과 | **${RESULT}** |
| 현황 | ${STATUS} |
| 대응방안 | cron 관련 파일의 소유자를 root로 변경하고 권한을 640 이하로 설정 |

__MD_EOF__
