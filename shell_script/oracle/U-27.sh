#!/bin/bash
# shell_script/oracle/U-27.sh
# -----------------------------------------------------------------------------
# [U-27] RPC 서비스 비활성화 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 보안 결함이 많은 RPC 서비스들을 차단하여 원격 코드 실행 및 정보 유출 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-27"
CATEGORY="서비스 관리"
RISK="상"
ITEM="RPC 서비스 비활성화"

RESULT="양호"
STATUS=""

RPC_SERVICES=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "pcnfsd" "rpc.statd" "rpc.nisd" "rpc.pcnfsd")
ACTIVE_RPC=""

for SVC in "${RPC_SERVICES[@]}"; do
    if pgrep -x "$SVC" > /dev/null || systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_RPC="${ACTIVE_RPC}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="취약한 RPC 서비스가 모두 비활성화되어 있습니다."
else
    STATUS="취약한 RPC 서비스가 활성화되어 있습니다: ${ACTIVE_RPC}"
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
| 대응방안 | 불필요한 RPC 서비스 중지 및 비활성화 |

__MD_EOF__
