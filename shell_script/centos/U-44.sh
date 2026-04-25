#!/bin/bash
# shell_script/centos/U-44.sh
# -----------------------------------------------------------------------------
# [U-44] root 계정 외 UID가 0인 계정 존재 여부 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.1(사용자 식별)
# - 목적: 관리자 권한(UID 0)을 가진 다른 계정을 식별하여 권한 남용 및 백도어 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-44"
CATEGORY="계정 관리"
RISK="상"
ITEM="root 계정 외 UID가 0인 계정 존재 여부"

RESULT="양호"
STATUS=""

# 1. UID 가 0인 모든 계정 추출
UID_ZERO_ACCOUNTS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
ACCOUNTS_COUNT=$(echo "$UID_ZERO_ACCOUNTS" | wc -w)

if [ "$ACCOUNTS_COUNT" -gt 1 ]; then
    RESULT="취약"
    STATUS="root 외에 UID가 0인 계정이 존재합니다: $(echo $UID_ZERO_ACCOUNTS | sed 's/root //')"
else
    STATUS="UID가 0인 계정이 root 뿐입니다."
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
| 대응방안 | root 외에 UID 0인 계정이 있다면 해당 계정의 UID를 변경하거나 삭제 |

__MD_EOF__
