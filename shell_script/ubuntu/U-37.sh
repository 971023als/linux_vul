#!/bin/bash
# shell_script/ubuntu/U-37.sh
# -----------------------------------------------------------------------------
# [U-37] 웹서비스 에러 메시지 통제
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 에러 발생 시 출력되는 시스템 정보(버전, 경로 등)를 차단하여 정보 수집 공격 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-37"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 에러 메시지 통제"

RESULT="양호"
STATUS=""

# 1. Apache 점검
if [ -d "/etc/apache2" ]; then
    # ErrorDocument 설정 확인
    if ! grep -rEi "ErrorDocument" /etc/apache2/ 2>/dev/null | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에 커스텀 에러 페이지(ErrorDocument) 설정이 누락되어 있습니다."
    fi
fi

# 2. Nginx 점검
if [ -d "/etc/nginx" ]; then
    # error_page 설정 확인
    if ! grep -rEi "error_page" /etc/nginx/ 2>/dev/null | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 커스텀 에러 페이지(error_page) 설정이 누락되어 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 웹 서비스가 설치되어 있지 않거나 에러 메시지 통제 설정이 존재합니다."
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
| 대응방안 | 1. Apache: ErrorDocument 404 /error.html 설정<br>2. Nginx: error_page 404 /error.html 설정 |

__MD_EOF__
