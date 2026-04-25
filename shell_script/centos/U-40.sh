#!/bin/bash
# shell_script/centos/U-40.sh
# -----------------------------------------------------------------------------
# [U-40] 웹 서비스 파일 업로드 및 다운로드 제한 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 대용량 파일 업로드/다운로드를 제한하여 시스템 자원 고갈 및 DoS 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-40"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 파일 업로드 및 다운로드 제한"

RESULT="양호"
STATUS=""

# 1. Apache(httpd) 점검
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if [ -f "$HTTPD_CONF" ]; then
    # LimitRequestBody 설정 확인 (기본값 0: 무제한)
    if grep -r "LimitRequestBody" /etc/httpd/ 2>/dev/null | grep -v "^#" > /dev/null; then
        STATUS="Apache 설정에 LimitRequestBody(업로드 용량 제한)가 적용되어 있습니다."
    else
        RESULT="취약"
        STATUS="Apache 설정에 LimitRequestBody 설정이 누락되어 있습니다(무제한 허용 위험)."
    fi
fi

# 2. Nginx 점검
NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "$NGINX_CONF" ]; then
    if grep -r "client_max_body_size" /etc/nginx/ 2>/dev/null | grep -v "^#" > /dev/null; then
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 client_max_body_size 가 적용되어 있습니다."
    else
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 client_max_body_size 설정이 누락되어 있습니다."
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
| 대응방안 | Apache(LimitRequestBody), Nginx(client_max_body_size) 설정 추가 |

__MD_EOF__
