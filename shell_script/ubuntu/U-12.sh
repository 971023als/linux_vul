#!/bin/bash
# shell_script/ubuntu/U-12.sh
# -----------------------------------------------------------------------------
# [U-12] /etc/services 파일 소유자 및 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 서비스 포트 매핑 정보의 무단 수정을 방지하여 서비스 오용 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-12"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/services 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/services"

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
    RESULT="취약"
    STATUS="$TARGET 파일을 찾을 수 없습니다."
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
| 대응방안 | chown root ${TARGET} && chmod 644 ${TARGET} |

__MD_EOF__
