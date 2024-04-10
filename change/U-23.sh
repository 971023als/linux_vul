#!/bin/bash

vulnerable_services=("echo" "discard" "daytime" "chargen")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# /etc/xinetd.d 디렉터리 내의 서비스 비활성화
for service in "${vulnerable_services[@]}"; do
    service_path="$xinetd_dir/$service"
    if [ -f "$service_path" ]; then
        sed -i 's/disable\s*=\s*no/disable = yes/' "$service_path"
        echo "$service 서비스가 $service_path 파일에서 비활성화되었습니다."
    fi
done

# /etc/inetd.conf 파일 내의 서비스 주석 처리
if [ -f "$inetd_conf" ]; then
    for service in "${vulnerable_services[@]}"; do
        sed -i "/^$service /s/^/#/" "$inetd_conf"
        echo "$service 서비스가 $inetd_conf 파일에서 비활성화되었습니다."
    done
fi

echo "모든 DoS 공격에 취약한 서비스가 비활성화되었습니다."
