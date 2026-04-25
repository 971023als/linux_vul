#!/bin/bash
# shell_script/centos/U-46.sh
# -----------------------------------------------------------------------------
# [U-46] 패스워드 최소 길이 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.4(비밀번호 관리)
# - 목적: 짧은 패스워드 사용을 금지하여 무차별 대입 공격(Brute Force) 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-46"
CATEGORY="계정 관리"
RISK="중"
ITEM="패스워드 최소 길이 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/login.defs"

# 1. login.defs 점검
if [ -f "$TARGET" ]; then
    MIN_LEN=$(grep "^PASS_MIN_LEN" "$TARGET" | awk '{print $2}')
    if [ -n "$MIN_LEN" ] && [ "$MIN_LEN" -ge 8 ]; then
        STATUS="PASS_MIN_LEN 이 ${MIN_LEN}으로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="PASS_MIN_LEN 이 설정되어 있지 않거나 8 미만입니다."
    fi
fi

# 2. PAM 설정(pwquality) 교차 점검 (RHEL 7 이상 표준)
PAM_AUTH="/etc/pam.d/system-auth"
if [ -f "$PAM_AUTH" ]; then
    if grep -q "pam_pwquality.so" "$PAM_AUTH"; then
        PWQ_LEN=$(grep "pam_pwquality.so" "$PAM_AUTH" | grep -o "minlen=[0-9]*" | cut -d= -f2)
        if [ -n "$PWQ_LEN" ] && [ "$PWQ_LEN" -ge 8 ]; then
            STATUS="${STATUS} / PAM 설정에 minlen=${PWQ_LEN} 이 적용되어 있습니다."
            RESULT="양호" # PAM 설정이 우선하므로 양호로 판단 가능
        fi
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
| 대응방안 | /etc/login.defs 또는 PAM 설정에서 패스워드 최소 길이를 8자 이상으로 설정 |

__MD_EOF__
