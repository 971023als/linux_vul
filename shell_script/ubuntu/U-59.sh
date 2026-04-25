#!/bin/bash
# shell_script/ubuntu/U-59.sh
# -----------------------------------------------------------------------------
# [U-59] SNMP 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 SNMP 서비스를 중지하여 정보 수집 공격 및 원격 설정 변경 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-59"
CATEGORY="서비스 관리"
RISK="중"
ITEM="SNMP 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. SNMP 서비스 실행 여부 확인
if systemctl is-active --quiet snmpd 2>/dev/null; then
    RESULT="취약"
    STATUS="SNMP 서비스(snmpd)가 활성화되어 있습니다."
else
    STATUS="SNMP 서비스가 비활성화되어 있습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
else
    # 업무상 사용하는 경우를 위해 '수동 검토' 의견 포함
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
| 대응방안 | SNMP 서비스 중지 (systemctl stop snmpd && systemctl disable snmpd) |

__MD_EOF__
