#!/bin/bash
# shell_script/ubuntu/U-03.sh
# -----------------------------------------------------------------------------
# [U-03] 계정 잠금 임계값 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.4.3(인증 및 권한 부여)
# - 목적: 패스워드 무차별 대입 공격(Brute-force) 시 계정을 자동 잠금하여 시스템 보호
# -----------------------------------------------------------------------------

set -u

CODE="U-03"
CATEGORY="계정 관리"
RISK="상"
ITEM="계정 잠금 임계값 설정"

RESULT="양호"
STATUS=""

# 1. PAM 설정 파일 확인 (Ubuntu/Debian 기준)
# Ubuntu 20.04+ 에서는 pam_faillock.so 를 권장하며 common-auth 에 설정함
PAM_COMMON_AUTH="/etc/pam.d/common-auth"

if [ ! -f "$PAM_COMMON_AUTH" ]; then
    RESULT="취약"
    STATUS="PAM 인증 설정 파일($PAM_COMMON_AUTH)을 찾을 수 없습니다."
else
    # 2. 계정 잠금 모듈 및 임계값(deny) 확인
    # pam_faillock.so 또는 pam_tally2.so 확인
    LOCK_MODULE=$(grep -E "pam_faillock.so|pam_tally2.so" "$PAM_COMMON_AUTH" | grep -v "^#" | head -n 1)
    
    if [ -z "$LOCK_MODULE" ]; then
        RESULT="취약"
        STATUS="계정 잠금 모듈(pam_faillock 또는 pam_tally2)이 설정되어 있지 않습니다."
    else
        # deny 값 추출
        DENY_VAL=$(echo "$LOCK_MODULE" | grep -oP 'deny=\K\d+')
        
        if [ -z "$DENY_VAL" ]; then
            RESULT="취약"
            STATUS="계정 잠금 임계값(deny)이 명시되어 있지 않습니다."
        elif [ "$DENY_VAL" -gt 10 ]; then
            RESULT="취약"
            STATUS="계정 잠금 임계값이 10회를 초과($DENY_VAL회)하여 설정되어 있습니다."
        else
            STATUS="계정 잠금 임계값이 $DENY_VAL회로 적절히 설정되어 있습니다."
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
| 대응방안 | 1. /etc/pam.d/common-auth 파일에 auth required pam_faillock.so preauth silent deny=5 unlock_time=900 등 추가<br>2. auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900 등 추가 |

__MD_EOF__
