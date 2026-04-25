#!/bin/bash
# shell_script/centos/U-03.sh
# -----------------------------------------------------------------------------
# [U-03] 계정 잠금 임계값 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제8조(비밀번호 관리), ISMS-P 2.5.1(사용자 식별)
# - 목적: 무차별 대입 공격(Brute-force) 발생 시 계정을 잠금 처리하여 추가 시도 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-03"
CATEGORY="계정 관리"
RISK="상"
ITEM="계정 잠금 임계값 설정"

RESULT="양호"
STATUS=""

# RHEL 계열 PAM 설정 파일
PAM_AUTH="/etc/pam.d/system-auth"
[ ! -f "$PAM_AUTH" ] && PAM_AUTH="/etc/pam.d/password-auth"

if [ -f "$PAM_AUTH" ]; then
    # pam_faillock (CentOS 8+) 또는 pam_tally2 (CentOS 7) 확인
    if grep -qE "pam_faillock.so|pam_tally2.so" "$PAM_AUTH"; then
        LOCK_CONFIG=$(grep -E "pam_faillock.so|pam_tally2.so" "$PAM_AUTH")
        # deny=5 이하 권고
        if [[ "$LOCK_CONFIG" == *"deny="* ]]; then
            STATUS="계정 잠금 임계값 설정 모듈이 활성화되어 있습니다."
        else
            RESULT="취약"
            STATUS="잠금 모듈은 있으나 임계값(deny) 설정이 누락되었습니다."
        fi
    else
        RESULT="취약"
        STATUS="계정 잠금 설정 모듈(pam_faillock 등)이 누락되었습니다."
    fi
else
    RESULT="취약"
    STATUS="PAM 설정 파일($PAM_AUTH)을 찾을 수 없습니다."
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
| 대응방안 | /etc/pam.d/system-auth 에 pam_faillock.so auth/account 설정 추가 |

__MD_EOF__
