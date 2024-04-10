#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-66"
severity="중"
check_item="SNMP 서비스 구동 점검"
result=""
status=""
recommendation="SNMP 서비스 사용을 필요로 하지 않는 경우, 서비스를 비활성화"

# SNMP 서비스 실행 여부 확인
if ps -ef | grep -i "snmp" | grep -v "grep" > /dev/null; then
    result="취약"
    status="SNMP 서비스를 사용하고 있습니다."
else
    result="양호"
    status="SNMP 서비스를 사용하지 않고 있습니다."
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황: $status"
echo "대응방안: $recommendation"
