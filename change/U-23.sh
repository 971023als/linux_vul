#!/bin/bash

# DoS 취약 서비스 목록
vulnerable_services=("echo" "discard" "daytime" "chargen")

# /etc/xinetd.d 내의 서비스 비활성화
for service in "${vulnerable_services[@]}"; do
    service_path="/etc/xinetd.d/$service"
    if [ -f "$service_path" ]; then
        echo "disabling $service service in xinetd"
        sed -i 's/disable[ ]*=[ ]*no/disable = yes/g' "$service_path"
    fi
done

# /etc/inetd.conf 내의 서비스 비활성화
for service in "${vulnerable_services[@]}"; do
    if grep -q "^$service" /etc/inetd.conf 2>/dev/null; then
        echo "disabling $service service in inetd"
        sed -i "/^$service/s/^/#/" /etc/inetd.conf
    fi
done

echo "U-23 DoS 공격에 취약한 서비스 비활성화 작업이 완료되었습니다."
