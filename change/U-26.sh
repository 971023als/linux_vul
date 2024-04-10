#!/bin/bash

# automountd 또는 autofs 서비스 비활성화 함수
disable_service() {
    local service_name=$1
    # systemd를 사용하는 시스템의 경우
    if systemctl is-active --quiet $service_name; then
        systemctl stop $service_name
        systemctl disable $service_name
        echo "$service_name 서비스가 비활성화되었습니다."
    elif service --status-all | grep -Fq $service_name; then
        # SysVinit를 사용하는 시스템의 경우
        service $service_name stop
        chkconfig $service_name off
        echo "$service_name 서비스가 비활성화되었습니다."
    else
        echo "$service_name 서비스는 이미 비활성화 상태이거나, 시스템에 존재하지 않습니다."
    fi
}

# automountd와 autofs 서비스 비활성화
disable_service "autofs"
disable_service "automount"

echo "automountd 및 autofs 서비스 비활성화 조치가 완료되었습니다."
