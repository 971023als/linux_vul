#!/bin/bash

# Finger 서비스 비활성화 조치
# /etc/inetd.conf 또는 /etc/xinetd.d/ 내 Finger 서비스 설정 비활성화

# inetd를 사용하는 경우
if [ -f "/etc/inetd.conf" ]; then
    sed -i '/finger/s/^/#/' /etc/inetd.conf
    echo "/etc/inetd.conf에서 Finger 서비스 비활성화됨."
fi

# xinetd를 사용하는 경우
if [ -d "/etc/xinetd.d" ]; then
    for service_file in /etc/xinetd.d/*finger*; do
        if [ -f "$service_file" ]; then
            sed -i 's/disable\s*=\s*no/disable = yes/' "$service_file"
            echo "$service_file에서 Finger 서비스 비활성화됨."
        fi
    done
fi

# 서비스 재시작 또는 systemctl 사용하여 서비스 비활성화
if systemctl is-active --quiet finger; then
    systemctl stop finger
    systemctl disable finger
    echo "systemctl을 사용하여 Finger 서비스 비활성화 완료."
elif service --status-all | grep -Fq 'finger'; then
    service finger stop
    update-rc.d finger disable
    echo "service 명령어를 사용하여 Finger 서비스 비활성화 완료."
fi

echo "Finger 서비스 비활성화 조치가 완료되었습니다."
