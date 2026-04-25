#!/bin/bash
# shell_script/centos/U-48.sh
# -----------------------------------------------------------------------------
# [U-48] 관리자 그룹에 최소한의 계정 포함 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.5(특수 권한 관리)
# - 목적: root 그룹(GID 0)에 소속된 계정을 최소화하여 관리자 권한 오남용 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-48"
CATEGORY="계정 관리"
RISK="중"
ITEM="관리자 그룹에 최소한의 계정 포함"

RESULT="양호"
STATUS=""

# 1. GID 가 0인 그룹명 확인 (보통 root)
GROUP_NAME=$(awk -F: '$3 == 0 {print $1}' /etc/group | head -n 1)

# 2. 해당 그룹에 소속된 계정 리스트 추출
GROUP_MEMBERS=$(grep "^${GROUP_NAME}:" /etc/group | cut -d: -f4)
PRIMARY_MEMBERS=$(awk -F: -v gid=0 '$4 == gid {print $1}' /etc/passwd)

ALL_MEMBERS=$(echo "${GROUP_MEMBERS} ${PRIMARY_MEMBERS}" | tr ',' ' ' | xargs -n1 | sort -u | xargs)

if [ -n "$ALL_MEMBERS" ]; then
    # root 외의 계정이 포함되어 있는지 확인
    VULN_MEMBERS=$(echo "$ALL_MEMBERS" | sed 's/\broot\b//g' | xargs)
    if [ -n "$VULN_MEMBERS" ]; then
        RESULT="취약"
        STATUS="root 그룹에 root 외의 계정이 포함되어 있습니다: ${VULN_MEMBERS}"
    else
        STATUS="root 그룹에 root 계정만 적절히 포함되어 있습니다."
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
| 대응방안 | root 그룹에서 불필요한 계정 제거 (/etc/group 수정) |

__MD_EOF__
