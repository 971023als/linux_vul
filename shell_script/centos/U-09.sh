#!/bin/bash
# shell_script/centos/U-09.sh
# -----------------------------------------------------------------------------
# [U-09] /etc/hosts 파일 소유자 및 권한 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 호스트 이름 매핑 파일의 무단 수정을 방지하여 피싱 공격 예방
# -----------------------------------------------------------------------------

set -u

CODE="U-09"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/hosts 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/hosts"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c "%U" "$TARGET")
    PERMS=$(stat -c "%a" "$TARGET")
    
    if [ "$OWNER" != "root" ]; then
        RESULT="취약"
        STATUS="소유자가 root가 아닌 $OWNER 입니다."
    fi
    
    if [ "$PERMS" -gt 644 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }권한이 644보다 큰 $PERMS 입니다."
    fi
else
    STATUS="$TARGET 파일이 존재하지 않습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] "
    [ -z "$STATUS" ] && STATUS="[양호] $TARGET 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root ${TARGET} && chmod 644 ${TARGET} |

__MD_EOF__
