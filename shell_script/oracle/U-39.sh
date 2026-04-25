#!/bin/bash
# shell_script/oracle/U-39.sh
# -----------------------------------------------------------------------------
# [U-39] 웹 서비스 링크 사용 금지 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 심볼릭 링크를 통해 웹 루트 외부의 시스템 파일에 접근하는 것을 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-39"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 링크 사용 금지"

RESULT="양호"
STATUS=""

HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if [ -f "$HTTPD_CONF" ]; then
    if grep -r "Options" /etc/httpd/ 2>/dev/null | grep -i "FollowSymLinks" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에 심볼릭 링크 사용(FollowSymLinks)이 허용되어 있습니다."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="웹 서비스에서 심볼릭 링크 사용이 적절히 제한되어 있거나 서비스가 미사용 중입니다."
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
| 대응방안 | Apache 설정(httpd.conf)에서 Options -FollowSymLinks 로 변경 |

__MD_EOF__
