#!/bin/bash

# NIS 서비스 비활성화 함수
disable_nis_service() {
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

# NIS 관련 서비스 목록
nis_services=("ypserv" "ypbind" "ypxfrd" "rpc.yppasswdd" "rpc.ypupdated")

# 각 서비스에 대해 비활성화 시도
for service in "${nis_services[@]}"; do
    disable_nis_service $service
done

echo "모든 NIS 관련 서비스가 비활성화되었습니다."
