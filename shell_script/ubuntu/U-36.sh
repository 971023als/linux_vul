#!/bin/bash
# shell_script/ubuntu/U-36.sh
# -----------------------------------------------------------------------------
# [U-36] 웹서비스 상위 디렉토리 접근 금지
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 서버 설정 오류를 이용한 시스템 파일(상위 디렉토리) 접근 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-36"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 상위 디렉토리 접근 금지"

RESULT="양호"
STATUS=""

# 1. Apache 점검
if [ -d "/etc/apache2" ]; then
    # AllowOverride None 확인 및 FollowSymLinks 제한 점검
    # 보안 가이드상 AllowOverride None 을 권고함 (사용자 개별 설정 방지)
    if grep -rEi "AllowOverride" /etc/apache2/ 2>/dev/null | grep -qi "All" | grep -v "^#" > /dev/null; then
        RESULT="취약"
        STATUS="Apache 설정에서 AllowOverride 가 All 로 설정되어 있어 개별적인 설정 조작이 가능합니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 웹 서비스 상위 디렉토리 접근 제한 설정이 적절하거나 웹 서비스가 없습니다."
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
| 대응방안 | 1. Apache: AllowOverride None 설정<br>2. 심볼릭 링크 추적 방지 (Options -FollowSymLinks) |

__MD_EOF__
