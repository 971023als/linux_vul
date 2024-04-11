#!/bin/bash

# tftp, talk, ntalk 서비스 비활성화
services=("tftp" "talk" "ntalk")

echo "tftp, talk, ntalk 서비스를 확인하고 있습니다..."

# /etc/xinetd.d 디렉터리 내의 서비스 파일 수정
for service in "${services[@]}"; do
    if [ -f "/etc/xinetd.d/$service" ]; then
        echo "$service 서비스를 비활성화합니다."
        sed -i '/disable[ ]*=[ ]*no/c\disable         = yes' "/etc/xinetd.d/$service"
    fi
done

# /etc/inetd.conf 파일 내의 서비스 주석 처리
if [ -f "/etc/inetd.conf" ]; then
    for service in "${services[@]}"; do
        if grep -q "^$service" "/etc/inetd.conf"; then
            echo "$service 서비스를 /etc/inetd.conf에서 주석 처리합니다."
            sed -i "/^$service/s/^/#/" "/etc/inetd.conf"
        fi
    done
fi

echo "U-29 tftp, talk, ntalk 서비스 비활성화 작업이 완료되었습니다."
