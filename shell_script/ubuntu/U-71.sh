#!/bin/bash
# shell_script/ubuntu/U-71.sh
# -----------------------------------------------------------------------------
# [U-71] 홈 디렉터리로 지정되지 않은 계정 금지
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 홈 디렉터리가 비정상적인 계정을 식별하여 좀비 계정 및 관리되지 않는 계정 정리
# -----------------------------------------------------------------------------

set -u

CODE="U-71"
CATEGORY="계정 관리"
RISK="하"
ITEM="홈 디렉터리로 지정되지 않은 계정 금지"

RESULT="양호"
STATUS=""
VULN_ACCOUNTS=""

# 1. 일반 사용자(UID 1000 이상) 중 홈 디렉터리가 없거나 / 인 계정 확인
while IFS=: read -r USER_NAME _ UID_VAL _ _ HOME_DIR _; do
    if [ "$UID_VAL" -ge 1000 ] && [ "$USER_NAME" != "nobody" ]; then
        if [ ! -d "$HOME_DIR" ] || [ "$HOME_DIR" == "/" ]; then
            VULN_ACCOUNTS="${VULN_ACCOUNTS}${USER_NAME} "
            RESULT="취약"
        fi
    fi
done < /etc/passwd

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 일반 계정에 대해 정상적인 홈 디렉터리가 지정되어 있습니다."
else
    STATUS="다음 계정들의 홈 디렉터리 설정이 부적절합니다: ${VULN_ACCOUNTS}"
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
| 대응방안 | 불필요한 계정 삭제 또는 정상적인 홈 디렉터리 생성 및 할당 |

__MD_EOF__
