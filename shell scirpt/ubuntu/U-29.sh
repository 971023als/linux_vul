#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-29"
위험도="상"
진단_항목="tftp, talk 서비스 비활성화"
대응방안="tftp, talk, ntalk 서비스 비활성화"
현황=()

services=("tftp" "talk" "ntalk")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"
service_found=false

# /etc/xinetd.d 디렉터리 내 서비스 검사
if [ -d "$xinetd_dir" ]; then
    for service in "${services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -q 'disable\s*=\s*yes' "$service_path"; then
                현황+=("$service 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.")
                service_found=true
            fi
        fi
    done
fi

# /etc/inetd.conf 파일 내 서비스 검사
if [ -f "$inetd_conf" ]; then
    for service in "${services[@]}"; do
        if grep -E "^$service\s" "$inetd_conf" &> /dev/null; then
            현황+=("$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
            service_found=true
        fi
    done
fi

# 진단 결과 결정
if $service_found; then
    진단_결과="취약"
else
    진단_결과="양호"
    현황+=("tftp, talk, ntalk 서비스가 모두 비활성화되어 있습니다.")
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
