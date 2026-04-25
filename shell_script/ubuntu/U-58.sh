#!/bin/bash
# shell_script/ubuntu/U-58.sh
# -----------------------------------------------------------------------------
# [U-58] SSH 서비스 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: SSH 설정 파일의 무단 수정을 방지하여 비인가 접근 및 서비스 설정 변경 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-58"
CATEGORY="서비스 관리"
RISK="상"
ITEM="SSH 서비스 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/ssh/sshd_config"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c "%U" "$TARGET")
    PERMS=$(stat -c "%a" "$TARGET")
    
    if [ "$OWNER" != "root" ]; then
        RESULT="취약"
        STATUS="소유자가 root가 아닌 $OWNER 입니다."
    fi
    
    if [ "$PERMS" -gt 600 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }권한이 600보다 큰 $PERMS 입니다."
    fi
else
    RESULT="취약"
    STATUS="SSH 설정 파일($TARGET)을 찾을 수 없습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $TARGET 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root ${TARGET} && chmod 600 ${TARGET} |

__MD_EOF__
