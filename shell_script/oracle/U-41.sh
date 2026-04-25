#!/bin/bash
# shell_script/oracle/U-41.sh
# -----------------------------------------------------------------------------
# [U-41] 웹 서비스 Custom Error Page 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 오류 발생 시 시스템 정보(OS, 웹 서버 버전 등) 노출을 방지하기 위해 사용자 정의 에러 페이지 사용
# -----------------------------------------------------------------------------

set -u

CODE="U-41"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 Custom Error Page 설정"

RESULT="양호"
STATUS=""

HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if [ -f "$HTTPD_CONF" ]; then
    if grep -r "ErrorDocument" /etc/httpd/ 2>/dev/null | grep -v "^#" > /dev/null; then
        STATUS="Apache 설정에 Custom Error Page(ErrorDocument)가 정의되어 있습니다."
    else
        RESULT="취약"
        STATUS="Apache 설정에 Custom Error Page 설정이 누락되어 있습니다(정보 유출 위험)."
    fi
fi

NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "$NGINX_CONF" ]; then
    if grep -r "error_page" /etc/nginx/ 2>/dev/null | grep -v "^#" > /dev/null; then
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 Custom Error Page(error_page)가 정의되어 있습니다."
    else
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 Custom Error Page 설정이 누락되어 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="웹 서비스가 실행 중이지 않습니다."
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
| 대응방안 | Apache(ErrorDocument), Nginx(error_page) 설정을 통해 커스텀 에러 페이지 지정 |

__MD_EOF__
