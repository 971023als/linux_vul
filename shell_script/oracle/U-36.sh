#!/bin/bash
# shell_script/oracle/U-36.sh
# -----------------------------------------------------------------------------
# [U-36] 웹 서비스 프로세스 권한 제한 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 서비스가 하위 권한 계정으로 구동되도록 하여 시스템 침해 시 피해 확산 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-36"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 프로세스 권한 제한"

RESULT="양호"
STATUS=""

if pgrep -x "httpd" > /dev/null; then
    HTTPD_USER=$(ps -ef | grep -v "root" | grep "httpd" | awk '{print $1}' | head -n 1)
    if [ -z "$HTTPD_USER" ]; then
        RESULT="취약"
        STATUS="Apache(httpd) 프로세스가 root 권한으로 실행 중입니다."
    else
        STATUS="Apache(httpd) 프로세스가 하위 권한 계정($HTTPD_USER)으로 실행 중입니다."
    fi
fi

if pgrep -x "nginx" > /dev/null; then
    NGINX_USER=$(ps -ef | grep -v "root" | grep "nginx" | awk '{print $1}' | head -n 1)
    if [ -z "$NGINX_USER" ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 프로세스가 root 권한으로 실행 중입니다."
    else
        STATUS="${STATUS:+${STATUS} / }Nginx 프로세스가 하위 권한 계정($NGINX_USER)으로 실행 중입니다."
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
| 대응방안 | 웹 서버 설정 파일에서 구동 계정을 별도의 전용 계정(apache, nginx 등)으로 지정 |

__MD_EOF__
