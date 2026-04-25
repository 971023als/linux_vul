#!/bin/bash
# shell_script/ubuntu/U-66.sh
# -----------------------------------------------------------------------------
# [U-66] 로그 파일 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 로그 파일의 권한을 제한하여 비인가된 사용자의 로그 변조 및 삭제 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-66"
CATEGORY="로그 관리"
RISK="중"
ITEM="로그 파일 권한 설정"

RESULT="양호"
STATUS=""

# 1. 점검 대상 주요 로그 파일
LOG_FILES=("/var/log/auth.log" "/var/log/syslog" "/var/log/messages" "/var/log/secure" "/var/log/lastlog" "/var/log/wtmp")
VULN_STATUS=""

for LOG in "${LOG_FILES[@]}"; do
    if [ -f "$LOG" ]; then
        OWNER=$(stat -c "%U" "$LOG")
        PERMS=$(stat -c "%a" "$LOG")
        
        # 소유자 root 또는 syslog, 권한 640 이하 권고
        if [[ "$OWNER" != "root" && "$OWNER" != "syslog" ]] || [ "$PERMS" -gt 640 ]; then
            VULN_STATUS="${VULN_STATUS}${LOG}(${OWNER}, ${PERMS}) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 주요 로그 파일의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="[취약] 다음 로그 파일의 설정이 부적절합니다: ${VULN_STATUS}"
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
| 대응방안 | 주요 로그 파일의 소유자를 root로 변경하고 권한을 640 이하로 설정 |

__MD_EOF__
