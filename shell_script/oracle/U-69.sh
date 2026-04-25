#!/bin/bash
# shell_script/oracle/U-69.sh
# -----------------------------------------------------------------------------
# [U-69] 홈 디렉터리 존재 여부 점검 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 존재하지 않는 홈 디렉터리를 가진 계정을 식별하여 비정상 계정 정리
# -----------------------------------------------------------------------------

set -u

CODE="U-69"
CATEGORY="계정 관리"
RISK="중"
ITEM="홈 디렉터리 존재 여부 점검"

RESULT="양호"
STATUS=""
VULN_ACCOUNTS=""

USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1":"$6}' /etc/passwd)

for USER_DATA in $USERS; do
    U_NAME=$(echo "$USER_DATA" | cut -d: -f1)
    U_HOME=$(echo "$USER_DATA" | cut -d: -f2)
    
    if [ ! -d "$U_HOME" ]; then
        RESULT="취약"
        VULN_ACCOUNTS="${VULN_ACCOUNTS}${U_NAME}(${U_HOME}) "
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 사용자의 홈 디렉터리가 시스템에 존재합니다."
else
    STATUS="홈 디렉터리가 존재하지 않는 계정이 식별되었습니다: ${VULN_ACCOUNTS}"
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
| 대응방안 | 홈 디렉터리가 없는 불필요한 계정 삭제 또는 디렉터리 생성 |

__MD_EOF__
