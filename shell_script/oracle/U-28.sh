#!/bin/bash
# shell_script/oracle/U-28.sh
# -----------------------------------------------------------------------------
# [U-28] NIS, NIS+ 서비스 비활성화 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 암호화되지 않은 네트워크 정보 서비스(NIS)를 차단하여 인증 정보 탈취 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-28"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NIS, NIS+ 서비스 비활성화"

RESULT="양호"
STATUS=""

NIS_SERVICES=("ypserv" "ypbind" "yppasswdd" "ypxfrd")
ACTIVE_SVC=""

for SVC in "${NIS_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_SVC="${ACTIVE_SVC}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="NIS 관련 서비스가 모두 비활성화되어 있습니다."
else
    STATUS="NIS 관련 서비스가 활성화되어 있습니다: ${ACTIVE_SVC}"
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
| 대응방안 | NIS 서비스 중지 (systemctl stop ypserv && systemctl disable ypserv) |

__MD_EOF__
