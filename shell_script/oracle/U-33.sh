#!/bin/bash
# shell_script/oracle/U-33.sh
# -----------------------------------------------------------------------------
# [U-33] DNS 보안 버전 패치 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 최신 버전의 DNS(BIND)를 유지하여 알려진 취약점을 통한 서비스 거부 및 변조 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-33"
CATEGORY="서비스 관리"
RISK="상"
ITEM="DNS 보안 버전 패치"

RESULT="양호"
STATUS=""

if systemctl is-active --quiet named 2>/dev/null; then
    VERSION=$(named -v 2>/dev/null)
    STATUS="DNS(named) 서비스가 실행 중입니다. ($VERSION)"
    RESULT="양호"
else
    STATUS="DNS(named) 서비스가 활성화되어 있지 않습니다."
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
| 대응방안 | DNS 서비스를 최신 버전으로 업데이트하거나 불필요 시 중지 |

__MD_EOF__
