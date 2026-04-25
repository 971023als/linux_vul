#!/bin/bash

# SNMP 서비스 사용 점검 및 비활성화 스크립트

# SNMP 서비스 상태 점검
snmp_service_status=$(ps -ef | grep '[s]nmp')

if [ -n "$snmp_service_status" ]; then
    echo "SNMP 서비스가 활성화되어 있습니다. 비활성화를 권장합니다."

    # SNMP 서비스 비활성화 (systemctl이 사용 가능한 경우)
    if command -v systemctl > /dev/null 2>&1; then
        echo "systemctl을 사용하여 SNMP 서비스를 비활성화합니다."
        systemctl stop snmpd
        systemctl disable snmpd
        echo "U-66 SNMP 서비스가 비활성화되었습니다."
    else
        echo "U-66 systemctl을 사용할 수 없습니다. SNMP 서비스를 수동으로 비활성화하세요."
    fi
else
    echo "U-66 SNMP 서비스가 비활성화되어 있거나 사용되지 않고 있습니다. 양호합니다."
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-66"
_change_item="SNMP 서비스가 활성화되어 있습니다. 비활성화를 권장"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
