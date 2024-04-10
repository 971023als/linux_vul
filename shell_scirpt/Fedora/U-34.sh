#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-34"
위험도="상"
진단_항목="DNS Zone Transfer 설정"
대응방안="Zone Transfer를 허가된 사용자에게만 허용"
현황=()
named_conf_path="/etc/named.conf"

# DNS 서비스 실행 여부 확인
if ps -ef | grep -i 'named' | grep -v 'grep' &> /dev/null; then
    dns_service_running=true
else
    dns_service_running=false
fi

if $dns_service_running; then
    if [ -f "$named_conf_path" ]; then
        if grep -q "allow-transfer { any; }" "$named_conf_path"; then
            진단_결과="취약"
            현황+=("/etc/named.conf 파일에 allow-transfer { any; } 설정이 있습니다.")
        else
            진단_결과="양호"
            현황+=("DNS Zone Transfer가 허가된 사용자에게만 허용되어 있습니다.")
        fi
    else
        진단_결과="양호"
        현황+=("/etc/named.conf 파일이 존재하지 않습니다. DNS 서비스 미사용 가능성.")
    fi
else
    진단_결과="양호"
    현황+=("DNS 서비스가 실행 중이지 않습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
