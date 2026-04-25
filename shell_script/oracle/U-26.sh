#!/bin/bash
# shell_script/oracle/U-26.sh
# -----------------------------------------------------------------------------
# [U-26] automountd 서비스 비활성화 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 원격 파일 시스템을 자동으로 마운트하는 서비스를 차단하여 부적절한 파일 노출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-26"
CATEGORY="서비스 관리"
RISK="상"
ITEM="automountd 서비스 비활성화"

RESULT="양호"
STATUS=""

if systemctl is-active --quiet autofs 2>/dev/null; then
    RESULT="취약"
    STATUS="autofs(automountd) 서비스가 활성화되어 있습니다."
else
    STATUS="autofs 서비스가 비활성화되어 있습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
else
    STATUS="[취약] $STATUS (업무상 불필요 시 중지 권고)"
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
| 대응방안 | autofs 서비스 중지 (systemctl stop autofs && systemctl disable autofs) |

__MD_EOF__
