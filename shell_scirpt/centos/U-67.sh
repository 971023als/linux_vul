#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-67"
severity="중"
check_item="SNMP 서비스 Community String의 복잡성 설정"
result=""
status=""
recommendation="SNMP Community 이름이 public, private이 아닌 경우"

# SNMP 서비스 실행 여부 확인
if ! ps -ef | grep -i "snmp" | grep -v "grep" > /dev/null; then
    result="양호"
    status="SNMP 서비스를 사용하지 않고 있습니다."
else
    # snmpd.conf 파일 검색
    snmpdconf_files=$(find / -name snmpd.conf -type f 2>/dev/null)
    weak_string_found=false

    if [[ -z "$snmpdconf_files" ]]; then
        result="취약"
        status="SNMP 서비스를 사용하고 있으나, Community String을 설정하는 파일이 없습니다."
    else
        for file_path in $snmpdconf_files; do
            if grep -Eiq "\b(public|private)\b" "$file_path"; then
                weak_string_found=true
                result="취약"
                status="SNMP Community String이 취약(public 또는 private)으로 설정되어 있습니다. 파일: $file_path"
                break
            fi
        done
    fi

    if ! $weak_string_found && [[ -n "$snmpdconf_files" ]]; then
        result="양호"
        status="SNMP Community String이 적절히 설정되어 있습니다."
    fi
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황: $status"
echo "대응방안: $recommendation"
