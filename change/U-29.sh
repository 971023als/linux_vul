#!/bin/bash

# 서비스 비활성화 함수
disable_service() {
    local service_name=$1
    local service_path="/etc/xinetd.d/$service_name"
    local inetd_conf="/etc/inetd.conf"

    # /etc/xinetd.d 디렉터리 내의 서비스 파일이 있는 경우
    if [ -f "$service_path" ]; then
        sed -i 's/disable\s*=\s*no/disable = yes/' "$service_path"
        echo "$service_name 서비스가 $service_path 파일에서 비활성화되었습니다."
    fi

    # /etc/inetd.conf 파일 내의 서비스가 있는 경우
    if grep -E "^$service_name\s" "$inetd_conf" &> /dev/null; then
        sed -i "/^$service_name\s/s/^/#/" "$inetd_conf"
        echo "$service_name 서비스가 $inetd_conf 파일에서 비활성화되었습니다."
    fi
}

# tftp, talk, ntalk 서비스 비활성화
services=("tftp" "talk" "ntalk")
for service in "${services[@]}"; do
    disable_service "$service"
done

echo "tftp, talk, ntalk 서비스가 모두 비활성화되었습니다."
