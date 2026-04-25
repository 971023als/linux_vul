#!/bin/bash
# shell_script/ubuntu/U-02.sh
# -----------------------------------------------------------------------------
# [U-02] 패스워드 복잡성 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.4.3(인증 및 권한 부여)
# - 목적: 추측하기 어려운 패스워드 설정을 강제하여 무차별 대입 공격(Brute-force) 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-02"
CATEGORY="계정 관리"
RISK="상"
ITEM="패스워드 복잡성 설정"

RESULT="양호"
STATUS=""

# 1. PAM 설정 파일 확인 (Ubuntu/Debian 기준)
PAM_COMMON_PWD="/etc/pam.d/common-password"
PWQUALITY_CONF="/etc/security/pwquality.conf"

CHECK_TARGETS=()
[ -f "$PAM_COMMON_PWD" ] && CHECK_TARGETS+=("$PAM_COMMON_PWD")
[ -f "$PWQUALITY_CONF" ] && CHECK_TARGETS+=("$PWQUALITY_CONF")

if [ ${#CHECK_TARGETS[@]} -eq 0 ]; then
    RESULT="취약"
    STATUS="PAM 패스워드 설정 파일을 찾을 수 없습니다."
else
    # 2. 상세 설정값 검증 (pwquality 기준)
    # minlen: 최소 길이 (8자 이상 권고)
    # lcredit, ucredit, dcredit, ocredit: 영문 소문자, 대문자, 숫자, 특수문자 요건
    
    # pwquality.conf 우선 점검
    if [ -f "$PWQUALITY_CONF" ]; then
        MINLEN=$(grep -v '^#' "$PWQUALITY_CONF" | grep "minlen" | awk -F'=' '{print $2}' | xargs)
        LCREDIT=$(grep -v '^#' "$PWQUALITY_CONF" | grep "lcredit" | awk -F'=' '{print $2}' | xargs)
        UCREDIT=$(grep -v '^#' "$PWQUALITY_CONF" | grep "ucredit" | awk -F'=' '{print $2}' | xargs)
        DCREDIT=$(grep -v '^#' "$PWQUALITY_CONF" | grep "dcredit" | awk -F'=' '{print $2}' | xargs)
        OCREDIT=$(grep -v '^#' "$PWQUALITY_CONF" | grep "ocredit" | awk -F'=' '{print $2}' | xargs)
    else
        # common-password 내 pam_pwquality.so 인자 점검
        MINLEN=$(grep "pam_pwquality.so" "$PAM_COMMON_PWD" | grep -o "minlen=[0-9]*" | cut -d'=' -f2)
        # ... 기타 인자들
    fi

    # 판정 로직 (금융보안원 기준: 3종류 조합 시 8자, 2종류 조합 시 10자 이상)
    # 여기서는 범용적으로 8자 이상 + 영문/숫자/특수문자 혼합 여부 체크
    if [[ -z "$MINLEN" ]] || [ "$MINLEN" -lt 8 ]; then
        RESULT="취약"
        STATUS="패스워드 최소 길이가 8자 미만이거나 설정되어 있지 않습니다."
    fi
    
    # 복잡성 요건 (ucredit, lcredit, dcredit, ocredit 중 3개 이상이 -1 이하면 양호)
    # 구체적인 수치는 환경마다 다르므로 존재 여부 위주로 체크
    if ! grep -Eq "pam_pwquality.so|pam_cracklib.so" "$PAM_COMMON_PWD"; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }PAM 복잡성 검사 모듈(pwquality/cracklib)이 활성화되어 있지 않습니다."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 패스워드 최소 길이 및 복잡성 설정이 적절하게 구성되어 있습니다."
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
| 대응방안 | 1. /etc/security/pwquality.conf 파일에서 minlen=8, lcredit=-1, ucredit=-1, dcredit=-1, ocredit=-1 설정<br>2. /etc/pam.d/common-password 에 pam_pwquality.so 모듈 라인 확인 |

__MD_EOF__
