#!/bin/bash
# shell_script/ubuntu/U-22.sh
# -----------------------------------------------------------------------------
# [U-22] cron 파일 소유자 및 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 예약 작업 설정 파일의 무단 수정을 방지하여 악성 스크립트 실행 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-22"
CATEGORY="서비스 관리"
RISK="상"
ITEM="cron 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""

# 점검 대상 리스트
CRON_FILES=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
VULN_FILES=""

for FILE in "${CRON_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE")
        PERMS=$(stat -c "%a" "$FILE")
        # 소유자 root 확인 및 권한 600 이하 확인 (Ubuntu 기본은 644일 수 있으나 600 권고)
        if [ "$OWNER" != "root" ] || [ "$PERMS" -gt 640 ]; then
            VULN_FILES="${VULN_FILES}${FILE} (Owner: $OWNER, Perm: $PERMS)\n"
            RESULT="취약"
        fi
    fi
done

# cron 디렉터리 권한 확인
CRON_DIRS=("/etc/cron.d" "/etc/cron.daily" "/etc/cron.hourly" "/etc/cron.monthly" "/etc/cron.weekly")
for DIR in "${CRON_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        OWNER=$(stat -c "%U" "$DIR")
        PERMS=$(stat -c "%a" "$DIR")
        if [ "$OWNER" != "root" ] || [ "${PERMS:2:1}" -gt 0 ]; then
            VULN_FILES="${VULN_FILES}${DIR} (Owner: $OWNER, Perm: $PERMS)\n"
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] cron 관련 파일 및 디렉터리의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="[취약] 다음 항목들의 설정이 부적절합니다:\n${VULN_FILES}"
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
| 대응방안 | 소유자를 root로 변경하고 일반 사용자 쓰기 권한 제거 (chmod 600 [FILE]) |

__MD_EOF__
