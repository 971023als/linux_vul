#!/bin/bash
# shell_script/oracle/U-68.sh
# -----------------------------------------------------------------------------
# [U-68] 홈 디렉터리 소유자 및 권한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 타인의 홈 디렉터리 접근 및 수정을 차단하여 개인 정보 및 설정 보호
# -----------------------------------------------------------------------------

set -u

CODE="U-68"
CATEGORY="계정 관리"
RISK="중"
ITEM="홈 디렉터리 소유자 및 권한 설정"

RESULT="양호"
STATUS=""
VULN_DIRS=""

USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1":"$6}' /etc/passwd)

for USER_DATA in $USERS; do
    U_NAME=$(echo "$USER_DATA" | cut -d: -f1)
    U_HOME=$(echo "$USER_DATA" | cut -d: -f2)
    
    if [ -d "$U_HOME" ]; then
        OWNER=$(stat -c %U "$U_HOME")
        PERM=$(stat -c %a "$U_HOME")
        
        if [ "$OWNER" != "$U_NAME" ] || [ "${PERM: -1}" -gt 0 ]; then
            RESULT="취약"
            VULN_DIRS="${VULN_DIRS}${U_HOME}(소유:${OWNER},권한:${PERM}) "
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 사용자 홈 디렉터리의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="다음 홈 디렉터리들의 설정이 취약합니다: ${VULN_DIRS}"
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
| 대응방안 | chown [계정] [홈디렉터리] && chmod 750 [홈디렉터리] |

__MD_EOF__
