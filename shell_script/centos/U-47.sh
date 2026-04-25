#!/bin/bash
# shell_script/centos/U-47.sh
# -----------------------------------------------------------------------------
# [U-47] 패스워드 최대 사용 기간 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.4(비밀번호 관리)
# - 목적: 패스워드를 정기적으로 변경하게 하여 탈취된 패스워드의 사용 기간 단축
# -----------------------------------------------------------------------------

set -u

CODE="U-47"
CATEGORY="계정 관리"
RISK="중"
ITEM="패스워드 최대 사용 기간 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/login.defs"

# 1. login.defs 점검
if [ -f "$TARGET" ]; then
    MAX_DAYS=$(grep "^PASS_MAX_DAYS" "$TARGET" | awk '{print $2}')
    if [ -n "$MAX_DAYS" ] && [ "$MAX_DAYS" -le 90 ]; then
        STATUS="PASS_MAX_DAYS 가 ${MAX_DAYS}일로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="PASS_MAX_DAYS 가 설정되어 있지 않거나 90일을 초과합니다."
    fi
    
    # 추가: PASS_MIN_DAYS 확인 (변경 최소 간격)
    MIN_DAYS=$(grep "^PASS_MIN_DAYS" "$TARGET" | awk '{print $2}')
    if [ -n "$MIN_DAYS" ] && [ "$MIN_DAYS" -ge 1 ]; then
        STATUS="${STATUS} / PASS_MIN_DAYS=${MIN_DAYS} 적용됨."
    fi
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
| 대응방안 | /etc/login.defs 에서 PASS_MAX_DAYS 를 90 이하로 설정 |

__MD_EOF__
