#!/bin/bash
# shell_script/ubuntu/U-27.sh
# -----------------------------------------------------------------------------
# [U-27] RPC 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 RPC 서비스를 차단하여 원격지에서의 시스템 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-27"
CATEGORY="서비스 관리"
RISK="상"
ITEM="RPC 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. rpcbind 서비스 점검 (Ubuntu/Debian)
if command -v systemctl >/dev/null 2>&1; then
    # rpcbind 는 많은 서비스의 의존성이므로 신중히 점검
    if systemctl is-active --quiet rpcbind 2>/dev/null; then
        RESULT="취약"
        STATUS="rpcbind 서비스가 활성화되어 있습니다."
    fi
fi

# 2. 개별 RPC 서비스(rstatd, rusersd, rwalld, sprayd 등) 점검
RPC_SERVICES=("rstatd" "rusersd" "rwalld" "sprayd")
if [ -d "/etc/xinetd.d" ]; then
    for SVC in "${RPC_SERVICES[@]}"; do
        if grep -rEi "disable\s*=\s*no" "/etc/xinetd.d/" 2>/dev/null | grep -qi "$SVC"; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }${SVC} 서비스(xinetd)가 활성화되어 있습니다."
        fi
    done
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 불필요한 RPC 서비스가 비활성화되어 있습니다."
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
| 대응방안 | 불필요한 RPC 서비스 중지 및 비활성화 (systemctl stop/disable rpcbind) |

__MD_EOF__
