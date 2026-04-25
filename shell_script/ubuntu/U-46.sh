#!/bin/bash
# shell_script/ubuntu/U-46.sh
# -----------------------------------------------------------------------------
# [U-46] 패스워드 최소 길이 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제8조(비밀번호 관리), ISMS-P 2.5.1(사용자 식별)
# - 목적: 짧은 패스워드 사용을 금지하여 무차별 대입 공격에 의한 계정 탈취 예방
# -----------------------------------------------------------------------------

set -u

CODE="U-46"
CATEGORY="계정 관리"
RISK="중"
ITEM="패스워드 최소 길이 설정"

RESULT="양호"
STATUS=""

# 1. /etc/login.defs 점검
LOGIN_DEFS="/etc/login.defs"
if [ -f "$LOGIN_DEFS" ]; then
    MIN_LEN=$(grep "^PASS_MIN_LEN" "$LOGIN_DEFS" | awk '{print $2}')
    if [ -n "$MIN_LEN" ] && [ "$MIN_LEN" -ge 8 ]; then
        STATUS="login.defs 에 PASS_MIN_LEN이 ${MIN_LEN}으로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="login.defs 에 PASS_MIN_LEN이 8자 미만(${MIN_LEN:-미설정})으로 설정되어 있습니다."
    fi
fi

# 2. PAM 설정 점검 (Ubuntu는 주로 common-password의 pam_pwquality 사용)
PAM_PW="/etc/pam.d/common-password"
if [ -f "$PAM_PW" ]; then
    PAM_MINLEN=$(grep "pam_pwquality.so" "$PAM_PW" | grep -o "minlen=[0-9]*" | cut -d= -f2)
    if [ -n "$PAM_MINLEN" ] && [ "$PAM_MINLEN" -ge 8 ]; then
        STATUS="${STATUS} / PAM 설정에 minlen이 ${PAM_MINLEN}으로 설정되어 있습니다."
        RESULT="양호" # login.defs가 낮더라도 PAM이 우선하면 양호로 판단 가능
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
| 대응방안 | /etc/login.defs 또는 /etc/pam.d/common-password 에서 최소 길이 8자 이상 설정 |

__MD_EOF__
