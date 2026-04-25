#!/bin/bash
# shell_script/ubuntu/U-47.sh
# -----------------------------------------------------------------------------
# [U-47] 패스워드 최대 사용 기간 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제8조(비밀번호 관리), ISMS-P 2.5.1(사용자 식별)
# - 목적: 패스워드를 정기적으로 변경하게 하여 유출된 패스워드의 재사용 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-47"
CATEGORY="계정 관리"
RISK="중"
ITEM="패스워드 최대 사용 기간 설정"

RESULT="양호"
STATUS=""

# 1. /etc/login.defs 점검
LOGIN_DEFS="/etc/login.defs"
if [ -f "$LOGIN_DEFS" ]; then
    MAX_DAYS=$(grep "^PASS_MAX_DAYS" "$LOGIN_DEFS" | awk '{print $2}')
    if [ -n "$MAX_DAYS" ] && [ "$MAX_DAYS" -le 90 ]; then
        STATUS="PASS_MAX_DAYS가 ${MAX_DAYS}일로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="PASS_MAX_DAYS가 90일보다 크거나 미설정(${MAX_DAYS:-미설정})되어 있습니다."
    fi
else
    RESULT="취약"
    STATUS="/etc/login.defs 파일을 찾을 수 없습니다."
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
| 대응방안 | /etc/login.defs 에서 PASS_MAX_DAYS 90 설정 |

__MD_EOF__
