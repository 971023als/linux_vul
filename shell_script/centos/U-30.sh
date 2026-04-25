#!/bin/bash
# shell_script/centos/U-30.sh
# -----------------------------------------------------------------------------
# [U-30] 메일 서비스 비활성화 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 메일 서비스를 중지하여 외부 공격자의 악용 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-30"
CATEGORY="서비스 관리"
RISK="상"
ITEM="메일 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 주요 SMTP 서비스 확인
SMTP_SERVICES=("sendmail" "postfix")
ACTIVE_SVC=""

for SVC in "${SMTP_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_SVC="${ACTIVE_SVC}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="메일 서비스(SMTP)가 모두 비활성화되어 있습니다."
else
    STATUS="메일 서비스가 활성화되어 있습니다: ${ACTIVE_SVC} (업무상 불필요 시 중지 권고)"
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
| 대응방안 | 메일 서비스 중지 (systemctl stop postfix && systemctl disable postfix) |

__MD_EOF__
