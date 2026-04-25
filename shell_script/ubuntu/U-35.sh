#!/bin/bash
# shell_script/ubuntu/U-35.sh
# -----------------------------------------------------------------------------
# [U-35] 웹서비스 디렉토리 리스팅 제거
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 서버의 디렉토리 구조 및 내부 파일 정보 노출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-35"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 디렉토리 리스팅 제거"

RESULT="양호"
STATUS=""

# 1. Apache 점검
if [ -d "/etc/apache2" ]; then
    # Options Indexes 설정 확인
    if grep -rEi "Options\s+.*Indexes" /etc/apache2/ 2>/dev/null | grep -vEi "\-Indexes" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에서 디렉토리 리스팅(Indexes)이 허용되어 있습니다."
    fi
fi

# 2. Nginx 점검
if [ -d "/etc/nginx" ]; then
    # autoindex on 설정 확인
    if grep -rEi "autoindex\s+on" /etc/nginx/ 2>/dev/null | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에서 디렉토리 리스팅(autoindex on)이 허용되어 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 웹 서비스가 설치되어 있지 않거나 디렉토리 리스팅이 적절히 차단되어 있습니다."
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
| 대응방안 | 1. Apache: Options -Indexes 설정<br>2. Nginx: autoindex off 설정 |

__MD_EOF__
