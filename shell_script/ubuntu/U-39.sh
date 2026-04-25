#!/bin/bash
# shell_script/ubuntu/U-39.sh
# -----------------------------------------------------------------------------
# [U-39] 웹서비스 링크 사용 금지
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 루트 외부의 시스템 파일에 대한 심볼릭 링크 접근을 차단하여 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-39"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 링크 사용 금지"

RESULT="양호"
STATUS=""

# 1. Apache 점검 (FollowSymLinks 옵션 확인)
if [ -d "/etc/apache2" ]; then
    if grep -rEi "Options\s+.*FollowSymLinks" /etc/apache2/ 2>/dev/null | grep -vEi "\-FollowSymLinks" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에서 심볼릭 링크 사용(FollowSymLinks)이 허용되어 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 웹 서비스가 설치되어 있지 않거나 심볼릭 링크 사용이 적절히 제한되어 있습니다."
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
| 대응방안 | Apache 설정에서 Options -FollowSymLinks 로 변경 |

__MD_EOF__
