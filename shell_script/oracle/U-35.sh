#!/bin/bash
# shell_script/oracle/U-35.sh
# -----------------------------------------------------------------------------
# [U-35] 웹 서비스 디렉터리 리스팅 제거 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 디렉터리 내 파일 목록 노출을 차단하여 시스템 구조 및 주요 파일 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-35"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 디렉터리 리스팅 제거"

RESULT="양호"
STATUS=""

HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if [ -f "$HTTPD_CONF" ]; then
    if grep -r "Options" /etc/httpd/ 2>/dev/null | grep "Indexes" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에 디렉터리 리스팅(Indexes)이 활성화되어 있습니다."
    fi
fi

NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "$NGINX_CONF" ]; then
    if grep -r "autoindex" /etc/nginx/ 2>/dev/null | grep "on;" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 디렉터리 리스팅(autoindex)이 활성화되어 있습니다."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="웹 서비스 디렉터리 리스팅 기능이 비활성화되어 있거나 서비스가 실행 중이지 않습니다."
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
| 대응방안 | Apache(Indexes 제거), Nginx(autoindex off) 설정 변경 |

__MD_EOF__
