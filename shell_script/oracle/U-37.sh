#!/bin/bash
# shell_script/oracle/U-37.sh
# -----------------------------------------------------------------------------
# [U-37] 웹 서비스 상위 디렉터리 접근 제한 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 루트 외부의 시스템 파일에 접근하는 경로 탐색 공격 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-37"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 상위 디렉터리 접근 제한"

RESULT="양호"
STATUS=""

HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if [ -f "$HTTPD_CONF" ]; then
    if grep -r "AllowOverride" /etc/httpd/ 2>/dev/null | grep -qi "None"; then
        STATUS="Apache 설정에 AllowOverride None이 적용되어 있습니다."
    fi
    if grep -r "Options" /etc/httpd/ 2>/dev/null | grep -qi "FollowSymLinks"; then
        STATUS="${STATUS:+${STATUS} / }FollowSymLinks 옵션이 활성화되어 있습니다(점검 권고)."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="웹 서비스가 실행 중이지 않거나 설정이 기본 상태입니다."
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
| 대응방안 | 웹 설정에서 AllowOverride None 및 불필요한 심볼릭 링크 허용 제거 |

__MD_EOF__
