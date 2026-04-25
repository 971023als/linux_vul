#!/bin/bash
# shell_script/centos/U-02.sh
# -----------------------------------------------------------------------------
# [U-02] 패스워드 복잡성 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제8조(비밀번호 관리), ISMS-P 2.5.1(사용자 식별)
# - 목적: 추측하기 어려운 복잡한 패스워드를 강제하여 무차별 대입 공격 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-02"
CATEGORY="계정 관리"
RISK="상"
ITEM="패스워드 복잡성 설정"

RESULT="양호"
STATUS=""

# RHEL 계열 PAM 설정 파일 (CentOS 7/8, Oracle 7/8/9)
PAM_AUTH="/etc/pam.d/system-auth"
[ ! -f "$PAM_AUTH" ] && PAM_AUTH="/etc/pam.d/password-auth"

if [ -f "$PAM_AUTH" ]; then
    # pam_pwquality.so 또는 pam_cracklib.so 모듈 확인
    if grep -qE "pam_pwquality.so|pam_cracklib.so" "$PAM_AUTH"; then
        # 세부 복잡성 옵션(minlen, dcredit, ucredit, lcredit, ocredit 등) 체크
        COMPLEXITY=$(grep -E "pam_pwquality.so|pam_cracklib.so" "$PAM_AUTH")
        if [[ "$COMPLEXITY" == *"minlen"* ]] && [[ "$COMPLEXITY" == *"credit"* ]]; then
            STATUS="패스워드 복잡성 설정 모듈이 활성화되어 있습니다."
        else
            RESULT="취약"
            STATUS="패스워드 복잡성 설정 모듈은 있으나 세부 옵션(minlen 등)이 부족합니다."
        fi
    else
        RESULT="취약"
        STATUS="패스워드 복잡성 설정 모듈(pam_pwquality 등)이 누락되었습니다."
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
| 대응방안 | /etc/pam.d/system-auth 에 pam_pwquality.so 설정 추가 |

__MD_EOF__
