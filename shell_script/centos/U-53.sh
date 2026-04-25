#!/bin/bash
# shell_script/centos/U-53.sh
# -----------------------------------------------------------------------------
# [U-53] 사용자 shell 제한 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 로그인이 불필요한 시스템 계정에 제한된 셸을 부여하여 비인가 로그인 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-53"
CATEGORY="계정 관리"
RISK="하"
ITEM="사용자 shell 제한"

RESULT="양호"
STATUS=""
VULN_ACCOUNTS=""

# 1. RHEL 계열 시스템 계정(UID 1000 미만) 중 셸 제한이 필요한 계정 리스트
# (root, sync, shutdown, halt 제외)
SYSTEM_ACCOUNTS=$(awk -F: '$3 < 1000 && $1 !~ /root|sync|shutdown|halt/ {print $1}' /etc/passwd)

for ACC in $SYSTEM_ACCOUNTS; do
    SHELL_VAL=$(getent passwd "$ACC" | cut -d: -f7)
    if [[ "$SHELL_VAL" != *"/nologin" ]] && [[ "$SHELL_VAL" != *"/false" ]]; then
        VULN_ACCOUNTS="${VULN_ACCOUNTS}${ACC}(${SHELL_VAL}) "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 시스템 계정에 대해 셸 제한이 적절히 설정되어 있습니다."
else
    STATUS="다음 시스템 계정들의 셸 제한이 설정되어 있지 않습니다: ${VULN_ACCOUNTS}"
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
| 대응방안 | usermod -s /sbin/nologin [계정명] 명령으로 셸 제한 설정 |

__MD_EOF__
