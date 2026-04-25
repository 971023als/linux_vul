#!/bin/bash
# shell_script/centos/U-60.sh
# -----------------------------------------------------------------------------
# [U-60] SNMP Community String 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 기본 또는 단순한 Community String을 변경하여 비인가된 시스템 정보 유출 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-60"
CATEGORY="서비스 관리"
RISK="중"
ITEM="SNMP Community String 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/snmp/snmpd.conf"

# 1. SNMP 서비스 실행 여부 및 설정 확인
if [ -f "$TARGET" ]; then
    # 취약한 기본 스트링(public, private) 사용 여부 확인
    if grep -v "^#" "$TARGET" | grep -Ei "com2sec|rocommunity|rwcommunity" | grep -Ei "public|private" > /dev/null; then
        RESULT="취약"
        STATUS="SNMP 설정에 취약한 Community String(public 또는 private)이 사용 중입니다."
    else
        STATUS="SNMP Community String이 기본값이 아닌 값으로 설정되어 있습니다."
    fi
else
    STATUS="SNMP 설정 파일($TARGET)이 존재하지 않습니다(해당없음)."
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
| 대응방안 | snmpd.conf 에서 public/private 대신 복잡한 문자열로 변경 |

__MD_EOF__
