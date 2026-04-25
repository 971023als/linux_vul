#!/bin/bash
# shell_script/oracle/U-18.sh
# -----------------------------------------------------------------------------
# [U-18] 접속 IP 및 포트 제한 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 허가된 IP와 서비스 포트만 접근을 허용하여 외부 공격 노출 최소화
# -----------------------------------------------------------------------------

set -u

CODE="U-18"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="접속 IP 및 포트 제한"

RESULT="양호"
STATUS=""

if systemctl is-active --quiet firewalld 2>/dev/null; then
    RULES_COUNT=$(firewall-cmd --list-all --permanent | grep -E "services:|ports:|rich rules:" | wc -l)
    if [ "$RULES_COUNT" -gt 0 ]; then
        STATUS="firewalld 가 활성화되어 있으며, 정책이 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="firewalld 가 실행 중이나 세부 제한 정책이 정의되어 있지 않습니다."
    fi
elif systemctl is-active --quiet iptables 2>/dev/null; then
    IPT_COUNT=$(iptables -L -n | grep -vE "^Chain|^target" | wc -l)
    if [ "$IPT_COUNT" -gt 0 ]; then
        STATUS="iptables 가 활성화되어 있으며, 정책이 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="iptables 가 실행 중이나 세부 제한 정책이 정의되어 있지 않습니다."
    fi
else
    RESULT="취약"
    STATUS="firewalld 및 iptables 방화벽 서비스가 비활성화되어 있습니다."
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
| 대응방안 | firewalld 또는 iptables를 활성화하고 인가된 IP/포트만 허용하도록 설정 |

__MD_EOF__
