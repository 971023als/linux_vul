#!/bin/bash
# shell_script/oracle/U-29.sh
# -----------------------------------------------------------------------------
# [U-29] NIS 서비스 접근 제한 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: NIS 공유 시 인가된 호스트만 접근 가능하도록 제한하여 인증 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-29"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NIS 서비스 접근 제한"

RESULT="양호"
STATUS=""
TARGET="/var/yp/securenets"

if systemctl is-active --quiet ypserv 2>/dev/null; then
    if [ -f "$TARGET" ]; then
        if grep -v "^#" "$TARGET" | grep -E "[0-9]" > /dev/null; then
            STATUS="NIS 접근 제한 설정(securenets)이 정의되어 있습니다."
        else
            RESULT="취약"
            STATUS="securenets 파일은 존재하나 유효한 제한 정책이 설정되어 있지 않습니다."
        fi
    else
        RESULT="취약"
        STATUS="NIS 서비스를 사용 중이나 접근 제한 설정 파일($TARGET)이 존재하지 않습니다."
    fi
else
    STATUS="NIS 서비스를 사용하고 있지 않습니다(해당없음)."
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
| 대응방안 | /var/yp/securenets 파일에 허용할 네트워크/호스트 명시 |

__MD_EOF__
