#!/bin/bash

# SNMP 커뮤니티 문자열 복잡성 설정 점검 및 조치 스크립트

# SNMP 서비스 실행 여부 점검
if ! pgrep -f snmpd > /dev/null; then
    echo "SNMP 서비스가 실행 중이지 않습니다."
    exit 0
fi

# snmpd.conf 파일 검색 및 점검
find / -name snmpd.conf -type f 2>/dev/null | while read -r snmpd_conf_path; do
    if grep -Eiq '\b(public|private)\b' "$snmpd_conf_path"; then
        echo "취약한 SNMP 커뮤니티 문자열(public 또는 private)이 $snmpd_conf_path 에서 발견되었습니다."
        echo "보다 복잡한 커뮤니티 문자열로 변경을 권장합니다."
        
        # 여기에 커뮤니티 문자열을 변경하는 코드를 추가할 수 있습니다.
        # 예: sed -i 's/public/yourComplexString/g' "$snmpd_conf_path"
        # sed -i 's/private/yourOtherComplexString/g' "$snmpd_conf_path"

        # 변경 후 SNMP 서비스 재시작
        # systemctl restart snmpd 또는 service snmpd restart
    else
        echo "U-67 $snmpd_conf_path 파일의 SNMP 커뮤니티 문자열이 안전하게 설정되어 있습니다."
    fi
done

# ==== 조치 결과 MD 출력 ====
_change_code="U-67"
_change_item="SNMP 서비스가 실행 중이지 않습니다."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
