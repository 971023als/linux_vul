#!/bin/bash
# shell_script/ubuntu/U-40.sh
# -----------------------------------------------------------------------------
# [U-40] 웹서비스 파일 업로드 및 다운로드 제한
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 대용량 파일 업로드를 통한 DoS 공격 및 악성 파일 업로드 위험 최소화
# -----------------------------------------------------------------------------

set -u

CODE="U-40"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 파일 업로드 및 다운로드 제한"

RESULT="양호"
STATUS=""

# 1. Apache 점검 (LimitRequestBody)
if [ -d "/etc/apache2" ]; then
    if ! grep -rEi "LimitRequestBody" /etc/apache2/ 2>/dev/null | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에 파일 업로드 크기 제한(LimitRequestBody) 설정이 누락되어 있습니다."
    fi
fi

# 2. Nginx 점검 (client_max_body_size)
if [ -d "/etc/nginx" ]; then
    if ! grep -rEi "client_max_body_size" /etc/nginx/ 2>/dev/null | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Nginx 설정에 파일 업로드 크기 제한(client_max_body_size) 설정이 누락되어 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 웹 서비스가 설치되어 있지 않거나 파일 업로드 제한 설정이 존재합니다."
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
| 대응방안 | 1. Apache: LimitRequestBody 5000000 (5MB 제한 예시) 설정<br>2. Nginx: client_max_body_size 5M 설정 |

__MD_EOF__
