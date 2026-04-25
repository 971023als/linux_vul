#!/bin/bash
# shell_script/oracle/U-34.sh
# -----------------------------------------------------------------------------
# [U-34] DNS Zone Transfer 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 비인가된 사용자의 Zone Transfer를 제한하여 내부 네트워크 정보 유출 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-34"
CATEGORY="서비스 관리"
RISK="상"
ITEM="DNS Zone Transfer 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/named.conf"

if [ -f "$TARGET" ]; then
    if grep -r "allow-transfer" "$TARGET" /etc/named.conf /etc/named.rfc1912.zones 2>/dev/null | grep -q "any"; then
        RESULT="취약"
        STATUS="DNS 설정에 모든 호스트(any)로의 Zone Transfer가 허용되어 있습니다."
    elif ! grep -rq "allow-transfer" "$TARGET" /etc/named.conf /etc/named.rfc1912.zones 2>/dev/null; then
        RESULT="취약"
        STATUS="DNS 설정에 Zone Transfer 제한(allow-transfer)이 설정되어 있지 않습니다."
    else
        STATUS="Zone Transfer가 특정 호스트로 적절히 제한되어 있습니다."
    fi
else
    STATUS="DNS 설정 파일($TARGET)이 존재하지 않습니다(해당없음)."
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
| 대응방안 | named.conf 에서 allow-transfer { localhost; [IP]; }; 로 특정 호스트만 허용 |

__MD_EOF__
