#!/bin/bash
# shell_script/ubuntu/U-48.sh
# -----------------------------------------------------------------------------
# [U-48] 패스워드 최소 사용 기간 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제8조(비밀번호 관리), ISMS-P 2.5.1(사용자 식별)
# - 목적: 패스워드 변경 후 즉시 다시 변경하는 행위를 방지하여 과거 패스워드 재사용 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-48"
CATEGORY="계정 관리"
RISK="중"
ITEM="패스워드 최소 사용 기간 설정"

RESULT="양호"
STATUS=""

# 1. /etc/login.defs 점검
LOGIN_DEFS="/etc/login.defs"
if [ -f "$LOGIN_DEFS" ]; then
    MIN_DAYS=$(grep "^PASS_MIN_DAYS" "$LOGIN_DEFS" | awk '{print $2}')
    if [ -n "$MIN_DAYS" ] && [ "$MIN_DAYS" -ge 1 ]; then
        STATUS="PASS_MIN_DAYS가 ${MIN_DAYS}일로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="PASS_MIN_DAYS가 1일 미만(${MIN_DAYS:-미설정})으로 설정되어 있습니다."
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
| 대응방안 | /etc/login.defs 에서 PASS_MIN_DAYS 1 설정 |

__MD_EOF__
