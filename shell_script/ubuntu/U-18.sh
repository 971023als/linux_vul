#!/bin/bash
# shell_script/ubuntu/U-18.sh
# -----------------------------------------------------------------------------
# [U-18] 접속 IP 및 포트 제한
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.4.7(원격접근 통제)
# - 목적: 허용된 IP/포트 외의 접근을 차단하여 불필요한 노출 및 공격 면 최소화
# -----------------------------------------------------------------------------

set -u

CODE="U-18"
CATEGORY="서비스 관리"
RISK="상"
ITEM="접속 IP 및 포트 제한"

RESULT="양호"
STATUS=""

# 1. TCP Wrappers 점검
ALLOW_FILE="/etc/hosts.allow"
DENY_FILE="/etc/hosts.deny"
TCPW_CONFIGURED=false

if [ -f "$DENY_FILE" ] && grep -qi "ALL" "$DENY_FILE"; then
    TCPW_CONFIGURED=true
fi

# 2. 방화벽(UFW/IPTables) 점검
FIREWALL_ACTIVE=false
if command -v ufw >/dev/null 2>&1; then
    if ufw status | grep -q "Status: active"; then
        FIREWALL_ACTIVE=true
    fi
fi

if ! $TCPW_CONFIGURED && ! $FIREWALL_ACTIVE; then
    RESULT="취약"
    STATUS="TCP Wrappers(hosts.deny) 또는 UFW 방화벽이 활성화되어 있지 않습니다."
else
    STATUS="[양호] "
    $TCPW_CONFIGURED && STATUS="${STATUS}TCP Wrappers가 설정되어 있습니다. "
    $FIREWALL_ACTIVE && STATUS="${STATUS}UFW 방화벽이 활성화되어 있습니다."
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
| 대응방안 | 1. /etc/hosts.deny 에 ALL: ALL 설정 후 hosts.allow 에 허용 IP 등록<br>2. ufw enable 명령으로 방화벽 활성화 및 규칙 설정 |

__MD_EOF__
