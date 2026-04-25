#!/bin/bash
# shell_script/centos/U-54.sh
# -----------------------------------------------------------------------------
# [U-54] Session Timeout 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 유휴 세션을 자동으로 종료하여 비인가 사용자의 세션 탈취 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-54"
CATEGORY="계정 관리"
RISK="하"
ITEM="Session Timeout 설정"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 전역 설정 파일 확인
CHECK_FILES=("/etc/profile" "/etc/bashrc")
TMOUT_VAL=""

for FILE in "${CHECK_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        VAL=$(grep "TMOUT=" "$FILE" | grep -v "^#" | cut -d= -f2 | tail -n 1)
        if [ -n "$VAL" ]; then
            TMOUT_VAL=$VAL
            break
        fi
    fi
done

if [ -n "$TMOUT_VAL" ]; then
    # TMOUT 값이 600초(10분) 이하인지 확인
    if [ "$TMOUT_VAL" -le 600 ] && [ "$TMOUT_VAL" -gt 0 ]; then
        STATUS="Session Timeout 이 ${TMOUT_VAL}초로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="Session Timeout 설정값이 600초를 초과합니다: ${TMOUT_VAL}"
    fi
else
    RESULT="취약"
    STATUS="전역 설정 파일(/etc/profile 등)에 TMOUT 설정이 존재하지 않습니다."
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
| 대응방안 | /etc/profile 또는 /etc/bashrc 에 TMOUT=600 및 export TMOUT 추가 |

__MD_EOF__
