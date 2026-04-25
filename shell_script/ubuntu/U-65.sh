#!/bin/bash
# shell_script/ubuntu/U-65.sh
# -----------------------------------------------------------------------------
# [U-65] SNMP 서비스 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: SNMP 설정 파일의 권한을 제한하여 Community String 등 주요 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-65"
CATEGORY="서비스 관리"
RISK="중"
ITEM="SNMP 서비스 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/snmp/snmpd.conf"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c "%U" "$TARGET")
    PERMS=$(stat -c "%a" "$TARGET")
    
    if [ "$OWNER" != "root" ]; then
        RESULT="취약"
        STATUS="소유자가 root가 아닌 $OWNER 입니다."
    fi
    
    # 640 이하 권고 (Community String 보호)
    if [ "$PERMS" -gt 640 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }권한이 640보다 큰 $PERMS 입니다."
    fi
else
    STATUS="SNMP 설정 파일($TARGET)이 존재하지 않습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    [ -z "$STATUS" ] && STATUS="[양호] SNMP 설정 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root ${TARGET} && chmod 640 ${TARGET} |

__MD_EOF__
